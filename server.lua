local PlayTime = {}
function math.round(number, decimals, method)
    decimals = decimals or 0
    local factor = 10 ^ decimals
    if (method == "ceil" or method == "floor") then return math[method](number * factor) / factor
    else return tonumber(("%."..decimals.."f"):format(number)) end
end

function ResultGet()

end

function player_Wasted()
	local x,y,_ = getElementPosition(source)
	x = math.round(x)
	y = math.round(y)
	callRemote("http://109.227.228.4/engine/include/MTA/stats/death.php", ResultGet, toJSON({x, y}))
end
addEventHandler("onPlayerWasted", root, player_Wasted)





function Join()
	PlayTime[source] = getTickCount()
end
addEventHandler("onPlayerJoin", getRootElement(), Join)



function ScriptOn()
	for theKey,thePlayer in ipairs(getElementsByType("player")) do
		PlayTime[thePlayer] = getTickCount()
	end
end
addEventHandler("onResourceStart", getResourceRootElement(), ScriptOn)



function Quit()
	callRemote("http://109.227.228.4/engine/include/MTA/stats/playtime.php", ResultGet, getTickCount()-PlayTime[source])
	PlayTime[source] = nil
end
addEventHandler("onPlayerQuit", getRootElement(), Quit)





local Coords = {}
local SendToServer = 30 -- Отправлять на сервер каждые
setTimer(function()
	for theKey,thePlayer in ipairs(getElementsByType("player")) do
		local i,d = getElementInterior(thePlayer), getElementDimension(thePlayer)
		local theVehicle = getPedOccupiedVehicle(thePlayer)
		if(i == 0 and d == 0 and theVehicle) then
			local x,y,_ = getElementPosition(thePlayer)
			x, y = math.round(x), math.round(y)
			if(not Coords[x]) then Coords[x] = {} end
			if(not Coords[x][y]) then Coords[x][y] = 0 end
			Coords[x][y] = Coords[x][y]+1
			if(SendToServer == 0) then
				callRemote("http://109.227.228.4/engine/include/MTA/stats/zone.php", ResultGet, toJSON(Coords))
				Coords = {}
				SendToServer = 30
			else
				SendToServer = SendToServer-1
			end
		end
	end
end, 1000, 0)


function math.round(number, decimals, method)
    decimals = decimals or 0
    local factor = 10 ^ decimals
    if (method == "ceil" or method == "floor") then return math[method](number * factor) / factor
    else return tonumber(("%."..decimals.."f"):format(number)) end
end















