-----------------------------------------------------------------------------------------
--
-- myTripV4.lua
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

local mainTabBarHeight = composer.getVariable("mainTabBarHeight")
local mainTabBarY = composer.getVariable("mainTabBarY")

local titleListBoundary, titleListGroup
local setStatus = {}
local arrow = {}
-- 時間參數
local thisDate = { thisYear = tostring(os.date("%Y")), thisMonth = tostring(os.date("%m")), thisDay = tostring(os.date("%d"))}

local ceil = math.ceil
local floor = math.floor

function scene:create( event )
    local sceneGroup = self.view
    local dropDownShadow = {}
	local dropDownBase = {}
	local selected = {}
	local checkboxOptions = {
		frames = 
		{
			{
				x = 0,
				y = 0,
				width = 91,
				height = 91
			},
			{
				x = 116,
				y = 0,
				width = 91,
				height = 91
			},
			{
				x = 0,
				y = 104,
				width = 48,
				height = 48
			},
			{
				x = 60,
				y = 104,
				width = 48,
				height = 48
			},
		}
	}
	local checkboxSheet = graphics.newImageSheet("assets/checkbox.png",checkboxOptions)
------------------- 背景元件 -------------------
	local background = display.newRect(cx, cy, screenW+ox+ox, screenH+oy+oy)
	sceneGroup:insert(background)
	background:setFillColor(unpack(backgroundColor))
-- 按鈕監聽事件	
	local titleSelection, titleGroup,invitedGroup
	local function onBtnListener( event )
		local id = event.target.id 
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
		elseif (id == "backBtn") then
			local options = { time = 300, effect = "flipFadeOutIn"}
			composer.gotoScene("myTripPlan",options)
		end
		return true
	end
------------------- 抬頭元件 -------------------
-- 白色底圖
	local titleBase = display.newRect( cx, 0, screenW+ox+ox, floor(178*hRate))
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
		onRelease = onBtnListener,
	})
	sceneGroup:insert(backArrowNum,backBtn)
-- 顯示文字-新增旅程計畫
	local titleText = display.newText({
		text = "新增旅程計畫",
		height = 0,
		y = backBtn.y,
		font = getFont.font,
		fontSize = 14,
	})
	sceneGroup:insert(titleText)
	titleText:setFillColor(unpack(wordColor))
	titleText.anchorX = 0
	titleText.x = backArrow.x+backArrow.contentWidth+ceil(30*wRate)
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
-- 背景scrollView
	local backgroundScrollView = widget.newScrollView({
		id = "backgroundScrollView",
		width = screenW+ox+ox,
		height = screenH+oy+oy-titleBase.contentHeight,
		horizontalScrollDisabled = true,
		isBounceEnabled = false,
		backgroundColor = backgroundColor,
	})
	sceneGroup:insert(backgroundScrollView)
	backgroundScrollView.x = cx
	backgroundScrollView.y = titleBase.y+titleBase.contentHeight*0.5+backgroundScrollView.contentHeight*0.5
-- 陰影
	local titleBaseShadow = display.newImage( sceneGroup, "assets/s-down.png", titleBase.x, titleBase.y+titleBase.contentHeight*0.5)
	titleBaseShadow.anchorY = 0
	titleBaseShadow.width = titleBase.contentWidth
	titleBaseShadow.height = floor(titleBaseShadow.height*0.8)
------------------- 旅程資訊元件 -------------------
-- 背景scrollView的元件
	local scrollViewGroup = display.newGroup()
	backgroundScrollView:insert(scrollViewGroup)
-- 顯示文字-旅程資訊	
	local tripInfoText = display.newText({
		text = "旅程資訊",
		font = getFont.font,
		fontSize = 10,
	})
	scrollViewGroup:insert(tripInfoText)
	tripInfoText:setFillColor(unpack(wordColor))
	tripInfoText.anchorX = 0
	tripInfoText.anchorY = 0
	tripInfoText.x = backBtn.x
	tripInfoText.y = ceil(60*hRate)
------------------- 洲別元件 -------------------
	local optionTitleText = {}
-- 觸碰事件用背景
	local continentBase = display.newRect( cx, tripInfoText.y+ceil(70*hRate) , backgroundScrollView.contentWidth, ceil(160*hRate))
	scrollViewGroup:insert(continentBase)
	continentBase.anchorY = 0
-- 陰影
	tripInfoTopShadow = display.newImage( scrollViewGroup, "assets/s-up.png", continentBase.x, continentBase.y)
	tripInfoTopShadow.anchorY = 1
	tripInfoTopShadow.width = continentBase.contentWidth
	tripInfoTopShadow.height = floor(tripInfoTopShadow.height*0.5)
-- 顯示文字-"洲別"
	optionTitleText["continent"] = display.newText({
		text = "洲別",
		font = getFont.font,
		fontSize = 10,
	})
	scrollViewGroup:insert(optionTitleText["continent"])
	optionTitleText["continent"]:setFillColor(unpack(wordColor))
	optionTitleText["continent"].anchorX = 0
	optionTitleText["continent"].anchorY = 0
	optionTitleText["continent"].x = -ox+ceil(60*wRate)
	optionTitleText["continent"].y = continentBase.y+ceil(20*hRate)
-- 顯示文字-"請選擇"
	local continentSelectedText = display.newText({
		text = "請選擇",
		font = getFont.font,
		fontSize = 12,
	})
	scrollViewGroup:insert(continentSelectedText)
	continentSelectedText:setFillColor(unpack(wordColor))
	continentSelectedText.anchorX = 0
	continentSelectedText.anchorY = 0
	continentSelectedText.x = -ox+ceil(70*wRate)
	continentSelectedText.y = optionTitleText["continent"].y+optionTitleText["continent"].contentHeight+ceil(20*hRate)
-- 底線
	local continentBaseLine = display.newLine( optionTitleText["continent"].x, continentBase.y+(continentBase.contentHeight*0.95), -ox+continentBase.contentWidth*0.94, continentBase.y+(continentBase.contentHeight*0.95))
	scrollViewGroup:insert(continentBaseLine)
	continentBaseLine:setStrokeColor(unpack(separateLineColor))
	continentBaseLine.strokeWidth = 1
-- 箭頭
	arrow["continent"] = display.newImageRect("assets/btn-dropdown.png", 256, 168)
	scrollViewGroup:insert(arrow["continent"])
	arrow["continent"].width = arrow["continent"].width*0.05
	arrow["continent"].height = arrow["continent"].height*0.05
	arrow["continent"].x = continentBase.contentWidth*0.92-ox
	arrow["continent"].y = continentSelectedText.y+(continentSelectedText.contentHeight*0.6)
	setStatus["continentArrow"] = "down"
-- 洲別選單的監聽事件
	--local continentGroup 
	continentBase:addEventListener("touch", function (event)
		local phase = event.phase
		if (phase == "ended") then
			if (setStatus["continentArrow"] == "down") then
				optionTitleText["continent"]:setFillColor(unpack(subColor2))
				continentBaseLine:setStrokeColor(unpack(subColor2))
				continentBaseLine.strokeWidth = 2
				arrow["continent"]:rotate(180)
				setStatus["continentArrow"] = "up"
				--continentGroup.isVisible = true
			else
				optionTitleText["continent"]:setFillColor(unpack(wordColor))
				continentBaseLine:setStrokeColor(unpack(separateLineColor))
				continentBaseLine.strokeWidth = 1
				arrow["continent"]:rotate(180)
				setStatus["continentArrow"] = "down"
				--continentGroup.isVisible = false
			end
		end
		return true
	end)
------------------- 國家元件 -------------------
-- 觸碰事件用背景
	local tripPointBase = display.newRect( cx, continentBase.y+continentBase.contentHeight , continentBase.contentWidth, continentBase.contentHeight)
	scrollViewGroup:insert(tripPointBase)
	tripPointBase.anchorY = 0
	--tripPointBase:setFillColor( 1, 0, 0, 0.3)
-- 顯示文字-"國家"
	optionTitleText["tripPoint"] = display.newText({
		text = "國家",
		font = getFont.font,
		fontSize = 10,
	})
	scrollViewGroup:insert(optionTitleText["tripPoint"])
	optionTitleText["tripPoint"]:setFillColor(unpack(wordColor))
	optionTitleText["tripPoint"].anchorX = 0
	optionTitleText["tripPoint"].anchorY = 0
	optionTitleText["tripPoint"].x = -ox+ceil(60*wRate)
	optionTitleText["tripPoint"].y = tripPointBase.y+ceil(20*hRate)
-- 顯示文字-請選擇
	local tripPointSelectedText = display.newText({
		text = "請選擇",
		font = getFont.font,
		fontSize = 12,
	})
	scrollViewGroup:insert(tripPointSelectedText)
	tripPointSelectedText:setFillColor(unpack(wordColor))
	tripPointSelectedText.anchorX = 0
	tripPointSelectedText.anchorY = 0
	tripPointSelectedText.x = -ox+ceil(70*wRate)
	tripPointSelectedText.y = optionTitleText["tripPoint"].y+optionTitleText["tripPoint"].contentHeight+ceil(20*hRate)
-- 底線
	local tripPointBaseLine = display.newLine( optionTitleText["tripPoint"].x, tripPointBase.y+(tripPointBase.contentHeight*0.95), -ox+tripPointBase.contentWidth*0.94, tripPointBase.y+(tripPointBase.contentHeight*0.95))
	scrollViewGroup:insert(tripPointBaseLine)
	tripPointBaseLine:setStrokeColor(unpack(separateLineColor))
	tripPointBaseLine.strokeWidth = 1
-- 箭頭
	arrow["tripPoint"] = display.newImageRect("assets/btn-dropdown.png", 256, 168)
	scrollViewGroup:insert(arrow["tripPoint"])
	arrow["tripPoint"].width = arrow["tripPoint"].width*0.05
	arrow["tripPoint"].height = arrow["tripPoint"].height*0.05
	arrow["tripPoint"].x = tripPointBase.contentWidth*0.92-ox
	arrow["tripPoint"].y = tripPointSelectedText.y+(tripPointSelectedText.contentHeight*0.6)
	setStatus["tripPointArrow"] = "down"
-- 旅行地點選單的監聽事件
	local tripPointGroup 
	tripPointBase:addEventListener("touch", function (event)
		local phase = event.phase
		if (phase == "ended") then
			if (setStatus["tripPointArrow"] == "down") then
				optionTitleText["tripPoint"]:setFillColor(unpack(subColor2))
				tripPointBaseLine:setStrokeColor(unpack(subColor2))
				tripPointBaseLine.strokeWidth = 2
				arrow["tripPoint"]:rotate(180)
				setStatus["tripPointArrow"] = "up"
				tripPointGroup.isVisible = true
			else
				optionTitleText["tripPoint"]:setFillColor(unpack(wordColor))
				tripPointBaseLine:setStrokeColor(unpack(separateLineColor))
				tripPointBaseLine.strokeWidth = 1
				arrow["tripPoint"]:rotate(180)
				setStatus["tripPointArrow"] = "down"
				tripPointGroup.isVisible = false	
			end
		end
		return true
	end)
------------------- 地區元件 -------------------
-- 觸碰事件用背景
	local tripRegionBase = display.newRect( tripPointBase.x, tripPointBase.y+tripPointBase.contentHeight, tripPointBase.contentWidth, tripPointBase.contentHeight)
	scrollViewGroup:insert(tripRegionBase)
	tripRegionBase.anchorY = 0
	--tripRegionBase:setFillColor( 0, 1, 0, 0.3)
-- 顯示文字-地區
	optionTitleText["tripRegion"] = display.newText({
		text = "地區",
		font = getFont.font,
		fontSize = 10,
	})
	scrollViewGroup:insert(optionTitleText["tripRegion"])
	optionTitleText["tripRegion"]:setFillColor(unpack(wordColor))
	optionTitleText["tripRegion"].anchorX = 0
	optionTitleText["tripRegion"].anchorY = 0
	optionTitleText["tripRegion"].x = -ox+ceil(60*wRate)
	optionTitleText["tripRegion"].y = optionTitleText["tripPoint"].y+tripRegionBase.contentHeight
-- 顯示文字-請選擇
	local tripRegionSelectedText = display.newText({
		text = "請選擇",
		font = getFont.font,
		fontSize = 12,
	})
	scrollViewGroup:insert(tripRegionSelectedText)
	tripRegionSelectedText:setFillColor(unpack(wordColor))
	tripRegionSelectedText.anchorX = 0
	tripRegionSelectedText.anchorY = 0
	tripRegionSelectedText.x = -ox+ceil(70*wRate)
	tripRegionSelectedText.y = optionTitleText["tripRegion"].y+optionTitleText["tripRegion"].contentHeight+ceil(20*hRate)
-- 底線
	local tripRegionBaseLine = display.newLine( optionTitleText["tripRegion"].x, tripRegionBase.y+(tripRegionBase.contentHeight*0.95), -ox+tripRegionBase.contentWidth*0.94, tripRegionBase.y+(tripRegionBase.contentHeight*0.95))
	scrollViewGroup:insert(tripRegionBaseLine)
	tripRegionBaseLine:setStrokeColor(unpack(separateLineColor))
	tripRegionBaseLine.strokeWidth = 1
-- 箭頭
	arrow["tripRegion"] = display.newImageRect("assets/btn-dropdown.png", 256, 168)
	scrollViewGroup:insert(arrow["tripRegion"])
	arrow["tripRegion"].width = arrow["tripRegion"].width*0.05
	arrow["tripRegion"].height = arrow["tripRegion"].height*0.05
	arrow["tripRegion"].x = tripRegionBase.contentWidth*0.92-ox
	arrow["tripRegion"].y = tripRegionSelectedText.y+(tripRegionSelectedText.contentHeight*0.6)
	setStatus["tripRegionArrow"] = "down"
-- 遮罩
	local tripRegionCover = display.newRect( tripRegionBase.x, tripRegionBase.y, tripRegionBase.contentWidth, tripRegionBase.contentHeight)
	scrollViewGroup:insert(tripRegionCover)
	tripRegionCover.anchorY = 0
	tripRegionCover:setFillColor( 1, 1, 1, 0.7)
	tripRegionCover:addEventListener("touch", function() return true ; end)
	--tripRegionCover.isVisible = false
-- 地區選單的監聽事件
	local tripRegionGroup, tripPointSelected
	tripRegionBase:addEventListener("touch", function (event)
		local phase = event.phase
		if (tripPointSelected == true) then 
			if (phase == "ended") then
				if (setStatus["tripRegionArrow"] == "down") then
					optionTitleText["tripRegion"]:setFillColor(unpack(subColor2))
					tripRegionBaseLine:setStrokeColor(unpack(subColor2))
					tripRegionBaseLine.strokeWidth = 2
					arrow["tripRegion"]:rotate(180)
					setStatus["tripRegionArrow"] = "up"
					tripRegionGroup.isVisible = true
				else
					optionTitleText["tripRegion"]:setFillColor(unpack(wordColor))
					tripRegionBaseLine:setStrokeColor(unpack(separateLineColor))
					tripRegionBaseLine.strokeWidth = 1
					arrow["tripRegion"]:rotate(180)
					setStatus["tripRegionArrow"] = "down"
					tripRegionGroup.isVisible = false	
				end
			end
		end
		return true
	end)
------------------- 出發日期元件 -------------------
	local showedWord = {}
-- 觸碰事件用背景
	local startDateBase = display.newRect( tripRegionBase.x, tripRegionBase.y+tripRegionBase.contentHeight, tripRegionBase.contentWidth, tripRegionBase.contentHeight)
	scrollViewGroup:insert(startDateBase)
	startDateBase.anchorY = 0
	--startDateBase:setFillColor( 0, 0, 1, 0.3)
	-- 年
	local startDateYearBase = display.newRect( 0, 0, startDateBase.contentWidth*0.28, startDateBase.contentHeight)
	scrollViewGroup:insert(startDateYearBase)
	startDateYearBase.anchorY = 0
	startDateYearBase.x = -ox+ceil(60*wRate)+startDateYearBase.contentWidth/2
	startDateYearBase.y = startDateBase.y
	startDateYearBase.name = "sYearBase"
	setStatus["startDateYearBase"] = "off"
	-- 月
	local startDateMonthBase = display.newRect( 0, 0, startDateBase.contentWidth*0.3, startDateBase.contentHeight)
	scrollViewGroup:insert(startDateMonthBase)
	startDateMonthBase.anchorY = 0
	startDateMonthBase.x = startDateYearBase.x+startDateYearBase.contentWidth/2+startDateMonthBase.contentWidth/2
	startDateMonthBase.y = startDateBase.y
	startDateMonthBase.name = "sMonthBase"
	setStatus["startDateMonthBase"] = "off"
	-- 日
	local startDateDayBase = display.newRect( 0, 0, startDateBase.contentWidth*0.3, startDateBase.contentHeight)
	scrollViewGroup:insert(startDateDayBase)
	startDateDayBase.anchorY = 0
	startDateDayBase.x = startDateMonthBase.x+startDateMonthBase.contentWidth/2+startDateDayBase.contentWidth/2
	startDateDayBase.y = startDateBase.y
	startDateDayBase.name = "sDayBase"
	setStatus["startDateDayBase"] = "off"
-- 顯示文字-"出發日期"
	optionTitleText["startDate"] = display.newText({
		text = "出發日期",
		font = getFont.font,
		fontSize = 10,
	})
	scrollViewGroup:insert(optionTitleText["startDate"])
	optionTitleText["startDate"]:setFillColor(unpack(wordColor))
	optionTitleText["startDate"].anchorX = 0
	optionTitleText["startDate"].anchorY = 0
	optionTitleText["startDate"].x = -ox+ceil(60*wRate)
	optionTitleText["startDate"].y = optionTitleText["tripRegion"].y+startDateBase.contentHeight
-- 出發日期選項-顯示文字
-- 年-顯示日期
	local startDateYearSelectedText = display.newText({
		text = thisDate.thisYear,
		font = getFont.font,
		fontSize = 12,
	})
	scrollViewGroup:insert(startDateYearSelectedText)
	startDateYearSelectedText:setFillColor(unpack(wordColor))
	startDateYearSelectedText.anchorX = 0
	startDateYearSelectedText.anchorY = 0
	startDateYearSelectedText.x = -ox+startDateBase.contentWidth*0.12
	startDateYearSelectedText.y = optionTitleText["startDate"].y+optionTitleText["startDate"].contentHeight+ceil(20*hRate)
-- 年-箭頭
	arrow["startYear"] = display.newImageRect("assets/btn-dropdown.png", 256, 168)
	scrollViewGroup:insert(arrow["startYear"])
	arrow["startYear"].width = arrow["startYear"].width*0.05
	arrow["startYear"].height = arrow["startYear"].height*0.05
	arrow["startYear"].x = -ox+tripRegionBase.contentWidth*0.27
	arrow["startYear"].y = startDateYearSelectedText.y+(startDateYearSelectedText.contentHeight*0.55)
	setStatus["startDateYearArrow"] = "down"
