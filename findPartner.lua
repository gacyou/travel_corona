-----------------------------------------------------------------------------------------
--
-- findPartner.lua
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

local country = { {"台灣","Taiwan"}, {"日本","Japan"}, {"韓國","Korea"}, {"美國","America"}, {"加拿大","Canada"}, {"德國","Germany"}, {"非洲","Africa"}}
local region = { Taiwan = { "台北", "台中", "高雄" }, Japan = { "東京", "大阪", "京都"}, Korea = {"首爾","釜山"}, America = {"敬請期待"}, Canada = {"敬請期待"}, Germany = {"敬請期待"}, Africa = {"敬請期待"} }
-- print(region.Taiwan)    -- Sub Table
-- print(region.Taiwan[1]) -- 台北
-- print(#region.Taiwan)   -- 3
-- local a = { {"台灣","Taiwan"}, {"日本","Japan"}}
-- print(a[1][1])  -- 台灣
-- print(a[1][2])  -- Taiwan => 可以用 region[a[1][2]] 接此參數進一步獲得地區的資訊
-- 也可以 local b = a[1][2] print(region[b]) 進一步獲得地區的資訊

local countryList, countryGroup, countryFrameText, countrySelected, setRegion
local countryTextBase = {}
local regionList, regionGroup, regionFrameText, regionSelected
local regionTextBase = {}

local frameVertices = {	
	0, 0, 
	math.floor(826*wRate), 0,
	math.floor(826*wRate), math.floor(85*hRate),	 
	0, math.floor(85*hRate)
}
local triangleVertices = { 260, 165, 266, 165, 263, 169}

-- function Zone Start
local function ceil( value )
	return math.ceil(value)
end

local function floor( value )
	return math.floor(value)
end

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
	end
	if (id == "searchPartnerBtn") then
		if (countrySelected == true and regionSelected == true) then 
			composer.setVariable("getCountry", countryFrameText.text)
			composer.setVariable("getRegion", regionFrameText.text)
			local options = { time = 200, effect = "flipFadeOutIn"}
			composer.gotoScene("partnerResult",options)
		end
	end
	if (id == "addMyTripBtn") then 
		local options = { time = 200, effect = "flipFadeOutIn"}
		composer.gotoScene("myTripPlan",options)		
	end
	return true
end
-- function Zone End

-- create()
function scene:create( event )
	local sceneGroup = self.view
	mainTabBar.myTabBarShown()
------------------- 背景元件 -------------------
	local background = display.newRect(cx, cy,screenW+ox+ox,screenH+oy+oy)
	sceneGroup:insert(background)
	background:setFillColor(unpack(backgroundColor))
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
 		onRelease = onBtnListener,
 	})
 	sceneGroup:insert(listIconNum,listBtn)
 	setStatus["listBtn"] = "down"
------------------- 藍色底圖元件 -------------------
-- 藍色底圖
	local blueBase = display.newImageRect("assets/mate-bg.png",1080,506)
	sceneGroup:insert(blueBase)
	blueBase.width = screenW+ox+ox
	blueBase.height = ceil(455*hRate)
	blueBase.x = cx
	blueBase.y = titleBase.y+titleBase.contentHeight*0.5+(blueBase.contentHeight*0.5)
-- 底圖文字
	local findPartnerTitleText = display.newEmbossedText({
		text = "來喔！來尋找旅伴喔!",
		font = getFont.font,
		fontSize = 18,
	})
	sceneGroup:insert(findPartnerTitleText)
	findPartnerTitleText.x = cx
	findPartnerTitleText.y = blueBase.y-(blueBase.contentHeight*0.15)
	local color = {
		highlight = { r = 0, g = 0, b = 0 },
		shadow = { r = 1, g = 1, b =1  }
	}
	findPartnerTitleText:setEmbossColor( color )
------------------- 尋找旅伴-底圖元件 -------------------
-- 圖示-tag-find.png
	local findTag = display.newImageRect("assets/tag-find.png", 404, 135)
	sceneGroup:insert(findTag)
	findTag.anchorX = 0
	findTag.anchorY = 0
	findTag.width = findTag.width*wRate
	findTag.height = findTag.height*hRate
	findTag.x = -ox+ceil(20*wRate)
	findTag.y = -oy+ceil(566*hRate)
	local findTagNum = sceneGroup.numChildren
