-----------------------------------------------------------------------------------------
--
-- editation.lua
--
-----------------------------------------------------------------------------------------

local composer = require("composer")
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

local ox, oy = math.abs(display.screenOriginX), math.abs(display.screenOriginY)
local cx, cy = display.contentCenterX, display.contentCenterY
local screenW, screenH = display.contentWidth, display.contentHeight
local wRate = screenW/1080
local hRate = screenH/1920

local messageGroup = display.newGroup()
local travelPrtnGroup = display.newGroup()
local msgTableView,trvlTableView,genderView
local infoTextField = {}
local partnerTextField = {}

local prevScene = composer.getSceneName("previous")

local function ceil( value )
	return math.ceil(value)
end

local function floor( value )
	return math.floor(value)
end

--	TabBar的按鍵監聽事件
local function onTabListener( event )
	local getTabId = event.target.id
	if( getTabId == "personalMsgBtn") then
		for i=1,#partnerTextField do
			if ( partnerTextField[i] ) then partnerTextField[i].isVisible = false end
		end
		for i=1,#infoTextField do
			if ( infoTextField[i] ) then infoTextField[i].isVisible = true end
		end
		travelPrtnGroup.isVisible = false
		messageGroup.isVisible = true
	end
	if (getTabId == "travelPtnBtn") then
		for i=1,#infoTextField do
			if ( infoTextField[i] ) then infoTextField[i].isVisible = false end
		end
		--[[
		for i=1,#partnerTextField do
			if ( partnerTextField[i] ) then partnerTextField[i].isVisible = true end
		end
		]]--
		messageGroup.isVisible = false
		travelPrtnGroup.isVisible = true	
	end
end

-- 按鈕的監聽事件
local function onBtnListener( event )
	local targetId = event.target.id
	if( targetId == "backBtn") then 
		local options = { effect = "slideLeft", time = 400}
		composer.gotoScene("personalcenter",options)
		--composer.hideOverlay("slideLeft",400)
	end
	if( targetId == "doneBtn") then
		local options = { effect = "slideLeft", time = 400}
		composer.gotoScene("personalcenter",options)
		--composer.hideOverlay("slideLeft",400)
	end
end

function scene:recover( event )
	for i=1,#partnerTextField do
		if (partnerTextField[i]) then partnerTextField[i].isVisible = true end
	end
end

function scene:create( event )
	local sceneGroup = self.view
	mainTabBar.myTabBarHidden()
------------------ 背景元件 -------------------
	local background = display.newRect( cx, cy, screenW+ox+ox, screenH+oy+oy)
	background:setFillColor(unpack(backgroundColor))
	sceneGroup:insert(background)
------------------ 抬頭元件 -------------------
-- 陰影
	local titleBaseShadow = display.newImageRect("assets/shadow0205.png", 320, floor(178*hRate))
	sceneGroup:insert(titleBaseShadow)
	titleBaseShadow.width = screenW+ox+ox
	titleBaseShadow.height = floor(178*hRate)
	titleBaseShadow.x = cx
	titleBaseShadow.y = -oy+titleBaseShadow.height*0.5
-- 白底
	local titleBase = display.newRect( cx, 0, screenW+ox+ox, titleBaseShadow.contentHeight*0.9)
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
		onRelease = onBtnListener,
	})
	sceneGroup:insert(backArrowNum,backBtn)
-- 顯示文字-"編輯"
	local titleText = display.newText({
		text = "編輯",
		font = getFont.font,
		fontSize = 14,
	})
	sceneGroup:insert(titleText)
	titleText:setFillColor(unpack(wordColor))
	titleText.anchorX = 0
	titleText.x = backArrow.x+backArrow.contentWidth+ceil(30*wRate)
	titleText.y = titleBase.y
-- 完成按鈕
	local doneBtn = widget.newButton({
		id = "doneBtn",
		x = screenW+ox-ceil(49*wRate),
		y = backBtn.y,
		width = screenW/16,
		height = screenH/16,
		label = "完成",
		labelColor = { default = mainColor1, over = mainColor2 },
		font = getFont.font,
		fontSize = 14,
		defaultFile= "assets/transparent.png",
		onRelease = onBtnListener,
	})
	sceneGroup:insert(doneBtn)
	doneBtn.anchorX = 1
