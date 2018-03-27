-----------------------------------------------------------------------------------------
--
-- otherTitle.lua
--
-----------------------------------------------------------------------------------------

local composer = require( "composer" )
local widget = require("widget")
local mainTabBar = require("mainTabBar")
local getFont = require("setFont")
local scene = composer.newScene()

local ox, oy = math.abs(display.screenOriginX), math.abs(display.screenOriginY)
local cx, cy = display.contentCenterX, display.contentCenterY
local screenW, screenH = display.contentWidth, display.contentHeight
local sW, sH = display.safeActualContentWidth, display.safeActualContentHeight
local wRate = screenW/1080
local hRate = screenH/1920

local wordColor = { 99/255, 99/255, 99/255 }
local backgroundColor = { 245/255, 245/255, 245/255 }
local mainColor1 = { 6/255, 184/255, 217/255 }
local mainColor2 = { 7/255, 162/255, 192/255 }
local subColor1 = { 246/255, 148/255, 106/255}
local subColor2 = { 250/255, 128/255, 79/255}
local separateLineColor = { 204/255, 204/255, 204/255 }

local function ceil( value )
	return math.ceil(value)
end

local function floor( value )
	return math.floor(value)
end

-- create()
function scene:create( event )
	local sceneGroup = self.view
	local picName = event.params.titlePicName
	local textContent = event.params.titleTextContent
	local setStatus = {}
------------------- 添加我的旅程抬頭元件 -------------------
-- 白色底圖+陰影 白底範圍=圖形高度的0.9
	local titleBaseShadow = display.newImageRect("assets/shadow0205.png", screenW+ox+ox, floor(200*hRate))
	sceneGroup:insert(titleBaseShadow)
	titleBaseShadow.x = cx
	titleBaseShadow.y = -oy+titleBaseShadow.contentHeight*0.5
-- 返回按鈕圖片
	local backArrow = display.newImage( sceneGroup, "assets/btn-back-b.png",-ox+ceil(49*wRate), -oy+(titleBaseShadow.contentHeight*0.9)*0.5)
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
		height = titleBaseShadow.contentHeight*0.89,
		onRelease = 			
			function ()
				local options = {
					params = {
						titlePicName = picName,
						titleTextContent = textContent,
					}
				}
				composer.gotoScene("recommendTitle",options)
			end,
	})
	sceneGroup:insert(backArrowNum,backBtn)
-- 顯示文字-抬頭文字
	local titleText = display.newText({
		text = event.params.otherTitleTextContent,
		height = 0,
		y = backArrow.y,
		font = getFont.font,
		fontSize = 14,
	})
	sceneGroup:insert(titleText)
	titleText:setFillColor(unpack(wordColor))
	titleText.anchorX = 0
	titleText.x = backArrow.x+backArrow.contentWidth+(40*wRate)
-- 抬頭文字選項箭頭
	local titleArrow = display.newImageRect("assets/btn-dropdown.png", 256, 168)
	sceneGroup:insert(titleArrow)
	titleArrow.width = titleArrow.width*0.05
	titleArrow.height = titleArrow.height*0.05
	titleArrow.x = titleText.x+titleText.contentWidth+ceil(20*wRate)+titleArrow.contentWidth*0.5
	titleArrow.y = backBtn.y
	setStatus["titleArrow"] = "down"
-- 購物車圖片
	local shoppingCart = display.newImage( sceneGroup, "assets/btn-cart-b.png",(screenW+ox)-(45*wRate), backArrow.y)
	shoppingCart.anchorX = 1
	shoppingCart.width = shoppingCart.width*0.07
 	shoppingCart.height = shoppingCart.height*0.07
 	local shoppingCartNum = sceneGroup.numChildren
