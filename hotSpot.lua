-----------------------------------------------------------------------------------------
--
-- hotSpot.lua
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

local hotSpotGroup = display.newGroup()
local allGroup = display.newGroup()
local searchTextField
local cleanTextBtn
local tableView

local mainTabBarHeight = composer.getVariable("mainTabBarHeight")
local mainTabBarY = composer.getVariable("mainTabBarY")
--mainTabBar.myTabBarHidden()

local function ceil( value )
	return math.ceil(value)
end

local function floor( value )
	return math.floor(value)
end

--  Button的按鍵監聽事件
local function onPressLinstener( event )
	local BtnId = event.target.id
	if( BtnId == "cleanTextBtn") then 
		searchTextField.text = ""
	end
end

function scene:create( event )
	local sceneGroup = self.view
	if ( composer.getVariable("mainTabBarStatus") and composer.getVariable("mainTabBarStatus") == "hidden" ) then
		mainTabBar.myTabBarScrollShown()
		mainTabBar.setSelectedHotSpot()
		composer.setVariable("mainTabBarStatus", "shown")
	else
		mainTabBar.myTabBarShown()
		mainTabBar.setSelectedHotSpot()
	end
	--	TabBar的按鍵監聽事件
	local function onTabLinstener( event )
		-- body
		local getTabId = event.target.id
		if( getTabId == "hotDestTabBtn" ) then
			searchTextField.isVisible = false
			allGroup.isVisible = false
			hotSpotGroup.isVisible = true
		end
		if (getTabId == "allBtn" ) then
			searchTextField.isVisible = true
			hotSpotGroup.isVisible = false
			allGroup.isVisible = true	
		end
	end	
------------------ TabBar元件 ------------------
-- 按鈕
	local destTabBtns = {
		{
			id = "hotDestTabBtn",
			label = "熱門目的地",
			labelColor = { default = separateLineColor, over = wordColor },
			font = getFont.font,
			size = 14,
			labelYOffset = -6,
			defaultFile = "assets/btn-space-.png", 
			overFile = "assets/btn-bottomborder-.png",
			width = (screenW+ox+ox)/2, 
			height = 116*hRate, 
			selected = true,
			onPress = onTabLinstener,
		},
		{
			id = "allBtn",
			label = "全 部",
			labelColor = { default = separateLineColor, over = wordColor },
			font = getFont.font,
			size = 14,
			labelYOffset = -6,
			defaultFile = "assets/btn-space-.png", 
			overFile = "assets/btn-bottomborder-.png",
			width = (screenW+ox+ox)/2, 
			height = 116*hRate, 
			onPress = onTabLinstener,
			selected = false,
		}
	}
-- 本體
	local destTabBar = widget.newTabBar{
		top = -oy,
		left = -ox,
		width = screenW+ox+ox, 
		height = 116*hRate,
		backgroundFile = "assets/white.png",
		tabSelectedLeftFile = "assets/Left.png",
		tabSelectedMiddleFile = "assets/Middle.png",
		tabSelectedRightFile = "assets/Right.png",
		tabSelectedFrameWidth = (screenW+ox+ox)/2/3,
		tabSelectedFrameHeight = screenH/12,
		buttons = destTabBtns,
	}
	sceneGroup:insert(destTabBar)
	destTabBar:setSelected(1)
------------------ 熱門目的地元件 ------------------
-- hotSpotScrollView
	sceneGroup:insert(hotSpotGroup)
	local function scrollviewListener( event )
		local phase = event.phase
		if (phase == "moved") then
			mainTabBar.myTabBarScrollHidden()
		else
			mainTabBar.myTabBarScrollShown()
		end
	end
	local hotSpotSrcollView = widget.newScrollView({
		id = "hotSpotSrcollView",
		top = -oy+destTabBar.contentHeight+floor(15*hRate),
		width = screenW+ox+ox, 
		height = screenH+oy+oy-destTabBar.contentHeight,
		hidebackground = false,
		backgroundColor = backgroundColor,
		horizontalScrollDisabled = true,
		verticalScrollDisabled = false,
		listener = scrollviewListener,
	})
	hotSpotGroup:insert(hotSpotSrcollView)
	hotSpotSrcollView.x = cx
-- 觸碰圖片去主題推薦頁面的監聽事件
	local hotSpotScrollViewGroup = display.newGroup()
	hotSpotSrcollView:insert(hotSpotScrollViewGroup)
	local rowPicureNum = {}
	local rowTitleNum = {}
	local hotSpotPic = {}
	local hotSpotTitle = {}
	local picture = { "assets/Angkor.png","assets/temple.jpg" }
	local function recommendCreateListener( event )
		local phase = event.phase
		local id = event.target.id
		if (phase == "moved") then
			-- 背景scrollview移動
			local dy = math.abs(event.yStart-event.y)
			if ( dy > 10) then
				hotSpotSrcollView:takeFocus(event)
			end
		elseif (phase == "ended") then
			hotSpotPic[id]:removeEventListener("touch",recommendCreateListener)
			local setPicName
			if ( id%2 == 0) then 
				setPicName = picture[2]
			else
				setPicName = picture[1]
			end
			local options = {
				params = {
					titlePicName = setPicName,
					titleTextContent = hotSpotTitle[id].text
				}
			}
			composer.gotoScene("recommendTitle", options)
		end
		return true
	end
