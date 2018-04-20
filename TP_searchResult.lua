-----------------------------------------------------------------------------------------
--
-- TP_searchResult.lua
--
-----------------------------------------------------------------------------------------
local widget = require ("widget")
local composer = require ("composer")
local mainTabBar = require("mainTabBar")
local getFont = require("setFont")
local optionsTable = require("optionsTable")
 
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

local setStatus = {}

local ceil = math.ceil
local floor = math.floor

-- create()
function scene:create( event )
	local sceneGroup = self.view
	mainTabBar.myTabBarHidden()
	local getFromScene = event.params.setFromScene
	--local prevScene = composer.getSceneName("previous")
	local getContinent = event.params.setContinent
	local getCountry = event.params.setCountry
	local getCity = event.params.setCity
	local getGender = event.params.setGender
	--print( getContinent, getCountry, getCity, getGender )
	------------------- 抬頭元件 -------------------
	-- 白底
		local titleBase = display.newRect(0, 0, screenW+ox+ox, floor(178*hRate))
		sceneGroup:insert(titleBase)
		titleBase.x = cx
		titleBase.y = -oy+titleBase.contentHeight*0.5
	-- 抬頭陰影
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
			onRelease = function()
				local options = { time = 300, effect = "flipFadeOutIn"}
					composer.gotoScene( getFromScene, options)
				return true
			end,
		})
		sceneGroup:insert( backArrowNum, backBtn)
	-- 顯示文字-"搜尋結果"
		local titleText = display.newText({
			text = "搜尋結果",
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
	 		onRelease = function()
	 			if (setStatus["listBtn"] == "up") then 
					setStatus["listBtn"] = "down"
					transition.to(titleListGroup,{ y = -titleListBoundary.contentHeight, time = 200})
					timer.performWithDelay(200, function() titleListBoundary.isVisible = false ;end)
				else
					setStatus["listBtn"] = "up"
					titleListBoundary.isVisible = true
					transition.to(titleListGroup,{ y = 0, time = 200})
				end
				return true
	 		end,
	 	})
	 	sceneGroup:insert(listIconNum,listBtn)
	 	setStatus["listBtn"] = "down"
	------------------- 搜尋結果 -------------------
	-- 結果文字
		local setResultText
		if ( getFromScene == "TP_findPartner" ) then
			setResultText = getContinent.."/"..getCountry.."/"..getCity
		elseif ( getFromScene == "TP_memberSearch" ) then
			setResultText = getContinent.."/"..getCountry.."/"..getGender
		end
		local resultText = display.newText({
			text = setResultText,
			font = getFont.font,
			fontSize = 12,
		})
		sceneGroup:insert(resultText)
		resultText:setFillColor(unpack(mainColor1))
		resultText.anchorX = 0
		resultText.x = -ox + ceil(40*wRate)
		resultText.y = titleBase.y+titleBase.contentHeight*0.5+(50*hRate)+resultText.contentHeight*0.5
		local resultNum = 7
		local resultNumText = display.newText({
				text = " "..tostring(resultNum).."個結果",
				font = getFont.font,
				fontSize = 12,
			})
		sceneGroup:insert(resultNumText)
		resultNumText:setFillColor(unpack(wordColor))
		resultNumText.anchorX = 0
		resultNumText.x = resultText.x+resultText.contentWidth
		resultNumText.y = resultText.y
	-- 顯示圖像的ScrollView
		local resultScrollView = widget.newScrollView({
			id = "resultScrollView",
			width = screenW+ox+ox,
			height = screenH+oy+oy-titleBase.contentHeight,
			horizontalScrollDisabled = true,
			isBounceEnabled = true,
			backgroundColor = backgroundColor,
			isLocked = true,
		})
		sceneGroup:insert(resultScrollView)
		resultScrollView.anchorY = 0
		resultScrollView.x = cx
		resultScrollView.y = resultText.y+(resultText.contentHeight/2)
	-- 圖像排序
		local resultScrollViewGroup = display.newGroup()
		resultScrollView:insert(resultScrollViewGroup)
		local yBasement = 0
		local xBasement
		local getNameTable = {}
		for i = 1, resultNum do
			getNameTable[i] = "鬼子"..i.."號"
		end
		-- 觸碰頭像到個人介紹
		local function tapToIntrodunction(event)
			composer.setVariable("partnerName", getNameTable[event.target.id])
			print(getNameTable[event.target.id])
			options = { time = 300, effect = "fade", params = { setFromScene = getFromScene } }
			composer.gotoScene("TP_resultInfomation",options)
		end
		for i = 1, resultNum do
			xBasement = ((i-1)%3)
			if (i > 1 and xBasement == 0 ) then
				yBasement = yBasement+1
			end
			-- 陰影底圖	
				local resultViewBase = display.newRect( 0, 0, floor(320*wRate), screenH/3)
				resultScrollViewGroup:insert(resultViewBase)
				resultViewBase.anchorX = 0
				resultViewBase.anchorY = 0
				resultViewBase.x = ceil(40*wRate)+(resultViewBase.contentWidth+ceil(20*wRate))*xBasement
				resultViewBase.y = ceil(50*hRate)+resultViewBase.contentHeight*yBasement
				resultViewBase.fill = { type = "image", filename = "assets/paper-findmember.png"}
				resultViewBase.id = i
				resultViewBase:addEventListener("tap",tapToIntrodunction)
			-- 頭像
				local resultViewPic = display.newRoundedRect( 0, 0, resultViewBase.contentWidth*0.8, resultViewBase.contentHeight*0.45, 2)
				resultScrollViewGroup:insert(resultViewPic)
				resultViewPic:setFillColor(unpack(separateLineColor))
				resultViewPic.x = resultViewBase.x+resultViewBase.contentWidth*0.5
				resultViewPic.y = resultViewBase.y+resultViewBase.contentHeight*0.3
				resultViewPic.fill = { type = "image", filename = "assets/wow.jpg"}
			-- 顯示文字-姓名
				local name = display.newText({
					text = getNameTable[i],
					font = getFont.font,
					fontSize = 12,
				})
				resultScrollViewGroup:insert(name)
				name:setFillColor(unpack(wordColor))
				name.anchorX = 0
				name.anchorY = 0
				name.x = resultViewPic.x-resultViewPic.contentWidth*0.5
				name.y = resultViewPic.y+resultViewPic.contentHeight*0.5+ceil(20*hRate)
			-- 顯示文字-出發日期
				local startDateText = display.newText({
					text = "3068/04/87 -",
					font = getFont.font,
					fontSize = 12,
				})
				resultScrollViewGroup:insert(startDateText)
				startDateText:setFillColor(unpack(wordColor))
				startDateText.anchorX = 0
				startDateText.anchorY = 0 
				startDateText.x = name.x
				startDateText.y = name.y+name.contentHeight+ceil(20*hRate)
			-- 顯示文字-回程日期
				local endDateText = display.newText({
					text = "3068/09/78",
					font = getFont.font,
					fontSize = 12,
				})
				resultScrollViewGroup:insert(endDateText)
				endDateText:setFillColor(unpack(wordColor))
				endDateText.anchorX = 0
				endDateText.anchorY = 0
				endDateText.x = startDateText.x
				endDateText.y = startDateText.y+startDateText.contentHeight+ceil(20*hRate)
		end
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
	-- 選項內容
		for i = 1, #listOptions do
			-- 選項白底
			local optionBase = display.newRect( titleListScrollViewGroup, titleListScrollView.contentWidth*0.5, 0, titleListScrollView.contentWidth, optionBaseHeight)
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
		composer.removeScene("TP_searchResult")
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