-- 年-"年"
	showedWord["startYear"] = display.newText({
		text = "年",
		font = getFont.font,
		fontSize = 12,
	})
	scrollViewGroup:insert(showedWord["startYear"])
	showedWord["startYear"]:setFillColor(unpack(wordColor))
	showedWord["startYear"].anchorX = 0
	showedWord["startYear"].anchorY = 0
	showedWord["startYear"].x = -ox+startDateBase.contentWidth*0.3
	showedWord["startYear"].y = startDateYearSelectedText.y
-- 月-顯示日期
	local startDateMonthSelectedText = display.newText({
		text = thisDate.thisMonth,
		font = getFont.font,
		fontSize = 12,
	})
	scrollViewGroup:insert(startDateMonthSelectedText)
	startDateMonthSelectedText:setFillColor(unpack(wordColor))
	startDateMonthSelectedText.anchorX = 0
	startDateMonthSelectedText.anchorY = 0
	startDateMonthSelectedText.x = -ox+startDateBase.contentWidth*0.45
	startDateMonthSelectedText.y = startDateYearSelectedText.y
-- 月-箭頭
	arrow["startMonth"] = display.newImageRect("assets/btn-dropdown.png", 256, 168)
	scrollViewGroup:insert(arrow["startMonth"])
	arrow["startMonth"].width = arrow["startMonth"].width*0.05
	arrow["startMonth"].height = arrow["startMonth"].height*0.05
	arrow["startMonth"].x = -ox+tripRegionBase.contentWidth*0.57
	arrow["startMonth"].y = startDateMonthSelectedText.y+(startDateMonthSelectedText.contentHeight*0.55)
	setStatus["startDateMonthArrow"] = "down"
-- 月-"月"
	showedWord["startMonth"] = display.newText({
		text = "月",
		font = getFont.font,
		fontSize = 12,
	})
	scrollViewGroup:insert(showedWord["startMonth"])
	showedWord["startMonth"]:setFillColor(unpack(wordColor))
	showedWord["startMonth"].anchorX = 0
	showedWord["startMonth"].anchorY = 0
	showedWord["startMonth"].x = -ox+startDateBase.contentWidth*0.6
	showedWord["startMonth"].y = startDateYearSelectedText.y
-- 月-遮罩
	local startDateMonthCover = display.newRect( 0, 0, startDateMonthBase.contentWidth, startDateMonthBase.contentHeight)
	scrollViewGroup:insert(startDateMonthCover)
	startDateMonthCover.anchorY = 0
	startDateMonthCover.x = startDateMonthBase.x
	startDateMonthCover.y = startDateMonthBase.y
	startDateMonthCover:setFillColor( 1, 1, 1, 0.7)
	startDateMonthCover.isVisible = false
	startDateMonthCover:addEventListener("touch", function() return true ; end)
-- 日-顯示日期
	local startDateDaySelectedText = display.newText({
		text = thisDate.thisDay,
		font = getFont.font,
		fontSize = 12,
	})
	scrollViewGroup:insert(startDateDaySelectedText)
	startDateDaySelectedText:setFillColor(unpack(wordColor))
	startDateDaySelectedText.anchorX = 0
	startDateDaySelectedText.anchorY = 0
	startDateDaySelectedText.x = -ox+startDateBase.contentWidth*0.75
	startDateDaySelectedText.y = startDateYearSelectedText.y
-- 日-箭頭
	arrow["startDay"] = display.newImageRect("assets/btn-dropdown.png", 256, 168)
	scrollViewGroup:insert(arrow["startDay"])
	arrow["startDay"].width = arrow["startDay"].width*0.05
	arrow["startDay"].height = arrow["startDay"].height*0.05
	arrow["startDay"].x = -ox+tripRegionBase.contentWidth*0.87
	arrow["startDay"].y = startDateDaySelectedText.y+(startDateDaySelectedText.contentHeight*0.55)
	setStatus["startDateDayArrow"] = "down"
-- 日-"日"
	showedWord["startDay"] = display.newText({
		text = "日",
		font = getFont.font,
		fontSize = 12,
	})
	scrollViewGroup:insert(showedWord["startDay"])
	showedWord["startDay"]:setFillColor(unpack(wordColor))
	showedWord["startDay"].anchorX = 0
	showedWord["startDay"].anchorY = 0
	showedWord["startDay"].x = -ox+startDateBase.contentWidth*0.9
	showedWord["startDay"].y = startDateYearSelectedText.y
-- 日-遮罩
	local startDateDayCover = display.newRect( 0, 0, startDateDayBase.contentWidth, startDateDayBase.contentHeight)
	scrollViewGroup:insert(startDateDayCover)
	startDateDayCover.anchorY = 0
	startDateDayCover.x = startDateDayBase.x
	startDateDayCover.y = startDateDayBase.y
	startDateDayCover:setFillColor( 1, 1, 1, 0.7)
	startDateDayCover.isVisible = false
	startDateDayCover:addEventListener("touch", function() return true ; end)
-- 出發日期選項-底線
	local startDateBaseLine = display.newLine( optionTitleText["startDate"].x, startDateBase.y+(startDateBase.contentHeight*0.95), startDateBase.contentWidth*0.94-ox, startDateBase.y+(startDateBase.contentHeight*0.95))
	scrollViewGroup:insert(startDateBaseLine)
	startDateBaseLine:setStrokeColor(unpack(separateLineColor))
	startDateBaseLine.strokeWidth = 1
-- 出發日期選單開關監聽事件
	local startDateYearGroup, startDateMonthGroup, startDateDayGroup 
	local function startDateBaseListner(event)
		local phase = event.phase
		local name = event.target.name
		if (phase == "ended") then 
			if (name == "sYearBase") then
				if (setStatus["startDateYearBase"] == "off") then
					-- 年的打開選單動作
					arrow["startYear"]:rotate(180)
					setStatus["startDateYearBase"] = "on"
					startDateYearGroup.isVisible = true
					-- 打開月遮罩，同時取消月選項的選擇
					startDateMonthCover.isVisible = true
					if (setStatus["startDateMonthBase"] == "on") then
						arrow["startMonth"]:rotate(180)
						setStatus["startDateMonthBase"] = "off"
						startDateMonthGroup.isVisible = false
					end
					-- 打開日遮罩，同時取消日選項的選擇
					startDateDayCover.isVisible = true
					if (setStatus["startDateDayBase"] == "on") then
						arrow["startDay"]:rotate(180)
						setStatus["startDateDayBase"] = "off"
						startDateDayGroup.isVisible = false
					end
					if( setStatus["startDateMonthBase"] == "off" and setStatus["startDateDayBase"] == "off") then 
						optionTitleText["startDate"]:setFillColor(unpack(subColor2))
						startDateBaseLine:setStrokeColor(unpack(subColor2))
						startDateBaseLine.strokeWidth = 2
					end	
				else
					-- 年的關閉選單動作
					arrow["startYear"]:rotate(180)
					setStatus["startDateYearBase"] = "off"
					startDateYearGroup.isVisible = false
					startDateMonthCover.isVisible = false
					startDateDayCover.isVisible = false
					if( setStatus["startDateMonthBase"] == "off" and setStatus["startDateDayBase"] == "off") then 
						optionTitleText["startDate"]:setFillColor(unpack(wordColor))
						startDateBaseLine:setStrokeColor(unpack(separateLineColor))
						startDateBaseLine.strokeWidth = 1
					end
				end
			elseif (name == "sMonthBase") then
				if (setStatus["startDateMonthBase"] == "off") then
					-- 月的打開選單動作
					arrow["startMonth"]:rotate(180)
					setStatus["startDateMonthBase"] = "on"
					startDateMonthGroup.isVisible = true
					-- 打開日遮罩，同時取消日選項的選擇
					startDateDayCover.isVisible = true
					if (setStatus["startDateDayBase"] == "on") then
						arrow["startDay"]:rotate(180)
						setStatus["startDateDayBase"] = "off"
						startDateDayGroup.isVisible = false
					end
					if (setStatus["startDateYearBase"] == "off" and setStatus["startDateDayBase"] == "off") then 
						optionTitleText["startDate"]:setFillColor(unpack(subColor2))
						startDateBaseLine:setStrokeColor(unpack(subColor2))
						startDateBaseLine.strokeWidth = 2
					end	
				else
					-- 月的關閉選單動作
					arrow["startMonth"]:rotate(180)
					setStatus["startDateMonthBase"] = "off"
					startDateMonthGroup.isVisible = false
					startDateDayCover.isVisible = false
					if (setStatus["startDateYearBase"] == "off" and setStatus["startDateDayBase"] == "off") then 
						optionTitleText["startDate"]:setFillColor(unpack(wordColor))
						startDateBaseLine:setStrokeColor(unpack(separateLineColor))
						startDateBaseLine.strokeWidth = 1
					end				
				end
			elseif (name == "sDayBase") then
				if (setStatus["startDateDayBase"] == "off") then
					-- 日的打開選單動作
					arrow["startDay"]:rotate(180)
					setStatus["startDateDayBase"] = "on"
					startDateDayGroup.isVisible = true
					if( setStatus["startDateYearBase"] == "off" and setStatus["startDateMonthBase"] == "off") then 
						optionTitleText["startDate"]:setFillColor(unpack(subColor2))
						startDateBaseLine:setStrokeColor(unpack(subColor2))
						startDateBaseLine.strokeWidth = 2
					end	
				else
					-- 日的關閉選單動作
					arrow["startDay"]:rotate(180)
					setStatus["startDateDayBase"] = "off"
					startDateDayGroup.isVisible = false
					if( setStatus["startDateYearBase"] == "off" and setStatus["startDateMonthBase"] == "off") then 
						optionTitleText["startDate"]:setFillColor(unpack(wordColor))
						startDateBaseLine:setStrokeColor(unpack(separateLineColor))
						startDateBaseLine.strokeWidth = 1
					end	
				end
			end
		end
		return true
	end
	startDateYearBase:addEventListener("touch", startDateBaseListner)
	startDateMonthBase:addEventListener("touch", startDateBaseListner)
	startDateDayBase:addEventListener("touch", startDateBaseListner)
------------------- 回程日期元件 -------------------
-- 觸碰事件用背景
	local backDateBase = display.newRect( startDateBase.x, startDateBase.y+startDateBase.contentHeight, startDateBase.contentWidth, startDateBase.contentHeight)
	scrollViewGroup:insert(backDateBase)
	backDateBase.anchorY = 0
	-- 年
	local backDateYearBase = display.newRect( 0, 0, backDateBase.contentWidth*0.28, backDateBase.contentHeight)
	scrollViewGroup:insert(backDateYearBase)
	backDateYearBase.anchorY = 0
	backDateYearBase.x = -ox+ceil(60*wRate)+backDateYearBase.contentWidth/2
	backDateYearBase.y = backDateBase.y
	backDateYearBase.name = "bYearBase"
	setStatus["backDateYearBase"] = "off"
	-- 月
	local backDateMonthBase = display.newRect( 0, 0, backDateBase.contentWidth*0.3, backDateBase.contentHeight)
	scrollViewGroup:insert(backDateMonthBase)
	backDateMonthBase.anchorY = 0
	backDateMonthBase.x = backDateYearBase.x+backDateYearBase.contentWidth/2+backDateMonthBase.contentWidth/2
	backDateMonthBase.y = backDateBase.y
	backDateMonthBase.name = "bMonthBase"
	setStatus["backDateMonthBase"] = "off"
	-- 日
	local backDateDayBase = display.newRect( 0, 0, backDateBase.contentWidth*0.3, backDateBase.contentHeight)
	scrollViewGroup:insert(backDateDayBase)
	backDateDayBase.anchorY = 0
	backDateDayBase.x = backDateMonthBase.x+backDateMonthBase.contentWidth/2+backDateDayBase.contentWidth/2
	backDateDayBase.y = backDateBase.y
	backDateDayBase.name = "bDayBase"
	setStatus["backDateDayBase"] = "off"
-- 顯示文字-回程日期
	optionTitleText["backDate"] = display.newText({
		text = "回程日期",
		font = getFont.font,
		fontSize = 10,
	})
	scrollViewGroup:insert(optionTitleText["backDate"])
	optionTitleText["backDate"]:setFillColor(unpack(wordColor))
	optionTitleText["backDate"].anchorX = 0
	optionTitleText["backDate"].anchorY = 0
	optionTitleText["backDate"].x = -ox+ceil(60*wRate)
	optionTitleText["backDate"].y = optionTitleText["startDate"].y+backDateBase.contentHeight
-- 回程日期選項-顯示文字
-- 年-顯示日期
	local backDateYearSelectedText = display.newText({
		text = thisDate.thisYear,
		font = getFont.font,
		fontSize = 12,
	})
	scrollViewGroup:insert(backDateYearSelectedText)
	backDateYearSelectedText:setFillColor(unpack(wordColor))
	backDateYearSelectedText.anchorX = 0
	backDateYearSelectedText.anchorY = 0
	backDateYearSelectedText.x = -ox+backDateBase.contentWidth*0.12
	backDateYearSelectedText.y = optionTitleText["backDate"].y+optionTitleText["backDate"].contentHeight+ceil(20*hRate)
-- 年-箭頭
	arrow["backYear"] = display.newImageRect("assets/btn-dropdown.png", 256, 168)
	scrollViewGroup:insert(arrow["backYear"])
	arrow["backYear"].width = arrow["backYear"].width*0.05
	arrow["backYear"].height = arrow["backYear"].height*0.05
	arrow["backYear"].x = -ox+tripRegionBase.contentWidth*0.27
	arrow["backYear"].y = backDateYearSelectedText.y+(backDateYearSelectedText.contentHeight*0.55)
	setStatus["backDateYearArrow"] = "down"
-- 年-"年"
	showedWord["backYear"] = display.newText({
		text = "年",
		font = getFont.font,
		fontSize = 12,
	})
	scrollViewGroup:insert(showedWord["backYear"])
	showedWord["backYear"]:setFillColor(unpack(wordColor))
	showedWord["backYear"].anchorX = 0
	showedWord["backYear"].anchorY = 0
	showedWord["backYear"].x = -ox+backDateBase.contentWidth*0.3
	showedWord["backYear"].y = backDateYearSelectedText.y
-- 月-顯示日期
	local backDateMonthSelectedText = display.newText({
		text = thisDate.thisMonth,
		font = getFont.font,
		fontSize = 12,
	})
	scrollViewGroup:insert(backDateMonthSelectedText)
	backDateMonthSelectedText:setFillColor(unpack(wordColor))
	backDateMonthSelectedText.anchorX = 0
	backDateMonthSelectedText.anchorY = 0
	backDateMonthSelectedText.x = -ox+backDateBase.contentWidth*0.45
	backDateMonthSelectedText.y = backDateYearSelectedText.y
-- 月-箭頭
	arrow["backMonth"] = display.newImageRect("assets/btn-dropdown.png", 256, 168)
	scrollViewGroup:insert(arrow["backMonth"])
	arrow["backMonth"].width = arrow["backMonth"].width*0.05
	arrow["backMonth"].height = arrow["backMonth"].height*0.05
	arrow["backMonth"].x = -ox+tripRegionBase.contentWidth*0.57
	arrow["backMonth"].y = backDateMonthSelectedText.y+(backDateMonthSelectedText.contentHeight*0.55)
	setStatus["backDateMonthArrow"] = "down"
-- 月-"月"
	showedWord["backMonth"] = display.newText({
		text = "月",
		font = getFont.font,
		fontSize = 12,
	})
	scrollViewGroup:insert(showedWord["backMonth"])
	showedWord["backMonth"]:setFillColor(unpack(wordColor))
	showedWord["backMonth"].anchorX = 0
	showedWord["backMonth"].anchorY = 0
	showedWord["backMonth"].x = -ox+backDateBase.contentWidth*0.6
	showedWord["backMonth"].y = backDateYearSelectedText.y
-- 月-遮罩
	local backDateMonthCover = display.newRect( 0, 0, backDateMonthBase.contentWidth, backDateMonthBase.contentHeight)
	scrollViewGroup:insert(backDateMonthCover)
	backDateMonthCover.anchorY = 0
	backDateMonthCover.x = backDateMonthBase.x
	backDateMonthCover.y = backDateMonthBase.y
	backDateMonthCover:setFillColor( 1, 1, 1, 0.7)
	backDateMonthCover.isVisible = false
	backDateMonthCover:addEventListener("touch", function() return true ; end)
-- 日-顯示日期
	local backDateDaySelectedText = display.newText({
		text = thisDate.thisDay,
		font = getFont.font,
		fontSize = 12,
	})
	scrollViewGroup:insert(backDateDaySelectedText)
	backDateDaySelectedText:setFillColor(unpack(wordColor))
	backDateDaySelectedText.anchorX = 0
	backDateDaySelectedText.anchorY = 0
	backDateDaySelectedText.x = -ox+backDateBase.contentWidth*0.75
	backDateDaySelectedText.y = backDateYearSelectedText.y
-- 日-箭頭
	arrow["backDay"] = display.newImageRect("assets/btn-dropdown.png", 256, 168)
	scrollViewGroup:insert(arrow["backDay"])
	arrow["backDay"].width = arrow["backDay"].width*0.05
	arrow["backDay"].height = arrow["backDay"].height*0.05
	arrow["backDay"].x = -ox+tripRegionBase.contentWidth*0.87
	arrow["backDay"].y = backDateDaySelectedText.y+(backDateDaySelectedText.contentHeight*0.55)
	setStatus["backDateDayArrow"] = "down"
-- 日-"日"
	showedWord["backDay"] = display.newText({
		text = "日",
		font = getFont.font,
		fontSize = 12,
	})
	scrollViewGroup:insert(showedWord["backDay"])
	showedWord["backDay"]:setFillColor(unpack(wordColor))
	showedWord["backDay"].anchorX = 0
	showedWord["backDay"].anchorY = 0
	showedWord["backDay"].x = -ox+backDateBase.contentWidth*0.9
	showedWord["backDay"].y = backDateYearSelectedText.y
-- 日-遮罩
	local backDateDayCover = display.newRect( 0, 0, backDateDayBase.contentWidth, backDateDayBase.contentHeight)
	scrollViewGroup:insert(backDateDayCover)
	backDateDayCover.anchorY = 0
	backDateDayCover.x = backDateDayBase.x
	backDateDayCover.y = backDateDayBase.y
	backDateDayCover:setFillColor( 1, 1, 1, 0.7)
	backDateDayCover.isVisible = false
	backDateDayCover:addEventListener("touch", function() return true ; end)
-- 回程日期選項-底線
	local backDateBaseLine = display.newLine( optionTitleText["backDate"].x, backDateBase.y+(backDateBase.contentHeight*0.95), backDateBase.contentWidth*0.94-ox, backDateBase.y+(backDateBase.contentHeight*0.95))
	scrollViewGroup:insert(backDateBaseLine)
	backDateBaseLine:setStrokeColor(unpack(separateLineColor))
	backDateBaseLine.strokeWidth = 1