-- 將圖片放入 hotSpotSrcollView
	local picYPadding = floor(15*hRate)
	local scrollHeight = 0
	for i=1,10 do 
		local pictureNum
		if( i%2 ==0 ) then 
			pictureNum = 2
		else
			pictureNum = 1
		end

		local rowPicure = display.newImageRect(picture[pictureNum], hotSpotSrcollView.contentWidth, ceil(445*wRate))
		hotSpotScrollViewGroup:insert(rowPicure)
		rowPicure.x = hotSpotSrcollView.contentWidth*0.5
		rowPicure.y = rowPicure.contentHeight*0.5+(rowPicure.contentHeight+picYPadding)*(i-1)
		rowPicure.id = i
		rowPicureNum[i] = hotSpotScrollViewGroup.numChildren
		hotSpotPic[i] = rowPicure
		rowPicure:addEventListener("touch", recommendCreateListener)

    	local rowTitle = display.newText({
			text = "吳哥窟 " .. i,
			font = getFont.font,
			fontSize = 24
    	})
    	hotSpotScrollViewGroup:insert(rowTitle)
    	hotSpotTitle[i] = rowTitle
    	rowTitleNum[i] = hotSpotScrollViewGroup.numChildren
    	rowTitle.x = rowPicure.x
    	rowTitle.y = rowPicure.y

    	if (i == 10) then 
    		local bottomPadding = display.newRect(rowPicure.x, rowPicure.y+rowPicure.contentHeight*0.5+picYPadding*0.5, hotSpotSrcollView.contentWidth, picYPadding)
    		hotSpotScrollViewGroup:insert(bottomPadding)
    		scrollHeight = bottomPadding.y+bottomPadding.contentHeight+mainTabBarHeight
    	end
	end	
	hotSpotSrcollView:setScrollHeight(scrollHeight)
------------------ 全部元件 ------------------
	sceneGroup:insert(allGroup)
	allGroup.isVisible = false
-- 陰影
	local searchShadow = display.newImageRect("assets/shadow0205.png", screenW+ox+ox, floor(178*hRate))
	allGroup:insert(searchShadow)
	searchShadow.x = cx
	searchShadow.y = -oy+destTabBar.contentHeight+floor(15*hRate)+searchShadow.contentHeight*0.5
-- icon-放大鏡
	local searchIcon = display.newImageRect("assets/btn-search-b.png", 261, 261)
	allGroup:insert(searchIcon)
	searchIcon.anchorX = 0
	searchIcon.width = searchIcon.width*0.07
	searchIcon.height = searchIcon.height*0.07
	searchIcon.x = -ox+ceil(50*wRate)
	searchIcon.y =	searchShadow.y-searchShadow.contentHeight*0.05
-- 圖片-搜尋欄外框
	local searchBarPic = display.newImageRect("assets/enter-search-b-short.png",(screenW+ox+ox)*0.85, searchShadow.contentHeight*0.6)
	allGroup:insert(searchBarPic)
	searchBarPic.anchorX = 0
	searchBarPic.x = searchIcon.x+searchIcon.contentWidth+ceil(32*wRate)
	searchBarPic.y = searchIcon.y
-- 輸入欄位	
	searchTextField = native.newTextField( searchBarPic.x+ceil(35*wRate), searchBarPic.y, (screenW+ox+ox)*0.75, searchBarPic.contentHeight*0.8)
	allGroup:insert(searchTextField)
	searchTextField.anchorX = 0
	searchTextField.hasBackground = false
	searchTextField.font = getFont.font
	--searchTextField.size = 16
	searchTextField:resizeFontToFitHeight()
	searchTextField.inputType = "default"
	searchTextField.align = "left"
	searchTextField:setSelection(0,0)
	searchTextField.placeholder = "輸入目的地、景點或活動..."
	searchTextField.isVisible = false
-- 按鈕-清除輸入內容
	cleanTextBtn = widget.newButton({
		id = "cleanTextBtn",
		x = searchTextField.x+searchTextField.contentWidth, 
		y = searchTextField.y,
		defaultFile="assets/btn-search-delete.png", 
		width = 240*0.08, 
		height = 240*0.08,
		onRelease = onPressLinstener
	})
	allGroup:insert(cleanTextBtn)
	cleanTextBtn.anchorX = 0
	cleanTextBtn.isVisible = false

-- TextField 的 userInput監聽事件
	local function onTextFieldListener( event )
		local phase = event.phase
		if ( phase == "editing" and event.text ~= "" ) then
			cleanTextBtn.isVisible = true
		else
			cleanTextBtn.isVisible = false
		end
		if ( phase == "ended" or phase == "submitted") then 
			event.target.text = ""
			cleanTextBtn.isVisible = false
		end
	end
	searchTextField:addEventListener("userInput", onTextFieldListener)
end

function scene:show( event )
	local sceneGroup = self.view
	local phase = event.phase
	if phase == "will" then
	elseif phase == "did" then
	end	
end
 
function scene:hide( event )
	local sceneGroup = self.view
	local phase = event.phase
	if event.phase == "will" then

	elseif phase == "did" then
		composer.removeScene("hotSpot")
	end
end

function scene:destroy( event )
	local sceneGroup = self.view
end

---------------------------------------------------------------------------------

-- Listener setup
scene:addEventListener( "create", scene )
scene:addEventListener( "show", scene )
scene:addEventListener( "hide", scene )
scene:addEventListener( "destroy", scene )

-----------------------------------------------------------------------------------------

--local myViews = { hotSpotGroup , allGroup }
--slideView.new(myViews)
--onHotDestinationView()
--onAllView()
return scene