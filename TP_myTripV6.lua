-----------------------------------------------------------------------------------------
--
-- TP_myTripV6.lua
--
-----------------------------------------------------------------------------------------
local widget = require ("widget")
local composer = require ("composer")
local mainTabBar = require("mainTabBar")
local getFont = require("setFont")
local json = require("json")
local optionsTable = require("optionsTable")
local token = require("token")
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

local continentOptions = { "亞洲", ["亞洲"] = 1, "歐洲", ["歐洲"] = 2, "北美洲", ["北美洲"] = 5, "南美洲", ["南美洲"] = 7 }
local continentJson = json.encode( continentOptions )

local titleListBoundary, titleListGroup
local setStatus = {}
local arrow = {}
-- 時間參數
local thisDate = { thisYear = tostring(os.date("%Y")), thisMonth = tostring(os.date("%m")), thisDay = tostring(os.date("%d"))}

local function getFebDay( yearValue )
	local febDay
	if ( yearValue%400 == 0 or ( yearValue%4 == 0 and yearValue%100 ~= 0 ) ) then 
		febDay = 29
	else
		febDay = 28
	end
	return febDay
end

local ceil = math.ceil
local floor = math.floor

function scene:create( event )
    local sceneGroup = self.view
    mainTabBar.myTabBarHidden()
    local dropDownFrame = {}
	local dropDownBase = {}
	local selected = {}
	-- 按鈕監聽事件	
		local titleSelection, titleGroup, invitedGroup
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
				local options = { time = 200, effect = "fade"}
				composer.gotoScene("TP_myTripPlan",options)
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
		local baseScrollView = widget.newScrollView({
			id = "baseScrollView",
			width = screenW+ox+ox,
			height = screenH+oy+oy-titleBase.contentHeight,
			horizontalScrollDisabled = true,
			isBounceEnabled = false,
			isLocked = true,
			backgroundColor = backgroundColor,
			x = cx,
			y = titleBase.y+titleBase.contentHeight*0.5,
		})
		sceneGroup:insert(baseScrollView)
		baseScrollView.anchorY = 0
	-- 陰影
		local titleBaseShadow = display.newImage( sceneGroup, "assets/s-down.png", titleBase.x, titleBase.y+titleBase.contentHeight*0.5)
		titleBaseShadow.anchorY = 0
		titleBaseShadow.width = titleBase.contentWidth
		titleBaseShadow.height = floor(titleBaseShadow.height*0.8)
	------------------- 背景scrollView的元件 -------------------
	-- 旅程資訊元件 --
	-- scrollview參數
		local scrollViewGroup = display.newGroup()
		baseScrollView:insert(scrollViewGroup)
		local optionTitleText = {}
		local showDateText = {}
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
		tripInfoText.x = ceil(49*wRate)
		tripInfoText.y = ceil(60*hRate)
	
	-- 洲別選單元件 --
	-- 觸碰事件用背景
		local continentBase = display.newRect( baseScrollView.contentWidth*0.5, tripInfoText.y+ceil(70*hRate) , baseScrollView.contentWidth, ceil(160*hRate))
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
		optionTitleText["continent"].x = ceil(60*wRate)
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
		continentSelectedText.x = ceil(70*wRate)
		continentSelectedText.y = optionTitleText["continent"].y+optionTitleText["continent"].contentHeight+ceil(20*hRate)
	-- 底線
		local continentBaseLine = display.newLine( optionTitleText["continent"].x, continentBase.y+(continentBase.contentHeight*0.95), continentBase.contentWidth-ceil(60*wRate), continentBase.y+(continentBase.contentHeight*0.95))
		scrollViewGroup:insert(continentBaseLine)
		continentBaseLine:setStrokeColor(unpack(separateLineColor))
		continentBaseLine.strokeWidth = 1
	-- 箭頭
		arrow["continent"] = display.newImageRect("assets/btn-dropdown.png", 256, 168)
		scrollViewGroup:insert(arrow["continent"])
		arrow["continent"].width = arrow["continent"].width*0.05
		arrow["continent"].height = arrow["continent"].height*0.05
		arrow["continent"].x = continentBase.contentWidth*0.92
		arrow["continent"].y = continentSelectedText.y+(continentSelectedText.contentHeight*0.6)
		setStatus["continentArrow"] = "down"
	-- 洲別選單的監聽事件
		local continentGroup 
		continentBase:addEventListener("touch", function (event)
			local phase = event.phase
			if (phase == "ended") then
				if ( setStatus["continentArrow"] == "down" ) then
					optionTitleText["continent"]:setFillColor(unpack(subColor2))
					continentBaseLine:setStrokeColor(unpack(subColor2))
					continentBaseLine.strokeWidth = 2
					arrow["continent"]:rotate(180)
					setStatus["continentArrow"] = "up"
					continentGroup.isVisible = true
				else
					optionTitleText["continent"]:setFillColor(unpack(wordColor))
					continentBaseLine:setStrokeColor(unpack(separateLineColor))
					continentBaseLine.strokeWidth = 1
					arrow["continent"]:rotate(180)
					setStatus["continentArrow"] = "down"
					continentGroup.isVisible = false
				end
			end
			return true
		end)

	-- 國家選單元件 --
	-- 觸碰事件用背景
		local tripPointBase = display.newRect( continentBase.x, continentBase.y+continentBase.contentHeight , continentBase.contentWidth, continentBase.contentHeight)
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
		optionTitleText["tripPoint"].x = optionTitleText["continent"].x
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
		tripPointSelectedText.x = continentSelectedText.x
		tripPointSelectedText.y = optionTitleText["tripPoint"].y+optionTitleText["tripPoint"].contentHeight+ceil(20*hRate)
	-- 底線
		local tripPointBaseLine = display.newLine( optionTitleText["tripPoint"].x, tripPointBase.y+(tripPointBase.contentHeight*0.95), tripPointBase.contentWidth-ceil(60*wRate), tripPointBase.y+(tripPointBase.contentHeight*0.95))
		scrollViewGroup:insert(tripPointBaseLine)
		tripPointBaseLine:setStrokeColor(unpack(separateLineColor))
		tripPointBaseLine.strokeWidth = 1
	-- 箭頭
		arrow["tripPoint"] = display.newImageRect("assets/btn-dropdown.png", 256, 168)
		scrollViewGroup:insert(arrow["tripPoint"])
		arrow["tripPoint"].width = arrow["tripPoint"].width*0.05
		arrow["tripPoint"].height = arrow["tripPoint"].height*0.05
		arrow["tripPoint"].x = tripPointBase.contentWidth*0.92
		arrow["tripPoint"].y = tripPointSelectedText.y+(tripPointSelectedText.contentHeight*0.6)
		setStatus["tripPointArrow"] = "down"
	-- 遮罩
		local tripPointCover = display.newRect( tripPointBase.x, tripPointBase.y, tripPointBase.contentWidth, tripPointBase.contentHeight)
		scrollViewGroup:insert(tripPointCover)
		tripPointCover.anchorY = 0
		tripPointCover:setFillColor( 1, 1, 1, 0.7)
		tripPointCover:addEventListener("touch", function() return true ; end)
	-- 國家選單的監聽事件
		local countryGroup 
		tripPointBase:addEventListener("touch", function (event)
			local phase = event.phase
			if (phase == "ended") then
				if (setStatus["tripPointArrow"] == "down") then
					optionTitleText["tripPoint"]:setFillColor(unpack(subColor2))
					tripPointBaseLine:setStrokeColor(unpack(subColor2))
					tripPointBaseLine.strokeWidth = 2
					arrow["tripPoint"]:rotate(180)
					setStatus["tripPointArrow"] = "up"
					countryGroup.isVisible = true
				else
					optionTitleText["tripPoint"]:setFillColor(unpack(wordColor))
					tripPointBaseLine:setStrokeColor(unpack(separateLineColor))
					tripPointBaseLine.strokeWidth = 1
					arrow["tripPoint"]:rotate(180)
					setStatus["tripPointArrow"] = "down"
					countryGroup.isVisible = false	
				end
			end
			return true
		end)

	-- 地區選單元件 --
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
		optionTitleText["tripRegion"].x = optionTitleText["continent"].x
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
		tripRegionSelectedText.x = continentSelectedText.x
		tripRegionSelectedText.y = optionTitleText["tripRegion"].y+optionTitleText["tripRegion"].contentHeight+ceil(20*hRate)
	-- 底線
		local tripRegionBaseLine = display.newLine( optionTitleText["tripRegion"].x, tripRegionBase.y+(tripRegionBase.contentHeight*0.95), tripRegionBase.contentWidth-ceil(60*wRate), tripRegionBase.y+(tripRegionBase.contentHeight*0.95))
		scrollViewGroup:insert(tripRegionBaseLine)
		tripRegionBaseLine:setStrokeColor(unpack(separateLineColor))
		tripRegionBaseLine.strokeWidth = 1
	-- 箭頭
		arrow["tripRegion"] = display.newImageRect("assets/btn-dropdown.png", 256, 168)
		scrollViewGroup:insert(arrow["tripRegion"])
		arrow["tripRegion"].width = arrow["tripRegion"].width*0.05
		arrow["tripRegion"].height = arrow["tripRegion"].height*0.05
		arrow["tripRegion"].x = tripRegionBase.contentWidth*0.92
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
		local regionGroup, tripPointSelected
		tripRegionBase:addEventListener("touch", function (event)
			local phase = event.phase
			if ( tripPointSelected == true ) then 
				if (phase == "ended") then
					if (setStatus["tripRegionArrow"] == "down") then
						optionTitleText["tripRegion"]:setFillColor(unpack(subColor2))
						tripRegionBaseLine:setStrokeColor(unpack(subColor2))
						tripRegionBaseLine.strokeWidth = 2
						arrow["tripRegion"]:rotate(180)
						setStatus["tripRegionArrow"] = "up"
						regionGroup.isVisible = true
					else
						optionTitleText["tripRegion"]:setFillColor(unpack(wordColor))
						tripRegionBaseLine:setStrokeColor(unpack(separateLineColor))
						tripRegionBaseLine.strokeWidth = 1
						arrow["tripRegion"]:rotate(180)
						setStatus["tripRegionArrow"] = "down"
						regionGroup.isVisible = false	
					end
				end
			end
			return true
		end)

	-- 日期元件參數 --
		local dateBaseWidth = ((screenW+ox+ox)-ceil(60*wRate)*2)/3
		local dateBaseHeight = tripRegionBase.contentHeight
	-- 出發日期元件 --
	-- 觸碰事件用背景
		local startDateBase = display.newRect( tripRegionBase.x, tripRegionBase.y+tripRegionBase.contentHeight, tripRegionBase.contentWidth, tripRegionBase.contentHeight)
		scrollViewGroup:insert(startDateBase)
		startDateBase.anchorY = 0
		--startDateBase:setFillColor( 0, 0, 1, 0.3)
	-- 年
		local startDateYearBase = display.newRect( ceil(60*wRate)+dateBaseWidth*0.5, startDateBase.y, dateBaseWidth, dateBaseHeight )
		scrollViewGroup:insert(startDateYearBase)
		startDateYearBase.anchorY = 0
		startDateYearBase.name = "sYearBase"
		setStatus["startDateYearBase"] = "off"
		--startDateYearBase:setFillColor( 1, 0, 0, 0.3)
	-- 月
		local startDateMonthBase = display.newRect( startDateYearBase.x+dateBaseWidth, startDateBase.y, dateBaseWidth, dateBaseHeight )
		scrollViewGroup:insert(startDateMonthBase)
		startDateMonthBase.anchorY = 0
		startDateMonthBase.name = "sMonthBase"
		setStatus["startDateMonthBase"] = "off"
		--startDateMonthBase:setFillColor( 0, 1, 0, 0.3)
	-- 日
		local startDateDayBase = display.newRect( startDateMonthBase.x+dateBaseWidth, startDateBase.y, dateBaseWidth, dateBaseHeight )
		scrollViewGroup:insert(startDateDayBase)
		startDateDayBase.anchorY = 0
		startDateDayBase.name = "sDayBase"
		setStatus["startDateDayBase"] = "off"
		--startDateDayBase:setFillColor( 0, 0, 1, 0.3)
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
		optionTitleText["startDate"].x = optionTitleText["continent"].x
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
		startDateYearSelectedText.anchorX = 1
		startDateYearSelectedText.anchorY = 0
		startDateYearSelectedText.x = startDateYearBase.x
		startDateYearSelectedText.y = optionTitleText["startDate"].y+optionTitleText["startDate"].contentHeight+ceil(20*hRate)
	-- 年-"年"
		showDateText["startYear"] = display.newText({
			text = "年",
			font = getFont.font,
			fontSize = 12,
		})
		scrollViewGroup:insert(showDateText["startYear"])
		showDateText["startYear"]:setFillColor(unpack(wordColor))
		showDateText["startYear"].anchorX = 1
		showDateText["startYear"].anchorY = 0
		showDateText["startYear"].x = startDateYearBase.x+dateBaseWidth*0.5
		showDateText["startYear"].y = startDateYearSelectedText.y
	-- 年-箭頭
		arrow["startYear"] = display.newImage("assets/btn-dropdown.png")
		scrollViewGroup:insert(arrow["startYear"])
		arrow["startYear"].width = arrow["startYear"].width*0.05
		arrow["startYear"].height = arrow["startYear"].height*0.05
		arrow["startYear"].x = showDateText["startYear"].x-showDateText["startYear"].contentWidth-ceil(20*wRate)-arrow["startYear"].contentWidth*0.5
		arrow["startYear"].y = startDateYearSelectedText.y+(startDateYearSelectedText.contentHeight*0.5)
		setStatus["startDateYearArrow"] = "down"
	-- 月-顯示日期
		local startDateMonthSelectedText = display.newText({
			text = thisDate.thisMonth,
			font = getFont.font,
			fontSize = 12,
		})
		scrollViewGroup:insert(startDateMonthSelectedText)
		startDateMonthSelectedText:setFillColor(unpack(wordColor))
		startDateMonthSelectedText.anchorX = 1
		startDateMonthSelectedText.anchorY = 0
		startDateMonthSelectedText.x = startDateMonthBase.x
		startDateMonthSelectedText.y = startDateYearSelectedText.y
	-- 月-"月"
		showDateText["startMonth"] = display.newText({
			text = "月",
			font = getFont.font,
			fontSize = 12,
		})
		scrollViewGroup:insert(showDateText["startMonth"])
		showDateText["startMonth"]:setFillColor(unpack(wordColor))
		showDateText["startMonth"].anchorX = 1
		showDateText["startMonth"].anchorY = 0
		showDateText["startMonth"].x = startDateMonthBase.x+dateBaseWidth*0.5
		showDateText["startMonth"].y = startDateYearSelectedText.y
	-- 月-箭頭
		arrow["startMonth"] = display.newImage("assets/btn-dropdown.png")
		scrollViewGroup:insert(arrow["startMonth"])
		arrow["startMonth"].width = arrow["startMonth"].width*0.05
		arrow["startMonth"].height = arrow["startMonth"].height*0.05
		arrow["startMonth"].x = showDateText["startMonth"].x-showDateText["startMonth"].contentWidth-ceil(20*wRate)-arrow["startMonth"].contentWidth*0.5
		arrow["startMonth"].y = arrow["startYear"].y
		setStatus["startDateMonthArrow"] = "down"
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
		startDateDaySelectedText.anchorX = 1
		startDateDaySelectedText.anchorY = 0
		startDateDaySelectedText.x = startDateDayBase.x
		startDateDaySelectedText.y = startDateYearSelectedText.y
	-- 日-"日"
		showDateText["startDay"] = display.newText({
			text = "日",
			font = getFont.font,
			fontSize = 12,
		})
		scrollViewGroup:insert(showDateText["startDay"])
		showDateText["startDay"]:setFillColor(unpack(wordColor))
		showDateText["startDay"].anchorX = 1
		showDateText["startDay"].anchorY = 0
		showDateText["startDay"].x = startDateDayBase.x+dateBaseWidth*0.5
		showDateText["startDay"].y = startDateYearSelectedText.y
	-- 日-箭頭
		arrow["startDay"] = display.newImageRect("assets/btn-dropdown.png", 256, 168)
		scrollViewGroup:insert(arrow["startDay"])
		arrow["startDay"].width = arrow["startDay"].width*0.05
		arrow["startDay"].height = arrow["startDay"].height*0.05
		arrow["startDay"].x = showDateText["startDay"].x-showDateText["startDay"].contentWidth-ceil(20*wRate)-arrow["startDay"].contentWidth*0.5
		arrow["startDay"].y = arrow["startYear"].y
		setStatus["startDateDayArrow"] = "down"
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
		local startDateBaseLine = display.newLine( optionTitleText["startDate"].x, startDateBase.y+(startDateBase.contentHeight*0.95), startDateBase.contentWidth-ceil(60*wRate), startDateBase.y+(startDateBase.contentHeight*0.95))
		scrollViewGroup:insert(startDateBaseLine)
		startDateBaseLine:setStrokeColor(unpack(separateLineColor))
		startDateBaseLine.strokeWidth = 1
	-- 出發日期選單開關監聽事件
		local startDateYearGroup, startDateMonthGroup, startDateDayGroup 
		local function startDateBaseListner(event)
			local phase = event.phase
			local name = event.target.name
			if (phase == "ended") then 
				if ( name == "sYearBase" ) then
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
				elseif ( name == "sMonthBase" ) then
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
				elseif ( name == "sDayBase" ) then
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

	-- 回程日期元件 --
	-- 觸碰事件用背景--
		local backDateBase = display.newRect( startDateBase.x, startDateBase.y+startDateBase.contentHeight, startDateBase.contentWidth, startDateBase.contentHeight)
		scrollViewGroup:insert(backDateBase)
		backDateBase.anchorY = 0
	-- 年
		local backDateYearBase = display.newRect( startDateYearBase.x, backDateBase.y, dateBaseWidth, dateBaseHeight )
		scrollViewGroup:insert(backDateYearBase)
		backDateYearBase.anchorY = 0
		backDateYearBase.name = "bYearBase"
		setStatus["backDateYearBase"] = "off"
		--backDateYearBase:setFillColor( 1, 0, 0, 0.3)
	-- 月
		local backDateMonthBase = display.newRect( startDateMonthBase.x, backDateBase.y, dateBaseWidth, dateBaseHeight )
		scrollViewGroup:insert(backDateMonthBase)
		backDateMonthBase.anchorY = 0
		backDateMonthBase.name = "bMonthBase"
		setStatus["backDateMonthBase"] = "off"
		--backDateMonthBase:setFillColor( 0, 1, 0, 0.3)
	-- 日
		local backDateDayBase = display.newRect( startDateDayBase.x, backDateBase.y, dateBaseWidth, dateBaseHeight )
		scrollViewGroup:insert(backDateDayBase)
		backDateDayBase.anchorY = 0
		backDateDayBase.name = "bDayBase"
		setStatus["backDateDayBase"] = "off"
		--backDateDayBase:setFillColor( 0, 0, 1, 0.3)
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
		optionTitleText["backDate"].x = optionTitleText["continent"].x
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
		backDateYearSelectedText.anchorX = 1
		backDateYearSelectedText.anchorY = 0
		backDateYearSelectedText.x = startDateYearSelectedText.x
		backDateYearSelectedText.y = optionTitleText["backDate"].y+optionTitleText["backDate"].contentHeight+ceil(20*hRate)
	-- 年-"年"
		showDateText["backYear"] = display.newText({
			text = "年",
			font = getFont.font,
			fontSize = 12,
		})
		scrollViewGroup:insert(showDateText["backYear"])
		showDateText["backYear"]:setFillColor(unpack(wordColor))
		showDateText["backYear"].anchorX = 1
		showDateText["backYear"].anchorY = 0
		showDateText["backYear"].x = showDateText["startYear"].x
		showDateText["backYear"].y = backDateYearSelectedText.y
	-- 年-箭頭
		arrow["backYear"] = display.newImageRect("assets/btn-dropdown.png", 256, 168)
		scrollViewGroup:insert(arrow["backYear"])
		arrow["backYear"].width = arrow["backYear"].width*0.05
		arrow["backYear"].height = arrow["backYear"].height*0.05
		arrow["backYear"].x = arrow["startYear"].x
		arrow["backYear"].y = backDateYearSelectedText.y+(backDateYearSelectedText.contentHeight*0.5)
		setStatus["backDateYearArrow"] = "down"
	-- 月-顯示日期
		local backDateMonthSelectedText = display.newText({
			text = thisDate.thisMonth,
			font = getFont.font,
			fontSize = 12,
		})
		scrollViewGroup:insert(backDateMonthSelectedText)
		backDateMonthSelectedText:setFillColor(unpack(wordColor))
		backDateMonthSelectedText.anchorX = 1
		backDateMonthSelectedText.anchorY = 0
		backDateMonthSelectedText.x = startDateMonthSelectedText.x
		backDateMonthSelectedText.y = backDateYearSelectedText.y
	-- 月-"月"
		showDateText["backMonth"] = display.newText({
			text = "月",
			font = getFont.font,
			fontSize = 12,
		})
		scrollViewGroup:insert(showDateText["backMonth"])
		showDateText["backMonth"]:setFillColor(unpack(wordColor))
		showDateText["backMonth"].anchorX = 1
		showDateText["backMonth"].anchorY = 0
		showDateText["backMonth"].x = showDateText["startMonth"].x
		showDateText["backMonth"].y = backDateYearSelectedText.y
	-- 月-箭頭
		arrow["backMonth"] = display.newImageRect("assets/btn-dropdown.png", 256, 168)
		scrollViewGroup:insert(arrow["backMonth"])
		arrow["backMonth"].width = arrow["backMonth"].width*0.05
		arrow["backMonth"].height = arrow["backMonth"].height*0.05
		arrow["backMonth"].x = arrow["startMonth"].x
		arrow["backMonth"].y = arrow["backYear"].y
		setStatus["backDateMonthArrow"] = "down"
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
		backDateDaySelectedText.anchorX = 1
		backDateDaySelectedText.anchorY = 0
		backDateDaySelectedText.x = startDateDaySelectedText.x
		backDateDaySelectedText.y = backDateYearSelectedText.y
	-- 日-"日"
		showDateText["backDay"] = display.newText({
			text = "日",
			font = getFont.font,
			fontSize = 12,
		})
		scrollViewGroup:insert(showDateText["backDay"])
		showDateText["backDay"]:setFillColor(unpack(wordColor))
		showDateText["backDay"].anchorX = 1
		showDateText["backDay"].anchorY = 0
		showDateText["backDay"].x = showDateText["startDay"].x
		showDateText["backDay"].y = backDateYearSelectedText.y
	-- 日-箭頭
		arrow["backDay"] = display.newImageRect("assets/btn-dropdown.png", 256, 168)
		scrollViewGroup:insert(arrow["backDay"])
		arrow["backDay"].width = arrow["backDay"].width*0.05
		arrow["backDay"].height = arrow["backDay"].height*0.05
		arrow["backDay"].x = arrow["startDay"].x
		arrow["backDay"].y = arrow["backYear"].y
		setStatus["backDateDayArrow"] = "down"
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
		local backDateBaseLine = display.newLine( optionTitleText["backDate"].x, backDateBase.y+(backDateBase.contentHeight*0.95), backDateBase.contentWidth-ceil(60*wRate), backDateBase.y+(backDateBase.contentHeight*0.95))
		scrollViewGroup:insert(backDateBaseLine)
		backDateBaseLine:setStrokeColor(unpack(separateLineColor))
		backDateBaseLine.strokeWidth = 1
	-- 回程日期選單開關監聽事件
		local backDateYearGroup, backDateMonthGroup, backDayGroup 
		local function backDateBaseListner(event)
			local phase = event.phase
			local name = event.target.name
			if (phase == "ended") then 
				if ( name == "bYearBase" ) then
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
							backDayGroup.isVisible = false
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
				elseif ( name == "bMonthBase" ) then
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
							backDayGroup.isVisible = false
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
				elseif ( name == "bDayBase" ) then
					if (setStatus["backDateDayBase"] == "off") then
						-- 日的打開選單動作
						arrow["backDay"]:rotate(180)
						setStatus["backDateDayBase"] = "on"
						backDayGroup.isVisible = true
						if( setStatus["backDateYearBase"] == "off" and setStatus["backDateMonthBase"] == "off") then 
							optionTitleText["backDate"]:setFillColor(unpack(subColor2))
							backDateBaseLine:setStrokeColor(unpack(subColor2))
							backDateBaseLine.strokeWidth = 2
						end	
					else
						-- 日的關閉選單動作
						arrow["backDay"]:rotate(180)
						setStatus["backDateDayBase"] = "off"
						backDayGroup.isVisible = false
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
	-- 底部陰影
		local tripInfoBottomPadding = display.newRect( scrollViewGroup, backDateBase.x, backDateBase.y+backDateBase.contentHeight, backDateBase.contentWidth, backDateBase.contentHeight*0.3)
		tripInfoBottomPadding.anchorY = 0
		local tripInfoBottomShadow = display.newImage( scrollViewGroup, "assets/s-down.png", tripInfoBottomPadding.x, tripInfoBottomPadding.y+tripInfoBottomPadding.contentHeight)
		tripInfoBottomShadow.anchorY = 0
		tripInfoBottomShadow.width = titleBase.contentWidth
		tripInfoBottomShadow.height = floor(tripInfoBottomShadow.height*0.5)
	------------------- 確認添加按鈕元件 -------------------
	-- 按鈕
		local setCityId
		local confirmAddBtn = widget.newButton({
				id = "confirmAddBtn",
				defaultFile = "assets/btn-order.png",
	 			width =  451,
	 			height =  120,
	 			onRelease = function()
	 				local startDateTimestamp = os.time({ year = startDateYearSelectedText.text, month = startDateMonthSelectedText.text, day = startDateDaySelectedText.text })
	 				local backDateTimestamp = os.time({ year = backDateYearSelectedText.text, month = backDateMonthSelectedText.text, day = backDateDaySelectedText.text })
	 				if ( setCityId ) then
	 					if ( startDateTimestamp > backDateTimestamp ) then
	 						native.showAlert( "錯誤", "回程日期比出發日期還要早，請重新選擇", { "確定" } )
	 					else
	 						native.showAlert( "", "完成計畫設定，是否要儲存此計畫?", { "確定", "取消" }, 
	 						function( event )
	 						 	if ( event.action == "clicked" ) then
	 						 		local index = event.index
	 						 		if ( index == 1 ) then
	 						 			local function setTipPlan( event )
	 						 				if ( event.isError ) then
	 						 					print( "Network Error： "..event.response )
	 						 				else
	 						 					print( "Save Success： "..event.response )
	 						 					local hintGroup = display.newGroup()
	 						 					local hintRoundedRect = widget.newButton({
	 						 						x = cx,
	 						 						y = (screenH+oy+oy)*0.7,
	 						 						isEnabled = false,
	 						 						fillColor = { default = { 0, 0, 0, 0.6 }, over = { 0, 0, 0, 0.6 }},
	 						 						shape = "roundedRect",
	 						 						width = screenW*0.35,
	 						 						height = screenH/16,
	 						 						cornerRadius = 20,
	 						 					})
	 						 					hintGroup:insert(hintRoundedRect)
	 						 					local hintRoundedRectText = display.newText({
	 						 						text = "儲存成功",
	 						 						font = getFont.font,
	 						 						fontSize = 14,
	 						 						x = hintRoundedRect.x,
	 						 						y = hintRoundedRect.y,
	 						 					})
	 						 					hintGroup:insert(hintRoundedRectText)
	 						 					transition.to( hintGroup, { time = 2000, alpha = 0, transition = easing.inExpo } )
	 						 					timer.performWithDelay( 2000, function () hintGroup:removeSelf(); end )
	 						 					composer.gotoScene( "TP_myTripPlan", { time = 200, effect = "fade" } )
	 						 				end
	 						 			end
										local accessToken
										if ( composer.getVariable("accessToken") ) then
											if ( token.getAccessToken() and token.getAccessToken() ~= composer.getVariable("accessToken") ) then
												composer.setVariable( "accessToken", token.getAccessToken() )
											end
											accessToken = composer.getVariable("accessToken")
										end
										local setStartDate = startDateYearSelectedText.text.."-"..startDateMonthSelectedText.text.."-"..startDateDaySelectedText.text
										local setBackDate = backDateYearSelectedText.text.."-"..backDateMonthSelectedText.text.."-"..backDateDaySelectedText.text
										local headers = {}
										local body
										local params = {}
										headers["Authorization"] = "Bearer "..accessToken
										body = "cityId="..setCityId.."&start="..setStartDate.."&end="..setBackDate
										params.headers = headers
										params.body = body
										local setTripUrl = optionsTable.setTripPlanUrl
										network.request( setTripUrl, "POST", setTipPlan, params)
	 						 		end
	 						 	end
	 						end)
	 					end
	 				else
	 					native.showAlert( "錯誤", "尚有選項未完成選擇，請繼續選擇", { "確定" } )
	 				end
	 			end
			})
		scrollViewGroup:insert(confirmAddBtn)
		confirmAddBtn.anchorY = 1
		confirmAddBtn.width = screenW+ox+ox
		confirmAddBtn.height = math.floor(confirmAddBtn.height/3)
		confirmAddBtn.x = confirmAddBtn.contentWidth*0.5
		confirmAddBtn.y = baseScrollView.contentHeight
	-- 顯示文字-+確認添加
		local confirmAddText = display.newText({
			text = "+確認添加",
			font = getFont.font,
			fontSize = 18,
		})
		scrollViewGroup:insert(confirmAddText)
		confirmAddText.x = confirmAddBtn.x
		confirmAddText.y = confirmAddBtn.y-confirmAddBtn.contentHeight*0.5
	------------------- 回程日期下拉式選單 -------------------
	-- 選單參數 --
		local dateFrameWidth = dateBaseWidth*0.8
		local dateFrameHeight = screenH*0.4
		local dateBaseHeight = dateFrameHeight/4
		local dateBasePadding = dateBaseHeight*0.5
	-- 選單日期參數
		local thisYear = tonumber(thisDate.thisYear)
		local thisMonth = tonumber(thisDate.thisMonth)	
		local fabDay = getFebDay(thisYear)
		local daysOfMonthOption = { 31, febDay, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31}
		local daysOfMonth = daysOfMonthOption[thisMonth]
		local days = {}
		for i = 1, daysOfMonth do
			if ( i < 10) then 
				days[i] = tostring("0")..tostring(i)
			else
				days[i] = tostring(i)
			end
		end
		local monthOption = { "01", "02", "03", "04", "05", "06", "07", "08", "09", "10", "11", "12"}
		local yearOption = { thisYear, thisYear+1}
	-- 日選單 --
	-- 選單外框
		backDayGroup = display.newGroup()
		scrollViewGroup:insert(backDayGroup)
		dropDownFrame["backDay"] = display.newImageRect( "assets/shadow-320480.png", dateFrameWidth, dateFrameHeight )
		backDayGroup:insert(dropDownFrame["backDay"])
		dropDownFrame["backDay"].anchorY = 0
		dropDownFrame["backDay"].x = backDateDaySelectedText.x-ceil(20*wRate)
		dropDownFrame["backDay"].y = backDateBaseLine.y+backDateBaseLine.strokeWidth
	-- 選單ScrollView
		local backDateDayScrollView = widget.newScrollView({
			id = "backDateDayScrollView",
			width = dateFrameWidth*0.95,
			height = dateFrameHeight*59/60,
			horizontalScrollDisabled = true,
			isBounceEnabled = false,
			backgroundColor = {1},
		})
		backDayGroup:insert(backDateDayScrollView)
		backDateDayScrollView.anchorY = 0
		backDateDayScrollView.x = dropDownFrame["backDay"].x
		backDateDayScrollView.y = dropDownFrame["backDay"].y
		local backDateDayScrollViewGroup = display.newGroup()
		backDateDayScrollView:insert(backDateDayScrollViewGroup)
	-- 日選單選項監聽事件
		local backDayText = {}
		selected["backDayTarget"], selected["preBackDayTarget"], selected["backDayCancel"] = nil, nil, false
		local function backDayTextListener( event )
			local phase = event.phase
			local name = event.target.name
			-- 按壓選項時選項及背景會變色
			if ( phase == "began" and name == "selectable") then
				if ( selected["backDayCancel"] == true ) then
					selected["backDayCancel"]  = false
				end
				if ( selected["backDayTarget"] == nil and selected["preBackDayTarget"] == nil) then
					-- 第一次選擇選項，選項字體跟背景變色
					selected["backDayTarget"] = event.target
					selected["backDayTarget"]:setFillColor( 0, 0, 0, 0.1)
					backDayText[selected["backDayTarget"].id]:setFillColor(unpack(subColor1))
				elseif ( selected["backDayTarget"] == nil and selected["preBackDayTarget"] ~= nil ) then
					-- 當選定選項後，要再更改選項
					if ( event.target ~= selected["preBackDayTarget"] ) then
						
						backDayText[selected["preBackDayTarget"].id]:setFillColor(unpack(wordColor))

						event.target:setFillColor( 0, 0, 0, 0.1)
						backDayText[event.target.id]:setFillColor(unpack(subColor1))
						selected["backDayTarget"] = event.target
					end
				end
			elseif ( phase == "moved" and name == "selectable" ) then
				selected["backDayCancel"] = true
				local dy = math.abs(event.yStart-event.y)
				local dx = math.abs(event.xStart-event.x)
				if (dy > 10 or dx > 0 ) then
					if ( selected["backDayTarget"] ~= nil ) then
						-- 尚未選定選項進行拖曳動作，取消選項判定
						-- 拖曳時判定是移動ScrollView
						backDateDayScrollView:takeFocus(event)
						selected["backDayTarget"]:setFillColor(1)
						backDayText[selected["backDayTarget"].id]:setFillColor(unpack(wordColor))
						selected["backDayTarget"] = nil
						if ( selected["preBackDayTarget"] ~= nil ) then
							-- 當選項有選定過再進行選單移動，保持選項維持被選狀態
							backDayText[selected["preBackDayTarget"].id]:setFillColor(unpack(subColor1))
						end
					end		
				end
			elseif ( phase == "ended" and name == "selectable" and selected["backDayCancel"] == false and selected["backDayTarget"] ~= nil ) then
				-- 選項被選定後選框的變化
					arrow["backDay"]:rotate(180)
					setStatus["backDateDayArrow"] = "down"
					setStatus["backDateDayBase"] = "off"
					backDateDaySelectedText.text = backDayText[event.target.id].text
					if( setStatus["backDateYearBase"] == "off" and setStatus["backDateMonthBase"] == "off") then 
						optionTitleText["backDate"]:setFillColor(unpack(wordColor))
						backDateBaseLine:setStrokeColor(unpack(separateLineColor))
						backDateBaseLine.strokeWidth = 1
					end
				-- 選項選單變化
					selected["backDayTarget"]:setFillColor(1)
					selected["preBackDayTarget"] = selected["backDayTarget"]
					selected["backDayTarget"] = nil
					backDayGroup.isVisible = false
			end
			return true
		end
	-- 日選單選項-現實時間 --
	-- 建立日選單選項
		local yOfThisDay
		for i = 1, #days do
			-- 觸碰用背景
				local backDayTextBase = display.newRect( backDateDayScrollViewGroup, backDateDayScrollView.contentWidth/2, dateBasePadding+(dateBaseHeight*(i-1)), dateFrameWidth*0.96, dateBaseHeight)
				--backDateDayScrollView:insert(backDayTextBase)
				backDayTextBase.id = i
				backDayTextBase:addEventListener("touch",backDayTextListener)
			-- 日期選項
				backDayText[i] = display.newText({
					parent = backDateDayScrollViewGroup,
					text = days[i],
					font = getFont.font,
					fontSize = 18,
					x = backDateDayScrollView.contentWidth/2,
					y = backDayTextBase.y
				})
				--backDateDayScrollView:insert(backDayText[i])
			-- 判定日選項的日期
				if ( backDateYearSelectedText.text == thisDate.thisYear and backDateMonthSelectedText.text == thisDate.thisMonth) then
					backDateDaySelectedText.text = thisDate.thisDay
				else
					backDateDaySelectedText.text = days[1]
				end
			-- 判定當月已經過的日期
				if ( backDateYearSelectedText.text == thisDate.thisYear and backDateMonthSelectedText.text == thisDate.thisMonth and i < tonumber(thisDate.thisDay)) then 
					backDayText[i]:setFillColor(unpack(separateLineColor))
					backDayTextBase.name = "unselectable"
				else
					if ( backDayText[i].text == backDateDaySelectedText.text ) then
						backDayText[i]:setFillColor(unpack(subColor1))
						selected["preBackDayTarget"] = backDayTextBase
					else
						backDayText[i]:setFillColor(unpack(wordColor))
					end
					backDayTextBase.name = "selectable"
				end
			-- 判斷ScrollView選項的位置
				local baseDay
				if ( #days - tonumber(thisDate.thisDay) < 3 ) then
					baseDay =  #days - 3
				else
					baseDay = tonumber(backDateDaySelectedText.text)
				end
				if ( i == baseDay) then
					yOfThisDay = -backDayText[i].y+dateBasePadding
				end
		end
		-- 將ScrollView轉到相對應的位置
			backDateDayScrollView:scrollToPosition( { y = yOfThisDay, time = 500 } )
			backDayGroup.isVisible = false

	-- 月選單 --
	-- 選單外框
		backDateMonthGroup = display.newGroup()
		scrollViewGroup:insert(backDateMonthGroup)
		dropDownFrame["backMonth"] = display.newImageRect( "assets/shadow-320480.png", dateFrameWidth, dateFrameHeight )
		backDateMonthGroup:insert(dropDownFrame["backMonth"])
		dropDownFrame["backMonth"].anchorY = 0
		dropDownFrame["backMonth"].x = backDateMonthSelectedText.x-ceil(20*wRate)
		dropDownFrame["backMonth"].y = backDateBaseLine.y+backDateBaseLine.strokeWidth
	-- 選單ScrollView
		local backDateMonthScrollView = widget.newScrollView({
			id = "backDateMonthScrollView",
			width = dateFrameWidth*0.95,
			height = dateFrameHeight*59/60,
			horizontalScrollDisabled = true,
			isBounceEnabled = false,
		})
		backDateMonthGroup:insert(backDateMonthScrollView)
		backDateMonthScrollView.anchorY = 0
		backDateMonthScrollView.x = dropDownFrame["backMonth"].x
		backDateMonthScrollView.y = dropDownFrame["backMonth"].y
		local backDateMonthScrollViewGroup = display.newGroup()
		backDateMonthScrollView:insert(backDateMonthScrollViewGroup)
	-- 月選單選項監聽事件
		local backMonthText = {}
		selected["backMonthTarget"], selected["preBackMonthTarget"], selected["backMonthCancel"] = nil, nil, false
		local function backMonthTextListener( event )
			local phase = event.phase
			local name = event.target.name
			local preSelectedMonth = backDateMonthSelectedText.text
			-- 按壓選項時選項及背景會變色
			if ( phase == "began" and name == "selectable" ) then
				if ( selected["backMonthCancel"] == true ) then
					selected["backMonthCancel"] = false
				end
				if ( selected["backMonthTarget"] == nil and selected["preBackMonthTarget"] == nil ) then
					-- 第一次選擇選項，選項字體跟背景變色
					selected["backMonthTarget"] = event.target
					selected["backMonthTarget"]:setFillColor( 0, 0, 0, 0.1)
					backMonthText[selected["backMonthTarget"].id]:setFillColor(unpack(subColor1))
				elseif ( selected["backMonthTarget"] == nil and selected["preBackMonthTarget"] ~= nil  ) then
					-- 當選定選項後，要再更改選項
					if ( event.target ~= selected["preBackMonthTarget"] ) then
						
						backMonthText[selected["preBackMonthTarget"].id]:setFillColor(unpack(wordColor))
						
						selected["backMonthTarget"] = event.target
						selected["backMonthTarget"]:setFillColor( 0, 0, 0, 0.1)
						backMonthText[selected["backMonthTarget"].id]:setFillColor(unpack(subColor1))	
					end
				end
			elseif ( phase == "moved" and name == "selectable" ) then
				selected["backMonthCancel"] = true
				local dy = math.abs(event.yStart-event.y)
				local dx = math.abs(event.xStart-event.x)
				if ( dy > 10 or dx > 0 ) then
					if ( selected["backMonthTarget"] ~= nil ) then
						backDateMonthScrollView:takeFocus(event)
						selected["backMonthTarget"]:setFillColor(1)
						backMonthText[selected["backMonthTarget"].id]:setFillColor(unpack(wordColor))
						selected["backMonthTarget"] = nil
						if ( selected["preBackMonthTarget"] ~= nil ) then
							backMonthText[selected["preBackMonthTarget"].id]:setFillColor(unpack(subColor1))
						end					
					end
				end
			elseif ( phase == "ended" and name == "selectable" and selected["backMonthCancel"] == false and selected["backMonthTarget"] ~= nil ) then
				-- 選項被選定後執行的動作
					arrow["backMonth"]:rotate(180)
					setStatus["backDateMonthArrow"] = "down"
					setStatus["backDateMonthBase"] = "off"
					backDateMonthSelectedText.text = backMonthText[event.target.id].text
					if( setStatus["backDateYearBase"] == "off" and setStatus["backDateDayBase"] == "off") then 
						optionTitleText["backDate"]:setFillColor(unpack(wordColor))
						backDateBaseLine:setStrokeColor(unpack(separateLineColor))
						backDateBaseLine.strokeWidth = 1
					end
				-- 選項選單變化
					selected["backMonthTarget"]:setFillColor(1)
					selected["preBackMonthTarget"] = selected["backMonthTarget"]
					selected["backMonthTarget"] = nil
					backDateMonthGroup.isVisible = false
					backDateDayCover.isVisible = false
				-- 當選擇其他月份時需要換該月份相對的天數
				-- 日選單重新產生
				if ( backDateMonthSelectedText.text ~= preSelectedMonth) then
					if ( backDateDayScrollViewGroup ) then
						selected["backDayTarget"] = nil
						selected["preBackDayTarget"] = nil
						selected["backDay"] = false
						backDateDayScrollView:remove(backDateDayScrollViewGroup)
						backDateDayScrollViewGroup = nil
					end
					backDateDayScrollViewGroup = display.newGroup()
					backDateDayScrollView:insert(backDateDayScrollViewGroup)
					-- 重新產生回程日期選單
					-- 新日選單選項-配合月選項產生日期
					local selectedMonth = tonumber(backDateMonthSelectedText.text)
					local daysOfSelectedMonth = daysOfMonthOption[selectedMonth]
					local days = {}
					for i = 1, daysOfSelectedMonth do
						if ( i < 10) then 
							days[i] = tostring("0")..tostring(i)
						else
							days[i] = tostring(i)
						end
					end
					-- 新回程日期選單-建立日選單選項
					for i = 1, #days do 
						local backDayTextBase = display.newRect( backDateDayScrollViewGroup, backDateDayScrollView.contentWidth/2, dateBasePadding+(dateBaseHeight*(i-1)), backDateDayScrollView.contentWidth, dateBaseHeight)							
						--backDateDayScrollView:insert(backDayTextBase)
						backDayTextBase.id = i
						backDayTextBase:addEventListener("touch",backDayTextListener)

						backDayText[i] = display.newText({
							parent = backDateDayScrollViewGroup,
							text = days[i],
							font = getFont.font,
							fontSize = 18,
						})
						--backDateDayScrollView:insert(backDayText[i])
						backDayText[i].x = backDateDayScrollView.contentWidth/2
						backDayText[i].y = backDayTextBase.y
						
						-- 判定日選項的日期
							if (backDateYearSelectedText.text == thisDate.thisYear and backDateMonthSelectedText.text == thisDate.thisMonth) then
								backDateDaySelectedText.text = thisDate.thisDay
							else
								backDateDaySelectedText.text = days[1]
							end
						-- 判定當月已經過的日期
							if ( backDateYearSelectedText.text == thisDate.thisYear and backDateMonthSelectedText.text == thisDate.thisMonth and i<tonumber(thisDate.thisDay)) then 
								backDayText[i]:setFillColor(unpack(separateLineColor))
								backDayTextBase.name = "unselectable"
							else
								if ( backDayText[i].text == backDateDaySelectedText.text ) then
									backDayText[i]:setFillColor(unpack(subColor1))
									selected["preBackDayTarget"] = backDayTextBase
								else
									backDayText[i]:setFillColor(unpack(wordColor))
								end
								backDayTextBase.name = "selectable"
							end
						-- 判斷ScrollView選項的位置
							if ( backDateYearSelectedText.text == thisDate.thisYear and backDateMonthSelectedText.text == thisDate.thisMonth) then 
								local baseDay
								if (#days - tonumber(thisDate.thisDay) < 3 ) then
									baseDay =  #days - 3
								else
									baseDay = tonumber(backDateDaySelectedText.text)
								end
								if ( i == baseDay) then
									yOfThisDay = -backDayText[i].y+dateBasePadding
								end
							else
								if (i == tonumber(backDateDaySelectedText.text)) then
									yOfThisDay = -backDayText[i].y+dateBasePadding
								end
							end
					end
					-- 將ScrollView轉到相對應的位置
						backDateDayScrollView:scrollToPosition( { y = yOfThisDay, time = 500 } )
						backDayGroup.isVisible = false
				end
			end
			return true
		end
	-- 月選單選項-現實時間
		local yOfThisMonth
		for i = 1, #monthOption do
			local backMonthTextBase = display.newRect( backDateMonthScrollViewGroup, backDateMonthScrollView.contentWidth/2, dateBasePadding+(dateBaseHeight*(i-1)), dateFrameWidth*0.96, dateBaseHeight)
			--backDateMonthScrollView:insert(backMonthTextBase)
			backMonthTextBase.id = i
			backMonthTextBase:addEventListener("touch", backMonthTextListener)
			backMonthText[i] = display.newText({
				parent = backDateMonthScrollViewGroup,
				text = monthOption[i],
				font = getFont.font,
				fontSize = 18,
				x = backDateMonthScrollView.contentWidth*0.5,
				y = backMonthTextBase.y,
			})
			--backDateMonthScrollView:insert(backMonthText[i])
			
			-- 判定月選項的月份
				if ( backDateYearSelectedText.text == thisDate.thisYear) then
					backDateMonthSelectedText.text = thisDate.thisMonth
				else
					backDateMonthSelectedText.text = monthOption[1]
				end
			-- 判定現實當年經過的月份
				if (backDateYearSelectedText.text == thisDate.thisYear and i<tonumber(thisDate.thisMonth)) then
					backMonthText[i]:setFillColor(unpack(separateLineColor))
					backMonthTextBase.name = "unselectable"
				else
					if ( backMonthText[i].text == backDateMonthSelectedText.text ) then
						backMonthText[i]:setFillColor(unpack(subColor1))
						selected["preBackMonthTarget"] = backMonthTextBase
					else
						backMonthText[i]:setFillColor(unpack(wordColor))
					end
					backMonthTextBase.name = "selectable"
				end
			-- 判斷ScrollView選項的位置
				local baseMonth
				if ( #monthOption - thisDate.thisMonth < 3) then 
					baseMonth = #monthOption - 3
				else
					baseMonth = tonumber(backDateMonthSelectedText.text)
				end
				if (i == baseMonth) then
					yOfThisMonth = -backMonthText[i].y+dateBasePadding
				end
		end
		-- 將ScrollView轉到相對應的位置
			backDateMonthScrollView:scrollToPosition( { y = yOfThisMonth, time = 500 } )
			backDateMonthGroup.isVisible = false

	-- 年選單 --
	-- 選單外框
		backDateYearGroup = display.newGroup()
		scrollViewGroup:insert(backDateYearGroup)
		dropDownFrame["backYear"] = display.newImageRect( "assets/shadow-320480.png", dateFrameWidth, dateFrameHeight*0.6)
		backDateYearGroup:insert(dropDownFrame["backYear"])
		dropDownFrame["backYear"].anchorY = 0 
		dropDownFrame["backYear"].x = backDateYearSelectedText.x-ceil(35*wRate)
		dropDownFrame["backYear"].y = backDateBaseLine.y+backDateBaseLine.strokeWidth
	-- 選單ScrollView
		local backDateYearScrollView = widget.newScrollView({
			id = "backDateYearScrollView",
			width = dateFrameWidth*0.95,
			height = dropDownFrame["backYear"].contentHeight*59/60,
			horizontalScrollDisabled = true,
			isBounceEnabled = false,
		})
		backDateYearGroup:insert(backDateYearScrollView)
		backDateYearScrollView.anchorY = 0
		backDateYearScrollView.x = dropDownFrame["backYear"].x
		backDateYearScrollView.y = dropDownFrame["backYear"].y
	-- 年選單選項監聽事件
		local backYearText = {}
		selected["backYearTarget"], selected["preBackYearTarget"], selected["backYearCancel"] = nil, nil, false
		local function backYearTextListener( event )
			local phase = event.phase
			local preSelectedYear = backDateYearSelectedText.text
			if ( phase == "began" ) then
				if ( selected["backYearCancel"] == true ) then
					selected["backYearCancel"] = false
				end
				if ( selected["backYearTarget"] == nil and selected["preBackYearTarget"] == nil ) then
					selected["backYearTarget"] = event.target
					selected["backYearTarget"]:setFillColor( 0, 0, 0, 0.1)
					backYearText[selected["backYearTarget"].id]:setFillColor(unpack(subColor1))
				elseif ( selected["backYearTarget"] == nil and selected["preBackYearTarget"] ~= nil ) then
					if ( event.target ~= selected["preBackYearTarget"] ) then
						
						backYearText[selected["preBackYearTarget"].id]:setFillColor(unpack(wordColor))
						
						selected["backYearTarget"] = event.target
						selected["backYearTarget"]:setFillColor( 0, 0, 0, 0.1)
						backYearText[selected["backYearTarget"].id]:setFillColor(unpack(subColor1))
					end
				end
			elseif ( phase == "moved" ) then
				selected["backYearCancel"] = true
				local dy = math.abs(event.yStart-event.y)
				local dx = math.abs(event.xStart-event.y)
				if ( dy > 10 or dx > 0 ) then 
					if ( selected["backYearTarget"] ~= nil ) then
						backDateYearScrollView:takeFocus(event)
						selected["backYearTarget"]:setFillColor(1)
						backYearText[selected["backYearTarget"].id]:setFillColor(unpack(wordColor))
						selected["backYearTarget"] = nil
						if ( selected["preBackYearTarget"] ~= nil ) then
							backYearText[selected["preBackYearTarget"].id]:setFillColor(unpack(subColor1))
						end
					end
				end
			elseif ( phase == "ended" and selected["backYearCancel"] == false and selected["backYearTarget"] ~= nil ) then
				event.target:setFillColor(1)
				selected["preBackYearTarget"] = selected["backYearTarget"]
				selected["backYear"] = true
				-- 選項被選定後執行的動作
					arrow["backYear"]:rotate(180)
					setStatus["backDateYearArrow"] = "down"
					setStatus["backDateYearBase"] = "off"
					backDateYearSelectedText.text = backYearText[event.target.id].text
					if( setStatus["backDateMonthBase"] == "off" and setStatus["backDateDayBase"] == "off") then 
						optionTitleText["backDate"]:setFillColor(unpack(wordColor))
						backDateBaseLine:setStrokeColor(unpack(separateLineColor))
						backDateBaseLine.strokeWidth = 1
					end
				-- 選項選單變化
					selected["backYearTarget"]:setFillColor(1)
					selected["preBackYearTarget"] = selected["backYearTarget"]
					selected["backYearTarget"] = nil
					backDateYearGroup.isVisible = false
					backDateMonthCover.isVisible = false
					backDateDayCover.isVisible = false
				-- 當選擇其他年份時將月份跟日期選單重置至該年的0101
				if ( backDateYearSelectedText.text ~= preSelectedYear ) then
					-- 回程日期年監聽事件-重置月選單
						if ( backDateMonthScrollViewGroup ) then 
							selected["backMonthTarget"] = nil
							selected["preBackMonthTarget"] = nil
							selected["backMonth"] = false
							backDateMonthScrollView:remove(backDateMonthScrollViewGroup)
							backDateMonthScrollViewGroup = nil
						end
						backDateMonthScrollViewGroup = display.newGroup()
						backDateMonthScrollView:insert(backDateMonthScrollViewGroup)
					-- 配合選擇的年份再對應現實時間顯示月份
						if ( backDateYearSelectedText.text == thisDate.thisYear ) then
							backDateMonthSelectedText.text = thisDate.thisMonth
						else
							backDateMonthSelectedText.text = "01"
						end
						for i = 1, #monthOption do
							local backMonthTextBase = display.newRect( backDateMonthScrollViewGroup, backDateMonthScrollView.contentWidth/2, dateBasePadding+(dateBaseHeight*(i-1)), backDateMonthScrollView.contentWidth, dateBaseHeight)
							--backDateMonthScrollView:insert(backMonthTextBase)
							backMonthTextBase.id = i
							backMonthTextBase:addEventListener("touch", backMonthTextListener)
							
							backMonthText[i] = display.newText({
								parent = backDateMonthScrollViewGroup,
								text = monthOption[i],
								font = getFont.font,
								fontSize = 18,
							})
							--backDateMonthScrollView:insert(backMonthText[i])
							backMonthText[i].x = backDateMonthScrollView.contentWidth*0.5
							backMonthText[i].y = backMonthTextBase.y
							-- 判定月選項的月份
							if ( backDateYearSelectedText.text == thisDate.thisYear) then
								backDateMonthSelectedText.text = thisDate.thisMonth
							else
								backDateMonthSelectedText.text = monthOption[1]
							end
							-- 判定現實當年經過的月份
							if (backDateYearSelectedText.text == thisDate.thisYear and i<tonumber(thisDate.thisMonth)) then
								backMonthText[i]:setFillColor(unpack(separateLineColor))
								backMonthTextBase.name = "unselectable"
							else
								if ( backMonthText[i].text == backDateMonthSelectedText.text ) then
									backMonthText[i]:setFillColor(unpack(subColor1))
									selected["preBackMonthTarget"] = backMonthTextBase
								else
									backMonthText[i]:setFillColor(unpack(wordColor))
								end
								backMonthTextBase.name = "selectable"
							end
							-- 判斷ScrollView選項的位置
							if ( i == tonumber(backDateMonthSelectedText.text)) then
								yOfThisMonth = -backMonthText[i].y+dateBasePadding
							end
						end
					-- 將ScrollView轉到相對應的位置
						backDateMonthScrollView:scrollToPosition({ 
							y = yOfThisMonth,
							time = 500
						})
						backDateMonthGroup.isVisible = false
					-- 回程日期年監聽事件-重置日選單
						if ( backDateDayScrollViewGroup ) then 
							selected["startDayTarget"] = nil
							selected["preStartDayTarget"] = nil
							selected["startDay"] = false
							backDateDayScrollView:remove(backDateDayScrollViewGroup)
							backDateDayScrollViewGroup = nil
						end
						backDateDayScrollViewGroup = display.newGroup()
						backDateDayScrollView:insert(backDateDayScrollViewGroup)
					-- 回程日期選單-新日選單選項-配合月選項產生日期
						local selectedMonth = tonumber(backDateMonthSelectedText.text)
						local daysOfSelectedMonth = daysOfMonthOption[selectedMonth]
						local days = {}
						for i = 1, daysOfSelectedMonth do
							if ( i < 10) then 
								days[i] = tostring("0")..tostring(i)
							else
								days[i] = tostring(i)
							end
						end
					-- 回程日期選單-建立新日選單選項
					-- 重新建立日選項的日期順序
						for i = 1, #days do 
							local backDayTextBase = display.newRect( backDateDayScrollViewGroup, backDateDayScrollView.contentWidth/2, dateBasePadding+(dateBaseHeight*(i-1)), backDateDayScrollView.contentWidth, dateBaseHeight)
							--backDateDayScrollView:insert(backDayTextBase)
							backDayTextBase.id = i
							backDayTextBase:addEventListener("touch",backDayTextListener)
					
							backDayText[i] = display.newText({
								parent = backDateDayScrollViewGroup,
								text = days[i],
								font = getFont.font,
								fontSize = 18,
							})
							--backDateDayScrollView:insert(backDayText[i])
							backDayText[i].x = backDateDayScrollView.contentWidth/2
							backDayText[i].y = backDayTextBase.y
							-- 判定日選項的日期
							if ( backDateYearSelectedText.text == thisDate.thisYear and backDateMonthSelectedText.text == thisDate.thisMonth) then
								backDateDaySelectedText.text = thisDate.thisDay
							else
								backDateDaySelectedText.text = days[1]
							end
							-- 判定現實當月已經過的日期
							if ( backDateYearSelectedText.text == thisDate.thisYear and backDateMonthSelectedText.text == thisDate.thisMonth and i<tonumber(thisDate.thisDay)) then 
								backDayText[i]:setFillColor(unpack(separateLineColor))
								backDayTextBase.name = "unselectable"
							else
								if ( backDayText[i].text == backDateDaySelectedText.text ) then
									backDayText[i]:setFillColor(unpack(subColor1))
									selected["preBackDayTarget"] = backDayTextBase
								else
									backDayText[i]:setFillColor(unpack(wordColor))
								end
								backDayTextBase.name = "selectable"
							end
							-- 判斷ScrollView選項的位置
							if ( backDateYearSelectedText.text == thisDate.thisYear and backDateMonthSelectedText.text == thisDate.thisMonth) then 
								local baseDay
								if (#days - tonumber(thisDate.thisDay) < 3 ) then
									baseDay =  #days - 3
								else
									baseDay = tonumber(backDateDaySelectedText.text)
								end
								if ( i == baseDay) then
									yOfThisDay = -backDayText[i].y+dateBasePadding
								end
							else
								if (i == tonumber(backDateDaySelectedText.text)) then
									yOfThisDay = -backDayText[i].y+dateBasePadding
								end
							end
						end
					-- 將ScrollView轉到相對應的位置
						backDateDayScrollView:scrollToPosition( { y = yOfThisDay, time = 500 } )
						backDayGroup.isVisible = false
				end
			end
			return true
		end
	-- 年選單選項-現實時間
		for i = 1, #yearOption do
			local backYearTextBase = display.newRect( backDateYearScrollView.contentWidth/2, dateBasePadding+(dateBaseHeight*(i-1)), dateFrameWidth*0.96, dateBaseHeight)
			backDateYearScrollView:insert(backYearTextBase)
			backYearTextBase.id = i
			backYearTextBase:addEventListener("touch", backYearTextListener)
			
			backYearText[i] = display.newText({
				text = yearOption[i],
				font = getFont.font,
				fontSize = 18,
				x = backDateYearScrollView.contentWidth*0.5,
				y = backYearTextBase.y,
			})
			backDateYearScrollView:insert(backYearText[i])
			if ( backYearText[i].text == backDateYearSelectedText.text ) then
				backYearText[i]:setFillColor(unpack(subColor1))
				selected["preBackYearTarget"] = backYearTextBase
			else
				backYearText[i]:setFillColor(unpack(wordColor))
			end
		end
		backDateYearGroup.isVisible = false
	------------------- 出發日期下拉式選單 -------------------
	-- 日選單 --
	-- 選單外框
		startDateDayGroup = display.newGroup()
		scrollViewGroup:insert(startDateDayGroup)
		dropDownFrame["startDay"] = display.newImageRect( "assets/shadow-320480.png", dateFrameWidth, dateFrameHeight )
		startDateDayGroup:insert(dropDownFrame["startDay"])
		dropDownFrame["startDay"].anchorY = 0
		dropDownFrame["startDay"].x = dropDownFrame["backDay"].x
		dropDownFrame["startDay"].y = startDateBaseLine.y+startDateBaseLine.strokeWidth	
	-- 選單ScrollView
		local startDateDayScrollView = widget.newScrollView({
			id = "startDateDayScrollView",
			width = dateFrameWidth*0.95,
			height = dateFrameHeight*59/60,
			horizontalScrollDisabled = true,
			isBounceEnabled = false,
		})
		startDateDayGroup:insert(startDateDayScrollView)
		startDateDayScrollView.anchorY = 0
		startDateDayScrollView.x = dropDownFrame["startDay"].x
		startDateDayScrollView.y = dropDownFrame["startDay"].y
	-- 日選單選項監聽事件
		local strtDayText = {}
		selected["startDayTarget"], selected["preStartDayTarget"], selected["startDayCancel"] = nil, nil, false
		local function strtDayTextListener( event )
			local phase = event.phase
			local name = event.target.name
			if ( phase == "began" and name == "selectable" ) then
				if ( selected["startDayCancel"] == true ) then
					selected["startDayCancel"] = false
				end
				if ( selected["startDayTarget"] == nil and selected["preStartDayTarget"] == nil ) then
					selected["startDayTarget"] = event.target
					selected["startDayTarget"]:setFillColor( 0, 0, 0, 0.1)
					strtDayText[selected["startDayTarget"].id]:setFillColor(unpack(subColor1))
				elseif ( selected["startDayTarget"] == nil and selected["preStartDayTarget"] ~= nil ) then
					if ( event.target ~= selected["preStartDayTarget"] ) then
						
						strtDayText[selected["preStartDayTarget"].id]:setFillColor(unpack(wordColor))
						
						selected["startDayTarget"] = event.target
						selected["startDayTarget"]:setFillColor( 0, 0, 0, 0.1)
						strtDayText[selected["startDayTarget"].id]:setFillColor(unpack(subColor1))
					end
				end
			elseif ( phase == "moved" and name == "selectable" ) then
				selected["startDayCancel"] = true
				local dy = math.abs(event.yStart-event.y)
				local dx = math.abs(event.xStart-event.x)
				if ( dy > 10 or dx > 0 ) then
					if ( selected["startDayTarget"] ~= nil ) then
						startDateDayScrollView:takeFocus(event)
						selected["startDayTarget"]:setFillColor(1)
						strtDayText[selected["startDayTarget"].id]:setFillColor(unpack(wordColor))
						selected["startDayTarget"] = nil
						if ( selected["preStartDayTarget"] ~= nil ) then
							strtDayText[selected["preStartDayTarget"].id]:setFillColor(unpack(subColor1))	
						end
					end	
				end
			elseif ( phase == "ended" and name == "selectable" and selected["startDayCancel"] == false and selected["startDayTarget"] ~= nil ) then
				-- 選項被選定後執行的動作
					arrow["startDay"]:rotate(180)
					setStatus["startDateDayArrow"] = "down"
					setStatus["startDateDayBase"] = "off"
					startDateDaySelectedText.text = strtDayText[event.target.id].text
					if( setStatus["startDateYearBase"] == "off" and setStatus["startDateMonthBase"] == "off") then 
						optionTitleText["startDate"]:setFillColor(unpack(wordColor))
						startDateBaseLine:setStrokeColor(unpack(separateLineColor))
						startDateBaseLine.strokeWidth = 1
					end
				-- 選項選單變化
					selected["startDayTarget"]:setFillColor(1)
					selected["preStartDayTarget"] = selected["startDayTarget"]
					selected["startDayTarget"] = nil
					startDateDayGroup.isVisible = false
			end
			return true
		end
	-- 日選單選項-現實時間
	-- 建立日選單選項
		for i = 1, #days do 
			local strtDayTextBase = display.newRect( startDateDayScrollView.contentWidth/2, dateBasePadding+(dateBaseHeight*(i-1)), dateFrameWidth*0.96, dateBaseHeight)
			startDateDayScrollView:insert(strtDayTextBase)
			strtDayTextBase.id = i
			strtDayTextBase:addEventListener("touch", strtDayTextListener)

			strtDayText[i] = display.newText({
				text = days[i],
				font = getFont.font,
				fontSize = 18,
				x = startDateDayScrollView.contentWidth/2,
				y = strtDayTextBase.y,
			})
			startDateDayScrollView:insert(strtDayText[i])
			-- 判定日選項的日期
				if ( startDateYearSelectedText.text == thisDate.thisYear and startDateMonthSelectedText.text == thisDate.thisMonth) then
					startDateDaySelectedText.text = thisDate.thisDay
				else
					startDateDaySelectedText.text = days[1]
				end
			-- 判定當月已經過的日期
				if ( startDateYearSelectedText.text == thisDate.thisYear and startDateMonthSelectedText.text == thisDate.thisMonth and i<tonumber(thisDate.thisDay)) then 
					strtDayText[i]:setFillColor(unpack(separateLineColor))
					strtDayTextBase.name = "unselectable"
				else
					if ( strtDayText[i].text == startDateDaySelectedText.text ) then
						strtDayText[i]:setFillColor(unpack(subColor1))
						selected["preStartDayTarget"] = strtDayTextBase
					else
						strtDayText[i]:setFillColor(unpack(wordColor))
					end
					strtDayTextBase.name = "selectable"
				end
			-- 判斷ScrollView選項的位置
				local baseDay
				if ( #days - tonumber(thisDate.thisDay) < 3 ) then
					baseDay =  #days - 3
				else
					baseDay = tonumber(startDateDaySelectedText.text)
				end
				if ( i == baseDay) then
					yOfThisDay = -strtDayText[i].y+dateBasePadding
				end
		end
		-- 將ScrollView轉到相對應的位置
			startDateDayScrollView:scrollToPosition( { y = yOfThisDay, time = 500 } )
			startDateDayGroup.isVisible = false

	-- 月選單 --
	-- 選單外框
		startDateMonthGroup = display.newGroup()
		scrollViewGroup:insert(startDateMonthGroup)
		dropDownFrame["startMonth"] = display.newImageRect( "assets/shadow-320480.png", dateFrameWidth, dateFrameHeight )
		startDateMonthGroup:insert(dropDownFrame["startMonth"])
		dropDownFrame["startMonth"].anchorY = 0
		dropDownFrame["startMonth"].x = dropDownFrame["backMonth"].x
		dropDownFrame["startMonth"].y = startDateBaseLine.y+startDateBaseLine.strokeWidth
	-- 選單ScrollView
		local startDateMonthScrollView = widget.newScrollView({
				id = "startDateMonthScrollView",
				width = dateFrameWidth*0.95,
				height = dateFrameHeight*59/60,
				horizontalScrollDisabled = true,
				isBounceEnabled = false,
			})
		startDateMonthGroup:insert(startDateMonthScrollView)
		startDateMonthScrollView.anchorY = 0
		startDateMonthScrollView.x = dropDownFrame["startMonth"].x
		startDateMonthScrollView.y = dropDownFrame["startMonth"].y
	-- 月選單選項監聽事件
		local strtMonthText = {}
		selected["startMonthTarget"], selected["preStartMonthTarget"], selected["startMonthCancel"] = nil, nil, false
		local function strtMonthTextListener( event )
			local phase = event.phase
			local name = event.target.name
			local preSelectedMonth = startDateMonthSelectedText.text
			if ( phase == "began" and name == "selectable") then
				if ( selected["startMonthCancel"] == true ) then
					selected["startMonthCancel"] = false
				end
				if ( selected["startMonthTarget"] == nil and selected["preStartMonthTarget"] == nil ) then
					selected["startMonthTarget"] = event.target
					selected["startMonthTarget"]:setFillColor( 0, 0, 0, 0.1)
					strtMonthText[selected["startMonthTarget"].id]:setFillColor(unpack(subColor1))
				end
				if ( selected["startMonthTarget"] == nil and selected["preStartMonthTarget"] ~= nil ) then
					if ( event.target ~= selected["preStartMonthTarget"] ) then 
						
						strtMonthText[selected["preStartMonthTarget"].id]:setFillColor(unpack(wordColor))
						
						selected["startMonthTarget"] = event.target
						selected["startMonthTarget"]:setFillColor( 0, 0, 0, 0.1)
						strtMonthText[selected["startMonthTarget"].id]:setFillColor(unpack(subColor1))						
					end
				end
			end
			if ( phase == "moved" and name == "selectable" ) then
				local dy = math.abs(event.yStart-event.y)
				local dx = math.abs(event.xStart-event.x)
				if ( dy > 10 or dx > 0 ) then
					if ( selected["startMonthTarget"] ~= nil ) then
						startDateMonthScrollView:takeFocus(event)
						selected["startMonthTarget"]:setFillColor(1)
						strtMonthText[selected["startMonthTarget"].id]:setFillColor(unpack(wordColor))
						selected["startMonthTarget"] = nil
						if ( selected["preStartMonthTarget"] ~= nil ) then
							strtMonthText[selected["preStartMonthTarget"].id]:setFillColor(unpack(subColor1))
						end					
					end
				end
			end
			if ( phase == "ended" and name == "selectable" and selected["startMonthCancel"] == false and selected["startMonthTarget"] ~= nil ) then
				-- 選項被選定後執行的動作
					arrow["startMonth"]:rotate(180)
					setStatus["startDateMonthArrow"] = "down"
					setStatus["startDateMonthBase"] = "off"
					startDateMonthSelectedText.text = strtMonthText[event.target.id].text
					if( setStatus["startDateYearBase"] == "off" and setStatus["startDateDayBase"] == "off") then 
						optionTitleText["startDate"]:setFillColor(unpack(wordColor))
						startDateBaseLine:setStrokeColor(unpack(separateLineColor))
						startDateBaseLine.strokeWidth = 1
					end
				-- 選項選單變化
					selected["startMonthTarget"]:setFillColor(1)
					selected["preStartMonthTarget"] = selected["startMonthTarget"]
					selected["startMonthTarget"] = nil
					startDateMonthGroup.isVisible = false
					startDateDayCover.isVisible = false
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
							width = dateFrameWidth*0.95,
							height = dateFrameHeight*59/60,
							horizontalScrollDisabled = true,
							isBounceEnabled = false,
						})
						startDateDayGroup:insert(startDateDayScrollView)
						startDateDayScrollView.anchorY = 0
						startDateDayScrollView.x = dropDownFrame["startDay"].x
						startDateDayScrollView.y = dropDownFrame["startDay"].y
						-- 出發日期選單-建立新日選單選項
						for i = 1, #days do 
							local strtDayTextBase = display.newRect( startDateDayScrollView.contentWidth/2, dateBasePadding+(dateBaseHeight*(i-1)), startDateDayScrollView.contentWidth, dateBaseHeight)
							startDateDayScrollView:insert(strtDayTextBase)
							strtDayTextBase.id = i
							strtDayTextBase:addEventListener("touch",strtDayTextListener)
							strtDayText[i] = display.newText({
									text = days[i],
									font = getFont.font,
									fontSize = 18,
									x = startDateDayScrollView.contentWidth/2,
									y = strtDayTextBase.y,
								})
							startDateDayScrollView:insert(strtDayText[i])
							
							-- 判定日選項的日期
								if (startDateYearSelectedText.text == thisDate.thisYear and startDateMonthSelectedText.text == thisDate.thisMonth) then
									startDateDaySelectedText.text = thisDate.thisDay
								else
									startDateDaySelectedText.text = days[1]
								end
							-- 判定當月已經過的日期
								if (startDateYearSelectedText.text == thisDate.thisYear and startDateMonthSelectedText.text == thisDate.thisMonth and i<tonumber(thisDate.thisDay)) then 
									strtDayText[i]:setFillColor(unpack(separateLineColor))
									strtDayTextBase.name = "unselectable"
								else
									if ( strtDayText[i].text == startDateDaySelectedText.text ) then
										strtDayText[i]:setFillColor(unpack(subColor1))
										selected["preStartDayTarget"] = strtDayTextBase
									else
										strtDayText[i]:setFillColor(unpack(wordColor))
									end
									strtDayTextBase.name = "selectable"
								end
							-- 判斷ScrollView選項的位置
							if ( startDateYearSelectedText.text == thisDate.thisYear and startDateMonthSelectedText.text == thisDate.thisMonth) then 
								local baseDay
								if ( #days - tonumber(thisDate.thisDay) < 3 ) then
									baseDay =  #days - 3
								else
									baseDay = tonumber(startDateDaySelectedText.text)
								end
								if ( i == baseDay) then
									yOfThisDay = -strtDayText[i].y+dateBasePadding
								end
							else
								if ( i == tonumber(startDateDaySelectedText.text)) then
									yOfThisDay = -strtDayText[i].y+dateBasePadding
								end
							end
						end
						-- 將ScrollView轉到相對應的位置
						startDateDayScrollView:scrollToPosition( { y = yOfThisDay, time = 500 } )
						startDateDayGroup.isVisible = false
					end
			end
			return true
		end
	-- 月選單選項-現實時間
		for i = 1, #monthOption do
			local strtMonthTextBase = display.newRect(startDateMonthScrollView.contentWidth/2, dateBasePadding+(dateBaseHeight*(i-1)), dateFrameWidth*0.96, dateBaseHeight)
			startDateMonthScrollView:insert(strtMonthTextBase)
			strtMonthTextBase.id = i
			strtMonthTextBase:addEventListener("touch", strtMonthTextListener)
			strtMonthText[i] = display.newText({
				text = monthOption[i],
				font = getFont.font,
				fontSize = 18,
				x = startDateMonthScrollView.contentWidth*0.5,
				y = strtMonthTextBase.y,
			})
			startDateMonthScrollView:insert(strtMonthText[i])
			
			-- 判定月選項的月份
				if ( startDateYearSelectedText.text == thisDate.thisYear) then
					startDateMonthSelectedText.text = thisDate.thisMonth
				else
					startDateMonthSelectedText.text = monthOption[1]
				end
			-- 判定現實當年經過的月份
				if (startDateYearSelectedText.text == thisDate.thisYear and i<tonumber(thisDate.thisMonth)) then
					strtMonthText[i]:setFillColor(unpack(separateLineColor))
					strtMonthTextBase.name = "unselectable"
				else
					if (strtMonthText[i].text == startDateMonthSelectedText.text ) then
						strtMonthText[i]:setFillColor(unpack(subColor1))
						selected["preStartMonthTarget"] = strtMonthTextBase
					else
						strtMonthText[i]:setFillColor(unpack(wordColor))
					end
					strtMonthTextBase.name = "selectable"
				end
			-- 判斷ScrollView選項的位置
				local baseMonth
				if (#monthOption - thisDate.thisMonth < 3) then 
					baseMonth = #monthOption - 3
				else
					baseMonth = tonumber(startDateMonthSelectedText.text)
				end
				if (i == baseMonth) then
					yOfThisMonth = -strtMonthText[i].y+dateBasePadding
				end
		end
		-- 將ScrollView轉到相對應的位置
			startDateMonthScrollView:scrollToPosition( { y = yOfThisMonth, time = 500 } )
			startDateMonthGroup.isVisible = false

	-- 年選單 --
	-- 選單外框
		startDateYearGroup = display.newGroup()
		scrollViewGroup:insert(startDateYearGroup)
		dropDownFrame["startYear"] = display.newImageRect( "assets/shadow-320480.png", dateFrameWidth, dateFrameHeight*0.6)
		startDateYearGroup:insert(dropDownFrame["startYear"])
		dropDownFrame["startYear"].anchorY = 0
		dropDownFrame["startYear"].x = dropDownFrame["backYear"].x
		dropDownFrame["startYear"].y = startDateBaseLine.y+startDateBaseLine.strokeWidth
	-- 選單ScrollView
		local startDateYearScrollView = widget.newScrollView({
			id = "startDateYearScrollView",
			width = dateFrameWidth*0.95,
			height = dropDownFrame["startYear"].contentHeight*59/60,
			horizontalScrollDisabled = true,
			isBounceEnabled = false,
		})
		startDateYearGroup:insert(startDateYearScrollView)
		startDateYearScrollView.anchorY = 0
		startDateYearScrollView.x = dropDownFrame["startYear"].x
		startDateYearScrollView.y = dropDownFrame["startYear"].y
	-- 年選單選項監聽事件
		local strtYearText = {}
		selected["startYearTarget"], selected["preStartYearTarget"], selected["startYearCancel"] = nil, nil, false
		local function strtYearTextListener( event )
			local phase = event.phase
			local name = event.target.name
			local preSelectedYear = startDateYearSelectedText.text
			if ( phase == "began" ) then
				if ( selected["startYearCancel"] == true ) then
					selected["startYearCancel"] = false
				end
				if ( selected["startYearTarget"] == nil and selected["preStartYearTarget"] == nil ) then
					selected["startYearTarget"] = event.target
					selected["startYearTarget"]:setFillColor( 0, 0, 0, 0.1)
					strtYearText[selected["startYearTarget"].id]:setFillColor(unpack(subColor1))
				elseif ( selected["startYearTarget"] == nil and  selected["preStartYearTarget"] ~= nil ) then
					if ( event.target ~= selected["preStartYearTarget"] ) then
					
						strtYearText[selected["preStartYearTarget"].id]:setFillColor(unpack(wordColor))
						
						selected["startYearTarget"] = event.target
						selected["startYearTarget"]:setFillColor( 0, 0, 0, 0.1)
						strtYearText[selected["startYearTarget"].id]:setFillColor(unpack(subColor1))
					end
				end
			end
			if ( phase == "moved" ) then
				local dy = math.abs(event.yStart-event.y)
				local dx = math.abs(event.xStart-event.y)
				if ( dy > 10 or dx > 0 ) then 
					if ( selected["startYearTarget"] ~= nil ) then
						startDateYearScrollView:takeFocus(event)
						selected["startYearTarget"]:setFillColor(1)
						strtYearText[selected["startYearTarget"].id]:setFillColor(unpack(wordColor))
						selected["startYearTarget"] = nil
						if ( selected["preStartYearTarget"] ~= nil ) then
							strtYearText[selected["preStartYearTarget"].id]:setFillColor(unpack(subColor1))
						end
					end
				end	
			end
			if ( phase == "ended" and selected["startYearCancel"] == false and selected["startYearTarget"] ~= nil ) then				
				-- 選項被選定後執行的動作
					arrow["startYear"]:rotate(180)
					setStatus["startDateYearArrow"] = "down"
					setStatus["startDateYearBase"] = "off"
					startDateYearSelectedText.text = strtYearText[event.target.id].text					
					if( setStatus["startDateMonthBase"] == "off" and setStatus["startDateDayBase"] == "off") then 
						optionTitleText["startDate"]:setFillColor(unpack(wordColor))
						startDateBaseLine:setStrokeColor(unpack(separateLineColor))
						startDateBaseLine.strokeWidth = 1
					end
				-- 選項選單變化
					selected["startYearTarget"]:setFillColor(1)
					selected["preStartYearTarget"] = selected["startYearTarget"]
					selected["startYearTarget"] = nil
					startDateYearGroup.isVisible = false
					startDateMonthCover.isVisible = false
					startDateDayCover.isVisible = false
					
					if ( startDateYearSelectedText.text ~= preSelectedYear ) then
						-- 當選擇其他年份時將月份跟日期選單重置至該年的0101
						-- 重置月選單
							if ( startDateMonthScrollView ) then 
								selected["startMonthTarget"] = nil
								selected["preStartMonthTarget"] = nil
								selected["startMonth"] = false
								startDateMonthGroup:remove(startDateMonthScrollView)
								startDateMonthScrollView = nil
							end
						-- 配合選擇的年份再對應現實時間顯示月份
							if (startDateYearSelectedText.text == thisDate.thisYear) then
								startDateMonthSelectedText.text = thisDate.thisMonth
							else
								startDateMonthSelectedText.text = "01"
							end 
							startDateMonthScrollView = widget.newScrollView({
								id = "startDateMonthScrollView",
								width = dateFrameWidth*0.95,
								height = dateFrameHeight*59/60,
								horizontalScrollDisabled = true,
								isBounceEnabled = false,
							})
							startDateMonthGroup:insert(startDateMonthScrollView)
							startDateMonthScrollView.anchorY = 0
							startDateMonthScrollView.x = dropDownFrame["startMonth"].x
							startDateMonthScrollView.y = dropDownFrame["startMonth"].y
							for i = 1,#monthOption do
								local strtMonthTextBase = display.newRect(startDateMonthScrollView.contentWidth/2, dateBasePadding+(dateBaseHeight*(i-1)), startDateMonthScrollView.contentWidth, dateBaseHeight)
								startDateMonthScrollView:insert(strtMonthTextBase)
								strtMonthTextBase.id = i
								strtMonthTextBase:addEventListener("touch", strtMonthTextListener)
							
								strtMonthText[i] = display.newText({
									text = monthOption[i],
									font = getFont.font,
									fontSize = 18,
									x = startDateMonthScrollView.contentWidth*0.5,
									y = strtMonthTextBase.y,
								})
								startDateMonthScrollView:insert(strtMonthText[i])
								-- 判定月選項的月份
									if ( startDateYearSelectedText.text == thisDate.thisYear) then
										startDateMonthSelectedText.text = thisDate.thisMonth
									else
										startDateMonthSelectedText.text = monthOption[1]
									end
								-- 判定現實當年經過的月份
									if (startDateYearSelectedText.text == thisDate.thisYear and i<tonumber(thisDate.thisMonth)) then
										strtMonthText[i]:setFillColor(unpack(separateLineColor))
										strtMonthTextBase.name = "unselectable"
									else
										if (strtMonthText[i].text == startDateMonthSelectedText.text ) then
											strtMonthText[i]:setFillColor(unpack(subColor1))
											selected["preStartMonthTarget"] = strtMonthTextBase
										else
											strtMonthText[i]:setFillColor(unpack(wordColor))
										end
										strtMonthTextBase.name = "selectable"
									end
								-- 判斷ScrollView選項的位置
									if ( i == tonumber(startDateMonthSelectedText.text)) then
										yOfThisMonth = -strtMonthText[i].y+dateBasePadding
									end
							end
							-- 將ScrollView轉到相對應的位置
								startDateMonthScrollView:scrollToPosition( { y= yOfThisMonth, time = 500 } )
								startDateMonthGroup.isVisible = false
						-- 重置日選單
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
								width = dateFrameWidth*0.95,
								height = dateFrameHeight*59/60,
								horizontalScrollDisabled = true,
								isBounceEnabled = false,
							})
							startDateDayGroup:insert(startDateDayScrollView)
							startDateDayScrollView.anchorY = 0
							startDateDayScrollView.x = dropDownFrame["startDay"].x
							startDateDayScrollView.y = dropDownFrame["startDay"].y
						-- 出發日期選單-建立新日選單選項
						-- 重新建立日選項的日期順序
							for i = 1, #days do 
								local strtDayTextBase = display.newRect( startDateDayScrollView.contentWidth/2, dateBasePadding+(dateBaseHeight*(i-1)), startDateDayScrollView.contentWidth, dateBaseHeight)
								startDateDayScrollView:insert(strtDayTextBase)
								strtDayTextBase.id = i
								strtDayTextBase:addEventListener("touch",strtDayTextListener)
									
								strtDayText[i] = display.newText({
									text = days[i],
									font = getFont.font,
									fontSize = 18,
									x = startDateDayScrollView.contentWidth/2,
									y = strtDayTextBase.y,
								})
								startDateDayScrollView:insert(strtDayText[i])
								-- 判定日選項的日期
									if ( startDateYearSelectedText.text == thisDate.thisYear and startDateMonthSelectedText.text == thisDate.thisMonth) then
										startDateDaySelectedText.text = thisDate.thisDay
									else
										startDateDaySelectedText.text = days[1]
									end
								-- 判定現實當月已經過的日期
									if ( startDateYearSelectedText.text == thisDate.thisYear and startDateMonthSelectedText.text == thisDate.thisMonth and i<tonumber(thisDate.thisDay)) then 
										strtDayText[i]:setFillColor(unpack(separateLineColor))
										strtDayTextBase.name = "unselectable"
									else
										if ( strtDayText[i].text == startDateDaySelectedText.text ) then
											strtDayText[i]:setFillColor(unpack(subColor1))
											selected["preStartDayTarget"] = strtDayTextBase
										else
											strtDayText[i]:setFillColor(unpack(wordColor))
										end
										strtDayTextBase.name = "selectable"
									end
								-- 判斷ScrollView選項的位置
									if ( startDateYearSelectedText.text == thisDate.thisYear and startDateMonthSelectedText.text == thisDate.thisMonth) then 
										local baseDay
										if ( #days - tonumber(thisDate.thisDay) < 3 ) then
											baseDay =  #days - 3
										else
											baseDay = tonumber(startDateDaySelectedText.text)
										end
										if ( i == baseDay) then
											yOfThisDay = -strtDayText[i].y+dateBasePadding
										end
									else
										if ( i == tonumber(startDateDaySelectedText.text) ) then
											yOfThisDay = -strtDayText[i].y+dateBasePadding
										end
									end
							end
							-- 將ScrollView轉到相對應的位置
								startDateDayScrollView:scrollToPosition( { y = yOfThisDay, time = 500 } )
								startDateDayGroup.isVisible = false
					end
			end
			return true
		end
	-- 出發日期選單-年選單選項-現實時間
		for i = 1, #yearOption do
			local strtYearTextBase = display.newRect(startDateYearScrollView.contentWidth/2, dateBasePadding+(dateBaseHeight*(i-1)), dateFrameWidth*0.96, dateBaseHeight)
			startDateYearScrollView:insert(strtYearTextBase)
			strtYearTextBase.id = i
			strtYearTextBase:addEventListener("touch", strtYearTextListener)
			
			strtYearText[i] = display.newText({
				text = yearOption[i],
				font = getFont.font,
				fontSize = 18,
				x = startDateYearScrollView.contentWidth*0.5,
				y = strtYearTextBase.y,
			})
			startDateYearScrollView:insert(strtYearText[i])
			if (strtYearText[i].text == startDateYearSelectedText.text ) then
				strtYearText[i]:setFillColor(unpack(subColor1))
				selected["preStartYearTarget"] = strtYearTextBase
			else
				strtYearText[i]:setFillColor(unpack(wordColor))
			end
		end
		startDateYearGroup.isVisible = false
	------------------- 洲別/國家/地區下拉式選單 -------------------
	-- 通用參數
		local listFrameWidth = continentBaseLine.contentWidth*0.8
		local listFrameHeight = screenH*0.375
		local listBaseWidth = listFrameWidth*0.96
		local listBaseHeight = screenH/16
		local listBasePadding = listBaseHeight/3
	-- 洲別下拉式選單 --
	-- 外框
		continentGroup = display.newGroup()
		scrollViewGroup:insert(continentGroup)
		local contientGroupNum = scrollViewGroup.numChildren
		local contientListFrame = display.newImageRect( continentGroup, "assets/shadow-320480-paper.png", listFrameWidth, listFrameHeight)
		contientListFrame:addEventListener( "touch", function() return true; end)
		contientListFrame.anchorY = 0
		contientListFrame.x = baseScrollView.contentWidth*0.5
		contientListFrame.y = continentBaseLine.y+continentBaseLine.strokeWidth

		local contientScrollView = widget.newScrollView({
			id = "contientScrollView",
			x = baseScrollView.contentWidth*0.5,
			y = contientListFrame.y,
			width = listFrameWidth*0.95,
			height = listFrameHeight*59/60,
			isBounceEnabled = false,
			horizontalScrollDisabled = true,
			isLocked = true,
			backgroundColor = {1},
		})
		continentGroup:insert(contientScrollView)
		contientScrollView.anchorY = 0
		local contientScrollViewHeight = 0 
		local contientScrollViewGroup = display.newGroup()
		contientScrollView:insert(contientScrollViewGroup)
	-- 洲別選單內容監聽事件
		local continentListText = {}
		local cancelSelected = false
		local nowSelection, prevSelction = nil, nil
		local function continentListOptionListener( event )
			local  phase = event.phase
			if ( phase == "began" ) then
				if ( cancelSelected == true ) then
					cancelSelected = false
				end
				if ( nowSelection == nil and prevSelction == nil ) then
					nowSelection = event.target
					nowSelection:setFillColor( 0, 0, 0, 0.1)
					continentListText[nowSelection.id]:setFillColor(unpack(subColor2))
				elseif ( nowSelection == nil and prevSelction ~= nil ) then
					if ( event.target ~= prevSelction ) then
						
						continentListText[prevSelction.id]:setFillColor(unpack(wordColor))

						nowSelection = event.target
						nowSelection:setFillColor( 0, 0, 0, 0.1)
						continentListText[nowSelection.id]:setFillColor(unpack(subColor2))
					end
				end
			elseif ( phase == "moved" ) then
				cancelSelected = true
				local dx = math.abs(event.xStart-event.x)
				local dy = math.abs(event.yStart-event.y)
				if (dx > 10 or dy > 10) then
					if (nowSelection ~= nil) then
						contientScrollView:takeFocus(event)
						nowSelection:setFillColor(1)
						continentListText[nowSelection.id]:setFillColor(unpack(wordColor))
						nowSelection = nil
						if (prevSelction ~= nil) then
							continentListText[prevSelction.id]:setFillColor(unpack(subColor2))
						end
					end
				end
			elseif ( phase == "ended" and cancelSelected == false and nowSelection ~= nil ) then
				-- 洲別選框相關變化
					if ( continentListText[nowSelection.id].text ~= continentSelectedText.text ) then
						tripPointSelectedText.text = "請選擇"
						if ( tripRegionCover.isVisible == false ) then tripRegionCover.isVisible = true end
						tripRegionSelectedText.text = "請選擇"
						setCityId = nil
					end
					optionTitleText["continent"]:setFillColor(unpack(wordColor))
					continentSelectedText.text = continentListText[nowSelection.id].text
					continentBaseLine.strokeWidth = 1
					continentBaseLine:setStrokeColor(unpack(separateLineColor))
					arrow["continent"]:rotate(180)
					setStatus["continentArrow"] = "down"
				-- 選項選單變化
					nowSelection:setFillColor(1)
					prevSelction = nowSelection
					nowSelection = nil
					--contientSelected = true
					continentGroup.isVisible = false		

				-- 產生國家選項選單 --
				-- 接洲別產生國家API
					local continentDecode = json.decode(continentJson)
					local continentDecodeValue = continentSelectedText.text
					--print( continentDecode[continentDecodeValue] )
					local countryListOptions, countryIdList = {}, {}
					local function getCountryInfo( event )
						if ( event.isError ) then
							print( "Network Error: "..event.response )
						else
							--print( "Response: "..event.response )
							local countryJsonData = json.decode( event.response )
							for key, countryTableJson in pairs(countryJsonData["list"]) do
								--print( key, countryTableJson)
								--print(countryTableJson)
								--for k,v in pairs(countryTableJson) do
								--	print (k,v)
								--end
								-- 利用countryTableJson對應的 key, value獲取資訊
								table.insert( countryListOptions, countryTableJson["desc"])
								table.insert( countryIdList, countryTableJson["id"])
							end
						end
						
						-- 國家選單外框
							if ( countryGroup ) then
								countryGroup:removeSelf()
								countryGroup = nil
							end
							countryGroup = display.newGroup()
							scrollViewGroup:insert( contientGroupNum, countryGroup )
							local countryGroupNum = scrollViewGroup.numChildren
							local countryListFrame = display.newImageRect( countryGroup, "assets/shadow-320480-paper.png", listFrameWidth, listFrameHeight)
							countryListFrame:addEventListener( "touch", function() return true; end )
							countryListFrame.anchorY = 0
							countryListFrame.x = baseScrollView.contentWidth*0.5
							countryListFrame.y = tripPointBaseLine.y+tripPointBaseLine.strokeWidth

							local countryScrollView = widget.newScrollView({
								id = "countryScrollView",
								x = baseScrollView.contentWidth*0.5,
								y = countryListFrame.y,
								width = listFrameWidth*0.95,
								height = listFrameHeight*59/60,
								isBounceEnabled = false,
								horizontalScrollDisabled = true,
								isLocked = true,
								backgroundColor = {1},
							})
							countryGroup:insert(countryScrollView)
							countryScrollView.anchorY = 0
							local countryScrollViewHeight = 0 
							local countryScrollViewGroup = display.newGroup()
							countryScrollView:insert(countryScrollViewGroup)
						-- 國家選單內容監聽事件
							local countryListText = {}
							local cancelCountrySelected = false
							local nowCountrySelection, prevCountrySelction = nil, nil
							local function countryListOptionListener( event )
								local  phase = event.phase
								if ( phase == "began" ) then
									if ( cancelCountrySelected == true ) then
										cancelCountrySelected = false
									end
									if ( nowCountrySelection == nil and prevCountrySelction == nil ) then
										nowCountrySelection = event.target
										nowCountrySelection:setFillColor( 0, 0, 0, 0.1)
										countryListText[nowCountrySelection.id]:setFillColor(unpack(subColor2))
									elseif ( nowCountrySelection == nil and prevCountrySelction ~= nil ) then
										if ( event.target ~= prevCountrySelction ) then
											
											countryListText[prevCountrySelction.id]:setFillColor(unpack(wordColor))

											nowCountrySelection = event.target
											nowCountrySelection:setFillColor( 0, 0, 0, 0.1)
											countryListText[nowCountrySelection.id]:setFillColor(unpack(subColor2))
										end
									end
								elseif ( phase == "moved" ) then
									cancelCountrySelected = true
									local dx = math.abs(event.xStart-event.x)
									local dy = math.abs(event.yStart-event.y)
									if (dx > 10 or dy > 10) then
										if (nowCountrySelection ~= nil) then
											countryScrollView:takeFocus(event)
											nowCountrySelection:setFillColor(1)
											countryListText[nowCountrySelection.id]:setFillColor(unpack(wordColor))
											nowCountrySelection = nil
											if (prevCountrySelction ~= nil) then
												countryListText[prevCountrySelction.id]:setFillColor(unpack(subColor2))
											end
										end
									end
								elseif ( phase == "ended" and cancelCountrySelected == false and nowCountrySelection ~= nil ) then
									-- 國家選框相關變化
										if ( countryListText[nowCountrySelection.id].text ~= tripPointSelectedText.text ) then
											tripRegionSelectedText.text = "請選擇"
											setCityId = nil
										end
										optionTitleText["tripPoint"]:setFillColor(unpack(wordColor))
										tripPointSelectedText.text = countryListText[nowCountrySelection.id].text
										tripPointBaseLine.strokeWidth = 1
										tripPointBaseLine:setStrokeColor(unpack(separateLineColor))
										arrow["tripPoint"]:rotate(180)
										setStatus["tripPointArrow"] = "down"
									-- 選項選單變化
										local countryId = countryIdList[nowCountrySelection.id]
										nowCountrySelection:setFillColor(1)
										prevCountrySelction = nowCountrySelection
										nowCountrySelection = nil
										countryGroup.isVisible = false
										tripPointSelected = true
										--countrySelected = true

									-- 產生地區選項選單 --
									-- 接國家產生地區API
										local regionListOptions, regionIdList = {}, {}
										local function getRegionInfo( event )
											if ( event.isError ) then
												print( "Network Error: "..event.response )
											else
												--print( "Response: "..event.response )
												local regionJsonData = json.decode( event.response )
												for key, regionTableJson in pairs(regionJsonData["list"]) do
													--print( key, regionTableJson)
													--print(regionTableJson)
													table.insert( regionListOptions, regionTableJson["desc"])
													table.insert( regionIdList, regionTableJson["id"])
												end
											end
											
											-- 地區選單外框
												if ( regionGroup ) then
													regionGroup:removeSelf()
													regionGroup = nil
												end
												regionGroup = display.newGroup()
												scrollViewGroup:insert( contientGroupNum, regionGroup )
												local regionListFrame = display.newImageRect( regionGroup, "assets/shadow-320480-paper.png", listFrameWidth, listFrameHeight)
												regionListFrame:addEventListener("touch", function () return true; end)
												regionListFrame.anchorY = 0
												regionListFrame.x = baseScrollView.contentWidth*0.5
												regionListFrame.y = tripRegionBaseLine.y+tripRegionBaseLine.strokeWidth

												local regionScrollView = widget.newScrollView({
													id = "regionScrollView",
													x = baseScrollView.contentWidth*0.5,
													y = regionListFrame.y,
													width = listFrameWidth*0.95,
													height = listFrameHeight*59/60,
													isBounceEnabled = false,
													horizontalScrollDisabled = true,
													isLocked = true,
													backgroundColor = {1},
												})
												regionGroup:insert(regionScrollView)
												regionScrollView.anchorY = 0
												local regionScrollViewHeight = 0 
												local regionScrollViewGroup = display.newGroup()
												regionScrollView:insert(regionScrollViewGroup)
											-- 地區選單內容監聽事件
												local regionListText = {}
												local cancelRegionSelected = false
												local nowRegionSelection, prevRegionSelction = nil, nil
												local function regionListOptionListener( event )
													local  phase = event.phase
													if ( phase == "began" ) then
														if ( cancelRegionSelected == true ) then
															cancelRegionSelected = false
														end
														if ( nowRegionSelection == nil and prevRegionSelction == nil ) then
															nowRegionSelection = event.target
															nowRegionSelection:setFillColor( 0, 0, 0, 0.1)
															regionListText[nowRegionSelection.id]:setFillColor(unpack(subColor2))
														elseif ( nowRegionSelection == nil and prevRegionSelction ~= nil ) then
															if ( event.target ~= prevRegionSelction ) then
																
																regionListText[prevRegionSelction.id]:setFillColor(unpack(wordColor))

																nowRegionSelection = event.target
																nowRegionSelection:setFillColor( 0, 0, 0, 0.1)
																regionListText[nowRegionSelection.id]:setFillColor(unpack(subColor2))
															end
														end
													elseif ( phase == "moved" ) then
														cancelRegionSelected = true
														local dx = math.abs(event.xStart-event.x)
														local dy = math.abs(event.yStart-event.y)
														if (dx > 10 or dy > 10) then
															if (nowRegionSelection ~= nil) then
																regionScrollView:takeFocus(event)
																nowRegionSelection:setFillColor(1)
																regionListText[nowRegionSelection.id]:setFillColor(unpack(wordColor))
																nowRegionSelection = nil
																if (prevRegionSelction ~= nil) then
																	regionListText[prevRegionSelction.id]:setFillColor(unpack(subColor2))
																end
															end
														end
													elseif ( phase == "ended" and cancelRegionSelected == false and nowRegionSelection ~= nil ) then
														-- 地區選框相關變化
															optionTitleText["tripRegion"]:setFillColor(unpack(wordColor))
															tripRegionSelectedText.text = regionListText[nowRegionSelection.id].text
															tripRegionBaseLine.strokeWidth = 1
															tripRegionBaseLine:setStrokeColor(unpack(separateLineColor))
															arrow["tripRegion"]:rotate(180)
															setStatus["tripRegionArrow"] = "down"
														-- 選項選單變化
															setCityId = regionIdList[nowRegionSelection.id]
															nowRegionSelection:setFillColor(1)
															prevRegionSelction = nowRegionSelection
															nowRegionSelection = nil
															regionGroup.isVisible = false
															--regionSelected = true
													end
													return true
												end
											-- 地區選單內容
												for i = 1, #regionListOptions do
													local regionListBase = display.newRect( regionScrollViewGroup, regionScrollView.contentWidth*0.5, listBasePadding+(listBaseHeight+listBasePadding)*(i-1), listBaseWidth, listBaseHeight )
													regionListBase.anchorY = 0
													regionListBase.id = i
													regionListBase:addEventListener( "touch", regionListOptionListener)
													--regionListBase:setFillColor( math.random(), math.random(), math.random())

													regionListText[i] = display.newText({
														parent = regionScrollViewGroup,
														text = regionListOptions[i],
														font = getFont.font,
														fontSize = 12,
														x = regionListBase.x,
														y = regionListBase.y+regionListBase.contentHeight*0.5,
													})
													regionListText[i]:setFillColor(unpack(wordColor))
													
													if ( i == #regionListOptions ) then
														regionScrollViewHeight = regionListBase.y+regionListBase.contentHeight+listBasePadding
														if ( regionScrollViewHeight > regionScrollView.contentHeight ) then
															regionScrollView:setScrollHeight( regionScrollViewHeight )
															regionScrollView:setIsLocked( false, "vertical")
														end
													end
												end
												regionGroup.isVisible = false
												tripRegionCover.isVisible = false
										end
										local getRegionUrl = optionsTable.getCityByCountryUrl..countryId
										network.request( getRegionUrl, "GET", getRegionInfo)
								end
								return true
							end
						-- 國家選單內容
							for i = 1, #countryListOptions do
								local countryListBase = display.newRect( countryScrollViewGroup, countryScrollView.contentWidth*0.5, listBasePadding+(listBaseHeight+listBasePadding)*(i-1), listBaseWidth, listBaseHeight )
								countryListBase.anchorY = 0
								countryListBase.id = i
								countryListBase:addEventListener( "touch", countryListOptionListener)
								--countryListBase:setFillColor( math.random(), math.random(), math.random())

								countryListText[i] = display.newText({
									parent = countryScrollViewGroup,
									text = countryListOptions[i],
									font = getFont.font,
									fontSize = 12,
									x = countryListBase.x,
									y = countryListBase.y+countryListBase.contentHeight*0.5,
								})
								countryListText[i]:setFillColor(unpack(wordColor))
								
								if ( i == #countryListOptions ) then
									countryScrollViewHeight = countryListBase.y+countryListBase.contentHeight+listBasePadding
									if ( countryScrollViewHeight > countryScrollView.contentHeight ) then
										countryScrollView:setScrollHeight( countryScrollViewHeight )
										countryScrollView:setIsLocked( false, "vertical")
									end
								end
							end	
							countryGroup.isVisible = false
							tripPointCover.isVisible = false
					end
					local getCountryUrl = optionsTable.getCountryByContinentUrl..continentDecode[continentDecodeValue]
					network.request( getCountryUrl, "GET", getCountryInfo)	
			end
			return true
		end
	-- 洲別選單內容
		for i = 1, #continentOptions do
			local contientListBase = display.newRect( contientScrollViewGroup, contientScrollView.contentWidth*0.5, listBasePadding+(listBaseHeight+listBasePadding)*(i-1), listBaseWidth, listBaseHeight )
			contientListBase.anchorY = 0
			contientListBase.id = i
			contientListBase:addEventListener( "touch", continentListOptionListener)
			--contientListBase:setFillColor( math.random(), math.random(), math.random())

			continentListText[i] = display.newText({
				parent = contientScrollViewGroup,
				text = continentOptions[i],
				font = getFont.font,
				fontSize = 12,
				x = contientListBase.x,
				y = contientListBase.y+contientListBase.contentHeight*0.5,
			})
			continentListText[i]:setFillColor(unpack(wordColor))
			
			if ( i == #continentOptions ) then
				contientScrollViewHeight = contientListBase.y+contientListBase.contentHeight+listBasePadding
				if ( contientScrollViewHeight > contientScrollView.contentHeight ) then
					contientScrollView:setScrollHeight( contientScrollViewHeight )
					contientScrollView:setIsLocked( false, "vertical")
				end
			end
		end	
		continentGroup.isVisible = false		
	------------------- 抬頭下拉式選單 -------------------
	-- 選單邊界
		local listOptions = optionsTable.TP_titleListOptions
		local listOptionScenes = optionsTable.TP_titleListScenes
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
		for i = 1, #listOptions do
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
		composer.removeScene("TP_myTripV6")
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