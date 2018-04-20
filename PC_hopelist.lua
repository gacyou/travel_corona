-----------------------------------------------------------------------------------------
--
-- PC_hopelist.lua
--
-----------------------------------------------------------------------------------------

local composer = require( "composer" )
local widget = require("widget")
local getFont = require("setFont")
local mainTabBar = require("mainTabBar")
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
local wRate = screenW/1080
local hRate = screenH/1920

local picSet = {"assets/Angkor.png" ,"assets/temple.jpg", "assets/night.jpg"}

local ceil = math.ceil
local floor = math.floor

local isLogin
if (composer.getVariable("isLogin")) then 
	isLogin = composer.getVariable("isLogin")
else
	isLogin = false
end

function scene:create( event )
	local sceneGroup = self.view
	mainTabBar.myTabBarHidden()
	-- 白底
		local titleBase = display.newRect( sceneGroup, cx, -oy, screenW+ox+ox, floor(178*hRate))
		titleBase.y = titleBase.y+titleBase.contentHeight*0.5
	-- 返回按鈕圖片
		local backArrow = display.newImage( sceneGroup, "assets/btn-back-b.png",-ox+ceil(49*wRate), -oy+titleBase.contentHeight*0.5)
		backArrow.width = (backArrow.width*0.07)
		backArrow.height = (backArrow.height*0.07)
		backArrow.anchorX = 0
		local backArrowNum = sceneGroup.numChildren
	-- 返回按鈕
		local backBtn = widget.newButton({
			id = "backBtn",
			x = backArrow.x+backArrow.contentWidth*0.5,
			y = backArrow.y,
			shape = "rect",
			width = screenW*0.1,
			height = titleBase.contentHeight,
			onRelease = function(event)
				composer.gotoScene( "PC_personalCenter", { effect = "fade", time = 300 } )
			end,
		})
		sceneGroup:insert(backArrowNum,backBtn)
	-- 顯示文字-"願望清單"
		local titleText = display.newText({
			text = "願望清單",
			font = getFont.font,
			fontSize = 14,
			x = backArrow.x+backArrow.contentWidth+ceil(30*wRate),
			y = backArrow.y,
		})
		sceneGroup:insert(titleText)
		titleText:setFillColor(unpack(wordColor))
		titleText.anchorX = 0
	-- 陰影
		local titleBaseShadow = display.newImage( sceneGroup, "assets/s-down.png", titleBase.x, titleBase.y+titleBase.contentHeight*0.5)
		titleBaseShadow.anchorY = 0
		titleBaseShadow.width = screenW+ox+ox
		titleBaseShadow.height = titleBaseShadow.height*0.5
	if ( isLogin == false ) then 
		local funroadBird = display.newImage( sceneGroup, "assets/img-bird.png" , cx, cy)
		funroadBird.anchorY = 1
		funroadBird.width = funroadBird.width*0.35
		funroadBird.height = funroadBird.height*0.35
		local text1 = display.newText({
				parent = sceneGroup,
				text = "尚無清單，",
				font = getFont.font,
				fontSize = 14,
				x = cx,
				y = funroadBird.y+floor(70*hRate),
			})
		text1:setFillColor(unpack(wordColor))
		text1.anchorX = 1
		text1.anchorY = 0
		local text2 = display.newText({
				parent = sceneGroup,
				text = "去逛逛",
				font = getFont.font,
				fontSize = 14,
				x = cx,
				y = text1.y,
			})
		text2:setFillColor(unpack(mainColor1))
		text2.anchorX = 0
		text2.anchorY = 0
		local text3 = display.newText({
				parent = sceneGroup,
				text = "吧!",
				font = getFont.font,
				fontSize = 14,
				x = text2.x+text2.contentWidth,
				y = text2.y,			
			})
		text3:setFillColor(unpack(wordColor))
		text3.anchorX = 0
		text3.anchorY = 0
	else
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
		for i = 1, 9 do
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
	
end

function scene:show( event )
	local sceneGroup = self.view
	local phase = event.phase
	if phase == "will" then
	elseif phase == "did" then
	end	
end

function scene:hide( event )
	local sceneGroup = self.view
	local phase = event.phase
	if event.phase == "will" then
	elseif phase == "did" then
		composer.removeScene("PC_hopelist")
	end
end

function scene:destroy( event )
	local sceneGroup = self.view
end

---------------------------------------------------------------------------------

-- Listener setup
scene:addEventListener( "create", scene )
scene:addEventListener( "show", scene )
scene:addEventListener( "hide", scene )
scene:addEventListener( "destroy", scene )

-----------------------------------------------------------------------------------------

return scene