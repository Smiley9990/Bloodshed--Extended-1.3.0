MuR = MuR or {}
MuR.Armor = MuR.Armor or {}

MuR.Armor.BodyParts = {
    ["face"] = {
        bone = "ValveBiped.Bip01_Head1",
        pos = Vector(4, -1, 0),
        ang = Angle(0, 90, 90),
        hitgroups = {HITGROUP_HEAD},
        organs = {"Brain"}
    },
    ["face2"] = {
        bone = "ValveBiped.Bip01_Head1",
        pos = Vector(4, -1, 0),
        ang = Angle(0, 90, 90),
        hitgroups = {HITGROUP_HEAD},
        organs = {"Brain"}
    },
    ["facecover"] = {
        bone = "ValveBiped.Bip01_Head1",
        pos = Vector(0, 0, 0),
        ang = Angle(0, 90, 90),
        hitgroups = {HITGROUP_HEAD},
        organs = {"Brain", "Carotid Artery", "Neck"}
    },
    ["head"] = {
        bone = "ValveBiped.Bip01_Head1",
        pos = Vector(0, 0, 0),
        ang = Angle(0, 0, 0),
        hitgroups = {HITGROUP_HEAD},
        organs = {"Brain", "Carotid Artery", "Neck"}
    },
    ["ears"] = {
        bone = "ValveBiped.Bip01_Head1",
        pos = Vector(4, -1, 0),
        ang = Angle(0, 90, 90),
        hitgroups = {HITGROUP_HEAD},
        organs = {"Brain"}
    },
    ["body"] = {
        bone = "ValveBiped.Bip01_Spine2",
        pos = Vector(0, 0, 0),
        ang = Angle(0, 90, 0),
        hitgroups = {HITGROUP_CHEST, HITGROUP_STOMACH},
        organs = {"Heart", "Right Lung", "Left Lung", "Liver", "Spine"}
    }
}

