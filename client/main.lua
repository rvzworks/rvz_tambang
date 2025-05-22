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

        local netId = NetworkGetNetworkIdFromEntity(obj)
        SetNetworkIdExistsOnAllMachines(netId, true)

        spawnedObjects[i] = obj
    end
end

local function DeleteAndRespawn(entity)
    for i, obj in pairs(spawnedObjects) do
        if DoesEntityExist(obj) and obj == entity then
            DeleteEntity(obj)
            spawnedObjects[i] = nil

            SetTimeout(10000, function()
                local pos = Config.SpawnBatu[i]
                local newObj = CreateObject(model, pos.x, pos.y, pos.z, true, true, true)
                FreezeEntityPosition(newObj, true)
                SetEntityAsMissionEntity(newObj, true, true)
                local netId = NetworkGetNetworkIdFromEntity(newObj)
                SetNetworkIdExistsOnAllMachines(netId, true)
                spawnedObjects[i] = newObj
            end)
            break
        end
    end
end

RegisterNetEvent('rvz_tambang:tambangBatu', function(entity)
    if not DoesEntityExist(entity) then
        lib.notify({ title = 'Error', description = 'Entity tidak valid', type = 'error' })
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
        TriggerServerEvent('rvz_tambang:dapatBatu')
        DeleteAndRespawn(entity)
    else
        lib.notify({
            title = 'Batal',
            description = 'Mengambil Batu dibatalkan',
            type = 'error'
        })
    end
end)

RegisterNetEvent('rvz_tambang:cuciBatu', function()
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
            TriggerServerEvent('rvz_tambang:dapatBatuCucian')
        else
            lib.notify({
                title = 'Batal',
                description = 'Mencuci Batu dibatalkan',
                type = 'error'
            })
        end
    else
        lib.notify({
            title = 'Error',
            description = 'Kamu tidak memiliki cukup batu',
            type = 'error'
        })
    end
end)

Citizen.CreateThread(function()
    SpawnBatu()
    exports.ox_target:addModel(model, {
        {
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
    exports.ox_target:addBoxZone({
        name = 'cuci_batu',
        coords = vector3(1915.9977, 330.9988, 161.5980),
        size = vector3(20, 20, 1.5),
        rotation = 0,
        debug = true,
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
end)

AddEventHandler('onResourceStart', function(resource)
    if resource == GetCurrentResourceName() then
        SpawnBatu()
    end
end)