------------------ 頭像元件 -------------------
-- 白底
	local photoBase = display.newRect( cx, titleBase.y+titleBase.contentHeight*0.5+floor(90*hRate), screenW+ox+ox, ceil(110*hRate))
	sceneGroup:insert(photoBase)
	photoBase.y = photoBase.y+photoBase.contentHeight*0.5
-- 頭像區	
	local editPhoto = display.newRoundedRect( -ox+ceil(38*wRate), photoBase.y-photoBase.contentHeight*0.5, floor(96*wRate), floor(96*wRate), 1)
	sceneGroup:insert(editPhoto)
	editPhoto.anchorX = 0
	editPhoto.anchorY = 0
	editPhoto.fill = {type = "image", filename = "assets/people.jpg"}
-- 顯示文字-"更換頭像"
	local photoText = display.newText({
		text = "更換頭像",
		x = editPhoto.x+editPhoto.contentWidth+ceil(30*wRate),
		y = photoBase.y,
		font = getFont.font,
		fontSize = 12,
	})
	sceneGroup:insert(photoText)
	photoText:setFillColor(unpack(wordColor))
	photoText.anchorX = 0
------------------ TabBar元件 -------------------
	local editTabBtns = {
		{
			id = "personalMsgBtn",
			label = "個人信息",
			labelColor = { default = mainColor1, over = mainColor2 },
			font = getFont.font,
			size = 12,
			labelYOffset = -6,
			defaultFile = "assets/btn-topborder-space.png", 
			overFile = "assets/btn-topborder.png",
			width = (screenW+ox+ox)*0.5, 
			height = floor(110*hRate), 
			selected = true,
			onPress = onTabListener
		},
		{
			id = "travelPtnBtn",
			label = "旅伴資料",
			labelColor = { default = mainColor1, over = mainColor2 },
			font = getFont.font,
			size = 12,
			labelYOffset = -6,
			defaultFile = "assets/btn-topborder-space.png", 
			overFile = "assets/btn-topborder.png",
			width = (screenW+ox+ox)*0.5, 
			height = floor(110*hRate), 
			onPress = onTabListener
		}
	}
	local editTabBar = widget.newTabBar{
		width = screenW+ox+ox, 
		height = ceil(110*hRate),
		backgroundFile = "assets/white.png",
		tabSelectedLeftFile = "assets/Left.png",
		tabSelectedMiddleFile = "assets/Middle.png",
		tabSelectedRightFile = "assets/Right.png",
		tabSelectedFrameWidth = 20,
		tabSelectedFrameHeight = floor(110*hRate), 
		buttons = editTabBtns,
	}
	editTabBar:setSelected(1)
	sceneGroup:insert(editTabBar)
	editTabBar.x = cx
	editTabBar.y = photoBase.y+photoBase.contentHeight*0.5+ceil(50*hRate)+editTabBar.contentHeight*0.5
------------------ 個人信息元件 -------------------
-- 顯示文字-姓名填寫提示訊息
	sceneGroup:insert(messageGroup)
	messageGroup.isVisible = false
	local msgBase = display.newRect( cx, editTabBar.y+editTabBar.contentHeight*0.5, screenW+ox+ox, screenH/40)
	messageGroup:insert(msgBase)
	msgBase.y = msgBase.y+msgBase.contentHeight*0.5
	local msgText = display.newText({
		text = "*中英文姓名可擇一填寫",
		x = backArrow.x,
		y = msgBase.y,
		font = getFont.font,
		fontSize = 10,
	})
	messageGroup:insert(msgText)
	msgText:setFillColor(unpack(separateLineColor))
	msgText.anchorX = 0
-- 個人信息的scrollView	
	local infomationScrollView = widget.newScrollView({
		id = "infomationScrollView",
		x = cx,
		y = msgBase.y+msgBase.contentHeight*0.5,
		width = screenW+ox+ox,
		height = screenH+oy+oy-(msgBase.y+msgBase.contentHeight*0.5),
		horizontalScrollDisabled = true,
		isBounceEnabled = false,
		backgroundColor = {1},
	})
	messageGroup:insert(infomationScrollView)
	infomationScrollView.anchorY = 0