MuR.Armor.Items = {

    ["pot"] = {
        bodypart = "head",
        model = "models/props_interiors/pot02a.mdl",
        scale = 1.15,
        pos_offset = Vector(6, 0.1, -6),
        ang_offset = Angle(0, 280, 90),
        armor = 5,
        damage_reduction_by_type = {[DMG_SLASH]=0.1, [DMG_CLUB]=0.1},
        gas_protection = 0,
        protected_organs = {"Brain"},
        damage_types = {DMG_SLASH, DMG_CLUB},
        icon = "entities/mur_armor_pot.png",
        overlay = "bs_overlays/pot_overlay.png",
        equip_sound = "physics/metal/metal_solid_impact_hard1.wav",
        unequip_sound = "physics/metal/metal_solid_impact_soft1.wav",
        equip_time = 1.5,
        unequip_time = 1.5
    },
    ["face2_halfmask"] = {
        bodypart = "face2",
        model = "models/eft_props/gear/facecover/facecover_mask.mdl",
        scale = 1,
        pos_offset = Vector(3, 1, 0),
        ang_offset = Angle(0, 270, 270),
        armor = 0,
        damage_reduction_by_type = {[DMG_SLASH]=0.04, [DMG_CLUB]=0.04},
        gas_protection = 0,
        protected_organs = {"Brain"},
        damage_types = {DMG_SLASH, DMG_CLUB},
        icon = "entities/ent_jack_gmod_ezarmor_halfmask.png",
        equip_sound = "murdered/armor/face_equip.wav",
        unequip_sound = "murdered/armor/face_unequip.wav",
        blocks_bodyparts = {"facecover"},
        equip_time = 1.5,
        unequip_time = 1.5
    },
    ["face2_halfmask_skull"] = {
        bodypart = "face2",
        model = "models/eft_props/gear/facecover/facecover_skull_half_mask.mdl",
        scale = 1,
        pos_offset = Vector(3, 1, 0),
        ang_offset = Angle(0, 270, 270),
        armor = 0,
        damage_reduction_by_type = {[DMG_SLASH]=0.04, [DMG_CLUB]=0.04},
        gas_protection = 0,
        protected_organs = {"Brain"},
        damage_types = {DMG_SLASH, DMG_CLUB},
        icon = "entities/ent_jack_gmod_ezarmor_ghosthalfmask.png",
        equip_sound = "murdered/armor/face_equip.wav",
        unequip_sound = "murdered/armor/face_unequip.wav",
        blocks_bodyparts = {"facecover"},
        equip_time = 1.5,
        unequip_time = 1.5
    },
    ["face2_jason"] = {
        bodypart = "face2",
        model = "models/eft_props/gear/facecover/facecover_halloween_jason.mdl",
        scale = 1,
        pos_offset = Vector(2.2, 0, 0),
        ang_offset = Angle(0, 280, 270),
        armor = 0,
        damage_reduction_by_type = {[DMG_SLASH]=0.2, [DMG_CLUB]=0.1},
        gas_protection = 0,
        protected_organs = {"Brain"},
        damage_types = {DMG_SLASH, DMG_CLUB},
        icon = "entities/ent_jack_gmod_ezarmor_jason.png",
        equip_sound = "murdered/armor/face_equip.wav",
        unequip_sound = "murdered/armor/face_unequip.wav",
        blocks_bodyparts = {"facecover", "head", "face"},
        equip_time = 1.5,
        unequip_time = 1.5
    },
    ["face2_cqcm_black"] = {
        bodypart = "face2",
        model = "models/eft_props/gear/facecover/facecover_ballistic_mask.mdl",
        scale = 1,
        pos_offset = Vector(2.2, 0, 0),
        ang_offset = Angle(0, 280, 270),
        armor = 0,
        damage_reduction_by_type = {[DMG_SLASH]=0.5, [DMG_CLUB]=0.5, [DMG_BLAST]=0.2, [DMG_BULLET]=0.3},
        gas_protection = 0,
        protected_organs = {"Brain"},
        damage_types = {DMG_SLASH, DMG_CLUB, DMG_BLAST, DMG_BULLET},
        icon = "entities/ent_jack_gmod_ezarmor_ballisticmask.png",
        equip_sound = "murdered/armor/face_equip.wav",
        unequip_sound = "murdered/armor/face_unequip.wav",
        blocks_bodyparts = {"facecover", "face"},
        equip_time = 1.5,
        unequip_time = 1.5
    },
    ["face2_glorious"] = {
        bodypart = "face2",
        model = "models/eft_props/gear/facecover/facecover_glorious.mdl",
        scale = 1,
        pos_offset = Vector(2.2, 0, 0),
        ang_offset = Angle(0, 280, 270),
        armor = 0,
        damage_reduction_by_type = {[DMG_SLASH]=0.2, [DMG_CLUB]=0.2, [DMG_BLAST]=0.2, [DMG_BULLET]=0.2},
        gas_protection = 0,
        protected_organs = {"Brain"},
        damage_types = {DMG_SLASH, DMG_CLUB, DMG_BLAST, DMG_BULLET},
        icon = "entities/ent_jack_gmod_ezarmor_glorious.png",
        equip_sound = "murdered/armor/face_equip.wav",
        unequip_sound = "murdered/armor/face_unequip.wav",
        blocks_bodyparts = {"facecover", "face"},
        equip_time = 1.5,
        unequip_time = 1.5
    },
    ["face2_deadlyskull"] = {
        bodypart = "face2",
        model = "models/eft_props/gear/facecover/facecover_skullmask.mdl",
        scale = 1,
        pos_offset = Vector(2.2, 0.4, 0),
        ang_offset = Angle(0, 280, 270),
        armor = 0,
        damage_reduction_by_type = {[DMG_SLASH]=0.2, [DMG_CLUB]=0.2, [DMG_BLAST]=0.1, [DMG_BULLET]=0.1},
        gas_protection = 0,
        protected_organs = {"Brain"},
        damage_types = {DMG_SLASH, DMG_CLUB, DMG_BLAST, DMG_BULLET},
        icon = "entities/ent_jack_gmod_ezarmor_deadlyskull.png",
        equip_sound = "murdered/armor/face_equip.wav",
        unequip_sound = "murdered/armor/face_unequip.wav",
        blocks_bodyparts = {"facecover", "face"},
        equip_time = 1.5,
        unequip_time = 1.5
    },
    ["face2_welding_ubey"] = {
        bodypart = "face2",
        model = "models/eft_props/gear/facecover/facecover_boss_welding_ubey.mdl",
        scale = 1,
        pos_offset = Vector(2.2, 0, 0),
        ang_offset = Angle(0, 280, 270),
        armor = 0,
        damage_reduction_by_type = {[DMG_SLASH]=1.3, [DMG_CLUB]=1.3, [DMG_BLAST]=0.5, [DMG_BULLET]=1.0},
        gas_protection = 0,
        protected_organs = {"Brain"},
        damage_types = {DMG_SLASH, DMG_CLUB, DMG_BLAST, DMG_BULLET},
        icon = "entities/ent_jack_gmod_ezarmor_weldingkill.png",
        overlay = "materials/mask_overlays/altyn.png",
        equip_sound = "murdered/armor/face_equip.wav",
        unequip_sound = "murdered/armor/face_unequip.wav",
        blocks_bodyparts = {"facecover", "head", "face"},
        allows_on_blocked = {head = {"cap_boss"}},
        equip_time = 1.5,
        unequip_time = 1.5
    },
    ["face_aviator"] = {
        bodypart = "face",
        model = "models/eft_props/gear/eyewear/glasses_aviator.mdl",
        scale = 1,
        pos_offset = Vector(1.3, 0.4, 0),
        ang_offset = Angle(0, 290, 270),
        armor = 0,
        damage_reduction = 0,
        gas_protection = 0,
        protected_organs = {"Brain"},
        damage_types = {DMG_SLASH},
        icon = "entities/ent_jack_gmod_ezarmor_aviators.png",
        equip_sound = "murdered/armor/face_equip.wav",
        unequip_sound = "murdered/armor/face_unequip.wav",
        equip_time = 0.4,
        unequip_time = 0.4
    },
    ["face_gaswelder"] = {
        bodypart = "face",
        model = "models/eft_props/gear/eyewear/glasses_welder.mdl",
        scale = 1,
        pos_offset = Vector(1.3, 0.4, 0),
        ang_offset = Angle(0, 290, 270),
        armor = 0,
        damage_reduction_by_type = {[DMG_BLAST]=0.04},
        gas_protection = 0,
        protected_organs = {"Brain"},
        damage_types = {DMG_BLAST},
        icon = "entities/ent_jack_gmod_ezarmor_gaswelderglass.png",
        equip_sound = "murdered/armor/face_equip.wav",
        unequip_sound = "murdered/armor/face_unequip.wav",
        equip_time = 0.4,
        unequip_time = 0.4
    },
    ["face_tactical"] = {
        bodypart = "face",
        model = "models/eft_props/gear/eyewear/glasses_tactical.mdl",
        scale = 1,
        pos_offset = Vector(1.3, 0.4, 0),
        ang_offset = Angle(0, 290, 270),
        armor = 0,
        damage_reduction = 0,
        gas_protection = 0,
        protected_organs = {"Brain"},
        damage_types = {DMG_SLASH},
        icon = "entities/ent_jack_gmod_ezarmor_tactical.png",
        equip_sound = "murdered/armor/face_equip.wav",
        unequip_sound = "murdered/armor/face_unequip.wav",
        equip_time = 0.4,
        unequip_time = 0.4
    },
    ["face_raybench"] = {
        bodypart = "face",
        model = "models/eft_props/gear/eyewear/glasses_rayban.mdl",
        scale = 1,
        pos_offset = Vector(1.3, 0.4, 0),
        ang_offset = Angle(0, 290, 270),
        armor = 0,
        damage_reduction = 0,
        gas_protection = 0,
        protected_organs = {"Brain"},
        damage_types = {DMG_SLASH},
        icon = "entities/ent_jack_gmod_ezarmor_raybench.png",
        equip_sound = "murdered/armor/face_equip.wav",
        unequip_sound = "murdered/armor/face_unequip.wav",
        equip_time = 0.4,
        unequip_time = 0.4
    },
    ["face_roundglasses"] = {
        bodypart = "face",
        model = "models/eft_props/gear/eyewear/glasses_aoron.mdl",
        scale = 1,
        pos_offset = Vector(1.3, 0.4, 0),
        ang_offset = Angle(0, 290, 270),
        armor = 0,
        damage_reduction = 0,
        gas_protection = 0,
        protected_organs = {"Brain"},
        damage_types = {DMG_SLASH},
        icon = "entities/ent_jack_gmod_ezarmor_roundglasses.png",
        equip_sound = "murdered/armor/face_equip.wav",
        unequip_sound = "murdered/armor/face_unequip.wav",
        equip_time = 0.4,
        unequip_time = 0.4
    },
    ["face_6b34"] = {
        bodypart = "face",
        model = "models/eft_props/gear/eyewear/glasses_6b34.mdl",
        scale = 1,
        pos_offset = Vector(1.3, 0.4, 0),
        ang_offset = Angle(0, 290, 270),
        armor = 0,
        damage_reduction_by_type = {[DMG_BLAST]=0.04},
        gas_protection = 0,
        protected_organs = {"Brain"},
        damage_types = {DMG_BLAST},
        icon = "entities/ent_jack_gmod_ezarmor_6b34.png",
        equip_sound = "murdered/armor/face_equip.wav",
        unequip_sound = "murdered/armor/face_unequip.wav",
        equip_time = 0.4,
        unequip_time = 0.4
    },
    ["ears_xcel"] = {
        bodypart = "ears",
        model = "models/eft_props/gear/headsets/headset_xcel.mdl",
        scale = 1,
        pos_offset = Vector(1.5, 0.3, 0),
        ang_offset = Angle(0, 290, 270),
        armor = 0,
        damage_reduction = 0,
        gas_protection = 0,
        protected_organs = {"Brain"},
        damage_types = {DMG_SLASH},
        icon = "entities/ent_jack_gmod_ezarmor_xcel.png",
        equip_sound = "murdered/armor/face_equip.wav",
        unequip_sound = "murdered/armor/face_unequip.wav",
        equip_time = 0.4,
        unequip_time = 0.4,
        sound_boost_footsteps = true,
        sound_muffle_other = 0.35,
    },
    ["ears_tactical_sport"] = {
        bodypart = "ears",
        model = "models/eft_props/gear/headsets/headset_tactical_sport.mdl",
        scale = 1,
        pos_offset = Vector(1.5, 0.3, 0),
        ang_offset = Angle(0, 290, 270),
        armor = 0,
        damage_reduction = 0,
        gas_protection = 0,
        protected_organs = {"Brain"},
        damage_types = {DMG_SLASH},
        icon = "entities/ent_jack_gmod_ezarmor_tacticalsport.png",
        equip_sound = "murdered/armor/face_equip.wav",
        unequip_sound = "murdered/armor/face_unequip.wav",
        equip_time = 0.4,
        unequip_time = 0.4,
        sound_boost_footsteps = true,
        sound_muffle_other = 0.35,
    },
    ["ears_razor"] = {
        bodypart = "ears",
        model = "models/eft_props/gear/headsets/headset_razor.mdl",
        scale = 1,
        pos_offset = Vector(1.5, 0.3, 0),
        ang_offset = Angle(0, 290, 270),
        armor = 0,
        damage_reduction = 0,
        gas_protection = 0,
        protected_organs = {"Brain"},
        damage_types = {DMG_SLASH},
        icon = "entities/ent_jack_gmod_ezarmor_razor.png",
        equip_sound = "murdered/armor/face_equip.wav",
        unequip_sound = "murdered/armor/face_unequip.wav",
        equip_time = 0.4,
        unequip_time = 0.4,
        sound_boost_footsteps = true,
        sound_muffle_other = 0.35,
    },
    ["ears_sordin"] = {
        bodypart = "ears",
        model = "models/eft_props/gear/headsets/headset_msa.mdl",
        scale = 1,
        pos_offset = Vector(1.5, 0.3, 0),
        ang_offset = Angle(0, 290, 270),
        armor = 0,
        damage_reduction = 0,
        gas_protection = 0,
        protected_organs = {"Brain"},
        damage_types = {DMG_SLASH},
        icon = "entities/ent_jack_gmod_ezarmor_sordin.png",
        equip_sound = "murdered/armor/face_equip.wav",
        unequip_sound = "murdered/armor/face_unequip.wav",
        equip_time = 0.4,
        unequip_time = 0.4,
        sound_boost_footsteps = true,
        sound_muffle_other = 0.35,
    },
    ["ears_m32"] = {
        bodypart = "ears",
        model = "models/eft_props/gear/headsets/headset_m32.mdl",
        scale = 1,
        pos_offset = Vector(1.5, 0.3, 0),
        ang_offset = Angle(0, 290, 270),
        armor = 0,
        damage_reduction = 0,
        gas_protection = 0,
        protected_organs = {"Brain"},
        damage_types = {DMG_SLASH},
        icon = "entities/ent_jack_gmod_ezarmor_m32.png",
        equip_sound = "murdered/armor/face_equip.wav",
        unequip_sound = "murdered/armor/face_unequip.wav",
        equip_time = 0.4,
        unequip_time = 0.4,
        sound_boost_footsteps = true,
        sound_muffle_other = 0.35,
    },
    ["gasmask"] = {
        bodypart = "face2",
        model = "models/murdered/mask/Gas_Mask.mdl",
        scale = 1,
        pos_offset = Vector(0, 0, 0),
        ang_offset = Angle(0, 270, 270),
        armor = 5,
        damage_reduction_by_type = {[DMG_SLASH]=0.1, [DMG_CLUB]=0.1},
        gas_protection = 1,
        pepper_protection = 1,
        protected_organs = {"Brain"},
        damage_types = {DMG_POISON, DMG_NERVEGAS, DMG_RADIATION, DMG_ACID, DMG_SLASH, DMG_CLUB},
        icon = "entities/mur_armor_gasmask.png",
        overlay = "bs_overlays/gasmask_overlay.png",
        equip_sound = "murdered/armor/face_equip.wav",
        unequip_sound = "murdered/armor/face_unequip.wav",
        blocks_bodyparts = {"face"},
        equip_time = 2.5,
        unequip_time = 2.5
    },
    ["facecover_nomex"] = {
        bodypart = "facecover",
        model = "models/eft_props/gear/facecover/facecover_nomex.mdl",
        scale = 1,
        pos_offset = Vector(1.7, 0.4, 0),
        ang_offset = Angle(0, 290, 270),
        armor = 0,
        damage_reduction = 0.05,
        gas_protection = 0,
        protected_organs = {"Brain", "Neck"},
        damage_types = {DMG_SLASH},
        icon = "materials/entities/ent_jack_gmod_ezarmor_coldfear.png",
        equip_sound = "murdered/armor/face_equip.wav",
        overlay = "materials/mask_overlays/mask_anvis.png",
        unequip_sound = "murdered/armor/face_unequip.wav",
        equip_time = 1,
        unequip_time = 1
    },
    ["facecover_skull"] = {
        bodypart = "facecover",
        model = "models/eft_props/gear/facecover/facecover_mask_skull.mdl",
        scale = 1,
        pos_offset = Vector(1.7, 0.4, 0),
        ang_offset = Angle(0, 290, 270),
        armor = 0,
        damage_reduction = 0.05,
        gas_protection = 0,
        protected_organs = {"Brain", "Neck"},
        damage_types = {DMG_SLASH},
        icon = "entities/ent_jack_gmod_ezarmor_ghostbalacvlava.png",
        equip_sound = "murdered/armor/face_equip.wav",
        overlay = "materials/mask_overlays/mask_anvis.png",
        unequip_sound = "murdered/armor/face_unequip.wav",
        equip_time = 1,
        unequip_time = 1
    },
    ["facecover_gray"] = {
        bodypart = "facecover",
        model = "models/eft_props/gear/facecover/facecover_scavbalaclava.mdl",
        scale = 1,
        pos_offset = Vector(1.7, 0.4, 0),
        ang_offset = Angle(0, 290, 270),
        armor = 0,
        damage_reduction = 0.05,
        gas_protection = 0,
        protected_organs = {"Brain", "Neck"},
        damage_types = {DMG_SLASH},
        icon = "entities/ent_jack_gmod_ezarmor_balaclava.png",
        equip_sound = "murdered/armor/face_equip.wav",
        overlay = "materials/mask_overlays/mask_anvis.png",
        unequip_sound = "murdered/armor/face_unequip.wav",
        equip_time = 1,
        unequip_time = 1
    },
    ["facecover_black"] = {
        bodypart = "facecover",
        model = "models/eft_props/gear/facecover/facecover_scavbalaclava_black.mdl",
        scale = 1,
        pos_offset = Vector(1.7, 0.4, 0),
        ang_offset = Angle(0, 290, 270),
        armor = 0,
        damage_reduction = 0.05,
        gas_protection = 0,
        protected_organs = {"Brain", "Neck"},
        damage_types = {DMG_SLASH},
        icon = "entities/ent_jack_gmod_ezarmor_balaclavablack.png",
        equip_sound = "murdered/armor/face_equip.wav",
        overlay = "materials/mask_overlays/mask_anvis.png",
        unequip_sound = "murdered/armor/face_unequip.wav",
        equip_time = 1,
        unequip_time = 1
    },
    ["facecover_smoke"] = {
        bodypart = "facecover",
        model = "models/eft_props/gear/facecover/facecover_smoke.mdl",
        scale = 1,
        pos_offset = Vector(1.7, 0.4, 0),
        ang_offset = Angle(0, 290, 270),
        armor = 0,
        damage_reduction = 0.05,
        gas_protection = 0,
        protected_organs = {"Brain", "Neck"},
        damage_types = {DMG_SLASH},
        icon = "entities/ent_jack_gmod_ezarmor_smokebalacvlava.png",
        equip_sound = "murdered/armor/face_equip.wav",
        overlay = "materials/mask_overlays/mask_anvis.png",
        unequip_sound = "murdered/armor/face_unequip.wav",
        equip_time = 1,
        unequip_time = 1
    },
    ["facecover_zryachii"] = {
        bodypart = "facecover",
        model = "models/eft_props/gear/facecover/facecover_zryachii_closed.mdl",
        scale = 1,
        pos_offset = Vector(1.7, 0.4, 0),
        ang_offset = Angle(0, 290, 270),
        armor = 0,
        damage_reduction = 0.05,
        gas_protection = 0,
        protected_organs = {"Brain", "Neck"},
        damage_types = {DMG_SLASH},
        icon = "entities/ent_jack_gmod_ezarmor_zryachiibalacvlava.png",
        equip_sound = "murdered/armor/face_equip.wav",
        overlay = "materials/mask_overlays/mask_anvis.png",
        unequip_sound = "murdered/armor/face_unequip.wav",
        equip_time = 1,
        unequip_time = 1
    },
    ["facecover_hockey_captain"] = {
        bodypart = "head",
        model = "models/eft_props/gear/facecover/facecover_hockey_01.mdl",
        scale = 0.9,
        pos_offset = Vector(2, 0.4, 0),
        ang_offset = Angle(0, 290, 270),
        armor = 0,
        damage_reduction_by_type = {[DMG_SLASH]=0.3, [DMG_CLUB]=0.3, [DMG_BLAST]=0.02, [DMG_BULLET]=0.02},
        gas_protection = 0,
        protected_organs = {"Brain"},
        damage_types = {DMG_SLASH, DMG_CLUB, DMG_BULLET, DMG_BLAST},
        icon = "entities/ent_jack_gmod_ezarmor_hockeycaptain.png",
        equip_sound = "murdered/armor/face_equip.wav",
        overlay = "materials/mask_overlays/mask_gasmask.png",
        unequip_sound = "murdered/armor/face_unequip.wav",
        blocks_bodyparts = {"face", "face2"},
        equip_time = 2,
        unequip_time = 2
    },
    ["facecover_hockey_brawler"] = {
        bodypart = "head",
        model = "models/eft_props/gear/facecover/facecover_hockey_02.mdl",
        scale = 0.9,
        pos_offset = Vector(2, 0.4, 0),
        ang_offset = Angle(0, 290, 270),
        armor = 0,
        damage_reduction_by_type = {[DMG_SLASH]=0.3, [DMG_CLUB]=0.3, [DMG_BLAST]=0.02, [DMG_BULLET]=0.02},
        gas_protection = 0,
        protected_organs = {"Brain"},
        damage_types = {DMG_SLASH, DMG_CLUB, DMG_BULLET, DMG_BLAST},
        icon = "entities/ent_jack_gmod_ezarmor_hockeybrawler.png",
        equip_sound = "murdered/armor/face_equip.wav",
        overlay = "materials/mask_overlays/mask_gasmask.png",
        unequip_sound = "murdered/armor/face_unequip.wav",
        blocks_bodyparts = {"face", "face2"},
        equip_time = 2,
        unequip_time = 2
    },
    ["facecover_hockey_quiet"] = {
        bodypart = "head",
        model = "models/eft_props/gear/facecover/facecover_hockey_03.mdl",
        scale = 0.9,
        pos_offset = Vector(2, 0.4, 0),
        ang_offset = Angle(0, 290, 270),
        armor = 0,
        damage_reduction_by_type = {[DMG_SLASH]=0.3, [DMG_CLUB]=0.3, [DMG_BLAST]=0.02, [DMG_BULLET]=0.02},
        gas_protection = 0,
        protected_organs = {"Brain"},
        damage_types = {DMG_SLASH, DMG_CLUB, DMG_BULLET, DMG_BLAST},
        icon = "entities/ent_jack_gmod_ezarmor_hockeyquiet.png",
        equip_sound = "murdered/armor/face_equip.wav",
        overlay = "materials/mask_overlays/mask_gasmask.png",
        unequip_sound = "murdered/armor/face_unequip.wav",
        blocks_bodyparts = {"face", "face2"},
        equip_time = 2,
        unequip_time = 2
    },
    ["moto_helmet"] = {
        bodypart = "head",
        model = "models/murdered/helmets/moto_helmet.mdl",
        scale = 1,
        pos_offset = Vector(4, 0, 0),
        ang_offset = Angle(-90, 270, 270),
        armor = 0,
        damage_reduction_by_type = {[DMG_SLASH]=0.3, [DMG_CLUB]=0.3, [DMG_BLAST]=0.04, [DMG_BULLET]=0.04},
        gas_protection = 0.1,
        pepper_protection = 1,
        protected_organs = {"Brain"},
        damage_types = {DMG_SLASH, DMG_CLUB, DMG_BULLET, DMG_BLAST},
        icon = "entities/mur_armor_moto_helmet.png",
        overlay = "bs_overlays/motoh_overlay.png",
        equip_sound = "murdered/armor/helmet_equip.wav",
        unequip_sound = "murdered/armor/helmet_unequip.wav",
        blocks_bodyparts = {"face2"},
        equip_time = 2.5,
        unequip_time = 2.5
    },
    ["helmet_ulach"] = {
        bodypart = "head",
        model = "models/murdered/helmets/helmet_ulach.mdl",
        scale = 1,
        pos_offset = Vector(2, 0, 0),
        ang_offset = Angle(0, 270, 270),
        armor = 0,
        damage_reduction_by_type = {[DMG_SLASH]=0.7, [DMG_CLUB]=0.7, [DMG_BLAST]=0.1, [DMG_BULLET]=0.3},
        gas_protection = 0,
        protected_organs = {"Brain"},
        damage_types = {DMG_SLASH, DMG_CLUB, DMG_BULLET, DMG_BLAST},
        icon = "entities/mur_armor_helmet_ulach.png",
        overlay = "bs_overlays/helm_overlay.png",
        equip_sound = "murdered/armor/helmet_equip.wav",
        unequip_sound = "murdered/armor/helmet_unequip.wav",
        equip_time = 2.5,
        unequip_time = 2.5
    },
    ["helmet_tsh4m"] = {
        bodypart = "head",
        model = "models/eft_props/gear/helmets/helmet_tsh_4m2.mdl",
        scale = 1,
        pos_offset = Vector(2.2, 0.6, 0),
        ang_offset = Angle(0, 280, 270),
        armor = 0,
        damage_reduction_by_type = {[DMG_SLASH]=0.3, [DMG_CLUB]=0.3, [DMG_BLAST]=0.1, [DMG_BULLET]=0.02},
        gas_protection = 0,
        protected_organs = {"Brain"},
        damage_types = {DMG_SLASH, DMG_CLUB, DMG_BLAST, DMG_BULLET},
        icon = "entities/ent_jack_gmod_ezarmor_shlemofon.png",
        equip_sound = "murdered/armor/helmet_equip.wav",
        unequip_sound = "murdered/armor/helmet_unequip.wav",
        equip_time = 1,
        unequip_time = 1
    },
    ["helmet_vulkan5"] = {
        bodypart = "head",
        model = "models/eft_props/gear/helmets/helmet_vulkan_5.mdl",
        scale = 1,
        pos_offset = Vector(2, 0, 0),
        ang_offset = Angle(0, 280, 270),
        armor = 0,
        damage_reduction_by_type = {[DMG_SLASH]=1.3, [DMG_CLUB]=1.3, [DMG_BLAST]=0.2, [DMG_BULLET]=0.5},
        gas_protection = 0,
        protected_organs = {"Brain"},
        damage_types = {DMG_SLASH, DMG_CLUB, DMG_BULLET, DMG_BLAST},
        icon = "entities/ent_jack_gmod_ezarmor_vulkan5.png",
        overlay = "bs_overlays/helm_overlay.png",
        equip_sound = "murdered/armor/helmet_equip.wav",
        unequip_sound = "murdered/armor/helmet_unequip.wav",
        equip_time = 2.5,
        unequip_time = 2.5
    },
    ["helmet_k1c"] = {
        bodypart = "head",
        model = "models/eft_props/gear/helmets/helmet_k1c.mdl",
        scale = 1,
        pos_offset = Vector(2, 0, 0),
        ang_offset = Angle(0, 270, 270),
        armor = 0,
        damage_reduction_by_type = {[DMG_SLASH]=0.3, [DMG_CLUB]=0.3, [DMG_BLAST]=0.1, [DMG_BULLET]=0.1},
        gas_protection = 0,
        protected_organs = {"Brain"},
        damage_types = {DMG_SLASH, DMG_CLUB, DMG_BULLET, DMG_BLAST},
        icon = "entities/ent_jack_gmod_ezarmor_kolpak1s.png",
        overlay = "bs_overlays/helm_overlay.png",
        equip_sound = "murdered/armor/helmet_equip.wav",
        unequip_sound = "murdered/armor/helmet_unequip.wav",
        equip_time = 2.5,
        unequip_time = 2.5
    },
    ["helmet_sphera_c"] = {
        bodypart = "head",
        model = "models/eft_props/gear/helmets/helmet_sphera_c.mdl",
        scale = 1,
        pos_offset = Vector(2.3, 0, 0),
        ang_offset = Angle(0, 280, 270),
        armor = 0,
        damage_reduction_by_type = {[DMG_SLASH]=0.7, [DMG_CLUB]=0.7, [DMG_BLAST]=0.1, [DMG_BULLET]=0.2},
        gas_protection = 0,
        protected_organs = {"Brain"},
        damage_types = {DMG_SLASH, DMG_CLUB, DMG_BULLET, DMG_BLAST},
        icon = "entities/ent_jack_gmod_ezarmor_sferas.png",
        overlay = "bs_overlays/helm_overlay.png",
        equip_sound = "murdered/armor/helmet_equip.wav",
        unequip_sound = "murdered/armor/helmet_unequip.wav",
        equip_time = 2.5,
        unequip_time = 2.5
    },
    ["helmet_shpm"] = {
        bodypart = "head",
        model = "models/eft_props/gear/helmets/helmet_shpm.mdl",
        scale = 1,
        pos_offset = Vector(3, 0, 0),
        ang_offset = Angle(0, 270, 270),
        armor = 0,
        damage_reduction_by_type = {[DMG_SLASH]=0.7, [DMG_CLUB]=0.7, [DMG_BLAST]=0.06, [DMG_BULLET]=0.04},
        gas_protection = 0.1,
        protected_organs = {"Brain"},
        damage_types = {DMG_SLASH, DMG_CLUB, DMG_BULLET, DMG_BLAST},
        icon = "entities/ent_jack_gmod_ezarmor_shpmhelm.png",
        overlay = "bs_overlays/riot_overlay.png",
        equip_sound = "murdered/armor/helmet_equip.wav",
        unequip_sound = "murdered/armor/helmet_unequip.wav",
        equip_time = 2.5,
        unequip_time = 2.5
    },
    ["cap_bear_black"] = {
        bodypart = "head",
        model = "models/eft_props/gear/headwear/cap_bear_black.mdl",
        scale = 1,
        pos_offset = Vector(2.2, 0.6, 0),
        ang_offset = Angle(0, 280, 270),
        armor = 0,
        damage_reduction_by_type = {[DMG_SLASH]=0.04, [DMG_CLUB]=0.04},
        gas_protection = 0,
        protected_organs = {"Brain"},
        damage_types = {DMG_SLASH, DMG_CLUB},
        icon = "entities/ent_jack_gmod_ezarmor_bearcapblack.png",
        equip_sound = "murdered/armor/helmet_equip.wav",
        unequip_sound = "murdered/armor/helmet_unequip.wav",
        equip_time = 1,
        unequip_time = 1
    },
    ["cap_bear_green"] = {
        bodypart = "head",
        model = "models/eft_props/gear/headwear/cap_bear_green.mdl",
        scale = 1,
        pos_offset = Vector(3, 0.6, 0),
        ang_offset = Angle(0, 280, 270),
        armor = 0,
        damage_reduction_by_type = {[DMG_SLASH]=0.04, [DMG_CLUB]=0.04},
        gas_protection = 0,
        protected_organs = {"Brain"},
        damage_types = {DMG_SLASH, DMG_CLUB},
        icon = "entities/ent_jack_gmod_ezarmor_bearcapgreen.png",
        equip_sound = "murdered/armor/helmet_equip.wav",
        unequip_sound = "murdered/armor/helmet_unequip.wav",
        equip_time = 1,
        unequip_time = 1
    },
    ["cap_boss"] = {
        bodypart = "head",
        model = "models/eft_props/gear/headwear/cap_boss_tagillacap.mdl",
        scale = 1,
        pos_offset = Vector(2.2, 0.6, 0),
        ang_offset = Angle(0, 280, 270),
        armor = 0,
        damage_reduction_by_type = {[DMG_SLASH]=0.04, [DMG_CLUB]=0.04},
        gas_protection = 0,
        protected_organs = {"Brain"},
        damage_types = {DMG_SLASH, DMG_CLUB},
        icon = "entities/ent_jack_gmod_ezarmor_bosscap.png",
        equip_sound = "murdered/armor/helmet_equip.wav",
        unequip_sound = "murdered/armor/helmet_unequip.wav",
        equip_time = 1,
        unequip_time = 1
    },
    ["cap_mhs"] = {
        bodypart = "head",
        model = "models/eft_props/gear/headwear/cap_mhs.mdl",
        scale = 1,
        pos_offset = Vector(2.2, 0.6, 0),
        ang_offset = Angle(0, 280, 270),
        armor = 0,
        damage_reduction_by_type = {[DMG_SLASH]=0.04, [DMG_CLUB]=0.04},
        gas_protection = 0,
        protected_organs = {"Brain"},
        damage_types = {DMG_SLASH, DMG_CLUB},
        icon = "entities/ent_jack_gmod_ezarmor_emercom.png",
        equip_sound = "murdered/armor/helmet_equip.wav",
        unequip_sound = "murdered/armor/helmet_unequip.wav",
        equip_time = 1,
        unequip_time = 1
    },
    ["cap_police"] = {
        bodypart = "head",
        model = "models/eft_props/gear/headwear/cap_police.mdl",
        scale = 1,
        pos_offset = Vector(2.2, 0.6, 0),
        ang_offset = Angle(0, 280, 270),
        armor = 0,
        damage_reduction_by_type = {[DMG_SLASH]=0.04, [DMG_CLUB]=0.04},
        gas_protection = 0,
        protected_organs = {"Brain"},
        damage_types = {DMG_SLASH, DMG_CLUB},
        icon = "entities/ent_jack_gmod_ezarmor_police.png",
        equip_sound = "murdered/armor/helmet_equip.wav",
        unequip_sound = "murdered/armor/helmet_unequip.wav",
        equip_time = 1,
        unequip_time = 1
    },
    ["cap_scav"] = {
        bodypart = "head",
        model = "models/eft_props/gear/headwear/cap_scav.mdl",
        scale = 1,
        pos_offset = Vector(2.2, 0.6, 0),
        ang_offset = Angle(0, 280, 270),
        armor = 0,
        damage_reduction_by_type = {[DMG_SLASH]=0.04, [DMG_CLUB]=0.04},
        gas_protection = 0,
        protected_organs = {"Brain"},
        damage_types = {DMG_SLASH, DMG_CLUB},
        icon = "entities/ent_jack_gmod_ezarmor_scavcap.png",
        equip_sound = "murdered/armor/helmet_equip.wav",
        unequip_sound = "murdered/armor/helmet_unequip.wav",
        equip_time = 1,
        unequip_time = 1
    },
    ["helmet_riot"] = {
        bodypart = "head",
        model = "models/murdered/helmets/helmet_riot.mdl",
        scale = 1,
        pos_offset = Vector(3, 0, 0),
        ang_offset = Angle(0, 270, 270),
        armor = 0,
        damage_reduction_by_type = {[DMG_SLASH]=0.9, [DMG_CLUB]=0.9, [DMG_BLAST]=0.06, [DMG_BULLET]=0.04},
        gas_protection = 0.1,
        protected_organs = {"Brain"},
        damage_types = {DMG_SLASH, DMG_CLUB, DMG_BULLET, DMG_BLAST},
        icon = "entities/mur_armor_helmet_riot.png",
        overlay = "bs_overlays/riot_overlay.png",
        equip_sound = "murdered/armor/helmet_equip.wav",
        unequip_sound = "murdered/armor/helmet_unequip.wav",
        equip_time = 2.5,
        unequip_time = 2.5
    },
    ["vest_security"] = {
        bodypart = "body",
        model = "models/eft_props/gear/chestrigs/cr_ctacticall.mdl",
        scale = 0.9,
        pos_offset = Vector(-1, -2.8, 0),
        ang_offset = Angle(180, 270, 270),
        armor = 0,
        damage_reduction_by_type = {[DMG_SLASH]=0.2, [DMG_CLUB]=0.2, [DMG_BLAST]=0.1, [DMG_BULLET]=0.1},
        gas_protection = 0,
        protected_organs = {"Heart", "Right Lung", "Left Lung", "Liver", "Spine"},
        damage_types = {DMG_BLAST, DMG_BULLET, DMG_SLASH, DMG_CLUB},
        icon = "entities/ent_jack_gmod_ezarmor_securityvest.png",
        equip_sound = "murdered/armor/armor_equip.wav",
        unequip_sound = "murdered/armor/armor_unequip.wav",
        equip_time = 2,
        unequip_time = 2,
        speed_penalty_run = 0.05
    },
    ["vest_hexgrid"] = {
        bodypart = "body",
        model = "models/eft_props/gear/armor/ar_custom_hexgrid.mdl",
        scale = 0.9,
        pos_offset = Vector(-0.4, -2.8, 0),
        ang_offset = Angle(180, 270, 270),
        armor = 0,
        damage_reduction_by_type = {[DMG_SLASH]=1.0, [DMG_CLUB]=1.0, [DMG_BLAST]=0.1, [DMG_BULLET]=0.7},
        gas_protection = 0,
        protected_organs = {"Heart", "Right Lung", "Left Lung"},
        damage_types = {DMG_BLAST, DMG_BULLET, DMG_SLASH, DMG_CLUB},
        icon = "entities/ent_jack_gmod_ezarmor_hexgrid.png",
        equip_sound = "murdered/armor/armor_equip.wav",
        unequip_sound = "murdered/armor/armor_unequip.wav",
        equip_time = 2,
        unequip_time = 2
    },
    ["vest_hexatac"] = {
        bodypart = "body",
        model = "models/eft_props/gear/armor/ar_hexatac.mdl",
        scale = 0.9,
        pos_offset = Vector(-0.4, -2.8, 0),
        ang_offset = Angle(180, 270, 270),
        armor = 0,
        damage_reduction_by_type = {[DMG_SLASH]=0.7, [DMG_CLUB]=0.7, [DMG_BLAST]=0.1, [DMG_BULLET]=0.5},
        gas_protection = 0,
        protected_organs = {"Heart", "Right Lung", "Left Lung"},
        damage_types = {DMG_BLAST, DMG_BULLET, DMG_SLASH, DMG_CLUB},
        icon = "entities/ent_jack_gmod_ezarmor_hexatachpc.png",
        equip_sound = "murdered/armor/armor_equip.wav",
        unequip_sound = "murdered/armor/armor_unequip.wav",
        equip_time = 2,
        unequip_time = 2
    },
    ["vest_korakulon_black"] = {
        bodypart = "body",
        model = "models/eft_props/gear/armor/ar_kirasa_black.mdl",
        scale = 0.9,
        pos_offset = Vector(-0.2, -3, 0),
        ang_offset = Angle(180, 270, 270),
        armor = 0,
        damage_reduction_by_type = {[DMG_SLASH]=0.4, [DMG_CLUB]=0.3, [DMG_BLAST]=0.1, [DMG_BULLET]=0.1},
        gas_protection = 0,
        protected_organs = {"Heart", "Right Lung", "Left Lung", "Liver", "Spine"},
        damage_types = {DMG_BLAST, DMG_BULLET, DMG_SLASH, DMG_CLUB},
        icon = "entities/ent_jack_gmod_ezarmor_kora_kulon_b.png",
        equip_sound = "murdered/armor/armor_equip.wav",
        unequip_sound = "murdered/armor/armor_unequip.wav",
        equip_time = 2,
        unequip_time = 2
    },
    ["vest_korakulon_emr"] = {
        bodypart = "body",
        model = "models/eft_props/gear/armor/ar_kirasa_camo.mdl",
        scale = 0.9,
        pos_offset = Vector(-0.2, -3, 0),
        ang_offset = Angle(180, 270, 270),
        armor = 0,
        damage_reduction_by_type = {[DMG_SLASH]=0.4, [DMG_CLUB]=0.3, [DMG_BLAST]=0.1, [DMG_BULLET]=0.1},
        gas_protection = 0,
        protected_organs = {"Heart", "Right Lung", "Left Lung", "Liver", "Spine"},
        damage_types = {DMG_BLAST, DMG_BULLET, DMG_SLASH, DMG_CLUB},
        icon = "entities/ent_jack_gmod_ezarmor_kora_kulon_dfl.png",
        equip_sound = "murdered/armor/armor_equip.wav",
        unequip_sound = "murdered/armor/armor_unequip.wav",
        equip_time = 2,
        unequip_time = 2
    },
    ["vest_zhuk_press"] = {
        bodypart = "body",
        model = "models/eft_props/gear/armor/ar_beetle3.mdl",
        scale = 0.9,
        pos_offset = Vector(-0.4, -2.8, 0),
        ang_offset = Angle(180, 270, 270),
        armor = 0,
        damage_reduction_by_type = {[DMG_SLASH]=0.6, [DMG_CLUB]=0.5, [DMG_BLAST]=0.3, [DMG_BULLET]=0.4},
        gas_protection = 0,
        protected_organs = {"Heart", "Right Lung", "Left Lung", "Liver", "Spine"},
        damage_types = {DMG_BLAST, DMG_BULLET, DMG_SLASH, DMG_CLUB},
        icon = "entities/ent_jack_gmod_ezarmor_zhukpress.png",
        equip_sound = "murdered/armor/armor_equip.wav",
        unequip_sound = "murdered/armor/armor_unequip.wav",
        equip_time = 2,
        unequip_time = 2
    },
    ["hev_tors"] = {
        bodypart = "body",
        permanent = true,
        protects_all_hitgroups = true,
        blocks_bodyparts = {"head", "facecover", "face", "face2", "ears"},
        damage_reduction_by_type = {[DMG_SLASH]=0.9, [DMG_CLUB]=0.9, [DMG_BLAST]=0.9, [DMG_BULLET]=0.9},
        gas_protection = 0,
        protected_organs = {"Brain", "Neck", "Heart", "Right Lung", "Left Lung", "Liver", "Spine"},
        damage_types = {DMG_BLAST, DMG_BULLET, DMG_SLASH, DMG_CLUB},
        icon = "entities/mur_armor_classI_armor.png",
        equip_time = 0,
        unequip_time = 0,

        barrier_health = 45,
        barrier_regen_delay = 15
    },
    ["wallhammer_armor"] = {
        bodypart = "body",
        permanent = true,
        protects_all_hitgroups = true,
        blocks_bodyparts = {"head", "facecover", "face", "face2", "ears"},
        damage_reduction_by_type = {[DMG_SLASH]=1.4, [DMG_CLUB]=1.4, [DMG_BLAST]=1.4, [DMG_BULLET]=1.4},
        gas_protection = 0,
        protected_organs = {"Brain", "Neck", "Heart", "Right Lung", "Left Lung", "Liver", "Spine"},
        damage_types = {DMG_BLAST, DMG_BULLET, DMG_SLASH, DMG_CLUB},
        icon = "entities/mur_armor_classI_armor.png",
        equip_time = 0,
        unequip_time = 0,
        speed_penalty_run = 0.45,
        speed_penalty_walk = 0.45
    },
    ["sniper_armor"] = {
        bodypart = "body",
        permanent = true,
        protects_all_hitgroups = true,
        blocks_bodyparts = {"head", "facecover", "face", "face2", "ears"},
        damage_reduction_by_type = {[DMG_SLASH]=0.4, [DMG_CLUB]=0.4, [DMG_BLAST]=0.4, [DMG_BULLET]=0.4},
        gas_protection = 0,
        protected_organs = {"Brain", "Neck", "Heart", "Right Lung", "Left Lung", "Liver", "Spine"},
        damage_types = {DMG_BLAST, DMG_BULLET, DMG_SLASH, DMG_CLUB},
        icon = "entities/mur_armor_classI_armor.png",
        equip_time = 0,
        unequip_time = 0
    },
    ["suppressor_armor"] = {
        bodypart = "body",
        permanent = true,
        protects_all_hitgroups = true,
        blocks_bodyparts = {"head", "facecover", "face", "face2", "ears"},
        damage_reduction_by_type = {[DMG_SLASH]=1.0, [DMG_CLUB]=1.0, [DMG_BLAST]=1.0, [DMG_BULLET]=1.0},
        gas_protection = 0,
        protected_organs = {"Brain", "Neck", "Heart", "Right Lung", "Left Lung", "Liver", "Spine"},
        damage_types = {DMG_BLAST, DMG_BULLET, DMG_SLASH, DMG_CLUB},
        icon = "entities/mur_armor_classI_armor.png",
        equip_time = 0,
        unequip_time = 0,
        speed_penalty_run = 0.35,
        speed_penalty_walk = 0.35
    },
    ["ordinal_armor"] = {
        bodypart = "body",
        permanent = true,
        protects_all_hitgroups = true,
        blocks_bodyparts = {"head", "facecover", "face", "face2", "ears"},
        damage_reduction_by_type = {[DMG_SLASH]=0.8, [DMG_CLUB]=0.8, [DMG_BLAST]=0.8, [DMG_BULLET]=0.8},
        gas_protection = 0,
        protected_organs = {"Brain", "Neck", "Heart", "Right Lung", "Left Lung", "Liver", "Spine"},
        damage_types = {DMG_BLAST, DMG_BULLET, DMG_SLASH, DMG_CLUB},
        icon = "entities/mur_armor_classI_armor.png",
        equip_time = 0,
        unequip_time = 0,
        speed_penalty_run = 0.1,
        speed_penalty_walk = 0.1
    },
    ["tony_armor"] = {
        bodypart = "body",
        permanent = true,
        protects_all_hitgroups = true,
        blocks_bodyparts = {"head", "facecover", "face", "face2", "ears"},
        damage_reduction_by_type = {[DMG_SLASH]=1.4, [DMG_CLUB]=1.4, [DMG_BLAST]=1.4, [DMG_BULLET]=1.4},
        gas_protection = 0,
        protected_organs = {"Brain", "Neck", "Heart", "Right Lung", "Left Lung", "Liver", "Spine"},
        damage_types = {DMG_BLAST, DMG_BULLET, DMG_SLASH, DMG_CLUB},
        icon = "entities/mur_armor_classI_armor.png",
        equip_time = 0,
        unequip_time = 0
    },
    ["grunt_armor"] = {
        bodypart = "body",
        permanent = true,
        protects_all_hitgroups = true,
        blocks_bodyparts = {"head", "facecover", "face", "face2", "ears"},
        damage_reduction_by_type = {[DMG_SLASH]=0.5, [DMG_CLUB]=0.5, [DMG_BLAST]=0.5, [DMG_BULLET]=0.5},
        gas_protection = 0,
        protected_organs = {"Brain", "Neck", "Heart", "Right Lung", "Left Lung", "Liver", "Spine"},
        damage_types = {DMG_BLAST, DMG_BULLET, DMG_SLASH, DMG_CLUB},
        icon = "entities/mur_armor_classI_armor.png",
        equip_time = 0,
        unequip_time = 0,
        speed_bonus_run = 0.25,
        speed_bonus_walk = 0.25
    },
    ["vest_fishing"] = {
        bodypart = "body",
        model = "models/eft_props/gear/chestrigs/cr_vestwild.mdl",
        scale = 0.9,
        pos_offset = Vector(-1, -2.8, 0),
        ang_offset = Angle(180, 270, 270),
        armor = 0,
        damage_reduction_by_type = {[DMG_SLASH]=0.06, [DMG_CLUB]=0.06, [DMG_BLAST]=0.02, [DMG_BULLET]=0.02},
        gas_protection = 0,
        protected_organs = {"Heart", "Right Lung", "Left Lung", "Liver", "Spine"},
        damage_types = {DMG_BLAST, DMG_BULLET, DMG_SLASH, DMG_CLUB},
        icon = "entities/ent_jack_gmod_ezarmor_scavvest.png",
        equip_sound = "murdered/armor/armor_equip.wav",
        unequip_sound = "murdered/armor/armor_unequip.wav",
        equip_time = 1,
        unequip_time = 0.8
    },
    ["classI_armor"] = {
        bodypart = "body",
        model = "models/murdered/armors/classI_armor.mdl",
        scale = 1,
        pos_offset = Vector(2.4, -2, 0),
        ang_offset = Angle(180, 270, 270),
        armor = 0,
        damage_reduction = 0.75, 
        gas_protection = 0,
        protected_organs = {"Heart", "Right Lung", "Left Lung", "Liver", "Spine"},
        damage_types = {DMG_BLAST, DMG_BULLET, DMG_SLASH, DMG_CLUB},
        ammo_scaling = {
            ["others"] = 0, 
            ["buckshot"] = 0.1,
            ["pistol"] = 0.1, 
        },
        icon = "entities/mur_armor_classI_armor.png",
        equip_sound = "murdered/armor/armor_equip.wav",
        unequip_sound = "murdered/armor/armor_unequip.wav",
        equip_time = 3,
        unequip_time = 3,
        speed_penalty_run = 0.15,
        speed_penalty_walk = 0.05
    },
    ["classII_armor"] = {
        bodypart = "body",
        model = "models/murdered/armors/classII_vest.mdl",
        scale = 1,
        pos_offset = Vector(2, -3, 0),
        ang_offset = Angle(90, 270, 270),
        armor = 0,
        damage_reduction = 0.5,
        gas_protection = 0,
        protected_organs = {"Heart", "Right Lung", "Left Lung", "Liver", "Spine"},
        damage_types = {DMG_BLAST, DMG_BULLET, DMG_SLASH, DMG_CLUB},
        ammo_scaling = {
            ["others"] = 0.1, 
            ["357"] = 0.3, 
            ["pistol"] = 0.75, 
            ["buckshot"] = 0.8,
        },
        icon = "entities/mur_armor_classII_armor.png",
        equip_sound = "murdered/armor/armor_equip.wav",
        unequip_sound = "murdered/armor/armor_unequip.wav",
        equip_time = 3,
        unequip_time = 3,
        speed_penalty_run = 0.25,
        speed_penalty_walk = 0.05
    },
    ["classII_police"] = {
        bodypart = "body",
        model = "models/murdered/armors/classII_police.mdl",
        scale = 1,
        pos_offset = Vector(3, -2, 0),
        ang_offset = Angle(180, 270, 270),
        armor = 0,
        damage_reduction = 0.5,
        gas_protection = 0,
        protected_organs = {"Heart", "Right Lung", "Left Lung", "Liver", "Spine"},
        damage_types = {DMG_BLAST, DMG_BULLET, DMG_SLASH, DMG_CLUB},
        ammo_scaling = {
            ["others"] = 0.1,
            ["357"] = 0.3,
            ["pistol"] = 0.75,
            ["buckshot"] = 0.8,
        },
        icon = "entities/mur_armor_classII_armor.png",
        equip_sound = "murdered/armor/armor_equip.wav",
        unequip_sound = "murdered/armor/armor_unequip.wav",
        equip_time = 3,
        unequip_time = 3,
        speed_penalty_run = 0.25,
        speed_penalty_walk = 0.05
    },
    ["classIII_armor"] = {
        bodypart = "body",
        model = "models/murdered/armors/classIII_vest.mdl",
        scale = 1,
        pos_offset = Vector(2, -3, 0),
        ang_offset = Angle(90, 270, 270),
        armor = 0,
        damage_reduction = 0.75, 
        gas_protection = 0,
        protected_organs = {"Heart", "Right Lung", "Left Lung", "Liver", "Spine"},
        damage_types = {DMG_BLAST, DMG_BULLET, DMG_SLASH, DMG_CLUB},
        ammo_scaling = {
            ["others"] = 0.2, 
            ["357"] = 0.6, 
            ["pistol"] = 0.9,
            ["buckshot"] = 0.9,
            ["ar2"] = 0.35, 
            ["smg1"] = 0.7,
        },
        icon = "entities/mur_armor_classIII_armor.png",
        equip_sound = "murdered/armor/armor_equip.wav",
        unequip_sound = "murdered/armor/armor_unequip.wav",
        equip_time = 3.5,
        unequip_time = 3.5,
        speed_penalty_run = 0.35,
        speed_penalty_walk = 0.1
    },
    ["classIII_police"] = {
        bodypart = "body",
        model = "models/murdered/armors/classIII_police.mdl",
        scale = 1,
        pos_offset = Vector(2, -4, 0),
        ang_offset = Angle(180, 280, 270),
        armor = 0,
        damage_reduction = 0.75,
        gas_protection = 0,
        protected_organs = {"Heart", "Right Lung", "Left Lung", "Liver", "Spine"},
        damage_types = {DMG_BLAST, DMG_BULLET, DMG_SLASH, DMG_CLUB},
        ammo_scaling = {
            ["others"] = 0.2, 
            ["357"] = 0.6, 
            ["pistol"] = 0.9,
            ["buckshot"] = 0.9,
            ["ar2"] = 0.35, 
            ["smg1"] = 0.7,
        },
        icon = "entities/mur_armor_classIII_police.png",
        equip_sound = "murdered/armor/armor_equip.wav",
        unequip_sound = "murdered/armor/armor_unequip.wav",
        equip_time = 3.5,
        unequip_time = 3.5
    },
}