-- 圖示-0301matesearch-paper.png
	local findPaper = display.newImageRect("assets/0301matesearch-paper.png", 1007, 1024)
	sceneGroup:insert(findTagNum, findPaper)
	findPaper.anchorX = 0
	findPaper.anchorY = 0
	findPaper.width = findPaper.width*wRate
	findPaper.height = findPaper.height*hRate
	findPaper.x = findTag.x+ceil(20*wRate)
	findPaper.y = findTag.y+ceil(10*hRate)
-- 顯示文字-"尋找旅伴"
	local findPartnerText = display.newText({
		text = "尋找旅伴",
		font = getFont.font,
		fontSize = 14,
	})
	sceneGroup:insert(findPartnerText)
	findPartnerText.anchorX = 0
	findPartnerText.x = -ox+ceil(128*wRate)
	findPartnerText.y = findTag.y+(90*hRate)*0.5
------------------- 尋找旅伴-洲別元件 -------------------
-- 顯示文字-"洲別"
	local continentText = display.newText({
		text = "洲別",
		font = getFont.font,
		fontSize = 14,
	})
	sceneGroup:insert(continentText)
	continentText:setFillColor(unpack(wordColor))
	continentText.anchorX = 0
	continentText.anchorY = 0
	continentText.x = findPartnerText.x
	continentText.y = findTag.y+findTag.contentHeight
-- 洲別選項外框
	local continentFrame = display.newPolygon( cx, cy, frameVertices)
	sceneGroup:insert(continentFrame)
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
	sceneGroup:insert(continentFrameText)
	continentFrameText:setFillColor(unpack(wordColor))
	continentFrameText.anchorX = 0
	continentFrameText.x = continentFrame.x+ceil(25*wRate)
	continentFrameText.y = continentFrame.y+continentFrame.contentHeight*0.5
-- 洲別選項的三角形
	local continentFrameTriangle = display.newPolygon ( continentFrame.x+continentFrame.contentWidth-ceil(40*wRate), continentFrameText.y, triangleVertices)
	sceneGroup:insert(continentFrameTriangle)
	continentFrameTriangle.strokeWidth = 2
	continentFrameTriangle:setStrokeColor(0)
	continentFrameTriangle:setFillColor(0)
	continentFrameTriangle.x = continentFrameTriangle.x - continentFrameTriangle.contentWidth*0.5
	setStatus["continentFrameTriangle"] = "down"
------------------- 尋找旅伴-國家元件 -------------------
-- 顯示文字-國家
	local countryText = display.newText({
			text = "國家",
			font = getFont.font,
			fontSize = 14,
		})
	sceneGroup:insert(countryText)
	countryText:setFillColor(unpack(wordColor))
	countryText.anchorX = 0
	countryText.anchorY = 0
	countryText.x = continentText.x
	countryText.y = continentFrame.y+continentFrame.contentHeight+floor(30*hRate)
-- 國家選項外框
	local countryFrame = display.newPolygon(cx,cy,frameVertices)
	sceneGroup:insert(countryFrame)
	countryFrame.strokeWidth = 1
	countryFrame:setStrokeColor(unpack(separateLineColor))
	countryFrame.anchorX = 0
	countryFrame.anchorY = 0
	countryFrame.x = countryText.x
	countryFrame.y = countryText.y+countryText.contentHeight+floor(20*hRate)
-- 顯示文字-"請選擇"
	countryFrameText = display.newText({
			text = "請選擇",
			font = getFont.font,
			fontSize = 14,
		})
	sceneGroup:insert(countryFrameText)
	countryFrameText:setFillColor(unpack(wordColor))
	countryFrameText.anchorX = 0
	countryFrameText.x = continentFrameText.x
	countryFrameText.y = countryFrame.y+countryFrame.contentHeight*0.5
-- 國家選項的三角形
	local countryFrameTriangle = display.newPolygon ( continentFrameTriangle.x, countryFrameText.y, triangleVertices)
	sceneGroup:insert(countryFrameTriangle)
	countryFrameTriangle.strokeWidth = 2
	countryFrameTriangle:setStrokeColor(0)
	countryFrameTriangle:setFillColor(0)
	setStatus["countryFrameTriangle"] = "down"