------------------ infomationScrollView內部元件	 -------------------
	local infomationGroup = display.newGroup()
	infomationScrollView:insert(infomationGroup)
	local infoTitleOptions = { "中文名字", "中文姓氏", "英文名字", "英文姓氏", "性別","護照所屬國家/地區", "國家/地區代碼", "手機號碼", "電子信箱"}
	local infomationBaseWidth = screenW+ox+ox 
	local infomationBaseHeight = screenH/12
	local infomationBaseX = infomationBaseWidth*0.5
	local infomationBaseY = infomationBaseHeight*0.5
	local infoTitleText = {}
	local infoSelection = {}
	local infoArrow = {}
	local infoBaeLine = {}
	local infoNowTarget, infoPreTarget = nil
-- 選項背景監聽事件
	local function infoListener( event )
		local phase = event.phase
		local id = event.target.id
		if (phase == "ended") then
			if (infoNowTarget == nil and infoPreTarget == nil) then
				infoNowTarget = event.target
				infoTitleText[infoNowTarget.id]:setFillColor(unpack(mainColor1))
				infoBaeLine[infoNowTarget.id]:setStrokeColor(unpack(mainColor1))
				infoBaeLine[infoNowTarget.id].strokeWidth = 2
				if (infoArrow[infoNowTarget.id]) then infoArrow[infoNowTarget.id]:rotate(180) end

				infoPreTarget = infoNowTarget
				infoNowTarget = nil
			elseif (infoNowTarget == nil and infoPreTarget ~= nil) then
				if (event.target ~= infoPreTarget) then
					infoTitleText[infoPreTarget.id]:setFillColor(unpack(wordColor))
					infoBaeLine[infoPreTarget.id]:setStrokeColor(unpack(separateLineColor))
					infoBaeLine[infoPreTarget.id].strokeWidth = 1
					if (infoArrow[infoPreTarget.id]) then infoArrow[infoPreTarget.id]:rotate(180) end

					infoNowTarget = event.target
					infoTitleText[infoNowTarget.id]:setFillColor(unpack(mainColor1))
					infoBaeLine[infoNowTarget.id]:setStrokeColor(unpack(mainColor1))
					infoBaeLine[infoNowTarget.id].strokeWidth = 2
					if (infoArrow[infoNowTarget.id]) then infoArrow[infoNowTarget.id]:rotate(180) end

					infoPreTarget = infoNowTarget
					infoNowTarget = nil
				end
			end
		end
		return true
	end
-- 輸入欄監聽事件
	local function infoTextInput( event )
		local phase = event.phase
		local id = event.target.id
		if (phase == "began") then
			if (infoNowTarget == nil and infoPreTarget == nil) then
				infoNowTarget = event.target
				infoTitleText[infoNowTarget.id]:setFillColor(unpack(mainColor1))
				infoBaeLine[infoNowTarget.id]:setStrokeColor(unpack(mainColor1))
				infoBaeLine[infoNowTarget.id].strokeWidth = 2
				if (infoArrow[infoNowTarget.id]) then infoArrow[infoNowTarget.id]:rotate(180) end

				infoPreTarget = infoNowTarget
				infoNowTarget = nil
			elseif (infoNowTarget == nil and infoPreTarget ~= nil) then
				if (event.target ~= infoPreTarget) then
					infoTitleText[infoPreTarget.id]:setFillColor(unpack(wordColor))
					infoBaeLine[infoPreTarget.id]:setStrokeColor(unpack(separateLineColor))
					infoBaeLine[infoPreTarget.id].strokeWidth = 1
					if (infoArrow[infoPreTarget.id]) then infoArrow[infoPreTarget.id]:rotate(180) end

					infoNowTarget = event.target
					infoTitleText[infoNowTarget.id]:setFillColor(unpack(mainColor1))
					infoBaeLine[infoNowTarget.id]:setStrokeColor(unpack(mainColor1))
					infoBaeLine[infoNowTarget.id].strokeWidth = 2
					if (infoArrow[infoNowTarget.id]) then infoArrow[infoNowTarget.id]:rotate(180) end
					
					infoPreTarget = infoNowTarget
					infoNowTarget = nil
				end
			end
		end
	end
