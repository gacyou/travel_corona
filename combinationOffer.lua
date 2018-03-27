-----------------------------------------------------------------------------------------
--
-- combinationOffer.lua
--
-----------------------------------------------------------------------------------------
local widget = require ("widget")
local composer = require ("composer")
local mainTabBar = require ("mainTabBar")
local getFont = require("setFont")
local json = require("json")
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

local searchTextField,searchText
local titleSearchTextField

local function ceil( value )
	return math.ceil( value )
end

local function floor( value )
	return math.floor( value )
end

-- create()
function scene:create( event )
	local sceneGroup = self.view
	if ( composer.getVariable("mainTabBarStatus") and composer.getVariable("mainTabBarStatus") == "hidden" ) then
		mainTabBar.myTabBarScrollShown()
		mainTabBar.setCominationOffer()
		composer.setVariable("mainTabBarStatus", "shown")
	else
		mainTabBar.myTabBarShown()
		mainTabBar.setCominationOffer()
	end
	local mainTabBarHeight = composer.getVariable("mainTabBarHeight")
	local cleanTextBtn, titleCleanTextBtn
	local optionList = { "獨家主題", "一般出團", "當地集散", "自助包車", "藝品餐券", "其他服務", "住宿訂房"}
	local sortOptions = { "人氣最高", "價格低至高", "最新商品"}
	local sortListBoundary, sortListGroup
	local eventListBoundary, eventListGroup
	local setStatus = {}
	local mainScrollview
	local tempText = ""
------------------- 抬頭元件1 -------------------
-- 白底
	local titleBaseGroup = display.newGroup()
	sceneGroup:insert(titleBaseGroup)
	local titleBase = display.newRect( titleBaseGroup, cx, -oy, screenW+ox+ox, floor(178*hRate))
	titleBase.x = cx
	titleBase.y = titleBase.y+titleBase.contentHeight*0.5
-- 返回按鈕圖片
	local backArrow = display.newImage( titleBaseGroup, "assets/btn-back-b.png",-ox+ceil(49*wRate), -oy+titleBase.contentHeight*0.5)
	backArrow.width = backArrow.width*0.07
	backArrow.height = backArrow.height*0.07
	backArrow.anchorX = 0
	local backArrowNum = titleBaseGroup.numChildren
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
	titleBaseGroup:insert(backArrowNum,backBtn)
-- 顯示文字-"組合優惠"
	local titleText = display.newText({
		text = "組合優惠",
		height = 0,
		y = backBtn.y,
		font = getFont.font,
		fontSize = 14,
	})
	titleBaseGroup:insert(titleText)
	titleText:setFillColor(unpack(wordColor))
	titleText.anchorX = 0
	titleText.x = backArrow.x+backArrow.contentWidth+ceil(30*wRate)
-- 購物車圖片
	local shoppingCart = display.newImage( titleBaseGroup, "assets/btn-cart-b.png",(screenW+ox)-(45*wRate), backArrow.y)
	shoppingCart.anchorX = 1
	shoppingCart.width = shoppingCart.width*0.07
	shoppingCart.height = shoppingCart.height*0.07
	local shoppingCartNum = titleBaseGroup.numChildren
-- 購物車按鈕
	local cartBtn = widget.newButton({
		id = "cartBtn",
		x = shoppingCart.x-shoppingCart.contentWidth*0.5,
		y = shoppingCart.y,
		shape = "rect",
		--fillColor = { default = {1,0,1,0.3}, over = {1,0,1,0.3}},
		width = screenW*0.09,
		height = backBtn.contentHeight,
		onRelease = 
			function ()
				mainTabBar.setShoppingCart()
				composer.gotoScene("shoppingCart")
			end,
	})
 	titleBaseGroup:insert( shoppingCartNum, cartBtn)
