--Function to be used elsewhere inside this "class"
local function GetHypotenuse(zX, zY, pX, pY)
    return math.sqrt((zX - pX)^2 + (zY - pY)^2)
end

local function getNearestPlayerToZombie(zombie)
	if isServer() then
		return getPlayer();
	end
    local nearestPlayer = nil
    local shortestDistance = math.huge  -- Represents a very large number

    local players = getOnlinePlayers()  -- Get the list of online players

    for i = 1, #players do
        local player = players[i]
        local distance = GetHypotenuse(zombie.getX(), zombie.getY(), player.getX(), player.getY())
        if distance < shortestDistance then
            shortestDistance = distance
            nearestPlayer = player
        end
    end

    return nearestPlayer
end

local SPEED_SPRINTER = 1
local SPEED_FAST_SHAMBLER = 2
local SPEED_SHAMBLER = 3

local function isTableEmpty(t)
	for _ in pairs(t) do
		return false
	end
	return true
end
--
local function doCheckAbilityCountdownCheck(zombieToPlayerRange,rangeToCheck,spclZ)
	-- If they are in range then we need to start the countdown for the ability usage.
	if zombieToPlayerRange < rangeToCheck then
		spclZ:getModData()["abilityTicker"] = spclZ:getModData()["abilityTicker"] + 1;
		return true
	-- If we are out of range then we need to reset the countdown.
	else 
		spclZ:getModData()["abilityTicker"] = 0;
		return false
	end
end
--Meant to change behavior of specials.
local function specialZombieAbilities(zombie)
	-- I only added this because I needed a locally exposed value in the debugger.
	local spclZ = zombie;

	-- Check if the zombie is alive.
	if spclZ.isAlive() ~= true then
		return
	end

	-- Because this game is trash.....
	if spclZ:getHealth() <= 0 then
		spclZ:Kill(nil);
	end

	local outfit = tostring(spclZ:getOutfitName());
	local mdDta = spclZ:getModData();
	
	-- If the table is empty or the mdDta is null it needs to be initialized I guess.
	if mdDta == nil or isTableEmpty(mdDta) then
		spclZ:getModData()["abilityTicker"] = 0
	end
	
	local player = getNearestPlayerToZombie(spclZ);

	--Exit if it can't find a player.
	if player == nil then
		return
	end

	local rangeToPlayer = GetHypotenuse(spclZ:getX(), spclZ:getY(), player:getX(), player:getY());
	
	if outfit == CHARGER_OUTFIT_NAME then
		local isInRange = doCheckAbilityCountdownCheck(rangeToPlayer,CHARGER_MAX_RANGE_CHECK,spclZ)
		if isInRange then
			if rangeToPlayer <= CHARGER_ABILITY_RANGE then
				if spclZ:getModData()["abilityTicker"] >= CHARGER_CD and spclZ:isKnockedDown() == false then
					player:setKnockedDown(true);
					spclZ:getModData()["abilityTicker"] = 0;
				end
			end
		end
	elseif outfit == BOOMER_OUTFIT_NAME then
		local isInRange = doCheckAbilityCountdownCheck(rangeToPlayer,BOOMER_MAX_RANGE_CHECK,spclZ)
		if isInRange then
			if rangeToPlayer <= BOOMER_ABILITY_RANGE then
				if spclZ:getModData()["abilityTicker"] >= BOOMER_CD then
					spclZ:getCurrentSquare():explode();
					spclZ:playSound("BigExplosion");
					spclZ:setHealth(0);
					spclZ:Kill(nil);
				end
			end
		end
	elseif outfit == RECLAIMER_OUTFIT_NAME then
		local isInRange = doCheckAbilityCountdownCheck(rangeToPlayer,RECLAIMER_MAX_RANGE_CHECK,spclZ)
		if isInRange then
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

Events.OnZombieUpdate.Add(specialZombieAbilities)