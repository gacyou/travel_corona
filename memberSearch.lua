-----------------------------------------------------------------------------------------
--
-- memberSearch.lua
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

local genderList, genderGroup, genderFrameText, genderSelected

local gender = { "男", "女", "不拘"}

local languageList, languageGroup, languageFrameText, languageSelected
local languageTextBase = {}
local language = { "繁體中文", "簡體中文", "英文", "日本語"}

local countryList, countryGroup, countryFrameText, countrySelected
local countryTextBase = {}
local country = { "台灣", "中國", "日本", "韓國", "美國", "英國", "德國", "澳洲", "非洲"}

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
	if (id == "searchBtn") then
		if ( genderSelected == true and languageSelected == true and countrySelected == true) then 
			composer.setVariable("getGender", genderFrameText.text)
			composer.setVariable("getLanguage", languageFrameText.text)
			composer.setVariable("getCountry", countryFrameText.text)
			local options = { time = 300, effect = "flipFadeOutIn"}
			composer.gotoScene("memberResult",options)
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
	local background = display.newRect(cx,cy+oy,screenW+ox+ox,screenH+oy+oy)
	sceneGroup:insert(background)
	background:setFillColor(unpack(backgroundColor))
------------------- 抬頭元件 -------------------
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
-- 顯示文字-"會員搜尋"
	local titleText = display.newText({
		text = "會員搜尋",
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
------------------- 搜尋會員藍色底圖 -------------------
-- 藍底
	local memberSearchGroup = display.newGroup()
	sceneGroup:insert(memberSearchGroup)
	local blueBase = display.newImageRect("assets/mate-bg.png",1080,506)
	memberSearchGroup:insert(blueBase)
	blueBase.width = screenW+ox+ox
	blueBase.height = ceil(455*hRate)
	blueBase.x = cx
	blueBase.y = titleBase.y+titleBase.contentHeight*0.5+(blueBase.contentHeight/2)
-- 顯示文字
	local memberSearchTitleText = display.newEmbossedText({
			text = "來喔！來尋找會員喔!",
			font = getFont.font,
			fontSize = 18,
		})
	memberSearchGroup:insert(memberSearchTitleText)
	memberSearchTitleText.x = cx
	memberSearchTitleText.y = blueBase.y-(blueBase.contentHeight*0.15)
	local color = {
		highlight = { r=0, g=0, b=0 },
		shadow = { r=1, g=1, b=1 }
	}
	memberSearchTitleText:setEmbossColor( color )
------------------- 會員搜尋元件(背景底圖+字) -------------------
-- 圖示-tag-find.png
	local findTag = display.newImageRect("assets/tag-find.png", 404, 135)
	memberSearchGroup:insert(findTag)
	findTag.anchorX = 0
	findTag.anchorY = 0
	findTag.width = ceil(findTag.width*wRate)
	findTag.height = ceil(findTag.height*hRate)
	findTag.x = -ox+ceil(20*wRate)
	findTag.y = -oy+ceil(566*hRate)
	local findTagNum = memberSearchGroup.numChildren
-- 圖示-0207search-paper.png
	local findPaper = display.newImageRect("assets/0207search-paper.png", 1012, 1079)
	memberSearchGroup:insert(findTagNum, findPaper)
	findPaper.anchorX = 0
	findPaper.anchorY = 0
	findPaper.width = floor(findPaper.width*wRate)
	findPaper.height = ceil(findPaper.height*wRate)
	findPaper.x = findTag.x+ceil(20*wRate)
	findPaper.y = findTag.y+ceil(10*hRate)
-- 顯示文字-"會員搜尋"
	local memberSearchText = display.newText({
			text = "會員搜尋",
			font = getFont.font,
			fontSize = 14,
		})
	memberSearchGroup:insert(memberSearchText)
	memberSearchText.anchorX = 0
	memberSearchText.x = -ox+ceil(128*wRate)
	memberSearchText.y = findTag.y+floor(90*hRate)*0.5
------------------- 會員搜尋元件 -------------------
------------------- 性別元件 -------------------
-- 顯示文字-"性別"
	local genderText = display.newText({
			text = "性別",
			font = getFont.font,
			fontSize = 14,
		})
	memberSearchGroup:insert(genderText)
	genderText:setFillColor(unpack(wordColor))
	genderText.anchorX = 0
	genderText.anchorY = 0
	genderText.x = memberSearchText.x
	genderText.y = findTag.y+findTag.contentHeight
-- 性別外框
	local genderSelectFrame = display.newPolygon(cx,cy,frameVertices)
	memberSearchGroup:insert(genderSelectFrame)
	genderSelectFrame.strokeWidth = 1
	genderSelectFrame:setStrokeColor(unpack(separateLineColor))
	genderSelectFrame.anchorX = 0
	genderSelectFrame.anchorY = 0
	genderSelectFrame.x = genderText.x
	genderSelectFrame.y = genderText.y+genderText.contentHeight+floor(20*hRate)
-- 顯示文字-請選擇
	genderFrameText = display.newText({
			text = "請選擇",
			font = getFont.font,
			fontSize = 14,
		})
	memberSearchGroup:insert(genderFrameText)
	genderFrameText:setFillColor(unpack(wordColor))
	genderFrameText.anchorX = 0
	genderFrameText.x = genderSelectFrame.x+ceil(25*wRate)
	genderFrameText.y = genderSelectFrame.y+genderSelectFrame.contentHeight*0.5
-- 性別選項的三角形
	local genderFrameTriangle = display.newPolygon( genderSelectFrame.x+(genderSelectFrame.contentWidth-ceil(40*wRate)), genderFrameText.y, triangleVertices)
	memberSearchGroup:insert(genderFrameTriangle)
	genderFrameTriangle.strokeWidth = 2
	genderFrameTriangle:setStrokeColor(0)
	genderFrameTriangle:setFillColor(0)
	genderFrameTriangle.x = genderFrameTriangle.x-genderFrameTriangle.contentWidth*0.5
	setStatus["genderFrameTriangle"] = "down"
-- 性別選擇框觸碰監聽事件
	genderSelectFrame:addEventListener("tap", function(event) 
		genderFrameTriangle:rotate(180)
		if (setStatus["genderFrameTriangle"] == "up") then 
			setStatus["genderFrameTriangle"] = "down"
			genderSelectFrame.strokeWidth = 1
			genderSelectFrame:setStrokeColor(unpack(separateLineColor))
			transition.to(genderGroup,{ y = -genderList.contentHeight, time = 200})
			timer.performWithDelay(300, function() genderList.isVisible = false ;end)
		else
			setStatus["genderFrameTriangle"] = "up"
			genderSelectFrame.strokeWidth = 2
			genderSelectFrame:setStrokeColor(unpack(subColor2))
			genderList.isVisible = true
			transition.to(genderGroup,{ y = 0, time = 200})
		end
		end)
------------------- 語言元件 -------------------
-- 顯示文字-"語言"
	local languageText = display.newText({
			text = "語言",
			font = getFont.font,
			fontSize = 14,
		})
	memberSearchGroup:insert(languageText)
	languageText:setFillColor(unpack(wordColor))
	languageText.anchorX = 0
	languageText.anchorY = 0
	languageText.x = genderText.x
	languageText.y = genderSelectFrame.y+genderSelectFrame.contentHeight+ceil(40*hRate)
-- 語言外框
	local languageSelectFrame = display.newPolygon(cx,cy,frameVertices)
	memberSearchGroup:insert(languageSelectFrame)
	languageSelectFrame.strokeWidth = 1
	languageSelectFrame:setStrokeColor(unpack(separateLineColor))
	languageSelectFrame.anchorX = 0
	languageSelectFrame.anchorY = 0
	languageSelectFrame.x = languageText.x
	languageSelectFrame.y = languageText.y+languageText.contentHeight+floor(20*hRate)
-- 顯示文字-請選擇
	languageFrameText = display.newText({
			text = "請選擇",
			font = getFont.font,
			fontSize = 14,
		})
	memberSearchGroup:insert(languageFrameText)
	languageFrameText:setFillColor(unpack(wordColor))
	languageFrameText.anchorX = 0
	languageFrameText.x = genderFrameText.x
	languageFrameText.y = languageSelectFrame.y+languageSelectFrame.contentHeight*0.5
-- 語言選項的三角形
	local languageFrameTriangle = display.newPolygon( genderFrameTriangle.x, languageFrameText.y, triangleVertices)
	memberSearchGroup:insert(languageFrameTriangle)
	languageFrameTriangle.strokeWidth = 2
	languageFrameTriangle:setStrokeColor(0)
	languageFrameTriangle:setFillColor(0)
	setStatus["languageFrameTriangle"] = "down"
-- 語言選擇框觸碰監聽事件
	languageSelectFrame:addEventListener("tap", function(event) 
		languageFrameTriangle:rotate(180)
		if (setStatus["languageFrameTriangle"] == "up") then 
			setStatus["languageFrameTriangle"] = "down"
			languageSelectFrame.strokeWidth = 1
			languageSelectFrame:setStrokeColor(unpack(separateLineColor))
			transition.to(languageGroup,{ y = -languageList.contentHeight, time = 200})
			timer.performWithDelay(200, function() languageList.isVisible = false ;end)
		else
			setStatus["languageFrameTriangle"] = "up"
			languageSelectFrame.strokeWidth = 2
			languageSelectFrame:setStrokeColor(unpack(subColor2))
			languageList.isVisible = true
			transition.to(languageGroup,{ y = 0, time = 200})
		end
		end)
------------------- 洲別元件 -------------------
-- 顯示文字-"洲別"
	local continentText = display.newText({
		text = "洲別",
		font = getFont.font,
		fontSize = 14,
	})
	memberSearchGroup:insert(continentText)
	continentText:setFillColor(unpack(wordColor))
	continentText.anchorX = 0
	continentText.anchorY = 0
	continentText.x = languageText.x
	continentText.y = languageSelectFrame.y+languageSelectFrame.contentHeight+ceil(40*hRate)
-- 洲別選項外框
	local continentFrame = display.newPolygon( cx, cy, frameVertices)
	memberSearchGroup:insert(continentFrame)
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
	memberSearchGroup:insert(continentFrameText)
	continentFrameText:setFillColor(unpack(wordColor))
	continentFrameText.anchorX = 0
	continentFrameText.x = languageFrameText.x
	continentFrameText.y = continentFrame.y+continentFrame.contentHeight*0.5
-- 洲別選項的三角形
	local continentFrameTriangle = display.newPolygon ( languageFrameTriangle.x, continentFrameText.y, triangleVertices)
	memberSearchGroup:insert(continentFrameTriangle)
	continentFrameTriangle.strokeWidth = 2
	continentFrameTriangle:setStrokeColor(0)
	continentFrameTriangle:setFillColor(0)
	setStatus["continentFrameTriangle"] = "down"
------------------- 國家元件 -------------------
-- 顯示文字-"國家"
	local countryText = display.newText({
			text = "國家",
			font = getFont.font,
			fontSize = 14,		
		})
	memberSearchGroup:insert(countryText)
	countryText:setFillColor(unpack(wordColor))
	countryText.anchorX = 0
	countryText.anchorY = 0
	countryText.x = languageText.x
	countryText.y = continentFrame.y+continentFrame.contentHeight+ceil(40*hRate)
-- 國家外框
	local countrySelectFrame = display.newPolygon(cx,cy,frameVertices)
	memberSearchGroup:insert(countrySelectFrame)
	countrySelectFrame.strokeWidth = 1
	countrySelectFrame:setStrokeColor(unpack(separateLineColor))
	countrySelectFrame.anchorX = 0
	countrySelectFrame.anchorY = 0
	countrySelectFrame.x = countryText.x
	countrySelectFrame.y = countryText.y+countryText.contentHeight+floor(20*hRate)
-- 顯示文字-請選擇
	countryFrameText = display.newText({
			text = "請選擇",
			font = getFont.font,
			fontSize = 14,
		})
	memberSearchGroup:insert(countryFrameText)
	countryFrameText:setFillColor(unpack(wordColor))
	countryFrameText.anchorX = 0
	countryFrameText.x = continentFrameText.x
	countryFrameText.y = countrySelectFrame.y+countrySelectFrame.contentHeight*0.5
-- 國家選擇外框內的三角形
	local countryFrameTriangle = display.newPolygon ( continentFrameTriangle.x, countryFrameText.y, triangleVertices)
	memberSearchGroup:insert(countryFrameTriangle)
	countryFrameTriangle.strokeWidth = 2
	countryFrameTriangle:setStrokeColor(0)
	countryFrameTriangle:setFillColor(0)
	setStatus["countryFrameTriangle"] = "down"
-- 語言選擇框觸碰監聽事件
	countrySelectFrame:addEventListener("tap", function(event) 
		countryFrameTriangle:rotate(180)
		if (setStatus["countryFrameTriangle"] == "up") then 
			setStatus["countryFrameTriangle"] = "down"
			countrySelectFrame.strokeWidth = 1
			countrySelectFrame:setStrokeColor(unpack(separateLineColor))
			transition.to(countryGroup,{ y = -countryList.contentHeight, time = 200})
			timer.performWithDelay(300, function() countryList.isVisible = false ;end)
		else
			setStatus["countryFrameTriangle"] = "up"
			countrySelectFrame.strokeWidth = 2
			countrySelectFrame:setStrokeColor(unpack(subColor2))
			countryList.isVisible = true
			transition.to(countryGroup,{ y = 0, time = 200})
		end
		end)
-- 搜尋按鈕
	local searchBtn = widget.newButton({
			id = "searchBtn",
			label = "搜尋會員",
			labelColor = { default = { 1, 1, 1}, over = { 1, 1, 1} },
			font = getFont.font,
			fontSize = 14,
			defaultFile = "assets/btn-mate.png",
			width = ceil(344*wRate),
			height = ceil(85*hRate),
			onRelease = onBtnListener,
		})
	memberSearchGroup:insert(searchBtn)
	searchBtn.anchorX = 1
	searchBtn.anchorY = 1
	searchBtn.x = screenW+ox-ceil(110*wRate)
	searchBtn.y = findPaper.y+findPaper.contentHeight-ceil(100*hRate)
------------------- 國家下拉式選單 -------------------
-- 邊界
	countryList = display.newContainer( countrySelectFrame.contentWidth*0.8, screenH*0.375)
	memberSearchGroup:insert(countryList)
	countryList.anchorY = 0
	countryList.x = cx
	countryList.y = countrySelectFrame.y+countrySelectFrame.contentHeight
-- 選單內容
	countryGroup = display.newGroup()
	countryList:insert(countryGroup)
	local countryListBaseShadow =  display.newImageRect(countryGroup, "assets/shadow-320480.png", countryList.contentWidth, countryList.contentHeight)
	local countryListBase = display.newRect( countryGroup, 0, 0, (countryListBaseShadow.contentWidth)*0.95, (countryListBaseShadow.contentHeight)*59/60)
	countryListBase.y = countryListBase.y-(countryListBaseShadow.contentHeight-countryListBase.contentHeight)/2
	countryListBase:addEventListener("touch", function () return true ; end )
	countryListBase:addEventListener("tap", function () return true ; end )
-- 國家選項 ScrollView
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
-- 觸碰國家內容的監聽事件
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
			timer.performWithDelay(200, function() countrySelectFrame.strokeWidth = 1 ; end)
			timer.performWithDelay(200, function() countrySelectFrame:setStrokeColor(unpack(separateLineColor)) ; end)
			countrySelected = true
		end
		return true
	end
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
				text = country[i],
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
------------------- 語言下拉式選單 -------------------
-- 邊界	
	languageList = display.newContainer( languageSelectFrame.contentWidth*0.8, screenH*0.375)
	memberSearchGroup:insert(languageList)
	languageList.anchorY = 0
	languageList.x = cx
	languageList.y = languageSelectFrame.y+languageSelectFrame.contentHeight
-- 選單內容
	languageGroup = display.newGroup()
	languageList:insert(languageGroup)
	local languageListBaseShadow =  display.newImageRect(languageGroup, "assets/shadow-320480.png", languageList.contentWidth, languageList.contentHeight)
	local languageListBase = display.newRect( languageGroup, 0, 0, (languageListBaseShadow.contentWidth)*0.95, (languageListBaseShadow.contentHeight)*59/60)
	languageListBase.y = languageListBase.y - (languageListBaseShadow.contentHeight - languageListBase.contentHeight)/2
	languageListBase:addEventListener("touch", function () return true ; end )
	languageListBase:addEventListener("tap", function () return true ; end )
-- 語言選項 ScrollView
	local languageScrollViewHeight = 0
	local languageScrollView = widget.newScrollView({
			id = "languageScrollView",
			x = 0,
			y = 0,
			width = languageListBase.contentWidth,
			height = languageListBase.contentHeight,
			horizontalScrollDisabled = true,
			isBounceEnabled = false,
		})
	languageGroup:insert(languageScrollView)
	languageScrollView.y = languageListBaseShadow.y-((languageListBaseShadow.contentHeight-languageScrollView.contentHeight))/2
-- 觸碰語言內容的監聽事件
	local languageOptionText = {}
	local lNowTarget, lPrevTarget = nil
	local function languageListener( event )
		local phase = event.phase
		if (phase == "began") then
			if (lNowTarget == nil and lPrevTarget == nil) then
				lNowTarget = event.target
				lNowTarget:setFillColor( 0, 0, 0, 0.1)
				languageOptionText[lNowTarget.id]:setFillColor(unpack(subColor1))
			elseif (lNowTarget == nil and lPrevTarget ~= nil) then
				if (event.target ~= lPrevTarget) then
					
					languageOptionText[lPrevTarget.id]:setFillColor(unpack(wordColor))

					lNowTarget = event.target
					lNowTarget:setFillColor( 0, 0, 0, 0.1)
					languageOptionText[lNowTarget.id]:setFillColor(unpack(subColor1))
				end
			end
		elseif (phase == "moved") then
			local dx = math.abs(event.xStart-event.x)
			local dy = math.abs(event.yStart-event.y)
			if (dx > 10 or dy > 10) then
				if (lNowTarget ~= nil) then
					languageScrollView:takeFocus(event)
					lNowTarget:setFillColor(1)
					languageOptionText[lNowTarget.id]:setFillColor(unpack(wordColor))
					lNowTarget = nil
					if (lPrevTarget ~= nil) then
						languageOptionText[lPrevTarget.id]:setFillColor(unpack(subColor1))
					end
				end
			end
		elseif (phase == "ended" and lNowTarget ~= nil) then
			setStatus["languageFrameTriangle"] = "down"
			languageFrameTriangle:rotate(180)
			transition.to(languageGroup,{ y = -languageList.contentHeight, time = 200})
			lPrevTarget = lNowTarget
			lNowTarget = nil
			languageFrameText.text = languageOptionText[lPrevTarget.id].text
			timer.performWithDelay(200, function() languageList.isVisible = false ; end)
			timer.performWithDelay(200, function() lPrevTarget:setFillColor(1) ; end)
			timer.performWithDelay(200, function() languageSelectFrame.strokeWidth = 1 ; end)
			timer.performWithDelay(200, function() languageSelectFrame:setStrokeColor(unpack(separateLineColor)) ; end)
			languageSelected = true
		end
		return true
	end
-- 選項內容(語言)
	local languagePad = languageList.contentHeight/60
	local languageOptionWidth =  languageScrollView.contentWidth
	local languageOptionHeight = languagePad*10
	local languageScrollViewGroup = display.newGroup()
	languageScrollView:insert(languageScrollViewGroup)
	for i=1,#language do
		-- 白底
		local languageTextBase = display.newRect( languageOptionWidth*0.5, (languagePad+languageOptionHeight*0.5)+(languageOptionHeight+languagePad)*(i-1), languageOptionWidth, languageOptionHeight)
		languageScrollViewGroup:insert(languageTextBase)
		languageTextBase.id = i
		languageTextBase:addEventListener("touch", languageListener)
		-- 選項
		languageOptionText[i] = display.newText({
				text = language[i],
				font = getFont.font,
				fontSize = 14,
			})
		languageScrollViewGroup:insert(languageOptionText[i])
		languageOptionText[i]:setFillColor(unpack(wordColor))
		languageOptionText[i].x = languageTextBase.x
		languageOptionText[i].y = languageTextBase.y
		-- 底部間距
		if (i == #language) then
			local bottomPad = display.newRect( languageScrollViewGroup, languageTextBase.x, languageTextBase.y+languageTextBase.contentHeight*0.5+languagePad*0.5, languageOptionWidth, languagePad)
			languageScrollViewHeight = bottomPad.y+bottomPad.contentHeight*0.5
		end
	end
	if (languageScrollViewHeight > languageScrollView.contentHeight) then
		languageScrollView:setScrollHeight(languageScrollViewHeight)
	end
	languageGroup.y = -languageList.contentHeight
	languageList.isVisible = false
------------------- 性別下拉式選單 -------------------
-- 邊界
	genderList = display.newContainer( genderSelectFrame.contentWidth*0.8, screenH*0.375)
	memberSearchGroup:insert(genderList)
	genderList.anchorY = 0
	genderList.x = cx
	genderList.y = genderSelectFrame.y+genderSelectFrame.contentHeight
-- 選單內容
	genderGroup = display.newGroup()
	genderList:insert(genderGroup)
	local genderListBaseShadow =  display.newImageRect(genderGroup, "assets/shadow-320480.png", genderList.contentWidth, genderList.contentHeight)
	local genderListBase = display.newRect( genderGroup, 0, 0, (genderListBaseShadow.contentWidth)*0.95, (genderListBaseShadow.contentHeight)*59/60)
	genderListBase.y = genderListBaseShadow.y-((genderListBaseShadow.contentHeight-genderListBase.contentHeight))/2
	genderListBase:addEventListener("touch", function () return true ; end )
	genderListBase:addEventListener("tap", function () return true ; end )
-- 性別選項 ScrollView
	local genderScrollViewHeight = 0
	local genderScrollView = widget.newScrollView({
			id = "genderScrollView",
			x = 0,
			y = 0,
			width = genderListBase.contentWidth,
			height = genderListBase.contentHeight,
			horizontalScrollDisabled = true,
			isBounceEnabled = false,
			--backgroundColor = { 1, 0, 0, 0.3},
		})
	genderGroup:insert(genderScrollView)
	genderScrollView.y = genderListBase.y
-- 觸碰性別內容的監聽事件
	local genderOptionText = {}
	local gNowTarget, gPrevTarget = nil
	local function genderListener( event )
		local phase = event.phase
		if (phase == "began") then
			if (gNowTarget == nil and gPrevTarget == nil) then
				gNowTarget = event.target
				gNowTarget:setFillColor( 0, 0, 0, 0.1)
				genderOptionText[gNowTarget.id]:setFillColor(unpack(subColor1))
			elseif (gNowTarget == nil and gPrevTarget ~= nil) then
				if (event.target ~= gPrevTarget) then

					genderOptionText[gPrevTarget.id]:setFillColor(unpack(wordColor))

					gNowTarget = event.target
					gNowTarget:setFillColor( 0, 0, 0, 0.1)
					genderOptionText[gNowTarget.id]:setFillColor(unpack(subColor1))
				end
			end
		elseif (phase == "moved") then
			local dx = math.abs(event.xStart-event.x)
			local dy = math.abs(event.yStart-event.y)
			if (dx > 10 or dy > 10) then
				if (gNowTarget ~= nil) then
					genderScrollView:takeFocus(event)
					gNowTarget:setFillColor(1)
					genderOptionText[gNowTarget.id]:setFillColor(unpack(wordColor))
					gNowTarget = nil
					if (gPrevTarget ~= nil) then
						genderOptionText[gPrevTarget.id]:setFillColor(unpack(subColor1))
					end
				end
			end
		elseif (phase == "ended" and gNowTarget ~= nil) then
			setStatus["genderFrameTriangle"] = "down"
			genderFrameTriangle:rotate(180)
			transition.to(genderGroup,{ y = -genderList.contentHeight, time = 300})
			gPrevTarget = gNowTarget
			gNowTarget = nil
			genderFrameText.text = genderOptionText[gPrevTarget.id].text
			timer.performWithDelay(200, function() genderList.isVisible = false ; end)
			timer.performWithDelay(200, function() gPrevTarget:setFillColor(1) ; end)
			timer.performWithDelay(200, function() genderSelectFrame.strokeWidth = 1 ; end)
			timer.performWithDelay(200, function() genderSelectFrame:setStrokeColor(unpack(separateLineColor)) ; end)
			genderSelected = true
		end
		return true
	end
-- 選項內容(性別)
	local genderPad = genderList.contentHeight/60
	local genderOptionWidth =  genderScrollView.contentWidth
	local genderOptionHeight = genderPad*10
	local genderScrollViewGroup = display.newGroup()
	genderScrollView:insert(genderScrollViewGroup)
	for i=1,#gender do
		-- 白底
		local genderTextBase = display.newRect( genderOptionWidth*0.5, (genderPad+genderOptionHeight*0.5)+(genderPad+genderOptionHeight)*(i-1), genderOptionWidth, genderOptionHeight)
		genderScrollViewGroup:insert(genderTextBase)
		genderTextBase.id = i
		genderTextBase:addEventListener("touch",genderListener)
		-- 選項
		genderOptionText[i] = display.newText({
			text = gender[i],
			font = getFont.font,
			fontSize = 14,
		})
		genderScrollViewGroup:insert(genderOptionText[i])
		genderOptionText[i]:setFillColor(unpack(wordColor))
		genderOptionText[i].x = genderTextBase.x
		genderOptionText[i].y = genderTextBase.y
		-- 底部間距
		if (i == #gender) then
			local bottomPad = display.newRect( genderScrollViewGroup, genderTextBase.x, genderTextBase.y+genderTextBase.contentHeight*0.5+genderPad*0.5, genderOptionWidth, genderPad)
			genderScrollViewHeight = bottomPad.y+bottomPad.contentHeight*0.5
		end	
	end
	if (genderScrollViewHeight > genderScrollView.contentHeight) then 
		genderScrollView:setScrollHeight(genderScrollViewHeight)
	end
	genderGroup.y = -genderList.contentHeight
	genderList.isVisible = false
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
		composer.removeScene("memberSearch")
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