RegisterNetEvent('rvz_tambang:server:dapatBatu', function()
    local src = source
    exports.ox_inventory:AddItem(src, 'raw_ore', math.random(Config.HasilBatu.min, Config.HasilBatu.max))
end)

RegisterNetEvent('rvz_tambang:server:dapatBatuCucian', function()
    local src = source
    exports.ox_inventory:RemoveItem(src, 'raw_ore', 2)
    exports.ox_inventory:AddItem(src, 'washed_ore', 2)
end)

RegisterNetEvent('rvz_tambang:server:dapatHasilSmelting', function()
    local src = source
    local chance = math.random(100)
    exports.ox_inventory:RemoveItem(src, 'washed_ore', 5)

    exports.ox_inventory:AddItem(src, 'iron_ingot', 2)
    exports.ox_inventory:AddItem(src, 'copper_ingot', 1)
    exports.ox_inventory:AddItem(src, 'coal_chunk', 1)
    exports.ox_inventory:AddItem(src, 'sulfur', 1)

    if chance <= 15 then
        exports.ox_inventory:AddItem(src, 'aluminum_ingot', 1)
    end

    if chance <= 5 then
        exports.ox_inventory:AddItem(src, 'gold_nugget', 1)
    end
end)