-- 回程日期選單開關監聽事件
	local backDateYearGroup, backDateMonthGroup, backDateDayGroup 
	local function backDateBaseListner(event)
		local phase = event.phase
		local name = event.target.name
		if (phase == "ended") then 
			if (name == "bYearBase") then
				if (setStatus["backDateYearBase"] == "off") then
					-- 年的打開選單動作
					arrow["backYear"]:rotate(180)
					setStatus["backDateYearBase"] = "on"
					backDateYearGroup.isVisible = true
					-- 打開月遮罩，同時取消月選項的選擇
					backDateMonthCover.isVisible = true
					if (setStatus["backDateMonthBase"] == "on") then
						arrow["backMonth"]:rotate(180)
						setStatus["backDateMonthBase"] = "off"
						backDateMonthGroup.isVisible = false
					end
					-- 打開日遮罩，同時取消日選項的選擇
					backDateDayCover.isVisible = true
					if (setStatus["backDateDayBase"] == "on") then
						arrow["backDay"]:rotate(180)
						setStatus["backDateDayBase"] = "off"
						backDateDayGroup.isVisible = false
					end
					if( setStatus["backDateMonthBase"] == "off" and setStatus["backDateDayBase"] == "off") then 
						optionTitleText["backDate"]:setFillColor(unpack(subColor2))
						backDateBaseLine:setStrokeColor(unpack(subColor2))
						backDateBaseLine.strokeWidth = 2
					end	
				else
					-- 年的關閉選單動作
					arrow["backYear"]:rotate(180)
					setStatus["backDateYearBase"] = "off"
					backDateYearGroup.isVisible = false
					backDateMonthCover.isVisible = false
					backDateDayCover.isVisible = false
					if( setStatus["backDateMonthBase"] == "off" and setStatus["backDateDayBase"] == "off") then 
						optionTitleText["backDate"]:setFillColor(unpack(wordColor))
						backDateBaseLine:setStrokeColor(unpack(separateLineColor))
						backDateBaseLine.strokeWidth = 1
					end
				end
			elseif (name == "bMonthBase") then
				if (setStatus["backDateMonthBase"] == "off") then
					-- 月的打開選單動作
					arrow["backMonth"]:rotate(180)
					setStatus["backDateMonthBase"] = "on"
					backDateMonthGroup.isVisible = true
					-- 打開日遮罩，同時取消日選項的選擇
					backDateDayCover.isVisible = true
					if (setStatus["backDateDayBase"] == "on") then
						arrow["backDay"]:rotate(180)
						setStatus["backDateDayBase"] = "off"
						backDateDayGroup.isVisible = false
					end
					if (setStatus["backDateYearBase"] == "off" and setStatus["backDateDayBase"] == "off") then 
						optionTitleText["backDate"]:setFillColor(unpack(subColor2))
						backDateBaseLine:setStrokeColor(unpack(subColor2))
						backDateBaseLine.strokeWidth = 2
					end	
				else
					-- 月的關閉選單動作
					arrow["backMonth"]:rotate(180)
					setStatus["backDateMonthBase"] = "off"
					backDateMonthGroup.isVisible = false
					backDateDayCover.isVisible = false
					if (setStatus["backDateYearBase"] == "off" and setStatus["backDateDayBase"] == "off") then 
						optionTitleText["backDate"]:setFillColor(unpack(wordColor))
						backDateBaseLine:setStrokeColor(unpack(separateLineColor))
						backDateBaseLine.strokeWidth = 1
					end				
				end
			elseif (name == "bDayBase") then
				if (setStatus["backDateDayBase"] == "off") then
					-- 日的打開選單動作
					arrow["backDay"]:rotate(180)
					setStatus["backDateDayBase"] = "on"
					backDateDayGroup.isVisible = true
					if( setStatus["backDateYearBase"] == "off" and setStatus["backDateMonthBase"] == "off") then 
						optionTitleText["backDate"]:setFillColor(unpack(subColor2))
						backDateBaseLine:setStrokeColor(unpack(subColor2))
						backDateBaseLine.strokeWidth = 2
					end	
				else
					-- 日的關閉選單動作
					arrow["backDay"]:rotate(180)
					setStatus["backDateDayBase"] = "off"
					backDateDayGroup.isVisible = false
					if( setStatus["backDateYearBase"] == "off" and setStatus["backDateMonthBase"] == "off") then 
						optionTitleText["backDate"]:setFillColor(unpack(wordColor))
						backDateBaseLine:setStrokeColor(unpack(separateLineColor))
						backDateBaseLine.strokeWidth = 1
					end	
				end
			end
		end
		return true
	end
	backDateYearBase:addEventListener("touch", backDateBaseListner)
	backDateMonthBase:addEventListener("touch", backDateBaseListner)
	backDateDayBase:addEventListener("touch", backDateBaseListner)
------------------- 費用分配元件 -------------------
-- 觸碰事件用背景
	local chargeBase = display.newRect( backDateBase.x, backDateBase.y+backDateBase.contentHeight, backDateBase.contentWidth, backDateBase.contentHeight)
	scrollViewGroup:insert(chargeBase)
	chargeBase.anchorY = 0
-- 陰影
	local tripInfoBottomShadow = display.newImage( scrollViewGroup, "assets/s-down.png", chargeBase.x, chargeBase.y+chargeBase.contentHeight)
	tripInfoBottomShadow.anchorY = 0
	tripInfoBottomShadow.width = titleBase.contentWidth
	tripInfoBottomShadow.height = floor(tripInfoBottomShadow.height*0.5)
-- 顯示文字-費用分配
	optionTitleText["charge"] = display.newText({
		text = "費用分配",
		font = getFont.font,
		fontSize = 10,
	})
	scrollViewGroup:insert(optionTitleText["charge"])
	optionTitleText["charge"]:setFillColor(unpack(wordColor))
	optionTitleText["charge"].anchorX = 0
	optionTitleText["charge"].anchorY = 0
	optionTitleText["charge"].x = -ox+ceil(60*wRate)
	optionTitleText["charge"].y = optionTitleText["backDate"].y+backDateBase.contentHeight
-- chargeRadio
	local myChargeRadio = widget.newSwitch({
			id = "myChargeRadio",
			style = "radio",
			x = -ox+ceil(60*wRate),
			y = optionTitleText["charge"].y+optionTitleText["charge"].contentHeight+floor(10*hRate),
			sheet = checkboxSheet,
			frameOff = 4,
			frameOn = 3
		})
	scrollViewGroup:insert(myChargeRadio)
	myChargeRadio.anchorX = 0
	myChargeRadio.anchorY = 0
	myChargeRadio:scale(0.5,0.5)
-- 顯示文字-我付全額
	local myChargeText = display.newText({
		text = "我付全額",
		font = getFont.font,
		fontSize = 12,
	})
	scrollViewGroup:insert(myChargeText)
	myChargeText:setFillColor(unpack(wordColor))
	myChargeText.anchorX = 0
	myChargeText.x = -ox+ceil(120*wRate)
	myChargeText.y = myChargeRadio.y+myChargeRadio.contentHeight*0.6
	myChargeText.name = "myChargeText"
-- youChargeRadio
	local youChargeRadio = widget.newSwitch({
			id = "youChargeRadio",
			style = "radio",
			x = myChargeRadio.x+chargeBase.contentWidth*0.33,
			y = myChargeRadio.y,
			sheet = checkboxSheet,
			frameOff = 4,
			frameOn = 3
		})
	scrollViewGroup:insert(youChargeRadio)
	youChargeRadio.anchorX = 0
	youChargeRadio.anchorY = 0
	youChargeRadio:scale(0.5,0.5)
-- 顯示文字-你付全額
	local youChargeText = display.newText({
		text = "你付全額",
		font = getFont.font,
		fontSize = 12,
	})
	scrollViewGroup:insert(youChargeText)
	youChargeText:setFillColor(unpack(wordColor))
	youChargeText.anchorX = 0
	youChargeText.x = myChargeText.x+chargeBase.contentWidth*0.33
	youChargeText.y = myChargeText.y
	youChargeText.name = "youChargeText"
-- halfChargeRadio
	local halfChargeRadio = widget.newSwitch({
			id = "youChargeRadio",
			style = "radio",
			x = youChargeRadio.x+chargeBase.contentWidth*0.33,
			y = myChargeRadio.y,
			sheet = checkboxSheet,
			frameOff = 4,
			frameOn = 3
		})
	scrollViewGroup:insert(halfChargeRadio)
	halfChargeRadio.anchorX = 0
	halfChargeRadio.anchorY = 0
	halfChargeRadio:scale(0.5,0.5)
-- 顯示文字-一人一半
	local halfChargeText = display.newText({
		text = "一人一半",
		font = getFont.font,
		fontSize = 12,
	})
	scrollViewGroup:insert(halfChargeText)
	halfChargeText:setFillColor(unpack(wordColor))
	halfChargeText.anchorX = 0
	halfChargeText.x = youChargeText.x+chargeBase.contentWidth*0.33
	halfChargeText.y = youChargeText.y
	halfChargeText.name = "halfChargeText"
-- 費用分配監聽事件
	local function onChargeListener(event)
		local phase = event.phase
		local name = event.target.name
		if (phase == "ended") then 
			if (name == "halfChargeText") then
				halfChargeRadio:setState({
						isOn = true
					})
			elseif (name == "youChargeText") then
				youChargeRadio:setState({
						isOn = true
					})
			else
				myChargeRadio:setState({
						isOn = true
					})
			end
		end
		return true
	end
	myChargeText:addEventListener("touch", onChargeListener)
	youChargeText:addEventListener("touch", onChargeListener)
	halfChargeText:addEventListener("touch", onChargeListener)
------------------- 發送計畫邀請元件 -------------------
-- checkBox
	local invitedCheckBox = widget.newSwitch({
			id = "invitedCheckBox",
			style = "checkbox",
			x = -ox+ceil(60*wRate),
			y = chargeBase.y+chargeBase.contentHeight+ceil(60*hRate),
			sheet = checkboxSheet,
			frameOff = 2,
			frameOn = 1
		})
	scrollViewGroup:insert(invitedCheckBox)
	invitedCheckBox.anchorX = 0
	invitedCheckBox:scale(0.4,0.4)
	invitedCheckBox.y = invitedCheckBox.y+invitedCheckBox.contentHeight*0.5
-- 顯示文字-"發送計畫邀請"
 	local sentIvitationText = display.newText({
		text = "發送計畫邀請",
		font = getFont.font,
		fontSize = 12,
	})
	scrollViewGroup:insert(sentIvitationText)
	sentIvitationText:setFillColor(unpack(wordColor))
	sentIvitationText.name = "sentIvitationText"
	sentIvitationText.anchorX = 0
	sentIvitationText.anchorY = 0
	sentIvitationText.x = invitedCheckBox.x+invitedCheckBox.contentWidth+ceil(10*wRate)
	sentIvitationText.y = chargeBase.y+chargeBase.contentHeight+ceil(60*hRate)
	invitedCheckBox.y = sentIvitationText.y+sentIvitationText.contentHeight*0.5
------------------- 隱藏的邀請選單 -------------------
-- 白底-"選擇發送對象"
	invitedGroup = display.newGroup()
	scrollViewGroup:insert(invitedGroup)
	invitedGroup.isVisible = false
	local sentInvitationBase = display.newRect( cx, sentIvitationText.y+ceil(70*hRate), chargeBase.contentWidth, chargeBase.contentHeight)
	sentInvitationBase.anchorY = 0
	invitedGroup:insert(sentInvitationBase)
	--sentInvitationBase:setFillColor(1,0,0,0.3)
-- 陰影
	invitationTopShadow = display.newImage( invitedGroup, "assets/s-up.png", sentInvitationBase.x, sentInvitationBase.y)
	invitationTopShadow.anchorY = 1
	invitationTopShadow.width = sentInvitationBase.contentWidth
	invitationTopShadow.height = floor(invitationTopShadow.height*0.5)
-- 顯示文字-"選擇發送對象"
	optionTitleText["sentTarget"] = display.newText({
		text = "選擇發送對象",
		font = getFont.font,
		fontSize = 10,
	})
	invitedGroup:insert(optionTitleText["sentTarget"])
	optionTitleText["sentTarget"]:setFillColor(unpack(wordColor))
	optionTitleText["sentTarget"].anchorX = 0
	optionTitleText["sentTarget"].anchorY = 0
	optionTitleText["sentTarget"].x = -ox+ceil(60*wRate)
	optionTitleText["sentTarget"].y = sentInvitationBase.y+ceil(20*hRate)
-- 有計畫的checkBox
	local plannedChexkBox = widget.newSwitch({
			id = "plannedChexkBox",
			style = "checkbox",
			x = -ox+ceil(60*wRate),
			y = optionTitleText["sentTarget"].y+optionTitleText["sentTarget"].contentHeight+ceil(20*hRate),
			sheet = checkboxSheet,
			frameOff = 2,
			frameOn = 1
		})
	invitedGroup:insert(plannedChexkBox)
	plannedChexkBox.anchorX = 0
	plannedChexkBox:scale(0.4,0.4)
	plannedChexkBox.y = plannedChexkBox.y+plannedChexkBox.contentHeight*0.5
-- 顯示文字-"有設定去該國家地區旅行計畫的用戶"
	local plannedTargetText = display.newText({
		text = "有設定去該國家地區旅行計畫的用戶",
		font = getFont.font,
		fontSize = 12,
	})
	invitedGroup:insert(plannedTargetText)
	plannedTargetText:setFillColor(unpack(wordColor))
	plannedTargetText.name = "plannedTargetText"
	plannedTargetText.anchorX = 0
	plannedTargetText.anchorY = 0
	plannedTargetText.x = plannedChexkBox.x+plannedChexkBox.contentWidth+ceil(10*wRate)
	plannedTargetText.y = optionTitleText["sentTarget"].y+optionTitleText["sentTarget"].contentHeight+ceil(20*hRate)
	plannedChexkBox.y = plannedTargetText.y+plannedTargetText.contentHeight*0.5
-- 有設定去該國家地區旅行計畫的用戶監聽事件
	local function plannedListener( event )
		local phase = event.phase
		if (phase == "began") then
			if (plannedChexkBox.isOn == false) then
				plannedChexkBox.isOn = true
				plannedChexkBox:setState({
						isOn = true,
						--onComplete = onBtnListener
					})
			else
				plannedChexkBox.isOn = false
				plannedChexkBox:setState({
						isOn = false,
						--onComplete = onBtnListener
					})
			end
		end
		return true
	end
	plannedTargetText:addEventListener("touch", plannedListener)
-- 白底-"設定搜尋條件"
	local setConditionBase = display.newRect( cx, sentInvitationBase.y+sentInvitationBase.contentHeight, sentInvitationBase.contentWidth, sentInvitationBase.contentHeight)
	setConditionBase.anchorY = 0
	invitedGroup:insert(setConditionBase)
	--setConditionBase:setFillColor(0,1,0,0.3)
-- 顯示文字-"設定搜尋條件"
	optionTitleText["setCondition"] = display.newText({
		text = "設定搜尋條件",
		font = getFont.font,
		fontSize = 10,
	})
	invitedGroup:insert(optionTitleText["setCondition"])
	optionTitleText["setCondition"]:setFillColor(unpack(wordColor))
	optionTitleText["setCondition"].anchorX = 0
	optionTitleText["setCondition"].anchorY = 0
	optionTitleText["setCondition"].x = -ox+ceil(60*wRate)
	optionTitleText["setCondition"].y = setConditionBase.y+ceil(20*hRate)
-- 顯示文字-性別
	showedWord["gender"] = display.newText({
		text = "性別",
		font = getFont.font,
		fontSize = 10,
	})
	invitedGroup:insert(showedWord["gender"])
	showedWord["gender"]:setFillColor(unpack(wordColor))
	showedWord["gender"].anchorX = 0
	showedWord["gender"].x = -ox+ceil(60*wRate)
	showedWord["gender"].y = optionTitleText["setCondition"].y+optionTitleText["setCondition"].contentHeight+ceil(20*hRate)+showedWord["gender"].contentHeight*0.5
-- 性別底線
	local genderBaseLine = display.newLine( showedWord["gender"].x+showedWord["gender"].contentWidth+ceil(10*wRate), setConditionBase.y+setConditionBase.contentHeight*0.9, -ox+ceil(screenW*0.47), setConditionBase.y+setConditionBase.contentHeight*0.9)
	invitedGroup:insert(genderBaseLine)
	genderBaseLine:setStrokeColor(unpack(separateLineColor))
	genderBaseLine.strokeWidth = 1
-- 性別觸發監聽事件用背景
	local genderBase = display.newRect( invitedGroup, genderBaseLine.x+genderBaseLine.contentWidth*0.5, 0, genderBaseLine.contentWidth, setConditionBase.contentHeight*0.5)
	--genderBase:setFillColor( 1, 0, 0, 0.3)
	genderBase.anchorY = 1
	genderBase.y = genderBaseLine.y
	genderBase.name = "gender"
-- 顯示文字-不拘
	local showGenderText = display.newText({
		text = "不拘",
		font = getFont.font,
		fontSize = 14,
	})
	invitedGroup:insert(showGenderText)
	showGenderText:setFillColor(unpack(wordColor))
	showGenderText.anchorX = 0
	showGenderText.x = genderBaseLine.x+genderBaseLine.contentWidth*0.33
	showGenderText.y = showedWord["gender"].y
-- 性別箭頭
	arrow["gender"] = display.newImageRect("assets/btn-dropdown.png", 256, 168)
	invitedGroup:insert(arrow["gender"])
	arrow["gender"].width = arrow["gender"].width*0.05
	arrow["gender"].height = arrow["gender"].height*0.05
	arrow["gender"].x = -ox+(screenW+ox+ox)*0.45
	arrow["gender"].y = showedWord["gender"].y
	setStatus["genderArrow"] = "down"
-- 顯示文字-語言
	showedWord["language"] = display.newText({
		text = "語言",
		font = getFont.font,
		fontSize = 10,
	})
	invitedGroup:insert(showedWord["language"])
	showedWord["language"]:setFillColor(unpack(wordColor))
	showedWord["language"].anchorX = 0
	showedWord["language"].x = arrow["gender"].x+arrow["gender"].contentWidth+ceil(20*wRate)
	showedWord["language"].y = showedWord["gender"].y
-- 語言底線
	local languageBaseLine = display.newLine( showedWord["language"].x+showedWord["language"].contentWidth+ceil(10*wRate), setConditionBase.y+setConditionBase.contentHeight*0.9, -ox+ceil(screenW*0.92), setConditionBase.y+setConditionBase.contentHeight*0.9 )
	invitedGroup:insert(languageBaseLine)
	languageBaseLine:setStrokeColor(unpack(separateLineColor))
	languageBaseLine.strokeWidth = 1
-- 語言觸發監聽事件用背景
	local languageBase = display.newRect( invitedGroup, languageBaseLine.x+languageBaseLine.contentWidth*0.5, 0, languageBaseLine.contentWidth, setConditionBase.contentHeight*0.5)
	languageBase.anchorY = 1
	languageBase.y = languageBaseLine.y
	languageBase.name = "language"