-- 國家選擇監聽事件
	countryFrame:addEventListener("tap", 
		function(event) 
			countryFrameTriangle:rotate(180)
			if (setStatus["countryFrameTriangle"] == "up") then 
				setStatus["countryFrameTriangle"] = "down"
				countryFrame.strokeWidth = 1
				countryFrame:setStrokeColor(unpack(separateLineColor))
				transition.to(countryGroup,{ y = -countryList.contentHeight, time = 200})
				timer.performWithDelay(200, function() countryList.isVisible = false ;end)
			else
				setStatus["countryFrameTriangle"] = "up"
				countryList.isVisible = true
				countryFrame.strokeWidth = 2
				countryFrame:setStrokeColor(unpack(subColor2))
				transition.to(countryGroup,{ y = 0, time = 200})
			end
		end)
------------------- 尋找旅伴-地區元件 -------------------	
-- 顯示文字-地區
	local regionText = display.newText({
			text = "地區",
			font = getFont.font,
			fontSize = 14,
		})
	sceneGroup:insert(regionText)
	regionText:setFillColor(unpack(wordColor))
	regionText.anchorX = 0
	regionText.anchorY = 0
	regionText.x = continentText.x
	regionText.y = countryFrame.y+countryFrame.contentHeight+floor(30*hRate)
-- 地區選項的外框
	local regionFrame = display.newPolygon( cx, cy, frameVertices)
	sceneGroup:insert(regionFrame)
	regionFrame.strokeWidth = 1
	regionFrame:setStrokeColor(unpack(separateLineColor))
	regionFrame.anchorX = 0
	regionFrame.anchorY = 0
	regionFrame.x = regionText.x
	regionFrame.y = regionText.y+regionText.contentHeight+floor(20*hRate)
-- 顯示文字-"請選擇"
	regionFrameText = display.newText({
			text = "請選擇",
			font = getFont.font,
			fontSize = 14,
		})
	sceneGroup:insert(regionFrameText)
	regionFrameText:setFillColor(unpack(wordColor))
	regionFrameText.anchorX = 0
	regionFrameText.x = continentFrameText.x
	regionFrameText.y = regionFrame.y+regionFrame.contentHeight*0.5
-- 地區選項內的三角形
	local regionFrameTriangle = display.newPolygon( continentFrameTriangle.x, regionFrameText.y, triangleVertices)
	sceneGroup:insert(regionFrameTriangle)
	regionFrameTriangle.strokeWidth = 2
	regionFrameTriangle:setStrokeColor(0)
	regionFrameTriangle:setFillColor(0)
	setStatus["regionFrameTriangle"] = "down"	
-- 地區選擇監聽事件
	regionFrame:addEventListener("tap", 
		function(event)
			if( countrySelected == true) then 
				regionFrameTriangle:rotate(180)
				if (setStatus["regionFrameTriangle"] == "up") then 
					setStatus["regionFrameTriangle"] = "down"
					regionFrame.strokeWidth = 1
					regionFrame:setStrokeColor(unpack(separateLineColor))
					transition.to(regionGroup,{ y = -regionList.contentHeight, time = 200})
					timer.performWithDelay(200, function() regionList.isVisible = false ;end)
				else
					setStatus["regionFrameTriangle"] = "up"
					regionList.isVisible = true
					regionFrame.strokeWidth = 2
					regionFrame:setStrokeColor(unpack(subColor2))
					transition.to(regionGroup,{ y = 0, time = 200})
				end
			end
		end)
-- 按鈕
	local searchPartnerBtn = widget.newButton({
			id = "searchPartnerBtn",
			label = "搜尋旅伴",
			labelColor = { default = { 1, 1, 1}, over = { 1, 1, 1} },
			font = getFont.font,
			fontSize = 14,
			defaultFile = "assets/btn-mate.png",
			width = 350*wRate,
			height = 90*hRate,
			onRelease= onBtnListener,
		})
	sceneGroup:insert(searchPartnerBtn)
	searchPartnerBtn.anchorX = 1
	searchPartnerBtn.anchorY = 1
	searchPartnerBtn.x = screenW+ox-ceil(110*wRate)
	searchPartnerBtn.y = findPaper.y+findPaper.contentHeight-ceil(60*hRate)
	searchPartnerBtn.y = findPaper.y+findPaper.contentHeight*0.03+findPaper.contentHeight*0.94-floor(45*hRate)
------------------- 添加我的旅程元件 -------------------
-- 底圖
-- 圖示-tag-add.png
	local addTag = display.newImageRect("assets/tag-add.png", 504, 135)
	sceneGroup:insert(addTag)
	addTag.anchorX = 0
	addTag.anchorY = 0
	addTag.width = addTag.width*wRate
	addTag.height = addTag.height*hRate
	addTag.x = -ox+ceil(20*wRate)
	addTag.y = findPaper.y+findPaper.contentHeight+floor(18*hRate)
	local addTagNum = sceneGroup.numChildren
