-----------------------------------------------------------------------------------------
--
-- HS_hotSpot.lua
--
-----------------------------------------------------------------------------------------
local composer = require( "composer" )
local widget = require("widget")
local mainTabBar = require("mainTabBar")
local getFont = require("setFont")
local json = require("json")
local optionsTable = require("optionsTable")

local scene = composer.newScene()

local ox, oy = math.abs(display.screenOriginX), math.abs(display.screenOriginY)
local cx, cy = display.contentCenterX, display.contentCenterY
local screenW, screenH = display.contentWidth, display.contentHeight
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
local hotSpotSrcollView, hotSpotTabBar
local isReturn = true
local setStatus = {}
local baseDir = system.TemporaryDirectory

local mainTabBarHeight = composer.getVariable("mainTabBarHeight")
local mainTabBarY = composer.getVariable("mainTabBarY")
--mainTabBar.myTabBarHidden()
local ceil = math.ceil
local floor = math.floor

function scene:create( event )
	local sceneGroup = self.view
	local coverGroup = display.newGroup()
	local coverBase = display.newRect( coverGroup, cx, cy, screenW+ox+ox, screenH+oy+oy )
	coverBase:setFillColor( 0, 0, 0, 0.2 )
	coverBase:addEventListener("touch", function () return true; end)
	local coverSpinner = widget.newSpinner({
		id = "coverSpinner",
		x = cx,
		y = cy,
	})
	coverGroup:insert(coverSpinner)
	coverSpinner:scale( 0.6, 0.6 )
	coverSpinner:start()
	if ( composer.getVariable("mainTabBarStatus") and composer.getVariable("mainTabBarStatus") == "hidden" ) then
		mainTabBar.myTabBarScrollShown()
		mainTabBar.setSelectedHotSpot()
		composer.setVariable("mainTabBarStatus", "shown")
	else
		mainTabBar.myTabBarShown()
		mainTabBar.setSelectedHotSpot()
	end
	------------------ TabBar元件 ------------------
	--	TabBar的按鍵監聽事件
		local function onTabLinstener( event )
			local id = event.target.id
			if ( id == "hotDestTabBtn" ) then
				searchTextField.isVisible = false
				allGroup.isVisible = false
				hotSpotGroup.isVisible = true
			end
			if ( id == "allBtn" ) then
				searchTextField.isVisible = true
				hotSpotGroup.isVisible = false
				allGroup.isVisible = true	
			end
			return true
		end	
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
	-- tabBar
		hotSpotTabBar = widget.newTabBar{
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
		sceneGroup:insert(hotSpotTabBar)
		hotSpotTabBar:setSelected(1)
	------------------ 熱門目的地元件 ------------------
	-- hotSpotScrollView
		sceneGroup:insert(hotSpotGroup)
		hotSpotGroup.isVisible = false
		setStatus["mainTabBar"] = "shown" 
		local function scrollviewListener( event )
			local phase = event.phase
			if (phase == "moved") then
				if (event.direction == "up" and setStatus["mainTabBar"] == "shown") then
					mainTabBar.myTabBarScrollHidden()
					setStatus["mainTabBar"] = "hidden"
				end
				if (event.direction == "down" and setStatus["mainTabBar"] == "hidden") then
					mainTabBar.myTabBarScrollShown()
					setStatus["mainTabBar"] = "shown"
				end
			end
			if (event.limitReached) then
				mainTabBar.myTabBarScrollShown()
				setStatus["mainTabBar"] = "shown"
			end
			return true
		end
		hotSpotSrcollView = widget.newScrollView({
			id = "hotSpotSrcollView",
			top = -oy+hotSpotTabBar.contentHeight+floor(15*hRate),
			width = screenW+ox+ox, 
			height = screenH+oy+oy-hotSpotTabBar.contentHeight,
			hidebackground = false,
			isBounceEnabled = false,
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
		local function hotSpotListener( event )
			if ( event.isError) then
				print( "Network Error! "..event.response )
			elseif ( event.phase == "ended" ) then
				coverSpinner:stop()
				coverGroup.isVisible = false
				-- print ("RESPONSE: "..event.response)
				local decodedData = json.decode(event.response)
				local objectNum = #decodedData
			--	for k,v in pairs(decodedData) do
			--		print(k,v)
			--	end
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
						--hotSpotPic[id]:removeEventListener("touch",recommendCreateListener)
						local setPicName
						if ( id % 2 == 0) then 
							setPicName = picture[2]
						else
							setPicName = picture[1]
						end
						local options = {
							time = 200,
							effect = "fade",
							params = {
								titlePicName = setPicName,
								--titleDir = baseDir,
								titleTextContent = hotSpotTitle[id].text
							}
						}
						composer.gotoScene("HS_recommendTitle", options)
					end
					return true
				end
				-- 將圖片放入 hotSpotSrcollView
					local picYPadding = floor(15*hRate)
					local scrollHeight = 0
					for i = 1, objectNum do 
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
							text = decodedData[i]["title"],
							font = getFont.font,
							fontSize = 24
						})
						hotSpotScrollViewGroup:insert(rowTitle)
						hotSpotTitle[i] = rowTitle
						rowTitleNum[i] = hotSpotScrollViewGroup.numChildren
						rowTitle.x = rowPicure.x
						rowTitle.y = rowPicure.y

						if (i == objectNum) then 
							local bottomPadding = display.newRect(rowPicure.x, rowPicure.y+rowPicure.contentHeight*0.5+picYPadding*0.5, hotSpotSrcollView.contentWidth, picYPadding)
							hotSpotScrollViewGroup:insert(bottomPadding)
							scrollHeight = bottomPadding.y+bottomPadding.contentHeight+mainTabBarHeight
						end
					end
					hotSpotSrcollView:setScrollHeight(scrollHeight)
			end
		end
		local headers = {}
		headers["Content-Type"] = "application/json"
		local body = "{\"lang\":\"zh_TW\"}"
		local parms = {}
		parms.headers = headers
		parms.body = body
		local hotSpotUrl = optionsTable.getHotSoptUrl
		network.request( hotSpotUrl, "POST", hotSpotListener, parms)
	------------------ 全部元件 ------------------
		sceneGroup:insert(allGroup)
		allGroup.isVisible = false
	-- 陰影
		local searchShadow = display.newImageRect("assets/shadow0205.png", screenW+ox+ox, floor(178*hRate))
		allGroup:insert(searchShadow)
		searchShadow.x = cx
		searchShadow.y = -oy+hotSpotTabBar.contentHeight+floor(15*hRate)+searchShadow.contentHeight*0.5
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
		local cleanTextBtn = widget.newButton({
			id = "cleanTextBtn",
			x = searchTextField.x+searchTextField.contentWidth, 
			y = searchTextField.y,
			defaultFile="assets/btn-search-delete.png", 
			width = 240*0.08, 
			height = 240*0.08,
			onRelease = function()
				searchTextField.text = ""
				native.setKeyboardFocus(nil)
			end,
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
		hotSpotGroup.isVisible = true
		hotSpotSrcollView:scrollTo( "top", { time = 0 } )
	elseif phase == "did" then
		if ( isReturn == false ) then
			isReturn = true
			hotSpotGroup.isVisible = true
			allGroup.isVisible = false
			hotSpotTabBar:setSelected(1)
		end
	end	
end
 
function scene:hide( event )
	local sceneGroup = self.view
	local phase = event.phase
	if event.phase == "will" then
		searchTextField.isVisible = false
	elseif phase == "did" then
		isReturn = false
		--composer.removeScene("hotSpot")
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

return scene