-- infomationScrollView內容
	for i=1,#infoTitleOptions do
		-- 白底
		local infoBase = display.newRect( infomationGroup, infomationBaseX, infomationBaseY, infomationBaseWidth, infomationBaseHeight)
		infoBase.id = i
		infoBase:addEventListener("touch",infoListener)
		-- 顯示文字-抬頭內容
		infoTitleText[i] = display.newText({
			text = infoTitleOptions[i],
			font = getFont.font,
			fontSize = 10,
			x = ceil(49*wRate),
			y = infoBase.y-(infomationBaseHeight*0.5),
		})
		infomationGroup:insert(infoTitleText[i])
		infoTitleText[i]:setFillColor(unpack(wordColor))
		infoTitleText[i].anchorX = 0
		infoTitleText[i].anchorY = 0
		-- 輸入欄位或是選單
		if (i ~= 5 and  i ~= 6 and i ~= 7) then
			infoTextField[i] = native.newTextField( infoTitleText[i].x, infoTitleText[i].y+infoTitleText[i].contentHeight+floor(16*hRate), infomationBaseWidth*0.7, infomationBaseHeight*0.4)
			infomationGroup:insert(infoTextField[i])
			infoTextField[i].anchorX = 0
			infoTextField[i].anchorY = 0
			infoTextField[i].id = i
			infoTextField[i].hasBackground = false
			infoTextField[i].font = getFont.font
			infoTextField[i]:resizeFontToFitHeight()
			infoTextField[i]:setSelection(0,0)
			infoTextField[i].isVisible = false
			if (i == 8) then
				infoTextField[i].placeholder = "請輸入您的手機號碼"
			end
			infoTextField[i]:addEventListener("userInput",infoTextInput)
		else
			infoSelection[i] = display.newText({
				text = "請選擇",
				font = getFont.font,
				fontSize = 12,
			})
			infomationGroup:insert(infoSelection[i])
			infoSelection[i]:setFillColor(unpack(wordColor))
			infoSelection[i].anchorX = 0
			infoSelection[i].anchorY = 0
			infoSelection[i].x = infoTitleText[i].x
			infoSelection[i].y = infoTitleText[i].y+infoTitleText[i].contentHeight+floor(12*hRate)
			-- 箭頭
			infoArrow[i] = display.newImage( infomationGroup, "assets/btn-dropdown.png", infomationBaseWidth*0.9, infoSelection[i].y+infoSelection[i].contentHeight*0.5)
			infoArrow[i].width = infoArrow[i].width*0.07
			infoArrow[i].height = infoArrow[i].height*0.07
		end
		--底線
		infoBaeLine[i] = display.newLine( ceil(49*wRate), infoBase.y+infoBase.contentHeight*0.3, screenW+ox-ceil(49*wRate), infoBase.y+infoBase.contentHeight*0.3)
		infomationGroup:insert(infoBaeLine[i])
		infoBaeLine[i].strokeWidth = 1
		infoBaeLine[i]:setStrokeColor(unpack(separateLineColor))
		infomationBaseY = infomationBaseY+(infomationBaseHeight)
		-- 必填區塊
		if (i == 4 or i == 5) then
			local base = display.newRect( infomationGroup, infomationBaseX, infoBase.y+infoBase.contentHeight*0.5, infomationBaseWidth, msgBase.contentHeight)
			base.anchorY = 0
			infomationBaseY = base.y+base.contentHeight+infomationBaseHeight*0.5
			local hintText = display.newText({
				text = "*必填",
				x = backArrow.x,
				y = base.y+base.contentHeight*0.5,
				font = getFont.font,
				fontSize = 10,
			})
			infomationGroup:insert(hintText)
			hintText:setFillColor(unpack(separateLineColor))
			hintText.anchorX = 0
		end
	end
