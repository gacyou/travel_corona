-----------------------------------------------------------------------------------------
--
-- PC_point.lua
--
-----------------------------------------------------------------------------------------

local composer = require( "composer" )
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

local isLogin
if (composer.getVariable("isLogin")) then 
	isLogin = composer.getVariable("isLogin")
else
	isLogin = false
end

local ceil = math.ceil
local floor = math.floor

function scene:create( event )
	local sceneGroup = self.view
	tabBar.myTabBarHidden()
	local hasPoint
	local setPoint = event.params.point
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
			onRelease = function()
				tabBar.myTabBarShown()
				composer.hideOverlay( "slideLeft", 400 )
				return true
			end,
		})
		sceneGroup:insert( backArrowNum, backBtn)
	-- 顯示文字-"我的積分"
		local titleText = display.newText({
			text = "我的積分",
			font = getFont.font,
			fontSize = 14,
		})
		sceneGroup:insert(titleText)
		titleText:setFillColor(unpack(wordColor))
		titleText.anchorX = 0
		titleText.x = backArrow.x+backArrow.contentWidth+ceil(30*wRate)
		titleText.y = titleBase.y
	------------------ 顯示積分元件 -------------------
		if ( isLogin == false ) then 
			-- 未登入 --
			-- 圖示-gift-o.png
				local noPointPic = display.newImageRect("assets/gift-o.png",240,210)
				sceneGroup:insert(noPointPic)
				noPointPic.alpha = 0.2
				noPointPic.anchorY = 1
				noPointPic.x = cx
				noPointPic.y = cy
				noPointPic.width = noPointPic.width*0.4
				noPointPic.height = noPointPic.height*0.4
			-- 顯示文字
				local noPointText = display.newText({
					text = "您目前沒有獲得積分唷~預訂行程獲取積分 ! ",
					font = getFont.font,
					fontSize = 12,
				})
				sceneGroup:insert(noPointText)
				noPointText:setFillColor(unpack(wordColor))
				noPointText.anchorX = 0
				noPointText.anchorY = 0
				noPointText.x = 25
				noPointText.y = cy+floor(45*hRate)	
			-- 顯示文字-"去逛逛"
				local hintText = display.newText({
					parent = sceneGroup,
					text = "去逛逛",
					font = getFont.font,
					fontSize = 12,
					x = noPointText.x+noPointText.contentWidth,
					y = noPointText.y,
				})
				hintText:setFillColor(unpack(mainColor1))
				hintText.anchorX = 0
				hintText.anchorY = 0
				--[[
				local goShoppingBtn = widget.newButton({
					id = "goShoppingBtn",
					label = "去逛逛",
					labelColor = { default = mainColor1, over = mainColor2},
					font = getFont.font,
					fontSize = 12,
					width = screenW/16,
					height = noPointText.contentHeight,
					defaultFile = "assets/transparent.png",
					onPress = onBtnListener,
				})
				sceneGroup:insert(goShoppingBtn)
				goShoppingBtn.anchorX = 0
				goShoppingBtn.anchorY = 0
				goShoppingBtn.x = noPointText.x+noPointText.width
				goShoppingBtn.y = noPointText.y
				]]--
		else
			-- 已登入 --
			-- 顯示文字-"可用積分"
				local usefulPointText = display.newText({
					text = "可用積分",
					x = backBtn.x,
					y = titleBaseShadow.y+titleBase.contentHeight*0.5+ceil(80*hRate),
					font = getFont.font,
					fontSize = 10,
				})
				sceneGroup:insert(usefulPointText)
				usefulPointText:setFillColor(unpack(wordColor))
				usefulPointText.anchorX = 0
				usefulPointText.anchorY = 0
			-- 白底
				local pointBase = display.newRect(cx, 0, screenW+ox+ox, ceil(230*hRate))
				sceneGroup:insert(pointBase)
				pointBase.y = usefulPointText.y+usefulPointText.contentHeight+ceil(20*hRate)+pointBase.contentHeight*0.5
			-- 圖示-gift-b.png
				local pointPic = display.newImageRect("assets/gift-b.png", 240, 210)
				pointPic.anchorX = 0
				pointPic.width = pointPic.width*0.15
				pointPic.height = pointPic.height*0.15
				pointPic.x = backBtn.x
				pointPic.y = pointBase.y
				sceneGroup:insert(pointPic)
			-- 顯示文字-顯示積分
				local  pointText = display.newText({
					text = setPoint,
					font = getFont.font,
					fontSize = 14,
				})
				sceneGroup:insert(pointText)
				pointText:setFillColor(unpack(subColor2))
				pointText.anchorX = 0
				pointText.anchorY = 1
				pointText.x = pointPic.x+pointPic.contentWidth+ceil(50*wRate)
				pointText.y = pointBase.y-pointBase.contentHeight*0.5+ceil(65*hRate)+pointText.contentHeight
			-- 顯示文字-"積分 = "	
				local showPointText = display.newText({
					text = " 積分 = ",
					font = getFont.font,
					fontSize = 12,
				})
				sceneGroup:insert(showPointText)
				showPointText:setFillColor(unpack(wordColor))
				showPointText.anchorX = 0
				showPointText.anchorY = 1
				showPointText.x = pointText.x+pointText.contentWidth
				showPointText.y = pointText.y
			-- 顯示文字-積分對應的價值	
				local  getPToMoney = display.newText({
					text = setPoint,
					font = getFont.font,
					fontSize = 14,
				})
				sceneGroup:insert(getPToMoney)
				getPToMoney:setFillColor(unpack(subColor2))
				getPToMoney.anchorX = 0
				getPToMoney.anchorY = 1
				getPToMoney.x = showPointText.x+showPointText.contentWidth
				getPToMoney.y = pointText.y
			-- 顯示文字-"台幣"	
				local  showCurrency = display.newText({
					text = " 台幣",
					font = getFont.font,
					fontSize = 12,
				})
				sceneGroup:insert(showCurrency)
				showCurrency:setFillColor(unpack(wordColor))
				showCurrency.anchorX = 0
				showCurrency.anchorY = 1
				showCurrency.x = getPToMoney.x+getPToMoney.contentWidth
				showCurrency.y = pointText.y
			-- 顯示文字-提醒文字
				local statementText = display.newText({
					text = "(你可以在付款的時候使用積分。)",
					font = getFont.font,
					fontSize = 12,
				})
				sceneGroup:insert(statementText)
				statementText:setFillColor(unpack(wordColor))
				statementText.anchorX = 0
				statementText.anchorY = 0
				statementText.x = pointText.x
				statementText.y = showPointText.y+ceil(25*hRate)
			-- 白底淺灰線
				local pointBaseTopLine = display.newLine(-ox, pointBase.y-pointBase.contentHeight*0.5, screenW+ox, pointBase.y-pointBase.contentHeight*0.5)
				sceneGroup:insert(pointBaseTopLine)
				pointBaseTopLine:setStrokeColor(unpack(separateLineColor))
				pointBaseTopLine.strokeWidth = 1
				local pointBaseBottomLine = display.newLine(-ox, pointBase.y+pointBase.contentHeight*0.5, screenW+ox, pointBase.y+pointBase.contentHeight*0.5)
				sceneGroup:insert(pointBaseBottomLine)
				pointBaseBottomLine:setStrokeColor(unpack(separateLineColor))
				pointBaseBottomLine.strokeWidth = 1
			-- 積分紀錄
			-- 顯示文字-積分紀錄
				local pointRecordText = display.newText({
					text = "積分記錄",
					font = getFont.font,
					fontSize = 10,
				})
				sceneGroup:insert(pointRecordText)
				pointRecordText:setFillColor( unpack(wordColor))
				pointRecordText.anchorX = 0
				pointRecordText.anchorY = 0
				pointRecordText.x = backBtn.x
				pointRecordText.y = pointBaseBottomLine.y+ceil(80*hRate)
			-- 積分記錄的ScrollView
				local pointRecordScrollView = widget.newScrollView({
					id = "pointRecordScrollView",
					top = pointRecordText.y+pointRecordText.contentHeight+ceil(20*hRate),
					left = -ox,
					width = screenW+ox+ox,
					height = screenH+oy-(pointRecordText.y+pointRecordText.contentHeight+ceil(20*hRate)),
					horizontalScrollDisabled = true,
					backgroundColor = backgroundColor,
					--isBounceEnabled = false,
				})
				sceneGroup:insert(pointRecordScrollView)		
				local pointRecordGroup = display.newGroup()
				pointRecordScrollView:insert(pointRecordGroup)
				for i=1 ,5 do
				-- 白底	
					local recordBase = display.newRect(0,0,screenW*0.95+ox+ox, ceil(182*hRate)*2)
					pointRecordGroup:insert(recordBase)
					recordBase.x = pointRecordScrollView.contentWidth*0.5
					recordBase.y = recordBase.contentHeight*0.5+(10+recordBase.contentHeight)*(i-1)
				-- 圖示-deco-y.png
					local recordTag = display.newImageRect("assets/deco-y.png",45,364)
					pointRecordGroup:insert(recordTag)
					recordTag.width = recordTag.width*0.3
					recordTag.height = recordBase.contentHeight
					recordTag.anchorX = 0
					recordTag.x = recordBase.x-recordBase.contentWidth*0.5
					recordTag.y = recordTag.contentHeight*0.5+(10+recordTag.contentHeight)*(i-1)
				-- 顯示文字-"獲得積分"
					local getPointText = display.newText({
						text = "獲得積分",
						font = getFont.font,
						fontSize = 14,
					})
					pointRecordGroup:insert(getPointText)
					getPointText:setFillColor(unpack(wordColor))
					getPointText.anchorX = 1
					getPointText.anchorY = 0
					getPointText.x = recordBase.x+recordBase.contentWidth*0.5-ceil(35*wRate)
					getPointText.y = ceil(40*hRate)+(10+recordBase.contentHeight)*(i-1)
				-- 顯示文字-獲得的積分
					local getPoint = display.newText({
						text = "0",
						font = getFont.font,
						fontSize = 14,
						align = "center",
					})
					pointRecordGroup:insert(getPoint)
					getPoint:setFillColor(unpack(subColor2))
					getPoint.x = getPointText.x-getPointText.contentWidth*0.5
					getPoint.y = getPointText.y+getPointText.contentHeight+ceil(40*hRate)
				-- 垂直線
					local recordVerticalLine = display.newLine( getPointText.x-getPointText.contentWidth-ceil(35*wRate), (recordBase.y-recordBase.contentHeight*0.45), 
						getPointText.x-getPointText.contentWidth-ceil(35*wRate), (recordBase.y+recordBase.contentHeight*0.45))
					pointRecordGroup:insert(recordVerticalLine)
					recordVerticalLine:setStrokeColor(unpack(separateLineColor))
					recordVerticalLine.strokeWidth = 1
				-- 水平線
					local recordHorizontalLine = display.newLine( recordVerticalLine.x, recordBase.y, recordBase.x+recordBase.contentWidth*0.5, recordBase.y)
					pointRecordGroup:insert(recordHorizontalLine)
					recordHorizontalLine:setStrokeColor(unpack(separateLineColor))
					recordHorizontalLine.strokeWidth = 1
				-- 顯示文字-"使用積分"
					local usedPointText = display.newText({
						text = "使用積分",
						font = getFont.font,
						fontSize = 14,
					})
					pointRecordGroup:insert(usedPointText)
					usedPointText:setFillColor(unpack(wordColor))
					usedPointText.anchorX = 1
					usedPointText.anchorY = 0
					usedPointText.x = getPointText.x
					usedPointText.y = recordHorizontalLine.y+ceil(40*hRate)
				-- 顯示文字-使用的積分
					local usedPoint = display.newText({
						text = "0",
						font = getFont.font,
						fontSize = 14,
						align = "center",
					})
					pointRecordGroup:insert(usedPoint)
					usedPoint:setFillColor(unpack(mainColor2))
					usedPoint.x = getPoint.x
					usedPoint.y = usedPointText.y+usedPointText.contentHeight+ceil(40*hRate)
				-- 顯示文字-產品抬頭
					local recordTitleText = display.newText({
						text = "柬埔寨5日遊",
						font = getFont.font,
						fontSize = 14,
					})
					pointRecordGroup:insert(recordTitleText)
					recordTitleText:setFillColor(unpack(wordColor))
					recordTitleText.anchorX = 0
					recordTitleText.anchorY = 0
					recordTitleText.x = recordTag.x+recordTag.contentWidth+ceil(40*wRate)
					recordTitleText.y = ceil(40*hRate)+(10+recordBase.contentHeight)*(i-1)
				-- 顯示文字-訂單編號
					local recordOrderNumText = display.newText({
						text = "訂單編號：0000000000",
						font = getFont.font,
						fontSize = 10,
					})
					pointRecordGroup:insert(recordOrderNumText)
					recordOrderNumText:setFillColor(unpack(wordColor))
					recordOrderNumText.anchorX = 0
					recordOrderNumText.anchorY = 0
					recordOrderNumText.x = recordTitleText.x
					recordOrderNumText.y = recordTitleText.y+recordTitleText.contentHeight+ceil(40*hRate)
				
					local recordOrderDateText = display.newText({
						text = "2017年12月31日 AM 00:00",
						font = getFont.font,
						fontSize = 10,
					})
					pointRecordGroup:insert(recordOrderDateText)
					recordOrderDateText:setFillColor(unpack(wordColor))
					recordOrderDateText.anchorX = 0
					recordOrderDateText.anchorY = 0
					recordOrderDateText.x = recordOrderNumText.x
					recordOrderDateText.y = recordOrderNumText.y+recordOrderNumText.contentHeight+ceil(40*hRate)
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
		composer.removeScene("PC_point")
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