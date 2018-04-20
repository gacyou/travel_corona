-----------------------------------------------------------------------------------------
--
-- PC_orderList.lua
-- 
-----------------------------------------------------------------------------------------

local composer = require( "composer" )
local widget = require("widget")
local getFont = require("setFont")
local mainTabBar = require("mainTabBar")
local scene = composer.newScene()

local wordColor = { 99/255, 99/255, 99/255 }
local backgroundColor = { 245/255, 245/255, 245/255 }
local mainColor1 = { 6/255, 184/255, 217/255 }
local mainColor2 = { 7/255, 162/255, 192/255 }
local subColor1 = { 246/255, 148/255, 106/255}
local subColor2 = { 250/255, 128/255, 79/255}
local separateLineColor = { 204/255, 204/255, 204/255 }
local embellishColor = { 249/255, 220/255, 119/255}
local hintAlertColor = { 247/255, 86/255, 86/255}

local ox, oy = math.abs(display.screenOriginX), math.abs(display.screenOriginY)
local cx, cy = display.contentCenterX, display.contentCenterY
local screenW, screenH = display.contentWidth, display.contentHeight
local wRate = screenW/1080
local hRate = screenH/1920

local unpaidOrderGroup,historyOrderGroup

local orderNum = "00000000"
local constructDate = "2017/12/15 23:59"
local scheduledDate = "2017/12/31"
local timeLimitDate = "2017/12/29 23:59"
local picSet = {"assets/Angkor.png" ,"assets/temple.jpg", "assets/night.jpg"}
local statusSet = { "paid", "paid", "overtime", "paid"}

local prevScene = composer.getSceneName("previous")

local mainTabBarHeight = composer.getVariable("mainTabBarHeight")

local hasOrder = true
local isLogin
if (composer.getVariable("isLogin")) then 
	isLogin = composer.getVariable("isLogin")
else
	isLogin = false
end

local ceil = math.ceil
local floor = math.floor