-- 排序圖片
	local sort = display.newImage( titleBaseGroup, "assets/btn-sort.png", shoppingCart.x-shoppingCart.contentWidth-(45*wRate), shoppingCart.y)
	sort.anchorX = 1
	sort.width = sort.width*0.055
	sort.height = sort.height*0.055
	local sortNum = titleBaseGroup.numChildren
	setStatus["sortList"] = "down"
-- 排序按鈕
	local sortBtn = widget.newButton({
		id = "sortBtn",
		x = sort.x-sort.contentWidth*0.5,
		y = sort.y,
		shape = "rect",
		width = screenW*0.09,
		height = backBtn.contentHeight,
		onRelease = function ()
			if (setStatus["sortList"] == "down") then
				if (setStatus["eventArrow"] == "up") then
					setStatus["eventArrow"] = "down"
					eventListBoundary.isVisible = false
					timer.performWithDelay(100, function ()
						transition.to(eventListGroup, { y = -eventListBoundary.contentHeight, time = 200})
					end) 
				end
				setStatus["sortList"] = "up"
				sortListBoundary.isVisible = true
				transition.to(sortListGroup, { y = 0,time = 200})
				local x,y = mainScrollview:getContentPosition()
				if (y > -10) then
					searchTextField.isVisible = false
					searchText.isVisible = true
				end
				mainTabBar.myTabBarScrollHidden()
			else
				setStatus["sortList"] = "down"
				local x,y = mainScrollview:getContentPosition()
				if (y > -10) then
					searchTextField.isVisible = true
					searchText.isVisible = false
				end
				transition.to(sortListGroup, { y = -sortListBoundary.contentHeight, time = 200})
				timer.performWithDelay( 200, function () sortListBoundary.isVisible = false; end)
				mainTabBar.myTabBarScrollShown()
			end
			return true
		end,
	})
	titleBaseGroup:insert( sortNum, sortBtn)
------------------- 抬頭元件2 -------------------
-- 白底
	local titleSearchGroup = display.newGroup()
	sceneGroup:insert(titleSearchGroup)
	local titleSearchBase = display.newRect( titleSearchGroup, cx, -oy, screenW+ox+ox, floor(178*hRate))
	titleSearchBase.x = cx
	titleSearchBase.y = titleSearchBase.y+titleSearchBase.contentHeight*0.5
-- 圖示-btn-search-b.png
	local titleSearchPic = display.newImage( titleSearchGroup, "assets/btn-search-b.png", ceil(49*wRate), titleSearchBase.y)
	titleSearchPic.anchorX = 0
	titleSearchPic.width = titleSearchPic.width*0.07
	titleSearchPic.height = titleSearchPic.height*0.07
-- 圖示-enter-search-b-short.png
	local titleSearchFrame = display.newImage( titleSearchGroup, "assets/enter-search-b-short.png", titleSearchPic.x+titleSearchPic.contentWidth+ceil(30*wRate), titleSearchBase.y)
	titleSearchFrame.anchorX = 0
	titleSearchFrame.width = titleSearchBase.contentWidth*0.75
	titleSearchFrame.height = titleSearchBase.contentHeight*0.8
-- 搜尋輸入欄
	titleSearchTextField = native.newTextField( titleSearchFrame.x+ceil(30*wRate), titleSearchBase.y, titleSearchFrame.contentWidth*0.85, titleSearchFrame.contentHeight*0.7)
	titleSearchGroup:insert(titleSearchTextField)
	titleSearchTextField.anchorX = 0
	titleSearchTextField.text = ""
	titleSearchTextField.name = "titleSearch"	
	titleSearchTextField.hasBackground = false
	titleSearchTextField.font = getFont.font
	titleSearchTextField:resizeFontToFitHeight()
	titleSearchTextField.inputType = "default"
	titleSearchTextField.align = "left"
	titleSearchTextField:setSelection(0,0)
	titleSearchTextField:setTextColor(unpack(wordColor))
	titleSearchTextField.placeholder = "搜尋活動"
	titleSearchTextField.isVisible = false