------------------ 旅伴系統元件 -------------------
-- 白底
	sceneGroup:insert(travelPrtnGroup)
	travelPrtnGroup.isVisible = false
	local trvlPrtnSysBase = display.newRect(travelPrtnGroup, cx, editTabBar.y+editTabBar.contentHeight*0.5, screenW+ox+ox, screenH/12)
	trvlPrtnSysBase.anchorY = 0
-- 旅伴資料的scrollView	
	local partnerScrollView = widget.newScrollView({
		id = "partnerScrollView",
		x = cx,
		y = trvlPrtnSysBase.y+trvlPrtnSysBase.contentHeight,
		width = screenW+ox+ox,
		height = screenH+oy+oy-(trvlPrtnSysBase.y+trvlPrtnSysBase.contentHeight),
		horizontalScrollDisabled = true,
		isBounceEnabled = false,
		backgroundColor = {1},
	})
	travelPrtnGroup:insert(partnerScrollView)
	partnerScrollView.anchorY = 0
-- 旅伴資料的scrollView遮罩
	local partnerScrollViewCover = display.newRect(travelPrtnGroup,partnerScrollView.x,partnerScrollView.y,partnerScrollView.contentWidth,partnerScrollView.contentHeight)
	partnerScrollViewCover:setFillColor(1,1,1,0.7)
	partnerScrollViewCover.anchorY = 0
	partnerScrollViewCover:addEventListener("touch", function() return true ; end)
-- 顯示文字-"旅伴系統"
	local trvlPrtnSysText = display.newText({
		parent = travelPrtnGroup,
		text = "旅伴系統",
		font = getFont.font,
		fontSize = 12,
		x = -ox+ceil(49*wRate),
		y = trvlPrtnSysBase.y+trvlPrtnSysBase.contentHeight*0.5,
	}) 
	trvlPrtnSysText:setFillColor(unpack(wordColor))
	trvlPrtnSysText.anchorX = 0
-- 旅伴系統開關表單
	local switchOptions = { isOn = false, isAnimated = true }
	local options = {
		frames = {
			{ x=0, y=0, width=124, height=40 },
			{ x=0, y=50, width=40, height=40 },
			{ x=45, y=50, width=40, height=40 },
			{ x=129, y=0, width=80, height=40 }
		},
		sheetContentWidth = 209,
		sheetContentHeight = 90
	}
	local onOffSwitchSheet = graphics.newImageSheet( "assets/toggle.png", options )
-- 顯示文字-開關狀態
	local partnerSysOnOffText = display.newText({
		text = "關閉",
		font = getFont.font,
		fontSize = 12,
	})
	travelPrtnGroup:insert(partnerSysOnOffText)
	partnerSysOnOffText:setFillColor(unpack(wordColor))
	partnerSysOnOffText.anchorX = 1
-- 分隔線	
	trvlPrtnSysBaseLine = display.newLine(-ox, trvlPrtnSysBase.y+trvlPrtnSysBase.contentHeight, screenW+ox, trvlPrtnSysBase.y+trvlPrtnSysBase.contentHeight)
	travelPrtnGroup:insert(trvlPrtnSysBaseLine)
	trvlPrtnSysBaseLine.strokeWidth = 1
	trvlPrtnSysBaseLine:setStrokeColor(unpack(separateLineColor))
------------------ partnerScrollView內部元件 -------------------
	local partnerGroup = display.newGroup()
	partnerScrollView:insert(partnerGroup)
	local partnerTitleOptions = { "暱稱", "年齡", "國家", "性別", "通用口語","喜歡的旅遊方式", "想旅行的國家", "關於我"}
	local partnerBaseWidth = screenW+ox+ox 
	local partnerBaseHeight = screenH/12
	local partnerBaseX = partnerBaseWidth*0.5
	local partnerBaseY = partnerBaseHeight*0.5
	local partnerTitleText = {}
	local partnerSelection = {}
	local partnerArrow = {}
	local partnerBaeLine = {}
	local partnerNowTarget, partnerPreTarget = nil
