-----------------------------------------------------------------------------------------
--
-- orderOptions.lua
--
-----------------------------------------------------------------------------------------
local composer = require ("composer")
local widget = require ("widget")
local mainTabBar = require ("mainTabBar")
local getFont = require("setFont")
local json = require("json")
local token = require("token")

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
		for i = 1, #optionText do
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
	------------------- 底部元件 -------------------
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
				if ( composer.getVariable("accessToken") ) then
					if ( token.getAccessToken() and token.getAccessToken() ~= composer.getVariable("accessToken") ) then
						composer.setVariable( "accessToken", token.getAccessToken() )
					end
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
					local hintGroup = display.newGroup()
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
					hintGroup:insert(hintRoundedRect)
					local hintRoundedRectText = display.newText({
						text = "",
						font = getFont.font,
						fontSize = 14,
						x = hintRoundedRect.x,
						y = hintRoundedRect.y,
					})
					hintGroup:insert(hintRoundedRectText)
					if ( getFromScene == "goodPage" ) then
						hintRoundedRectText.text = "已加入購物車"
					elseif ( getFromScene == "shoppingCart" ) then
						hintRoundedRectText.text = "更改完成"
					end
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
								composer.gotoScene( "shoppingCart", { time = 200, effect = "fade" } )
								--hintRoundedRectText.text = "已加入購物車"
								transition.to( hintGroup, { time = 2000, alpha = 0, transition = easing.inExpo } )
								--transition.to( hintRoundedRect, { time = 2000, alpha = 0, transition = easing.inExpo } )
								timer.performWithDelay( 2000, function ()
									hintGroup:removeSelf()
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
								--hintRoundedRectText.text = "更改完成",
								transition.to( hintRoundedRectText, { time = 2000, alpha = 0, transition = easing.inExpo } )
								transition.to( hintRoundedRect, { time = 2000, alpha = 0, transition = easing.inExpo } )
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
	-- 月曆 --
	-- 顯示文字-"年"
		sceneGroup:insert(dateOptionGroup)
		local dateTitleBase = display.newRect( dateOptionGroup, cx, dateOptionY+1, screenW+ox+ox, screenH/10)
		dateTitleBase:addEventListener("touch", function ()
			return true
		end)
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
		local weekDays = { "日", "一", "二", "三","四", "五", "六" }
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
		local monthDaysBase, monthdayText = {}, {}
		local groupNumData = {} -- calendarGroup[groupNumData]對應的月份
		local yearData, dayData = {}, {}
		local nowTarget, prevTarget = nil, nil
		local isCancel = false
		local function calendarDayListener( event )
			local getGroupNum = groupNumData[tonumber(monthDateText.text)]
			local phase = event.phase
			if ( phase == "began") then
				if ( isCancel == true ) then
					isCancel = false
				end
				-- 第一次觸碰物件 --
				if ( nowTarget == nil and prevTarget == nil ) then
					nowTarget = event.target
					nowTarget:setFillColor(unpack(mainColor1))
					monthdayText[getGroupNum][nowTarget.id]:setFillColor(1)

					prevTarget = nowTarget
				end
				-- 有物件被選定後的觸碰事件 --
				if ( nowTarget == nil and prevTarget ~= nil ) then
					prevTarget:setFillColor(1)
					monthdayText[getGroupNum][prevTarget.id]:setFillColor(unpack(wordColor))

					nowTarget = event.target
					nowTarget:setFillColor(unpack(mainColor1))
					monthdayText[getGroupNum][nowTarget.id]:setFillColor(1)
				end
			elseif ( phase == "moved" ) then
				isCancel = true
				-- 尚未有物件被選定的取消事件 --
				if ( event.target == nowTarget and event.target == prevTarget ) then
					event.target:setFillColor(1)
					monthdayText[getGroupNum][event.target.id]:setFillColor(unpack(wordColor))
					prevTarget = nil
					nowTarget = nil
				end
				-- 有物件被選定後的取消事件 --
				if ( event.target == nowTarget and event.target ~= prevTarget ) then
					prevTarget:setFillColor(unpack(mainColor1))
					monthdayText[getGroupNum][prevTarget.id]:setFillColor(1)

					event.target:setFillColor(1)
					monthdayText[getGroupNum][event.target.id]:setFillColor(unpack(wordColor))
					nowTarget = nil
				end
			elseif ( phase == "ended" and isCancel == false ) then
				dateOptionGroup.isVisible = false
				setStatus[1] = "down"
				productOptionArrow[1]:rotate(180)
				productOptionLine[1]:setStrokeColor(unpack(separateLineColor))
				productOptionLine[1].strokeWidth = 1
				if ( tonumber(monthdayText[getGroupNum][nowTarget.id].text) < 10 ) then
					productOptionText[1].text = yearDateText.text.."/"..monthDateText.text.."/".."0"..monthdayText[getGroupNum][nowTarget.id].text
				else
					productOptionText[1].text = yearDateText.text.."/"..monthDateText.text.."/"..monthdayText[getGroupNum][nowTarget.id].text
				end
				prevTarget = nowTarget
				nowTarget = nil
			end
			return true
		end
	-- 月曆日期元件 --
	-- 時間參數 --
		local firstDay = os.time({ year = thisYear, month = thisMonth, day = "1"})
		local finallDay = os.time({ year = thisYear, month = thisMonth, day = daysOfMonth[thisMonth]})
		local startWeek = os.date("%U",firstDay)
		local endWeek = os.date("%U",finallDay)
		local totalWeek = endWeek-startWeek+1
		local startWeekday = os.date("%w",firstDay)
		local startWeekDayNum = startWeekday+1
		local endWeekDayNum = startWeekDayNum+daysOfMonth[thisMonth]-1
	-- 月曆表格參數 --
		local xBasement, yBasement = 0, 0
		local bottomLineNum
		local limitedAddedMonth = 6
		local calendarGroup = {}
		local getYear = thisYear
		local getMonth = thisMonth
	-- 月曆月份 --
		for j = 1, limitedAddedMonth+1 do
			monthdayText[j] = {}
			monthDaysBase[j] = {}
			yBasement = 0
			calendarGroup[j] = display.newGroup()
			dateOptionGroup:insert(calendarGroup[j])
			if ( getYear%400 == 0 or ( getYear%4 == 0 and getYear%100 ~= 0 ) ) then 
				febDays = 29
			else
				febDays = 28
			end
			local daysOfCalendarMonth = { 31, febDays, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31}
			if ( j > 1 ) then
				getMonth = tonumber(getMonth)+1
				if ( tonumber(getMonth) < 10 ) then
					getMonth = "0"..tonumber(getMonth)
				elseif ( tonumber(getMonth) == 13 ) then
					getMonth = "01"
					getYear = tonumber(getYear)+1
				end
				calendarGroup[j].x = calendarGroup[j].x+(screenW+ox+ox)
			else
				calendarGroup[j].x = calendarGroup[j].x
			end
			-- 反查表
			yearData[tonumber(getMonth)] = getYear -- 記錄該月對應的年份
			groupNumData[tonumber(getMonth)] = j -- 記錄該月對應的calendarGroup編號
			dayData[j] = {} -- 記錄該groupNum對應的月份的日期編號
			
			firstDay = os.time({ year = getYear, month = getMonth, day = "1" })
			finallDay = os.time({ year = getYear, month = getMonth, day = daysOfCalendarMonth[tonumber(getMonth)] })
			startWeek = os.date("%U",firstDay)
			endWeek = os.date("%U",finallDay)
			totalWeek = endWeek-startWeek+1
			startWeekday = os.date("%w",firstDay)
			startWeekDayNum = startWeekday+1
			endWeekDayNum = startWeekDayNum+daysOfCalendarMonth[tonumber(getMonth)]-1
			-- 該月份的天數
			for i = 1, #weekDays*totalWeek do
				xBasement = ((i-1)%#weekDays)
				if ( xBasement == 0 ) then
					if ( i > 1 ) then
						yBasement = yBasement+1
					end
					weekBase = display.newRect( calendarGroup[j], cx, dateTitleBase.y+dateTitleBase.contentHeight+monthDaysBaseEdge*yBasement, screenW+ox+ox, monthDaysBaseEdge)
					weekBase.anchorY = 0
				end
				-- 月曆觸碰事件
				monthDaysBase[j][i] = display.newRect( calendarGroup[j], -ox+(dateTitleBase.contentWidth-monthDaysBaseEdge*#weekDays)*0.5, dateTitleBase.y+dateTitleBase.contentHeight+monthDaysBaseEdge*yBasement, monthDaysBaseEdge, monthDaysBaseEdge)
				monthDaysBase[j][i].anchorX = 0
				monthDaysBase[j][i].anchorY = 0
				monthDaysBase[j][i].x = monthDaysBase[j][i].x+monthDaysBase[j][i].contentWidth*xBasement
				monthDaysBase[j][i].id = i
				-- 月曆顯示日期
				monthdayText[j][i] = display.newText({
					parent = calendarGroup[j],
					text = "",
					font = getFont.font,
					fontSize = 10,
					x = monthDaysBase[j][i].x+monthDaysBase[j][i].contentWidth*0.5,
					y = monthDaysBase[j][i].y+monthDaysBase[j][i].contentHeight*0.5,
				})
				if ( i >= startWeekDayNum and i <= endWeekDayNum) then
					monthdayText[j][i].text = i-startWeekDayNum+1
					dayData[j][(i-startWeekDayNum+1)] = i -- 紀錄某月份該日對應的編號
					if ( getYear == tonumber(thisDate.thisYear) and getMonth == tonumber(thisDate.thisMonth) and tonumber(monthdayText[j][i].text) < tonumber(thisDate.thisDay) ) then
						monthdayText[j][i]:setFillColor(unpack(separateLineColor))
					else
						monthdayText[j][i]:setFillColor(unpack(wordColor))
						monthDaysBase[j][i]:addEventListener("touch", calendarDayListener)
					end
				else
					monthdayText[j][i].text = ""
				end

				-- 月曆線
				local verticalLine = display.newLine ( calendarGroup[j], monthDaysBase[j][i].x, monthDaysBase[j][i].y, monthDaysBase[j][i].x, monthDaysBase[j][i].y+monthDaysBase[j][i].contentHeight)
				verticalLine:setStrokeColor(unpack(separateLineColor))
				verticalLine.strokeWidth = 1
				if ( xBasement == 6 ) then
					local verticalLineBottom = display.newLine ( calendarGroup[j], monthDaysBase[j][i].x+monthDaysBaseEdge, monthDaysBase[j][i].y, monthDaysBase[j][i].x+monthDaysBaseEdge, monthDaysBase[j][i].y+monthDaysBase[j][i].contentHeight)
					verticalLineBottom:setStrokeColor(unpack(separateLineColor))
					verticalLineBottom.strokeWidth = 1

					local horizontalLine = display.newLine ( calendarGroup[j], -ox+(dateTitleBase.contentWidth-monthDaysBaseEdge*#weekDays)*0.5, monthDaysBase[j][i].y, screenW+ox-(dateTitleBase.contentWidth-monthDaysBaseEdge*#weekDays)*0.5, monthDaysBase[j][i].y)
					horizontalLine:setStrokeColor(unpack(separateLineColor))
					horizontalLine.strokeWidth = 1
					if ( totalWeek-yBasement == 1 ) then
						local horizontalLineBottom = display.newLine ( calendarGroup[j], -ox+(dateTitleBase.contentWidth-monthDaysBaseEdge*#weekDays)*0.5, monthDaysBase[j][i].y+monthDaysBase[j][i].contentHeight, screenW+ox-(dateTitleBase.contentWidth-monthDaysBaseEdge*#weekDays)*0.5, monthDaysBase[j][i].y+monthDaysBase[j][i].contentHeight)
						horizontalLineBottom:setStrokeColor(unpack(separateLineColor))
						horizontalLineBottom.strokeWidth = 1
						bottomLineNum = calendarGroup[j].numChildren
					end
				end
			end
			-- 不可選提示區
			local hintBase = display.newRect( cx, dateTitleBase.y+dateTitleBase.contentHeight+monthDaysBaseEdge*totalWeek, screenW+ox+ox, monthDaysBaseEdge*0.8)
			calendarGroup[j]:insert( bottomLineNum, hintBase)
			hintBase.anchorY = 0
			local circle = display.newCircle ( calendarGroup[j], backArrow.x+backArrow.contentWidth*0.5, hintBase.y+hintBase.contentHeight*0.5, 6)
			circle:setFillColor(unpack(separateLineColor))
			local hintText = display.newText({
				parent = calendarGroup[j],
				text = "不可選日期",
				font = getFont.font,
				fontSize = 12,
				x = circle.x+circle.contentWidth+ceil(10*wRate),
				y = circle.y,
			})
			hintText:setFillColor(unpack(wordColor))
			hintText.anchorX = 0
		end
	
		local groupNum
		local calendarBase = {}
		local function nextMonth()
			transition.to( calendarBase.now, { time = 300, x = (screenW+ox+ox)*-1, transition = easing.outExpo } )
			transition.to( calendarBase.next, { time = 300, x =  0, transition = easing.outExpo } )
			calendarBase.prev = calendarBase.now
			calendarBase.now = calendarBase.next
			
			if ( groupNum <= #calendarGroup ) then
				groupNum = groupNum + 1
			end

			if ( calendarGroup[groupNum+1] ) then
				calendarBase.next = calendarGroup[groupNum+1]
				calendarBase["next"].x = (screenW+ox+ox)
			end
		end
		
		local function prevMonth()
			transition.to( calendarBase.now, { time = 300, x = screenW+ox+ox, transition = easing.outExpo } )
			transition.to( calendarBase.prev, { time = 300, x = 0, transition = easing.outExpo } )
			calendarBase.next = calendarBase.now
			calendarBase.now = calendarBase.prev

			if ( groupNum > 1 ) then
				groupNum = groupNum - 1
			end

			if ( calendarGroup[groupNum-1] ) then
				calendarBase.prev = calendarGroup[groupNum-1]
				calendarBase["prev"].x = (screenW+ox+ox)*-1
			end
		end
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
					if ( tonumber(monthDateText.text) == tonumber(thisDate.thisMonth)+limitedAddedMonth and tonumber(yearDateText.text) == tonumber(thisDate.thisYear)) then
						rightArrow.isVisible = false
						rightArrowBtn.isVisible = false
					end
				end
				nextMonth()
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
					if ( tonumber(monthDateText.text) < tonumber(thisDate.thisMonth)+limitedAddedMonth and tonumber(yearDateText.text) == tonumber(thisDate.thisYear)) then
						rightArrow.isVisible = true
						rightArrowBtn.isVisible = true
					end
				end
				prevMonth()
			end
		end
	-- 按鈕-左右箭頭
	-- 左箭頭
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
	-- 右箭頭
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
	-- 月曆再定位 --
		if ( getFromScene == "goodPage" ) then
			groupNum = 1
			calendarBase.prev = nil
			calendarBase.now = calendarGroup[1]
			calendarBase.next = calendarGroup[2]
		elseif ( getFromScene == "shoppingCart" ) then
			local getDatePattern = "(%d+)/(%d+)/(%d+)"
			local year,month,day = getOrderDate:match(getDatePattern)
			groupNum = groupNumData[tonumber(month)]
			if ( tonumber(year) == tonumber(yearData[tonumber(month)]) ) then
				local dayId = dayData[groupNum][tonumber(day)]
				yearDateText.text = year
				monthDateText.text = month
				monthDaysBase[groupNum][dayId]:setFillColor(unpack(mainColor1))
				monthdayText[groupNum][dayId]:setFillColor(1)
				prevTarget = monthDaysBase[groupNum][dayId]
			end
			if ( groupNum == 1 ) then
				calendarBase.prev = nil
				calendarBase.now = calendarGroup[groupNum]
				calendarBase["now"].x = 0
				calendarBase.next = calendarGroup[groupNum+1]
				calendarBase["next"].x = (screenW+ox+ox)
				leftArrow.isVisible = false
				leftArrowBtn.isVisible = false
				rightArrow.isVisible = true
				rightArrowBtn.isVisible = true
			elseif( groupNum == limitedAddedMonth+1 ) then
				calendarBase.prev = calendarGroup[groupNum-1]
				calendarBase["prev"].x = (screenW+ox+ox)*-1
				calendarBase.now = calendarGroup[groupNum]
				calendarBase["now"].x = 0
				calendarBase.next = nil
				leftArrow.isVisible = true
				leftArrowBtn.isVisible = true
				rightArrow.isVisible = false
				rightArrowBtn.isVisible = false
			else
				calendarBase.prev = calendarGroup[groupNum-1]
				calendarBase["prev"].x = (screenW+ox+ox)*-1
				calendarBase.now = calendarGroup[groupNum]
				calendarBase["now"].x = 0
				calendarBase.next = calendarGroup[groupNum+1]
				calendarBase["next"].x = (screenW+ox+ox)
				leftArrow.isVisible = true
				leftArrowBtn.isVisible = true
				rightArrow.isVisible = true
				rightArrowBtn.isVisible = true
			end
		end
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