-- 按鈕-清除輸入內容
	titleCleanTextBtn = widget.newButton({
		id = "titleCleanTextBtn",
		x = titleSearchTextField.x+titleSearchTextField.contentWidth+ceil(10*wRate), 
		y = titleSearchTextField.y,
		defaultFile="assets/btn-search-delete.png", 
		width = 240*0.08, 
		height = 240*0.08,
		onRelease = function (event)
			tempText = nil
			searchTextField.text = ""
			titleSearchTextField.text = ""
			searchText.text = "搜尋活動"
			event.target.isVisible = false
			cleanTextBtn.isVisible = false
			return true
		end
	})
	titleSearchGroup:insert(titleCleanTextBtn)
	titleCleanTextBtn.anchorX = 0
	titleCleanTextBtn.isVisible = false
-- 圖示-btn-search-delete-b.png
	local searchBackCross = display.newImage( titleSearchGroup, "assets/btn-search-delete-b.png", screenW+ox-ceil(30*wRate), titleSearchBase.y)
	searchBackCross.width = searchBackCross.width*0.08
	searchBackCross.height = searchBackCross.height*0.08
	searchBackCross.x = searchBackCross.x - searchBackCross.contentWidth*0.5
	searchBackCross:rotate(180)
	local searchBackCrossNum = titleSearchGroup.numChildren
-- 關閉抬頭2按鈕
	local searchBackCrossBtn = widget.newButton({
		id = "searchBackCrossBtn",
		x = searchBackCross.x,
		y = searchBackCross.y,
		shape = "rect",
		--fillColor = { default = {1,0,1,0.3}, over = {1,0,1,0.3}},
		width = screenW*0.1,
		height = titleBase.contentHeight,
		onRelease = function ()
			titleBaseGroup.isVisible = true
			titleSearchGroup.isVisible = false
			titleSearchTextField.isVisible = false
			return true
		end
	})
	titleSearchGroup:insert(searchBackCrossNum,searchBackCrossBtn)
	titleSearchGroup.isVisible = false
------------------- 抬頭元件1 -------------------
-- 抬頭1-搜尋按鈕事件
	local function titleSearch( evnet )
		titleBaseGroup.isVisible = false
		titleSearchGroup.isVisible = true
		titleSearchTextField.isVisible = true
		return true
	end
-- 抬頭1-搜尋圖片
	local search = display.newImage( titleBaseGroup, "assets/btn-search-b.png", sort.x-sort.contentWidth-(45*wRate), sort.y)
	search.anchorX = 1
	search.width = search.width*0.07
	search.height = search.height*0.07
	local searchNum = titleBaseGroup.numChildren
	search.isVisible = false
-- 抬頭1-搜尋按鈕
	local searchBtn = widget.newButton({
		id = "searchBtn",
		x = search.x-search.contentWidth*0.5,
		y = search.y,
		shape = "rect",
		width = screenW*0.09,
		height = backBtn.contentHeight,
		onRelease = titleSearch,
	})
	titleBaseGroup:insert( searchNum, searchBtn)
	searchBtn.isVisible = false
------------------- scrollView元件 -------------------
-- mainScrollView 事件
	local eventGroup
	local function mainScrollviewListener( event )
		local phase = event.phase
		local x,y = event.target:getContentPosition()
		if (y < -10) then
		-- scrollView搜尋功能off
			searchTextField.isVisible = false
			if (setStatus["search"] == "on" or setStatus["titleSearch"] == "on") then
				native.setKeyboardFocus(nil)
				setStatus["search"] = "off" 
				setStatus["titleSearch"] = "off"
			end
			--if (searchTextField.text ~= "") then
			--	searchText.text = searchTextField.text
			--end
			searchText.isVisible = true
		end
		if (y > -10) then
		-- scrollView搜尋功能on
			if (tempText ~= nil ) then
				searchTextField.text = tempText

			end
			searchTextField.isVisible = true
			searchText.isVisible = false
		end
		if (y < -46) then
		-- 抬頭搜尋功能on
			search.isVisible = true
			searchBtn.isVisible = true
		end
		if (y > -46) then
		-- 抬頭搜尋功能off	
			titleBaseGroup.isVisible = true
			search.isVisible = false
			searchBtn.isVisible = false
			titleSearchGroup.isVisible = false
			titleSearchTextField.isVisible = false
		end
		if (y < -60) then
			eventGroup.isVisible = true
		end
		if (y > -60) then
			eventGroup.isVisible = false
		end
	end
