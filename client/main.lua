QBCore = exports['qb-core']:GetCoreObject()
local model = Config.ModelBatu
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
            duration = Config.Progress.Tambang.duration,
            label = Config.Progress.Tambang.label,
            useWhileDead = false,
            canCancel = true,
            disable = {
                car = true,
                move = true,
                combat = true
            },
            anim = Config.Progress.Tambang.anim,
            prop = Config.Progress.Tambang.prop
        }) then
        TriggerServerEvent('rvz_tambang:server:dapatBatu')
        DeleteAndRespawn(entity)
    else
        lib.notify({
            title = 'Batal',
            description = 'Menambang Batu dibatalkan',
            type = 'error',
            position = 'center-right'
        })
    end
end)

RegisterNetEvent('rvz_tambang:client:cuciBatu', function()
    local itemName = Config.Item.BatuMentah
    local itemRequired = 2
    local hasItem = exports.ox_inventory:Search('count', itemName)

    if hasItem >= itemRequired then
        local progress = Config.Progress.Cuci
        if lib.progressBar({
                duration = progress.duration,
                label = progress.label,
                useWhileDead = false,
                canCancel = true,
                disable = {
                    car = true,
                    move = true,
                    combat = true
                },
                anim = progress.anim,
                prop = progress.prop -- optional, bisa nil
            }) then
            TriggerServerEvent('rvz_tambang:server:dapatBatuCucian')
        else
            lib.notify({
                title = 'Batal',
                description = progress.label .. ' dibatalkan',
                type = 'error',
                position = 'center-right'
            })
        end
    else
        lib.notify({
            title = 'Error',
            description = 'Kamu tidak memiliki cukup ' .. itemName:gsub('_', ' '),
            type = 'error',
            position = 'center-right'
        })
    end
end)


RegisterNetEvent('rvz_tambang:client:smeltBatu', function()
    local itemName = Config.Item.BatuCuci
    local itemRequired = 2
    local hasItem = exports.ox_inventory:Search('count', itemName)

    if hasItem >= itemRequired then
        local progress = Config.Progress.Smelt
        if lib.progressBar({
                duration = progress.duration,
                label = progress.label,
                useWhileDead = false,
                canCancel = true,
                disable = {
                    car = true,
                    move = true,
                    combat = true
                },
                anim = progress.anim,
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
            description = 'Kamu tidak memiliki cukup ' .. itemName:gsub('_', ' '),
            type = 'error',
            position = 'center-right'
        })
    end
end)

Citizen.CreateThread(function()
    for k, lokasi in pairs(Config.CuciBatu) do
        local radiusBlip = AddBlipForRadius(lokasi.x, lokasi.y, lokasi.z, 50.0)
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
            if dist < 50 then
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
