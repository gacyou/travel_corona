-----------------------------------------------------------------------------------------
--
-- TP_myTripPlan.lua
--
-----------------------------------------------------------------------------------------
local widget = require ("widget")
local composer = require ("composer")
local mainTabBar = require("mainTabBar")
local getFont = require("setFont")
local json = require("json")
local optionsTable = require("optionsTable")
local token = require("token")

local scene = composer.newScene()

local wordColor = { 99/255, 99/255, 99/255 }
local backgroundColor = { 245/255, 245/255, 245/255 }
local mainColor1 = { 6/255, 184/255, 217/255 }
local mainColor2 = { 7/255, 162/255, 192/255 }
local subColor1 = { 246/255, 148/255, 106/255}
local subColor2 = { 250/255, 128/255, 79/255}
local separateLineColor = { 204/255, 204/255, 204/255 }
local hintRed = { 247/255, 86/255, 86/255}

local ox, oy = math.abs(display.screenOriginX), math.abs(display.screenOriginY)
local cx, cy = display.contentCenterX, display.contentCenterY
local screenW, screenH = display.contentWidth, display.contentHeight
local wRate = screenW/1080
local hRate = screenH/1920

local titleListBoundary, titleListGroup
local setStatus = {}

local isLogin
if ( composer.getVariable("isLogin") ) then 
	isLogin = composer.getVariable("isLogin")
else
	isLogin = false
end

local ceil = math.ceil
local floor = math.floor