-- 上下滑動的scrollView
	mainScrollview = widget.newScrollView({
		id = "mainScrollview",
		width = screenW+ox+ox,
		height = screenH+oy+oy-titleBase.contentHeight,
		horizontalScrollDisabled = true,
		isBounceEnabled = false,
		backgroundColor = backgroundColor,
		listener = mainScrollviewListener,
	})
	sceneGroup:insert(mainScrollview)
	mainScrollview.anchorY = 0
	mainScrollview.x = -ox+mainScrollview.contentWidth*0.5
	mainScrollview.y = -oy+titleBase.contentHeight
-- scrollView內部元件相關參數
	local mainScrollViewGroup = display.newGroup()
	mainScrollview:insert(mainScrollViewGroup)
	local scrollViewWidth = mainScrollview.contentWidth
	local setScrollHeight = 0
-- 搜尋欄
	-- 白底
	local searchBase = display.newRect( mainScrollViewGroup, scrollViewWidth*0.5, 1,scrollViewWidth, floor(178*hRate))
	searchBase.y = searchBase.y+searchBase.contentHeight*0.5
	setScrollHeight = setScrollHeight+searchBase.y+searchBase.contentHeight*0.5
	-- 圖示-btn-search-b.png-放大鏡
	local searchPic = display.newImage( mainScrollViewGroup, "assets/btn-search-b.png", ceil(49*wRate), searchBase.y)
	searchPic.anchorX = 0
	searchPic.width = searchPic.width*0.07
	searchPic.height = searchPic.height*0.07
	-- 圖示-enter-search-b-short.png-藍色外框
	local searchFrame = display.newImage( mainScrollViewGroup, "assets/enter-search-b-short.png", searchPic.x+searchPic.contentWidth+ceil(30*wRate), searchBase.y)
	searchFrame.anchorX = 0
	searchFrame.width = scrollViewWidth*0.85
	searchFrame.height = searchBase.contentHeight*0.8
	-- 輸入欄位
	searchTextField = native.newTextField( searchFrame.x+ceil(30*wRate), searchBase.y, searchFrame.contentWidth*0.85, searchFrame.contentHeight*0.7)
	mainScrollViewGroup:insert(searchTextField)
	searchTextField.anchorX = 0
	searchTextField.text = ""
	searchTextField.name = "search"
	searchTextField.hasBackground = false
	searchTextField.font = getFont.font
	searchTextField:resizeFontToFitHeight()
	searchTextField.inputType = "default"
	searchTextField.align = "left"
	searchTextField:setSelection(0,0)
	searchTextField:setTextColor(unpack(wordColor))
	searchTextField.placeholder = "搜尋活動"
	searchTextField.isVisible = false
	-- 顯示文字
	searchText = display.newText({
		parent = mainScrollViewGroup,
		text = "搜尋活動",
		font = getFont.font,
		fontSize = searchTextField.size,
		x = searchTextField.x+1,
		y = searchTextField.y+1,
	})
	searchText:setFillColor(unpack(wordColor))
	searchText.anchorX = 0
	searchText.isVisible = false
	-- 按鈕-清除輸入內容
	cleanTextBtn = widget.newButton({
		id = "cleanTextBtn",
		x = searchTextField.x+searchTextField.contentWidth+ceil(20*wRate), 
		y = searchTextField.y,
		defaultFile="assets/btn-search-delete.png", 
		width = 240*0.08, 
		height = 240*0.08,
		onRelease = function (event)
			tempText = nil
			searchTextField.text = ""
			titleSearchTextField.text = ""
			searchText.text = "搜尋活動"
			event.target.isVisible = false
			titleCleanTextBtn.isVisible = false
		end
	})
	mainScrollViewGroup:insert(cleanTextBtn)
	cleanTextBtn.anchorX = 0
	cleanTextBtn.isVisible = false
	-- searchTextField 的 userInput監聽事件
	local function onTextFieldListener( event )
		local phase = event.phase
		if (phase == "began") then
			if (event.target.name == "search") then
				setStatus["search"] = "on"
			elseif 	(event.target.name == "titleSearch") then
				setStatus["titleSearch"] = "on"
			end
		elseif ((phase == "editing" and event.text ~= nil) or event.target.text ~= "") then
			if (event.target.name == "search") then
				cleanTextBtn.isVisible = true
			elseif (event.target.name == "titleSearch") then
				titleCleanTextBtn.isVisible = true
			end
			if (event.text ~= nil ) then
				tempText = event.text
				searchText.text = tempText
				titleSearchTextField.text = tempText
				cleanTextBtn.isVisible = true
				titleCleanTextBtn.isVisible = true
			end
		elseif (phase == "ended" or phase == "submitted") then
			event.target.text = ""
			cleanTextBtn.isVisible = false
			titleCleanTextBtn.isVisible = false
		end
	end
	searchTextField:addEventListener("userInput", onTextFieldListener)
	titleSearchTextField:addEventListener("userInput", onTextFieldListener)
	-- 分隔線
	local themeLine = display.newLine( mainScrollViewGroup, 0, searchBase.y+searchBase.contentHeight*0.5, scrollViewWidth, searchBase.y+searchBase.contentHeight*0.5)
	themeLine:setStrokeColor(unpack(backgroundColor))
	themeLine.strokeWidth = 1
	setScrollHeight = setScrollHeight+themeLine.strokeWidth
