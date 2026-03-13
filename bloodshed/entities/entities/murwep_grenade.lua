AddCSLuaFile()

ENT.Base = "obj_vj_projectile_base"
ENT.PrintName = "Grenade"

game.AddParticles("particles/ac_explosions.pcf")

if SERVER then
    function ENT:Initialize()
        if self.F1 then
            self:SetModel("models/simpnades/w_f1.mdl")
        else
            self:SetModel("models/simpnades/w_m67.mdl")
        end
        self:PhysicsInit(SOLID_VPHYSICS)
        local phys = self:GetPhysicsObject()
        if IsValid(phys) then
            phys:Wake()
        end
        self.Activated = false

        if !IsValid(self.OwnerTrap) then
            timer.Simple(4, function()
                if !IsValid(self) then return end
                self:Explode()
            end)
            self.VJ_ID_Grenade = true
            self.VJ_ID_Grabbable = true
        else
            if IsValid(phys) then
                phys:Sleep()
                phys:EnableMotion(false)
            end
            self:SetCollisionGroup(COLLISION_GROUP_DEBRIS_TRIGGER)
            if self.StakeLimit then
                self.Limited = true
            end
        end
    end

    function ENT:Think()
        if self.Activated then return end
        
        if not IsValid(self.StakeEnt) then
            return
        end

        if self.Limited and self:WorldSpaceCenter():Distance(self.StakeEnt:WorldSpaceCenter()) > self.StakeLimit then
            self:ActivateGrenade()
            return
        end
        

        local checkHeights = {0, 10, 20, 30, 40}
        local stakePos = self.StakeEnt:GetPos() + self.StakeEnt:GetUp() * 5
        local grenadePos = self:GetPos()
        
        local shouldActivate = false
        local hitEntity = nil
        
        for _, heightOffset in ipairs(checkHeights) do
            local tr = util.TraceLine({
                start = grenadePos + Vector(0, 0, 5 + heightOffset),
                endpos = stakePos + Vector(0, 0, heightOffset),
                filter = {self, self.OwnerTrap, self:GetParent(), self.StakeEnt, self.StakeEnt:GetParent()},
                mask = MASK_SOLID
            })
            
            local ent = tr.Entity
            if IsValid(ent) then
                if ent:IsPlayer() then
                    if ent:Alive() and ent:Health() > 0 and !ent:IsKiller() and ent != self.OwnerTrap then
                        shouldActivate = true
                        hitEntity = ent
                        break
                    end  
                elseif ent:IsNPC() then
                    if ent:Health() > 0 then
                        if ent:GetClass() == "npc_vj_bloodshed_suspect" then
                            if IsValid(self.OwnerTrap) and self.OwnerTrap:IsPlayer() then
                                shouldActivate = true
                                hitEntity = ent
                                break
                            elseif IsValid(self.OwnerTrap) and self.OwnerTrap:GetClass() == "npc_vj_bloodshed_suspect" then

                            end
                        else
                            shouldActivate = true
                            hitEntity = ent
                            break
                        end
                    end
                else
                    local phys = ent:GetPhysicsObject()
                    if IsValid(phys) and phys:IsMotionEnabled() then
                        shouldActivate = true
                        hitEntity = ent
                        break
                    end
                end
            end
        end
        
        if shouldActivate and IsValid(hitEntity) then
            self:ActivateGrenade()
        end
        
        self:NextThink(CurTime() + 0.05)
        return true
    end

    function ENT:PhysicsCollide(data, phys)
        if data.Speed > 50 then
            self:EmitSound(")murdered/weapons/grenade/m67_bounce_01.wav", 60, math.random(80,120))
            sound.EmitHint(SOUND_DANGER, self:GetPos(), 400, 1, self)
        end
    end

    function ENT:OnTakeDamage(dmg)
        if self.Activated then return end
        if dmg:GetDamage() > 5 then
            self:Explode()
        end
    end

    function ENT:ActivateGrenade()
        if self.Activated then return end
        self.Activated = true
        if IsValid(self.StakeConst) then
            self.StakeConst:Remove()
            self:EmitSound("weapons/tripwire/ropeshoot.wav", 60, math.random(80,120)) 
        end
        timer.Simple(0.1, function()
            if !IsValid(self) then return end
            self:EmitSound(")murdered/weapons/grenade/f1_pinpull.wav", 60, math.random(80,120)) 
        end)
        timer.Simple(1, function()
            if !IsValid(self) then return end
            self:StopSound("weapons/tripwire/ropeshoot.wav")
            self:Explode()
        end)
    end

    function ENT:Bullets()
        local count, det = 14, 0
        timer.Create("grenbullets"..self:EntIndex(), 0.0001, count, function()
            if !IsValid(self) then return end
            det = det + 1
            for i = 1, 20 do
                local dir = VectorRand(-1,1)
                if self:OnGround() and dir.z < 0 then
                    dir.z = math.Rand(0,1)
                end
                local bullet = {} 
                bullet.Attacker = self.PlayerOwner or game.GetWorld()
                bullet.Damage = 50
                bullet.Force = 5
                bullet.Num = 1
                bullet.Src = self:WorldSpaceCenter()
                bullet.Dir = dir
                bullet.Spread = Vector(0, 0, 0)
                bullet.Tracer = 1
                bullet.TracerName = "Tracer"
                bullet.IgnoreEntity = self
                
                self:FireBullets(bullet)
            end
            if det == count then
                SafeRemoveEntityDelayed(self, 0.2)
            end
        end)
    end
    
    function ENT:Explode()
        self.Activated = true
        local num = 1
        if self.SuperGrenade then
            num = math.random(10,100)
        end
        for i=1, num do
            timer.Simple(i/10, function()
                if !IsValid(self) then return end
                self:EmitSound(")murdered/weapons/other/ied_detonate_dist_0"..math.random(1,3)..".wav", 120, math.random(90,110))
                util.ScreenShake(self:GetPos(), 25, 25, 3, 2000)
                ParticleEffect("AC_grenade_explosion", self:GetPos(), Angle(0,0,0))
                ParticleEffect("AC_grenade_explosion_air", self:GetPos(), Angle(0,0,0))
                util.Decal("Scorch", self:GetPos(), self:GetPos()-Vector(0,0,8), self)
                local att = self
                if IsValid(self.PlayerOwner) then
                    att = self.PlayerOwner
                end
                if self.F1 then
                    util.BlastDamage(att, att, self:GetPos(), 400, 200)
                else
                    util.BlastDamage(att, att, self:GetPos(), 300, 250)
                end
                MakeExplosionReverb(self:GetPos())
                if i == num then
                    self:Bullets()
                end
            end)
        end
    end

    function ENT:DisarmTripwire(disarmer)
        if self.Activated then return false end
        if not IsValid(self.OwnerTrap) then return false end
        if not IsValid(disarmer) or not disarmer:IsPlayer() then return false end
        
        net.Start("MuR.TripwireDisarm")
        net.WriteEntity(self)
        net.Send(disarmer)
        
        return true
    end
    
    function ENT:CompleteDisarm(disarmer)
        if self.Activated then return false end
        if not IsValid(self.OwnerTrap) then return false end
        
        local grenadeClass = self.F1 and "mur_f1" or "mur_m67"
        
        if IsValid(disarmer) and disarmer:IsPlayer() then
            disarmer:GiveWeapon(grenadeClass)
        end
        
        if IsValid(self.StakeConst) then
            self.StakeConst:Remove()
        end
        
        if IsValid(self.StakeEnt) then
            self.StakeEnt:Remove()
        end
        
        self:EmitSound("physics/metal/metal_solid_impact_bullet1.wav", 60, 100)
        self:Remove()
        
        return true
    end
    
    function ENT:FailDisarm(disarmer)
        if self.Activated then return false end
        self:ActivateGrenade()
        return true
    end
end