-- create()
function scene:create( event )
	local sceneGroup = self.view
	mainTabBar.myTabBarHidden()
	-- 按鈕監聽事件	
	local titleSelection, titleGroup,invitedGroup
	local function onBtnListener( event )
		local id = event.target.id
		if (id == "addTripBtn") then
			local options = { time = 200, effect = "fade"}
			composer.gotoScene("TP_myTripV6",options)				
		end
		return true
	end
	------------------- 抬頭元件 -------------------
	-- 白底
		local titleBase = display.newRect( cx, 0, screenW+ox+ox, floor(178*hRate))
		sceneGroup:insert(titleBase)
		titleBase.y = -oy+titleBase.contentHeight*0.5
		local titleBaseShadow = display.newImage( sceneGroup, "assets/s-down.png", titleBase.x, titleBase.y+titleBase.contentHeight*0.5)
		titleBaseShadow.anchorY = 0
		titleBaseShadow.width = titleBase.contentWidth
		titleBaseShadow.height = floor(titleBaseShadow.height*0.8)
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
			onRelease = function()
				composer.gotoScene( "TP_findPartner", { time = 200, effect = "fade"} )
				return true
			end,
		})
		sceneGroup:insert(backArrowNum,backBtn)
	-- 顯示文字-"我的旅程計畫"
		local titleText = display.newText({
			text = "我的旅程計畫",
			y = backBtn.y,
			font = getFont.font,
			fontSize = 14,
		})
		sceneGroup:insert(titleText)
		titleText:setFillColor(unpack(wordColor))
		titleText.anchorX = 0
		titleText.x = backArrow.x+backArrow.contentWidth+ceil(30*wRate)
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
	 		onRelease = function()
	 			if (setStatus["listBtn"] == "up") then 
	 				setStatus["listBtn"] = "down"
	 				transition.to( titleListGroup, { y = -titleListBoundary.contentHeight, time = 200 } )
	 				timer.performWithDelay( 200, function() titleListBoundary.isVisible = false ; end )
	 			else
	 				setStatus["listBtn"] = "up"
	 				titleListBoundary.isVisible = true
	 				transition.to( titleListGroup, { y = 0, time = 200 } )
	 			end
	 			return true
	 		end,
	 	})
	 	sceneGroup:insert( listIconNum, listBtn)
		setStatus["listBtn"] = "down"
	-- 主要scrollView
		local mainScrollView = widget.newScrollView({
			id = "mainScrollView",
			width = screenW+ox+ox,
			height = screenH+oy+oy-titleBase.contentHeight,
			horizontalScrollDisabled = true,
			isBounceEnabled = false,
			isLocked = true,
			backgroundColor = backgroundColor,
			x = cx,
			y = titleBase.y+titleBase.contentHeight*0.5,
		})
		sceneGroup:insert(mainScrollView)
		mainScrollView.anchorY = 0
		local mainScrollViewHeight = 0
		local mainScrollViewGroup = display.newGroup()
		mainScrollView:insert(mainScrollViewGroup)
	-- 陰影
		local titleBaseShadow = display.newImage( sceneGroup, "assets/s-down.png", titleBase.x, titleBase.y+titleBase.contentHeight*0.5)
		titleBaseShadow.anchorY = 0
		titleBaseShadow.width = titleBase.contentWidth
		titleBaseShadow.height = floor(titleBaseShadow.height*0.8)
	------------------- 旅程計畫元件 -------------------
	local planPath, planFile, planList = nil, nil, {}
	if ( isLogin == false ) then
		-- 無計畫
			local funloadBird = display.newImage( sceneGroup, "assets/img-bird.png" , cx, cy*0.75)
			funloadBird.anchorY = 1
			funloadBird.width = funloadBird.width*0.35
			funloadBird.height = funloadBird.height*0.35
		-- 顯示文字
			local noPlanText = display.newText({
				text = "你還沒有旅程計畫，快來建立吧!",
				font = getFont.font,
				fontSize = 14,
			})
			sceneGroup:insert(noPlanText)
			noPlanText:setFillColor(unpack(wordColor))
			noPlanText.anchorY = 0
			noPlanText.x = cx
			noPlanText.y = funloadBird.y+ceil(70*hRate)
		-- 按鈕-新增旅程計畫
			local addTripBtn = widget.newButton({
				id = "addTripBtn",
				defaultFile = "assets/btn-settlement.png",
				label = "新增旅程計畫",
				labelColor = { default = { 1, 1, 1}, over = { 1, 1, 1} },
				font = getFont.font,
				fontSize = 14,
				width =  (screenW+ox+ox)*0.5,
				height =  floor(80*0.4),
				onRelease = function()
					composer.gotoScene( "TP_myTripV6", { time = 200, effect = "fade" } )
					return true
				end,
			})
			sceneGroup:insert(addTripBtn)
			addTripBtn.x = cx
		 	addTripBtn.y = cy
	else
		local function getMyTripList( event )
			if (event.isError) then
				print("Network Error：", event.response)
			else
				--print ("RESPONSE: " .. event.response)
				local decodedData = json.decode(event.response)
				local tripList = decodedData["myTripList"]
				local datePattern = "(%d%d%d%d)(%d%d)(%d%d)%d+"
				if ( #tripList > 0 ) then
					-- 有計畫
					-- 顯示文字-提示文字
						local hintText = display.newText({
							text = "*在這裡你可以修改你所有的旅程計畫",
							font = getFont.font,
							fontSize = 10,
						})
						mainScrollViewGroup:insert(hintText)
						hintText:setFillColor(unpack(hintRed))
						hintText.anchorX = 0
						hintText.anchorY = 0
						hintText.x = ceil(49*wRate)
						hintText.y = floor(60*hRate)
					-- 計畫列表 --
					-- 陰影
						local planBaseTopShadow = display.newImage( mainScrollViewGroup, "assets/s-up.png", mainScrollView.contentWidth*0.5, hintText.y+ceil(50*hRate))
						planBaseTopShadow.anchorY = 1
						planBaseTopShadow.width = mainScrollView.contentWidth
						planBaseTopShadow.height = floor(planBaseTopShadow.height*0.3)
					-- 表格
						local endNum = #tripList
						for i = 1, endNum do
							-- 白底
							local planBase = display.newRect( mainScrollViewGroup, mainScrollView.contentWidth*0.5, hintText.y+ceil(110*hRate)*0.5, planBaseTopShadow.contentWidth, floor(200*hRate))
							planBase.anchorY = 0
							planBase.y = planBase.y+(planBaseTopShadow.contentHeight+planBase.contentHeight)*(i-1)
						
							-- 列表數字
							local listNumText = display.newText({
								text = i,
								font = getFont.font,
								fontSize = 10,
							})
							mainScrollViewGroup:insert(listNumText)
							listNumText:setFillColor(unpack(wordColor))
							listNumText.anchorX = 0
							listNumText.x = hintText.x
							listNumText.y = planBase.y+planBase.contentHeight*0.5
						
							-- 顯示文字-"旅行地點"
							local tripPointText = display.newText({
								text = "旅行地點："..tripList[i]["city"]["country"]["desc"].."-"..tripList[i]["city"]["desc"],
								font = getFont.font,
								fontSize = 10,
							})
							mainScrollViewGroup:insert(tripPointText)
							tripPointText:setFillColor(unpack(wordColor))
							tripPointText.anchorX = 0
							tripPointText.x = listNumText.x+ceil(60*wRate)
							tripPointText.y = planBase.y+planBase.contentHeight*0.2
						
							-- 顯示文字-"出發日期"
							local setStart = {}
							setStart["year"], setStart["month"], setStart["day"] = tripList[i]["start"]:match(datePattern)
							local startDateText = display.newText({
								text = "出發日期："..setStart["year"].."/"..setStart["month"].."/"..setStart["day"],
								font = getFont.font,
								fontSize = 10,
							})
							mainScrollViewGroup:insert(startDateText)
							startDateText:setFillColor(unpack(wordColor))
							startDateText.anchorX = 0
							startDateText.x = tripPointText.x
							startDateText.y = planBase.y+planBase.contentHeight*0.5
						
							-- 顯示文字-"結束日期"
							local setEnd = {}
							setEnd["year"], setEnd["month"], setEnd["day"] = tripList[i]["end"]:match(datePattern)
							local backDateText = display.newText({
								text = "結束日期："..setEnd["year"].."/"..setEnd["month"].."/"..setEnd["day"],
								font = getFont.font,
								fontSize = 10,
							})
							mainScrollViewGroup:insert(backDateText)
							backDateText:setFillColor(unpack(wordColor))
							backDateText.anchorX = 0
							backDateText.x = tripPointText.x
							backDateText.y = planBase.y+planBase.contentHeight*0.8
							
							-- 刪除計畫圖示
							local deleteIcon = display.newImage( mainScrollViewGroup, "assets/delete.png", planBase.contentWidth-ceil(49*wRate), planBase.y+planBase.contentHeight*0.5)
							deleteIcon.anchorX = 1
							deleteIcon.width = deleteIcon.width*0.07
							deleteIcon.height = deleteIcon.height*0.07
							-- 更改計畫圖示
							local modifyIcon = display.newImage( mainScrollViewGroup, "assets/pen.png", deleteIcon.x-deleteIcon.contentWidth-ceil(49*wRate), deleteIcon.y )
							modifyIcon.anchorX = 1
							modifyIcon.width = modifyIcon.width*0.07
							modifyIcon.height = modifyIcon.height*0.07
							
							-- 底部陰影
							if ( i == endNum ) then
								local planBaseBottomShadow = display.newImage( mainScrollViewGroup, "assets/s-down.png", planBaseTopShadow.x, planBase.y+planBase.contentHeight)
								planBaseBottomShadow.anchorY = 0
								planBaseBottomShadow.width = titleBase.contentWidth
								planBaseBottomShadow.height = floor(planBaseBottomShadow.height*0.3)
							end
							mainScrollViewHeight = planBase.y+planBase.contentHeight
						end

						local addTripBtn = widget.newButton({
							id = "addTripBtn",
							defaultFile = "assets/btn-settlement.png",
							label = "新增旅程計畫",
							labelColor = { default = { 1, 1, 1}, over = { 1, 1, 1} },
							font = getFont.font,
							fontSize = 14,
							width =  (screenW+ox+ox)*0.5,
							height =  floor(80*0.4),
							onRelease = function()
								composer.gotoScene( "TP_myTripV6", { time = 200, effect = "fade" } )
								return true
							end,
							x = planBaseTopShadow.x,
							y = mainScrollViewHeight+floor(65*hRate),
						})
						mainScrollViewGroup:insert(addTripBtn)
						addTripBtn.anchorY = 0
						mainScrollViewHeight = addTripBtn.y+addTripBtn.contentHeight+10
						if ( mainScrollViewHeight > mainScrollView.contentHeight ) then
							mainScrollView:setScrollHeight(mainScrollViewHeight)
							mainScrollView:setIsLocked( false, "vertical")
						end
				else
					-- 無計畫
						local funloadBird = display.newImage( sceneGroup, "assets/img-bird.png" , cx, cy*0.75)
						funloadBird.anchorY = 1
						funloadBird.width = funloadBird.width*0.35
						funloadBird.height = funloadBird.height*0.35
					-- 顯示文字
						local noPlanText = display.newText({
							text = "你還沒有旅程計畫，快來建立吧!",
							font = getFont.font,
							fontSize = 14,
						})
						sceneGroup:insert(noPlanText)
						noPlanText:setFillColor(unpack(wordColor))
						noPlanText.anchorY = 0
						noPlanText.x = cx
						noPlanText.y = funloadBird.y+ceil(70*hRate)
					-- 按鈕-新增旅程計畫
						local addTripBtn = widget.newButton({
							id = "addTripBtn",
							defaultFile = "assets/btn-settlement.png",
							label = "新增旅程計畫",
							labelColor = { default = { 1, 1, 1}, over = { 1, 1, 1} },
							font = getFont.font,
							fontSize = 14,
							width =  (screenW+ox+ox)*0.5,
							height =  floor(80*0.4),
							onRelease = function()
								composer.gotoScene( "TP_myTripV6", { time = 200, effect = "fade" } )
								return true
							end,
						})
						sceneGroup:insert(addTripBtn)
						addTripBtn.x = cx
					 	addTripBtn.y = cy
				end
			end
		end
		local accessToken
		if ( composer.getVariable("accessToken") ) then
			if ( token.getAccessToken() and token.getAccessToken() ~= composer.getVariable("accessToken") ) then
				composer.setVariable( "accessToken", token.getAccessToken() )
			end
			accessToken = composer.getVariable("accessToken")
		end
		local headers = {}
		headers["authorization"] = "Bearer "..accessToken
		local params = {}
		params.headers = headers
		local getMyTripListUrl = optionsTable.getTripPlanUrl
		network.request( getMyTripListUrl, "POST", getMyTripList, params)
	end
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
		composer.removeScene("TP_myTripPlan")
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