-- 主題欄ScrollView
	local themeScrollView = widget.newScrollView({
		top = setScrollHeight,
		left = -ox,
		id = "themeScrollView",
		width = scrollViewWidth,
		height = floor(178*hRate),
		verticalScrollDisabled  = true,
		isBounceEnabled = false,
	})
	mainScrollViewGroup:insert(themeScrollView)
	setScrollHeight = setScrollHeight+themeScrollView.contentHeight
-- 主題欄選項
	local thememainScrollViewGroup = display.newGroup()
	themeScrollView:insert(thememainScrollViewGroup)
	-- 選項參數
	local defaultIcon, overIcon, themeBase, themeText = {}, {}, {}, {}
	-- 下拉式選單參數
	local listBase, listText = {}, {}
	-- 選項事件
	local isCancel = false
	local defaultTheme, defaultList, defaultTarget, nowTarget, preTarget = nil, nil, nil, nil, nil
	local function optionListener( event )
		local phase = event.phase
		local name = event.target.name
		if (name == "theme") then
			defaultTarget = defaultTheme
		elseif (name == "list") then
			defaultTarget = defaultList
		end
		if (phase == "began") then
			if (event.target ~= defaultTarget) then
				if (isCancel == true) then
					isCancel = false
				end
				nowTarget = event.target
				overIcon[nowTarget.id].isVisible = true
				defaultIcon[nowTarget.id].isVisible = false
				themeText[nowTarget.id]:setFillColor(unpack(mainColor1))
				listText[nowTarget.id]:setFillColor(unpack(subColor2))

				overIcon[defaultTarget.id].isVisible = false
				defaultIcon[defaultTarget.id].isVisible = true
				themeText[defaultTarget.id]:setFillColor(unpack(wordColor))
				listText[defaultTarget.id]:setFillColor(unpack(wordColor))
			end
		elseif (phase == "moved") then
			isCancel = true
			if ( event.target ~= defaultTarget and nowTarget ~= nil) then
				if (name == "theme") then
					local dy = math.abs(event.yStart-event.y)
					if (dy > 10) then
						mainScrollview:takeFocus(event)
					end
					local dx = math.abs(event.xStart-event.x)
					if (dx > 10) then
						themeScrollView:takeFocus(event)
					end
				end
				overIcon[defaultTarget.id].isVisible = true
				defaultIcon[defaultTarget.id].isVisible = false
				themeText[defaultTarget.id]:setFillColor(unpack(mainColor1))
				listText[defaultTarget.id]:setFillColor(unpack(subColor2))

				overIcon[nowTarget.id].isVisible = false
				defaultIcon[nowTarget.id].isVisible = true
				themeText[nowTarget.id]:setFillColor(unpack(wordColor))
				listText[nowTarget.id]:setFillColor(unpack(wordColor))
			end
		elseif (phase == "ended" and isCancel == false and event.target ~= defaultTarget) then
			preTarget = defaultTarget
			defaultTarget = nowTarget
			nowTarget = nil
			defaultTheme = themeBase[defaultTarget.id]
			defaultList = listBase[defaultTarget.id]
			if (name == "list") then
				setStatus["eventArrow"] = "down"
				transition.to(eventListGroup, { y = -eventListBoundary.contentHeight, time = 200})
				mainTabBar.myTabBarScrollShown()
				timer.performWithDelay(200, function ()	eventListBoundary.isVisible = false; end)
				if (defaultTarget.id > 5) then
					themeScrollView:scrollTo( "right", {time = 200})
				else
					themeScrollView:scrollTo( "left", {time = 200})
				end
			end
		end
		return true
	end
	-- 選項
	for i=1,#optionList do
		themeBase[i] = display.newRect( thememainScrollViewGroup, (themeScrollView.contentHeight*1.5)*(i-1), 0, themeScrollView.contentHeight*1.5, themeScrollView.contentHeight)
		--themeBase[i]:setFillColor( math.random(), math.random(), math.random())
		themeBase[i].x = themeBase[i].x+themeBase[i].contentWidth*0.5
		themeBase[i].y = themeBase[i].y+themeBase[i].contentHeight*0.5
		themeBase[i].id = i
		themeBase[i].name = "theme"
		themeBase[i]:addEventListener("touch",optionListener)

		overIcon[i] = display.newImage( thememainScrollViewGroup, "assets/"..(i+1).."-.png", themeBase[i].x, themeBase[i].y-themeBase[i].contentHeight*0.4)
		overIcon[i].anchorY = 0
		overIcon[i].width = overIcon[i].width*0.25
		overIcon[i].height = overIcon[i].height*0.25

		defaultIcon[i] = display.newImage( thememainScrollViewGroup, "assets/theme0"..(i+1)..".png", themeBase[i].x, themeBase[i].y-themeBase[i].contentHeight*0.4)
		defaultIcon[i].anchorY = 0
		defaultIcon[i].width = defaultIcon[i].width*0.25
		defaultIcon[i].height = defaultIcon[i].height*0.25

		themeText[i] = display.newText({
			parent = thememainScrollViewGroup,
			text = optionList[i],
			font = getFont.font,
			fontSize = 10,
			x = overIcon[i].x,
			y = overIcon[i].y+overIcon[i].contentHeight+floor(12*hRate),
		})
		themeText[i].anchorY = 0
		if ( i == 1) then 
			defaultIcon[i].isVisible = false
			themeText[i]:setFillColor(unpack(mainColor1))
			defaultTheme = themeBase[i]
		else
			overIcon[i].isVisible = false
			themeText[i]:setFillColor(unpack(wordColor))
		end
	end
