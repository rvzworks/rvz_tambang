QBCore = exports['qb-core']:GetCoreObject()
local model = 'prop_rock_1_c'
local spawnedObjects = {}

local function LoadModel(mdl)
    RequestModel(mdl)
    while not HasModelLoaded(mdl) do
        Wait(50)
    end
end

local function SpawnBatu()
    LoadModel(model)

    for i, pos in pairs(Config.SpawnBatu) do
        local obj = CreateObject(model, pos.x, pos.y, pos.z, true, true, true)
        FreezeEntityPosition(obj, true)
        SetEntityAsMissionEntity(obj, true, true)
        spawnedObjects[i] = obj
    end
end

local function DeleteAndRespawn(entity)
    for i, obj in pairs(spawnedObjects) do
        if DoesEntityExist(obj) and obj == entity then
            DeleteEntity(obj)
            spawnedObjects[i] = nil

            SetTimeout(Config.SpawnBatuCooldown, function()
                local pos = Config.SpawnBatu[i]
                local newObj = CreateObject(model, pos.x, pos.y, pos.z, true, true, true)
                FreezeEntityPosition(newObj, true)
                SetEntityAsMissionEntity(newObj, true, true)
                spawnedObjects[i] = newObj
            end)
            break
        end
    end
end

RegisterNetEvent('rvz_tambang:client:tambangBatu', function(entity)
    if not DoesEntityExist(entity) then
        lib.notify({ title = 'Error', description = 'Entity tidak valid', type = 'error', position = 'center-right' })
        return
    end

    if lib.progressBar({
            duration = 5000,
            label = 'Menambang Batu',
            useWhileDead = false,
            canCancel = true,
            disable = {
                car = true,
                move = true,
                combat = true
            },
            anim = {
                dict = 'melee@hatchet@streamed_core',
                clip = 'plyr_rear_takedown_b'
            },
            prop = {
                model = `prop_tool_pickaxe`,
                bone = 57005,
                pos = vec3(0.13, 0.0, -0.02),
                rot = vec3(-90.0, 0.0, 0.0)
            },
        }) then
        TriggerServerEvent('rvz_tambang:server:dapatBatu')
        DeleteAndRespawn(entity)
    else
        lib.notify({
            title = 'Batal',
            description = 'Mengambil Batu dibatalkan',
            type = 'error',
            position = 'center-right'
        })
    end
end)

RegisterNetEvent('rvz_tambang:client:cuciBatu', function()
    local hasItem = exports.ox_inventory:Search('count', 'batu')
    if hasItem >= 2 then
        if lib.progressBar({
                duration = 5000,
                label = 'Mencuci Batu',
                useWhileDead = false,
                canCancel = true,
                disable = {
                    car = true,
                    move = true,
                    combat = true
                },
                anim = {
                    dict = 'amb@prop_human_bum_shopping_cart@male@base',
                    clip = 'base'
                },
                prop = {
                    model = `prop_tool_pickaxe`,
                    bone = 57005,
                    pos = vec3(0.13, 0.0, -0.02),
                    rot = vec3(-90.0, 0.0, 0.0)
                },
            }) then
            TriggerServerEvent('rvz_tambang:server:dapatBatuCucian')
        else
            lib.notify({
                title = 'Batal',
                description = 'Mencuci Batu dibatalkan',
                type = 'error',
                position = 'center-right'
            })
        end
    else
        lib.notify({
            title = 'Error',
            description = 'Kamu tidak memiliki cukup batu',
            type = 'error',
            position = 'center-right'
        })
    end
end)

RegisterNetEvent('rvz_tambang:client:smeltBatu', function()
    local hasItem = exports.ox_inventory:Search('count', 'batu_cucian')
    if hasItem >= 2 then
        if lib.progressBar({
                duration = 5000,
                label = 'Smelting Batu',
                useWhileDead = false,
                canCancel = true,
                disable = {
                    car = true,
                    move = true,
                    combat = true
                },
                anim = {
                    dict = 'amb@prop_human_bum_shopping_cart@male@base',
                    clip = 'base'
                },
            }) then
            TriggerServerEvent('rvz_tambang:server:dapatHasilSmelting')
        else
            lib.notify({
                title = 'Batal',
                description = 'Smelting Batu dibatalkan',
                type = 'error',
                position = 'center-right'
            })
        end
    else
        lib.notify({
            title = 'Error',
            description = 'Kamu tidak memiliki cukup batu cucian',
            type = 'error',
            position = 'center-right'
        })
    end
end)

Citizen.CreateThread(function()
    SpawnBatu()
    exports.ox_target:addModel(model, {
        {
            name = 'ambil_batu',
            label = 'Ambil Batu',
            icon = 'fas fa-hammer',
            distance = 2,
            onSelect = function(data)
                local entity = data.entity
                TriggerEvent('rvz_tambang:tambangBatu', entity)
            end
        }
    })

    -- Cuci Batu
    for k, v in pairs(Config.CuciBatu) do
        exports.ox_target:addBoxZone({
            name = 'cuci_batu',
            coords = vector3(v.x, v.y, v.z),
            size = vector3(20, 20, 1.5),
            rotation = 0,
            debug = false,
            options = {
                {
                    name = 'cuci_batu',
                    label = 'Cuci Batu',
                    icon = 'fas fa-water',
                    distance = 2,
                    onSelect = function()
                        TriggerEvent('rvz_tambang:cuciBatu')
                    end
                }
            }
        })
    end

    -- Smelt Batu
    exports.ox_target:addBoxZone({
        name = 'smelt_batu',
        coords = vector3(1110.87, -2008.65, 31.31),
        size = vector3(1, 1, 1.5),
        rotation = 0,
        debug = false,
        options = {
            name = 'smelt_batu',
            label = 'Smelt Batu',
            icon = 'fas fa-water',
            distance = 2,
            onSelect = function ()
                TriggerEvent('rvz_tambang:smeltBatu')
            end
        }
    })
end)

AddEventHandler('onResourceStart', function(resource)
    if resource == GetCurrentResourceName() then
        SpawnBatu()
    end
end)
