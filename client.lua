local NickNameBar = {}
local NickNameBarW, NickNameBarH = 200, 40
local StaminaBarW, StaminaBarH = 75, 1

function getMaxStamina()
	return 5+math.floor(getPedStat(localPlayer, 22)/40)
end

local Stamina = false
local LVLUPSTAMINA = 10
local ShakeLVL = 0

local Coords = {}
local CountCoords = 0



function SendCoordsToServer()
	triggerServerEvent("SendCoords", localPlayer, toJSON(Coords))
	Coords = {}
	CountCoords = 0
	return true
end



function checkKey()
	if(getPedControlState(localPlayer, "sprint")) and Stamina ~= 0 then
		Stamina = Stamina-0.1
		if(getPedStat(localPlayer, 22) ~= 1000) then
			LVLUPSTAMINA = LVLUPSTAMINA-0.1
			if(LVLUPSTAMINA == 0) then
				triggerServerEvent("StaminaOut", localPlayer, true)
				LVLUPSTAMINA = 10
			end
		end
	end
	if(Stamina <= 0) then
		triggerServerEvent("StaminaOut", localPlayer)
		setPedControlState(localPlayer, "sprint", false)
	end
	
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



function PlayerVehicleExit(theVehicle, seat)
	if(source == localPlayer) then 
		if(seat == 0) then
			SendCoordsToServer()
		end
	end
end
addEventHandler("onClientPlayerVehicleExit", getRootElement(), PlayerVehicleExit)






function math.round(number, decimals, method)
    decimals = decimals or 0
    local factor = 10 ^ decimals
    if (method == "ceil" or method == "floor") then return math[method](number * factor) / factor
    else return tonumber(("%."..decimals.."f"):format(number)) end
end


function PlayerSpawn()
	if(not Stamina) then
		setTimer(checkKey,100,0)
		setTimer(updateStamina,250,0)
		addEventHandler("onClientRender", root, DrawStaminaBar)
	end
	Stamina = getMaxStamina()
end
addEventHandler("onClientPlayerSpawn", getLocalPlayer(), PlayerSpawn)

function Start()
	if(not isPedDead(localPlayer)) then
		PlayerSpawn()
	end
end
addEventHandler("onClientResourceStart", getResourceRootElement(), Start)



function DrawStaminaBar()
	local cx,cy,cz = getCameraMatrix()
	for _, thePlayer in pairs(getElementsByType("player", getRootElement(), true)) do
		local x,y,z = getPedBonePosition(thePlayer, 8)
		local sx,sy = getScreenFromWorldPosition(x,y,z+0.3)
		if(sx and sy) then
			local depth = getDistanceBetweenPoints3D(x,y,z,cx,cy,cz)/7
			
			dxDrawImage(sx-((NickNameBarW/depth)/2),sy-((NickNameBarH/depth)/2), NickNameBarW/depth, NickNameBarH/depth, DrawNicknameBar(thePlayer))
		end
	end
end






local PlayersAction = {}
local timersAction = {}
function PlayerActionEvent(message,thePlayer)
	PlayersAction[thePlayer] = message
	if(isTimer(timersAction[thePlayer])) then
		killTimer(timersAction[thePlayer])
	end
	timersAction[thePlayer] = setTimer(function()
		PlayersAction[thePlayer] = nil
	end, 300+(#message*150), 1)
end
addEvent("PlayerActionEvent", true)
addEventHandler("PlayerActionEvent", localPlayer, PlayerActionEvent)




function DrawNicknameBar(thePlayer)
	if(not NickNameBar[thePlayer]) then
		NickNameBar[thePlayer] = dxCreateRenderTarget(NickNameBarW, NickNameBarH, true)
	end
	dxSetRenderTarget(NickNameBar[thePlayer], true)
	dxSetBlendMode("modulate_add")
	
	if(PlayersAction[thePlayer]) then			
		dxDrawText(PlayersAction[thePlayer], NickNameBarW,0, 2,2, tocolor(0,0,0,255), 1, 1, "default-bold", "center", "top", false, false, false, true, not getElementData(localPlayer, "LowPCMode"))
		dxDrawText(PlayersAction[thePlayer], NickNameBarW,0, 0,0, tocolor(255,255,255,255), 1, 1, "default-bold", "center", "top", false, false, false, true, not getElementData(localPlayer, "LowPCMode"))
	end
	
	dxDrawText(getPlayerName(thePlayer).."("..getElementData(thePlayer, "id")..")", NickNameBarW,NickNameBarH/2.4, 2,2, tocolor(0,0,0,255), 1, 1, "default-bold", "center", "top", false, false, false, true, not getElementData(localPlayer, "LowPCMode"))
	dxDrawText(getPlayerName(thePlayer).."("..getElementData(thePlayer, "id")..")", NickNameBarW,NickNameBarH/2.4, 0,0, tocolor(255,255,255,255), 1, 1, "default-bold", "center", "top", false, false, false, true, not getElementData(localPlayer, "LowPCMode"))
	if(thePlayer == localPlayer) then
		dxDrawRectangle((NickNameBarW/2)-(StaminaBarW/2),NickNameBarH-3, StaminaBarW, StaminaBarH, tocolor(50,50,50, 50), false, true)
		dxDrawRectangle((NickNameBarW/2),NickNameBarH-3, ((Stamina/getMaxStamina())*getMaxStamina()*(StaminaBarW/10)), StaminaBarH, tocolor(150,127,200, 150), false, not getElementData(localPlayer, "LowPCMode"))
		dxDrawRectangle((NickNameBarW/2),NickNameBarH-3, -((Stamina/getMaxStamina())*getMaxStamina()*(StaminaBarW/10)), StaminaBarH, tocolor(150,127,200, 150), false, not getElementData(localPlayer, "LowPCMode"))
	end
	
	dxSetBlendMode("blend")
	dxSetRenderTarget()
	return NickNameBar[thePlayer]
end


function updateStamina()
	if Stamina ~= getMaxStamina() and getPedControlState(localPlayer, "sprint") == false then
		Stamina = Stamina+0.1
	end
	
	if(ShakeLVL > 0) then
		ShakeLVL = ShakeLVL-1
		setCameraShakeLevel(ShakeLVL)
	end	
end



function ShakeLevel(level)
	ShakeLVL = ShakeLVL+level
end
addEvent("ShakeLevel", true)
addEventHandler("ShakeLevel", localPlayer, ShakeLevel)
