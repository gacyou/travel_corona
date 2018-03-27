-----------------------------------------------------------------------------------------
--
-- hopelist.lua
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
local sW, sH = display.safeActualContentWidth, display.safeActualContentHeight

local prevScene = composer.getSceneName("previous")

local picSet = {"assets/Angkor.png" ,"assets/temple.jpg", "assets/night.jpg"}

-- function zone Start
local function ceil( value )
	return math.ceil(value)
end

-- 按鈕的監聽事件
local function onBtnListener( event )
	local targetId = event.target.id
	if( targetId == "backBtn") then 
		--composer.hideOverlay("slideLeft",400)
		composer.gotoScene(prevScene,{effect="slideLeft",time=400})
	end
end
-- function zone End

function scene:create( event )
	local sceneGroup = self.view
	-- Called when the scene's view does not exist.

	local background = display.newRect(cx,cy+oy,screenW+ox+ox,screenH+oy+oy)
	background:setFillColor(unpack(backgroundColor))
	sceneGroup:insert(background)
	
	local titleBackground_shadow = display.newImageRect("assets/shadow.png",1068,476)
	sceneGroup:insert(titleBackground_shadow)
	titleBackground_shadow.x = cx
	titleBackground_shadow.y = -oy+ceil(cy*0.1)
	titleBackground_shadow.width = screenW*1.1+ox+ox
	titleBackground_shadow.height = screenH/10
	
	local titleBackground = display.newRect(cx, -oy+ceil(cy*0.1), screenW+ox+ox, screenH/11)
	titleBackground:setFillColor(1)
	sceneGroup:insert(titleBackground)
	
	local titleText = display.newText({
		text = "願望清單",
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

	local hopeListView = widget.newScrollView(
	{
		id = "hopeListView",
		top = -oy+ceil(cy*0.1)+(screenH/10)/2,
		left = -ox,
		width = screenW+ox+ox,
		height = screenH+oy+oy-(screenH/10)-(screenH/12),
		horizontalScrollDisabled = true,
	})
	sceneGroup:insert(hopeListView)
	
	local picNum
	local pad
	for i=1,9 do
		if ( i%3 == 0) then 
			picNum = 3
		elseif ( i%3 == 2) then
			picNum = 2
		else
			picNum = 1
		end
		
		if (i==1) then 
			pad = 0
		else
			pad = (10+(screenH/3+40))*(i-1)
		end
		-- 圖文的區塊
		local hopeListBackground = display.newImageRect("assets/shadow.png",1068,476)
		hopeListView:insert(hopeListBackground)
		hopeListBackground.x = cx+ox
		hopeListBackground.y = ceil(cy*0.5)+pad
		hopeListBackground.width = screenW*0.95+ox+ox
		hopeListBackground.height = (screenH/3+55)
		--[[
		local hopeListBackground = display.newRect(0,0,screenW*0.9+ox+ox,(screenH/3+40))
		hopeListView:insert(hopeListBackground)
		hopeListBackground:setFillColor(0.3)
		hopeListBackground.x = cx+ox
		hopeListBackground.y = ceil(cy*0.5)+pad
		]]--
		--print(hopeListBackground:localToContent(0,0))		
		
		-- 圖片
		local hopelistPic = display.newImage(picSet[picNum])
		hopeListView:insert(hopelistPic)
		hopelistPic.x = cx+ox
		hopelistPic.y = ceil(cy*0.37)+pad
		hopelistPic.width = screenW*0.88+ox+ox
		hopelistPic.height = (screenH/3)*0.8
		
		-- 標價
		--[[
		local labelPic = display.newImageRect("assets/tag-price.png",189,97)
		hopeListView:insert(labelPic)
		labelPic.width = labelPic.width*0.3
		labelPic.height = labelPic.height*0.3
		labelPic.x = cx*1.72
		labelPic.y = cy*0.21+pad
		local priceText = display.newText(
		{
			text = "NT$\n10,000",
			font = getFont.font,
			fontSize = 10,
		})
		hopeListView:insert(priceText)
		priceText:setFillColor(1)
		priceText.anchorX = 0
		priceText.x = cx*1.6
		priceText.y = ceil(cy*0.21)+pad
		]]
		-- 文字區塊
		local textBackground = display.newRect(0,0,screenW*0.88+ox+ox,(screenH/3)*0.4)
		hopeListView:insert(textBackground)
		textBackground.x = cx+ox
		textBackground.y = ceil(cy*0.77)+pad
		
		-- 可變文字一
		local infoText1 = display.newText(
		{
			text = "【吳哥窟+金邊】超值景點絕對不能錯過",
			font = getFont.font,
			fontSize = 12,
		})
		hopeListView:insert(infoText1)
		infoText1:setFillColor(unpack(wordColor))
		infoText1.anchorX = 0
		infoText1.x = 20
		infoText1.y = ceil(cy*0.6875)+pad
		
		-- 可變文字二
		local infoText2 = display.newText(
		{
			text = "暢玩柬埔寨超值景點套票，飽覽美不勝收的無敵景致。",
			font = getFont.font,
			fontSize = 10,
		})
		hopeListView:insert(infoText2)
		infoText2:setFillColor(unpack(wordColor))
		infoText2.anchorX = 0
		infoText2.x = 25
		infoText2.y = ceil(cy*0.75)+pad

		local priceText = display.newText(
		{
			text = "NT$ 10,000",
			font = getFont.font,
			fontSize = 12,
		})
		hopeListView:insert(priceText)
		priceText:setFillColor(unpack(wordColor))
		priceText.anchorX = 0
		priceText.x = 20
		priceText.y = ceil(cy*0.85)+pad

		local lovePic = display.newImageRect("assets/heart.png",280,240)
		hopeListView:insert(lovePic)
		lovePic.anchorX = 0
		lovePic.x = 275+ox+ox
		lovePic.y = ceil(cy*0.85)+pad
		lovePic.width = lovePic.width*0.07
		lovePic.height = lovePic.height*0.07
		--[[
		-- 旅遊區域
		local textPic1 = display.newImageRect("assets/map-marker-b.png",160,240)
		hopeListView:insert(textPic1)
		textPic1.anchorX = 0
		textPic1.x = 28
		textPic1.y = ceil(cy*0.82)+pad
		textPic1.width = (textPic1.width)*0.05
		textPic1.height = (textPic1.height)*0.05
		local areaText = display.newText(
		{
			text = "柬埔寨",
			font = getFont.font,
			fontSize = 10,
		})
		hopeListView:insert(areaText)
		areaText:setFillColor(0.5)
		areaText.anchorX = 0
		areaText.x = 40
		areaText.y = ceil(cy*0.82)+pad

		-- 分類
		local textPic2 = display.newImageRect("assets/check-square-b.png",240,240)
		hopeListView:insert(textPic2)
		textPic2.anchorX = 0
		textPic2.x = 25
		textPic2.y = ceil(cy*0.875)+pad
		textPic2.width = textPic2.width*0.05
		textPic2.height = textPic2.height*0.05
		local classText = display.newText(
		{
			text = "主題玩法",
			font = getFont.font,
			fontSize = 10,
		})
		hopeListView:insert(classText)
		classText:setFillColor(unpack(wordColor))
		classText.anchorX = 0
		classText.x = 40
		classText.y = ceil(cy*0.875)+pad

		-- 參加人數
		local textPic3 = display.newImage("assets/fire-b.png")
		hopeListView:insert(textPic3)
		textPic3.anchorX = 0
		textPic3.x = 218
		textPic3.y = ceil(cy*0.875)+pad
		textPic3.width = 221*0.04
		textPic3.height = 280*0.04
		local joinText = display.newText(
		{
			text = "1.5k人參加",
			font = getFont.font,
			fontSize = 10,
		})
		hopeListView:insert(joinText)
		joinText:setFillColor(unpack(wordColor))
		joinText.anchorX = 0
		joinText.x = 230
		joinText.y = ceil(cy*0.875)+pad
		]]--	
	end
	
end

function scene:show( event )
	local sceneGroup = self.view
	local phase = event.phase
	if phase == "will" then
		-- Called when the scene is still off screen and is about to move on screen
	elseif phase == "did" then
		-- Called when the scene is now on screen
		composer.removeScene("destination")
		composer.removeScene("view2")
		composer.removeScene("myorder")
		composer.removeScene("personalcenter")
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