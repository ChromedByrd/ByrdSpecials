function findField(obj, fname)
  for i = 0, getNumClassFields(obj) - 1 do
    local fn = getClassField(obj, i)
    if tostring(fn) == fname then
      return fn
    end
  end
end

local DRIFT_VARIANCE = 5
local TOO_CLOSE_NUMBER = 80
local QUAD_DIST = 80

function GetRandomPlayer()
	local chosenPlayer;
	
	if isServer() then
		local players = getOnlinePlayers();
		local chosenOne = ZombRand(#onlinePlayers)+1;
		chosenPlayer = onlinePlayers[chosenOne];
	else
		chosenPlayer = getPlayer();
	end
	
	return chosenPlayer;
end

function IsInBounds(x1, y1, x2, y2)
	if x1 > x and y1 > y then
		return true;
	else
		return false;
	end
end

function GetQuad(n)
	local toReturn
	
	if ZombRand(2) == 1 then
		toReturn = n - QUAD_DIST;
	else
		toReturn = n + QUAD_DIST;
	end
	
	return toReturn;
end

function GetDriftCoord()
	local toReturn
	
	if ZombRand(2) == 1 then
		toReturn = ZombRand(DRIFT_VARIANCE);
	else
		toReturn = -ZombRand(DRIFT_VARIANCE);
	end
	
	return toReturn;
end

function GetRandomCoord(n)
	local toReturn
	
	local q = GetQuad(n)
	local d = GetDriftCoord();
	
	toReturn = q + d;
	
	return toReturn;
end

function GetNearPlayer(pX, pY, zN)
	if not isServer() then
		return false;
	end
	
	local players = getOnlinePlayers();
	
	for i=1,#players,1
	do
		--Right Side
		local aX = pX + TOO_CLOSE_NUMBER;
		--Top Side
		local aY = pY - TOO_CLOSE_NUMBER;
		--Left Side
		local bX = pX - TOO_CLOSE_NUMBER;
		--Bot Side
		local bY = pY + TOO_CLOSE_NUMBER;
		
		--This is confusing
		if (zX < aX and zY < bY) or (zX > bX and zY > aY)then
			return players[i];
		end
	end
	
	return nil;
end

function GetNewCoordForNearPlayer(pX, pY, zN)
	local toReturn = false
	
	local possP = GetNearPlayer(pX, pY, zN);
	
	if possP ~= nil then
		coords = GetCoordForNearPlayer(pX, pY, zX, zY);
	end
	
	return toReturn;
end

--I would rather not update stats for no reason on already spawned zombies.
--So I'm trying to spawn them at intervals I wonder though if this will
--Create zombies like I want it to.
function CreateASpecial()
	local rP = GetRandomPlayer();
	
	local rX = GetRandomCoord(rP:getX());
	local rY = GetRandomCoord(rP:getY());
	
	local spclZ = createZombie(rX, rY, 0 , nil, 0, IsoDirections.E);
	
	local specialRandNum = ZombRand(SPECIAL_TOTAL)+1;
	if specialRandNum == CHARGER_NUM then
		getSandboxOptions():set("ZombieLore.Speed", CHARGER_SPEED)
		spclZ:makeInactive(true)
		spclZ:makeInactive(false)
		getSandboxOptions():set("ZombieLore.Speed", SPEED_FAST_SHAMBLER)
		spclZ:dressInPersistentOutfit(CHARGER_OUTFIT_NAME);
		spclZ:setHealth(CHARGER_MAX_HP)
	elseif specialRandNum == BOOMER_NUM then
		getSandboxOptions():set("ZombieLore.Speed", BOOMER_SPEED)
		spclZ:makeInactive(true)
		spclZ:makeInactive(false)
		getSandboxOptions():set("ZombieLore.Speed", SPEED_FAST_SHAMBLER)
		spclZ:dressInPersistentOutfit(BOOMER_OUTFIT_NAME);
		spclZ:setHealth(BOOMER_MAX_HP)
	elseif specialRandNum == RECLAIMER_NUM then
		getSandboxOptions():set("ZombieLore.Speed", RECLAIMER_SPEED)
		spclZ:makeInactive(true)
		spclZ:makeInactive(false)
		getSandboxOptions():set("ZombieLore.Speed", SPEED_FAST_SHAMBLER)
		spclZ:dressInPersistentOutfit(RECLAIMER_OUTFIT_NAME);
		spclZ:setHealth(RECLAIMER_MAX_HP)
	else
		--huh?
	end
	
	print(tostring(spclZ:getOutfitName()), " Spawned at: ", spclZ:getX(), ",", spclZ:getY())
end
--this is to ensure that there is less intensive way to update zombie speed.
--this will "wake them up" to be not default speed when they are hit.
function SetSpeedAgain(zombie)
	local outfit = tostring(zombie:getOutfitName());
	if outfit == CHARGER_OUTFIT_NAME then
		getSandboxOptions():set("ZombieLore.Speed", CHARGER_SPEED)
		zombie:makeInactive(true)
		zombie:makeInactive(false)
		getSandboxOptions():set("ZombieLore.Speed", SPEED_FAST_SHAMBLER)
	elseif outfit == BOOMER_OUTFIT_NAME then
		getSandboxOptions():set("ZombieLore.Speed", BOOMER_SPEED)
		zombie:makeInactive(true)
		zombie:makeInactive(false)
		getsandboxoptions():set("ZombieLore.Speed", SPEED_FAST_SHAMBLER)
	elseif outfit == RECLAIMER_OUTFIT_NAME then
		getSandboxOptions():set("ZombieLore.Speed", RECLAIMER_SPEED)
		zombie:makeInactive(true)
		zombie:makeInactive(false)
		getSandboxOptions():set("ZombieLore.Speed", SPEED_FAST_SHAMBLER)
	else
		--not a special zombie.
	end
end

Events.OnHitZombie.Add(SetSpeedAgain)
Events.EveryTenMinutes.Add(CreateASpecial)