-- 商品顯示區
	for i=1, 5 do
		local goodShadow = display.newImageRect( mainScrollViewGroup, "assets/shadow-3.png", ceil(990*wRate), floor(663*hRate))
		goodShadow.anchorY = 0
		goodShadow.x = scrollViewWidth*0.5
		goodShadow.y = setScrollHeight+floor(45*hRate)
		setScrollHeight = goodShadow.y+goodShadow.contentHeight
		if (i==5) then
			setScrollHeight = setScrollHeight+floor(45*hRate)
		end
	end
	if (setScrollHeight > mainScrollview.contentHeight) then
		mainScrollview:setScrollHeight(setScrollHeight+mainTabBarHeight)
	end
-- 全部活動觸碰事件
	local function eventBaseListener( event )
		local phase = event.phase
		if (phase == "ended") then
			if (setStatus["eventArrow"] == "down") then
				setStatus["eventArrow"] = "up"
				eventListBoundary.isVisible = true
				transition.to(eventListGroup, { y = 0,time = 200})
				mainTabBar.myTabBarScrollHidden()
			end
			if (event.target.name == "blackBase" and setStatus["eventArrow"] == "up") then
				setStatus["eventArrow"] = "down"
				transition.to(eventListGroup, { y = -eventListBoundary.contentHeight, time = 200})
				timer.performWithDelay( 200, function () eventListBoundary.isVisible = false; end)
				mainTabBar.myTabBarScrollShown()
			end
		end
		return true
	end