function scene:create( event )
	local sceneGroup = self.view
	mainTabBar.myTabBarHidden()
	-- 按鈕的監聽事件
	local function onBtnListener( event )
		local targetId = event.target.id
		if( targetId == "backBtn") then 
			composer.gotoScene( prevScene,{ effect = "fade", time = 300 })
		end
		if( targetId == "infoBtn") then 
			
		end
		if (targetId == "orderDetailBtn") then 
			composer.gotoScene("orderdetail")
		end
	end

	local function onTabListener( event )
		local targetId = event.target.id
		if( targetId == "unpaidOrderBtn") then
			historyOrderGroup.isVisible = false
			unpaidOrderGroup.isVisible = true
		end
		if( targetId == "historyOrderBtn") then
			unpaidOrderGroup.isVisible = false
			historyOrderGroup.isVisible = true
		end
	end
	------------------- 抬頭元件 -------------------
	-- 白底
		local titleBase = display.newRect( cx, 0, screenW+ox+ox, floor(178*hRate))
		sceneGroup:insert(titleBase)
		titleBase.y = -oy+(titleBase.contentHeight)*0.5
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
	-- 顯示文字-"我的訂單"
		local titleText = display.newText({
			parent = sceneGroup,
			text = "我的訂單",
			font = getFont.font,
			fontSize = 14,
			x = backArrow.x+backArrow.contentWidth+ceil(30*wRate),
			y = backArrow.y,
		})
		titleText:setFillColor(unpack(wordColor))
		titleText.anchorX = 0
	-- 說明按鈕
		local infoBtn = widget.newButton({
			id = "infoBtn",
			x = ceil(cx*1.85)+ox,
			y = -oy+ceil(cy*0.1),
			width = 240,
			height = 240,
			defaultFile = "assets/btn-informationicon.png",
			overFile = "assets/btn-informationicon.png",
			onRelease = function()
				composer.showOverlay( "PC_orderStatusDirection", { isModal = true, effect = "zoomOutIn", time = 300 } )
			end,
		})
		sceneGroup:insert(infoBtn)
		infoBtn.width = ceil(infoBtn.width*0.08)
		infoBtn.height = ceil(infoBtn.height*0.08)
	------------------- 訂單TabBar元件 -------------------
	-- 訂單訊息相關的TabBar
		local orderTabBtns = {
			{
				id = "unpaidOrderBtn",
				label = "未付款訂單",
				labelColor = { default = wordColor, over = mainColor1 },
				font = getFont.font,
				size = 12,
				labelYOffset=-8,
				defaultFile="assets/btn-space-.png", 
				overFile="assets/btn-bottomborder-.png",
				width = screenW/2+ox, 
				height = ceil(screenH*0.0625), 
				selected = true,
				onPress = onTabListener
			},
			{
				id = "historyOrderBtn",
				label = "歷史訂單",
				labelColor = { default = wordColor, over = mainColor1 },
				font = getFont.font,
				size = 12,
				labelYOffset=-8,
				defaultFile="assets/btn-space-.png", 
				overFile="assets/btn-bottomborder-.png",
				width = screenW/2+ox, 
				height = ceil(screenH*0.0625),
				selected = false,
				onPress = onTabListener,
			}
		}
		local orderTabBar = widget.newTabBar{
			top = -oy+titleBase.height,
			left = -ox,
			width = screenW+ox+ox, 
			height = screenH*0.0625,
			backgroundFile = "assets/white.png",
			tabSelectedLeftFile = "assets/Left.png",
			tabSelectedMiddleFile = "assets/Middle.png",
			tabSelectedRightFile = "assets/Right.png",
			tabSelectedFrameWidth = 20,
			tabSelectedFrameHeight = 52, 
			buttons = orderTabBtns,
		}
		sceneGroup:insert(orderTabBar)
	-- 抬頭-TabBar分隔線	
		local grayLine = display.newLine(-ox,-oy+floor(178*hRate),screenW+ox,-oy+floor(178*hRate))
		sceneGroup:insert(grayLine)
		grayLine:setStrokeColor(unpack(separateLineColor))
		grayLine.strokeWidth = 1
	------------------- TabBar頁面元件 -------------------
	-- 未付款訂單 --
		unpaidOrderGroup = display.newGroup()
		sceneGroup:insert(unpaidOrderGroup)
		if ( isLogin == false ) then
			local funroadBird = display.newImage( sceneGroup, "assets/img-bird.png" , cx, cy)
			funroadBird.anchorY = 1
			funroadBird.width = funroadBird.width*0.35
			funroadBird.height = funroadBird.height*0.35
			local text1 = display.newText({
					parent = unpaidOrderGroup,
					text = "尚無訂單，",
					font = getFont.font,
					fontSize = 14,
					x = cx,
					y = funroadBird.y+floor(70*hRate),
				})
			text1:setFillColor(unpack(wordColor))
			text1.anchorX = 1
			text1.anchorY = 0
			local text2 = display.newText({
					parent = unpaidOrderGroup,
					text = "去逛逛",
					font = getFont.font,
					fontSize = 14,
					x = cx,
					y = text1.y,
				})
			text2:setFillColor(unpack(mainColor1))
			text2.anchorX = 0
			text2.anchorY = 0
			local text3 = display.newText({
					parent = unpaidOrderGroup,
					text = "吧!",
					font = getFont.font,
					fontSize = 14,
					x = text2.x+text2.contentWidth,
					y = text2.y,			
				})
			text3:setFillColor(unpack(wordColor))
			text3.anchorX = 0
			text3.anchorY = 0
		else
			-- 未付款訂單ScorllView	
				local unpaidOrderView = widget.newScrollView({
					id = "unpaidOrderView",
					top = -oy+titleBase.contentHeight+orderTabBar.contentHeight+floor(30*hRate),
					left = -ox+ceil(22*wRate),
					width = (screenW-ceil(22*wRate)*2)+ox+ox, 
					height = screenH+oy+oy-(orderTabBar.y+orderTabBar.contentHeight+floor(30*hRate)),
					backgroundColor = backgroundColor,
				})
				unpaidOrderGroup:insert(unpaidOrderView)
			-- 頁面元件
				local pad
				local picNum
				for i=1,4 do
					
					if ( i%3 == 0) then 
						picNum = 3
					elseif ( i%3 == 2) then
						picNum = 2
					else
						picNum = 1
					end

					if( i == 1) then
						pad = 0
					else
						pad = ceil(420*hRate)*(i-1)
					end
					-- unpaidOrder ScrollView 陰影
					local unpaidOrderBaseShadow = display.newImageRect("assets/shadow.png",1068,476)
					unpaidOrderView:insert(unpaidOrderBaseShadow)
					unpaidOrderBaseShadow.width = (screenW-ceil(22*wRate)*2)+ox+ox
					unpaidOrderBaseShadow.height = ceil(420*hRate)
					unpaidOrderBaseShadow.x = unpaidOrderBaseShadow.width/2
					unpaidOrderBaseShadow.y = unpaidOrderBaseShadow.height/2+pad
					local unpdBaseShadowWidth = unpaidOrderBaseShadow.width    --306
					local unpdBaseShadowHeight = unpaidOrderBaseShadow.height  --120
					
					-- unpaidOrder ScrollView 圖文基底
					local unpaidOrderBase = display.newRect( 0, 0, unpaidOrderBaseShadow.width*0.965, unpaidOrderBaseShadow.height*0.925)
					unpaidOrderView:insert(unpaidOrderBase)
					unpaidOrderBase:setFillColor(1)
					unpaidOrderBase.x = unpaidOrderBaseShadow.x
					unpaidOrderBase.y = unpaidOrderBaseShadow.y
					
					-- unpaidOrder ScrollView 圖
					local unpaidOrderPic = display.newRoundedRect(0,0,ceil(340*wRate),ceil(240*hRate),2)
					unpaidOrderView:insert(unpaidOrderPic)
					unpaidOrderPic:setFillColor(unpack(separateLineColor))
					unpaidOrderPic.x = ceil(30*wRate)+ceil(unpaidOrderPic.width/2)
					unpaidOrderPic.y = ceil(30*hRate)+ceil(unpaidOrderPic.height/2)+pad
					unpaidOrderPic.fill = { type = "image", filename = picSet[picNum] }

					-- unpaidOrder ScrollView 長橫線
					local horizontalLine1 = display.newLine( ceil(unpaidOrderBase.width*0.03), unpaidOrderPic.y+ceil(unpaidOrderPic.height/2)+ceil(30*hRate),
						ceil(unpaidOrderBase.width*0.997), unpaidOrderPic.y+ceil(unpaidOrderPic.height/2)+ceil(30*hRate))
					unpaidOrderView:insert( horizontalLine1)
				 	horizontalLine1:setStrokeColor(unpack(separateLineColor))

					-- unpaidOrder ScrollView 訂單編號
					local orderNumText = display.newText({
						text = "訂單編號："..tostring(orderNum),
						font = getFont.font,
						fontSize = 10,
					})
					unpaidOrderView:insert(orderNumText)
					orderNumText:setFillColor(unpack(wordColor))
					orderNumText.anchorX = 0
					orderNumText.x = unpaidOrderPic.x+ceil(unpaidOrderPic.width/2)+ceil(22*wRate)
					orderNumText.y = ceil(30*hRate)+ceil(orderNumText.height/2)+pad

					-- unpaidOrder ScrollView 建立日期
					local constructDateText = display.newText({
						text = "建立日期："..constructDate,
						font = getFont.font,
						fontSize = 10,
					})
					unpaidOrderView:insert(constructDateText)
					constructDateText:setFillColor(unpack(wordColor))
					constructDateText.anchorX = 0
					constructDateText.x = orderNumText.x
					constructDateText.y = orderNumText.y+ceil(orderNumText.height/2)+ceil(15*hRate)+ceil(constructDateText.height/2)	

					-- unpaidOrder ScrollView 預定日期
					local scheduledDateText = display.newText({
						text = "預定日期："..scheduledDate,
						font = getFont.font,
						fontSize = 10,
					})
					unpaidOrderView:insert(scheduledDateText)
					scheduledDateText:setFillColor(unpack(wordColor))
					scheduledDateText.anchorX = 0
					scheduledDateText.x = orderNumText.x
					scheduledDateText.y = constructDateText.y+ceil(constructDateText.height/2)+ceil(15*hRate)+ceil(scheduledDateText.height/2)

					-- unpaidOrder ScrollView 付款時限
					local timeLimitDateText = display.newText({
						text = "付款時限："..timeLimitDate,
						font = getFont.font,
						fontSize = 10,
					})
					unpaidOrderView:insert(timeLimitDateText)
					timeLimitDateText:setFillColor(unpack(wordColor))
					timeLimitDateText.anchorX = 0
					timeLimitDateText.x = orderNumText.x
					timeLimitDateText.y = scheduledDateText.y+ceil(scheduledDateText.height/2)+ceil(15*hRate)+ceil(timeLimitDateText.height/2)

					-- unpaidOrder ScrollView 未付款
					local statusText = display.newText({
						text = "未付款",
						font = getFont.font,
						fontSize = 12,
					})
					unpaidOrderView:insert(statusText)
					statusText:setFillColor(unpack(subColor1))
					statusText.anchorX = 1
					statusText.x = unpaidOrderBase.width
					statusText.y = ceil(30*hRate)+ceil(statusText.height/2)+pad

					-- unpaidOrder ScrollView 去付款按鈕
					local text1 = display.newText({
							text = "去付款",
							font = getFont.font,
							fontSize = 12,
						})
					unpaidOrderView:insert(text1)
					text1.isVisible = false
					local goToPayBtn = widget.newButton(
					{
						id = "goToPayBtn",
						label = "去付款",
						labelColor = { default = wordColor, over = mainColor1},
						font = getFont.font,
						fontSize = 12,
						width = text1.width,
						height = text1.height,
						shape = "rect",
						--fillColor = { default = subColor1, over = subColor2}
					}) 
					unpaidOrderView:insert(goToPayBtn)
					goToPayBtn.anchorX = 0
					goToPayBtn.x = ceil(35*wRate)
					goToPayBtn.y = horizontalLine1.y+ceil(30*hRate)+ceil(text1.height/2)

					-- 按鍵之間的垂直線1
					local verticalLine1 = display.newLine( goToPayBtn.x+goToPayBtn.width+ceil(25*wRate), goToPayBtn.y-ceil(goToPayBtn.height/2),
						goToPayBtn.x+goToPayBtn.width+ceil(25*wRate), goToPayBtn.y+ceil(goToPayBtn.height/2))
					unpaidOrderView:insert(verticalLine1)
					verticalLine1:setStrokeColor(unpack(separateLineColor))
					
					-- unpaidOrder ScrollView 訂單明細按鈕
					local text2 = display.newText({
							text = "訂單明細",
							font = getFont.font,
							fontSize = 12,
						})
					unpaidOrderView:insert(text2)
					text2.isVisible = false		
					local orderDetailBtn = widget.newButton(
					{
						id = "orderDetailBtn",
						label = "訂單明細",
						labelColor = { default = wordColor, over = mainColor1},
						font = getFont.font,
						fontSize = 12,
						width = text2.width,
						height = text2.height,
						shape = "rect",
						onPress = onBtnListener,
					}) 
					unpaidOrderView:insert(orderDetailBtn)
					orderDetailBtn.anchorX = 0
					orderDetailBtn.x = verticalLine1.x+ceil(25*wRate)
					orderDetailBtn.y = horizontalLine1.y+ceil(30*hRate)+ceil(text2.height/2)

					local verticalLine2 = display.newLine( orderDetailBtn.x+orderDetailBtn.width+ceil(25*wRate), orderDetailBtn.y-ceil(orderDetailBtn.height/2),
						orderDetailBtn.x+orderDetailBtn.width+ceil(25*wRate), orderDetailBtn.y+ceil(orderDetailBtn.height/2))
					unpaidOrderView:insert(verticalLine2)
					verticalLine2:setStrokeColor(unpack(separateLineColor))

					-- unpaidOrder ScrollView 聯絡客服按鈕
					local text3 = display.newText({
							text = "聯絡客服",
							font = getFont.font,
							fontSize = 12,
						})
					unpaidOrderView:insert(text3)
					text3.isVisible = false		
					local contactSrvBtn = widget.newButton({
						id = "contactSrvBtn",
						label = "聯絡客服",
						labelColor = { default = wordColor, over = mainColor1},
						font = getFont.font,
						fontSize = 12,
						width = text3.width,
						height = text3.height,
						shape = "rect",
						--fillColor = { default = subColor1, over = subColor2}
					}) 
					unpaidOrderView:insert(contactSrvBtn)
					contactSrvBtn.anchorX = 0
					contactSrvBtn.x =  verticalLine2.x+ceil(25*wRate)
					contactSrvBtn.y =  horizontalLine1.y+ceil(30*hRate)+ceil(text3.height/2)

					-- unpaidOrder ScrollView 商品價位
					local unPaidPriceText = display.newText({
						text = "NT$15,000",
						font = getFont.font,
						fontSize = 12,
					})
					unpaidOrderView:insert(unPaidPriceText)
					unPaidPriceText:setFillColor(unpack(wordColor))
					unPaidPriceText.anchorX = 1
					unPaidPriceText.x = unpaidOrderBase.width-ceil(30*wRate)
					unPaidPriceText.y = horizontalLine1.y+ceil(30*hRate)+ceil(unPaidPriceText.height/2)
				end
		end
	-- 歷史訂單 --
		historyOrderGroup = display.newGroup()
		sceneGroup:insert(historyOrderGroup)
		historyOrderGroup.isVisible = false
		if ( isLogin == false ) then 
			local funroadBird = display.newImage( sceneGroup, "assets/img-bird.png" , cx, cy)
			funroadBird.anchorY = 1
			funroadBird.width = funroadBird.width*0.35
			funroadBird.height = funroadBird.height*0.35
			local text1 = display.newText({
					parent = historyOrderGroup,
					text = "尚無訂單，",
					font = getFont.font,
					fontSize = 14,
					x = cx,
					y = funroadBird.y+floor(70*hRate),
				})
			text1:setFillColor(unpack(wordColor))
			text1.anchorX = 1
			text1.anchorY = 0
			local text2 = display.newText({
					parent = historyOrderGroup,
					text = "去逛逛",
					font = getFont.font,
					fontSize = 14,
					x = cx,
					y = text1.y,
				})
			text2:setFillColor(unpack(mainColor1))
			text2.anchorX = 0
			text2.anchorY = 0
			local text3 = display.newText({
					parent = historyOrderGroup,
					text = "吧!",
					font = getFont.font,
					fontSize = 14,
					x = text2.x+text2.contentWidth,
					y = text2.y,			
				})
			text3:setFillColor(unpack(wordColor))
			text3.anchorX = 0
			text3.anchorY = 0
		else
			local historyOrderView = widget.newScrollView(
			{
				id = "historyOrderView",
				top = -oy+titleBase.height+orderTabBar.height+ceil(30*hRate),
				left = -ox+ceil(22*wRate),
				width = (screenW-ceil(22*wRate)*2)+ox+ox, 
				height = screenH-mainTabBarHeight-titleBase.height-orderTabBar.height+oy+oy,
				horizontalScrollDisabled = true,
				backgroundColor = backgroundColor,
			})
			historyOrderGroup:insert(historyOrderView)

			local pad
			local picNum
			for i=1,4 do
				if ( i%3 == 0) then 
					picNum = 3
				elseif ( i%3 == 2) then
					picNum = 2
				else
					picNum = 1
				end

				if( i == 1) then
					pad = 0
				else
					pad = ceil(420*hRate)*(i-1)
				end

				-- historyOrder ScrollView 陰影
				local hisOrderBaseShadow = display.newImageRect("assets/shadow.png",1068,476)
				historyOrderView:insert(hisOrderBaseShadow)
				hisOrderBaseShadow.width = (screenW-ceil(22*wRate)*2)+ox+ox
				hisOrderBaseShadow.height = ceil(420*hRate)
				hisOrderBaseShadow.x = ceil(hisOrderBaseShadow.width/2)
				hisOrderBaseShadow.y = ceil(hisOrderBaseShadow.height/2)+pad

				-- historyOrder ScrollView 圖文基底
				local hisOrderBase = display.newRect(0,0,hisOrderBaseShadow.width*0.965,hisOrderBaseShadow.height*0.925)
				historyOrderView:insert(hisOrderBase)
				hisOrderBase:setFillColor(1)
				hisOrderBase.x = hisOrderBaseShadow.x
				hisOrderBase.y = hisOrderBaseShadow.y

				-- historyOrder ScrollView 圖
				local hisOrderPic = display.newRoundedRect(0,0,ceil(340*wRate),ceil(240*hRate),2)
				historyOrderView:insert(hisOrderPic)
				hisOrderPic:setFillColor(unpack(separateLineColor))
				hisOrderPic.x = ceil(30*wRate)+ceil(hisOrderPic.width/2)
				hisOrderPic.y = ceil(30*hRate)+ceil(hisOrderPic.height/2)+pad
				hisOrderPic.fill = { type = "image", filename = picSet[picNum] }

				-- historyOrder ScrollView 灰色長橫線
				local hisHorizontalLine = display.newLine ( ceil(hisOrderBase.width*0.03), hisOrderPic.y+ceil(hisOrderPic.height/2)+ceil(30*hRate), 
					ceil(hisOrderBase.width*0.997), hisOrderPic.y+ceil(hisOrderPic.height/2)+ceil(30*hRate))
				historyOrderView:insert(hisHorizontalLine)
				hisHorizontalLine:setStrokeColor(unpack(separateLineColor))

				-- hisOrder ScrollView 訂單編號
				local orderNumText = display.newText({
					text = "訂單編號："..tostring(orderNum),
					font = getFont.font,
					fontSize = 10,
				})
				historyOrderView:insert(orderNumText)
				orderNumText:setFillColor(unpack(wordColor))
				orderNumText.anchorX = 0
				orderNumText.x = hisOrderPic.x+ceil(hisOrderPic.width/2)+ceil(22*wRate)
				orderNumText.y = ceil(30*hRate)+ceil(orderNumText.height/2)+pad

				-- hisOrder ScrollView 建立日期
				local constructDateText = display.newText({
					text = "建立日期："..constructDate,
					font = getFont.font,
					fontSize = 10,
				})
				historyOrderView:insert(constructDateText)
				constructDateText:setFillColor(unpack(wordColor))
				constructDateText.anchorX = 0
				constructDateText.x = orderNumText.x
				constructDateText.y = orderNumText.y+ceil(orderNumText.height/2)+ceil(15*hRate)+ceil(constructDateText.height/2)
				
				-- hisOrder ScrollView 預定日期
				local scheduledDateText = display.newText({
					text = "預定日期："..scheduledDate,
					font = getFont.font,
					fontSize = 10,
				})
				historyOrderView:insert(scheduledDateText)
				scheduledDateText:setFillColor(unpack(wordColor))
				scheduledDateText.anchorX = 0
				scheduledDateText.x = orderNumText.x
				scheduledDateText.y = constructDateText.y+ceil(constructDateText.height/2)+ceil(15*hRate)+ceil(scheduledDateText.height/2)
				
				-- hisOrder ScrollView 付款時限
				local timeLimitDateText = display.newText({
					text = "付款時限："..timeLimitDate,
					font = getFont.font,
					fontSize = 10,
				})
				historyOrderView:insert(timeLimitDateText)
				timeLimitDateText:setFillColor(unpack(wordColor))
				timeLimitDateText.anchorX = 0
				timeLimitDateText.x = orderNumText.x
				timeLimitDateText.y = scheduledDateText.y+ceil(scheduledDateText.height/2)+ceil(15*hRate)+ceil(timeLimitDateText.height/2)
				-- historyOrder ScrollView 付款狀態 { 已付款，逾時 }
				-- 利用狀態來判定之後要顯示的按鈕
				if ( statusSet[i] == "paid") then 
					-- 已付款顯示處理
					local statusText = display.newText({
						text = "已付款",
						font = getFont.font,
						fontSize = 12,
					})
					historyOrderView:insert(statusText)
					statusText:setFillColor(unpack(mainColor1))
					statusText.anchorX = 1
					statusText.x = hisOrderBase.width
					statusText.y = ceil(30*hRate)+ceil(statusText.height/2)+pad

					local text1 = display.newText({
						text = "訂單明細",
						font = getFont.font,
						fontSize = 12,
					})
					historyOrderView:insert(text1)
					text1.isVisible = false
					local orderDetailBtn = widget.newButton(
					{
						id = "orderDetailBtn",
						label = "訂單明細",
						labelColor = { default = wordColor, over = mainColor1},
						font = getFont.font,
						fontSize = 12,
						width = text1.width,
						height = text1.height,
						shape = "rect",
						onPress = onBtnListener,
					}) 
					historyOrderView:insert(orderDetailBtn)
					orderDetailBtn.anchorX = 0
					orderDetailBtn.x = ceil(35*wRate)
					orderDetailBtn.y = hisHorizontalLine.y+ceil(30*hRate)+ceil(text1.height/2)
					
					local hisVerticalLine1 = display.newLine( (orderDetailBtn.x+orderDetailBtn.width+ceil(25*wRate)), orderDetailBtn.y-ceil(orderDetailBtn.height/2),
								(orderDetailBtn.x+orderDetailBtn.width+ceil(25*wRate)), orderDetailBtn.y+ceil(orderDetailBtn.height/2) )
					historyOrderView:insert(hisVerticalLine1)
					hisVerticalLine1:setStrokeColor(unpack(separateLineColor))

					-- historyOrderView ScrollView 聯絡客服按鈕
					local text2 = display.newText({
						text = "聯絡客服",
						font = getFont.font,
						fontSize = 12,
					})
					historyOrderView:insert(text2)
					text2.isVisible = false
					local contactSrvBtn = widget.newButton({
						id = "contactSrvBtn",
						label = "聯絡客服",
						labelColor = { default = wordColor, over = mainColor1},
						font = getFont.font,
						fontSize = 12,
						width = text2.width,
						height = text2.height,
						shape = "rect",
						--fillColor = { default = subColor1, over = subColor2}
					}) 
					historyOrderView:insert(contactSrvBtn)
					contactSrvBtn.anchorX = 0
					contactSrvBtn.x = hisVerticalLine1.x+ceil(25*wRate)
					contactSrvBtn.y = hisHorizontalLine.y+ceil(30*hRate)+ceil(text2.height/2)
				end
				if(statusSet[i] == "overtime") then
					local statusText = display.newText({
						text = "逾時",
						font = getFont.font,
						fontSize = 12,
					})
					historyOrderView:insert(statusText)
					statusText:setFillColor(unpack(hintAlertColor))
					statusText.anchorX = 1
					statusText.x = hisOrderBase.width
					statusText.y = ceil(30*hRate)+ceil(statusText.height/2)+pad

					local text1 = display.newText({
						text = "刪除",
						font = getFont.font,
						fontSize = 12,
					})
					historyOrderView:insert(text1)
					text1.isVisible = false
					local delBtn = widget.newButton(
					{
						id = "delBtn",
						label = "刪除",
						labelColor = { default = wordColor, over = mainColor1},
						font = getFont.font,
						fontSize = 12,
						width = text1.width,
						height = text1.height,
						shape = "rect",
						onPress = onBtnListener,
					}) 
					historyOrderView:insert(delBtn)
					delBtn.anchorX = 0
					delBtn.x = ceil(35*wRate)
					delBtn.y = hisHorizontalLine.y+ceil(30*hRate)+ceil(text1.height/2)
					
					local hisVerticalLine1 = display.newLine( (delBtn.x+delBtn.width+ceil(25*wRate)), delBtn.y-ceil(delBtn.height/2),
								(delBtn.x+delBtn.width+ceil(25*wRate)), delBtn.y+ceil(delBtn.height/2) )
					historyOrderView:insert(hisVerticalLine1)
					hisVerticalLine1:setStrokeColor(unpack(separateLineColor))

					local text2 = display.newText({
						text = "訂單明細",
						font = getFont.font,
						fontSize = 12,
					})
					historyOrderView:insert(text2)
					text2.isVisible = false
					local orderDetailBtn = widget.newButton(
					{
						id = "orderDetailBtn",
						label = "訂單明細",
						labelColor = { default = wordColor, over = mainColor1},
						font = getFont.font,
						fontSize = 12,
						width = text2.width,
						height = text2.height,
						shape = "rect",
						onPress = onBtnListener,
					}) 
					historyOrderView:insert(orderDetailBtn)
					orderDetailBtn.anchorX = 0
					orderDetailBtn.x = hisVerticalLine1.x+ceil(25*wRate)
					orderDetailBtn.y = hisHorizontalLine.y+ceil(30*hRate)+ceil(text2.height/2)

					local hisVerticalLine2 = display.newLine( (orderDetailBtn.x+orderDetailBtn.width+ceil(25*wRate)), orderDetailBtn.y-ceil(orderDetailBtn.height/2),
								(orderDetailBtn.x+orderDetailBtn.width+ceil(25*wRate)), orderDetailBtn.y+ceil(orderDetailBtn.height/2) )
					historyOrderView:insert(hisVerticalLine2)
					hisVerticalLine2:setStrokeColor(unpack(separateLineColor))
					
					local text3 = display.newText({
						text = "聯絡客服",
						font = getFont.font,
						fontSize = 12,
					})
					historyOrderView:insert(text2)
					text3.isVisible = false
					local contactSrvBtn = widget.newButton({
						id = "contactSrvBtn",
						label = "聯絡客服",
						labelColor = { default = wordColor, over = mainColor1},
						font = getFont.font,
						fontSize = 12,
						width = text3.width,
						height = text3.height,
						shape = "rect",
						--fillColor = { default = subColor1, over = subColor2}
					}) 
					historyOrderView:insert(contactSrvBtn)
					contactSrvBtn.anchorX = 0
					contactSrvBtn.x = hisVerticalLine2.x+ceil(25*wRate)
					contactSrvBtn.y = hisHorizontalLine.y+ceil(30*hRate)+ceil(text3.height/2)
				end
			end
		end
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
		composer.removeScene("PC_orderList")
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