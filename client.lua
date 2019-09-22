local NickNameBar = {}
local NickNameBarW, NickNameBarH = 200, 40
local StaminaBarW, StaminaBarH = 75, 1

function getMaxStamina()
	return 5+math.floor(getPedStat(localPlayer, 22)/40)
end

local Stamina = false
local LVLUPSTAMINA = 10
local ShakeLVL = 0


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
	for _, thePlayer in pairs(getElementsByType("player", getRootElement(), true)) do
		local x,y,z = getPedBonePosition(thePlayer, 8)
		local cx,cy,cz = getCameraMatrix()
		local depth = getDistanceBetweenPoints3D(x,y,z,cx,cy,cz)/6
		local sx,sy = getScreenFromWorldPosition(x,y,z+0.5)
		if(sx and sy) then
			NickNameBar[thePlayer] = false
			
			dxDrawImage(sx-((NickNameBarW/depth)/2),sy, NickNameBarW/depth, NickNameBarH/depth, DrawNicknameBar(thePlayer))
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
	end, 300+(#message*75), 1)
end
addEvent("PlayerActionEvent", true)
addEventHandler("PlayerActionEvent", localPlayer, PlayerActionEvent)




function DrawNicknameBar(thePlayer)
	if(not NickNameBar[thePlayer]) then
		NickNameBar[thePlayer] = dxCreateRenderTarget(NickNameBarW, NickNameBarH, true)
		dxSetRenderTarget(NickNameBar[thePlayer], true)
		dxSetBlendMode("modulate_add")
		
		if(PlayersAction[thePlayer]) then
			dxDrawText(PlayersAction[thePlayer], NickNameBarW,0, 0,0, tocolor(255,255,255,255), 1, 1, "default-bold", "center", "top")
		end
		dxDrawText(getPlayerName(thePlayer).."("..getElementData(thePlayer, "id")..")", NickNameBarW,NickNameBarH/2.4, 0,0, tocolor(255,255,255,255), 1, 1, "default-bold", "center", "top")
		if(thePlayer == localPlayer) then
			dxDrawRectangle((NickNameBarW/2)-(StaminaBarW/2),NickNameBarH-3, StaminaBarW, StaminaBarH, tocolor(50,50,50, 50), false, true)
			dxDrawRectangle((NickNameBarW/2),NickNameBarH-3, ((Stamina/getMaxStamina())*getMaxStamina()*(StaminaBarW/10)), StaminaBarH, tocolor(150,127,200, 150), false, true)
			dxDrawRectangle((NickNameBarW/2),NickNameBarH-3, -((Stamina/getMaxStamina())*getMaxStamina()*(StaminaBarW/10)), StaminaBarH, tocolor(150,127,200, 150), false, true)
		end
		
		dxSetBlendMode("blend")
		dxSetRenderTarget()
	end
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