MuR.Armor.OrganDisplayOrder = {"Brain", "Carotid Artery", "Neck", "Heart", "Right Lung", "Left Lung", "Liver", "Spine"}

MuR.Armor.DamageTypeDisplayOrder = {
    DMG_BULLET, DMG_SLASH, DMG_CLUB, DMG_BLAST,
    DMG_POISON, DMG_NERVEGAS, DMG_RADIATION, DMG_ACID
}

function MuR.Armor.HasDamageType(armorId, damageType)
    local item = MuR.Armor.Items[armorId]
    if not item or not item.damage_types then return false end
    for _, dt in ipairs(item.damage_types) do
        if dt == "all" or (isnumber(dt) and dt == damageType) then return true end
    end
    return false
end

function MuR.Armor.GetArmorReductionForDamageType(item, damageType)
    if item.damage_reduction_by_type and item.damage_reduction_by_type[damageType] then
        return item.damage_reduction_by_type[damageType]
    end
    local reduction = item.damage_reduction or 0
    if damageType == DMG_BULLET and item.ammo_scaling then
        local maxR = reduction
        for _, v in pairs(item.ammo_scaling) do
            if isnumber(v) and v > maxR then maxR = v end
        end
        return maxR
    end
    if (damageType == DMG_POISON or damageType == DMG_NERVEGAS or damageType == DMG_RADIATION or damageType == DMG_ACID) and item.gas_protection then
        return math.max(reduction, item.gas_protection)
    end
    return reduction
