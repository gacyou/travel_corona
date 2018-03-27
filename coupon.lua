-----------------------------------------------------------------------------------------
--
-- coupon.lua
--
-----------------------------------------------------------------------------------------

local composer = require("composer")
local widget = require("widget")
local getFont = require("setFont")
local tabBar = require("mainTabBar")
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

local function ceil( value )
	return math.ceil(value)
end

local function floor( value )
	return math.floor(value)
end

-- 按鈕的監聽事件
local function onBtnListener( event )
	local targetId = event.target.id
	if( targetId == "backBtn") then
		tabBar.myTabBarShown()
		composer.hideOverlay("slideLeft",400)
	end
end

function scene:create( event )
	local sceneGroup = self.view
	tabBar.myTabBarHidden()
------------------ 背景元件 -------------------
	local background = display.newRect( cx, cy, screenW+ox+ox, screenH+oy+oy)
	sceneGroup:insert(background)
	background:setFillColor(unpack(backgroundColor))
------------------ 抬頭元件 -------------------
-- 陰影
	local titleBaseShadow = display.newImageRect("assets/shadow0205.png", 320, 60)
	sceneGroup:insert(titleBaseShadow)
	titleBaseShadow.width = screenW+ox+ox
	titleBaseShadow.height = floor(178*hRate)
	titleBaseShadow.x = cx
	titleBaseShadow.y = -oy+titleBaseShadow.height*0.5
-- 白底
	local titleBase = display.newRect( cx, 0, screenW+ox+ox, titleBaseShadow.contentHeight*0.9)
	sceneGroup:insert(titleBase)
	titleBase.y = -oy+titleBase.contentHeight*0.5
-- 返回按鈕	
	local backBtn = widget.newButton({
		id = "backBtn",
		x = -ox+ceil(49*wRate),
		y = titleBase.y,
		width = 162,
		height = 252,
		defaultFile = "assets/btn-back-b.png",
		overFile = "assets/btn-back-b.png",
		onRelease = onBtnListener,
	})
	sceneGroup:insert(backBtn)
	backBtn.anchorX = 0
	backBtn.width = backBtn.width*0.07
	backBtn.height = backBtn.height*0.07
-- 顯示文字-"優惠碼"
	local titleText = display.newText({
		text = "優惠碼",
		font = getFont.font,
		fontSize = 14,
	})
	sceneGroup:insert(titleText)
	titleText:setFillColor(unpack(wordColor))
	titleText.anchorX = 0
	titleText.x = backBtn.x+backBtn.contentWidth+ceil(30*wRate)
	titleText.y = titleBase.y
------------------ 輸入優惠碼元件 -------------------
-- 輸入區	
	local couponTextField = native.newTextField( backBtn.x, titleBaseShadow.y+titleBaseShadow.contentHeight*0.5+ceil(70*hRate), (screenW+ox+ox)*0.4, ceil(70*hRate))
	couponTextField.anchorX = 0
	couponTextField.anchorY = 0
	couponTextField.inputType = "default"
	couponTextField.font = getFont.font
	couponTextField.placeholder = "請輸入優惠碼"
	couponTextField.size = 12
	couponTextField:setSelection(0,0)
	sceneGroup:insert(couponTextField)
-- 兌換按鈕
	local exchangeBtn = widget.newButton({
		id = "exchangeBtn",
		label = "兌換",
		labelColor = { default = { 1, 1, 1, 1}, over = { 1, 1, 1, 0.7}},
		font = getFont.font,
		fontSize = 12,
		shape = "Rect",
		width = ceil(131*wRate),
		height = couponTextField.contentHeight,
		fillColor = { default = mainColor1, over = mainColor2 },
		emboss = true,
		onPress = onBtnListener,
	})
	sceneGroup:insert(exchangeBtn)
	exchangeBtn.anchorX = 0
	exchangeBtn.anchorY = 0
	exchangeBtn.x = couponTextField.x+couponTextField.contentWidth
	exchangeBtn.y = couponTextField.y
end

function scene:show( event )
	local sceneGroup = self.view
	local phase = event.phase
	if phase == "will" then
		-- Called when the scene is still off screen and is about to move on screen
	elseif phase == "did" then
		-- Called when the scene is now on screen
		--composer.removeScene("destination")
		--composer.removeScene("view2")	
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