-- 顯示文字-不拘
	local showLanguageText = display.newText({
		text = "不拘",
		font = getFont.font,
		fontSize = 14,
	})
	invitedGroup:insert(showLanguageText)
	showLanguageText:setFillColor(unpack(wordColor))
	showLanguageText.anchorX = 0
	showLanguageText.x = languageBaseLine.x+languageBaseLine.contentWidth*0.33
	showLanguageText.y = showedWord["language"].y
-- 語言箭頭
	arrow["language"] = display.newImageRect("assets/btn-dropdown.png", 256, 168)
	invitedGroup:insert(arrow["language"])
	arrow["language"].width = arrow["language"].width*0.05
	arrow["language"].height = arrow["language"].height*0.05
	arrow["language"].x = -ox+(screenW+ox+ox)*0.9
	arrow["language"].y = showedWord["language"].y
	setStatus["languageArrow"] = "down"
-- 搜尋條件監聽事件
	local genderGroup, languageGroup
	local function targetSearch( event )
		local name = event.target.name
		local phase = event.phase
		if (name == "gender") then
			if (setStatus["genderArrow"] == "down") then 
				setStatus["genderArrow"] = "up"
				arrow["gender"]:rotate(180)
				genderBaseLine.strokeWidth = 2
				genderBaseLine:setStrokeColor(unpack(subColor1))
				showedWord["gender"]:setFillColor(unpack(subColor1))
				genderGroup.isVisible = true
			else
				setStatus["genderArrow"] = "down"
				arrow["gender"]:rotate(180)
				genderBaseLine.strokeWidth = 1
				genderBaseLine:setStrokeColor(unpack(separateLineColor))
				showedWord["gender"]:setFillColor(unpack(wordColor))
				genderGroup.isVisible = false
			end
		end
		if (name == "language") then
			if (setStatus["languageArrow"] == "down") then 
				setStatus["languageArrow"] = "up"
				arrow["language"]:rotate(180)
				languageBaseLine.strokeWidth = 2
				languageBaseLine:setStrokeColor(unpack(subColor1))
				showedWord["language"]:setFillColor(unpack(subColor1))
				languageGroup.isVisible = true
			else
				setStatus["languageArrow"] = "down"
				arrow["language"]:rotate(180)
				languageBaseLine.strokeWidth = 1
				languageBaseLine:setStrokeColor(unpack(separateLineColor))
				showedWord["language"]:setFillColor(unpack(wordColor))
				languageGroup.isVisible = false
			end
		end
		return true
	end
	genderBase:addEventListener("tap",targetSearch)
	languageBase:addEventListener("tap",targetSearch)
-- 白底-"勾選發送對象"
	local checkTargetBase = display.newRect( cx, setConditionBase.y+setConditionBase.contentHeight, setConditionBase.contentWidth, setConditionBase.contentHeight*2.2)
	checkTargetBase.anchorY = 0
	invitedGroup:insert(checkTargetBase)
	--checkTargetBase:setFillColor(1,0,0,0.3)
-- 陰影
	local invitationBottomShadow = display.newImage( invitedGroup, "assets/s-down.png", checkTargetBase.x, checkTargetBase.y+checkTargetBase.contentHeight)
	invitationBottomShadow.anchorY = 0
	invitationBottomShadow.width = checkTargetBase.contentWidth
	invitationBottomShadow.height = floor(invitationBottomShadow.height*0.5)
-- 顯示文字-"勾選發送對象"
	optionTitleText["checkTarget"] = display.newText({
		text = "勾選發送對象",
		font = getFont.font,
		fontSize = 10,
	})
	invitedGroup:insert(optionTitleText["checkTarget"])
	optionTitleText["checkTarget"]:setFillColor(unpack(wordColor))
	optionTitleText["checkTarget"].anchorX = 0
	optionTitleText["checkTarget"].anchorY = 0
	optionTitleText["checkTarget"].x = -ox+ceil(60*wRate)
	optionTitleText["checkTarget"].y = checkTargetBase.y+ceil(20*hRate)
-- 頭像方框ScrollView
	local targetBaseScrollView = widget.newScrollView({
			id = "targetBaseScrollView",
			width = screenW+ox+ox,
			height = screenH*0.125,
			verticalScrollDisabled = true,
			--backgroundColor = { 1, 0, 0, 0.3},
		})
	invitedGroup:insert(targetBaseScrollView)
	targetBaseScrollView.x = cx
	targetBaseScrollView.y = optionTitleText["checkTarget"].y+optionTitleText["checkTarget"].contentHeight+20*hRate+targetBaseScrollView.contentHeight*0.5
-- 頭像方框監聽事件
	local targetCheckBox = {}
	local function targetPhotoListener(event)
		local phase = event.phase
		local id = event.target.id
		if (phase == "ended") then
			if (targetCheckBox[id].isOn == false) then
				targetCheckBox[id].isOn = true
				targetCheckBox[id]:setState({
						isOn = true,
						--onComplete = onBtnListener
					})
			else
				targetCheckBox[id].isOn = false
				targetCheckBox[id]:setState({
						isOn = false,
						--onComplete = onBtnListener
					})
			end
		end
		if (phase == "moved") then
			local dx = math.abs(event.xStart-event.x)
			local dy = math.abs(event.yStart-event.y)
			if (dx > 10 or dy > 0 ) then 
				targetBaseScrollView:takeFocus(event)
			end
		end
		return true
	end
-- 頭像方框+checkbox
	local xPadding = 10
	for i=1, 10 do 
		local targetBase = display.newRect(0,0, screenH*0.125, screenH*0.125)
		targetBaseScrollView:insert(targetBase)
		--targetBase:setFillColor(unpack(wordColor))
		targetBase.id = i
		targetBase.x = ceil(targetBaseScrollView.contentWidth*0.12)+(targetBase.contentWidth+xPadding)*(i-1)
		targetBase.y = targetBaseScrollView.contentHeight*0.5
		targetBase.fill = { type = "image", filename = "assets/wow.jpg"}
		targetBase:addEventListener("touch", targetPhotoListener)
		targetCheckBox[i] = widget.newSwitch({
				id = "targetCheckBox",
				style = "checkbox",
				sheet = checkboxSheet,
				frameOff = 2,
				frameOn = 1
			})
		targetBaseScrollView:insert(targetCheckBox[i])
		targetCheckBox[i]:scale(0.4,0.4)
		targetCheckBox[i].anchorX = 1
		targetCheckBox[i].anchorY = 0
		targetCheckBox[i].x = (targetBase.x+targetBase.contentWidth*0.5)
		targetCheckBox[i].y = targetBase.y-targetBase.contentHeight*0.5
	end
------------------- 確認添加按鈕元件 -------------------
-- 按鈕
	local confirmAddBtn = widget.newButton({
			id = "confirmAddBtn",
			defaultFile = "assets/btn-order.png",
 			width =  451,
 			height =  120,
		})
	scrollViewGroup:insert(confirmAddBtn)
	confirmAddBtn.width = screenW+ox+ox
	confirmAddBtn.height = math.floor(confirmAddBtn.height/3)
	confirmAddBtn.x = confirmAddBtn.contentWidth*0.5
	confirmAddBtn.y = checkTargetBase.y+checkTargetBase.contentHeight+ceil(20*hRate)+confirmAddBtn.contentHeight*0.5
-- 顯示文字-+確認添加
	local confirmAddText = display.newText({
		text = "+確認添加",
		font = getFont.font,
		fontSize = 18,
	})
	scrollViewGroup:insert(confirmAddText)
	confirmAddText.x = confirmAddBtn.x
	confirmAddText.y = confirmAddBtn.y
-- backgroundScrollView Ended Base
	local endedBase = display.newRect(scrollViewGroup, cx, confirmAddBtn.y+confirmAddBtn.contentHeight*0.5+ceil(10*hRate), backgroundScrollView.contentHeight, screenH*0.05)
	scrollViewGroup:insert(endedBase)
	endedBase.isVisible = false
------------------- 性別下拉式選單 -------------------
-- 選單大小
	genderGroup = display.newGroup()
	scrollViewGroup:insert(genderGroup)
	-- 外框
	dropDownShadow["genderSelection"] = display.newImageRect( "assets/shadow-320480.png", genderBaseLine.contentWidth, screenH/4)
	genderGroup:insert(dropDownShadow["genderSelection"])
	dropDownShadow["genderSelection"].anchorY = 0
	dropDownShadow["genderSelection"].x = genderBaseLine.x+genderBaseLine.contentWidth*0.45
	dropDownShadow["genderSelection"].y = genderBaseLine.y+genderBaseLine.strokeWidth
	local genderTextBaseHeight = dropDownShadow["genderSelection"].contentHeight/3
	-- 選項用的ScrollView
	local genderScrollView = widget.newScrollView({
			id = "genderScrollView",
			width = dropDownShadow["genderSelection"].contentWidth*0.85,
			height = dropDownShadow["genderSelection"].contentHeight*0.935,
			horizontalScrollDisabled = true,
			isBounceEnabled = false,			
		})
	genderGroup:insert(genderScrollView)
	genderScrollView.anchorY = 0
	genderScrollView.x = dropDownShadow["genderSelection"].x
	genderScrollView.y = dropDownShadow["genderSelection"].y
-- 監聽事件
	local genderText = {}
	selected["genderTarget"], selected["preGenderTarget"] = nil, nil
	selected["gender"] = false
	local function genderTextListener( event )
		local phase = event.phase
		-- 按壓選項時選項及背景會變色
		if (phase == "began") then
			if (selected["genderTarget"] == nil) then
				-- 第一次選擇選項，選項字體跟背景變色
				event.target:setFillColor( 0, 0, 0, 0.1)
				genderText[event.target.id]:setFillColor(unpack(subColor1))
				selected["genderTarget"] = event.target
			end
			if ( selected["genderTarget"] ~= nil and event.target ~= selected["genderTarget"] ) then
				-- 當選定選項後，要再更改選項
				selected["preGenderTarget"] = selected["genderTarget"]
				selected["preGenderTarget"]:setFillColor(1)
				genderText[selected["preGenderTarget"].id]:setFillColor(unpack(wordColor))

				event.target:setFillColor( 0, 0, 0, 0.1)
				genderText[event.target.id]:setFillColor(unpack(subColor1))
				selected["genderTarget"] = event.target
			end
		end
		if (phase == "moved") then
			-- 拖曳時判定是移動ScrollView
			local dy = math.abs(event.yStart-event.y)
			local dx = math.abs(event.xStart-event.x)
			if (dy > 10 or dx > 0 ) then
				genderScrollView:takeFocus(event)
			end
			if (event.target == selected["genderTarget"] and selected["preGenderTarget"] == nil ) then
				-- 尚未選定選項進行拖曳動作，取消選項判定
				event.target:setFillColor(1)
				genderText[event.target.id]:setFillColor(unpack(wordColor))
				selected["genderTarget"] = nil
			elseif (event.target == selected["genderTarget"] and event.target == selected["preGenderTarget"] ) then
				-- 當選項有選定過再進行選單移動，保持選項維持被選狀態
				event.target:setFillColor( 0, 0, 0, 0.1)
				genderText[event.target.id]:setFillColor(unpack(subColor1))	
			elseif (selected["startDay"] == true) then
				-- 選項有選定過，有觸碰其他選項時進行移動，回到原被選定的選項
				event.target:setFillColor(1)
				genderText[event.target.id]:setFillColor(unpack(wordColor))

				selected["preGenderTarget"]:setFillColor( 0, 0, 0, 0.1)
				genderText[selected["preGenderTarget"].id]:setFillColor(unpack(subColor1))
				selected["genderTarget"] = selected["preGenderTarget"]				
			end
		end
		if (phase == "ended") then
			selected["preGenderTarget"] = selected["genderTarget"]
			selected["gender"] = true
			-- 選項被選定後執行的動作
			arrow["gender"]:rotate(180)
			setStatus["genderArrow"] = "down"
			showGenderText.text = genderText[event.target.id].text
			genderGroup.isVisible = false
			showedWord["gender"]:setFillColor(unpack(wordColor))
			genderBaseLine:setStrokeColor(unpack(separateLineColor))
			genderBaseLine.strokeWidth = 1
		end
		return true
	end