end

MuR.Armor.BoneToHitgroup = {
    ["ValveBiped.Bip01_Head1"] = HITGROUP_HEAD,
    ["ValveBiped.Bip01_Neck1"] = HITGROUP_HEAD,
    ["ValveBiped.Bip01_R_Clavicle"] = HITGROUP_CHEST,
    ["ValveBiped.Bip01_L_Clavicle"] = HITGROUP_CHEST,
    ["ValveBiped.Bip01_Spine"] = HITGROUP_STOMACH,
    ["ValveBiped.Bip01_Spine1"] = HITGROUP_CHEST,
    ["ValveBiped.Bip01_Spine2"] = HITGROUP_CHEST,
    ["ValveBiped.Bip01_Spine4"] = HITGROUP_CHEST,
    ["ValveBiped.Bip01_Pelvis"] = HITGROUP_STOMACH,
    ["ValveBiped.Bip01_L_Thigh"] = HITGROUP_LEFTLEG,
    ["ValveBiped.Bip01_R_Thigh"] = HITGROUP_RIGHTLEG,
    ["ValveBiped.Bip01_L_Calf"] = HITGROUP_LEFTLEG,
    ["ValveBiped.Bip01_R_Calf"] = HITGROUP_RIGHTLEG,
    ["ValveBiped.Bip01_L_Foot"] = HITGROUP_LEFTLEG,
    ["ValveBiped.Bip01_R_Foot"] = HITGROUP_RIGHTLEG,
    ["ValveBiped.Bip01_L_UpperArm"] = HITGROUP_LEFTARM,
    ["ValveBiped.Bip01_R_UpperArm"] = HITGROUP_RIGHTARM,
    ["ValveBiped.Bip01_L_Forearm"] = HITGROUP_LEFTARM,
    ["ValveBiped.Bip01_R_Forearm"] = HITGROUP_RIGHTARM,
    ["ValveBiped.Bip01_L_Hand"] = HITGROUP_LEFTARM,
    ["ValveBiped.Bip01_R_Hand"] = HITGROUP_RIGHTARM,
}