-- 選項背景監聽事件
	local function partnerListener( event )
		local phase = event.phase
		local id = event.target.id
		if (phase == "ended") then
			if (partnerNowTarget == nil and partnerPreTarget == nil) then
				partnerNowTarget = event.target
				partnerTitleText[partnerNowTarget.id]:setFillColor(unpack(mainColor1))
				partnerBaeLine[partnerNowTarget.id]:setStrokeColor(unpack(mainColor1))
				partnerBaeLine[partnerNowTarget.id].strokeWidth = 2
				if (partnerArrow[partnerNowTarget.id]) then partnerArrow[partnerNowTarget.id]:rotate(180) end

				partnerPreTarget = partnerNowTarget
				partnerNowTarget = nil
			elseif (partnerNowTarget == nil and partnerPreTarget ~= nil) then
				if (event.target ~= partnerPreTarget) then
					partnerTitleText[partnerPreTarget.id]:setFillColor(unpack(wordColor))
					partnerBaeLine[partnerPreTarget.id]:setStrokeColor(unpack(separateLineColor))
					partnerBaeLine[partnerPreTarget.id].strokeWidth = 1
					if (partnerArrow[partnerPreTarget.id]) then partnerArrow[partnerPreTarget.id]:rotate(180) end

					partnerNowTarget = event.target
					partnerTitleText[partnerNowTarget.id]:setFillColor(unpack(mainColor1))
					partnerBaeLine[partnerNowTarget.id]:setStrokeColor(unpack(mainColor1))
					partnerBaeLine[partnerNowTarget.id].strokeWidth = 2
					if (partnerArrow[partnerNowTarget.id]) then partnerArrow[partnerNowTarget.id]:rotate(180) end

					partnerPreTarget = partnerNowTarget
					partnerNowTarget = nil
				end
			end
		end
		return true
	end
-- 輸入欄監聽事件
	local function partnerTextInput( event )
		local phase = event.phase
		local id = event.target.id
		if (phase == "began") then
			if (partnerNowTarget == nil and partnerPreTarget == nil) then
				partnerNowTarget = event.target
				partnerTitleText[partnerNowTarget.id]:setFillColor(unpack(mainColor1))
				partnerBaeLine[partnerNowTarget.id]:setStrokeColor(unpack(mainColor1))
				partnerBaeLine[partnerNowTarget.id].strokeWidth = 2
				if (partnerArrow[partnerNowTarget.id]) then partnerArrow[partnerNowTarget.id]:rotate(180) end

				partnerPreTarget = partnerNowTarget
				partnerNowTarget = nil
			elseif (partnerNowTarget == nil and partnerPreTarget ~= nil) then
				if (event.target ~= partnerPreTarget) then
					partnerTitleText[partnerPreTarget.id]:setFillColor(unpack(wordColor))
					partnerBaeLine[partnerPreTarget.id]:setStrokeColor(unpack(separateLineColor))
					partnerBaeLine[partnerPreTarget.id].strokeWidth = 1
					if (partnerArrow[partnerPreTarget.id]) then partnerArrow[partnerPreTarget.id]:rotate(180) end

					partnerNowTarget = event.target
					partnerTitleText[partnerNowTarget.id]:setFillColor(unpack(mainColor1))
					partnerBaeLine[partnerNowTarget.id]:setStrokeColor(unpack(mainColor1))
					partnerBaeLine[partnerNowTarget.id].strokeWidth = 2
					if (partnerArrow[partnerNowTarget.id]) then partnerArrow[partnerNowTarget.id]:rotate(180) end

					partnerPreTarget = partnerNowTarget
					partnerNowTarget = nil
				end
			end
		end
	end