-- 購物車按鈕
 	local cartBtn = widget.newButton({
 			id = "cartBtn",
			x = shoppingCart.x-shoppingCart.contentWidth*0.5,
			y = shoppingCart.y,
			shape = "rect",
			width = screenW*0.1,
			height = backBtn.contentHeight,
			onRelease = 
				function ()
					composer.gotoScene("shoppingCart")
				end,
 		})
 	sceneGroup:insert(shoppingCartNum,cartBtn)
 -- 排序圖片
	local sort = display.newImage( sceneGroup, "assets/btn-sort.png",shoppingCart.x-shoppingCart.contentWidth-(45*wRate), shoppingCart.y)
	sort.anchorX = 1
	sort.width = sort.width*0.055
 	sort.height = sort.height*0.055
 	local sortNum = sceneGroup.numChildren
-- 排序按鈕
 	local sortBtn = widget.newButton({
 			id = "sortBtn",
 			x = sort.x-sort.contentWidth*0.5,
 			y = sort.y,
 			shape = "rect",
 			width = screenW*0.1,
 			height = backBtn.contentHeight,
 			onRelease = onBtnListener,
 		})
 	sceneGroup:insert(sortNum,sortBtn)
-- 抬頭文字-下拉式選單
-- 選單邊界
	local optionList = { "獨家主題", "一般出團", "當地集散", "自助包車", "藝品餐券", "其他服務", "住宿訂房"}	
	local titleListBoundary = display.newContainer( screenW+ox+ox, screenH*0.5)
	sceneGroup:insert(titleListBoundary)
	titleListBoundary.anchorY = 0
	titleListBoundary.x = cx
	titleListBoundary.y = titleBaseShadow.y+titleBaseShadow.contentHeight*0.5
