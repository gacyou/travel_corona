-----------------------------------------------------------------------------------------
--
-- HS_recommendTitle.lua
--
-----------------------------------------------------------------------------------------
local composer = require( "composer" )
local widget = require("widget")
local mainTabBar = require("mainTabBar")
local getFont = require("setFont")
local json = require("json")

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

local titlePic,titleText
local rcmdTextField

local ceil = math.ceil
local floor = math.floor
-- create()
function scene:create( event )
	local sceneGroup = self.view
	mainTabBar.myTabBarHidden()
	--print(event.params.titlePicName)
	local getPicName = event.params.titlePicName
	local textContent = event.params.titleTextContent
	--print(event.params.titleTextContent)
	------------------ 主題推薦頁面元件 ------------------
	-- 主題頁面ScrollVIew
		local rcmdScrollView = widget.newScrollView({
			id = "rcmdScrollView",
			x = cx,
			y = cy,
			width = screenW+ox+ox,
			height = screenH+oy+oy,
			backgroundColor = backgroundColor,
			horizontalScrollDisabled = true,
			isBounceEnabled = false,
		})
		sceneGroup:insert(rcmdScrollView)
		local rcmdScrollViewGroup = display.newGroup()
		rcmdScrollView:insert(rcmdScrollViewGroup)
	-- 主題頁面抬頭圖片
		local picName = event.params.titlePicName
		local rcmdTitlePic = display.newImage(rcmdScrollViewGroup, picName)
		rcmdTitlePic.width = rcmdScrollView.contentWidth
		rcmdTitlePic.height = ceil(565*wRate)
		rcmdTitlePic.x = rcmdScrollView.contentWidth*0.5
		rcmdTitlePic.y = rcmdTitlePic.contentHeight*0.5
	-- 主題頁面搜尋列
		local rcmdShadow = display.newImageRect("assets/shadow0205.png", screenW+ox+ox, floor(200*hRate))
		rcmdScrollViewGroup:insert(rcmdShadow)
		rcmdShadow.x = rcmdTitlePic.x
		rcmdShadow.y = rcmdTitlePic.y+rcmdTitlePic.contentHeight*0.5+rcmdShadow.contentHeight*0.5
		local rcmdSearchIcon = display.newImageRect("assets/btn-search-b.png", 261, 261)
		rcmdScrollViewGroup:insert(rcmdSearchIcon)
		rcmdSearchIcon.anchorX = 0
		rcmdSearchIcon.width = rcmdSearchIcon.width*0.07
		rcmdSearchIcon.height = rcmdSearchIcon.height*0.07
		rcmdSearchIcon.x = ceil(50*wRate)
		rcmdSearchIcon.y = rcmdTitlePic.y+rcmdTitlePic.contentHeight*0.5+(rcmdShadow.contentHeight*0.9)*0.5
		local rcmdSearchBarPic = display.newImageRect("assets/enter-search-b-short.png",(screenW+ox+ox)*0.85, rcmdShadow.contentHeight*0.6)
		rcmdScrollViewGroup:insert(rcmdSearchBarPic)
		rcmdSearchBarPic.anchorX = 0
		rcmdSearchBarPic.x = rcmdSearchIcon.x+rcmdSearchIcon.contentWidth+ceil(32*wRate)
		rcmdSearchBarPic.y = rcmdSearchIcon.y
	-- 搜尋欄位
		rcmdTextField = native.newTextField( 0, rcmdSearchBarPic.y, (screenW+ox+ox)*0.75, rcmdSearchBarPic.contentHeight*0.7)
		rcmdScrollViewGroup:insert(rcmdTextField)
		rcmdTextField.anchorX = 0
		rcmdTextField.x = rcmdSearchBarPic.x+ceil(35*wRate)
		rcmdTextField.hasBackground = false
		rcmdTextField.font = getFont.font
		--rcmdTextField.size = 16
		rcmdTextField:resizeFontToFitHeight()
		rcmdTextField.inputType = "default"
		rcmdTextField.align = "left"
		rcmdTextField:setSelection(0,0)
		rcmdTextField.placeholder = "於此分類搜尋"
		rcmdTextField.isVisible = false
	-- 清除輸入按鈕
		local rcmdCleanTextBtn = widget.newButton({
				id = "rcmdCleanTextBtn",
				x = rcmdTextField.x+rcmdTextField.contentWidth, 
				y = rcmdTextField.y,
				defaultFile="assets/btn-search-delete.png", 
				width = 240*0.08, 
				height = 240*0.08,
			})
		rcmdScrollViewGroup:insert(rcmdCleanTextBtn)
		rcmdCleanTextBtn.anchorX = 0
		rcmdCleanTextBtn.isVisible = false
	-- rcmdTextField 的 userInput監聽事件
		local function rcmdTextFieldListener( event )
			local phase = event.phase
			if ( phase == "editing" and event.text ~= "" ) then
				rcmdCleanTextBtn.isVisible = true
			else
				rcmdCleanTextBtn.isVisible = false
			end
			if ( phase == "ended" or phase == "submitted") then 
				event.target.text = ""
				rcmdCleanTextBtn.isVisible = false
				native.setKeyboardFocus( nil )
			end
		end
		rcmdTextField:addEventListener("userInput", rcmdTextFieldListener)
	-- rcmdCleanTextBtn的按鍵監聽事件
		local function rcmdCleanTextBtnLinstener( event )
			if (event.phase == "ended") then
				rcmdTextField.text = ""
			end
			return true
		end
		rcmdCleanTextBtn:addEventListener("touch", rcmdCleanTextBtnLinstener)
	-- 顯示文字-主題名稱
		local rcmdTitleText = display.newText({
			parent = rcmdScrollViewGroup,
			text = textContent,
			font = getFont.font,
		})
		rcmdTitleText:setFillColor(unpack(wordColor))
		rcmdTitleText.anchorX = 0
		rcmdTitleText.anchorY = 0
		rcmdTitleText.x = ceil(22*wRate)
		rcmdTitleText.y = rcmdShadow.y+rcmdShadow.contentHeight*0.5+floor(45*hRate)
		rcmdTitleText.size = 14
	-- 顯示文字-查看所有活動
		local rcmdTitleAllText = display.newText({
			text = "查看所有活動",
			font = getFont.font,
			fontSize = 10,
		})
		rcmdScrollViewGroup:insert(rcmdTitleAllText)
		rcmdTitleAllText:setFillColor(unpack(wordColor))
		rcmdTitleAllText.anchorX = 1
		rcmdTitleAllText.anchorY = 1
		rcmdTitleAllText.x = rcmdScrollView.contentWidth-ceil(22*wRate)
		rcmdTitleAllText.y = rcmdTitleText.y+rcmdTitleText.contentHeight
	-- 白色箭頭
		local backArrow = display.newImage( rcmdScrollViewGroup, "assets/btn-back-w.png", ceil(35*wRate), floor(35*hRate))
		backArrow.anchorX = 0
		backArrow.width = (backArrow.width*0.07)
		backArrow.height = (backArrow.height*0.07)
		backArrow.y = backArrow.y+backArrow.contentHeight*0.5
	-- 返回按鈕
		local rcmdBackBtn = widget.newButton({
			id = "backBtn",
			x = backArrow.x+backArrow.contentWidth*0.5,
			y = backArrow.y,
			defaultFile = "assets/transparent.png",
					--shape = "rect",
			width = screenW*0.1,
			height = floor(178*hRate),
			onRelease = 
				function ()
					composer.gotoScene("HS_hotSpot", { time = 200, effect = "fade"} )
					mainTabBar.myTabBarScrollShown()
				end,
			})
		rcmdScrollViewGroup:insert(rcmdBackBtn)
	-- 白色購物車圖片
		local cartWhite = display.newImage( rcmdScrollViewGroup, "assets/btn-cart-w.png", rcmdScrollView.contentWidth-ceil(35*wRate), backArrow.y)
		cartWhite.width = (cartWhite.width*0.07)
		cartWhite.height = (cartWhite.height*0.07)
		cartWhite.anchorX = 1
	-- 購物車
		local rcmdCartBtn = widget.newButton({
			id = "cartBtn",
			x = cartWhite.x-cartWhite.contentWidth*0.5,
			y = cartWhite.y,
			defaultFile = "assets/transparent.png",
			--shape = "rect",
			width = screenW*0.1,
			height = rcmdBackBtn.contentHeight,
			onRelease = 
			function ()
				composer.gotoScene("shoppingCart", { time = 200, effect = "fade" } )
			end,
		})
		rcmdScrollViewGroup:insert(rcmdCartBtn)
	-- 主題頁面八個選項	--
	-- 參數
		local optionList = { "主題推薦", "獨家主題", "一般出團", "當地集散", "自助包車", "藝品餐券", "其他服務", "住宿訂房"}
		local iconBaseWidth = (screenW+ox+ox)/4
		local iconBaseHeight = iconBaseWidth
		local iconBaseX = iconBaseWidth*0.5
		local iconBaseY = rcmdTitleAllText.y+floor(45*hRate)+iconBaseHeight*0.5
	-- 選項監聽事件
		local icon = {}
		local iconOver = {}
		local iconText = {}
		local isCancel = false
		
		local function optionSelect( event )
			local phase = event.phase
			local id = event.target.id
			if (phase == "began") then
				if (isCancel == true) then
					isCancel = false
				end
				if (id > 1) then
					icon[1].isVisible = true
					icon[id].isVisible = false
					iconText[1]:setFillColor(unpack(wordColor))
					iconText[id]:setFillColor(unpack(subColor2))
				end
			elseif (phase == "moved") then
				if (id > 1) then
					icon[1].isVisible = false
					icon[id].isVisible = true
					iconText[1]:setFillColor(unpack(subColor2))
					iconText[id]:setFillColor(unpack(wordColor))
					isCancel = true
				end
				local dy = math.abs(event.yStart-event.y)
				if (dy > 10) then 
					rcmdScrollView:takeFocus(event)
					isCancel = true
				end
			elseif (phase == "ended") then
				if (id > 1 and isCancel == false ) then
					icon[1].isVisible = false
					icon[id].isVisible = true
					iconText[1]:setFillColor(unpack(subColor2))
					iconText[id]:setFillColor(unpack(wordColor))
					local options = {
						time = 200,
						effect = "fade",
						params = {
							otherTitleTextContent = iconText[id].text,
							titlePicName = picName,
							titleTextContent = textContent,
						}
					}
					composer.gotoScene("HS_otherTitle",options)
				end
			end
			return true
		end
	-- 選項位置
		local xBasement
		for i = 1, #optionList do
			xBasement = (i-1)%(ceil(#optionList*0.5))
			local iconBase = display.newRect( rcmdScrollViewGroup, iconBaseX, iconBaseY, iconBaseWidth, iconBaseHeight)
			iconBase.x = iconBase.x+iconBase.contentWidth*xBasement
			if (i <= #optionList*0.5) then
				iconBase.y = iconBaseY
			else
				iconBase.y = iconBaseY+iconBase.contentHeight
			end
			iconBase.id = i
			iconBase:addEventListener("touch",optionSelect)
			
			iconOver[i] = display.newImageRect("assets/theme0"..i.."-.png", 104, 85)
			rcmdScrollViewGroup:insert(iconOver[i])
			iconOver[i].anchorY = 1
			iconOver[i].width = iconOver[i].width*wRate
			iconOver[i].height = iconOver[i].height*wRate
			iconOver[i].x = iconBase.x
			if (i <= #optionList*0.5) then
				iconOver[i].y = iconBaseY
			else
				iconOver[i].y = iconBaseY+iconBaseHeight
			end

			icon[i] = display.newImageRect("assets/theme0"..i..".png", 104, 85)
			rcmdScrollViewGroup:insert(icon[i])
			icon[i].anchorY = 1
			icon[i].width = icon[i].width*wRate
			icon[i].height = icon[i].height*wRate
			icon[i].x = iconBase.x
			if (i <= #optionList*0.5) then
				icon[i].y = iconBaseY
			else
				icon[i].y = iconBaseY+iconBaseHeight
			end
	    	
	    	iconText[i] = display.newText({
	   			text = optionList[i],
	   			font = getFont.font,
	   			fontSize = 12,
	   		})
	   		rcmdScrollViewGroup:insert(iconText[i])
	   		if (i == 1) then 
	   			icon[i].isVisible = false
	   			iconText[i]:setFillColor(unpack(subColor2))
	   		else
	   			icon[i].isVisible = true
	   			iconText[i]:setFillColor(unpack(wordColor))
	   		end
	   		iconText[i].anchorY = 0
	   		iconText[i].x = icon[i].x
	   		iconText[i].y = icon[i].y+floor(32*hRate)
	   	end
	-- 分隔線
	
		local optionLine = {}
		-- 上橫線
			optionLine[1] = display.newLine( 0, iconBaseY-iconBaseHeight*0.5, screenW+ox+ox, iconBaseY-iconBaseHeight*0.5 )
			rcmdScrollViewGroup:insert(optionLine[1])
			optionLine[1]:setStrokeColor(unpack(separateLineColor))
			optionLine[1].strokeWidth = 1
		-- 中橫線
			optionLine[2] = display.newLine( 0, optionLine[1].y+iconBaseHeight, screenW+ox+ox, optionLine[1].y+iconBaseHeight )
			rcmdScrollViewGroup:insert(optionLine[2])
			optionLine[2]:setStrokeColor(unpack(separateLineColor))
			optionLine[2].strokeWidth = 1
		-- 下橫線
			optionLine[3] = display.newLine( 0, optionLine[2].y+iconBaseHeight, screenW+ox+ox, optionLine[2].y+iconBaseHeight )
			rcmdScrollViewGroup:insert(optionLine[3])
			optionLine[3]:setStrokeColor(unpack(separateLineColor))
			optionLine[3].strokeWidth = 1
		-- 左直線
			optionLine[4] = display.newLine( iconBaseWidth, optionLine[1].y, iconBaseWidth, optionLine[3].y )
			rcmdScrollViewGroup:insert(optionLine[4])
			optionLine[4]:setStrokeColor(unpack(separateLineColor))
			optionLine[4].strokeWidth = 1
	   	-- 中直線
			optionLine[5] = display.newLine( iconBaseWidth*2, optionLine[1].y, iconBaseWidth*2, optionLine[3].y )
			rcmdScrollViewGroup:insert(optionLine[5])
			optionLine[5]:setStrokeColor(unpack(separateLineColor))
			optionLine[5].strokeWidth = 1
		-- 右直線
			optionLine[6] = display.newLine( iconBaseWidth*3, optionLine[1].y, iconBaseWidth*3, optionLine[3].y )
			rcmdScrollViewGroup:insert(optionLine[6])
			optionLine[6]:setStrokeColor(unpack(separateLineColor))
			optionLine[6].strokeWidth = 1
	
	-- 商品ScrollView1
		local goodScrollView = {}
		local goodPicBase = {}
		local goodPicMask = {}
		local function scrollVertical( event )
			local phase = event.phase
			if (phase == "moved") then
				local dy = math.abs(event.yStart-event.y)
				if ( dy > 20) then
					rcmdScrollView:takeFocus(event)
				end
			end
			return true
		end
		goodScrollView[1] = widget.newScrollView({
			id = "goodScrollView1",
			x = 0,
			y = optionLine[3].y+floor(100*hRate),
			width = rcmdScrollView.contentWidth,
			height = floor(664*hRate),
			verticalScrollDisabled = true,
			backgroundColor = backgroundColor,
			listener = scrollVertical,
		})
		rcmdScrollViewGroup:insert(goodScrollView[1])
		goodScrollView[1].anchorX = 0
		goodScrollView[1].anchorY = 0
		local group1 = display.newGroup()
		goodScrollView[1]:insert(group1)
	-- ScrollView1元件
		goodPicBase[1] = display.newRect( group1, 0, 0, ceil(998*wRate), goodScrollView[1].contentHeight)
		goodPicBase[1].x = goodScrollView[1].x + goodPicBase[1].contentWidth*0.5
		goodPicBase[1].y = goodPicBase[1].contentHeight*0.5
		
		goodPicMask[1] = display.newImage(group1,"assets/colormask-y.png", 0, goodPicBase[1].y)
		goodPicMask[1].width = ceil(815*wRate)
		goodPicMask[1].height = goodPicBase[1].contentHeight
		goodPicMask[1].x = goodScrollView[1].x + goodPicMask[1].contentWidth*0.5

	-- 商品ScrollView2
		goodScrollView[2] = widget.newScrollView({
			id = "goodScrollView2",
			x = 0,
			y = goodScrollView[1].y+goodScrollView[1].contentHeight+floor(100*hRate),
			width = rcmdScrollView.contentWidth,
			height = floor(664*wRate),
			verticalScrollDisabled = true,
			backgroundColor = backgroundColor,
			listener = scrollVertical,
		})
		rcmdScrollViewGroup:insert(goodScrollView[2])
		goodScrollView[2].anchorX = 0
		goodScrollView[2].anchorY = 0
		local group2 = display.newGroup()
		goodScrollView[2]:insert(group2)
	-- ScrollView2元件
		goodPicBase[2] = display.newRect(group2, 0, 0, ceil(998*wRate), goodScrollView[2].contentHeight)
		goodPicBase[2].x = goodScrollView[2].x + goodPicBase[2].contentWidth*0.5
		goodPicBase[2].y = goodPicBase[2].contentHeight*0.5
			
		goodPicMask[2] = display.newImage(group2,"assets/colormask-o.png", 0, goodPicBase[2].y)
		goodPicMask[2].width = ceil(815*wRate)
		goodPicMask[2].height = goodPicBase[2].contentHeight
		goodPicMask[2].x = goodScrollView[2].x + goodPicMask[2].contentWidth*0.5

	-- 商品ScrollView3
		goodScrollView[3] = widget.newScrollView({
			id = "goodScrollView3",
			x = 0,
			y = goodScrollView[2].y+goodScrollView[2].contentHeight+floor(100*hRate),
			width = rcmdScrollView.contentWidth,
			height = floor(664*wRate),
			verticalScrollDisabled = true,
			backgroundColor = backgroundColor,
			listener = scrollVertical,
		})
		rcmdScrollViewGroup:insert(goodScrollView[3])
		goodScrollView[3].anchorX = 0
		goodScrollView[3].anchorY = 0
		local group3 = display.newGroup()
		goodScrollView[3]:insert(group3)
	-- ScrollView3元件
		goodPicBase[3] = display.newRect(group3, 0, 0, ceil(998*wRate), goodScrollView[3].contentHeight)
		goodPicBase[3].x = goodScrollView[3].x + goodPicBase[3].contentWidth*0.5
		goodPicBase[3].y = goodPicBase[3].contentHeight*0.5
			
		goodPicMask[3] = display.newImage(group3,"assets/colormask-b.png", 0, goodPicBase[3].y)
		goodPicMask[3].width = ceil(815*wRate)
		goodPicMask[3].height = goodPicBase[3].contentHeight
		goodPicMask[3].x = goodScrollView[3].x + goodPicMask[3].contentWidth*0.5
end

-- show()
function scene:show( event )
	local sceneGroup = self.view
	local phase = event.phase
	if ( phase == "will" ) then
	elseif ( phase == "did" ) then
		rcmdTextField.isVisible = true
	end
end

-- hide()
function scene:hide( event )
	local sceneGroup = self.view
	local phase = event.phase
	if ( phase == "will" ) then
		rcmdTextField.isVisible = false
	elseif ( phase == "did" ) then
		composer.removeScene("HS_recommendTitle")
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