-- partnerScrollView內容
	for i=1,#partnerTitleOptions do
		-- 必填區塊
		if (i == 1) then
			local base = display.newRect( partnerGroup, partnerBaseX, floor(20*hRate), partnerBaseWidth, screenH/40)
			base.anchorY = 0
			partnerBaseY = base.y+base.contentHeight+partnerBaseHeight*0.5
			local hintText = display.newText({
				text = "*必填",
				x = backArrow.x,
				y = base.y+base.contentHeight*0.5,
				font = getFont.font,
				fontSize = 10,
			})
			partnerGroup:insert(hintText)
			hintText:setFillColor(unpack(separateLineColor))
			hintText.anchorX = 0
		end		
		-- 白底
		local partnerBase = display.newRect( partnerGroup, partnerBaseX, partnerBaseY, partnerBaseWidth, partnerBaseHeight)
		partnerBase.id = i
		partnerBase:addEventListener("touch",partnerListener)
		-- 顯示文字-抬頭內容
		partnerTitleText[i] = display.newText({
			text = partnerTitleOptions[i],
			font = getFont.font,
			fontSize = 10,
			x = ceil(49*wRate),
			y = partnerBase.y-(infomationBaseHeight*0.5),
		})
		partnerGroup:insert(partnerTitleText[i])
		partnerTitleText[i]:setFillColor(unpack(wordColor))
		partnerTitleText[i].anchorX = 0
		partnerTitleText[i].anchorY = 0
		-- 輸入欄位或是選單
		if (i ~= 3 and  i ~= 4 and i ~= 6) then
			partnerTextField[i] = native.newTextField( partnerTitleText[i].x, partnerTitleText[i].y+partnerTitleText[i].contentHeight+floor(16*hRate), partnerBaseWidth*0.7, partnerBaseHeight*0.4)
			partnerGroup:insert(partnerTextField[i])
			partnerTextField[i].anchorX = 0
			partnerTextField[i].anchorY = 0
			partnerTextField[i].id = i
			partnerTextField[i].hasBackground = false
			partnerTextField[i].font = getFont.font
			partnerTextField[i]:resizeFontToFitHeight()
			partnerTextField[i]:setSelection(0,0)
			partnerTextField[i].isVisible = false
			if (i == 5) then
				partnerTextField[i].placeholder = "請填寫您的通用口語"
			elseif (i == 7) then
				partnerTextField[i].placeholder = "請填寫於此"
			elseif (i == 8) then
				partnerTextField[i].placeholder = "關於我..."
			end
			partnerTextField[i]:addEventListener("userInput",partnerTextInput)
		else
			partnerSelection[i] = display.newText({
				text = "請選擇",
				font = getFont.font,
				fontSize = 12,
			})
			partnerGroup:insert(partnerSelection[i])
			partnerSelection[i]:setFillColor(unpack(wordColor))
			partnerSelection[i].anchorX = 0
			partnerSelection[i].anchorY = 0
			partnerSelection[i].x = partnerTitleText[i].x
			partnerSelection[i].y = partnerTitleText[i].y+partnerTitleText[i].contentHeight+floor(12*hRate)
			-- 箭頭
			partnerArrow[i] = display.newImage( partnerGroup, "assets/btn-dropdown.png", partnerBaseWidth*0.9, partnerSelection[i].y+partnerSelection[i].contentHeight*0.5)
			partnerArrow[i].width = partnerArrow[i].width*0.07
			partnerArrow[i].height = partnerArrow[i].height*0.07
		end		
		--底線
		partnerBaeLine[i] = display.newLine( ceil(49*wRate), partnerBase.y+partnerBase.contentHeight*0.3, screenW+ox-ceil(49*wRate), partnerBase.y+partnerBase.contentHeight*0.3)
		partnerGroup:insert(partnerBaeLine[i])
		partnerBaeLine[i].strokeWidth = 1
		partnerBaeLine[i]:setStrokeColor(unpack(separateLineColor))

		partnerBaseY = partnerBaseY+partnerBaseHeight		
	end
	local checkboxOptions = {
		frames = 
		{
			{
				x = 0,
				y = 0,
				width = 91,
				height = 91
			},
			{
				x = 116,
				y = 0,
				width = 91,
				height = 91
			},
		}
	}
	local checkboxSheet = graphics.newImageSheet("assets/checkbox.png",checkboxOptions)
-- 我同意checkBox
	local agreeCheckBox = widget.newSwitch({
			id = "agreeCheckBox",
			style = "checkbox",
			x = ceil(50*wRate),
			y = partnerBaseY,
			sheet = checkboxSheet,
			frameOff = 2,
			frameOn = 1
		})
	partnerGroup:insert(agreeCheckBox)
	agreeCheckBox.anchorX = 0
	agreeCheckBox:scale(0.4,0.4)
