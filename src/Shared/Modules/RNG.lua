return function(module, luck)
	luck = math.clamp(luck or 0, 0, 100)
	local rollableItems = {}
	for _, item in ipairs(module.Stuff) do
		if item.Rollable then
			table.insert(rollableItems, item)
		end
	end

	local rarityMap = {}
	for _, rarityInfo in ipairs(module.Odds) do
		rarityMap[rarityInfo.Name] = rarityInfo.Rarity
	end

	local drops = {}
	for _, item in ipairs(rollableItems) do
		local rarityValue = rarityMap[item.Rarity]
		if rarityValue then
			table.insert(drops, {
				Item = item,
				Rarity = rarityValue
			})
		end
	end

	table.sort(drops, function(a, b)
		return a.Rarity > b.Rarity
	end)

	local filteredDrops = {}
	for _, drop in ipairs(drops) do
		if luck >= 50 and drop.Rarity < 20 then
			table.insert(filteredDrops, drop)
		elseif luck >= 20 and drop.Rarity < 40 then
			table.insert(filteredDrops, drop)
		elseif luck < 20 then
			table.insert(filteredDrops, drop)
		end
	end

	if #filteredDrops == 0 and #drops > 0 then
		filteredDrops = drops
	end

	local totalWeight = 0
	for _, drop in ipairs(filteredDrops) do
		local luckMultiplier = 1 + (luck / 100) * (drop.Rarity / 50)
		drop.AdjustedRarity = math.min(drop.Rarity * luckMultiplier, 100)
		totalWeight = totalWeight + drop.AdjustedRarity
	end

	if totalWeight == 0 then
		if #drops > 0 then
			return drops[#drops].Item
		end
		return nil
	end

	local randomNum = math.random(1, totalWeight)
	local currentWeight = 0
	for _, drop in ipairs(filteredDrops) do
		currentWeight = currentWeight + drop.AdjustedRarity
		if randomNum <= currentWeight then
			return drop.Item
		end
	end

	if #filteredDrops > 0 then
		return filteredDrops[#filteredDrops].Item
	elseif #drops > 0 then
		return drops[#drops].Item
	end
	return nil
end