-- 選項內容
	local titleListGroup = display.newGroup()
	titleListBoundary:insert(titleListGroup)
	local titleListShadow = display.newImageRect("assets/shadow-320480.png", screenW+ox+ox, screenH*0.5)
	titleListGroup:insert(titleListShadow)
	--local titleListBase = display.newRect(titleListGroup, 0, 0, titleListShadow.contentWidth*0.95, titleListShadow.contentHeight*59/60)
	--titleListBase.anchorY = 0
	--titleListBase.y = -titleListShadow.contentHeight*0.5
	local titleListScrollView = widget.newScrollView({
		id = "titleListScrollView",
		width = titleListShadow.contentWidth*0.95,
		height = titleListShadow.contentHeight*59/60,
		isLocked = true,
		backgroundColor = {1},
	})
	titleListGroup:insert(titleListScrollView)
	titleListScrollView.anchorY = 0
	titleListScrollView.x = 0
	--titleListScrollView.y = 0
	titleListScrollView.y = -titleListShadow.contentHeight*0.5
	local titleListScrollViewGroup = display.newGroup()
	titleListScrollView:insert(titleListScrollViewGroup)

	local optionBaseHeight = floor(titleListScrollView.contentHeight/#optionList)
	local optionText = {}
	local optionIcon = {}
	local optionIconOver = {}
	local defaultTarget, nowTarget, prevTarget = {}, {}, {}
	local isCanceled = false
	local function optionSelect( event )
		local phase = event.phase
		if (phase == "began") then
			if (isCanceled == true) then
				isCanceled = false
			end
			if (event.target ~= nowTarget) then
				prevTarget = nowTarget
				optionText[prevTarget.id]:setFillColor(unpack(wordColor))
				optionIcon[prevTarget.id].isVisible = true

				nowTarget = event.target
				nowTarget:setFillColor( 0, 0, 0, 0.1)
				optionText[nowTarget.id]:setFillColor(unpack(subColor2))
				optionIcon[nowTarget.id].isVisible = false
				display.getCurrentStage():setFocus(nowTarget)
			end
		elseif (phase == "moved") then
			local dx = math.abs(event.xStart - event.x)
			local dy = math.abs(event.yStart - event.y)
			if (dy > 10 or dx > 10) then
				titleListScrollView:takeFocus(event)
				nowTarget:setFillColor(1)
				optionText[nowTarget.id]:setFillColor(unpack(wordColor))
				optionIcon[nowTarget.id].isVisible = true
				display.getCurrentStage():setFocus(nil)
				optionText[defaultTarget.id]:setFillColor(unpack(subColor2))
				optionIcon[defaultTarget.id].isVisible = false
				nowTarget = defaultTarget
				isCanceled = true
			end
		elseif (phase == "ended" and isCanceled == false and nowTarget ~= defaultTarget) then
			display.getCurrentStage():setFocus(nil)
			titleArrow:rotate(180)
			setStatus["titleArrow"] = "down"
			transition.to(titleListGroup, { y = -titleListBoundary.contentHeight, time = 200})
			nowTarget:setFillColor(1)
			titleText.text = optionText[nowTarget.id].text
			defaultTarget = nowTarget
		end
	end
	for i = 1, #optionList do
		local optionBase = display.newRect(titleListScrollViewGroup, titleListScrollView.contentWidth*0.5, 0, titleListScrollView.contentWidth, optionBaseHeight)
		--optionBase.y = titleListScrollView.y+optionBaseHeight*0.5+optionBaseHeight*(i-1)
		optionBase.y = optionBaseHeight*0.5+optionBaseHeight*(i-1)
		optionBase.id = i
		optionBase:addEventListener("touch",optionSelect)

		optionIconOver[i] = display.newImage(titleListScrollViewGroup,"assets/theme0"..(i+1).."-.png")
		optionIconOver[i].anchorX = 0
		optionIconOver[i].x = optionBase.contentWidth*0.36
		optionIconOver[i].y = optionBase.y
		optionIconOver[i].width = optionIconOver[i].width*0.2
		optionIconOver[i].height = optionIconOver[i].height*0.2

		optionIcon[i] = display.newImage(titleListScrollViewGroup,"assets/theme0"..(i+1)..".png")
		optionIcon[i].anchorX = 0
		optionIcon[i].x = optionBase.contentWidth*0.36
		optionIcon[i].y = optionBase.y
		optionIcon[i].width = optionIcon[i].width*0.2
		optionIcon[i].height = optionIcon[i].height*0.2

		optionText[i] = display.newText({
			parent = titleListScrollViewGroup,
			x = optionBase.contentWidth-optionBase.contentWidth*0.36,
			y = optionIcon[i].y+optionIcon[i].contentHeight*0.15,
			text = optionList[i],
			font = getFont.font,
			fontSize = 14,
		})
		optionText[i].anchorX = 1
		if (optionText[i].text == titleText.text) then 
			optionIcon[i].isVisible = false
			optionText[i]:setFillColor(unpack(subColor2))
			nowTarget = optionBase
			defaultTarget = optionBase
		else
			optionIcon[i].isVisible = true
			optionText[i]:setFillColor(unpack(wordColor))
		end
	end
	titleListGroup.y = -titleListBoundary.contentHeight
	titleListBoundary.isVisible = false
-- 抬頭文字觸碰監聽事件
	local function showList( event )
		local phase = event.phase
		if (phase == "ended") then
			if (setStatus["titleArrow"] == "down") then
				titleArrow:rotate(180)
				setStatus["titleArrow"] = "up"
				titleListBoundary.isVisible = true
				transition.to( titleListGroup, { y = 0, time = 200})
			else
				titleArrow:rotate(180)
				setStatus["titleArrow"] = "down"
				transition.to( titleListGroup, { y = -titleListBoundary.contentHeight, time = 200})
				timer.performWithDelay(200, function() titleListBoundary.isVisible = false ; end)
			end
		end
	end
	titleText:addEventListener("touch",showList)
	titleArrow:addEventListener("touch",showList)
end

-- show()
function scene:show( event )
	local sceneGroup = self.view
	local phase = event.phase
	if ( phase == "will" ) then
	elseif ( phase == "did" ) then
	end
end

-- hide()
function scene:hide( event )
	local sceneGroup = self.view
	local phase = event.phase
	if ( phase == "will" ) then
	elseif ( phase == "did" ) then
		composer.removeScene("otherTitle")
	end
end

-- destroy()
function scene:destroy( event )
	local sceneGroup = self.view
end
-- -----------------------------------------------------------------------------------
-- Scene event function listeners
-- -----------------------------------------------------------------------------------
scene:addEventListener( "create", scene )
scene:addEventListener( "show", scene )
scene:addEventListener( "hide", scene )
scene:addEventListener( "destroy", scene )
-- -----------------------------------------------------------------------------------

return scene