-- 顯示文字-"我同意"
	local agreeText = display.newText({
		parent = partnerGroup,
		text = "我同意",
		font = getFont.font,
		fontSize = 12,
		x = agreeCheckBox.x+agreeCheckBox.contentWidth+ceil(20*wRate),
		y = agreeCheckBox.y
	})
	agreeText:setFillColor(unpack(wordColor))
	agreeText.anchorX = 0
-- 顯示文字-"<旅伴免責聲明>"
	local disclaimeText = display.newText({
		parent = partnerGroup,
		text = "<旅伴免責聲明>",
		font = getFont.font,
		fontSize = 12,
		x = agreeText.x+agreeText.contentWidth,
		y = agreeText.y
	})
	disclaimeText:setFillColor(unpack(subColor2))
	disclaimeText.anchorX = 0
	disclaimeText:addEventListener("touch", function (event)
			local phase = event.phase
			if (phase == "ended") then
				for i=1,#partnerTextField do
					if (partnerTextField[i]) then partnerTextField[i].isVisible = false end
				end
				local options = { isModal = true, effect = "zoomOutIn", time = 400 }
				composer.showOverlay( "disclaimer",options)
			end
			return true
	end)
------------------ 開關元件 -------------------
-- 開關監聽事件
	local function partnerSysSwitchListener( event )
		local phase = event.phase
		if (phase == "ended") then
			--print(event.target.isOn)
			if (event.target.isOn == true) then
				partnerSysOnOffText.text = "開啟"
				partnerSysOnOffText:setFillColor(unpack(mainColor1))
				partnerScrollViewCover.isVisible = false
				for i=1, #partnerTitleOptions do
					if ( partnerTextField[i] ) then partnerTextField[i].isVisible = true end
				end
			else
				partnerSysOnOffText.text = "關閉"
				partnerSysOnOffText:setFillColor(unpack(wordColor))
				partnerScrollViewCover.isVisible = true
				for i=1, #partnerTitleOptions do
					if ( partnerTextField[i] ) then partnerTextField[i].isVisible = false end
				end				
			end		
		end
		return true
	end
-- 旅伴系統開關	
	local partnerSysSwitch = widget.newSwitch({
			id = "partnerSysSwitch",
			style = "onOff",
			onEvent = partnerSysSwitchListener,
			sheet = onOffSwitchSheet,
			onOffBackgroundFrame = 1,
			onOffBackgroundWidth = 120,
			onOffBackgroundHeight = 40,
			onOffMask = "assets/mask.png",
			onOffHandleDefaultFrame = 2,
			onOffHandleOverFrame = 3,
			onOffOverlayFrame = 4,
			onOffOverlayWidth = 80,
			onOffOverlayHeight = 40,
			offDirection = "left",
		})
	travelPrtnGroup:insert(partnerSysSwitch)
	partnerSysSwitch:scale(0.6,0.6)
	partnerSysSwitch.anchorX = 1
	partnerSysSwitch.x = (screenW+ox)-ceil(partnerSysSwitch.contentWidth*0.3)-ceil(45*wRate)
	partnerSysSwitch.y = trvlPrtnSysBase.y+trvlPrtnSysBase.contentHeight*0.5
	partnerSysSwitch:setState(switchOptions)
	-- 開關狀態文字定位
	partnerSysOnOffText.x = partnerSysSwitch.x-ceil(partnerSysSwitch.contentWidth*0.3)-ceil(30*wRate)
	partnerSysOnOffText.y = partnerSysSwitch.y
end

function scene:show( event )
	local sceneGroup = self.view
	local phase = event.phase
	if phase == "will" then
		messageGroup.isVisible = true
		for i=1,#infoTextField do
			if ( infoTextField[i] ) then infoTextField[i].isVisible = true end
		end	
	elseif phase == "did" then
	end	
end

function scene:hide( event )
	local sceneGroup = self.view
	local phase = event.phase
	if event.phase == "will" then
	elseif phase == "did" then
		composer.removeScene("editation")
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