-----------------------------------------------------------------------------------------
--
-- orderOptions.lua
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

local ceil = math.ceil
local floor = math.floor

-- create()
function scene:create( event )
	local sceneGroup = self.view
	local getObjectId = event.params.objectId
	local getProductTitle = event.params.productTitle
	local getProductId = event.params.productId
	local getFromScene = event.params.fromScene
	local getPrice = event.params.singlePrice
	local getAmount = event.params.productAmount
	local getOrderDate = event.params.orderDate
	mainTabBar.myTabBarHidden()
	-- 時間參數 --
	local thisDate = { thisYear = tostring(os.date("%Y")), thisMonth = tostring(os.date("%m")), thisDay = tostring(os.date("%d"))}
	local thisYear = tonumber(thisDate.thisYear)
	local thisMonth = tonumber(thisDate.thisMonth)
	local febDays
	if ( thisYear%400 == 0 or (thisYear%4 ==0 and thisYear%100 ~= 0) ) then 
		febDays = 29
	else
		febDays = 28
	end
	local daysOfMonth = { 31, febDays, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31}
	setStatus = {}
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
			onRelease = 
			function ()
				local options
				if ( getFromScene == "goodPage" ) then
					options = {
						effect = "fade",
						time = 200,
						params = {
							productId = getProductId
						}
					}
				elseif ( getFromScene == "shoppingCart" ) then
					options = {
						effect = "fade",
						time = 200,
					}
				end
				composer.gotoScene( getFromScene, options )
				return true
			end,
		})
		sceneGroup:insert(backArrowNum,backBtn)
	-- 顯示文字-預定選項
		local titleText = display.newText({
			text = "預定選項",
			height = 0,
			y = backBtn.y,
			font = getFont.font,
			fontSize = 14,
		})
		sceneGroup:insert(titleText)
		titleText:setFillColor(unpack(wordColor))
		titleText.anchorX = 0
		titleText.x = backArrow.x+backArrow.contentWidth+ceil(30*wRate)
	-- 陰影
		local titleBaseShadow = display.newImage( sceneGroup, "assets/s-down.png", titleBase.x, titleBase.y+titleBase.contentHeight*0.5)
		titleBaseShadow.anchorY = 0
		titleBaseShadow.width = titleBase.contentWidth
		titleBaseShadow.height = floor(titleBaseShadow.height*0.6)
	------------------- 商品名稱 -------------------
		local productTitleBase = display.newRect( sceneGroup, cx, titleBaseShadow.y+floor(35*hRate), screenW+ox+ox, screenH/12)
		productTitleBase.anchorY = 0
		local productTitleText = display.newText({
			parent = sceneGroup,
			text = getProductTitle,
			font = getFont.font,
			fontSize = 14,
			x = backArrow.x,
			y = productTitleBase.y+productTitleBase.contentHeight*0.5,
			width = screenW+ox+ox-ceil(49*wRate)*2,
			height = 0,
		})
		productTitleText:setFillColor(unpack(mainColor2))
		productTitleText.anchorX = 0
		if ( productTitleText.contentHeight > productTitleBase.contentHeight ) then
			productTitleBase.height = productTitleText.contentHeight*1.1
		end
	------------------- 選項列表 -------------------
		local optionText = { "選擇訂購日期", "選擇商品數量"}
		local productOptionText, productOptionArrow, productOptionLine = {}, {}, {}
		local productOptionBaseY = productTitleBase.y+productTitleBase.contentHeight+floor(35*hRate)
		local dateOptionY
		local dateOptionGroup = display.newGroup()
		local productCountScrollView
		local function productOptionListener( event )
			local phase = event.phase
			local id = event.target.id
			if ( phase == "ended" ) then
				productOptionArrow[id]:rotate(180)
				if ( setStatus[id] == "down" ) then
					setStatus[id] = "up"
					productOptionLine[id]:setStrokeColor(unpack(mainColor1))
					productOptionLine[id].strokeWidth = 2
					if ( id == 1 ) then
						dateOptionGroup.isVisible = true
					elseif ( id == 2 ) then
						productCountScrollView.isVisible = true
					end	
				else
					setStatus[id] = "down"
					productOptionLine[id]:setStrokeColor(unpack(separateLineColor))
					productOptionLine[id].strokeWidth = 1
					if ( id == 1 ) then
						dateOptionGroup.isVisible = false
					elseif ( id == 2 ) then
						productCountScrollView.isVisible = false
						if ( tonumber(productOptionText[id]) == nil ) then
							productCountScrollView:scrollTo("top", { time = 100 })
						end
					end	
				end
			end
			return true
		end
		for i=1, #optionText do
			local productOptionBase = display.newRect( sceneGroup, cx, productOptionBaseY, screenW+ox+ox, screenH/16)
			productOptionBase.anchorY = 0
			productOptionBase.id = i
			productOptionBase:addEventListener("touch", productOptionListener)

			productOptionText[i] = display.newText({
				parent = sceneGroup,
				text = optionText[i],
				font = getFont.font,
				fontSize = 12,
				x = backArrow.x,
				y = productOptionBaseY+productOptionBase.contentHeight*0.35,
			})
			productOptionText[i]:setFillColor(unpack(wordColor))
			productOptionText[i].anchorX = 0
			productOptionText[i].anchorY = 0
			productOptionLine[i] = display.newLine( sceneGroup, productOptionText[i].x, productOptionBaseY+productOptionBase.contentHeight*0.85, productOptionBase.contentWidth-ceil(49*wRate), productOptionBaseY+productOptionBase.contentHeight*0.85)
			productOptionLine[i]:setStrokeColor(unpack(separateLineColor))
			productOptionLine[i].strokeWidth = 1
			if ( i == 1) then
				dateOptionY = productOptionLine[i].y
			end

			productOptionArrow[i] = display.newImage( sceneGroup, "assets/btn-dropdown-dg.png", productOptionLine[i].x+productOptionLine[i].contentWidth, productOptionText[i].y+productOptionText[i].contentHeight*0.5)
			productOptionArrow[i].width = productOptionArrow[i].width*0.05
			productOptionArrow[i].height = productOptionArrow[i].height*0.05
			productOptionArrow[i].x = productOptionArrow[i].x-productOptionArrow[i].contentWidth
			setStatus[i] = "down"
			productOptionBaseY = productOptionBaseY+productOptionBase.contentHeight
			if ( i == #optionText) then
				local productionBottomBase = display.newRect( sceneGroup, cx, productOptionBaseY, screenW+ox+ox, screenH/16)
				productionBottomBase.anchorY = 0
				productOptionBaseY = productOptionBaseY+productionBottomBase.contentHeight
			end
		end
		if ( getFromScene == "shoppingCart" ) then
			productOptionText[1].text = getOrderDate
			productOptionText[2].text = getAmount
		end
	------------------- 按鈕 -------------------
		local bottomBase = display.newRect( sceneGroup, cx, screenH+oy, screenW+ox+ox, screenH/10)
		bottomBase.anchorY = 1
		local bottomBaseText = display.newText({
			parent = sceneGroup,
			text = "合計",
			font = getFont.font,
			fontSize = 12,
			x = backArrow.x,
			y = bottomBase.y-bottomBase.contentHeight*0.6,
		})
		bottomBaseText:setFillColor(unpack(wordColor))
		bottomBaseText.anchorX = 0
		local bottomMoneySignText = display.newText({
			parent = sceneGroup,
			text = "NT$",
			font = getFont.font,
			fontSize = 12,
			x = backArrow.x,
			y = bottomBase.y-bottomBase.contentHeight*0.3,
		})
		bottomMoneySignText:setFillColor(unpack(subColor2))
		bottomMoneySignText.anchorX = 0
		local bottomMoneyText = display.newText({
			parent = sceneGroup,
			text = getPrice*getAmount,
			font = getFont.font,
			fontSize = 12,
			x = bottomMoneySignText.x+bottomMoneySignText.contentWidth+ceil(10*wRate),
			y = bottomMoneySignText.y,
		})
		bottomMoneyText:setFillColor(unpack(subColor2))
		bottomMoneyText.anchorX = 0
		local btnLabel
		if ( getFromScene == "goodPage" ) then
			btnLabel = "確認加入"
		elseif ( getFromScene == "shoppingCart" ) then
			btnLabel = "確認更改"
		end
		local nextStepBtn = widget.newButton({
			id = "nextStepBtn",
			x = screenW+ox-ceil(49*wRate),
			y = bottomBase.y-bottomBase.contentHeight*0.5,
			label = btnLabel,
			labelColor = { default = { 1, 1, 1}, over = { 1, 1, 1, 0.6}},
			font = getFont.font,
			fontSize = 12,
			defaultFile = "assets/btn-addtocart.png",
			width = bottomBase.contentWidth*0.2,
			height = bottomBase.contentHeight*0.6,
			onRelease = function ( event )
				local accessToken
				if ( composer.getVariable("accessToken") and composer.getVariable("accessToken") ~= "N/A") then
					accessToken = composer.getVariable("accessToken")
				end
				local fullDatePattern = "%d+/%d+/%d+"
				if ( productOptionText[1].text:match(fullDatePattern) ~= nil and tonumber(productOptionText[2].text) ~= nil ) then
					local getDatePattern = "(%d+)/(%d+)/(%d+)"
					local year,month,day = productOptionText[1].text:match(getDatePattern)
					local beginDay = year..month..day.."00".."00".."00"
					local endDay = (year+1)..month..day.."00".."00".."00"
					local headers = {}
					local body
					local params = {}
					local hintRoundedRect = widget.newButton({
						x = cx,
						y = (screenH+oy+oy)*0.7,
						isEnabled = false,
						fillColor = { default = { 0, 0, 0, 0.6}, over = { 0, 0, 0, 0.6}},
						shape = "roundedRect",
						width = screenW*0.35,
						height = screenH/16,
						cornerRadius = 20,
					})
					local hintRoundedRectText = display.newText({
						text = "",
						font = getFont.font,
						fontSize = 14,
						x = hintRoundedRect.x,
						y = hintRoundedRect.y,
					})
					if ( getFromScene == "goodPage" ) then
						headers["Authorization"] = "Bearer "..accessToken
						headers["Content-Type"] = "application/json"
						body = "{\"itemId\":\""..getProductId.."\",\"count\":"..productOptionText[2].text..",\"useBegin\":\""..beginDay.."\",\"useEnd\":\""..endDay.."\",\"useCouponId\":\"0\"}"
						params.headers = headers
						params.body = body
						local function setIntoCart( event )
							if ( event.isError ) then
								print( "Network error!")
							else
								--print ("RESPONSE: "..event.response)
								hintRoundedRectText.text = "已加入購物車"
								timer.performWithDelay( 1700, function ()
									hintRoundedRectText.alpha = 0.3
									hintRoundedRect.alpha = 0.3
								end)
								timer.performWithDelay( 1800, function ()
									hintRoundedRectText.alpha = 0.2
									hintRoundedRect.alpha = 0.2
								end)
								timer.performWithDelay( 1900, function ()
									hintRoundedRectText.alpha = 0.1
									hintRoundedRect.alpha = 0.1
								end)
								timer.performWithDelay( 2000, function ()
									hintRoundedRectText:removeSelf()
									hintRoundedRect:removeSelf()
								end)
							end
						end
						local url = "http://211.21.114.208/1.0/ShoppingCart/add"
						network.request( url, "POST", setIntoCart, params)
					elseif ( getFromScene == "shoppingCart" ) then
						headers["Authorization"] = "Bearer "..accessToken
						headers["Content-Type"] = "application/json"
						body = "{\"id\":\""..getObjectId.."\",\"count\":"..productOptionText[2].text..",\"useBegin\":\""..beginDay.."\",\"useEnd\":\""..endDay.."\",\"useCouponId\":\"0\",\"useScore\":0}"
						params.headers = headers
						params.body = body
						local function upDateProduct( event )
							if ( event.isError ) then
								print( "Network error!")
							else
								composer.gotoScene( getFromScene, { time = 200, effect = "fade"})
								hintRoundedRectText.text = "更改完成",
								timer.performWithDelay( 1700, function ()
									hintRoundedRectText.alpha = 0.3
									hintRoundedRect.alpha = 0.3
								end)
								timer.performWithDelay( 1800, function ()
									hintRoundedRectText.alpha = 0.2
									hintRoundedRect.alpha = 0.2
								end)
								timer.performWithDelay( 1900, function ()
									hintRoundedRectText.alpha = 0.1
									hintRoundedRect.alpha = 0.1
								end)
								timer.performWithDelay( 2000, function ()
									hintRoundedRectText:removeSelf()
									hintRoundedRect:removeSelf()
								end)
							end
						end
						local url = "http://211.21.114.208:80/1.0/ShoppingCart/edit"
						network.request( url, "POST", upDateProduct, params)
					end
				end
			end,
		})
		sceneGroup:insert(nextStepBtn)
		nextStepBtn.anchorX = 1
	------------------- 商品數量選單 -------------------
		local productCountBaseHeight = screenH/16
		productCountScrollView = widget.newScrollView({
			id = "productCountScrollView",
			top = productOptionLine[2].y+2,
			horizontalScrollDisabled = true,
			isBounceEnabled = false,
			width = productOptionLine[2].contentWidth*0.8,
			height = productCountBaseHeight*6,
			backgroundColor = backgroundColor,
		})
		sceneGroup:insert(productCountScrollView)
		productCountScrollView.x = cx
		local productCountBaseWidth = productCountScrollView.contentWidth
		local productCountGroup = display.newGroup()
		productCountScrollView:insert(productCountGroup)
		local nowCount, prevCount = nil, nil
		local countCancel = false
		local function productCountListener( event )
			local phase = event.phase
			if ( phase == "began" ) then
				if ( countCancel == true) then
					countCancel = false
				end
				-- 第一次觸碰物件 --
				if ( nowCount == nil and prevCount == nil ) then
					nowCount = event.target
					nowCount:setFillColor( 0, 0, 0, 0.1)

					prevCount = nowCount
				end
				-- 有物件被選定後的觸碰事件 --
				if ( nowCount == nil and prevCount ~= nil ) then
					prevCount:setFillColor(1)

					nowCount = event.target
					nowCount:setFillColor( 0, 0, 0, 0.1)
				end
			elseif ( phase == "moved" ) then
				countCancel = true
				local dy = math.abs( event.yStart - event.y)
				if ( dy > 10 ) then
					productCountScrollView:takeFocus(event)
				end
				-- 尚未有物件被選定的取消事件 --
				if ( event.target == nowCount and event.target == prevCount ) then
					event.target:setFillColor(1)
					prevCount = nil
					nowCount = nil
				end
				-- 有物件被選定後的取消事件 --
				if ( event.target == nowCount and event.target ~= prevCount ) then
					prevCount:setFillColor( 0, 0, 0, 0.1)

					event.target:setFillColor(1)
					nowCount = nil
				end
			elseif ( phase == "ended" and countCancel == false ) then
				productCountScrollView.isVisible = false
				setStatus[2] = "down"
				productOptionArrow[2]:rotate(180)
				productOptionLine[2]:setStrokeColor(unpack(separateLineColor))
				productOptionLine[2].strokeWidth = 1
				productOptionText[2].text = tostring(event.target.id)
				prevCount = nowCount
				nowCount = nil
				bottomMoneyText.text = tostring(tonumber(getPrice)*tonumber(event.target.id))
			end
			return true
		end
		for i = 1, 10 do
			local productCountBase = display.newRect( productCountGroup, productCountBaseWidth*0.5, 0+(productCountBaseHeight)*(i-1), productCountBaseWidth, productCountBaseHeight)
			productCountBase.anchorY = 0
			productCountBase.id = i
			productCountBase:addEventListener("touch", productCountListener)
			local productCountText = display.newText({
				parent = productCountGroup,
				text = i,
				font = getFont.font,
				fontSize = 12,
				x = productCountBase.x,
				y = productCountBase.y+productCountBase.contentHeight*0.5,
			})
			productCountText:setFillColor(unpack(wordColor))
		end
		productCountScrollView.isVisible = false
	------------------- 訂購日期選單 -------------------
	-- 時間參數 --
		sceneGroup:insert(dateOptionGroup)
		local weekDays = { "日", "一", "二", "三","四", "五", "六" }
		local firstDay = os.time({ year = thisYear, month = thisMonth, day = "1"})
		local finallDay = os.time({ year = thisYear, month = thisMonth, day = daysOfMonth[thisMonth]})
		local startWeek = os.date("%U",firstDay)
		local endWeek = os.date("%U",finallDay)
		local totalWeek = endWeek-startWeek+1
		local startWeekday = os.date("%w",firstDay)
		local startDayNum = startWeekday+1
		local endDayNum = startDayNum+daysOfMonth[thisMonth]-1
	-- 月曆 --
	-- 顯示文字-"年"
		local dateTitleBase = display.newRect( dateOptionGroup, cx, dateOptionY+1, screenW+ox+ox, screenH/10)
		dateTitleBase.anchorY = 0
		local yearText = display.newText({
			parent = dateOptionGroup,
			text = "年",
			font = getFont.font,
			fontSize = 12,
			x = cx,
			y = dateTitleBase.y+dateTitleBase.contentHeight*0.3
		})
		yearText:setFillColor(unpack(wordColor))	
		-- 顯示文字-年數字
		local yearDateText = display.newText({
			parent = dateOptionGroup,
			text = thisDate.thisYear,
			font = getFont.font,
			fontSize = 12,
			x = yearText.x-yearText.contentWidth*0.5,
			y = yearText.y
		})
		yearDateText:setFillColor(unpack(wordColor))
		yearDateText.anchorX = 1
	-- 顯示文字-月數字
		local monthDateText = display.newText({
			parent = dateOptionGroup,
			text = thisDate.thisMonth,
			font = getFont.font,
			fontSize = 12,
			x = yearText.x+yearText.contentWidth*0.5,
			y = yearText.y
		})
		monthDateText:setFillColor(unpack(wordColor))
		monthDateText.anchorX = 0
	-- 顯示文字-"月"
		local monthText = display.newText({
			parent = dateOptionGroup,
			text = "月",
			font = getFont.font,
			fontSize = 12,
			x = monthDateText.x+monthDateText.contentWidth,
			y = yearText.y
		})
		monthText:setFillColor(unpack(wordColor))
		monthText.anchorX = 0
	-- 顯示文字-"日~六"
		local monthDaysBaseEdge = floor((screenW+ox+ox)/#weekDays)-1
		for i=1, #weekDays do
			local weekDaysText = display.newText({
				parent = dateOptionGroup,
				text = weekDays[i],
				font = getFont.font,
				fontSize = 12,
				x = -ox+(dateTitleBase.contentWidth-monthDaysBaseEdge*#weekDays)*0.5+monthDaysBaseEdge*0.5,
				y = dateTitleBase.y+dateTitleBase.contentHeight-floor(25*hRate),
			})
			weekDaysText:setFillColor(unpack(wordColor))
			weekDaysText.anchorY = 1
			weekDaysText.x = weekDaysText.x+(monthDaysBaseEdge)*(i-1)
		end
	-- 月曆日期監聽事件 --
		local monthdayText = {}
		local nowTarget, prevTarget = nil, nil
		local isCancel = false
		local function calendarDayListener( event )
			local phase = event.phase
			if ( phase == "began") then
				if ( isCancel == true ) then
					isCancel = false
				end
				-- 第一次觸碰物件 --
				if ( nowTarget == nil and prevTarget == nil ) then
					nowTarget = event.target
					nowTarget:setFillColor(unpack(mainColor1))
					monthdayText[nowTarget.id]:setFillColor(1)

					prevTarget = nowTarget
				end
				-- 有物件被選定後的觸碰事件 --
				if ( nowTarget == nil and prevTarget ~= nil ) then
					prevTarget:setFillColor(1)
					monthdayText[prevTarget.id]:setFillColor(unpack(wordColor))

					nowTarget = event.target
					nowTarget:setFillColor(unpack(mainColor1))
					monthdayText[nowTarget.id]:setFillColor(1)
				end
			elseif ( phase == "moved" ) then
				isCancel = true
				-- 尚未有物件被選定的取消事件 --
				if ( event.target == nowTarget and event.target == prevTarget ) then
					event.target:setFillColor(1)
					monthdayText[event.target.id]:setFillColor(unpack(wordColor))
					prevTarget = nil
					nowTarget = nil
				end
				-- 有物件被選定後的取消事件 --
				if ( event.target == nowTarget and event.target ~= prevTarget ) then
					prevTarget:setFillColor(unpack(mainColor1))
					monthdayText[prevTarget.id]:setFillColor(1)

					event.target:setFillColor(1)
					monthdayText[event.target.id]:setFillColor(unpack(wordColor))
					nowTarget = nil
				end
			elseif ( phase == "ended" and isCancel == false ) then
				dateOptionGroup.isVisible = false
				setStatus[1] = "down"
				productOptionArrow[1]:rotate(180)
				productOptionLine[1]:setStrokeColor(unpack(separateLineColor))
				productOptionLine[1].strokeWidth = 1
				if ( tonumber(monthdayText[nowTarget.id].text) < 10 ) then
					productOptionText[1].text = yearDateText.text.."/"..monthDateText.text.."/".."0"..monthdayText[nowTarget.id].text
				else
					productOptionText[1].text = yearDateText.text.."/"..monthDateText.text.."/"..monthdayText[nowTarget.id].text
				end
				prevTarget = nowTarget
				nowTarget = nil
			end
			return true
		end
	-- 月曆日期元件 --
		local calendarGroup = display.newGroup()
		dateOptionGroup:insert(calendarGroup)
		local xBasement, yBasement = 0, 0
		local bottomLineNum
		for i = 1, #weekDays*totalWeek do
			xBasement = ((i-1)%#weekDays)
			if ( xBasement == 0 ) then
				if ( i > 1 ) then
					yBasement = yBasement+1
				end

				weekBase = display.newRect( calendarGroup, cx, dateTitleBase.y+dateTitleBase.contentHeight+monthDaysBaseEdge*yBasement, screenW+ox+ox, monthDaysBaseEdge)
				weekBase.anchorY = 0
			end
			-- 月曆觸碰事件
			local monthDaysBase = display.newRect( calendarGroup, -ox+(dateTitleBase.contentWidth-monthDaysBaseEdge*#weekDays)*0.5, dateTitleBase.y+dateTitleBase.contentHeight+monthDaysBaseEdge*yBasement, monthDaysBaseEdge, monthDaysBaseEdge)
			monthDaysBase.anchorX = 0
			monthDaysBase.anchorY = 0
			monthDaysBase.x = monthDaysBase.x+monthDaysBase.contentWidth*xBasement
			monthDaysBase.id = i
			-- 月曆顯示日期
			monthdayText[i] = display.newText({
				parent = calendarGroup,
				text = "",
				font = getFont.font,
				fontSize = 10,
				x = monthDaysBase.x+monthDaysBase.contentWidth*0.5,
				y = monthDaysBase.y+monthDaysBase.contentHeight*0.5,
			})
			if ( i >= startDayNum and i <= endDayNum) then
				monthdayText[i].text = i-startDayNum+1
				if ( tonumber(yearDateText.text) == tonumber(thisDate.thisYear) and tonumber(monthDateText.text) == tonumber(thisDate.thisMonth) and tonumber(monthdayText[i].text) < tonumber(thisDate.thisDay) ) then
					monthdayText[i]:setFillColor(unpack(separateLineColor))
				else
					monthdayText[i]:setFillColor(unpack(wordColor))
					monthDaysBase:addEventListener("touch", calendarDayListener)
				end
			else
				monthdayText[i].text = ""
			end
			local verticalLine = display.newLine ( calendarGroup, monthDaysBase.x, monthDaysBase.y, monthDaysBase.x, monthDaysBase.y+monthDaysBase.contentHeight)
			verticalLine:setStrokeColor(unpack(separateLineColor))
			verticalLine.strokeWidth = 1
			if ( xBasement == 6 ) then
				local verticalLineBottom = display.newLine ( calendarGroup, monthDaysBase.x+monthDaysBaseEdge, monthDaysBase.y, monthDaysBase.x+monthDaysBaseEdge, monthDaysBase.y+monthDaysBase.contentHeight)
				verticalLineBottom:setStrokeColor(unpack(separateLineColor))
				verticalLineBottom.strokeWidth = 1

				local horizontalLine = display.newLine ( calendarGroup, -ox+(dateTitleBase.contentWidth-monthDaysBaseEdge*#weekDays)*0.5, monthDaysBase.y, screenW+ox-(dateTitleBase.contentWidth-monthDaysBaseEdge*#weekDays)*0.5, monthDaysBase.y)
				horizontalLine:setStrokeColor(unpack(separateLineColor))
				horizontalLine.strokeWidth = 1
				if ( totalWeek-yBasement == 1 ) then
					local horizontalLineBottom = display.newLine ( calendarGroup, -ox+(dateTitleBase.contentWidth-monthDaysBaseEdge*#weekDays)*0.5, monthDaysBase.y+monthDaysBase.contentHeight, screenW+ox-(dateTitleBase.contentWidth-monthDaysBaseEdge*#weekDays)*0.5, monthDaysBase.y+monthDaysBase.contentHeight)
					horizontalLineBottom:setStrokeColor(unpack(separateLineColor))
					horizontalLineBottom.strokeWidth = 1
					bottomLineNum = calendarGroup.numChildren
				end
			end
		end
		local hintBase = display.newRect( cx, dateTitleBase.y+dateTitleBase.contentHeight+monthDaysBaseEdge*totalWeek, screenW+ox+ox, monthDaysBaseEdge*0.8)
		calendarGroup:insert( bottomLineNum, hintBase)
		hintBase.anchorY = 0
		local circle = display.newCircle ( calendarGroup, backArrow.x+backArrow.contentWidth*0.5, hintBase.y+hintBase.contentHeight*0.5, 6)
		circle:setFillColor(unpack(separateLineColor))
		local hintText = display.newText({
			parent = calendarGroup,
			text = "不可選日期",
			font = getFont.font,
			fontSize = 12,
			x = circle.x+circle.contentWidth+ceil(10*wRate),
			y = circle.y,
		})
		hintText:setFillColor(unpack(wordColor))
		hintText.anchorX = 0
	-- 左右箭頭監聽事件
		local leftArrow, leftArrowBtn, rightArrow, rightArrowBtn 
		local function dateChangeListener(event)
			local id = event.target.id
			if ( id == "rightArrowBtn" ) then
				local eventNextYear
				local eventNextMonth
				if ( tonumber(monthDateText.text)+1 <= 14 ) then
					if ( tonumber(monthDateText.text)+1 < 10 ) then
						eventNextMonth = "0"..tostring(tonumber(monthDateText.text)+1)
					else
						eventNextMonth = tostring(tonumber(monthDateText.text)+1)
					end
					monthDateText.text = eventNextMonth
					if ( tonumber(monthDateText.text)+1 == 14 ) then
						eventNextMonth = "01"
						eventNextYear = tostring(tonumber(yearDateText.text)+1)
						monthDateText.text = eventNextMonth
						yearDateText.text = eventNextYear
					end
					
					if ( tonumber(monthDateText.text) > tonumber(thisDate.thisMonth) ) then
						leftArrow.isVisible = true
						leftArrowBtn.isVisible = true
					end
				end
			end
			if ( id == "leftArrowBtn" ) then
				local eventlastYear
				local eventlastMonth
				if ( tonumber(monthDateText.text)-1 >= -1 ) then
					if ( tonumber(monthDateText.text)-1 < 10 ) then
						eventlastMonth = "0"..tostring(tonumber(monthDateText.text)-1)
					else
						eventlastMonth = tostring(tonumber(monthDateText.text)-1)
					end
					monthDateText.text = eventlastMonth
					if ( tonumber(monthDateText.text)-1 == -1 ) then
						eventlastMonth = "12"
						eventlastYear = tostring(tonumber(yearDateText.text)-1)
						monthDateText.text = eventlastMonth
						yearDateText.text = eventlastYear
					end
					if ( tonumber(monthDateText.text) == tonumber(thisDate.thisMonth) and tonumber(yearDateText.text) == tonumber(thisDate.thisYear)) then
						leftArrow.isVisible = false
						leftArrowBtn.isVisible = false
					end
				end
			end
		end
	-- 按鈕-左右箭頭
		leftArrow = display.newImage( dateOptionGroup, "assets/btn-dropdown.png", yearDateText.x-yearDateText.contentWidth-ceil(40*wRate), dateTitleBase.y+dateTitleBase.contentHeight*0.28)
		leftArrow:rotate(90)
		leftArrow.width = leftArrow.width*0.05
		leftArrow.height = leftArrow.height*0.05
		leftArrow.x = leftArrow.x - leftArrow.contentWidth*0.5
		local leftArrowNum = dateOptionGroup.numChildren
		leftArrowBtn = widget.newButton({
			id = "leftArrowBtn",
			shape = "rect",
			fillColor = { default = {1,1,1}, over = {0,0,0,0.1}},
			x = leftArrow.x,
			y = leftArrow.y,
			width = leftArrow.contentWidth*3,
			height = leftArrow.contentHeight*2,
			onRelease = dateChangeListener,
		})
		dateOptionGroup:insert( leftArrowNum, leftArrowBtn)
		
		rightArrow = display.newImage(dateOptionGroup, "assets/btn-dropdown.png", monthText.x+monthText.contentWidth+ceil(40*wRate), leftArrow.y)
		rightArrow:rotate(270)
		rightArrow.width = rightArrow.width*0.05
		rightArrow.height = rightArrow.height*0.05
		rightArrow.x = rightArrow.x + rightArrow.contentWidth*0.5
		local rightArrowNum = dateOptionGroup.numChildren
		rightArrowBtn = widget.newButton({
			id = "rightArrowBtn",
			shape = "rect",
			fillColor = { default = {1,1,1}, over = {0,0,0,0.1}},
			x = rightArrow.x,
			y = rightArrow.y,
			width = rightArrow.contentWidth*3,
			height = rightArrow.contentHeight*2,
			onRelease = dateChangeListener,
		})
		dateOptionGroup:insert( rightArrowNum, rightArrowBtn)
		if ( yearDateText.text == thisDate.thisYear and monthDateText.text == thisDate.thisMonth) then
			leftArrow.isVisible = false
			leftArrowBtn.isVisible = false
		end
		dateOptionGroup.isVisible = false
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
		composer.removeScene("orderOptions")
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