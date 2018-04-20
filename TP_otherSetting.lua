-----------------------------------------------------------------------------------------
--
-- TP_otherSetting.lua
--
-----------------------------------------------------------------------------------------
local widget = require ("widget")
local composer = require ("composer")
local mainTabBar = require("mainTabBar")
local getFont = require("setFont")
local json = require("json")
local optionsTable = require("optionsTable")
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

local titleSelection, titleGroup, memberSearchGroup
local setStatus = {}
local nowTarget, prevTarget
local listOptions = { "findPartner", "myInformation", nil, "myAlbum", nil, "memberSearch", "otherSetting", "partnerDisclaimer" }

local getMsgSwitch, bePartnerSwitch
local switchOptions = { isOn = false, isAnimated = true }
local msgSwitchOption, ptnSwitchOption = {}, {}

local ceil = math.ceil
local floor = math.floor

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

local userLoginInfo = composer.getVariable("userLoginInfo")
-- create()
function scene:create( event )
    local sceneGroup = self.view
	mainTabBar.myTabBarHidden()
	-- 讀檔/建檔 --
	local list = {}
	local switchFileName = userLoginInfo.id.."_TP_othersetting.data"
	local switchPath = system.pathForFile( switchFileName, system.DocumentsDirectory )
	local switchFile = io.open( switchPath, "r" )
	if not switchFile then
		switchFile = io.open( switchPath, "w" )
		--switchFile:write("isOn=false\n", "isOn=false")
		list = { getMessage = false, beCollected = false }
		switchFile:write( json.encode(list) )
		io.close(switchFile)
		switchFile = nil
		switchFile = io.open( switchPath, "r" )
	end
	--[[
	local contents = switchFile:read("*l")
	local count = 1
	while (contents ~= nil) do
		list[count] = contents
		count = count+1
		contents = switchFile:read("*l")
	end
	--]]
	local contents = switchFile:read("*a")
	list = json.decode(contents)
	io.close(switchFile)
	switchFile = nil

	--local contentPattern = "%a+%=(.+)"
	--local getMsgIsOn = list[1]:match(contentPattern)
	local getMsgIsOn = list["getMessage"]
	if ( not getMsgIsOn ) then
		msgSwitchOption = { isOn = false, isAnimated = false }
	else
		msgSwitchOption = { isOn = true, isAnimated = false }
	end
	local getPtnIsOn = list["beCollected"]
	if ( not getPtnIsOn ) then
		ptnSwitchOption = { isOn = false, isAnimated = false }
	else
		ptnSwitchOption = { isOn = true, isAnimated = false }
	end
	------------------- 抬頭元件 -------------------
	-- 白底
		local titleBase = display.newRect(0, 0, screenW+ox+ox, floor(178*hRate))
		sceneGroup:insert(titleBase)
		titleBase.x = cx
		titleBase.y = -oy+titleBase.height*0.5
	-- 陰影
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
				options = { time = 300, effect = "fade"}
				composer.gotoScene("TP_findPartner", options)
			end,
		})
		sceneGroup:insert(backArrowNum,backBtn)
	-- 顯示文字-"其他設定"
		local titleText = display.newText({
			text = "其他設定",
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
		listIcon.width = listIcon.width*0.07
		listIcon.height = listIcon.height*0.07
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
	 				transition.to(titleListGroup,{ y = -titleListBoundary.contentHeight, time = 200})
	 				timer.performWithDelay(200, function() titleListBoundary.isVisible = false ;end)
	 			else
	 				setStatus["listBtn"] = "up"
	 				titleListBoundary.isVisible = true
	 				transition.to(titleListGroup,{ y = 0, time = 200})
	 			end
	 		end,
	 	})
	 	sceneGroup:insert(listIconNum,listBtn)
	 	setStatus["listBtn"] = "down"
	------------------- 推播開關 -------------------
	-- 收到旅伴留言開關 --
	-- 白底
		local getMsgSwitchWhiteBase = display.newRect( 0, 0, screenW+ox+ox, 200*hRate)
		sceneGroup:insert(getMsgSwitchWhiteBase)
		getMsgSwitchWhiteBase.x = cx
		getMsgSwitchWhiteBase.y = titleBase.y+(titleBase.contentHeight/2)+ceil(20*hRate)+(getMsgSwitchWhiteBase.contentHeight/2)
	-- 顯示文字-"收到其他旅伴留言時以app推播通知"
		local getMsgText = display.newText({
			text = "收到其他旅伴留言時以app推播通知",
			font = getFont.font,
			fontSize = 12,
		})
		sceneGroup:insert(getMsgText)
		getMsgText:setFillColor(unpack(wordColor))
		getMsgText.anchorX = 0
		getMsgText.x = -ox+ceil(55*wRate)
		getMsgText.y = getMsgSwitchWhiteBase.y
	-- 顯示文字-開關狀態
		local getMsgOnOffText = display.newText({
			text = "",
			font = getFont.font,
			fontSize = 12,
		})
		sceneGroup:insert(getMsgOnOffText)
		getMsgOnOffText.anchorX = 1
		if ( not getMsgIsOn ) then
			getMsgOnOffText.text = "關閉"
			getMsgOnOffText:setFillColor(unpack(wordColor))
		else
			getMsgOnOffText.text = "開啟"
			getMsgOnOffText:setFillColor(unpack(mainColor1))
		end
	-- 開關按鈕
		getMsgSwitch = widget.newSwitch({
				id = "getMsgSwitch",
				style = "onOff",
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
				onEvent = function( event )
					local phase = event.phase
					if (phase == "ended") then
						if (event.target.isOn == true) then
							getMsgOnOffText.text = "開啟"
							getMsgOnOffText:setFillColor(unpack(mainColor1))	
						else
							getMsgOnOffText.text = "關閉"
							getMsgOnOffText:setFillColor(unpack(wordColor))
						end
					end
				end,
			})
		sceneGroup:insert(getMsgSwitch)
		getMsgSwitch:scale(0.6,0.6)
		getMsgSwitch.anchorX = 1
		getMsgSwitch.x = (screenW+ox)-ceil(getMsgSwitch.contentWidth*0.3)-ceil(35*wRate)
		getMsgSwitch.y = getMsgSwitchWhiteBase.y
		getMsgSwitch:setState(msgSwitchOption)
	
		getMsgOnOffText.x = getMsgSwitch.x-ceil(getMsgSwitch.contentWidth*0.3)-ceil(30*wRate)
		getMsgOnOffText.y = getMsgSwitchWhiteBase.y
	
	-- 收到旅伴收藏開關 --
	-- 白底
		local bePartnerSwitchWhiteBase = display.newRect( 0, 0, screenW+ox+ox, 200*(hRate))
		sceneGroup:insert(bePartnerSwitchWhiteBase)
		bePartnerSwitchWhiteBase.x = cx
		bePartnerSwitchWhiteBase.y = getMsgSwitchWhiteBase.y+(getMsgSwitchWhiteBase.contentHeight/2)+(bePartnerSwitchWhiteBase.contentHeight/2)
	-- 顯示文字-"收到其他旅伴收藏時以app推播通知"
		local bePartnerText = display.newText({
			text = "收到其他旅伴收藏時以app推播通知",
			font = getFont.font,
			fontSize = 12,
		})
		sceneGroup:insert(bePartnerText)
		bePartnerText:setFillColor(unpack(wordColor))
		bePartnerText.anchorX = 0
		bePartnerText.x = -ox+ceil(55*wRate)
		bePartnerText.y = bePartnerSwitchWhiteBase.y
	-- 顯示文字-開關狀態
		local bePartnerOnOffText = display.newText({
			text = "",
			font = getFont.font,
			fontSize = 12,
		})
		sceneGroup:insert(bePartnerOnOffText)
		bePartnerOnOffText.anchorX = 1
		local ptnSwitchText
		if ( not getPtnIsOn ) then
			bePartnerOnOffText.text = "關閉"
			bePartnerOnOffText:setFillColor(unpack(wordColor))
		else
			bePartnerOnOffText.text = "開啟"
			bePartnerOnOffText:setFillColor(unpack(mainColor1))
		end
	-- 開關按鈕	
		bePartnerSwitch = widget.newSwitch({
			id = "bePartnerSwitch",
			style = "onOff",
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
			onEvent = function( event )
				local phase = event.phase
				if (phase == "ended") then
					if (event.target.isOn == true) then 
						bePartnerOnOffText.text = "開啟"
						bePartnerOnOffText:setFillColor(unpack(mainColor1))
					else
						bePartnerOnOffText.text = "關閉"
						bePartnerOnOffText:setFillColor(unpack(wordColor))			
					end
				end
			end,
		})
		sceneGroup:insert(bePartnerSwitch)
		bePartnerSwitch:scale(0.6,0.6)
		bePartnerSwitch.anchorX = 1
		bePartnerSwitch.x = (screenW+ox)-ceil(bePartnerSwitch.contentWidth*0.3)-ceil(35*wRate)
		bePartnerSwitch.y = bePartnerSwitchWhiteBase.y
		bePartnerSwitch:setState(ptnSwitchOption)

		bePartnerOnOffText.x = bePartnerSwitch.x-ceil(bePartnerSwitch.contentWidth*0.3)-ceil(30*wRate) 
		bePartnerOnOffText.y = bePartnerSwitchWhiteBase.y
	
	-- 分隔線
		local separateLine = display.newLine( -ox, getMsgSwitchWhiteBase.y+getMsgSwitchWhiteBase.contentHeight*0.5, screenW+ox, getMsgSwitchWhiteBase.y+getMsgSwitchWhiteBase.contentHeight*0.5)
		sceneGroup:insert(separateLine)
		separateLine:setStrokeColor(unpack(separateLineColor))
		separateLine.strokeWidth = 1
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
		local switchFileName = userLoginInfo.id.."_TP_othersetting.data"
		local switchPath = system.pathForFile( switchFileName, system.DocumentsDirectory )
		local switchFile = io.open( switchPath, "w" )
		local list = { getMessage = getMsgSwitch.isOn, beCollected = bePartnerSwitch.isOn }
		--switchFile:write( state1.."\n", state2)
		switchFile:write(json.encode(list))
		io.close(switchFile)
		switchFile = nil
		composer.removeScene("TP_otherSetting")
	elseif ( phase == "did" ) then
		
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