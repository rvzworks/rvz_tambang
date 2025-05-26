Config = {}

Config.HasilBatu = {
    min = 1,
    max = 3,
}

Config.ModelBatu = 'prop_rock_1_c'
Config.SpawnBatuCooldown = 60000 

Config.SpawnBatu = {
    [1] = vector3(2985.6663, 2817.0715, 45.9782),
    [2] = vector3(2997.3325, 2797.5261, 44.5136),
    [3] = vector3(3005.1230, 2782.4561, 43.1234),
    [4] = vector3(3012.4567, 2765.7890, 42.4567),
    [5] = vector3(3020.7890, 2750.1234, 41.7890),
    [6] = vector3(3030.1234, 2735.4567, 40.1234),
}

Config.CuciBatu = {
    [1] = vector3(1915.8446, 378.0317, 161.5055),
}

Config.Progress = {
    Tambang = {
        label = 'Menambang Batu',
        duration = 5000,
        anim = {
            dict = 'melee@hatchet@streamed_core',
            clip = 'plyr_rear_takedown_b'
        },
        prop = {
            model = `prop_tool_pickaxe`,
            bone = 57005,
            pos = vec3(0.13, 0.0, -0.02),
            rot = vec3(-90.0, 0.0, 0.0)
        }
    },
    Cuci = {
        label = 'Mencuci Batu',
        duration = 5000,
        anim = {
            dict = 'amb@world_human_bum_wash@male@high@idle_a',
            clip = 'idle_a'
        }
    },
    Smelt = {
        label = 'Smelting Batu',
        duration = 5000,
        anim = {
            dict = 'amb@prop_human_bum_shopping_cart@male@base',
            clip = 'base'
        }
    }
}

Config.Item = {
    BatuMentah = 'raw_ore',
    BatuCuci = 'washed_ore'
}
