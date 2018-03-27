-----------------------------------------------------------------------------------------
--
-- appointmentInfo.lua
-- 
-----------------------------------------------------------------------------------------

local composer = require( "composer" )
local widget = require("widget")
local getFont = require("setFont")
local scene = composer.newScene()

local wordColor = { 99/255, 99/255, 99/255 }
local backgroundColor = { 245/255, 245/255, 245/255 }
local mainColor1 = { 6/255, 184/255, 217/255 }
local mainColor2 = { 7/255, 162/255, 192/255 }
local subColor1 = { 246/255, 148/255, 106/255}
local subColor2 = { 250/255, 128/255, 79/255}
local separateLineColor = { 204/255, 204/255, 204/255 }

local ox, oy = math.abs(display.screenOriginX), math.abs(display.screenOriginY)
local cx, cy = display.contentCenterX, display.contentCenterY
local screenW, screenH = display.contentWidth, display.contentHeight
local wRate = screenW/1080
local hRate = screenH/1920

local prevScene = composer.getSceneName("previous")
local mainTabBarHeight = composer.getVariable("mainTabBarHeight")
local trfInfomation = { "日期", "起點", "迄點", "車種", "發車時間", "抵達時間", "司機", "車次" }
local trstInfomation = { "旅客姓名", "英文姓名", "備註" }
-- function Zone Start
local function ceil( value )
	return math.ceil(value)
end

-- 按鈕的監聽事件
local function onBtnListener( event )
	local targetId = event.target.id
	if( targetId == "backBtn") then 
		composer.hideOverlay("slideLeft",300)
	end
end


