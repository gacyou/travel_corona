-----------------------------------------------------------------------------------------
--
-- myAlbum.lua
--
-----------------------------------------------------------------------------------------
local widget = require ("widget")
local composer = require ("composer")
local mainTabBar = require("mainTabBar")
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

local memberSearchGroup
local titleListBoundary, titleListGroup
local setStatus = {}

local mainTabBarHeight = composer.getVariable("mainTabBarHeight")

local photoNum = 19
local photoBaseArray = {}
local textArray = {}
local photoEventGroup, photoScrollView

-- function Zone Start
local function ceil( value )
	return math.ceil(value)
end

local function floor( value )
	return math.floor(value)
end

local function onBtnListener( event )
	local id = event.target.id
	if (id == "backBtn") then
		options = { time = 300, effect = "fade"}
		composer.gotoScene("findPartner", options)
	end
	if (id == "listBtn") then
		if (setStatus["listBtn"] == "up") then 
			setStatus["listBtn"] = "down"
			transition.to(titleListGroup,{ y = -titleListBoundary.contentHeight, time = 200})
			timer.performWithDelay(200, function() titleListBoundary.isVisible = false ;end)
		else
			setStatus["listBtn"] = "up"
			titleListBoundary.isVisible = true
			transition.to(titleListGroup,{ y = 0, time = 200})
		end
	end
	return true
end

local function photoEvent(event)
	photoEventGroup = display.newGroup()
	local blackBase = display.newRect( cx, cy ,screenW+ox+ox, screenH+oy+oy)
	photoEventGroup:insert(blackBase)
	blackBase:setFillColor(0)
	blackBase:addEventListener("touch", function () return true; end)
	blackBase:addEventListener("tap", function () return true; end)
	local showEventBase = photoBaseArray[event.target.id]
	local prevBaseX = showEventBase.x
	local prevBaseY = showEventBase.y
	local prevBaseWidth = showEventBase.width
	local prevBaseHeight = showEventBase.height
	photoEventGroup:insert(showEventBase)
	showEventBase.width = screenW+ox+ox
	showEventBase.height = ceil(screenH+oy+oy)*0.4
	showEventBase.x = 0
	showEventBase.y = showEventBase.contentHeight/2
	local backBtnWhite = widget.newButton({
		id = "backBtnWhite",
		x = -ox+(49*wRate),
		y = -oy+ (45/2),
		width = 162,
		height = 252,
		defaultFile = "assets/btn-back-w.png",
		onRelease = function ()
			photoEventGroup.isVisible = false
			photoEventGroup:remove(showEventBase)
			showEventBase.x = prevBaseX
			showEventBase.y = prevBaseY
			showEventBase.width = prevBaseWidth
			showEventBase.height = prevBaseHeight
			photoScrollView:insert(showEventBase)
			photoEventGroup:removeSelf()
		end,
	})
	photoEventGroup:insert(backBtnWhite)
	backBtnWhite.width = (backBtnWhite.width*0.07)
	backBtnWhite.height = (backBtnWhite.height*0.07)
	backBtnWhite.anchorX = 0

	local delBtnWhite = widget.newButton({
 			id = "delBtnWhite",
 			defaultFile = "assets/trash-o-w.png",
 			width =  220,
 			height =  240,
 			onRelease = onBtnListener,
 		})
 	photoEventGroup:insert(delBtnWhite)
 	delBtnWhite.width = delBtnWhite.width*0.08
 	delBtnWhite.height = delBtnWhite.height*0.08
 	delBtnWhite.anchorX = 1
 	delBtnWhite.x = (screenW+ox)-(45*wRate)
 	delBtnWhite.y = -oy + ceil(45/2)
end
-- function Zone End

-- create()
function scene:create( event )
	local sceneGroup = self.view
	mainTabBar.myTabBarHidden()
------------------- 背景元件 -------------------
	local background = display.newRect(cx,cy+oy,screenW+ox+ox,screenH+oy+oy)
	sceneGroup:insert(background)
	background:setFillColor(unpack(backgroundColor))
------------------- 我的相簿抬頭元件 -------------------
-- 白底
	local titleBase = display.newRect(0, 0, screenW+ox+ox, floor(178*hRate))
	sceneGroup:insert(titleBase)
	titleBase.x = cx
	titleBase.y = -oy+((titleBase.height)/2)
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
		onRelease = onBtnListener,
	})
	sceneGroup:insert(backArrowNum,backBtn)
-- 顯示文字-"我的相簿"
	local titleText = display.newText({
		text = "我的相簿",
		y = titleBase.y,
		font = getFont.font,
		fontSize = 14,
	})
	sceneGroup:insert(titleText)
	titleText:setFillColor(unpack(wordColor))
	titleText.anchorX = 0
	titleText.x = backArrow.x+backArrow.contentWidth+(30*wRate)
