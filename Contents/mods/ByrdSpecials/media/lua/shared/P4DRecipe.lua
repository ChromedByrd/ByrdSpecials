	local lewt = 
	{ 
		"Base.Axe",
		"Base.BallPeenHammer", 
		"Base.ClubHammer", 
		"Base.CarBatteryCharger", 
		"Base.Crowbar", 
		"Base.GardenSaw", 
		"Base.Hammer", 
		"Base.HandAxe", 
		"Base.Jack", 
		"Base.LugWrench", 
		"Base.Paintbrush", 
		"Base.PipeWrench", 
		"Base.BlowTorch", 
		"Base.AxeStone", 
		"Base.Saw", 
		"Base.Screwdriver", 
		"Base.Sledgehammer", 
		"Base.HammerStone", 
		"Base.TirePump", 
		"Base.WoodAxe", 
		"Base.WoodenMallet", 
		"Base.Spanner"
	}

	function GetLootFromSkin()
		rndItmNum = ZombRand(#lewt)+1
		print(rndItmNum)
		getPlayer():getInventory():AddItems(lewt[rndItmNum], 1)
	end