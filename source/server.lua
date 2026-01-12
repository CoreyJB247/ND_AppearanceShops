-- Ensure MySQL is loaded
local MySQL = MySQL or exports.oxmysql

lib.callback.register("ND_AppearanceShops:clothingPurchase", function(src, store, clothing)
    local store = Config[store]
    local player = NDCore.getPlayer(src)
    if not store or not player then return end

    local price = store.price
    if not price then return true end
    if not player.deductMoney("bank", price, store.blip.label) then
        player.notify({
            title = store.blip.label,
            description = ("Payment of $%d failed!"):format(price),
            position = "bottom",
            type = "error"
        })
        return
    end

    if clothing and type(clothing) == "table" then
        player.setMetadata("clothing", clothing)
    end
    player.notify({
        title = store.blip.label,
        description = ("Payment of $%d confirmed!"):format(price),
        position = "bottom",
        type = "success"
    })
    return true
end)

RegisterNetEvent("ND_AppearanceShops:updateAppearance", function(clothing)
    local src = source
    local player = NDCore.getPlayer(src)
    if not player then return end

    if clothing and type(clothing) == "table" then
        player.setMetadata("clothing", clothing)
    end
end)

-- ============================================
-- NEW DATABASE FUNCTIONS (PER CHARACTER)
-- ============================================

-- Save outfit to database for specific character
lib.callback.register("ND_AppearanceShops:saveOutfit", function(src, name, appearance)
    local player = NDCore.getPlayer(src)
    if not player then return false end
    
    local characterId = player.id
    local appearanceJson = json.encode(appearance)
    
    local success = MySQL.insert.await('INSERT INTO player_outfits (character_id, name, appearance) VALUES (?, ?, ?)', {
        characterId,
        name,
        appearanceJson
    })
    
    return success and success > 0
end)

-- Load all outfits for current character (sorted alphabetically)
lib.callback.register("ND_AppearanceShops:getOutfits", function(src)
    local player = NDCore.getPlayer(src)
    if not player then return {} end
    
    local characterId = player.id
    
    local result = MySQL.query.await('SELECT id, name, appearance FROM player_outfits WHERE character_id = ? ORDER BY name ASC', {
        characterId
    })
    
    local outfits = {}
    for _, outfit in ipairs(result or {}) do
        table.insert(outfits, {
            id = outfit.id,
            name = outfit.name,
            appearance = json.decode(outfit.appearance)
        })
    end
    
    return outfits
end)

-- Delete outfit (with character verification)
lib.callback.register("ND_AppearanceShops:deleteOutfit", function(src, outfitId)
    local player = NDCore.getPlayer(src)
    if not player then return false end
    
    local characterId = player.id
    
    local success = MySQL.query.await('DELETE FROM player_outfits WHERE id = ? AND character_id = ?', {
        outfitId,
        characterId
    })
    
    return success and success.affectedRows > 0
end)

-- Rename outfit (with character verification)
lib.callback.register("ND_AppearanceShops:renameOutfit", function(src, outfitId, newName)
    local player = NDCore.getPlayer(src)
    if not player then return false end
    
    local characterId = player.id
    
    local success = MySQL.query.await('UPDATE player_outfits SET name = ? WHERE id = ? AND character_id = ?', {
        newName,
        outfitId,
        characterId
    })
    
    return success and success.affectedRows > 0
end)

-- Update outfit with new appearance (with character verification)
lib.callback.register("ND_AppearanceShops:updateOutfit", function(src, outfitId, appearance)
    local player = NDCore.getPlayer(src)
    if not player then return false end
    
    local characterId = player.id
    local appearanceJson = json.encode(appearance)
    
    local success = MySQL.query.await('UPDATE player_outfits SET appearance = ? WHERE id = ? AND character_id = ?', {
        appearanceJson,
        outfitId,
        characterId
    })
    
    return success and success.affectedRows > 0
end)