-- 下拉式選單按鈕圖片
	local listIcon = display.newImage( sceneGroup, "assets/btn-list.png",screenW+ox-ceil(45*wRate), backArrow.y)
	listIcon.width = (listIcon.width*0.07)
	listIcon.height = (listIcon.height*0.07)
	listIcon.anchorX = 1
	local listIconNum = sceneGroup.numChildren
-- 下拉式選單按鈕
 	local listBtn = widget.newButton({
 		id = "listBtn",
 		x = listIcon.x-listIcon.contentWidth*0.5,
 		y = listIcon.y,
 		shape = "rect",
 		width =  backBtn.contentWidth,
 		height =  titleBase.contentHeight,
 		onRelease = onBtnListener,
 	})
 	sceneGroup:insert(listIconNum,listBtn)
 	setStatus["listBtn"] = "down"
-- 刪除圖片按鈕
 	local delBtnBlack = widget.newButton({
 			id = "delBtnBlack",
 			defaultFile = "assets/delete.png",
 			width =  220,
 			height =  240,
 			onRelease = onBtnListener,
 		})
 	sceneGroup:insert(delBtnBlack)
 	delBtnBlack.width = delBtnBlack.width*0.07
 	delBtnBlack.height = delBtnBlack.height*0.07
 	delBtnBlack.anchorX = 1
 	delBtnBlack.x = listIcon.x-listIcon.contentWidth-(45*wRate)
 	delBtnBlack.y = titleBase.y
------------------- 相片的ScrollView ------------
	photoScrollView = widget.newScrollView({
			id = "photoScrollView",
			width = screenW+ox+ox,
			height = screenH+oy+oy-titleBase.contentHeight,
			horizontalScrollDisabled = true,
			isBounceEnabled  = false,
			backgroundColor = backgroundColor,
		})
	sceneGroup:insert(photoScrollView)
	photoScrollView.anchorY = 0
	photoScrollView.x = cx
	photoScrollView.y = -oy+titleBase.contentHeight
-- 抬頭陰影
	local titleBaseShadow = display.newImage( sceneGroup, "assets/s-down.png", titleBase.x, titleBase.y+titleBase.contentHeight*0.5)
	titleBaseShadow.anchorY = 0
	titleBaseShadow.width = titleBase.contentWidth
	titleBaseShadow.height = floor(titleBaseShadow.height*0.8)
------------------- 相片位置 ------------------
	local addPhoto, xBasement, photoBase, totalScrollHeight
	local yBasement = 0
	if (photoNum == 0) then 
		addPhoto = display.newImageRect("assets/add.png", 318, 233)
		photoScrollView:insert(addPhoto)
		addPhoto.width = addPhoto.width*wRate
		addPhoto.height = addPhoto.height*wRate
		addPhoto.anchorX = 0
		addPhoto.anchorY = 0 
		addPhoto.x = ceil(32*wRate)
		addPhoto.y = ceil(69*hRate)
		addPhoto.id = photoNum+1
	else
		for i=1,photoNum do
			xBasement = ((i-1)%3)
			if (i > 1 and xBasement == 0 ) then
				yBasement = yBasement+1
				totalScrollHeight = ceil(69*hRate) + (photoBase.contentHeight+ceil(35*hRate))*(yBasement+1)
			end
			photoBase = display.newRect( 0, 0, 318*wRate, 233*wRate)
			photoScrollView:insert(photoBase)
			photoBase:setFillColor(math.random(),math.random(),math.random())
			photoBase.anchorX = 0
			photoBase.anchorY = 0
			photoBase.x = ceil(32*wRate) + (photoBase.contentWidth+ceil(30*wRate))*xBasement
			photoBase.y = ceil(69*hRate) + (photoBase.contentHeight+ceil(35*hRate))*yBasement
			photoBase.id = i
			photoBaseArray[i] = photoBase
			photoBase:addEventListener("tap", photoEvent)		
		end
		if (photoNum < 20) then
			addPhoto = display.newImageRect("assets/add.png", 318, 233)
			photoScrollView:insert(addPhoto)
			addPhoto.width = addPhoto.width*wRate
			addPhoto.height = addPhoto.height*wRate
			addPhoto.anchorX = 0
			addPhoto.anchorY = 0
			xBasement = (xBasement+1)%3
			addPhoto.x = ceil(32*wRate) + (photoBase.contentWidth+ceil(30*wRate))*xBasement
			if (xBasement == 0) then
				yBasement = yBasement+1
			end			
			addPhoto.y = ceil(69*hRate) + (photoBase.contentHeight+ceil(35*hRate))*yBasement
			addPhoto.id = photoNum+1
		end
	end
	if ( totalScrollHeight > photoScrollView.contentHeight) then
		photoScrollView:setScrollHeight(totalScrollHeight)
	end