MuR.Armor.DamageBones = {
    "ValveBiped.Bip01_Head1",
    "ValveBiped.Bip01_Neck1",
    "ValveBiped.Bip01_R_Clavicle",
    "ValveBiped.Bip01_L_Clavicle",
    "ValveBiped.Bip01_Spine",
    "ValveBiped.Bip01_Spine1",
    "ValveBiped.Bip01_Spine2",
    "ValveBiped.Bip01_Spine4",
    "ValveBiped.Bip01_Pelvis",
    "ValveBiped.Bip01_L_Thigh",
    "ValveBiped.Bip01_R_Thigh",
    "ValveBiped.Bip01_L_Calf",
    "ValveBiped.Bip01_R_Calf",
    "ValveBiped.Bip01_L_Foot",
    "ValveBiped.Bip01_R_Foot",
    "ValveBiped.Bip01_L_UpperArm",
    "ValveBiped.Bip01_R_UpperArm",
    "ValveBiped.Bip01_L_Forearm",
    "ValveBiped.Bip01_R_Forearm",
    "ValveBiped.Bip01_L_Hand",
    "ValveBiped.Bip01_R_Hand",
}

MuR.Armor.GasCategories = {
    "poison",
    "nerve_agent",
    "irritant"
}

function MuR.Armor.GetItem(armorId)
    return MuR.Armor.Items[armorId]
