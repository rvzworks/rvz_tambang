QBCore = exports['qb-core']:GetCoreObject()
local model = 'prop_rock_1_c'
local spawnedObjects = {}
local lagiAction = false

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
    local hasItem = exports.ox_inventory:Search('count', 'raw_ore')
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
                    dict = 'amb@world_human_bum_wash@male@high@idle_a',
                    clip = 'idle_a'
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
    local hasItem = exports.ox_inventory:Search('count', 'washed_ore')
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
    for k, lokasi in pairs(Config.CuciBatu) do
        local radiusBlip = AddBlipForRadius(lokasi.x, lokasi.y, lokasi.z, 100.0)
        SetBlipColour(radiusBlip, 26) 
        SetBlipAlpha(radiusBlip, 128) 
    end
end)

Citizen.CreateThread(function()
    exports.ox_target:addModel(model, {
        {
            name = 'ambil_batu',
            label = 'Ambil Batu',
            icon = 'fas fa-hammer',
            distance = 2,
            onSelect = function(data)
                local entity = data.entity
                TriggerEvent('rvz_tambang:client:tambangBatu', entity)
            end
        }
    })

    exports.ox_target:addBoxZone({
        name = 'smelt_batu',
        coords = vector3(1110.87, -2008.65, 31.31),
        size = vector3(1, 1, 1.5),
        rotation = 0,
        debug = false,
        options = {
            {
                name = 'smelt_batu',
                label = 'Smelt Batu',
                icon = 'fas fa-water',
                distance = 2,
                onSelect = function()
                    TriggerEvent('rvz_tambang:client:smeltBatu')
                end
            }
        }
    })

    while true do
        local waitTime = 1000 
        local ped = PlayerPedId()
        local playerCoords = GetEntityCoords(ped)
        local isNear = false
        for k, lokasi in pairs(Config.CuciBatu) do
            local dist = #(playerCoords - vector3(lokasi.x, lokasi.y, lokasi.z))
            if dist < 100 then
                isNear = true
                waitTime = 0 
                if not lagiAction then
                    lib.showTextUI('[E] - untuk cuci batu')
                    if IsControlJustPressed(0, 38) then
                        lagiAction = true              
                        local success = lib.skillCheck('easy')
                        if success then
                            TriggerEvent('rvz_tambang:client:cuciBatu')
                        end
                        SetTimeout(5000, function()
                            lagiAction = false
                        end)
                    end
                end

                break
            end
        end
        if not isNear then
            lib.hideTextUI()
        end
        Citizen.Wait(waitTime)
    end
end)

AddEventHandler('onResourceStart', function(resource)
    if resource == GetCurrentResourceName() then
        SpawnBatu()
    end
end)
