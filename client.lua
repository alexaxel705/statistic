local Coords = {}
local CountCoords = 0

local WriteStatus = false -- Запись координат

local VehicleSkillDistance = 0 -- Расстояние на автомобиле
local VehicleWriteDistance = 0
local PedSkillDistance = 0 -- Расстояние пешком
local PedWriteDistance = 0
local drx,dry,drz = getElementPosition(localPlayer)
local PedStats = {}
local StreamerDistance = 0

for slot = 3, 4 do
	PedStats[slot] = getPedStat(localPlayer, slot)
end


function GetStats(skill)
	if(PedStats[skill]) then
		return PedStats[skill]
	else
		return 0
	end
end



function SendCoordsToServer()
	triggerServerEvent("SendCoords", localPlayer, toJSON(Coords))
	Coords = {}
	CountCoords = 0
	return true
end

local VehTypeSkill = {
	["Automobile"] = 160,
	["Monster Truck"] = 160,
	["Unknown"] = 160,
	["Trailer"] = 160,
	["Train"] = 160,
	["Boat"] = 160,
	["Bike"] = 229,
	["Quad"] = 229,
	["BMX"] = 230,
	["Helicopter"] = 169,
	["Plane"] = 169
}

local VehicleType = {
	[441] = "RC", 
	[464] = "RC", 
	[594] = "RC", 
	[501] = "RC", 
	[465] = "RC", 
	[564] = "RC", 
}

function GetVehicleType(theVehicle)
	if(isElement(theVehicle)) then theVehicle = getElementModel(theVehicle) end
	return VehicleType[theVehicle] or getVehicleType(theVehicle)
end

function checkKey()
	local x,y,z = getElementPosition(localPlayer)
	local distance = getDistanceBetweenPoints3D(drx, dry, drz, x, y, z)
	drx,dry,drz = x,y,z
	
	StreamerDistance = StreamerDistance+distance
	if(StreamerDistance > 100) then
		if(#getElementsByType("ped", getRootElement(), true) < 50) then
			triggerServerEvent("Streamer", localPlayer, localPlayer)
		end
		StreamerDistance = 0
	end
		
	local theVehicle = getPedOccupiedVehicle(localPlayer)
	
	if(theVehicle) then
		PedStats[4] = PedStats[4]+distance
		VehicleSkillDistance = VehicleSkillDistance+distance
		
		if(VehicleSkillDistance >= 3000) then
			local VehType = GetVehicleType(theVehicle)
			VehicleSkillDistance = 0
			triggerServerEvent("AddSkill", localPlayer, localPlayer, VehTypeSkill[VehType], 1)
		end
		
		
		if(WriteStatus) then
			VehicleWriteDistance = VehicleWriteDistance+distance
			if(VehicleWriteDistance > 10) then
				VehicleWriteDistance = 0
				save()
			end
		end
		
		local i, d = getElementInterior(theVehicle), getElementDimension(theVehicle)
		local seat = getPedOccupiedVehicleSeat(localPlayer)
		if(i == 0 and d == 0 and seat == 0) then
			x, y = math.round(x), math.round(y)
			if(not Coords[x]) then Coords[x] = {} end
			if(not Coords[x][y]) then Coords[x][y] = 1 end
			CountCoords = CountCoords+1
			if(CountCoords >= 100) then
				SendCoordsToServer()
			end
		end
	else
		PedStats[3] = PedStats[3]+distance
		
		PedSkillDistance = PedSkillDistance+distance
		if(PedSkillDistance >= 300) then
			PedSkillDistance = 0
			triggerServerEvent("AddSkill", localPlayer, localPlayer, 24, 5)
			triggerServerEvent("AddSkill", localPlayer, localPlayer, 22, 10)
		end
		
		if(WriteStatus) then
			PedWriteDistance = PedWriteDistance+distance
			if(PedWriteDistance > 5) then
				PedWriteDistance = 0
				save()
			end
		end
	end
end





local StatisticTimer = false
function Start()
	if(isPedDead(localPlayer)) then return false end
	if(getElementData(localPlayer, "PlayerStatus") ~= "play") then return false end
	if(isPedDead(localPlayer)) then return false end
	StatisticTimer = setTimer(checkKey,100,0)
end
addEventHandler("onClientResourceStart", getResourceRootElement(), Start)




function Spawn()
	local x, y, z = getElementPosition(localPlayer)
	drx,dry,drz = x,y,z
	StatisticTimer = setTimer(checkKey,100,0)
end
addEventHandler("onClientPlayerSpawn", getLocalPlayer(), Spawn)


function onWastedEffect(killer, weapon, bodypart)
	killTimer(StatisticTimer)
end
addEventHandler("onClientPlayerWasted", getRootElement(), onWastedEffect)







function PlayerVehicleExit(theVehicle, seat)
	if(source == localPlayer) then 
		if(seat == 0) then
			SendCoordsToServer()
		end
	end
end
addEventHandler("onClientPlayerVehicleExit", getRootElement(), PlayerVehicleExit)



addCommandHandler( "getinfo",
	function( )
		local info = dxGetStatus( )
		for k, v in pairs( info ) do
			outputChatBox( k .. " : " .. tostring( v ) )
		end
	end
)





function cursor() 
    if isCursorShowing(thePlayer) then
		showCursor(false)
	else
		showCursor(true)
    end

end


function saveauto()
	VehicleWriteDistance = 0
	PedWriteDistance = 0
	
	if(not WriteStatus) then
		save()
		triggerEvent("helpmessageEvent", localPlayer, "Запись начата")
		WriteStatus = true
	else
		triggerEvent("helpmessageEvent", localPlayer, "Запись остановлена")
		WriteStatus = false
	end
end



function save()
	local x,y,z = getElementPosition(localPlayer)
	local rx,ry,rz = getElementRotation(localPlayer)
	if(getPedOccupiedVehicle(localPlayer)) then
		x,y,z = getElementPosition(getPedOccupiedVehicle(localPlayer))
		if(not getElementData(localPlayer, "City")) then 
			z = getGroundPosition(x,y,z)
		else
			z = z-1
		end
		rx,ry,rz = getElementRotation(getPedOccupiedVehicle(localPlayer))
		triggerEvent("OutputChat", localPlayer, math.round(x, 1)..", "..math.round(y, 1)..", "..math.round(z, 1)..", "..math.round(rz, 0), "Coord")
		triggerServerEvent("saveserver", localPlayer, localPlayer, x,y,z,rx,ry,rz)
	else
		z = getGroundPosition(x,y,z)
		triggerEvent("OutputChat", localPlayer, math.round(x, 1)..", "..math.round(y, 1)..", "..math.round(z, 1)..", "..math.round(rz, 0), "Coord")
		triggerServerEvent("saveserver", localPlayer, localPlayer, x,y,z,rx,ry,rz, "PedPath")
	end
end



if getPlayerName(localPlayer) == "alexaxel705" then
	bindKey("num_1", "down", saveauto) 
	bindKey("num_3", "down", save)
end


bindKey("F2", "down", cursor) 








function math.round(number, decimals, method)
    decimals = decimals or 0
    local factor = 10 ^ decimals
    if (method == "ceil" or method == "floor") then return math[method](number * factor) / factor
    else return tonumber(("%."..decimals.."f"):format(number)) end
end












