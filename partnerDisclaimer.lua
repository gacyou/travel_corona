-----------------------------------------------------------------------------------------
--
-- partnerDisclaimer.lua
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

local titleListBoundary, titleListGroup
local setStatus = {}

-- function Zone Start
local function ceil( value )
	return math.ceil(value)
end

local function floor ( value )
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

-- function Zone End
-- create()
function scene:create( event )
    local sceneGroup = self.view
    mainTabBar.myTabBarHidden()
------------------- 背景元件 -------------------
	local background = display.newRect(cx, cy, screenW+ox+ox, screenH+oy+oy)
    sceneGroup:insert(background)
	background:setFillColor(unpack(backgroundColor))
------------------- 抬頭元件 -------------------
-- 白底
	local titleBase = display.newRect(0, 0, screenW+ox+ox, floor(178*hRate))
	sceneGroup:insert(titleBase)
	titleBase.x = cx
	titleBase.y = -oy+titleBase.contentHeight*0.5
-- 陰影
	local titleBaseShadow = display.newImage( sceneGroup, "assets/s-down.png", titleBase.x, titleBase.y+titleBase.contentHeight*0.5)
	titleBaseShadow.anchorY = 0
	titleBaseShadow.width = titleBase.contentWidth
	titleBaseShadow.height = floor(titleBaseShadow.height*0.8)
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
-- 顯示文字-"免責聲明"
	local titleText = display.newText({
		text = "免責聲明",
		y = titleBase.y,
		font = getFont.font,
		fontSize = 14,
	})
	sceneGroup:insert(titleText)
	titleText:setFillColor(unpack(wordColor))
	titleText.anchorX = 0
	titleText.x = backArrow.x+backArrow.contentWidth+ceil(30*wRate)
-- 下拉式選單按鈕圖片
	local listIcon = display.newImage( sceneGroup, "assets/btn-list.png",screenW+ox-ceil(45*wRate), backArrow.y)
	listIcon.width = listIcon.width*0.07
	listIcon.height = listIcon.height*0.07
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
------------------- 免責聲明文字 ------------------
-- 免責聲明讀檔	
	local path = system.pathForFile( "Font_Data/disclaime.txt", system.ResourceDirectory )
	local file = io.open(path, "r")
	local list = {}
	if not file then 
		print("File is not found")
	else
		local contents = file:read("*l")
		local count = 1
		while (contents ~= nil) do
			list[count] = contents
			count = count+1
			contents = file:read("*l")
		end
	end
	io.close( file )
	file = nil
	--for k,v in pairs(list) do
	--	print(k,v)
	--end
-- 建立免責聲明
	local disclaimerWhiteBase = display.newRect( 0, 0, screenW+ox+ox, titleBase.contentHeight)
	sceneGroup:insert(disclaimerWhiteBase)
	disclaimerWhiteBase.x = cx
	disclaimerWhiteBase.y = titleBase.y+(titleBase.contentHeight*0.5)+floor(40*hRate)+(disclaimerWhiteBase.contentHeight*0.5)
	local disclaimerText = display.newText({
		text = list[1],
		font = getFont.font,
		fontSize = 12,
	})
	sceneGroup:insert(disclaimerText)
	disclaimerText:setFillColor(unpack(mainColor2))
	disclaimerText.anchorX = 0
	disclaimerText.x = -ox+ceil(50*wRate)
	disclaimerText.y = disclaimerWhiteBase.y
-- 分隔線
	local line = display.newLine( -ox, disclaimerWhiteBase.y+disclaimerWhiteBase.contentHeight*0.5, screenW+ox, disclaimerWhiteBase.y+disclaimerWhiteBase.contentHeight*0.5)
	sceneGroup:insert(line)
	line.strokeWidth = 1
	line:setStrokeColor(unpack(separateLineColor))
-- 免責聲明scrollview
	local scrollView = widget.newScrollView({
		id = "scrollView",
		width = screenW+ox+ox,
		height = screenH+oy+oy-(disclaimerWhiteBase.y+disclaimerWhiteBase.contentHeight*0.5),
		x = cx,
		y = line.y,
		isBounceEnabled = false,
		horizontalScrollDisabled = true,
		backgroundColor = {1},
	})
	sceneGroup:insert(scrollView)
	scrollView.anchorY = 0
-- 免責說明內容	
	local disclaimeGroup = display.newGroup()
	scrollView:insert(disclaimeGroup)
	local scrollViewHeight
	local textPadding = floor(40*hRate)
	local textX = scrollView.contentWidth*0.5
	local textY = textPadding
	local textWidth = scrollView.contentWidth*0.9

	for i=3,#list do
		local disclaimeText = display.newText({
			text = list[i],
			font = getFont.font,
			fontSize = 12,
			x = textX,
			y = textY,
			width = textWidth,
		})
		disclaimeGroup:insert(disclaimeText)
		disclaimeText:setFillColor(unpack(wordColor))
		disclaimeText.anchorY = 0
		textY = textY+disclaimeText.contentHeight+textPadding
		if (i == #list) then
			scrollViewHeight = textY+disclaimeText.contentHeight+textPadding
		end
	end
	local updateDayText = display.newText({
		text = list[2],
		font = getFont.font,
		fontSize = 12,
		x = textX,
		y = textY,
		width = textWidth,
		align = "right"
	})
	disclaimeGroup:insert(updateDayText)
	updateDayText:setFillColor(unpack(mainColor2))
	updateDayText.anchorY = 0
	scrollViewHeight = scrollViewHeight+updateDayText.contentHeight+textPadding
	scrollView:setScrollHeight( scrollViewHeight )
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
		composer.removeScene("partnerDisclaimer")
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