end

function MuR.Armor.GetBodyPart(partId)
    return MuR.Armor.BodyParts[partId]
end

function MuR.Armor.IsDamageTypeProtected(armorId, dmginfo)
    local item = MuR.Armor.Items[armorId]
    if not item or not item.damage_types then return false end

    for _, dt in ipairs(item.damage_types) do
        if dt == "all" then return true end
        if isnumber(dt) and dmginfo:IsDamageType(dt) then
            return true
        end
    end
    return false
end

function MuR.Armor.IsOrganProtected(armorId, organName, dmginfo)
    local item = MuR.Armor.Items[armorId]
    if not item then return false end

    if dmginfo and not MuR.Armor.IsDamageTypeProtected(armorId, dmginfo) then
        return false
    end

    if item.protected_organs then
        for _, org in ipairs(item.protected_organs) do
            if org == organName then
                return true
            end
        end
    end

    local part = MuR.Armor.BodyParts[item.bodypart]
    if part and part.organs then
        for _, org in ipairs(part.organs) do
            if org == organName then
                return true
            end
        end
    end

    return false
end

function MuR.Armor.IsHitgroupProtected(bodypart, hitgroup, armorId)
    if armorId then
        local item = MuR.Armor.Items[armorId]
        if item and item.protects_all_hitgroups then
            return true
        end
    end
    local part = MuR.Armor.BodyParts[bodypart]
    if not part or not part.hitgroups then return false end

    for _, hg in ipairs(part.hitgroups) do
        if hg == hitgroup then
            return true
        end
    end
    return false