-- 圖示-paper-add.png
	local addPaper = display.newImageRect("assets/paper-add.png", 1004, 291)
	sceneGroup:insert(findTagNum, addPaper)
	addPaper.anchorX = 0
	addPaper.anchorY = 0
	addPaper.width = floor(addPaper.width*wRate)
	addPaper.height = ceil(addPaper.height*hRate)
	addPaper.x = addTag.x+ceil(20*wRate)
	addPaper.y = addTag.y+ceil(10*hRate)
-- 顯示文字-"添加我的旅程"
	local addMyTripText = display.newText({
			text = "添加我的旅程",
			font = getFont.font,
			fontSize = 14,
		})
	sceneGroup:insert(addMyTripText)
	addMyTripText.anchorX = 0
	addMyTripText.x = findPartnerText.x
	addMyTripText.y = addTag.y+(90*hRate)*0.5
-- 我要找尋旅伴！顯示文字
	local wantedPartnerText = display.newText({
			text = "我要找尋旅伴！",
			font = getFont.font,
			fontSize = 14,
		})
	sceneGroup:insert(wantedPartnerText)
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
			onPress = onBtnListener,
		})
	sceneGroup:insert(addMyTripBtn)
	addMyTripBtn.anchorX = 1
	addMyTripBtn.x = searchPartnerBtn.x
	addMyTripBtn.y = wantedPartnerText.y
------------------- 國家&地區下拉式選單(with Container) -------------------
-- 將下拉式選單隱藏是移動Container中的元件到Container範圍外
-- 國家選單邊界
	countryList = display.newContainer( countryFrame.contentWidth*0.8, screenH*0.375)
	sceneGroup:insert(countryList)
	countryList.anchorY = 0
	countryList.x = cx
	countryList.y = countryFrame.y+countryFrame.contentHeight
	local countryListNum = sceneGroup.numChildren
-- 國家選單內容
	countryGroup = display.newGroup()
	countryList:insert(countryGroup)
	local countryListBaseShadow = display.newImageRect(countryGroup, "assets/shadow-320480.png", countryList.contentWidth, countryList.contentHeight)
	local countryListBase = display.newRect( countryGroup, 0, 0, (countryListBaseShadow.contentWidth)*0.95, (countryListBaseShadow.contentHeight)*59/60)
	countryListBase.y = countryListBase.y-(countryListBaseShadow.contentHeight-countryListBase.contentHeight)/2
	countryListBase:addEventListener("touch", function () return true ; end )
	countryListBase:addEventListener("tap", function () return true ; end )
-- 國家選項ScrollView
	local countryScrollViewHeight = 0
	local countryScrollView = widget.newScrollView({
			id = "countryScrollView",
			x = 0,
			y = 0,
			width = countryListBase.contentWidth,
			height = countryListBase.contentHeight,
			horizontalScrollDisabled = true,
			isBounceEnabled = false,
		})
	countryGroup:insert(countryScrollView)
	countryScrollView.y = countryListBaseShadow.y-((countryListBaseShadow.contentHeight-countryScrollView.contentHeight))/2