-- 全部活動
	eventGroup = display.newGroup()
	sceneGroup:insert(eventGroup)
	local eventBase = display.newRect( cx, titleBase.y+titleBase.contentHeight*0.5, titleBase.contentWidth, titleBase.contentHeight*0.8)
	eventGroup:insert(eventBase)
	eventBase.y = eventBase.y+eventBase.contentHeight*0.5
	eventBase:addEventListener("touch", eventBaseListener)
	local eventLine = display.newLine( eventGroup, 0, eventBase.y-eventBase.contentHeight*0.5, eventBase.contentWidth, eventBase.y-eventBase.contentHeight*0.5)
	eventLine.strokeWidth = 1
	eventLine:setStrokeColor(unpack(backgroundColor))
	local eventText = display.newText({
		parent = eventGroup,
		text = "全部活動",
		font = getFont.font,
		fontSize = 12,
		x = eventBase.x*0.85,
		y = eventBase.y,
	})
	eventText:setFillColor(unpack(wordColor))
	local eventArrow = display.newImage( eventGroup,"assets/btn-dropdown.png", eventBase.x*1.05, eventBase.y)
	eventArrow.width = eventArrow.width*0.04
	eventArrow.height = eventArrow.height*0.04
	setStatus["eventArrow"] = "down"
	eventGroup.isVisible = false
-- 全部活動下拉式選單
	eventListBoundary = display.newContainer(screenW+ox+ox, screenH+oy+oy-titleBase.contentHeight)
	sceneGroup:insert(eventListBoundary)
	eventListBoundary.anchorY = 0
	eventListBoundary.x = cx
	eventListBoundary.y = titleBase.y+titleBase.contentHeight*0.5
	eventListGroup = display.newGroup()
	eventListBoundary:insert(eventListGroup)