------------------- 抬頭下拉式選單 -------------------
-- 選單邊界
	local listOptions = { "尋找旅伴", "我的資料", "訊息中心", "我的相簿", "我的收藏", "會員搜尋", "其他設定", "免責聲明"}
	local listOptionScenes = { "findPartner", "myInformation", nil, "myAlbum", nil, "memberSearch", "otherSetting", "partnerDisclaimer"}
	titleListBoundary = display.newContainer( screenW+ox+ox, screenH*0.5)
	sceneGroup:insert(titleListBoundary)
	titleListBoundary.anchorY = 0
	titleListBoundary.x = cx
	titleListBoundary.y = titleBase.y+titleBase.contentHeight*0.5
-- 選項內容
	titleListGroup = display.newGroup()
	titleListBoundary:insert(titleListGroup)
	-- 邊界陰影
	local titleListShadow = display.newImageRect("assets/shadow-3.png", titleListBoundary.contentWidth, titleListBoundary.contentHeight)
	titleListGroup:insert(titleListShadow)
	titleListShadow:addEventListener("touch", function () return true ; end)
	titleListShadow:addEventListener("tap", function () return true ; end)
	-- 選單
	local titleListScrollView = widget.newScrollView({
		id = "titleListScrollView",
		width = titleListShadow.contentWidth*0.97,
		height = titleListShadow.contentHeight*0.98,
		isLocked = true,
		backgroundColor = {1},
	})
	titleListGroup:insert(titleListScrollView)
	titleListScrollView.x = 0
	titleListScrollView.y = 0
	local titleListScrollViewGroup = display.newGroup()
	titleListScrollView:insert(titleListScrollViewGroup)

	local optionBaseHeight = floor(titleListScrollView.contentHeight/#listOptions)
	local optionText = {}
	local defaultTarget, nowTarget, prevTarget = nil
	local isCanceled = false
	-- 選項監聽事件
	local function optionSelect( event )
		local phase = event.phase
		if (phase == "began") then
			if (isCanceled == true) then
				isCanceled = false
			end
			if (nowTarget == nil) then
				nowTarget = event.target
				nowTarget:setFillColor( 0, 0, 0, 0.1)
				optionText[nowTarget.id]:setFillColor(unpack(subColor2))

				display.getCurrentStage():setFocus(nowTarget)
			elseif (event.target ~= nowTarget and nowTarget ~= nil) then
				prevTarget = nowTarget
				optionText[prevTarget.id]:setFillColor(unpack(wordColor))

				nowTarget = event.target
				nowTarget:setFillColor( 0, 0, 0, 0.1)
				optionText[nowTarget.id]:setFillColor(unpack(subColor2))

				display.getCurrentStage():setFocus(nowTarget)
			end
		elseif (phase == "moved") then
			local dx = math.abs(event.xStart - event.x)
			local dy = math.abs(event.yStart - event.y)
			if (dy > 10 or dx > 10) then
				titleListScrollView:takeFocus(event)
				nowTarget:setFillColor(1)
				optionText[nowTarget.id]:setFillColor(unpack(wordColor))

				display.getCurrentStage():setFocus(nil)
				if (defaultTarget ~= nil) then
					optionText[defaultTarget.id]:setFillColor(unpack(subColor2))
					nowTarget = defaultTarget
				end
				isCanceled = true
			end
		elseif (phase == "ended" and isCanceled == false and nowTarget ~= defaultTarget) then
			display.getCurrentStage():setFocus(nil)
			transition.to(titleListGroup, { y = -titleListBoundary.contentHeight, time = 200})
			nowTarget:setFillColor(1)
			setStatus["listBtn"] = "down"
			if(listOptionScenes[nowTarget.id] ~= nil) then
				timer.performWithDelay(200, function() composer.gotoScene(listOptionScenes[nowTarget.id]) ; end)
			end
		end
	end
	for i=1,#listOptions do
		-- 選項白底
		local optionBase = display.newRect(titleListScrollViewGroup, titleListScrollView.contentWidth*0.5, 0, titleListScrollView.contentWidth, optionBaseHeight)
		optionBase.y = optionBaseHeight*0.5+optionBaseHeight*(i-1)
		optionBase.id = i
		optionBase:addEventListener("touch",optionSelect)
		-- 選項文字
		optionText[i] = display.newText({
			parent = titleListScrollViewGroup,
			x = optionBase.contentWidth*0.5,
			y = optionBase.y,
			text = listOptions[i],
			font = getFont.font,
			fontSize = 12,
		})
		if (optionText[i].text == titleText.text) then 
			optionText[i]:setFillColor(unpack(subColor2))
			nowTarget = optionBase
			defaultTarget = optionBase
		else
			optionText[i]:setFillColor(unpack(wordColor))
		end
	end
	titleListGroup.y = -titleListBoundary.contentHeight
	titleListBoundary.isVisible = false
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