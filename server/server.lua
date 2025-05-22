RegisterNetEvent('rvz_tambang:dapatBatu', function()
    local src = source
    exports.ox_inventory:AddItem(src, 'batu', math.random(Config.HasilBatu.min, Config.HasilBatu.max))
end)

RegisterNetEvent('rvz_tambang:dapatBatuCucian', function()
    local src = source
    exports.ox_inventory:RemoveItem(src, 'batu', 2)
    exports.ox_inventory:AddItem(src, 'batu_cucian', 2)
end)

RegisterNetEvent('rvz_tambang:dapatHasilSmelting', function()
    local src = source
    exports.ox_inventory:RemoveItem(src, 'batu_cucian', 2)

    -- Item Tambang
    exports.ox_inventory:RemoveItem(src, 'batu', 2)
end)