-- 下拉式選單元件
	for i=1,#optionList do
		listBase[i] = display.newRect( eventListGroup, 0, -eventListBoundary.contentHeight*0.5, eventListBoundary.contentWidth, screenH/16)
		listBase[i].anchorY = 0
		listBase[i].y = listBase[i].y+(listBase[i].contentHeight)*(i-1)
		listBase[i].id = i
		listBase[i].name = "list"
		listBase[i]:addEventListener("touch", optionListener)

		listText[i] = display.newText({
			parent = eventListGroup,
			text = optionList[i],
			font = getFont.font,
			fontSize = 12,
			x = 0,
			y = listBase[i].y+listBase[i].contentHeight*0.5,
		})
		if ( i == defaultTheme.id) then
			listText[i]:setFillColor(unpack(subColor2))
			defaultList = listBase[i]
		else 
			listText[i]:setFillColor(unpack(wordColor))
		end
		if ( i == #optionList) then
			local listBlackBase = display.newRect( eventListGroup, 0, listBase[i].y+listBase[i].contentHeight, eventListBoundary.contentWidth, eventListBoundary.contentHeight-listBase[i].contentHeight*#optionList)
			listBlackBase.anchorY = 0
			listBlackBase:setFillColor(0,0,0,0.4)
			listBlackBase.name = "blackBase"
			listBlackBase:addEventListener("touch", eventBaseListener)
		end
	end
	eventListGroup.y = -eventListBoundary.contentHeight
	eventListBoundary.isVisible = false
-- 排序下拉式選單
	local sortListText = {}
	sortListBoundary = display.newContainer(screenW+ox+ox, screenH+oy+oy-titleBase.contentHeight)
	sceneGroup:insert(sortListBoundary)
	sortListBoundary.anchorY = 0
	sortListBoundary.x = cx
	sortListBoundary.y = titleBase.y+titleBase.contentHeight*0.5
	sortListGroup = display.newGroup()
	sortListBoundary:insert(sortListGroup)
-- 下拉式選單元件
	for i=1,#sortOptions do
		sortListBase = display.newRect( sortListGroup, 0, -sortListBoundary.contentHeight*0.5, sortListBoundary.contentWidth, screenH/16)
		sortListBase.anchorY = 0
		sortListBase.y = sortListBase.y+(sortListBase.contentHeight)*(i-1)
		sortListBase.id = i
		sortListBase:addEventListener("touch", function () return true;	end)
		if (i == 1) then
			local sortTitleLine = display.newLine( sortListGroup, sortListBase.x-sortListBase.contentWidth*0.5, sortListBase.y, sortListBase.x+sortListBase.contentWidth*0.5, sortListBase.y)
			sortTitleLine:setStrokeColor(unpack(backgroundColor))
			sortTitleLine.strokeWidth = 2
		end
		sortListText[i] = display.newText({
			parent = sortListGroup,
			text = sortOptions[i],
			font = getFont.font,
			fontSize = 12,
			x = 0,
			y = sortListBase.y+sortListBase.contentHeight*0.5,
		})
		sortListText[i]:setFillColor(unpack(wordColor))
		if ( i == #sortOptions) then
			local sortListBlackBase = display.newRect( sortListGroup, 0, sortListBase.y+sortListBase.contentHeight, sortListBoundary.contentWidth, sortListBoundary.contentHeight-sortListBase.contentHeight*#sortOptions)
			sortListBlackBase.anchorY = 0
			sortListBlackBase:setFillColor(0,0,0,0.4)
			sortListBlackBase:addEventListener("touch", 
			function ( event )
				local phase = event.phase
				if (phase == "ended") then
					setStatus["sortList"] = "down"
					local x,y = mainScrollview:getContentPosition()
					if (y > -10) then
						searchTextField.isVisible = true
						searchText.isVisible = false
					end
					transition.to(sortListGroup, { y = -sortListBoundary.contentHeight, time = 200})
					timer.performWithDelay( 200, function () sortListBoundary.isVisible = false; end)
					mainTabBar.myTabBarScrollShown()
				end
				return true
			end)
		end
	end
	sortListGroup.y = -sortListBoundary.contentHeight
	sortListBoundary.isVisible = false
end

-- show()
function scene:show( event )
	local sceneGroup = self.view
	local phase = event.phase
	if ( phase == "will" ) then
	elseif ( phase == "did" ) then
		searchTextField.isVisible = true
	end
end

-- hide()
function scene:hide( event )
	local sceneGroup = self.view
	local phase = event.phase
	if ( phase == "will" ) then
	elseif ( phase == "did" ) then
		composer.removeScene("combinationOffer")
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