-- 選單內容
	local genderOption = { "不拘", "男性", "女性"}
	for i=1, #genderOption do
		local genderTextBase = display.newRect( genderScrollView.contentWidth*0.5, (genderScrollView.contentHeight*0.5)-(((#genderOption-1)/2)*genderTextBaseHeight)+(genderTextBaseHeight*(i-1)), genderScrollView.contentWidth, genderTextBaseHeight)
		genderScrollView:insert(genderTextBase)
		genderTextBase.id = i
		genderTextBase:addEventListener("touch",genderTextListener)
		genderText[i] = display.newText({
					text = genderOption[i],
					font = getFont.font,
					fontSize = 16,
				})
		genderScrollView:insert(genderText[i])
		genderText[i]:setFillColor(unpack(wordColor))
		genderText[i].x = genderScrollView.contentWidth/2
		genderText[i].y = genderTextBase.y
	end
	genderGroup.isVisible = false
------------------- 語言下拉式選單 -------------------
-- 選單大小
	languageGroup = display.newGroup()
	scrollViewGroup:insert(languageGroup)
	-- 陰影
	dropDownShadow["languageSelection"] = display.newImageRect( "assets/shadow-320480.png", genderBaseLine.contentWidth, screenH/4)
	languageGroup:insert(dropDownShadow["languageSelection"])
	dropDownShadow["languageSelection"].anchorY = 0
	dropDownShadow["languageSelection"].x = languageBaseLine.x+languageBaseLine.contentWidth*0.45
	dropDownShadow["languageSelection"].y = languageBaseLine.y+languageBaseLine.strokeWidth
	local languageTextBaseHeight = dropDownShadow["languageSelection"].contentHeight/4
	local languageTextBasePadding = languageTextBaseHeight*0.5
	-- 選項用的ScrollView
	local languageScrollView = widget.newScrollView({
			id = "languageScrollView",
			width = dropDownShadow["languageSelection"].contentWidth*0.85,
			height = dropDownShadow["languageSelection"].contentHeight*0.935,
			horizontalScrollDisabled = true,
			isBounceEnabled = false,			
		})
	languageGroup:insert(languageScrollView)
	languageScrollView.anchorY = 0
	languageScrollView.x = dropDownShadow["languageSelection"].x
	languageScrollView.y = dropDownShadow["languageSelection"].y
-- 監聽事件
	local languageText = {}
	selected["languageTarget"], selected["preLanguageTarget"] = nil, nil
	selected["language"] = false
	local function languageTextListener( event )
		local phase = event.phase
		-- 按壓選項時選項及背景會變色
		if (phase == "began") then
			if (selected["languageTarget"] == nil) then
				-- 第一次選擇選項，選項字體跟背景變色
				event.target:setFillColor( 0, 0, 0, 0.1)
				languageText[event.target.id]:setFillColor(unpack(subColor1))
				selected["languageTarget"] = event.target
			end
			if ( selected["languageTarget"] ~= nil and event.target ~= selected["languageTarget"] ) then
				-- 當選定選項後，要再更改選項
				selected["preLanguageTarget"] = selected["languageTarget"]
				selected["preLanguageTarget"]:setFillColor(1)
				languageText[selected["preLanguageTarget"].id]:setFillColor(unpack(wordColor))

				event.target:setFillColor( 0, 0, 0, 0.1)
				languageText[event.target.id]:setFillColor(unpack(subColor1))
				selected["languageTarget"] = event.target
			end
		end
		if (phase == "moved") then
			-- 拖曳時判定是移動ScrollView
			local dy = math.abs(event.yStart-event.y)
			local dx = math.abs(event.xStart-event.x)
			if (dy > 10 or dx > 0 ) then
				languageScrollView:takeFocus(event)
			end
			if (event.target == selected["languageTarget"] and selected["preLanguageTarget"] == nil ) then
				-- 尚未選定選項進行拖曳動作，取消選項判定
				event.target:setFillColor(1)
				languageText[event.target.id]:setFillColor(unpack(wordColor))
				selected["languageTarget"] = nil
			elseif (event.target == selected["languageTarget"] and event.target == selected["preLanguageTarget"] ) then
				-- 當選項有選定過再進行選單移動，保持選項維持被選狀態
				event.target:setFillColor( 0, 0, 0, 0.1)
				languageText[event.target.id]:setFillColor(unpack(subColor1))	
			elseif (selected["startDay"] == true) then
				-- 選項有選定過，有觸碰其他選項時進行移動，回到原被選定的選項
				event.target:setFillColor(1)
				languageText[event.target.id]:setFillColor(unpack(wordColor))

				selected["preLanguageTarget"]:setFillColor( 0, 0, 0, 0.1)
				languageText[selected["preLanguageTarget"].id]:setFillColor(unpack(subColor1))
				selected["languageTarget"] = selected["preLanguageTarget"]				
			end
		end
		if (phase == "ended") then
			selected["preLanguageTarget"] = selected["languageTarget"]
			selected["language"] = true
			-- 選項被選定後執行的動作
			arrow["language"]:rotate(180)
			setStatus["languageArrow"] = "down"
			showLanguageText.text = languageText[event.target.id].text
			languageGroup.isVisible = false
			showedWord["language"]:setFillColor(unpack(wordColor))
			languageBaseLine:setStrokeColor(unpack(separateLineColor))
			languageBaseLine.strokeWidth = 1
		end
		return true
	end
-- 選單內容
	local languageOption = {"不拘", "中文", "英語", "日語", "韓語", "泰語", "俄語", "葡萄牙語", "拉丁語"}
	for i=1, #languageOption do 
		local languageTextBase = display.newRect( languageScrollView.contentWidth*0.5, languageTextBasePadding+languageTextBaseHeight*(i-1), languageScrollView.contentWidth, languageTextBaseHeight)
		languageScrollView:insert(languageTextBase)
		languageTextBase.id = i
		languageTextBase:addEventListener("touch", languageTextListener)
		languageText[i] = display.newText({
					text = languageOption[i],
					font = getFont.font,
					fontSize = 16,
				})
		languageScrollView:insert(languageText[i])
		languageText[i]:setFillColor(unpack(wordColor))
		languageText[i].x = languageScrollView.contentWidth/2
		languageText[i].y = languageTextBase.y
	end
	languageGroup.isVisible = false
------------------- 發送計畫邀請元件監聽事件 -------------------
-- 發送計畫邀請checkbox監聽事件
	local function sentIvitationChekBoxListener( event )
		local phase = event.phase
		if (phase == "ended") then
			if (event.target.isOn == true) then
				invitedGroup.isVisible = true
			else
				invitedGroup.isVisible = false
				if (plannedChexkBox.isOn == true) then
					plannedChexkBox.isOn = false
					plannedChexkBox:setState({
						isOn = false,
						--onComplete = onBtnListener
					})
				end
				if (genderGroup.isVisible == true) then 
					genderGroup.isVisible  =false
					showedWord["gender"]:setFillColor(unpack(wordColor))
					arrow["gender"]:rotate(180)
					setStatus["genderArrow"] = "down"
					genderBaseLine.strokeWidth = 1
					genderBaseLine:setStrokeColor(unpack(separateLineColor))
				end
				if (languageGroup.isVisible == true) then
					languageGroup.isVisible = false
					showedWord["language"]:setFillColor(unpack(wordColor))
					arrow["language"]:rotate(180)
					setStatus["languageArrow"] = "down"
					languageBaseLine.strokeWidth = 1
					languageBaseLine:setStrokeColor(unpack(separateLineColor))
				end
			end
		end
		return true
	end
	invitedCheckBox:addEventListener("touch", sentIvitationChekBoxListener)
-- 發送計畫邀請監聽事件
	local function sentIvitationListener( event )
		local phase = event.phase
		if (phase == "ended") then
			if (invitedCheckBox.isOn == false) then
				invitedCheckBox.isOn = true
				invitedCheckBox:setState({
						isOn = true,
						onComplete = sentIvitationChekBoxListener
					})
			else
				invitedCheckBox.isOn = false
				invitedCheckBox:setState({
						isOn = false,
						onComplete = sentIvitationChekBoxListener
					})
			end
		end
		return true
	end
	sentIvitationText:addEventListener("touch",sentIvitationListener)
------------------- 回程日期下拉式選單 -------------------
-- 日選單
	backDateDayGroup = display.newGroup()
	scrollViewGroup:insert(backDateDayGroup)
-- 選單外框
	dropDownShadow["backDaySelection"] = display.newImageRect( "assets/shadow-320480.png", backDateMonthBase.contentWidth*0.8, screenH*0.4)
	backDateDayGroup:insert(dropDownShadow["backDaySelection"])
	dropDownShadow["backDaySelection"].anchorY = 0
	dropDownShadow["backDaySelection"].x = ceil(backDateBase.contentWidth*0.765)
	dropDownShadow["backDaySelection"].y = backDateBaseLine.y+backDateBaseLine.strokeWidth
	local bDayTextBaseHeight = dropDownShadow["backDaySelection"].contentHeight/4
	local bDayTextBasePadding = bDayTextBaseHeight*0.5
-- 選單ScrollView
	local backDateDayScrollView = widget.newScrollView({
			id = "backDateDayScrollView",
			width = dropDownShadow["backDaySelection"].contentWidth*0.95,
			height = dropDownShadow["backDaySelection"].contentHeight*59/60,
			horizontalScrollDisabled = true,
			isBounceEnabled = false,
		})
	backDateDayGroup:insert(backDateDayScrollView)
	backDateDayScrollView.anchorY = 0
	backDateDayScrollView.x = dropDownShadow["backDaySelection"].x
	backDateDayScrollView.y = dropDownShadow["backDaySelection"].y
-- 日選單選項監聽事件
	local backDayText = {}
	selected["backDayTarget"], selected["preBackDayTarget"] = nil, nil
	selected["backDay"] = false
	local function backDayTextListener( event )
		local phase = event.phase
		-- 按壓選項時選項及背景會變色
		if (phase == "began") then
			if (selected["backDayTarget"] == nil and event.target.name == "selectable") then
				-- 第一次選擇選項，選項字體跟背景變色
				event.target:setFillColor( 0, 0, 0, 0.1)
				backDayText[event.target.id]:setFillColor(unpack(subColor1))
				selected["backDayTarget"] = event.target
			end
			if ( selected["backDayTarget"] ~= nil and event.target ~= selected["backDayTarget"] and event.target.name == "selectable") then
				-- 當選定選項後，要再更改選項
				selected["preBackDayTarget"] = selected["backDayTarget"]
				selected["preBackDayTarget"]:setFillColor(1)
				backDayText[selected["preBackDayTarget"].id]:setFillColor(unpack(wordColor))

				event.target:setFillColor( 0, 0, 0, 0.1)
				backDayText[event.target.id]:setFillColor(unpack(subColor1))
				selected["backDayTarget"] = event.target
			end
		end
		if (phase == "moved") then
			-- 拖曳時判定是移動ScrollView
			local dy = math.abs(event.yStart-event.y)
			local dx = math.abs(event.xStart-event.x)
			if (dy > 10 or dx > 0 ) then
				backDateDayScrollView:takeFocus(event)
			end
			if (event.target == selected["backDayTarget"] and selected["preBackDayTarget"] == nil and event.target.name == "selectable") then
				-- 尚未選定選項進行拖曳動作，取消選項判定
				event.target:setFillColor(1)
				backDayText[event.target.id]:setFillColor(unpack(wordColor))
				selected["backDayTarget"] = nil
			elseif (event.target == selected["backDayTarget"] and event.target == selected["preBackDayTarget"] and event.target.name == "selectable") then
				-- 當選項有選定過再進行選單移動，保持選項維持被選狀態
				event.target:setFillColor( 0, 0, 0, 0.1)
				backDayText[event.target.id]:setFillColor(unpack(subColor1))	
			elseif (selected["startDay"] == true) then
				-- 選項有選定過，有觸碰其他選項時進行移動，回到原被選定的選項
				if (event.target.name == "selectable") then
					event.target:setFillColor(1)
					backDayText[event.target.id]:setFillColor(unpack(wordColor))

					selected["preBackDayTarget"]:setFillColor( 0, 0, 0, 0.1)
					backDayText[selected["preBackDayTarget"].id]:setFillColor(unpack(subColor1))
					selected["backDayTarget"] = selected["preBackDayTarget"]
				end					
			end
		end
		if (phase == "ended") then
			if (event.target.name == "selectable") then
				selected["preBackDayTarget"] = selected["backDayTarget"]
				selected["backDay"] = true
				-- 選項被選定後執行的動作
				arrow["backDay"]:rotate(180)
				setStatus["backDateDayArrow"] = "down"
				setStatus["backDateDayBase"] = "off"
				backDateDaySelectedText.text = backDayText[event.target.id].text
				backDateDayGroup.isVisible = false
				if( setStatus["backDateYearBase"] == "off" and setStatus["backDateMonthBase"] == "off") then 
					optionTitleText["backDate"]:setFillColor(unpack(wordColor))
					backDateBaseLine:setStrokeColor(unpack(separateLineColor))
					backDateBaseLine.strokeWidth = 1
				end
			end
		end
		return true
	end
-- 日選單選項-現實時間
-- 產生回程日期顯示月份的日期
	local thisYear = tonumber(thisDate.thisYear)
	local thisMonth = tonumber(thisDate.thisMonth)
	local febDay
	if ( thisYear%400 == 0 or (thisYear%4 ==0 and thisYear%100 ~= 0) ) then 
		febDay = 29
	else
		febDay = 28
	end
	local daysOfMonthOption = { 31, febDay, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31}
	local backDaysOfBackMonth = daysOfMonthOption[thisMonth]
	local backTimeDays = {}
	for i=1,backDaysOfBackMonth do
		if ( i<10) then 
			backTimeDays[i] = tostring("0")..tostring(i)
		else
			backTimeDays[i] = tostring(i)
		end
	end
-- 建立日選單選項
	local yOfThisDay
	for i=1, #backTimeDays do
		-- 觸碰用背景
		local backDayTextBase = display.newRect( backDateDayScrollView.contentWidth/2, bDayTextBasePadding+(bDayTextBaseHeight*(i-1)), backDateDayScrollView.contentWidth, bDayTextBaseHeight)
		backDateDayScrollView:insert(backDayTextBase)
		backDayTextBase.id = i
		backDayTextBase:addEventListener("touch",backDayTextListener)
		-- 日期選項
		backDayText[i] = display.newText({
					text = backTimeDays[i],
					font = getFont.font,
					fontSize = 18,
				})
		backDateDayScrollView:insert(backDayText[i])
		backDayText[i].x = backDateDayScrollView.contentWidth/2
		backDayText[i].y = backDayTextBase.y
		-- 判定當月已經過的日期
		if ( backDateYearSelectedText.text == thisDate.thisYear and backDateMonthSelectedText.text == thisDate.thisMonth and i<tonumber(thisDate.thisDay)) then 
			backDayText[i]:setFillColor(unpack(separateLineColor))
			backDayTextBase.name = "unselectable"
		else
			backDayText[i]:setFillColor(unpack(wordColor))
			backDayTextBase.name = "selectable"
		end
		-- 判定日選項的日期
		if ( backDateYearSelectedText.text == thisDate.thisYear and backDateMonthSelectedText.text == thisDate.thisMonth) then
			backDateDaySelectedText.text = thisDate.thisDay
		else
			backDateDaySelectedText.text = backTimeDays[1]
		end
		-- 判斷ScrollView選項的位置
		local baseDay
		if (#backTimeDays - tonumber(thisDate.thisDay) < 3 ) then
			baseDay =  #backTimeDays - 3
		else
			baseDay = tonumber(backDateDaySelectedText.text)
		end
		if ( i == baseDay) then
			yOfThisDay = -backDayText[i].y+bDayTextBasePadding
		end
	end
	-- 將ScrollView轉到相對應的位置
	backDateDayScrollView:scrollToPosition({ 
			y = yOfThisDay,
			time = 500
		})
	backDateDayGroup.isVisible = false

-- 回程日期選單大小-月選單
	backDateMonthGroup = display.newGroup()
	scrollViewGroup:insert(backDateMonthGroup)
-- 選單外框
	dropDownShadow["backMonthSelection"] = display.newImageRect( "assets/shadow-320480.png", backDateMonthBase.contentWidth*0.8, screenH*0.4)
	backDateMonthGroup:insert(dropDownShadow["backMonthSelection"])
	dropDownShadow["backMonthSelection"].anchorY = 0
	dropDownShadow["backMonthSelection"].x = ceil(backDateBase.contentWidth*0.468)
	dropDownShadow["backMonthSelection"].y = backDateBaseLine.y+backDateBaseLine.strokeWidth
	local bMonthTextBaseHeight = dropDownShadow["backMonthSelection"].contentHeight/4
	local bMonthTextBasePadding = bMonthTextBaseHeight*0.5
-- 選單ScrollView
	local backDateMonthScrollView = widget.newScrollView({
			id = "backDateMonthScrollView",
			width = dropDownShadow["backMonthSelection"].contentWidth*0.95,
			height = dropDownShadow["backMonthSelection"].contentHeight*59/60,
			horizontalScrollDisabled = true,
			isBounceEnabled = false,
		})
	backDateMonthGroup:insert(backDateMonthScrollView)
	backDateMonthScrollView.anchorY = 0
	backDateMonthScrollView.x = dropDownShadow["backMonthSelection"].x
	backDateMonthScrollView.y = dropDownShadow["backMonthSelection"].y
-- 月選單選項監聽事件
	local backMonthText = {}
	selected["backMonthTarget"], selected["preBackMonthTarget"] = nil, nil
	selected["backMonth"] = false
	local function backMonthTextListener( event )
		local phase = event.phase
		local preSelectedMonth = backDateMonthSelectedText.text
		-- 按壓選項時選項及背景會變色
		if (phase == "began") then
			if (selected["backMonthTarget"] == nil and event.target.name == "selectable") then
				-- 第一次選擇選項，選項字體跟背景變色
				event.target:setFillColor( 0, 0, 0, 0.1)
				backMonthText[event.target.id]:setFillColor(unpack(subColor1))
				selected["backMonthTarget"] = event.target
			end
			if (selected["backMonthTarget"] ~= nil and event.target ~= selected["backMonthTarget"] and event.target.name == "selectable") then
				-- 當選定選項後，要再更改選項
				selected["preBackMonthTarget"] = selected["backMonthTarget"]
				selected["preBackMonthTarget"]:setFillColor(1)
				backMonthText[selected["preBackMonthTarget"].id]:setFillColor(unpack(wordColor))
				event.target:setFillColor( 0, 0, 0, 0.1)
				backMonthText[event.target.id]:setFillColor(unpack(subColor1))
				selected["backMonthTarget"] = event.target
			end
		end
		if (phase == "moved") then
			-- 拖曳時判定是移動ScrollView
			local dy = math.abs(event.yStart-event.y)
			local dx = math.abs(event.xStart-event.x)
			if (dy > 10 or dx > 0 ) then
				backDateMonthScrollView:takeFocus(event)
			end
			if (event.target == selected["backMonthTarget"] and selected["preBackMonthTarget"] == nil and event.target.name == "selectable") then
				-- 尚未選定選項進行拖曳動作，取消選項判定
				event.target:setFillColor(1)
				backMonthText[event.target.id]:setFillColor(unpack(wordColor))
				selected["backMonthTarget"] = nil
			elseif (event.target == selected["backMonthTarget"] and event.target == selected["preBackMonthTarget"] and event.target.name == "selectable") then
				-- 當選項有選定過再進行選單移動，保持選項維持被選狀態
				event.target:setFillColor( 0, 0, 0, 0.1)
				backMonthText[event.target.id]:setFillColor(unpack(subColor1))
			elseif (selected["startMonth"] == true) then
				-- 選項有選定過，有觸碰其他選項時進行移動，回到原被選定的選項
				event.target:setFillColor(1)
				backMonthText[event.target.id]:setFillColor(unpack(wordColor))
				selected["preBackMonthTarget"]:setFillColor( 0, 0, 0, 0.1)
				backMonthText[selected["preBackMonthTarget"].id]:setFillColor(unpack(subColor1))
				selected["backMonthTarget"] = selected["preBackMonthTarget"]						
			end
		end
		if (phase == "ended") then
			if (event.target.name == "selectable") then
				selected["preBackMonthTarget"] = selected["backMonthTarget"]
				selected["backMonth"] = true
				-- 選項被選定後執行的動作
				arrow["backMonth"]:rotate(180)
				setStatus["backDateMonthArrow"] = "down"
				setStatus["backDateMonthBase"] = "off"
				backDateMonthSelectedText.text = backMonthText[event.target.id].text
				backDateMonthGroup.isVisible = false
				backDateDayCover.isVisible = false
				if( setStatus["backDateYearBase"] == "off" and setStatus["backDateDayBase"] == "off") then 
					optionTitleText["backDate"]:setFillColor(unpack(wordColor))
					backDateBaseLine:setStrokeColor(unpack(separateLineColor))
					backDateBaseLine.strokeWidth = 1
				end
			-- 當選擇其他月份時需要換該月份相對的天數
			-- 日選單重新產生
				if ( backDateMonthSelectedText.text ~= preSelectedMonth) then
					if (backDateDayScrollView) then 
						selected["backDayTarget"] = nil
						selected["preBackDayTarget"] = nil
						selected["backDay"] = false
						backDateDayGroup:remove(backDateDayScrollView)
						backDateDayScrollView = nil
					end
			-- 回程日期選單-新日選單選項-配合月選項產生日期
					backDateDayScrollView = widget.newScrollView({
						id = "backDateDayScrollView",
						width = dropDownShadow["backDaySelection"].contentWidth*0.85,
						height = dropDownShadow["backDaySelection"].contentHeight*0.935,
						horizontalScrollDisabled = true,
						isBounceEnabled = false,
					})
					backDateDayGroup:insert(backDateDayScrollView)
					backDateDayScrollView.anchorY = 0
					backDateDayScrollView.x = dropDownShadow["backDaySelection"].x
					backDateDayScrollView.y = dropDownShadow["backDaySelection"].y
					local selectedMonth = tonumber(backDateMonthSelectedText.text)
					local daysOfSelectedMonth = daysOfMonthOption[selectedMonth]
					local selectedDays = {}
					for i=1, daysOfSelectedMonth do
						if ( i<10) then 
							selectedDays[i] = tostring("0")..tostring(i)
						else
							selectedDays[i] = tostring(i)
						end
					end
			-- 回程日期選單-建立新日選單選項
					for i=1, #selectedDays do 
						local backDayTextBase = display.newRect( backDateDayScrollView.contentWidth/2, bDayTextBasePadding+(bDayTextBaseHeight*(i-1)), backDateDayScrollView.contentWidth, bDayTextBaseHeight)
						backDateDayScrollView:insert(backDayTextBase)
						backDayTextBase.id = i
						backDayTextBase:addEventListener("touch",backDayTextListener)
						backDayText[i] = display.newText({
							text = selectedDays[i],
							font = getFont.font,
							fontSize = 18,
						})
						backDateDayScrollView:insert(backDayText[i])
						backDayText[i].x = backDateDayScrollView.contentWidth/2
						backDayText[i].y = backDayTextBase.y
						-- 判定當月已經過的日期
						if (backDateYearSelectedText.text == thisDate.thisYear and backDateMonthSelectedText.text == thisDate.thisMonth and i<tonumber(thisDate.thisDay)) then 
							backDayText[i]:setFillColor(unpack(separateLineColor))
							backDayTextBase.name = "unselectable"
						else
							backDayText[i]:setFillColor(unpack(wordColor))
							backDayTextBase.name = "selectable"
						end
						-- 判定日選項的日期
						if (backDateYearSelectedText.text == thisDate.thisYear and backDateMonthSelectedText.text == thisDate.thisMonth) then
							backDateDaySelectedText.text = thisDate.thisDay
						else
							backDateDaySelectedText.text = selectedDays[1]
						end
						-- 判斷ScrollView選項的位置
						if ( backDateYearSelectedText.text == thisDate.thisYear and backDateMonthSelectedText.text == thisDate.thisMonth) then 
							local baseDay
							if (#selectedDays - tonumber(thisDate.thisDay) < 3 ) then
								baseDay =  #selectedDays - 3
							else
								baseDay = tonumber(backDateDaySelectedText.text)
							end
							if ( i == baseDay) then
								yOfThisDay = -backDayText[i].y+bDayTextBasePadding
							end
						else
							if (i == tonumber(backDateDaySelectedText.text)) then
								yOfThisDay = -backDayText[i].y+bDayTextBasePadding
							end
						end
					end
					-- 將ScrollView轉到相對應的位置
					backDateDayScrollView:scrollToPosition( { 
							y = yOfThisDay,
							time = 500
						})
					backDateDayGroup.isVisible = false
				end
			end
		end
		return true
	end
-- 月選單選項-現實時間
	local monthOption = { "01", "02", "03", "04", "05", "06", "07", "08", "09", "10", "11", "12"}
	local yOfThisMonth
	for i=1,#monthOption do
		local backMonthTextBase = display.newRect(backDateMonthScrollView.contentWidth/2, bMonthTextBasePadding+(bMonthTextBaseHeight*(i-1)), backDateMonthScrollView.contentWidth, bMonthTextBaseHeight)
		backDateMonthScrollView:insert(backMonthTextBase)
		backMonthTextBase.id = i
		backMonthTextBase:addEventListener("touch", backMonthTextListener)
		backMonthText[i] = display.newText({
					text = monthOption[i],
					font = getFont.font,
					fontSize = 18,
				})
		backDateMonthScrollView:insert(backMonthText[i])
		backMonthText[i].x = backDateMonthScrollView.contentWidth*0.5
		backMonthText[i].y = backMonthTextBase.y
		-- 判定現實當年經過的月份
		if (backDateYearSelectedText.text == thisDate.thisYear and i<tonumber(thisDate.thisMonth)) then
			backMonthText[i]:setFillColor(unpack(separateLineColor))
			backMonthTextBase.name = "unselectable"
		else
			backMonthText[i]:setFillColor(unpack(wordColor))
			backMonthTextBase.name = "selectable"
		end
		-- 判定月選項的月份
		if ( backDateYearSelectedText.text == thisDate.thisYear) then
			backDateMonthSelectedText.text = thisDate.thisMonth
		else
			backDateMonthSelectedText.text = monthOption[1]
		end
		-- 判斷ScrollView選項的位置
		local baseMonth
		if (#monthOption - thisDate.thisMonth < 3) then 
			baseMonth = #monthOption - 3
		else
			baseMonth = tonumber(backDateMonthSelectedText.text)
		end
		if (i == baseMonth) then
			yOfThisMonth = -backMonthText[i].y+bMonthTextBasePadding
		end
	end
	-- 將ScrollView轉到相對應的位置
	backDateMonthScrollView:scrollToPosition({ 
			y = yOfThisMonth,
			time = 500
		})
	backDateMonthGroup.isVisible = false

-- 年選單
	backDateYearGroup = display.newGroup()
	scrollViewGroup:insert(backDateYearGroup)
-- 選單外框
	dropDownShadow["backYearSelection"] = display.newImageRect( "assets/shadow-320480.png", backDateYearBase.contentWidth*0.8, screenH*0.25)
	backDateYearGroup:insert(dropDownShadow["backYearSelection"])
	dropDownShadow["backYearSelection"].anchorY = 0 
	dropDownShadow["backYearSelection"].x = ceil(backDateBase.contentWidth*0.16)
	dropDownShadow["backYearSelection"].y = backDateBaseLine.y+backDateBaseLine.strokeWidth
	local bYearBaseHeight = (screenH*0.4)/4
	local bYearBasePadding = bYearBaseHeight*0.5
-- 選單ScrollView
	local backDateYearScrollView = widget.newScrollView({
			id = "backDateYearScrollView",
			width = dropDownShadow["backYearSelection"].contentWidth*0.95,
			height = dropDownShadow["backYearSelection"].contentHeight*59/60,
			horizontalScrollDisabled = true,
			isBounceEnabled = false,
		})
	backDateYearGroup:insert(backDateYearScrollView)
	backDateYearScrollView.anchorY = 0
	backDateYearScrollView.x = dropDownShadow["backYearSelection"].x
	backDateYearScrollView.y = dropDownShadow["backYearSelection"].y
-- 年選單選項監聽事件
	local backYearText = {}
	selected["backYearTarget"], selected["preBackYearTarget"] = nil, nil
	selected["backYear"] = false
	local function backYearTextListener( event )
		local phase = event.phase
		local preSelectedYear = backDateYearSelectedText.text
		-- 按壓選項時選項及背景會變色
		if (phase == "began") then
			if (selected["backYearTarget"] == nil) then
				-- 第一次選擇選項，選項字體跟背景變色
				event.target:setFillColor( 0, 0, 0, 0.1)
				backYearText[event.target.id]:setFillColor(unpack(subColor1))
				selected["backYearTarget"] = event.target
			end
			if ( selected["backYearTarget"] ~= nil and event.target ~= selected["backYearTarget"]) then
				-- 當選定選項後，要再更改選項
				selected["preBackYearTarget"] = selected["backYearTarget"]
				selected["preBackYearTarget"]:setFillColor(1)
				backYearText[selected["preBackYearTarget"].id]:setFillColor(unpack(wordColor))
				event.target:setFillColor( 0, 0, 0, 0.1)
				backYearText[event.target.id]:setFillColor(unpack(subColor1))
				selected["backYearTarget"] = event.target
			end
		end
		if (phase == "moved") then
			-- 拖曳時判定是移動ScrollView
			local dy = math.abs(event.yStart-event.y)
			local dx = math.abs(event.xStart-event.y)
			if (dy > 10 or dx > 0) then 
				backDateYearScrollView:takeFocus(event)
			end
			if (event.target == selected["backYearTarget"] and selected["preBackYearTarget"] == nil) then
				-- 尚未選定選項進行拖曳動作，取消選項判定
				event.target:setFillColor(1)
				backYearText[event.target.id]:setFillColor(unpack(wordColor))
				selected["backYearTarget"] = nil
			elseif (event.target == selected["backYearTarget"] and event.target == selected["preBackYearTarget"]) then
				-- 當選項有選定過再進行選單移動，保持選項維持被選狀態
				event.target:setFillColor( 0, 0, 0, 0.1)
				backYearText[event.target.id]:setFillColor(unpack(subColor1))				
			elseif (selected["startYear"] == true) then
				-- 選項有選定過，有觸碰其他選項時進行移動，回到原被選定的選項
				event.target:setFillColor(1)
				backYearText[event.target.id]:setFillColor(unpack(wordColor))

				selected["preBackYearTarget"]:setFillColor( 0, 0, 0, 0.1)
				backYearText[selected["preBackYearTarget"].id]:setFillColor(unpack(subColor1))
				selected["backYearTarget"] = selected["preBackYearTarget"]						
			end
		end
		if (phase == "ended") then
			selected["preBackYearTarget"] = selected["backYearTarget"]
			selected["backYear"] = true
			-- 選項被選定後執行的動作
			arrow["backYear"]:rotate(180)
			setStatus["backDateYearArrow"] = "down"
			setStatus["backDateYearBase"] = "off"
			backDateYearSelectedText.text = backYearText[event.target.id].text
			backDateYearGroup.isVisible = false
			backDateMonthCover.isVisible = false
			backDateDayCover.isVisible = false
			if( setStatus["backDateMonthBase"] == "off" and setStatus["backDateDayBase"] == "off") then 
				optionTitleText["backDate"]:setFillColor(unpack(wordColor))
				backDateBaseLine:setStrokeColor(unpack(separateLineColor))
				backDateBaseLine.strokeWidth = 1
			end
		-- 當選擇其他年份時將月份跟日期選單重置至該年的0101
			if (backDateYearSelectedText.text ~= preSelectedYear) then
			-- 回程日期年監聽事件-重置月選單
				if (backDateMonthScrollView) then 
					selected["backMonthTarget"] = nil
					selected["preBackMonthTarget"] = nil
					selected["backMonth"] = false
					backDateMonthGroup:remove(backDateMonthScrollView)
					backDateMonthScrollView = nil
					-- 配合選擇的年份再對應現實時間顯示月份
					if (backDateYearSelectedText.text == thisDate.thisYear) then
						backDateMonthSelectedText.text = thisDate.thisMonth
					else
						backDateMonthSelectedText.text = "01"
					end
					backDateMonthScrollView = widget.newScrollView({
						id = "backDateMonthScrollView",
						width = dropDownShadow["backMonthSelection"].contentWidth*0.85,
						height = dropDownShadow["backMonthSelection"].contentHeight*0.935,
						horizontalScrollDisabled = true,
						isBounceEnabled = false,
					})
					backDateMonthGroup:insert(backDateMonthScrollView)
					backDateMonthScrollView.anchorY = 0
					backDateMonthScrollView.x = dropDownShadow["backMonthSelection"].x
					backDateMonthScrollView.y = dropDownShadow["backMonthSelection"].y
					for i=1,#monthOption do
						local backMonthTextBase = display.newRect(backDateMonthScrollView.contentWidth/2, bMonthTextBasePadding+(bMonthTextBaseHeight*(i-1)), backDateMonthScrollView.contentWidth, bMonthTextBaseHeight)
						backDateMonthScrollView:insert(backMonthTextBase)
						backMonthTextBase.id = i
						backMonthTextBase:addEventListener("touch", backMonthTextListener)
						backMonthText[i] = display.newText({
								text = monthOption[i],
								font = getFont.font,
								fontSize = 18,
							})
						backDateMonthScrollView:insert(backMonthText[i])
						backMonthText[i].x = backDateMonthScrollView.contentWidth*0.5
						backMonthText[i].y = backMonthTextBase.y
						-- 判定現實當年經過的月份
						if (backDateYearSelectedText.text == thisDate.thisYear and i<tonumber(thisDate.thisMonth)) then
							backMonthText[i]:setFillColor(unpack(separateLineColor))
							backMonthTextBase.name = "unselectable"
						else
							backMonthText[i]:setFillColor(unpack(wordColor))
							backMonthTextBase.name = "selectable"
						end
						-- 判定月選項的月份
						if ( backDateYearSelectedText.text == thisDate.thisYear) then
							backDateMonthSelectedText.text = thisDate.thisMonth
						else
							backDateMonthSelectedText.text = monthOption[1]
						end
						-- 判斷ScrollView選項的位置
						if ( i == tonumber(backDateMonthSelectedText.text)) then
							yOfThisMonth = -backMonthText[i].y+bMonthTextBasePadding
						end
					end
					-- 將ScrollView轉到相對應的位置
					backDateMonthScrollView:scrollToPosition({ 
								y = yOfThisMonth,
								time = 500
							})
					backDateMonthGroup.isVisible = false
				end
			-- 回程日期年監聽事件-重置日選單
				if (backDateDayScrollView) then 
					selected["startDayTarget"] = nil
					selected["preStartDayTarget"] = nil
					selected["startDay"] = false
					backDateDayGroup:remove(backDateDayScrollView)
					backDateDayScrollView = nil
					-- 回程日期選單-新日選單選項-配合月選項產生日期
					backDateDayScrollView = widget.newScrollView({
						id = "backDateDayScrollView",
						width = dropDownShadow["backDaySelection"].contentWidth*0.85,
						height = dropDownShadow["backDaySelection"].contentHeight*0.935,
						horizontalScrollDisabled = true,
						isBounceEnabled = false,
					})
					backDateDayGroup:insert(backDateDayScrollView)
					backDateDayScrollView.anchorY = 0
					backDateDayScrollView.x = dropDownShadow["backDaySelection"].x
					backDateDayScrollView.y = dropDownShadow["backDaySelection"].y
					local selectedMonth = tonumber(backDateMonthSelectedText.text)
					local daysOfSelectedMonth = daysOfMonthOption[selectedMonth]
					local selectedDays = {}
					for i=1, daysOfSelectedMonth do
						if ( i<10) then 
							selectedDays[i] = tostring("0")..tostring(i)
						else
							selectedDays[i] = tostring(i)
						end
					end
					-- 回程日期選單-建立新日選單選項
					-- 重新建立日選項的日期順序
					for i=1, #selectedDays do 
						local backDayTextBase = display.newRect( backDateDayScrollView.contentWidth/2, bDayTextBasePadding+(bDayTextBaseHeight*(i-1)), backDateDayScrollView.contentWidth, bDayTextBaseHeight)
						backDateDayScrollView:insert(backDayTextBase)
						backDayTextBase.id = i
						backDayTextBase:addEventListener("touch",backDayTextListener)
						backDayText[i] = display.newText({
								text = selectedDays[i],
								font = getFont.font,
								fontSize = 18,
							})
						backDateDayScrollView:insert(backDayText[i])
						backDayText[i].x = backDateDayScrollView.contentWidth/2
						backDayText[i].y = backDayTextBase.y
						-- 判定現實當月已經過的日期
						if ( backDateYearSelectedText.text == thisDate.thisYear and backDateMonthSelectedText.text == thisDate.thisMonth and i<tonumber(thisDate.thisDay)) then 
							backDayText[i]:setFillColor(unpack(separateLineColor))
							backDayTextBase.name = "unselectable"
						else
							backDayText[i]:setFillColor(unpack(wordColor))
							backDayTextBase.name = "selectable"
						end
						-- 判定日選項的日期
						if ( backDateYearSelectedText.text == thisDate.thisYear and backDateMonthSelectedText.text == thisDate.thisMonth) then
							backDateDaySelectedText.text = thisDate.thisDay
						else
							backDateDaySelectedText.text = selectedDays[1]
						end
						-- 判斷ScrollView選項的位置
						if ( backDateYearSelectedText.text == thisDate.thisYear and backDateMonthSelectedText.text == thisDate.thisMonth) then 
							local baseDay
							if (#backTimeDays - tonumber(thisDate.thisDay) < 3 ) then
								baseDay =  #backTimeDays - 3
							else
								baseDay = tonumber(backDateDaySelectedText.text)
							end
							if ( i == baseDay) then
								yOfThisDay = -backDayText[i].y+bDayTextBasePadding
							end
						else
							if (i == tonumber(backDateDaySelectedText.text)) then
								yOfThisDay = -backDayText[i].y+bDayTextBasePadding
							end
						end
					end
					-- 將ScrollView轉到相對應的位置
					backDateDayScrollView:scrollToPosition( { 
							y = yOfThisDay,
							time = 500
						})
					backDateDayGroup.isVisible = false
				end
			end
		end
		return true
	end
-- 年選單選項-現實時間
	local yearOption = { thisYear, thisYear+1}
	local backYearTextBase
	for i=1,#yearOption do
		if (#yearOption <= 3) then
			backYearTextBase = display.newRect(backDateYearScrollView.contentWidth/2, (backDateYearScrollView.contentHeight*0.5)-((#yearOption-1)/2*bYearBaseHeight)+(bYearBaseHeight*(i-1)), backDateYearScrollView.contentWidth, bYearBaseHeight)
		else
			backYearTextBase = display.newRect(backDateYearScrollView.contentWidth/2, bYearBasePadding+(bYearBaseHeight*(i-1)), backDateYearScrollView.contentWidth, bYearBaseHeight)
		end
		backDateYearScrollView:insert(backYearTextBase)
		backYearTextBase.id = i
		backYearTextBase:addEventListener("touch", backYearTextListener)
		
		backYearText[i] = display.newText({
					text = yearOption[i],
					font = getFont.font,
					fontSize = 18,
				})
		backDateYearScrollView:insert(backYearText[i])
		backYearText[i]:setFillColor(unpack(wordColor))
		backYearText[i].x = backDateYearScrollView.contentWidth*0.5
		backYearText[i].y = backYearTextBase.y
	end
	backDateYearGroup.isVisible = false
------------------- 出發日期下拉式選單 -------------------
-- 日選單
	startDateDayGroup = display.newGroup()
	scrollViewGroup:insert(startDateDayGroup)
-- 選單外框
	dropDownShadow["startDaySelection"] = display.newImageRect( "assets/shadow-320480.png", startDateMonthBase.contentWidth*0.8, screenH*0.4)
	startDateDayGroup:insert(dropDownShadow["startDaySelection"])
	dropDownShadow["startDaySelection"].anchorY = 0
	dropDownShadow["startDaySelection"].x = ceil(startDateBase.contentWidth*0.765)
	dropDownShadow["startDaySelection"].y = startDateBaseLine.y+startDateBaseLine.strokeWidth
	local sDayTextBaseHeight = dropDownShadow["startDaySelection"].contentHeight/4
	local sDayTextBasePadding = sDayTextBaseHeight*0.5	
-- 選單ScrollView
	local startDateDayScrollView = widget.newScrollView({
			id = "startDateDayScrollView",
			width = dropDownShadow["startDaySelection"].contentWidth*0.95,
			height = dropDownShadow["startDaySelection"].contentHeight*59/60,
			horizontalScrollDisabled = true,
			isBounceEnabled = false,
		})
	startDateDayGroup:insert(startDateDayScrollView)
	startDateDayScrollView.anchorY = 0
	startDateDayScrollView.x = dropDownShadow["startDaySelection"].x
	startDateDayScrollView.y = dropDownShadow["startDaySelection"].y
-- 日選單選項監聽事件
	local strtDayText = {}
	selected["startDayTarget"], selected["preStartDayTarget"] = nil, nil
	selected["startDay"] = false
	local function strtDayTextListener( event )
		local phase = event.phase
		-- 按壓選項時選項及背景會變色
		if (phase == "began") then
			if (selected["startDayTarget"] == nil and event.target.name == "selectable") then
				-- 第一次選擇選項，選項字體跟背景變色
				event.target:setFillColor( 0, 0, 0, 0.1)
				strtDayText[event.target.id]:setFillColor(unpack(subColor1))
				selected["startDayTarget"] = event.target
			end
			if ( selected["startDayTarget"] ~= nil and event.target ~= selected["startDayTarget"] and event.target.name == "selectable") then
				-- 當選定選項後，要再更改選項
				selected["preStartDayTarget"] = selected["startDayTarget"]
				selected["preStartDayTarget"]:setFillColor(1)
				strtDayText[selected["preStartDayTarget"].id]:setFillColor(unpack(wordColor))
				event.target:setFillColor( 0, 0, 0, 0.1)
				strtDayText[event.target.id]:setFillColor(unpack(subColor1))
				selected["startDayTarget"] = event.target
			end
		end
		if (phase == "moved") then
			-- 拖曳時判定是移動ScrollView
			local dy = math.abs(event.yStart-event.y)
			local dx = math.abs(event.xStart-event.x)
			if (dy > 10 or dx > 0 ) then
				startDateDayScrollView:takeFocus(event)
			end
			if (event.target == selected["startDayTarget"] and selected["preStartDayTarget"] == nil and event.target.name == "selectable") then
				-- 尚未選定選項進行拖曳動作，取消選項判定
				event.target:setFillColor(1)
				strtDayText[event.target.id]:setFillColor(unpack(wordColor))
				selected["startDayTarget"] = nil
			elseif (event.target == selected["startDayTarget"] and event.target == selected["preStartDayTarget"] and event.target.name == "selectable") then
				-- 當選項有選定過再進行選單移動，保持選項維持被選狀態
				event.target:setFillColor( 0, 0, 0, 0.1)
				strtDayText[event.target.id]:setFillColor(unpack(subColor1))	
			elseif (selected["startDay"] == true) then
				-- 選項有選定過，有觸碰其他選項時進行移動，回到原被選定的選項
				if (event.target.name == "selectable") then
					event.target:setFillColor(1)
					strtDayText[event.target.id]:setFillColor(unpack(wordColor))
					selected["preStartDayTarget"]:setFillColor( 0, 0, 0, 0.1)
					strtDayText[selected["preStartDayTarget"].id]:setFillColor(unpack(subColor1))
					selected["startDayTarget"] = selected["preStartDayTarget"]
				end					
			end
		end
		if (phase == "ended") then
			if (event.target.name == "selectable") then
				selected["preStartDayTarget"] = selected["startDayTarget"]
				selected["startDay"] = true
				-- 選項被選定後執行的動作
				arrow["startDay"]:rotate(180)
				setStatus["startDateDayArrow"] = "down"
				setStatus["startDateDayBase"] = "off"
				startDateDaySelectedText.text = strtDayText[event.target.id].text
				startDateDayGroup.isVisible = false
				if( setStatus["startDateYearBase"] == "off" and setStatus["startDateMonthBase"] == "off") then 
					optionTitleText["startDate"]:setFillColor(unpack(wordColor))
					startDateBaseLine:setStrokeColor(unpack(separateLineColor))
					startDateBaseLine.strokeWidth = 1
				end
			end
		end
		return true
	end
-- 日選單選項-現實時間
	-- 產生當月的日期
	local daysOfThisMonth = daysOfMonthOption[thisMonth]
	local realTimeDays = {}
	for i=1, daysOfThisMonth do
		if ( i<10) then 
			realTimeDays[i] = tostring("0")..tostring(i)
		else
			realTimeDays[i] = tostring(i)
		end
	end
	-- 建立日選單選項
	for i=1,#realTimeDays do 
		-- 變色用背景
		local strtDayTextBase = display.newRect( startDateDayScrollView.contentWidth/2, sDayTextBasePadding+(sDayTextBaseHeight*(i-1)), startDateDayScrollView.contentWidth, sDayTextBaseHeight)
		startDateDayScrollView:insert(strtDayTextBase)
		strtDayTextBase.id = i
		strtDayTextBase:addEventListener("touch",strtDayTextListener)
		-- 日期選項
		strtDayText[i] = display.newText({
					text = realTimeDays[i],
					font = getFont.font,
					fontSize = 18,
				})
		startDateDayScrollView:insert(strtDayText[i])
		strtDayText[i].x = startDateDayScrollView.contentWidth/2
		strtDayText[i].y = strtDayTextBase.y
		-- 判定當月已經過的日期
		if ( startDateYearSelectedText.text == thisDate.thisYear and startDateMonthSelectedText.text == thisDate.thisMonth and i<tonumber(thisDate.thisDay)) then 
			strtDayText[i]:setFillColor(unpack(separateLineColor))
			strtDayTextBase.name = "unselectable"
		else
			strtDayText[i]:setFillColor(unpack(wordColor))
			strtDayTextBase.name = "selectable"
		end
		-- 判定日選項的日期
		if ( startDateYearSelectedText.text == thisDate.thisYear and startDateMonthSelectedText.text == thisDate.thisMonth) then
			startDateDaySelectedText.text = thisDate.thisDay
		else
			startDateDaySelectedText.text = realTimeDays[1]
		end
		-- 判斷ScrollView選項的位置
		local baseDay
		if (#realTimeDays - tonumber(thisDate.thisDay) < 3 ) then
			baseDay =  #realTimeDays - 3
		else
			baseDay = tonumber(startDateDaySelectedText.text)
		end
		if ( i == baseDay) then
			yOfThisDay = -strtDayText[i].y+sDayTextBasePadding
		end
	end
	-- 將ScrollView轉到相對應的位置
	startDateDayScrollView:scrollToPosition( { 
			y = yOfThisDay,
			time = 500
		})
	startDateDayGroup.isVisible = false

-- 月選單
	startDateMonthGroup = display.newGroup()
	scrollViewGroup:insert(startDateMonthGroup)
-- 選單外框
	dropDownShadow["startMonthSelection"] = display.newImageRect( "assets/shadow-320480.png", startDateMonthBase.contentWidth*0.9, screenH*0.4)
	startDateMonthGroup:insert(dropDownShadow["startMonthSelection"])
	dropDownShadow["startMonthSelection"].anchorY = 0
	dropDownShadow["startMonthSelection"].x = ceil(startDateBase.contentWidth*0.468)
	dropDownShadow["startMonthSelection"].y = startDateBaseLine.y+startDateBaseLine.strokeWidth
	local sMonthTextBaseHeight = dropDownShadow["startMonthSelection"].contentHeight/4
	local sMonthTextBasePadding = sMonthTextBaseHeight*0.5
-- 選單ScrollView
	local startDateMonthScrollView = widget.newScrollView({
			id = "startDateMonthScrollView",
			width = dropDownShadow["startMonthSelection"].contentWidth*0.95,
			height = dropDownShadow["startMonthSelection"].contentHeight*59/60,
			horizontalScrollDisabled = true,
			isBounceEnabled = false,
		})
	startDateMonthGroup:insert(startDateMonthScrollView)
	startDateMonthScrollView.anchorY = 0
	startDateMonthScrollView.x = dropDownShadow["startMonthSelection"].x
	startDateMonthScrollView.y = dropDownShadow["startMonthSelection"].y
-- 月選單選項監聽事件
	local strtMonthText = {}
	selected["startMonthTarget"], selected["preStartMonthTarget"] = nil, nil
	selected["startMonth"] = false
	local function strtMonthTextListener( event )
		local phase = event.phase
		local preSelectedMonth = startDateMonthSelectedText.text
		-- 按壓選項時選項及背景會變色
		if (phase == "began") then
			if (selected["startMonthTarget"] == nil and event.target.name == "selectable") then
				-- 第一次選擇選項，選項字體跟背景變色
				event.target:setFillColor( 0, 0, 0, 0.1)
				strtMonthText[event.target.id]:setFillColor(unpack(subColor1))
				selected["startMonthTarget"] = event.target
			end
			if ( selected["startMonthTarget"] ~= nil and event.target ~= selected["startMonthTarget"] and event.target.name == "selectable") then
				-- 當選定選項後，要再更改選項
				selected["preStartMonthTarget"] = selected["startMonthTarget"]
				selected["preStartMonthTarget"]:setFillColor(1)
				strtMonthText[selected["preStartMonthTarget"].id]:setFillColor(unpack(wordColor))
				event.target:setFillColor( 0, 0, 0, 0.1)
				strtMonthText[event.target.id]:setFillColor(unpack(subColor1))
				selected["startMonthTarget"] = event.target
			end
		end
		if (phase == "moved") then
			-- 拖曳時判定是移動ScrollView
			local dy = math.abs(event.yStart-event.y)
			local dx = math.abs(event.xStart-event.x)
			if (dy > 10 or dx > 0 ) then
				startDateMonthScrollView:takeFocus(event)
			end
			if (event.target == selected["startMonthTarget"] and selected["preStartMonthTarget"] == nil and event.target.name == "selectable") then
				-- 尚未選定選項進行拖曳動作，取消選項判定
				event.target:setFillColor(1)
				strtMonthText[event.target.id]:setFillColor(unpack(wordColor))
				selected["startMonthTarget"] = nil
			elseif (event.target == selected["startMonthTarget"] and event.target == selected["preStartMonthTarget"] and event.target.name == "selectable") then
				-- 當選項有選定過再進行選單移動，保持選項維持被選狀態
				event.target:setFillColor( 0, 0, 0, 0.1)
				strtMonthText[event.target.id]:setFillColor(unpack(subColor1))
			elseif (selected["startMonth"] == true) then
				-- 選項有選定過，有觸碰其他選項時進行移動，回到原被選定的選項
				event.target:setFillColor(1)
				strtMonthText[event.target.id]:setFillColor(unpack(wordColor))
				selected["preStartMonthTarget"]:setFillColor( 0, 0, 0, 0.1)
				strtMonthText[selected["preStartMonthTarget"].id]:setFillColor(unpack(subColor1))
				selected["startMonthTarget"] = selected["preStartMonthTarget"]						
			end
		end
		if (phase == "ended") then
			if(event.target.name == "selectable") then
				selected["preStartMonthTarget"] = selected["startMonthTarget"]
				selected["startMonth"] = true
				-- 選項被選定後執行的動作
				arrow["startMonth"]:rotate(180)
				setStatus["startDateMonthArrow"] = "down"
				setStatus["startDateMonthBase"] = "off"
				startDateMonthSelectedText.text = strtMonthText[event.target.id].text
				startDateMonthGroup.isVisible = false
				startDateDayCover.isVisible = false
				if( setStatus["startDateYearBase"] == "off" and setStatus["startDateDayBase"] == "off") then 
					optionTitleText["startDate"]:setFillColor(unpack(wordColor))
					startDateBaseLine:setStrokeColor(unpack(separateLineColor))
					startDateBaseLine.strokeWidth = 1
				end
			-- 當選擇其他月份時需要換該月份相對的天數
			-- 日選單重新產生
				if ( startDateMonthSelectedText.text ~= preSelectedMonth) then
					if (startDateDayScrollView) then 
						selected["startDayTarget"] = nil
						selected["preStartDayTarget"] = nil
						selected["startDay"] = false
						startDateDayGroup:remove(startDateDayScrollView)
						startDateDayScrollView = nil
					end
					-- 出發日期選單-新日選單選項-配合月選項產生日期
					startDateDayScrollView = widget.newScrollView({
						id = "startDateDayScrollView",
						width = dropDownShadow["startDaySelection"].contentWidth*0.85,
						height = dropDownShadow["startDaySelection"].contentHeight*0.935,
						horizontalScrollDisabled = true,
						isBounceEnabled = false,
					})
					startDateDayGroup:insert(startDateDayScrollView)
					startDateDayScrollView.anchorY = 0
					startDateDayScrollView.x = dropDownShadow["startDaySelection"].x
					startDateDayScrollView.y = dropDownShadow["startDaySelection"].y
					local selectedMonth = tonumber(startDateMonthSelectedText.text)
					local daysOfSelectedMonth = daysOfMonthOption[selectedMonth]
					local selectedDays = {}
					for i=1, daysOfSelectedMonth do
						if ( i<10) then 
							selectedDays[i] = tostring("0")..tostring(i)
						else
							selectedDays[i] = tostring(i)
						end
					end
					-- 出發日期選單-建立新日選單選項
					for i=1, #selectedDays do 
						local strtDayTextBase = display.newRect( startDateDayScrollView.contentWidth/2, sDayTextBasePadding+(sDayTextBaseHeight*(i-1)), startDateDayScrollView.contentWidth, sDayTextBaseHeight)
						startDateDayScrollView:insert(strtDayTextBase)
						strtDayTextBase.id = i
						strtDayTextBase:addEventListener("touch",strtDayTextListener)
						strtDayText[i] = display.newText({
								text = selectedDays[i],
								font = getFont.font,
								fontSize = 18,
							})
						startDateDayScrollView:insert(strtDayText[i])
						strtDayText[i].x = startDateDayScrollView.contentWidth/2
						strtDayText[i].y = strtDayTextBase.y
						-- 判定當月已經過的日期
						if (startDateYearSelectedText.text == thisDate.thisYear and startDateMonthSelectedText.text == thisDate.thisMonth and i<tonumber(thisDate.thisDay)) then 
							strtDayText[i]:setFillColor(unpack(separateLineColor))
							strtDayTextBase.name = "unselectable"
						else
							strtDayText[i]:setFillColor(unpack(wordColor))
							strtDayTextBase.name = "selectable"
						end
						-- 判定日選項的日期
						if (startDateYearSelectedText.text == thisDate.thisYear and startDateMonthSelectedText.text == thisDate.thisMonth) then
							startDateDaySelectedText.text = thisDate.thisDay
						else
							startDateDaySelectedText.text = selectedDays[1]
						end
						-- 判斷ScrollView選項的位置
						if ( startDateYearSelectedText.text == thisDate.thisYear and startDateMonthSelectedText.text == thisDate.thisMonth) then 
							local baseDay
							if (#realTimeDays - tonumber(thisDate.thisDay) < 3 ) then
								baseDay =  #realTimeDays - 3
							else
								baseDay = tonumber(startDateDaySelectedText.text)
							end
							if ( i == baseDay) then
								yOfThisDay = -strtDayText[i].y+sDayTextBasePadding
							end
						else
							if (i == tonumber(startDateDaySelectedText.text)) then
								yOfThisDay = -strtDayText[i].y+sDayTextBasePadding
							end
						end
					end
					-- 將ScrollView轉到相對應的位置
					startDateDayScrollView:scrollToPosition( { 
							y = yOfThisDay,
							time = 500
						})
					startDateDayGroup.isVisible = false
				end
			end
		end
		return true
	end
-- 月選單選項-現實時間
	for i=1,#monthOption do
		local strtMonthTextBase = display.newRect(startDateMonthScrollView.contentWidth/2, sMonthTextBasePadding+(sMonthTextBaseHeight*(i-1)), startDateMonthScrollView.contentWidth, sMonthTextBaseHeight)
		startDateMonthScrollView:insert(strtMonthTextBase)
		strtMonthTextBase.id = i
		strtMonthTextBase:addEventListener("touch", strtMonthTextListener)
		strtMonthText[i] = display.newText({
					text = monthOption[i],
					font = getFont.font,
					fontSize = 18,
				})
		startDateMonthScrollView:insert(strtMonthText[i])
		strtMonthText[i].x = startDateMonthScrollView.contentWidth*0.5
		strtMonthText[i].y = strtMonthTextBase.y
		-- 判定現實當年經過的月份
		if (startDateYearSelectedText.text == thisDate.thisYear and i<tonumber(thisDate.thisMonth)) then
			strtMonthText[i]:setFillColor(unpack(separateLineColor))
			strtMonthTextBase.name = "unselectable"
		else
			strtMonthText[i]:setFillColor(unpack(wordColor))
			strtMonthTextBase.name = "selectable"
		end
		-- 判定月選項的月份
		if ( startDateYearSelectedText.text == thisDate.thisYear) then
			startDateMonthSelectedText.text = thisDate.thisMonth
		else
			startDateMonthSelectedText.text = monthOption[1]
		end
		-- 判斷ScrollView選項的位置
		local baseMonth
		if (#monthOption - thisDate.thisMonth < 3) then 
			baseMonth = #monthOption - 3
		else
			baseMonth = tonumber(startDateMonthSelectedText.text)
		end
		if (i == baseMonth) then
			yOfThisMonth = -strtMonthText[i].y+sMonthTextBasePadding
		end
	end
	-- 將ScrollView轉到相對應的位置
	startDateMonthScrollView:scrollToPosition({ 
			y = yOfThisMonth,
			time = 500
		})
	startDateMonthGroup.isVisible = false

-- 年選單
	startDateYearGroup = display.newGroup()
	scrollViewGroup:insert(startDateYearGroup)
-- 選單外框
	dropDownShadow["startYearSelection"] = display.newImageRect( "assets/shadow-320480.png", startDateYearBase.contentWidth*0.8, screenH*0.25)
	startDateYearGroup:insert(dropDownShadow["startYearSelection"])
	dropDownShadow["startYearSelection"].anchorY = 0
	dropDownShadow["startYearSelection"].x = ceil(startDateBase.contentWidth*0.16)
	dropDownShadow["startYearSelection"].y = startDateBaseLine.y+startDateBaseLine.strokeWidth
	local sYearBaseHeight = (screenH*0.4)/4
	local sYearBasePadding = sYearBaseHeight*0.5
-- 選單ScrollView
	local startDateYearScrollView = widget.newScrollView({
			id = "startDateYearScrollView",
			width = dropDownShadow["startYearSelection"].contentWidth*0.95,
			height = dropDownShadow["startYearSelection"].contentHeight*59/60,
			horizontalScrollDisabled = true,
			isBounceEnabled = false,
		})
	startDateYearGroup:insert(startDateYearScrollView)
	startDateYearScrollView.anchorY = 0
	startDateYearScrollView.x = dropDownShadow["startYearSelection"].x
	startDateYearScrollView.y = dropDownShadow["startYearSelection"].y
-- 年選單選項監聽事件
	local strtYearText = {}
	selected["startYearTarget"], selected["preStartYearTarget"] = nil, nil
	selected["startYear"] = false
	local function strtYearTextListener( event )
		local phase = event.phase
		local preSelectedYear = startDateYearSelectedText.text
		-- 按壓選項時選項及背景會變色
		if (phase == "began") then
			if (selected["startYearTarget"] == nil) then
				-- 第一次選擇選項，選項字體跟背景變色
				event.target:setFillColor( 0, 0, 0, 0.1)
				strtYearText[event.target.id]:setFillColor(unpack(subColor1))
				selected["startYearTarget"] = event.target
			end
			if ( selected["startYearTarget"] ~= nil and event.target ~= selected["startYearTarget"]) then
				-- 當選定選項後，要再更改選項
				selected["preStartYearTarget"] = selected["startYearTarget"]
				selected["preStartYearTarget"]:setFillColor(1)
				strtYearText[selected["preStartYearTarget"].id]:setFillColor(unpack(wordColor))
				event.target:setFillColor( 0, 0, 0, 0.1)
				strtYearText[event.target.id]:setFillColor(unpack(subColor1))
				selected["startYearTarget"] = event.target
			end
		end
		if (phase == "moved") then
			-- 拖曳時判定是移動ScrollView
			local dy = math.abs(event.yStart-event.y)
			local dx = math.abs(event.xStart-event.y)
			if (dy > 10 or dx > 0) then 
				startDateYearScrollView:takeFocus(event)
			end
			if (event.target == selected["startYearTarget"] and selected["preStartYearTarget"] == nil) then
				-- 尚未選定選項進行拖曳動作，取消選項判定
				event.target:setFillColor(1)
				strtYearText[event.target.id]:setFillColor(unpack(wordColor))
				selected["startYearTarget"] = nil
			elseif (event.target == selected["startYearTarget"] and event.target == selected["preStartYearTarget"]) then
				-- 當選項有選定過再進行選單移動，保持選項維持被選狀態
				event.target:setFillColor( 0, 0, 0, 0.1)
				strtYearText[event.target.id]:setFillColor(unpack(subColor1))				
			elseif (selected["startYear"] == true) then
				-- 選項有選定過，有觸碰其他選項時進行移動，回到原被選定的選項
				event.target:setFillColor(1)
				strtYearText[event.target.id]:setFillColor(unpack(wordColor))
				selected["preStartYearTarget"]:setFillColor( 0, 0, 0, 0.1)
				strtYearText[selected["preStartYearTarget"].id]:setFillColor(unpack(subColor1))
				selected["startYearTarget"] = selected["preStartYearTarget"]						
			end
		end
		if (phase == "ended") then
			selected["preStartYearTarget"] = selected["startYearTarget"]
			selected["startYear"] = true
			-- 選項被選定後執行的動作
			arrow["startYear"]:rotate(180)
			setStatus["startDateYearArrow"] = "down"
			setStatus["startDateYearBase"] = "off"
			startDateYearSelectedText.text = strtYearText[event.target.id].text
			startDateYearGroup.isVisible = false
			startDateMonthCover.isVisible = false
			startDateDayCover.isVisible = false
			if( setStatus["startDateMonthBase"] == "off" and setStatus["startDateDayBase"] == "off") then 
				optionTitleText["startDate"]:setFillColor(unpack(wordColor))
				startDateBaseLine:setStrokeColor(unpack(separateLineColor))
				startDateBaseLine.strokeWidth = 1
			end
			if (startDateYearSelectedText.text ~= preSelectedYear) then
			-- 當選擇其他年份時將月份跟日期選單重置至該年的0101
			-- 重置月選單
				if (startDateMonthScrollView) then 
					selected["startMonthTarget"] = nil
					selected["preStartMonthTarget"] = nil
					selected["startMonth"] = false
					startDateMonthGroup:remove(startDateMonthScrollView)
					startDateMonthScrollView = nil
					-- 配合選擇的年份再對應現實時間顯示月份
					if (startDateYearSelectedText.text == thisDate.thisYear) then
						startDateMonthSelectedText.text = thisDate.thisMonth
					else
						startDateMonthSelectedText.text = "01"
					end
					startDateMonthScrollView = widget.newScrollView({
						id = "startDateMonthScrollView",
						width = dropDownShadow["startMonthSelection"].contentWidth*0.85,
						height = dropDownShadow["startMonthSelection"].contentHeight*0.935,
						horizontalScrollDisabled = true,
						isBounceEnabled = false,
					})
					startDateMonthGroup:insert(startDateMonthScrollView)
					startDateMonthScrollView.anchorY = 0
					startDateMonthScrollView.x = dropDownShadow["startMonthSelection"].x
					startDateMonthScrollView.y = dropDownShadow["startMonthSelection"].y
					for i=1,#monthOption do
						local strtMonthTextBase = display.newRect(startDateMonthScrollView.contentWidth/2, sMonthTextBasePadding+(sMonthTextBaseHeight*(i-1)), startDateMonthScrollView.contentWidth, sMonthTextBaseHeight)
						startDateMonthScrollView:insert(strtMonthTextBase)
						strtMonthTextBase.id = i
						strtMonthTextBase:addEventListener("touch", strtMonthTextListener)
						strtMonthText[i] = display.newText({
								text = monthOption[i],
								font = getFont.font,
								fontSize = 18,
							})
						startDateMonthScrollView:insert(strtMonthText[i])
						strtMonthText[i].x = startDateMonthScrollView.contentWidth*0.5
						strtMonthText[i].y = strtMonthTextBase.y
						-- 判定現實當年經過的月份
						if (startDateYearSelectedText.text == thisDate.thisYear and i<tonumber(thisDate.thisMonth)) then
							strtMonthText[i]:setFillColor(unpack(separateLineColor))
							strtMonthTextBase.name = "unselectable"
						else
							strtMonthText[i]:setFillColor(unpack(wordColor))
							strtMonthTextBase.name = "selectable"
						end
						-- 判定月選項的月份
						if ( startDateYearSelectedText.text == thisDate.thisYear) then
							startDateMonthSelectedText.text = thisDate.thisMonth
						else
							startDateMonthSelectedText.text = monthOption[1]
						end
						--backDateMonthSelectedText.text = startDateMonthSelectedText.text
						-- 判斷ScrollView選項的位置
						if ( i == tonumber(startDateMonthSelectedText.text)) then
							yOfThisMonth = -strtMonthText[i].y+sMonthTextBasePadding
						end
					end
					-- 將ScrollView轉到相對應的位置
					startDateMonthScrollView:scrollToPosition({ 
								y = yOfThisMonth,
								time = 500
							})
					startDateMonthGroup.isVisible = false
				end
			-- 重置日選單
				if (startDateDayScrollView) then 
					selected["startDayTarget"] = nil
					selected["preStartDayTarget"] = nil
					selected["startDay"] = false
					startDateDayGroup:remove(startDateDayScrollView)
					startDateDayScrollView = nil
					-- 出發日期選單-新日選單選項-配合月選項產生日期
					startDateDayScrollView = widget.newScrollView({
						id = "startDateDayScrollView",
						width = dropDownShadow["startDaySelection"].contentWidth*0.85,
						height = dropDownShadow["startDaySelection"].contentHeight*0.935,
						horizontalScrollDisabled = true,
						isBounceEnabled = false,
					})
					startDateDayGroup:insert(startDateDayScrollView)
					startDateDayScrollView.anchorY = 0
					startDateDayScrollView.x = dropDownShadow["startDaySelection"].x
					startDateDayScrollView.y = dropDownShadow["startDaySelection"].y
					local selectedMonth = tonumber(startDateMonthSelectedText.text)
					local daysOfSelectedMonth = daysOfMonthOption[selectedMonth]
					local selectedDays = {}
					for i=1, daysOfSelectedMonth do
						if ( i<10) then 
							selectedDays[i] = tostring("0")..tostring(i)
						else
							selectedDays[i] = tostring(i)
						end
					end
					-- 出發日期選單-建立新日選單選項
					-- 重新建立日選項的日期順序
					for i=1, #selectedDays do 
						local strtDayTextBase = display.newRect( startDateDayScrollView.contentWidth/2, sDayTextBasePadding+(sDayTextBaseHeight*(i-1)), startDateDayScrollView.contentWidth, sDayTextBaseHeight)
						startDateDayScrollView:insert(strtDayTextBase)
						strtDayTextBase.id = i
						strtDayTextBase:addEventListener("touch",strtDayTextListener)
						strtDayText[i] = display.newText({
								text = selectedDays[i],
								font = getFont.font,
								fontSize = 18,
							})
						startDateDayScrollView:insert(strtDayText[i])
						strtDayText[i].x = startDateDayScrollView.contentWidth/2
						strtDayText[i].y = strtDayTextBase.y
						-- 判定現實當月已經過的日期
						if ( startDateYearSelectedText.text == thisDate.thisYear and startDateMonthSelectedText.text == thisDate.thisMonth and i<tonumber(thisDate.thisDay)) then 
							strtDayText[i]:setFillColor(unpack(separateLineColor))
							strtDayTextBase.name = "unselectable"
						else
							strtDayText[i]:setFillColor(unpack(wordColor))
							strtDayTextBase.name = "selectable"
						end
						-- 判定日選項的日期
						if ( startDateYearSelectedText.text == thisDate.thisYear and startDateMonthSelectedText.text == thisDate.thisMonth) then
							startDateDaySelectedText.text = thisDate.thisDay
						else
							startDateDaySelectedText.text = selectedDays[1]
						end
						-- 判斷ScrollView選項的位置
						if ( startDateYearSelectedText.text == thisDate.thisYear and startDateMonthSelectedText.text == thisDate.thisMonth) then 
							local baseDay
							if (#realTimeDays - tonumber(thisDate.thisDay) < 3 ) then
								baseDay =  #realTimeDays - 3
							else
								baseDay = tonumber(startDateDaySelectedText.text)
							end
							if ( i == baseDay) then
								yOfThisDay = -strtDayText[i].y+sDayTextBasePadding
							end
						else
							if (i == tonumber(startDateDaySelectedText.text)) then
								yOfThisDay = -strtDayText[i].y+sDayTextBasePadding
							end
						end
					end
					-- 將ScrollView轉到相對應的位置
					startDateDayScrollView:scrollToPosition( { 
							y = yOfThisDay,
							time = 500
						})
					startDateDayGroup.isVisible = false
				end
			end
		end
		return true
	end
-- 出發日期選單-年選單選項-現實時間
	local strtYearTextBase
	for i=1,#yearOption do
		if (#yearOption <= 3) then
			strtYearTextBase = display.newRect(startDateYearScrollView.contentWidth/2, (startDateYearScrollView.contentHeight*0.5)-((#yearOption-1)/2*sYearBaseHeight)+(sYearBaseHeight*(i-1)), startDateYearScrollView.contentWidth, sYearBaseHeight)
		else
			strtYearTextBase = display.newRect(startDateYearScrollView.contentWidth/2, sYearBasePadding+(sYearBaseHeight*(i-1)), startDateYearScrollView.contentWidth, sYearBaseHeight)
		end
		startDateYearScrollView:insert(strtYearTextBase)
		strtYearTextBase.id = i
		strtYearTextBase:addEventListener("touch", strtYearTextListener)
		strtYearText[i] = display.newText({
					text = yearOption[i],
					font = getFont.font,
					fontSize = 18,
				})
		startDateYearScrollView:insert(strtYearText[i])
		strtYearText[i]:setFillColor(unpack(wordColor))
		strtYearText[i].x = startDateYearScrollView.contentWidth*0.5
		strtYearText[i].y = strtYearTextBase.y
	end
	startDateYearGroup.isVisible = false
------------------- 國家&地區下拉式選單 -------------------
-- 國家選單
	tripPointGroup = display.newGroup()
	scrollViewGroup:insert(tripPointGroup)
	local countryNum = scrollViewGroup.numChildren
-- 選單外框
	local tripPonitSelectionBaseShadow = display.newImageRect("assets/shadow-320480.png", tripPointBaseLine.contentWidth*0.8, screenH*0.5)
	tripPointGroup:insert(tripPonitSelectionBaseShadow)
	tripPonitSelectionBaseShadow.anchorY = 0
	tripPonitSelectionBaseShadow.x = cx
	tripPonitSelectionBaseShadow.y = tripPointBaseLine.y+tripPointBaseLine.strokeWidth
	-- 選單內選項背景高度
	local textBaseHeight = tripPonitSelectionBaseShadow.contentHeight*0.2
	-- 選單內選項間距
	local textBasePadding = textBaseHeight*0.5
-- 選單ScrollView
	local tripPointScrollView = widget.newScrollView({
			id = "tripPointScrollView",
			width = tripPonitSelectionBaseShadow.contentWidth*0.95,
			height = tripPonitSelectionBaseShadow.contentHeight*59/60,
			horizontalScrollDisabled = true,
			isBounceEnabled = false,
		})
	tripPointGroup:insert(tripPointScrollView)
	tripPointScrollView.anchorY = 0
	tripPointScrollView.x = tripPonitSelectionBaseShadow.x
	tripPointScrollView.y = tripPonitSelectionBaseShadow.y
-- 國家選項監聽事件
	local ctry_Slct_Text = {}
	local country = { {"台灣","Taiwan"}, {"日本","Japan"}, {"韓國","Korea"}, {"美國","America"}, {"加拿大","Canada"}, {"德國","Germany"}, {"非洲","Africa"}}
	local pointSelectedTarget, prePointSelectedTarget, setRegion
	local function pointListener( event )
		local phase = event.phase
		-- 按壓選項時選項及背景會變色
		if (phase == "began") then
			if (pointSelectedTarget == nil and prePointSelectedTarget == nil ) then
				-- 第一次選擇選項，選項字體跟背景變色
				event.target:setFillColor( 0, 0, 0, 0.1)
				ctry_Slct_Text[event.target.id]:setFillColor(unpack(subColor1))
				pointSelectedTarget = event.target
			end
			if ( pointSelectedTarget ~= nil and event.target ~= pointSelectedTarget) then
				-- 當選定選項後，要再更改選項
				prePointSelectedTarget = pointSelectedTarget
				prePointSelectedTarget:setFillColor(1)
				ctry_Slct_Text[prePointSelectedTarget.id]:setFillColor(unpack(wordColor))
				event.target:setFillColor( 0, 0, 0, 0.1)
				ctry_Slct_Text[event.target.id]:setFillColor(unpack(subColor1))
				pointSelectedTarget = event.target
			end
		end
		if (phase == "moved") then
			-- 拖曳時判定是移動ScrollView
			local dy = math.abs(event.yStart-event.y)
			local dx = math.abs(event.xStart-event.x)
			if (dy > 10 or dx > 0) then
				tripPointScrollView:takeFocus(event)
			end
			if (event.target == pointSelectedTarget and prePointSelectedTarget == nil ) then
				-- 尚未選定選項而進行選項移動時，取消選定色
				event.target:setFillColor(1)
				ctry_Slct_Text[event.target.id]:setFillColor(unpack(wordColor))
				pointSelectedTarget = nil
			elseif (event.target == pointSelectedTarget and event.target == prePointSelectedTarget) then
				-- 當選項有選定過再進行選單移動，保持選項維持被選狀態
				event.target:setFillColor( 0, 0, 0, 0.1)
				ctry_Slct_Text[event.target.id]:setFillColor(unpack(subColor1))
			elseif(tripPointSelected == true) then 
				-- 選項有選定過，有觸碰其他選項時進行移動，回到原被選定的選項
				event.target:setFillColor(1)
				ctry_Slct_Text[event.target.id]:setFillColor(unpack(wordColor))
				prePointSelectedTarget:setFillColor( 0, 0, 0, 0.1)
				ctry_Slct_Text[prePointSelectedTarget.id]:setFillColor(unpack(subColor1))
				pointSelectedTarget = prePointSelectedTarget
			end
		end
		if (phase == "ended") then
			prePointSelectedTarget = pointSelectedTarget
			tripPointSelected = true
			-- 選項被選定後執行的動作
			optionTitleText["tripPoint"]:setFillColor(unpack(wordColor))
			tripPointBaseLine:setStrokeColor(unpack(separateLineColor))
			tripPointBaseLine.strokeWidth = 1
			arrow["tripPoint"]:rotate(180)
			setStatus["tripPointArrow"] = "down"
			tripPointSelectedText.text = ctry_Slct_Text[event.target.id].text
			tripPointGroup.isVisible = false
			tripRegionCover.isVisible = false		
		-- 開始處理地區選項
			setRegion = country[event.target.id][2]
			-- 因為是在事件中產生地區選項，所以若有產生過地區選項要先移除
			if (tripRegionSelection) then 
				tripRegionSelection:removeSelf()
				if( setStatus["tripRegionArrow"] == "up") then 
					setStatus["tripRegionArrow"] = "down"
					arrow["tripRegion"]:rotate(180)
				end
				tripRegionSelectedText.text = "請選擇"
			end	
			local region = { Taiwan = { "台北", "台中", "高雄" }, Japan = { "東京", "大阪", "京都"}, Korea = {"首爾","釜山"}, America = {"敬請期待"}, Canada = {"敬請期待"}, Germany = {"敬請期待"}, Africa = {"敬請期待"} }
		-- 地區選單
			tripRegionGroup = display.newGroup()
			scrollViewGroup:insert(countryNum,tripRegionGroup)
		-- 選單外框
			local tripRegionSelectionBaseShadow = display.newImageRect("assets/shadow-320480.png", tripRegionBaseLine.contentWidth*0.8, screenH*0.5)
			tripRegionGroup:insert(tripRegionSelectionBaseShadow)
			tripRegionSelectionBaseShadow.anchorY = 0
			tripRegionSelectionBaseShadow.x = cx
			tripRegionSelectionBaseShadow.y = tripRegionBaseLine.y+tripRegionBaseLine.strokeWidth
			-- 選單內選項背景高度
			local textBaseHeight = tripRegionSelectionBaseShadow.contentHeight*0.2
			-- 選單內選項間距
			local textBasePadding = textBaseHeight*0.5
		-- 選單ScrollView
			local tripRegionScrollView = widget.newScrollView({
				id = "tripRegionScrollView",
				width = tripRegionSelectionBaseShadow.contentWidth*0.95,
				height = tripRegionSelectionBaseShadow.contentHeight*59/60,
				horizontalScrollDisabled = true,
				isBounceEnabled = false,
			})
			tripRegionGroup:insert(tripRegionScrollView)
			tripRegionScrollView.anchorY = 0
			tripRegionScrollView.x = tripRegionSelectionBaseShadow.x
			tripRegionScrollView.y = tripRegionSelectionBaseShadow.y
		-- 地區選項監聽事件
			local tripRegionSelected
			local rgon_Slct_Text = {}
			local regionSelectedTarget, preRegionSelectedTarget	
			local function regionListener( event )
				local phase = event.phase
				if (phase == "began") then
					if (regionSelectedTarget == nil) then
						-- 第一次選擇選項，選項字體跟背景變色
						event.target:setFillColor( 0, 0, 0, 0.1)
						rgon_Slct_Text[event.target.id]:setFillColor(unpack(subColor1))
						regionSelectedTarget = event.target
					end
					if ( regionSelectedTarget ~= nil and event.target ~= regionSelectedTarget) then
						-- 當選定選項後，要再更改選項
						preRegionSelectedTarget = regionSelectedTarget
						preRegionSelectedTarget:setFillColor(1)
						rgon_Slct_Text[preRegionSelectedTarget.id]:setFillColor(unpack(wordColor))
						event.target:setFillColor( 0, 0, 0, 0.1)
						rgon_Slct_Text[event.target.id]:setFillColor(unpack(subColor1))
						regionSelectedTarget = event.target
					end
				end
				if (phase == "moved") then
					-- 拖曳時判定是移動ScrollView
					local dy = math.abs(event.yStart-event.y)
					local dx = math.abs(event.xStart-event.x)
					if (dy > 10 or dx > 0) then
						tripRegionScrollView:takeFocus(event)
					end
					if (event.target == regionSelectedTarget and preRegionSelectedTarget == nil) then
						-- 第一次進行選項移動時，取消選定色
						event.target:setFillColor(1)
						rgon_Slct_Text[event.target.id]:setFillColor(unpack(wordColor))
						regionSelectedTarget = nil
					elseif (event.target == regionSelectedTarget and event.target == preRegionSelectedTarget) then
						-- 當選項有選定過再進行選單移動，保持選項維持被選狀態
						event.target:setFillColor( 0, 0, 0, 0.1)
						rgon_Slct_Text[event.target.id]:setFillColor(unpack(subColor1))
					elseif (tripRegionSelected == true) then
						-- 選項有選定過，有觸碰其他選項時進行移動，回到原被選定的選項
						event.target:setFillColor(1)
						rgon_Slct_Text[event.target.id]:setFillColor(unpack(wordColor))
						preRegionSelectedTarget:setFillColor( 0, 0, 0, 0.1)
						rgon_Slct_Text[preRegionSelectedTarget.id]:setFillColor(unpack(subColor1))
						regionSelectedTarget = preRegionSelectedTarget						
					end
				end
				if (phase == "ended") then
					preRegionSelectedTarget = regionSelectedTarget
					tripRegionSelected = true
					-- 選項被選定後執行的動作
					optionTitleText["tripRegion"]:setFillColor(unpack(wordColor))
					tripRegionBaseLine:setStrokeColor(unpack(separateLineColor))
					tripRegionBaseLine.strokeWidth = 1
					arrow["tripRegion"]:rotate(180)
					setStatus["tripRegionArrow"] = "down"
					tripRegionSelectedText.text = rgon_Slct_Text[event.target.id].text
					tripRegionGroup.isVisible = false
				end
				return true
			end
			-- 地區選項內容(地區名稱)
			for i=1,#region[setRegion] do
				local regionTextBase = display.newRect(tripRegionScrollView.contentWidth/2, textBasePadding+textBaseHeight*(i-1), tripRegionScrollView.contentWidth, textBaseHeight)
				tripRegionScrollView:insert(regionTextBase)
				regionTextBase.id = i
				regionTextBase:addEventListener("touch",regionListener)
				rgon_Slct_Text[i] = display.newText({
						text = region[setRegion][i],
						font = getFont.font,
						fontSize = 18,
					})
				tripRegionScrollView:insert(rgon_Slct_Text[i])
				rgon_Slct_Text[i]:setFillColor(unpack(wordColor))
				rgon_Slct_Text[i].x = tripRegionScrollView.contentWidth/2
				rgon_Slct_Text[i].y = textBasePadding+textBaseHeight*(i-1)
			end
			tripRegionGroup.isVisible = false
		end
		return true
	end
-- 旅遊地點選項內容(國家名稱)
	for i=1,#country do
		local countryTextBase = display.newRect(tripPointScrollView.contentWidth/2, textBasePadding+textBaseHeight*(i-1), tripPointScrollView.contentWidth, textBaseHeight)
		tripPointScrollView:insert(countryTextBase)
		countryTextBase.id = i
		countryTextBase:addEventListener("touch",pointListener)
		ctry_Slct_Text[i] = display.newText({
				text = country[i][1],
				font = getFont.font,
				fontSize = 18,
			})
		tripPointScrollView:insert(ctry_Slct_Text[i])
		ctry_Slct_Text[i]:setFillColor(unpack(wordColor))
		ctry_Slct_Text[i].x = tripPointScrollView.contentWidth/2
		ctry_Slct_Text[i].y = textBasePadding+textBaseHeight*(i-1)
	end
-- 隱藏旅遊地點選單
	tripPointGroup.isVisible = false
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
 		composer.removeScene("myTripV4")
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