end

function MuR.Armor.GetItemsForBodyPart(bodypart)
    local items = {}
    for id, item in pairs(MuR.Armor.Items) do
        if item.bodypart == bodypart then
            items[#items + 1] = id
        end
    end
    return items
end

function MuR.Armor.IsBodyPartBlocked(ply, bodypart)
    if not IsValid(ply) then return false end
    local currentArmor = ply:GetNW2String("MuR_Armor_" .. bodypart, "")
    for part, _ in pairs(MuR.Armor.BodyParts) do
        local armorId = ply:GetNW2String("MuR_Armor_" .. part, "")
        if armorId and armorId ~= "" then
            local item = MuR.Armor.GetItem(armorId)
            if item and item.blocks_bodyparts then
                for _, blocked in ipairs(item.blocks_bodyparts) do
                    if blocked == bodypart then

                        local allowed = item.allows_on_blocked and item.allows_on_blocked[bodypart]
                        if allowed and table.HasValue(allowed, currentArmor) then

                        else
                            return true
                        end
                    end
                end
            end
        end
    end
    return false
end

function MuR.Armor.GetSpeedPenaltyForPlayer(ply)
    local walkMult, runMult = 1, 1
    if not IsValid(ply) then return walkMult, runMult end
    for part, _ in pairs(MuR.Armor.BodyParts) do
        local armorId = ply:GetNW2String("MuR_Armor_" .. part, "")
        if armorId and armorId ~= "" then
            local item = MuR.Armor.GetItem(armorId)
            if item then
                if item.speed_penalty_walk then
                    walkMult = math.min(walkMult, 1 - item.speed_penalty_walk)
                end
                if item.speed_penalty_run then
                    runMult = math.min(runMult, 1 - item.speed_penalty_run)
                end
                if item.speed_bonus_walk then
                    walkMult = math.max(walkMult, 1 + item.speed_bonus_walk)
                end
                if item.speed_bonus_run then
                    runMult = math.max(runMult, 1 + item.speed_bonus_run)
                end
            end
        end
    end
    return walkMult, runMult
end