-- function Zone End
function scene:create( event )
	local sceneGroup = self.view
	-- Called when the scene's view does not exist.
	local background = display.newRect(cx,cy+oy,screenW+ox+ox,screenH+oy+oy)
	sceneGroup:insert(background)
	background:setFillColor(unpack(backgroundColor))
	local titleBackground = display.newRect(0, 0, screenW+ox+ox, ceil(178*hRate))
	sceneGroup:insert(titleBackground)
	titleBackground:setFillColor(1)
	titleBackground.x = cx
	titleBackground.y = -oy+ceil((titleBackground.height)/2)
	local titleBackgroundShadow = display.newImageRect("assets/shadow.png", 1068, 476)
	sceneGroup:insert(titleBackgroundShadow)
	titleBackgroundShadow.width = ceil(titleBackgroundShadow.width*0.33)+ox+ox
	titleBackgroundShadow.height = ceil(titleBackground.height*1.05)
	titleBackgroundShadow.x = titleBackground.x
	titleBackgroundShadow.y = titleBackground.y
	
	local titleText = display.newText({
		text = "查看預定資料",
		y = -oy+ceil(cy*0.1),
		font = getFont.font,
		fontSize = 14,
	})
	sceneGroup:insert(titleText)
	titleText:setFillColor(unpack(wordColor))
	titleText.anchorX = 0
	titleText.x = -ox+ceil(cx*0.25)

	local backBtn = widget.newButton({
		id = "backBtn",
		x = -ox+ceil(cx*0.14),
		y = -oy+ceil(cy*0.1),
		width = 162,
		height = 252,
		defaultFile = "assets/btn-back-b.png",
		overFile = "assets/btn-back-b.png",
		onPress = onBtnListener,
	})
	sceneGroup:insert(backBtn)
	backBtn.width = ceil(backBtn.width*0.07)
	backBtn.height = ceil(backBtn.height*0.07)

	local trafficInfoText = display.newText({
			text = "交通資訊",
			font = getFont.font,
			fontSize = 12,
		})
	sceneGroup:insert(trafficInfoText)
	trafficInfoText:setFillColor(unpack(wordColor))
	trafficInfoText.anchorX = 0
	trafficInfoText.x = -ox+ceil(50*wRate)
	trafficInfoText.y = titleBackground.y+ceil(titleBackground.height/2)+ceil(60*hRate)+ceil(trafficInfoText.height/2)

	local baseHeight
	if ( system.getInfo("model") == "iPad") then 
		baseHeight = ceil(80*hRate)
	else
		baseHeight = ceil(120*hRate)
	end

	local trafficInfoBase = display.newRect(0,0,screenW+ox+ox, 8*baseHeight+ceil(baseHeight/2))
	sceneGroup:insert(trafficInfoBase)
	trafficInfoBase.x = cx
	trafficInfoBase.y = trafficInfoText.y+ceil(trafficInfoText.height/2)+ceil(20*hRate)+ceil(trafficInfoBase.height/2)

	local trafficInfoBaseShadow = display.newImageRect("assets/shadow.png",1068,476)
	sceneGroup:insert(trafficInfoBaseShadow)
	trafficInfoBaseShadow.width = ceil(trafficInfoBaseShadow.contentWidth*0.33)+ox+ox
	trafficInfoBaseShadow.height = ceil(trafficInfoBase.contentHeight*1.05)
	trafficInfoBaseShadow.x = trafficInfoBase.x
	trafficInfoBaseShadow.y = trafficInfoBase.y

	local pad
	for i=1,8 do
		if ( i==1 ) then 
			pad = 0
		else
			pad = baseHeight*(i-1)
		end

		local infoText = display.newText({
				text = trfInfomation[i],
				font = getFont.font,
				fontSize = 12,
			})
		sceneGroup:insert(infoText)
		infoText:setFillColor(unpack(wordColor))
		infoText.anchorX = 0
		infoText.x = -ox+ceil(50*wRate)
		infoText.y = trafficInfoText.y+ceil(trafficInfoText.height/2)+ceil(20*hRate)+ceil(baseHeight*0.6)+pad

		local trafficInfoBaseLine = display.newLine( -ox+ceil(50*wRate), trafficInfoText.y+ceil(trafficInfoText.height/2)+ceil(20*hRate)+baseHeight+pad,
														screenW+ox-ceil(50*wRate), trafficInfoText.y+ceil(trafficInfoText.height/2)+ceil(20*hRate)+baseHeight+pad)
		sceneGroup:insert(trafficInfoBaseLine)
		trafficInfoBaseLine:setStrokeColor(unpack(separateLineColor))
	end



	local touristInfoText = display.newText({
			text = "旅客資訊",
			font = getFont.font,
			fontSize = 12,
		})
	sceneGroup:insert(touristInfoText)
	touristInfoText:setFillColor(unpack(wordColor))
	touristInfoText.anchorX = 0
	touristInfoText.x = -ox+ceil(50*wRate)
	touristInfoText.y = trafficInfoBase.y+ceil(trafficInfoBase.height/2)+ceil(60*hRate)+ceil(touristInfoText.height/2)

	local touristInfoBase = display.newRect(0,0,screenW+ox+ox, 3*baseHeight+ceil(baseHeight/2))
	sceneGroup:insert(touristInfoBase)
	touristInfoBase.x = cx
	touristInfoBase.y = touristInfoText.y+ceil(touristInfoText.height/2)+ceil(20*hRate)+ceil(touristInfoBase.height/2)

	local touristInfoBaseShadow = display.newImageRect("assets/shadow.png",1068,476)
	sceneGroup:insert(touristInfoBaseShadow)
	touristInfoBaseShadow.width = ceil(touristInfoBaseShadow.contentWidth*0.33)+ox+ox
	touristInfoBaseShadow.height = ceil(touristInfoBase.contentHeight*1.05)
	touristInfoBaseShadow.x = touristInfoBase.x
	touristInfoBaseShadow.y = touristInfoBase.y

	for i=1,3 do
		if ( i==1 ) then 
			pad = 0
		else
			pad = baseHeight*(i-1)
		end

		local infoText = display.newText({
				text = trstInfomation[i],
				font = getFont.font,
				fontSize = 12,
			})
		sceneGroup:insert(infoText)
		infoText:setFillColor(unpack(wordColor))
		infoText.anchorX = 0
		infoText.x = -ox+ceil(50*wRate)
		infoText.y = touristInfoText.y+ceil(touristInfoText.height/2)+ceil(20*hRate)+ceil(baseHeight*0.6)+pad

		local touristInfoBaseLine = display.newLine( -ox+ceil(50*wRate), touristInfoText.y+ceil(touristInfoText.height/2)+ceil(20*hRate)+baseHeight+pad,
														screenW+ox-ceil(50*wRate), touristInfoText.y+ceil(touristInfoText.height/2)+ceil(20*hRate)+baseHeight+pad)
		sceneGroup:insert(touristInfoBaseLine)
		touristInfoBaseLine:setStrokeColor(unpack(separateLineColor))
	end

end

function scene:show( event )
	local sceneGroup = self.view
	local phase = event.phase
	if phase == "will" then
		-- Called when the scene is still off screen and is about to move on screen
	elseif phase == "did" then
		-- Called when the scene is now on screen
		if(fromMain == true ) then
			composer.removeScene("destination")
			composer.removeScene("view2")
			composer.removeScene("personalcenter")
		end
	end	
end

function scene:hide( event )
	local sceneGroup = self.view
	local phase = event.phase
	if event.phase == "will" then
		-- Called when the scene is on screen and is about to move off screen
		--
		-- INSERT code here to pause the scene
		-- e.g. stop timers, stop animation, unload sounds, etc.)
	elseif phase == "did" then
		-- Called when the scene is now off screen
	end
end

function scene:destroy( event )
	local sceneGroup = self.view
	-- Called prior to the removal of scene's "view" (sceneGroup)
	-- 
	-- INSERT code here to cleanup the scene
	-- e.g. remove display objects, remove touch listeners, save state, etc.
end

---------------------------------------------------------------------------------

-- Listener setup
scene:addEventListener( "create", scene )
scene:addEventListener( "show", scene )
scene:addEventListener( "hide", scene )
scene:addEventListener( "destroy", scene )

-----------------------------------------------------------------------------------------

return scene