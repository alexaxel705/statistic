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
	callRemote("http://109.227.228.4/engine/include/MTA/stats/kill.php", ResultGet, toJSON({x, y}))
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