-- 國家選項的監聽事件
-- 觸碰後後同時產生該國家地區的下拉式選單
	local countryOptionText = {}
	local ctryNowTarget, ctryPrevTarget = nil

	local function countryListener( event )
		local phase = event.phase
		if (phase == "began") then
			if (ctryNowTarget == nil and ctryPrevTarget == nil) then
				ctryNowTarget = event.target
				ctryNowTarget:setFillColor( 0, 0, 0, 0.1)
				countryOptionText[ctryNowTarget.id]:setFillColor(unpack(subColor1))
			elseif (ctryNowTarget == nil and ctryPrevTarget ~= nil) then
				if (event.target ~= ctryPrevTarget) then
					
					countryOptionText[ctryPrevTarget.id]:setFillColor(unpack(wordColor))

					ctryNowTarget = event.target
					ctryNowTarget:setFillColor( 0, 0, 0, 0.1)
					countryOptionText[ctryNowTarget.id]:setFillColor(unpack(subColor1))
				end
			end
		elseif (phase == "moved") then
			local dx = math.abs(event.xStart-event.x)
			local dy = math.abs(event.yStart-event.y)
			if (dx > 10 or dy > 10) then
				if (ctryNowTarget ~= nil) then
					countryScrollView:takeFocus(event)
					ctryNowTarget:setFillColor(1)
					countryOptionText[ctryNowTarget.id]:setFillColor(unpack(wordColor))
					ctryNowTarget = nil
					if (ctryPrevTarget ~= nil) then
						countryOptionText[ctryPrevTarget.id]:setFillColor(unpack(subColor1))
					end
				end
			end
		elseif (phase == "ended" and ctryNowTarget ~= nil) then
			setStatus["countryFrameTriangle"] = "down"
			countryFrameTriangle:rotate(180)
			transition.to(countryGroup,{ y = -countryList.contentHeight, time = 200})
			ctryPrevTarget = ctryNowTarget
			ctryNowTarget = nil
			countryFrameText.text = countryOptionText[ctryPrevTarget.id].text
			timer.performWithDelay(200, function() countryList.isVisible = false ; end)
			timer.performWithDelay(200, function() ctryPrevTarget:setFillColor(1) ; end)
			timer.performWithDelay(200, function() countryFrame.strokeWidth = 1 ; end)
			timer.performWithDelay(200, function() countryFrame:setStrokeColor(unpack(separateLineColor)) ; end)
			countrySelected = true
			setRegion = country[event.target.id][2]
			-- 因為 scence:create 屬於產生圖像階段，故要直接產生地區的下拉選單
			-- 此選單是透過事件產生，執行結束後要remove掉，否則記憶體可能會爆炸
			-- 地區選項的下拉選單
				if (regionList) then 
					regionList:removeSelf()
					if( setStatus["regionFrameTriangle"] == "up") then 
						setStatus["regionFrameTriangle"] = "down"
						regionFrameTriangle:rotate(180)
					end
					regionFrameText.text = "請選擇"
				end
			-- 地區選單邊界
				regionList = display.newContainer( regionFrame.contentWidth*0.8, screenH*0.375)
				sceneGroup:insert(countryListNum, regionList)
				regionList.anchorY = 0
				regionList.x = cx
				regionList.y = regionFrame.y+regionFrame.contentHeight
			-- 地區選單內容
				regionGroup = display.newGroup()
				regionList:insert(regionGroup)
				local regionListBaseShadow = display.newImageRect(regionGroup, "assets/shadow-320480.png", regionList.contentWidth, regionList.contentHeight)
				local regionListBase = display.newRect( regionGroup, 0, 0, regionListBaseShadow.contentWidth*0.95, regionListBaseShadow.contentHeight*59/60)
				regionListBase.y = regionListBase.y-(regionListBaseShadow.contentHeight-regionListBase.contentHeight)/2
				regionListBase:addEventListener("touch", function () return true ; end )
				regionListBase:addEventListener("tap", function () return true ; end )
			-- 地區選項ScrollView
				local regionScrollViewHeight = 0
				local regionScrollView = widget.newScrollView({
					id = "regionScrollView",
					x = 0,
					y = 0,
					width = regionListBase.contentWidth,
					height = regionListBase.contentHeight,
					horizontalScrollDisabled = true,
					isBounceEnabled = false,
				})
				regionGroup:insert(regionScrollView)
				regionScrollView.y = regionListBaseShadow.y-((regionListBaseShadow.contentHeight-regionScrollView.contentHeight))/2
			-- 地區選項的監聽事件
				local regionOptionText = {}
				local regionNowTarget, regionPrevTarget = nil
				local function regionListener( event )
					local phase = event.phase
					if (phase == "began") then
						if (regionNowTarget == nil and regionPrevTarget == nil) then
							regionNowTarget = event.target
							regionNowTarget:setFillColor( 0, 0, 0, 0.1)
							regionOptionText[regionNowTarget.id]:setFillColor(unpack(subColor1))
						elseif (regionNowTarget == nil and regionPrevTarget ~= nil) then
							if (event.target ~= regionPrevTarget) then
								
								regionOptionText[regionPrevTarget.id]:setFillColor(unpack(wordColor))

								regionNowTarget = event.target
								regionNowTarget:setFillColor( 0, 0, 0, 0.1)
								regionOptionText[regionNowTarget.id]:setFillColor(unpack(subColor1))
							end
						end
					elseif (phase == "moved") then
						local dx = math.abs(event.xStart-event.x)
						local dy = math.abs(event.yStart-event.y)
						if (dx > 10 or dy > 10) then
							if (regionNowTarget ~= nil) then
								countryScrollView:takeFocus(event)
								regionNowTarget:setFillColor(1)
								regionOptionText[regionNowTarget.id]:setFillColor(unpack(wordColor))
								regionNowTarget = nil
								if (regionPrevTarget ~= nil) then
									regionOptionText[regionPrevTarget.id]:setFillColor(unpack(subColor1))
								end
							end
						end
					elseif (phase == "ended" and regionNowTarget ~= nil) then
						setStatus["regionFrameTriangle"] = "down"
						regionFrameTriangle:rotate(180)
						transition.to(regionGroup,{ y = -regionList.contentHeight, time = 200})
						regionPrevTarget = regionNowTarget
						regionNowTarget = nil
						regionFrameText.text = regionOptionText[regionPrevTarget.id].text
						timer.performWithDelay(200, function() regionList.isVisible = false ; end)
						timer.performWithDelay(200, function() regionPrevTarget:setFillColor(1) ; end)
						timer.performWithDelay(200, function() regionFrame.strokeWidth = 1 ; end)
						timer.performWithDelay(200, function() regionFrame:setStrokeColor(unpack(separateLineColor)) ; end)
						regionSelected = true
					end
					return true
				end -- 地區選項的監聽事件
			-- 地區選項內容(地區名稱)
				local regionPad = regionList.contentHeight/30
				local regionOptionWidth =  regionScrollView.contentWidth
				local regionOptionHeight = regionPad*5
				local regionScrollViewGroup = display.newGroup()
				regionScrollView:insert(regionScrollViewGroup)
				for i=1,#region[setRegion] do
					-- 白底
					regionTextBase = display.newRect( regionOptionWidth*0.5, (regionPad+regionOptionHeight*0.5)+(regionOptionHeight+regionPad)*(i-1), regionOptionWidth, regionOptionHeight)
					regionScrollViewGroup:insert(regionTextBase)
					regionTextBase.id = i
					regionTextBase:addEventListener("touch",regionListener)
					-- 選項
					regionOptionText[i] = display.newText({
							text = region[setRegion][i],
							font = getFont.font,
							fontSize = 14,
						})
					regionScrollViewGroup:insert(regionOptionText[i])
					regionOptionText[i]:setFillColor(unpack(wordColor))
					regionOptionText[i].x = regionTextBase.x
					regionOptionText[i].y = regionTextBase.y
					-- 底部間距
					if (i == #region[setRegion]) then
						local bottomPad = display.newRect( regionScrollViewGroup, regionTextBase.x, regionTextBase.y+regionTextBase.contentHeight*0.5+regionPad*0.5, regionOptionWidth, regionPad)
						regionScrollViewHeight = bottomPad.y+bottomPad.contentHeight*0.5
					end
				end
				regionGroup.y = -regionList.contentHeight
				regionList.isVisible = false
		end
		return true
	end -- 國家選項的監聽事件
-- 選項內容(國家)
	local countryPad = countryList.contentHeight/30
	local countryOptionWidth =  countryScrollView.contentWidth
	local countryOptionHeight = countryPad*5
	local countryScrollViewGroup = display.newGroup()
	countryScrollView:insert(countryScrollViewGroup)
	for i=1,#country do
		-- 白底
		local countryTextBase = display.newRect(countryOptionWidth*0.5, (countryPad+countryOptionHeight*0.5)+(countryOptionHeight+countryPad)*(i-1), countryOptionWidth, countryOptionHeight)
		countryScrollViewGroup:insert(countryTextBase)
		countryTextBase.id = i
		countryTextBase:addEventListener("touch", countryListener)
		-- 選項
		countryOptionText[i] = display.newText({
				text = country[i][1],
				font = getFont.font,
				fontSize = 14,
			})
		countryScrollViewGroup:insert(countryOptionText[i])
		countryOptionText[i]:setFillColor(unpack(wordColor))
		countryOptionText[i].x = countryTextBase.x
		countryOptionText[i].y = countryTextBase.y
		-- 底部間距
		if (i == #country) then
			local bottomPad = display.newRect( countryScrollViewGroup, countryTextBase.x, countryTextBase.y+countryTextBase.contentHeight*0.5+countryPad*0.5, countryOptionWidth, countryPad)
			countryScrollViewHeight = bottomPad.y+bottomPad.contentHeight*0.5
		end
	end
	if (countryScrollViewHeight > countryScrollView.contentHeight) then
		countryScrollView:setScrollHeight(countryScrollViewHeight)
	end
	countryGroup.y = -countryList.contentHeight
	countryList.isVisible = false
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
        composer.removeScene("findPartner")
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