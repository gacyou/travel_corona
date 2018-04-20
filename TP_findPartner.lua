-----------------------------------------------------------------------------------------
--
-- TP_findPartner.lua
--
-----------------------------------------------------------------------------------------
local widget = require ("widget")
local composer = require ("composer")
local mainTabBar = require("mainTabBar")
local getFont = require("setFont")
local json = require("json")
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

local mainTabBarHeight = composer.getVariable("mainTabBarHeight")

local continentOptions = { "亞洲", ["亞洲"] = 1, "歐洲", ["歐洲"] = 2, "北美洲", ["北美洲"] = 5, "南美洲", ["南美洲"] = 7 }
local continentJson = json.encode( continentOptions )

local country = { {"台灣","Taiwan"}, {"日本","Japan"}, {"韓國","Korea"}, {"美國","America"}, {"加拿大","Canada"}, {"德國","Germany"}, {"非洲","Africa"}}
local region = { Taiwan = { "台北", "台中", "高雄" }, Japan = { "東京", "大阪", "京都"}, Korea = {"首爾","釜山"}, America = {"敬請期待"}, Canada = {"敬請期待"}, Germany = {"敬請期待"}, Africa = {"敬請期待"} }
-- print(region.Taiwan)    -- Sub Table
-- print(region.Taiwan[1]) -- 台北
-- print(#region.Taiwan)   -- 3
-- local a = { {"台灣","Taiwan"}, {"日本","Japan"}}
-- print(a[1][1])  -- 台灣
-- print(a[1][2])  -- Taiwan => 可以用 region[a[1][2]] 接此參數進一步獲得地區的資訊
-- 也可以 local b = a[1][2] print(region[b]) 進一步獲得地區的資訊

local titleListBoundary, titleListGroup
local continentGroup, countryGroup, regionGroup
local continentSelected, countrySelected, regionSelected = false, false, false
local setStatus = {}

local ceil = math.ceil
local floor = math.floor

local frameVertices = {	
	0, 0, 
	floor(826*wRate)+ox+ox, 0,
	floor(826*wRate)+ox+ox, floor(85*hRate),	 
	0, floor(85*hRate)
}
local triangleVertices = { 260, 165, 266, 165, 263, 169}


-- create()
function scene:create( event )
	local sceneGroup = self.view
	mainTabBar.myTabBarShown()
	------------------- 抬頭元件 -------------------
	-- 白底
		local titleBase = display.newRect( cx, 0, screenW+ox+ox, floor(178*hRate))
		sceneGroup:insert(titleBase)
		titleBase.y = -oy+titleBase.contentHeight*0.5
	-- 返回按鈕圖片
		local backArrow = display.newImage( sceneGroup, "assets/btn-back-b.png",-ox+ceil(49*wRate), -oy+titleBase.contentHeight*0.5)
		backArrow.width = (backArrow.width*0.07)
		backArrow.height = (backArrow.height*0.07)
		backArrow.anchorX = 0
		local backArrowNum = sceneGroup.numChildren
		backArrow.isVisible = false
	-- 返回按鈕(本頁不需要所以隱藏)
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
		backBtn.isVisible = false
	-- 顯示文字-"尋找旅伴"
		local titleText = display.newText({
			text = "尋找旅伴",
			y = backBtn.y,
			font = getFont.font,
			fontSize = 14,
		})
		sceneGroup:insert(titleText)
		titleText:setFillColor(unpack(wordColor))
		titleText.anchorX = 0
		titleText.x = backArrow.x+backArrow.contentWidth+(30*wRate)
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
	 		onRelease = function ( event )
	 			if (setStatus["listBtn"] == "up") then 
	 				setStatus["listBtn"] = "down"
	 				transition.to(titleListGroup,{ y = -titleListBoundary.contentHeight, time = 200})
	 				timer.performWithDelay(200, function() titleListBoundary.isVisible = false ;end)
	 			else
	 				setStatus["listBtn"] = "up"
	 				titleListBoundary.isVisible = true
	 				transition.to(titleListGroup,{ y = 0, time = 200})
	 			end
	 		end,
	 	})
	 	sceneGroup:insert(listIconNum,listBtn)
	 	setStatus["listBtn"] = "down"
	------------------- 功能元件 -------------------
	-- baseScrollView --
		local baseScrollView = widget.newScrollView({
			id = "baseScrollView",
			left = -ox,
			top = titleBase.y+titleBase.contentHeight*0.5,
			width = screenW+ox+ox,
			height = screenH+oy+oy-(titleBase.contentHeight+mainTabBarHeight),
			horizontalScrollDisabled = true,
			isBounceEnabled = false,
			isLocked = true,
		})
		sceneGroup:insert(baseScrollView)
		local baseScrollveiwX = baseScrollView.contentWidth*0.5
		local baseScrollveiwY = 0
		local scrollviewWidth = baseScrollView.contentWidth
		local scrollciewX = scrollviewWidth*0.5
		local baseScrollViewHeight = 0
		local baseScrollViewGroup = display.newGroup()
		baseScrollView:insert(baseScrollViewGroup)
	
	-- 藍色底圖顯示元件 --
	-- 藍色底圖
		local blueBase = display.newImageRect("assets/mate-bg.png",1080,506)
		baseScrollViewGroup:insert(blueBase)
		blueBase.width = screenW+ox+ox
		blueBase.height = floor(455*hRate)
		blueBase.x = scrollciewX
		blueBase.y = blueBase.contentHeight*0.5
	-- 底圖文字
		local findPartnerTitleText = display.newEmbossedText({
			text = "來喔！來尋找旅伴喔!",
			font = getFont.font,
			fontSize = 18,
		})
		baseScrollViewGroup:insert(findPartnerTitleText)
		findPartnerTitleText.x = blueBase.x
		findPartnerTitleText.y = blueBase.y-(blueBase.contentHeight*0.15)
		local color = {
			highlight = { r = 0, g = 0, b = 0 },
			shadow = { r = 1, g = 1, b =1  }
		}
		findPartnerTitleText:setEmbossColor( color )
	
	-- 尋找旅伴選項元件 --
	-- 尋找旅伴選項外框
	-- 圖示-tag-find.png
		local findTag = display.newImageRect("assets/tag-find.png", 404, 135)
		baseScrollViewGroup:insert(findTag)
		findTag.anchorX = 0
		findTag.anchorY = 0
		findTag.width = findTag.width*wRate+ox*0.9
		findTag.height = findTag.height*hRate
		findTag.x = ceil(20*wRate)
		findTag.y = floor(568*hRate)-titleBase.contentHeight
		local findTagNum = baseScrollViewGroup.numChildren
	-- 圖示-0301matesearch-paper.png
		local findPaper = display.newImageRect("assets/0301matesearch-paper.png", 1007, 1024)
		baseScrollViewGroup:insert(findTagNum, findPaper)
		findPaper.anchorX = 0
		findPaper.anchorY = 0
		findPaper.width = findPaper.width*wRate+ox+ox
		findPaper.height = findPaper.height*hRate
		findPaper.x = findTag.x+ceil(20*wRate)
		findPaper.y = findTag.y+ceil(10*hRate)
	-- 顯示文字-"尋找旅伴"
		local findPartnerText = display.newText({
			text = "尋找旅伴",
			font = getFont.font,
			fontSize = 14,
		})
		baseScrollViewGroup:insert(findPartnerText)
		findPartnerText.anchorX = 0
		findPartnerText.x = ceil(128*wRate)
		findPartnerText.y = findTag.y+(90*hRate)*0.5
	
	-- 洲別元件
	-- 顯示文字-"洲別"
		local continentText = display.newText({
			text = "洲別",
			font = getFont.font,
			fontSize = 14,
		})
		baseScrollViewGroup:insert(continentText)
		continentText:setFillColor(unpack(wordColor))
		continentText.anchorX = 0
		continentText.anchorY = 0
		continentText.x = findPartnerText.x
		continentText.y = findTag.y+findTag.contentHeight
	-- 洲別選項外框
		local continentFrame = display.newPolygon( cx, cy, frameVertices)
		baseScrollViewGroup:insert(continentFrame)
		continentFrame.name = "continentFrame"
		continentFrame.strokeWidth = 1
		continentFrame:setStrokeColor(unpack(separateLineColor))
		continentFrame.anchorX = 0
		continentFrame.anchorY = 0
		continentFrame.x = continentText.x
		continentFrame.y = continentText.y+continentText.contentHeight+floor(20*hRate)
	-- 顯示文字-"請選擇"
		local continentFrameText = display.newText({
			text = "請選擇",
			font = getFont.font,
			fontSize = 14,
		})
		baseScrollViewGroup:insert(continentFrameText)
		continentFrameText:setFillColor(unpack(wordColor))
		continentFrameText.anchorX = 0
		continentFrameText.x = continentFrame.x+ceil(25*wRate)
		continentFrameText.y = continentFrame.y+continentFrame.contentHeight*0.5
	-- 洲別選項的三角形
		local continentFrameTriangle = display.newPolygon ( continentFrame.x+continentFrame.contentWidth-ceil(40*wRate), continentFrameText.y, triangleVertices)
		baseScrollViewGroup:insert(continentFrameTriangle)
		continentFrameTriangle.strokeWidth = 2
		continentFrameTriangle:setStrokeColor(0)
		continentFrameTriangle:setFillColor(0)
		continentFrameTriangle.x = continentFrameTriangle.x - continentFrameTriangle.contentWidth*0.5
		setStatus["continentFrameTriangle"] = "down"

	-- 國家元件
	-- 顯示文字-國家
		local countryText = display.newText({
				text = "國家",
				font = getFont.font,
				fontSize = 14,
			})
		baseScrollViewGroup:insert(countryText)
		countryText:setFillColor(unpack(wordColor))
		countryText.anchorX = 0
		countryText.anchorY = 0
		countryText.x = continentText.x
		countryText.y = continentFrame.y+continentFrame.contentHeight+floor(30*hRate)
	-- 國家選項外框
		local countryFrame = display.newPolygon(cx,cy,frameVertices)
		baseScrollViewGroup:insert(countryFrame)
		countryFrame.name = "countryFrame"
		countryFrame.strokeWidth = 1
		countryFrame:setStrokeColor(unpack(separateLineColor))
		countryFrame.anchorX = 0
		countryFrame.anchorY = 0
		countryFrame.x = countryText.x
		countryFrame.y = countryText.y+countryText.contentHeight+floor(20*hRate)
	-- 顯示文字-"請選擇"
		local countryFrameText = display.newText({
				text = "請選擇",
				font = getFont.font,
				fontSize = 14,
			})
		baseScrollViewGroup:insert(countryFrameText)
		countryFrameText:setFillColor(unpack(wordColor))
		countryFrameText.anchorX = 0
		countryFrameText.x = continentFrameText.x
		countryFrameText.y = countryFrame.y+countryFrame.contentHeight*0.5
	-- 國家選項的三角形
		local countryFrameTriangle = display.newPolygon ( continentFrameTriangle.x, countryFrameText.y, triangleVertices)
		baseScrollViewGroup:insert(countryFrameTriangle)
		countryFrameTriangle.strokeWidth = 2
		countryFrameTriangle:setStrokeColor(0)
		countryFrameTriangle:setFillColor(0)
		setStatus["countryFrameTriangle"] = "down"
	-- 國家選項遮罩
		local countryCover = display.newRect( baseScrollViewGroup, baseScrollView.contentWidth*0.5, countryText.y, countryFrame.contentWidth+ox, countryFrame.y+countryFrame.contentHeight-countryText.y )
		countryCover.anchorY = 0
		countryCover:setFillColor( 1, 1, 1, 0.7)
		countryCover:addEventListener( "touch", function() return true; end)
	
	-- 地區元件
	-- 顯示文字-地區
		local regionText = display.newText({
				text = "地區",
				font = getFont.font,
				fontSize = 14,
			})
		baseScrollViewGroup:insert(regionText)
		regionText:setFillColor(unpack(wordColor))
		regionText.anchorX = 0
		regionText.anchorY = 0
		regionText.x = continentText.x
		regionText.y = countryFrame.y+countryFrame.contentHeight+floor(30*hRate)
	-- 地區選項的外框
		local regionFrame = display.newPolygon( cx, cy, frameVertices)
		baseScrollViewGroup:insert(regionFrame)
		regionFrame.name = "regionFrame"
		regionFrame.strokeWidth = 1
		regionFrame:setStrokeColor(unpack(separateLineColor))
		regionFrame.anchorX = 0
		regionFrame.anchorY = 0
		regionFrame.x = regionText.x
		regionFrame.y = regionText.y+regionText.contentHeight+floor(20*hRate)
	-- 顯示文字-"請選擇"
		local regionFrameText = display.newText({
				text = "請選擇",
				font = getFont.font,
				fontSize = 14,
			})
		baseScrollViewGroup:insert(regionFrameText)
		regionFrameText:setFillColor(unpack(wordColor))
		regionFrameText.anchorX = 0
		regionFrameText.x = continentFrameText.x
		regionFrameText.y = regionFrame.y+regionFrame.contentHeight*0.5
	-- 地區選項內的三角形
		local regionFrameTriangle = display.newPolygon( continentFrameTriangle.x, regionFrameText.y, triangleVertices)
		baseScrollViewGroup:insert(regionFrameTriangle)
		regionFrameTriangle.strokeWidth = 2
		regionFrameTriangle:setStrokeColor(0)
		regionFrameTriangle:setFillColor(0)
		setStatus["regionFrameTriangle"] = "down"	
	-- 國家選項遮罩
		local regionCover = display.newRect( baseScrollViewGroup, baseScrollView.contentWidth*0.5, regionText.y, regionFrame.contentWidth+ox, regionFrame.y+regionFrame.contentHeight-regionText.y )
		regionCover.anchorY = 0
		regionCover:setFillColor( 1, 1, 1, 0.7)
		regionCover:addEventListener( "touch", function() return true; end)
	-- 洲別/國家/地區選項外框監聽事件
		local function frameListener( event )
			local name = event.target.name
			local phase = event.phase
			if ( phase == "moved" ) then
				local dy = math.abs( event.yStart - event.y )
				if ( dy > 10 ) then
					baseScrollView:takeFocus(event)
				end
			elseif ( phase == "ended" ) then
				if ( name == "continentFrame" ) then
					continentFrameTriangle:rotate(180)
					if (setStatus["continentFrameTriangle"] == "up") then 
						setStatus["continentFrameTriangle"] = "down"
						continentFrame.strokeWidth = 1
						continentFrame:setStrokeColor(unpack(separateLineColor))
						continentGroup.isVisible = false
					else
						setStatus["continentFrameTriangle"] = "up"
						continentFrame.strokeWidth = 2
						continentFrame:setStrokeColor(unpack(subColor2))
						continentGroup.isVisible = true

						if ( setStatus["countryFrameTriangle"] == "up" ) then
							countryFrameTriangle:rotate(180)
							setStatus["countryFrameTriangle"] = "down"
							countryFrame:setStrokeColor(unpack(separateLineColor))
							countryFrame.strokeWidth = 1
							countryGroup.isVisible = false
						end
						
						if ( setStatus["regionFrameTriangle"] == "up" ) then
							regionFrameTriangle:rotate(180)
							setStatus["regionFrameTriangle"] = "down"
							regionFrame:setStrokeColor(unpack(separateLineColor))
							regionFrame.strokeWidth = 1
							regionGroup.isVisible = false
						end
					end	
				elseif ( name == "countryFrame" ) then
					if( continentSelected == true ) then
						countryFrameTriangle:rotate(180)
						if (setStatus["countryFrameTriangle"] == "up") then
							setStatus["countryFrameTriangle"] = "down"
							countryFrame.strokeWidth = 1
							countryFrame:setStrokeColor(unpack(separateLineColor))
							countryGroup.isVisible = false
						else
							setStatus["countryFrameTriangle"] = "up"
							countryFrame.strokeWidth = 2
							countryFrame:setStrokeColor(unpack(subColor2))
							countryGroup.isVisible = true
							if ( baseScrollViewHeight > baseScrollView.contentHeight ) then
								baseScrollView:scrollTo( "bottom", { time = 0} )
							end
							if ( setStatus["regionFrameTriangle"] == "up" ) then
								regionFrameTriangle:rotate(180)
								setStatus["regionFrameTriangle"] = "down"
								regionFrame:setStrokeColor(unpack(separateLineColor))
								regionFrame.strokeWidth = 1
								regionGroup.isVisible = false
							end
						end
					end
				elseif ( name == "regionFrame") then
					if( countrySelected == true ) then
						regionFrameTriangle:rotate(180)
						if (setStatus["regionFrameTriangle"] == "up") then 
							setStatus["regionFrameTriangle"] = "down"
							regionFrame.strokeWidth = 1
							regionFrame:setStrokeColor(unpack(separateLineColor))
							regionGroup.isVisible = false
						else
							if ( baseScrollViewHeight > baseScrollView.contentHeight ) then
								baseScrollView:scrollTo( "bottom", { time = 0} )
							end
							setStatus["regionFrameTriangle"] = "up"
							regionFrame.strokeWidth = 2
							regionFrame:setStrokeColor(unpack(subColor2))
							regionGroup.isVisible = true
						end
					end
				end
			end
			return true
		end
		continentFrame:addEventListener( "touch", frameListener )
		countryFrame:addEventListener( "touch", frameListener )
		regionFrame:addEventListener( "touch", frameListener )	
	-- 搜尋旅伴按鈕
		local searchPartnerBtn = widget.newButton({
				id = "searchPartnerBtn",
				label = "搜尋旅伴",
				labelColor = { default = { 1, 1, 1}, over = { 1, 1, 1} },
				font = getFont.font,
				fontSize = 14,
				defaultFile = "assets/btn-mate.png",
				width = 350*wRate,
				height = 90*hRate,
				onRelease = function ( event )
					if ( continentSelected == true and countrySelected == true and regionSelected == true ) then 
						--composer.setVariable( "getCountry", countryFrameText.text )
						--composer.setVariable( "getRegion", regionFrameText.text )
						--composer.gotoScene( "TP_partnerResult", { time = 200, effect = "flipFadeOutIn"} )
						--local setScene = composer.getSceneName("current")
						local options = {
							time = 200,
							effect = "fade",
							params = {
								setFromScene = composer.getSceneName("current"),
								setContinent = continentFrameText.text,
								setCountry = countryFrameText.text,
								setCity = regionFrameText.text,
								setGender = "N/A"
							}
						}
						composer.gotoScene( "TP_searchResult", options )
					end
					return true
				end,
			})
		baseScrollViewGroup:insert(searchPartnerBtn)
		searchPartnerBtn.anchorX = 1
		searchPartnerBtn.anchorY = 1
		searchPartnerBtn.x = screenW+ox+ox-ceil(110*wRate)
		searchPartnerBtn.y = findPaper.y+findPaper.contentHeight-ceil(60*hRate)
		searchPartnerBtn.y = findPaper.y+findPaper.contentHeight*0.03+findPaper.contentHeight*0.94-floor(45*hRate)
	
	-- 添加我的旅程元件 --
	-- 添加我的旅程選項外框
	-- 圖示-tag-add.png
		local addTag = display.newImageRect("assets/tag-add.png", 504, 135)
		baseScrollViewGroup:insert(addTag)
		addTag.anchorX = 0
		addTag.anchorY = 0
		addTag.width = addTag.width*wRate
		addTag.height = addTag.height*hRate
		addTag.x = ceil(20*wRate)
		addTag.y = findPaper.y+findPaper.contentHeight+floor(18*hRate)
		local addTagNum = baseScrollViewGroup.numChildren
	-- 圖示-paper-add.png
		local addPaper = display.newImageRect("assets/paper-add.png", 1007, 291)
		baseScrollViewGroup:insert(findTagNum, addPaper)
		addPaper.anchorX = 0
		addPaper.anchorY = 0
		addPaper.width = addPaper.width*wRate+ox+ox
		addPaper.height = addPaper.height*hRate
		addPaper.x = addTag.x+ceil(20*wRate)
		addPaper.y = addTag.y+ceil(10*hRate)
	-- 顯示文字-"添加我的旅程"
		local addMyTripText = display.newText({
				text = "添加我的旅程",
				font = getFont.font,
				fontSize = 14,
			})
		baseScrollViewGroup:insert(addMyTripText)
		addMyTripText.anchorX = 0
		addMyTripText.x = findPartnerText.x
		addMyTripText.y = addTag.y+(90*hRate)*0.5
	-- 我要找尋旅伴！顯示文字
		local wantedPartnerText = display.newText({
				text = "我要找尋旅伴！",
				font = getFont.font,
				fontSize = 14,
			})
		baseScrollViewGroup:insert(wantedPartnerText)
		wantedPartnerText:setFillColor(unpack(wordColor))
		wantedPartnerText.anchorX = 0
		wantedPartnerText.x = addMyTripText.x
		wantedPartnerText.y = addMyTripText.y+addPaper.contentHeight*0.45
	-- 按鈕
		local addMyTripBtn = widget.newButton({
			id = "addMyTripBtn",
			label = "我的旅程計畫",
			labelColor = { default = { 1, 1, 1}, over = { 1, 1, 1} },
			font = getFont.font,
			fontSize = 14,
			defaultFile = "assets/btn-mate.png",
			width = 350*wRate,
			height = 90*hRate,
			onRelease = function (event)
				local options = { time = 200, effect = "fade"}
				composer.gotoScene("TP_myTripPlan",options)
				return true
			end,
		})
		baseScrollViewGroup:insert(addMyTripBtn)
		addMyTripBtn.anchorX = 1
		addMyTripBtn.x = searchPartnerBtn.x
		addMyTripBtn.y = wantedPartnerText.y

		baseScrollViewHeight = addPaper.y+addPaper.contentHeight
		if ( baseScrollViewHeight > baseScrollView.contentHeight ) then
			baseScrollView:setScrollHeight(baseScrollViewHeight+20)
			baseScrollView:setIsLocked( false, "vertical")
		end
	
	------------------- 洲別/國家/地區下拉式選單 -------------------
	-- 通用參數
		local listFrameWidth = continentFrame.contentWidth*0.8
		local listFrameHeight = screenH*0.375
		local listBaseWidth = listFrameWidth*0.96
		local listBaseHeight = screenH/16
		local listBasePadding = listBaseHeight/3
	-- 洲別下拉式選單 --
	-- 外框
		continentGroup = display.newGroup()
		baseScrollViewGroup:insert(continentGroup)
		local continentGroupNum = baseScrollViewGroup.numChildren
		local continentListFrame = display.newImageRect( continentGroup, "assets/shadow-320480-paper.png", listFrameWidth, listFrameHeight)
		continentListFrame:addEventListener( "touch", function() return true; end)
		continentListFrame.anchorY = 0
		continentListFrame.x = baseScrollView.contentWidth*0.5
		continentListFrame.y = continentFrame.y+continentFrame.contentHeight

		local continentScrollView = widget.newScrollView({
			id = "continentScrollView",
			x = baseScrollView.contentWidth*0.5,
			y = continentFrame.y+continentFrame.contentHeight,
			width = listFrameWidth*0.95,
			height = listFrameHeight*59/60,
			isBounceEnabled = false,
			horizontalScrollDisabled = true,
			isLocked = true,
			backgroundColor = {1},
		})
		continentGroup:insert(continentScrollView)
		continentScrollView.anchorY = 0
		local continentScrollViewHeight = 0 
		local continentScrollViewGroup = display.newGroup()
		continentScrollView:insert(continentScrollViewGroup)
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
						continentScrollView:takeFocus(event)
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
					if ( continentListText[nowSelection.id].text ~= continentFrameText.text ) then
						countryFrameText.text = "請選擇"
						if ( regionCover.isVisible == false ) then regionCover.isVisible = true end
						regionFrameText.text = "請選擇"
					end
					continentFrameText.text = continentListText[nowSelection.id].text
					continentFrame.strokeWidth = 1
					continentFrame:setStrokeColor(unpack(separateLineColor))
					continentFrameTriangle:rotate(180)
					setStatus["continentFrameTriangle"] = "down"
				-- 選項選單變化
					nowSelection:setFillColor(1)
					prevSelction = nowSelection
					nowSelection = nil
					continentSelected = true
					continentGroup.isVisible = false		

				-- 產生國家選項選單 --
				-- 接洲別產生國家API
					local continentDecode = json.decode(continentJson)
					local continentDecodeValue = continentFrameText.text
					--print( continentDecode[continentDecodeValue] )
					local countryListOptions = {}
					local countryIdList = {}
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
							baseScrollViewGroup:insert( continentGroupNum, countryGroup )
							local countryGroupNum = baseScrollViewGroup.numChildren
							local countryListFrame = display.newImageRect( countryGroup, "assets/shadow-320480-paper.png", listFrameWidth, listFrameHeight)
							countryListFrame:addEventListener( "touch", function() return true; end )
							countryListFrame.anchorY = 0
							countryListFrame.x = baseScrollView.contentWidth*0.5
							countryListFrame.y = countryFrame.y+countryFrame.contentHeight

							local countryScrollView = widget.newScrollView({
								id = "countryScrollView",
								x = baseScrollView.contentWidth*0.5,
								y = countryFrame.y+countryFrame.contentHeight,
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
										if ( countryListText[nowCountrySelection.id].text ~= countryFrameText.text ) then
											regionFrameText.text = "請選擇"
										end
										countryFrameText.text = countryListText[nowCountrySelection.id].text
										countryFrame.strokeWidth = 1
										countryFrame:setStrokeColor(unpack(separateLineColor))
										countryFrameTriangle:rotate(180)
										setStatus["countryFrameTriangle"] = "down"
									-- 選項選單變化
										local countryId = countryIdList[nowCountrySelection.id]
										nowCountrySelection:setFillColor(1)
										prevCountrySelction = nowCountrySelection
										nowCountrySelection = nil
										countryGroup.isVisible = false
										countrySelected = true

									-- 產生地區選項選單 --
									-- 接國家產生地區API
										local regionListOptions = {}
										local regionIdList = {}
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
												baseScrollViewGroup:insert( continentGroupNum, regionGroup )
												local regionListFrame = display.newImageRect( regionGroup, "assets/shadow-320480-paper.png", listFrameWidth, listFrameHeight)
												regionListFrame:addEventListener("touch", function () return true; end)
												regionListFrame.anchorY = 0
												regionListFrame.x = baseScrollView.contentWidth*0.5
												regionListFrame.y = regionFrame.y+regionFrame.contentHeight

												local regionScrollView = widget.newScrollView({
													id = "regionScrollView",
													x = baseScrollView.contentWidth*0.5,
													y = regionFrame.y+regionFrame.contentHeight,
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
															regionFrameText.text = regionListText[nowRegionSelection.id].text
															regionFrame.strokeWidth = 1
															regionFrame:setStrokeColor(unpack(separateLineColor))
															regionFrameTriangle:rotate(180)
															setStatus["regionFrameTriangle"] = "down"
														-- 選項選單變化
															nowRegionSelection:setFillColor(1)
															prevRegionSelction = nowRegionSelection
															nowRegionSelection = nil
															regionGroup.isVisible = false
															regionSelected = true
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
												regionCover.isVisible = false
										end
										local getRegionUrl = "http://211.21.114.208/1.0/other/GetCityListByCountryId/"..countryId
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
							countryCover.isVisible = false
					end
					local getCountryUrl = "http://211.21.114.208/1.0/other/GetCountryListByContinentId/"..continentDecode[continentDecodeValue]
					network.request( getCountryUrl, "GET", getCountryInfo)	
			end
			return true
		end
	-- 洲別選單內容
		for i = 1, #continentOptions do
			local continentListBase = display.newRect( continentScrollViewGroup, continentScrollView.contentWidth*0.5, listBasePadding+(listBaseHeight+listBasePadding)*(i-1), listBaseWidth, listBaseHeight )
			continentListBase.anchorY = 0
			continentListBase.id = i
			continentListBase:addEventListener( "touch", continentListOptionListener)
			--continentListBase:setFillColor( math.random(), math.random(), math.random())

			continentListText[i] = display.newText({
				parent = continentScrollViewGroup,
				text = continentOptions[i],
				font = getFont.font,
				fontSize = 12,
				x = continentListBase.x,
				y = continentListBase.y+continentListBase.contentHeight*0.5,
			})
			continentListText[i]:setFillColor(unpack(wordColor))
			
			if ( i == #continentOptions ) then
				continentScrollViewHeight = continentListBase.y+continentListBase.contentHeight+listBasePadding
				if ( continentScrollViewHeight > continentScrollView.contentHeight ) then
					continentScrollView:setScrollHeight( continentScrollViewHeight )
					continentScrollView:setIsLocked( false, "vertical")
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
		-- 選單
		local titleListScrollView = widget.newScrollView({
			id = "titleListScrollView",
			width = titleListShadow.contentWidth*0.97,
			height = titleListShadow.contentHeight*0.98,
			isLocked = true,
			backgroundColor = {1},
		})
		titleListGroup:insert(titleListScrollView)
		--titleListScrollView.anchorY = 0
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
				if( listOptionScenes[nowTarget.id] ~= nil ) then
					timer.performWithDelay(200, function() composer.gotoScene(listOptionScenes[nowTarget.id]) ; end)
				end
			end
			return true
		end
		for i = 1, #listOptions do
			-- 選項白底
			local optionBase = display.newRect(titleListScrollViewGroup, titleListScrollView.contentWidth*0.5, 0, titleListScrollView.contentWidth, optionBaseHeight)
			optionBase.y = optionBaseHeight*0.5+optionBaseHeight*(i-1)
			optionBase.id = i
			optionBase:addEventListener( "touch", optionSelect)
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
        composer.removeScene("TP_findPartner")
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
--print(countrySelected)
return scene