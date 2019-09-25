local Coords = {}
local CountCoords = 0



function SendCoordsToServer()
	triggerServerEvent("SendCoords", localPlayer, toJSON(Coords))
	Coords = {}
	CountCoords = 0
	return true
end



function checkKey()
	local theVehicle = getPedOccupiedVehicle(localPlayer)
	if(theVehicle) then
		local i, d = getElementInterior(theVehicle), getElementDimension(theVehicle)
		local seat = getPedOccupiedVehicleSeat(localPlayer)
		if(i == 0 and d == 0 and seat == 0) then
			local x, y, z = getElementPosition(theVehicle)
			x, y = math.round(x), math.round(y)
			if(not Coords[x]) then Coords[x] = {} end
			if(not Coords[x][y]) then Coords[x][y] = 1 end
			CountCoords = CountCoords+1
			if(CountCoords >= 100) then
				SendCoordsToServer()
			end
		end
	end
end
setTimer(checkKey,100,0)


function math.round(number, decimals, method)
    decimals = decimals or 0
    local factor = 10 ^ decimals
    if (method == "ceil" or method == "floor") then return math[method](number * factor) / factor
    else return tonumber(("%."..decimals.."f"):format(number)) end
end
