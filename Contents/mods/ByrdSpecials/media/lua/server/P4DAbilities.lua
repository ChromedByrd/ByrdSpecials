--Function to be used elsewhere inside this "class"
local function GetHypotenuse(zX, zY, pX, pY)
    return math.abs((zX-pX)^2 + math.abs(zY-pY)^2)^0.5;
end

local SPEED_SPRINTER = 1
local SPEED_FAST_SHAMBLER = 2
local SPEED_SHAMBLER = 3

function isTableEmpty(t)
	for _ in pairs(t) do
		return false
	end
	return true
end
--Meant to change behavior of specials.
function SpecialZombieAbilities(zombie)
	local spclZ = zombie;
	local outfit = tostring(spclZ:getOutfitName());
	local mdDta = spclZ:getModData();
	
	if mdDta == nil or isTableEmpty(mdDta) then
		spclZ:getModData()["abilityTicker"] = 0
	end
	
	local player = getPlayer();
	local rangeToPlayer = GetHypotenuse(spclZ:getX(), spclZ:getY(), player:getX(), player:getY());
	
	if outfit == CHARGER_OUTFIT_NAME then
		if rangeToPlayer < CHARGER_MAX_RANGE_CHECK then
			spclZ:getModData()["abilityTicker"] = spclZ:getModData()["abilityTicker"] + 1;
			if rangeToPlayer <= CHARGER_ABILITY_RANGE then
				if spclZ:getModData()["abilityTicker"] >= CHARGER_CD and spclZ:isKnockedDown() == false then
					player:setKnockedDown(true);
					spclZ:getModData()["abilityTicker"] = 0;
				end
			end
		end
	elseif outfit == BOOMER_OUTFIT_NAME then
		if rangeToPlayer < BOOMER_MAX_RANGE_CHECK then
			spclZ:getModData()["abilityTicker"] = spclZ:getModData()["abilityTicker"] + 1;
			if rangeToPlayer <= BOOMER_ABILITY_RANGE then
				if spclZ:getModData()["abilityTicker"] >= BOOMER_CD then
					spclZ:getCurrentSquare():explode()
					spclZ:playSound("BigExplosion");
					WorldFlares.launchFlare(750, spclZ:getX(), spclZ:getY(), 5, 0, 1, 0, 0, 1, 0, 0);
					spclZ:setHealth(0)
				end
			end
		end
	elseif outfit == RECLAIMER_OUTFIT_NAME then
		if rangeToPlayer < RECLAIMER_MAX_RANGE_CHECK then
			spclZ:getModData()["abilityTicker"] = spclZ:getModData()["abilityTicker"] + 1;
			if rangeToPlayer <= RECLAIMER_ABILITY_RANGE then
				if spclZ:getModData()["abilityTicker"] >= RECLAIMER_CD then
					spclZ:setHealth(RECLAIMER_MIN_HP)
					spclZ:getModData()["abilityTicker"] = 0;
				end
			end
		end
	else
		--Not a special zombie.
	end
	
end

Events.OnZombieUpdate.Add(SpecialZombieAbilities)