-----------------------------------------------------------------------------------------
--
-- PC_personalEdit.lua
--
-----------------------------------------------------------------------------------------

local composer = require("composer")
local widget = require("widget")
local getFont = require("setFont")
local mainTabBar = require("mainTabBar")
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
local hintAlertColor = { 247/255, 86/255, 86/255}

local ox, oy = math.abs(display.screenOriginX), math.abs(display.screenOriginY)
local cx, cy = display.contentCenterX, display.contentCenterY
local screenW, screenH = display.contentWidth, display.contentHeight
local wRate = screenW/1080
local hRate = screenH/1920

local infomationGroup = display.newGroup()
local travelMateGroup = display.newGroup()

local infoTitleOptions = { "中文名字", "中文姓氏", "英文名字", "英文姓氏", "性別", "洲別","所屬國家", "國家/地區代碼", "手機號碼", "電子信箱"}
local infoText, infoTextField, infoTextReverseTable = {}, {}, {}
local infoHintBase, infoHintText = {}, {}

local partnerTitleOptions = { "暱稱", "年齡", "性別", "洲別", "國家", "通用口語","喜歡的旅遊方式", "想旅行的國家", "關於我"}
local partnerText, partnerTextField, ptnrTextReverseTable = {}, {}, {}
local ptnrHintBase, ptnrHintText = {}, {}

local continentOptions = { "亞洲", ["亞洲"] = 1, "歐洲", ["歐洲"] = 2, "北美洲", ["北美洲"] = 5, "南美洲", ["南美洲"] = 7 }
local continentJson = json.encode( continentOptions )

local toMate = false
if ( composer.getVariable("toMate") ) then
	toMate = composer.getVariable("toMate")
end

local userLoginInfo
if ( composer.getVariable("userLoginInfo") ) then
	userLoginInfo = composer.getVariable("userLoginInfo")
end

local ceil = math.ceil
local floor = math.floor

function scene:recover( event )
	for i = 1, #partnerTitleOptions do
		if (partnerTextField[i]) then partnerTextField[i].isVisible = true end
	end
end

function scene:create( event )
	local sceneGroup = self.view
	mainTabBar.myTabBarHidden()
	local setStatus = {}
	local pattern = "%a+%=(.+)"
	local setCountry
	local ptnrSwitch
	-- 選單參數 --
	local frameName = "assets/shadow-320480-paper.png"
	local frameWidth = (screenW+ox+ox)*0.8
	local optionBaseWidth = frameWidth*0.95
	local optionBaseHeight = screenH/16
	local optionPadding = optionBaseHeight/3
	local infoSelection, ptnrList, partnerSelection = {}, {}, {}
	local genderOptions = { "男", "女" }
	--local continentOptions = { {"亞洲","Asia"}, {"歐洲","Europe"}, {"北美洲","NorthAmerica"}, {"南美洲","SouthAmerica"} }
	--[[
	local countryOptions = { 
		Asia = { "台灣", "日本", "印尼", "汶萊", "柬埔寨", "哈薩克", "吉爾吉斯", "烏茲別克", "不丹", "菲律賓"},
		Europe = { "比利時", "奧地利", "捷克", "葡萄牙", "西班牙", "法國", "德國", "瑞士"},
		NorthAmerica = { "敬請期待" },
		SouthAmerica = { "敬請期待" }
	}
	--]]
	local areaCode = { "台灣/+886", "香港/+852", "澳門/+853", "中國大陸/+86", "日本/+81","韓國/+82", "美國/+1" }
	local travelMethod = { "自助旅行", "跟團" }
	local genderGroup = display.newGroup()
	local continentGroup = display.newGroup()
	local countryGroup = display.newGroup()
	local areaCodeGroup = display.newGroup()
	local ptnrGenderGroup = display.newGroup()
	local ptnrcontinentGroup = display.newGroup()
	local ptnrCountryGroup = display.newGroup()
	local travelMethodGroup = display.newGroup()
	------------------ 讀檔 -------------------
	-- 個人訊息資料讀檔 --
		local infoFileName = userLoginInfo.id.."_PC_infomation.data" 
		local infoPath = system.pathForFile( infoFileName, system.DocumentsDirectory )
		local infoFile = io.open(infoPath, "r")
		local infoList = {}
		if not infoFile then
			print("No Personal Infomation File")
			for i = 1, #infoTitleOptions do
				infoList[i] = "N/A"
				if ( i == 10 and userLoginInfo.email ) then
					infoList[i] = "Email="..userLoginInfo.email
				end
			end
		else
			local contents = infoFile:read("*l")
			local count = 1
			while (contents ~= nil) do
				infoList[count] = contents
				count = count+1
				contents = infoFile:read("*l")
			end
			--local contents = infoFile:read("*a")
			--infoList = contents
			io.close(infoFile)
			infoFile = nil
		end
	-- 旅伴資料讀檔 --
		local ptnrFileName = userLoginInfo.id.."_PC_travelPartner.data"
		local ptnrPath = system.pathForFile( ptnrFileName, system.DocumentsDirectory )
		local ptnrFile = io.open(ptnrPath, "r")
		if not ptnrFile then
			print("No Travel Partner File")
			for i = 1, #partnerTitleOptions do
				ptnrList[i] = "N/A"
			end
		else
			local contents = ptnrFile:read("*l")
			local count = 1
			while (contents ~= nil) do
				ptnrList[count] = contents
				count = count+1
				contents = ptnrFile:read("*l")
			end
			--local contents = ptnrFile:read("*a")
			--ptnrList = contents
			io.close(ptnrFile)
			ptnrFile = nil
		end
	-- 旅伴開關讀檔 --
		local getSwitchIsOn
		--local switchFileName = userLoginInfo.id.."_PC_travelPartnerSwitch.txt"
		local switchFileName = userLoginInfo.id.."_PC_travelPartnerSwitch.data"
		local switchPath = system.pathForFile( switchFileName, system.DocumentsDirectory )
		local switchFile = io.open( switchPath, "r" )
		--local switchList = {}
		if not switchFile then
			switchFile = io.open( switchPath, "w")
			local switchTable = { mate = false }
			--switchFile:write( "isOn=false" )
			switchFile:write( json.encode(switchTable) )
			io.close(switchFile)
			switchFile = nil
			switchFile = io.open( switchPath, "r")
		end
		--[[
		local contents = switchFile:read("*l")		
		local count = 1
		while (contents ~= nil) do
			switchList[count] = contents
			count = count+1
			contents = switchFile:read("*l")
		end
		--]]
		local contents = switchFile:read("*a")
		getSwitchIsOn = json.decode(contents)
		io.close( switchFile )
		switchFile = nil
		--getSwitchIsOn = switchList[1]:match(pattern)
		local thisSwitchStatus = getSwitchIsOn["mate"]
	------------------ 抬頭元件 -------------------
	-- 陰影
		local titleBaseShadow = display.newImageRect("assets/shadow0205.png", screenW+ox+ox, floor(200*hRate))
		sceneGroup:insert(titleBaseShadow)
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
			onRelease = function ( event )
				local switchChanged, ptnrChanged, infoChanged
				if ( infoList and ptnrList and getSwitchIsOn ) then
					-- 開關狀態異動
					switchChanged = false
					if ( ptnrSwitch.isOn ~= thisSwitchStatus ) then
						switchChanged = true
					end
					-- 旅伴資料有異動
					ptnrChanged = false
					if ( getSwitchIsOn[mate] ) then
						for i = 1, #ptnrList do
							if ( partnerTextField[i] ) then
								if ( ptnrList[i]:match(pattern) ) then
									if ( partnerTextField[i].text ~= ptnrList[i]:match(pattern) ) then
										ptnrChanged = true
										break
									end
								else
									if ( partnerTextField[i].text ~= "" ) then
										ptnrChanged = true
										break
									end
								end
							elseif ( partnerSelection[i] ) then
								if ( ptnrList[i]:match(pattern) ) then
									if ( partnerSelection[i].text ~= ptnrList[i]:match(pattern) ) then
										ptnrChanged = true
										break
									end
								else
									if ( partnerSelection[i].text ~= "請選擇" ) then
										ptnrChanged = true
										break
									end
								end
							end
						end
					end
					-- 個人資料有異動
					infoChanged = false
					for i = 1, #infoList do
						if ( infoTextField[i] ) then
							if ( infoList[i]:match(pattern) ) then
								if ( infoTextField[i].text ~= infoList[i]:match(pattern) ) then
									infoChanged = true
									break
								end
							else
								if ( infoTextField[i].text ~= "" ) then
									infoChanged = true
									break
								end
							end
						elseif ( infoSelection[i] ) then
							if ( infoList[i]:match(pattern) ) then
								if ( infoSelection[i].text ~= infoList[i]:match(pattern) ) then
									infoChanged = true
									break
								end
							else
								if ( infoSelection[i].text ~= "請選擇" ) then
									print(i)
									infoChanged = true
									break
								end
							end
						end
					end
				end
				
				if ( infoChanged == true or ptnrChanged == true or switchChanged == true ) then
					native.showAlert( "", "資料異動未儲存，是否離開?", { "確定", "取消" },
						function ( event )
							if ( event.action == "clicked" ) then
								local i = event.index
								if ( i == 1) then
									composer.gotoScene("PC_personalCenter", { effect = "slideLeft", time = 300} )
								end
							end
						end)
				else
					composer.gotoScene("PC_personalCenter", { effect = "slideLeft", time = 300} )
				end
				return true
			end,
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
		editPhoto.fill = { type = "image", filename = "assets/wow.jpg" }
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
	-- TabBar的按鍵監聽事件
		local infomationScrollView
		local defaultInfoView
		local function onTabListener( event )
			local getTabId = event.target.id
			if ( getTabId == "personalMsgBtn" ) then
				infomationScrollView:scrollToPosition( { y = 0, time = 0} )
				for i = 1, #partnerTitleOptions do
					if ( partnerTextField[i] ) then
						partnerTextField[i].isVisible = false
						partnerText[i].isVisible = true
					end
				end
				for i = 1, #infoTitleOptions do
					if ( infoTextField[i] ) then
						infoTextField[i].isVisible = true
						infoText[i].isVisible = false
					end
				end
				travelMateGroup.isVisible = false
				infomationGroup.isVisible = true
			end
			if ( getTabId == "travelPtnBtn" ) then
				for i = 1, #infoTitleOptions do
					if ( infoTextField[i] ) then
						infoTextField[i].isVisible = false
						infoText[i].isVisible = true
					end
				end
				if ( not getSwitchIsOn["mate"] ) then
					for i = 1, #partnerTitleOptions do
						if ( partnerTextField[i] ) then
							partnerTextField[i].isVisible = false
							partnerText[i].isVisible = true
						end
					end
				else
					for i = 1, #partnerTitleOptions do
						if ( partnerTextField[i] ) then
							partnerTextField[i].isVisible = true
							partnerText[i].isVisible = false
						end
					end
				end
				infomationGroup.isVisible = false
				travelMateGroup.isVisible = true	
			end
		end
	-- TabBar
		local editTabBtns = {
			{
				id = "personalMsgBtn",
				label = "個人信息",
				labelColor = { default = wordColor, over = mainColor2 },
				font = getFont.font,
				size = 12,
				labelYOffset = -6,
				defaultFile = "assets/btn-topborder-space.png", 
				overFile = "assets/btn-topborder.png",
				width = (screenW+ox+ox)*0.5, 
				height = floor(110*hRate),
				onPress = onTabListener,
			},
			{
				id = "travelPtnBtn",
				label = "旅伴資料",
				labelColor = { default = wordColor, over = mainColor2 },
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
		sceneGroup:insert(editTabBar)
		if ( toMate ) then
			editTabBar:setSelected(2)
		else
			editTabBar:setSelected(1)
		end
		editTabBar.x = cx
		editTabBar.y = photoBase.y+photoBase.contentHeight*0.5+ceil(50*hRate)+editTabBar.contentHeight*0.5
	------------------ 個人信息元件 -------------------
	-- 個人信息的scrollView
		sceneGroup:insert(infomationGroup)
		infomationGroup.isVisible = false
		local isInfoScrolled = 0
		local infoMoved = false
		local infoDifferNum = 0
		local function infoScrollListener( event )
			local phase = event.phase
			if ( phase == "began" ) then
				if ( infoMoved == true ) then
					infoMoved = false
				end
			elseif ( phase == "moved" ) then
				local x,y = infomationScrollView:getContentPosition()
				infoMoved = true
				if ( isInfoScrolled ~= 0 ) then
					for i = 1, isInfoScrolled do
						if ( infoTextField[i] ) then
							infoTextField[i].isVisible = true
							infoText[i].isVisible = false
						end
					end
					isInfoScrolled = 0
				end
				if ( infoDifferNum > 0 ) then
					for i = 1, infoDifferNum do
						local textNum = tonumber(infoTextReverseTable[i])
						if ( y <= -infoTextField[textNum].y ) then
							infoTextField[textNum].isVisible = false
							infoText[textNum].isVisible = true
						else
							infoTextField[textNum].isVisible = true
							infoText[textNum].isVisible = false
						end
					end
				end
			elseif ( phase == "ended" and infoMoved == false ) then
				if ( isInfoScrolled ~= 0  ) then
					infomationScrollView:scrollToPosition( { y = 0 ,time = 0} )
				end
				for i = 1, isInfoScrolled do
					if ( infoTextField[i] ) then
						infoTextField[i].isVisible = true
						infoText[i].isVisible = false
					end
				end
				isInfoScrolled = 0
			end
			return true
		end
		infomationScrollView = widget.newScrollView({
			id = "infomationScrollView",
			x = cx,
			y = editTabBar.y+editTabBar.contentHeight*0.5,
			width = screenW+ox+ox,
			height = screenH+oy-(editTabBar.y+editTabBar.contentHeight*0.5),
			horizontalScrollDisabled = true,
			isBounceEnabled = false,
			backgroundColor = {1},
			listener = infoScrollListener,
		})
		infomationGroup:insert(infomationScrollView)
		infomationScrollView.anchorY = 0
	-- infomationScrollView內部元件 --
	-- infomationScrollView參數
		local infomationGroup = display.newGroup()
		infomationScrollView:insert(infomationGroup)
		local infomationBaseWidth = screenW+ox+ox 
		local infomationBaseHeight = screenH/12
		local infomationBaseX = infomationBaseWidth*0.5
		local infomationBaseY = 0
		local infoTitleText = {}
		--local infoSelection = {}
		local infoArrow = {}
		local infoBaseLine = {}
		local infoNowTarget, infoPreTarget = nil, nil
		local infoScrollHeight = 0
	-- 選項背景監聽事件
		local countrySelected = false
		--local isInfoScrolled = 0
		local function infoListener( event )
			local phase = event.phase
			local id = event.target.id
			if ( phase == "moved" ) then
				local dy = math.abs(event.y-event.yStart)
				if ( dy > 10 ) then
					infomationScrollView:takeFocus(event)
				end
			elseif ( phase == "ended" ) then
				-- mainScrollView 選項位置調整
					if ( infoTextField[id] and infoTextField[id].isVisible == false ) then
						if ( infoDifferNum > 0 ) then
							if ( id <= infoTextReverseTable[infoDifferNum] ) then
								infomationScrollView:scrollToPosition( { y = 0 ,time = 0} )
							end
						end
						for i = 1, id do
							if ( infoTextField[i] ) then
								infoTextField[i].isVisible = true
								infoText[i].isVisible = false
							end
						end
					end
					if ( id == 5 or id == 6 or id == 7 ) then
						infomationScrollView:scrollToPosition( { y = -(infoHintBase[5].y) ,time = 0} )
						isInfoScrolled = id
						-- 隱藏 isInfoScrolled 前面的TextField
						for i = 1, isInfoScrolled do
							if ( infoTextField[i] ) then
								infoTextField[i].isVisible = false
								infoText[i].isVisible = true
							end
						end
					elseif ( id >= 8 ) then
						infomationScrollView:scrollToPosition( { y = -(infoTitleText[8].y) ,time = 0} )
						isInfoScrolled = 8
						-- 隱藏 isInfoScrolled 前面的TextField
						for i = 1, isInfoScrolled do
							if ( infoTextField[i] ) then
								infoTextField[i].isVisible = false
								infoText[i].isVisible = true
							end
						end
					end
				-- 第一次選擇選項
				if ( infoNowTarget == nil and infoPreTarget == nil ) then
					infoNowTarget = event.target
					infoTitleText[infoNowTarget.id]:setFillColor(unpack(mainColor1))
					infoBaseLine[infoNowTarget.id]:setStrokeColor(unpack(mainColor1))
					infoBaseLine[infoNowTarget.id].strokeWidth = 2
					if ( infoTextField[infoNowTarget.id] ) then native.setKeyboardFocus( infoTextField[infoNowTarget.id] ) end
					if ( infoArrow[infoNowTarget.id] ) then
						local arrow = "infoArrow"..infoNowTarget.id
						infoArrow[infoNowTarget.id]:rotate(180)
						if ( setStatus[arrow] == "down" ) then
							setStatus[arrow] = "up"
							if ( infoNowTarget.id == 5 ) then
								genderGroup.isVisible = true
							end
							if ( infoNowTarget.id == 6 or infoNowTarget.id == 7 or infoNowTarget.id == 8 ) then
								if ( infoNowTarget.id == 6 ) then
									continentGroup.isVisible = true
								elseif ( infoNowTarget.id == 7 ) then
									countryGroup.isVisible = true
								elseif ( infoNowTarget.id == 8 ) then
									areaCodeGroup.isVisible = true
								end
								for i = infoNowTarget.id, #infoTitleOptions do 
									if ( infoTextField[i] ) then 
										infoTextField[i].isVisible = false
										infoText[i].isVisible = true
									end
								end
							end
						end
					end
				-- 有選項被選擇狀態	
				elseif ( infoNowTarget == nil and infoPreTarget ~= nil ) then
					if ( event.target.id ~= infoPreTarget.id ) then -- 相異的選項被選擇
						
						-- 舊的選項
						infoTitleText[infoPreTarget.id]:setFillColor(unpack(wordColor))
						infoBaseLine[infoPreTarget.id]:setStrokeColor(unpack(separateLineColor))
						infoBaseLine[infoPreTarget.id].strokeWidth = 1
						if ( infoTextField[infoPreTarget.id] ) then native.setKeyboardFocus( infoTextField[nil] ) end
						if ( infoArrow[infoPreTarget.id] ) then
							local arrow = "infoArrow"..infoPreTarget.id
							infoArrow[infoPreTarget.id]:rotate(180)
							setStatus[arrow] = "down"
							if ( infoPreTarget.id == 5 ) then
								genderGroup.isVisible = false
							end
							if ( infoPreTarget.id == 6 or infoPreTarget.id == 7 or infoPreTarget.id == 8 ) then
								if ( infoPreTarget.id == 6 ) then
									continentGroup.isVisible = false
								elseif ( infoPreTarget.id == 7 ) then
									countryGroup.isVisible = false
								elseif ( infoPreTarget.id == 8) then
									areaCodeGroup.isVisible = false
								end
								for i = infoPreTarget.id, #infoTitleOptions do 
									if ( infoTextField[i] ) then 
										infoTextField[i].isVisible = true
										infoText[i].isVisible = false
									end
								end
							end						
						end

						-- 新的選項
						infoNowTarget = event.target
						infoTitleText[infoNowTarget.id]:setFillColor(unpack(mainColor1))
						infoBaseLine[infoNowTarget.id]:setStrokeColor(unpack(mainColor1))
						infoBaseLine[infoNowTarget.id].strokeWidth = 2
						if ( infoTextField[infoNowTarget.id] ) then native.setKeyboardFocus( infoTextField[infoNowTarget.id] ) end
						if ( infoArrow[infoNowTarget.id] ) then
							local arrow = "infoArrow"..infoNowTarget.id
							infoArrow[infoNowTarget.id]:rotate(180)
							setStatus[arrow] = "up"
							if ( infoNowTarget.id == 5 ) then
								genderGroup.isVisible = true
							end
							if ( infoNowTarget.id == 6 or infoNowTarget.id == 7 or infoNowTarget.id == 8 ) then
								if ( infoNowTarget.id == 6 ) then
									continentGroup.isVisible = true
								elseif ( infoNowTarget.id == 7 ) then
									countryGroup.isVisible = true
								elseif ( infoNowTarget.id == 8 ) then
									areaCodeGroup.isVisible = true
								end
								for i = infoNowTarget.id, #infoTitleOptions do 
									if ( infoTextField[i] ) then 
										infoTextField[i].isVisible = false
										infoText[i].isVisible = true
									end
								end
							end
						end
					else -- 相同的選項被選擇
						infoTitleText[infoPreTarget.id]:setFillColor(unpack(wordColor))
						infoBaseLine[infoPreTarget.id]:setStrokeColor(unpack(separateLineColor))
						infoBaseLine[infoPreTarget.id].strokeWidth = 1
						if ( infoTextField[infoPreTarget.id] ) then native.setKeyboardFocus( infoTextField[nil] ) end
						if ( infoArrow[infoPreTarget.id] ) then
							local arrow = "infoArrow"..infoPreTarget.id
							infoArrow[infoPreTarget.id]:rotate(180)
							setStatus[arrow] = "down"
							if ( infoPreTarget.id == 5 ) then
								genderGroup.isVisible = false
							end
							if ( infoPreTarget.id == 6 or infoPreTarget.id == 7 or infoPreTarget.id == 8 ) then
								if ( infoPreTarget.id == 6 ) then
									continentGroup.isVisible = false
								elseif ( infoPreTarget.id == 7 ) then
									countryGroup.isVisible = false
								elseif ( infoPreTarget.id == 8) then
									areaCodeGroup.isVisible = false
								end
								for i = infoPreTarget.id, #infoTitleOptions do 
									if ( infoTextField[i] ) then 
										infoTextField[i].isVisible = true
										infoText[i].isVisible = false
									end
								end
							end
						end
						
						if ( id <= 4 ) then
							infomationScrollView:scrollToPosition( { y = 0 ,time = 0} )
						elseif ( id > 4 and id <= 7 ) then
							infomationScrollView:scrollToPosition( { y = -(infoHintBase[5].y) ,time = 0} )
						else
							infomationScrollView:scrollToPosition( { y = -(infoTitleText[8].y) ,time = 0} )
						end
					end
				end
				infoPreTarget = infoNowTarget
				infoNowTarget = nil
			end
			return true
		end
	-- 輸入欄監聽事件
		local function infoTextInput( event )
			local phase = event.phase
			local id = event.target.id
			if ( phase == "began" ) then
				if ( id >= 8 ) then
					infomationScrollView:scrollToPosition( { y = -(infoTitleText[8].y) ,time = 0} )
				end
				if ( infoNowTarget == nil and infoPreTarget == nil ) then
					infoNowTarget = event.target
					infoTitleText[infoNowTarget.id]:setFillColor(unpack(mainColor1))
					infoBaseLine[infoNowTarget.id]:setStrokeColor(unpack(mainColor1))
					infoBaseLine[infoNowTarget.id].strokeWidth = 2
					
					infoPreTarget = infoNowTarget
					infoNowTarget = nil
				elseif ( infoNowTarget == nil and infoPreTarget ~= nil ) then
					if ( event.target.id ~= infoPreTarget.id ) then
						infoTitleText[infoPreTarget.id]:setFillColor(unpack(wordColor))
						infoBaseLine[infoPreTarget.id]:setStrokeColor(unpack(separateLineColor))
						infoBaseLine[infoPreTarget.id].strokeWidth = 1
						if ( infoArrow[infoPreTarget.id] ) then
							local arrow = "infoArrow"..infoPreTarget.id
							infoArrow[infoPreTarget.id]:rotate(180)
							if ( setStatus[arrow] == "up" ) then
								setStatus[arrow] = "down"
								if ( infoPreTarget.id == 5 ) then
									genderGroup.isVisible = false
								end
							end
						end

						infoNowTarget = event.target
						infoTitleText[infoNowTarget.id]:setFillColor(unpack(mainColor1))
						infoBaseLine[infoNowTarget.id]:setStrokeColor(unpack(mainColor1))
						infoBaseLine[infoNowTarget.id].strokeWidth = 2
												
						infoPreTarget = infoNowTarget
						infoNowTarget = nil
					end
				end
			elseif ( phase == "submitted" ) then
				if ( id >= 4 ) then
					infomationScrollView:scrollToPosition( { y = -(infoHintBase[7].y) ,time = 0} )
				end
				if ( id == 1 ) then
					infoText[1].text = infoTextField[1].text
					native.setKeyboardFocus(infoTextField[2])
				elseif ( id == 2 ) then
					infoText[2].text = infoTextField[2].text
					native.setKeyboardFocus(infoTextField[3])
				elseif ( id == 3 ) then
					infoText[3].text = infoTextField[3].text
					native.setKeyboardFocus(infoTextField[4])
				elseif ( id == 4 ) then
					infoText[4].text = infoTextField[4].text
					native.setKeyboardFocus(infoTextField[9])
				elseif ( id == 9 ) then
					infoText[9].text = infoTextField[9].text
					if ( infoText[9].text == "" ) then infoText[9].text = "請輸入您的手機號碼" end
					native.setKeyboardFocus(infoTextField[10])
				elseif ( id == 10 ) then
					infoText[10].text = infoTextField[10].text
					native.setKeyboardFocus(nil)
					infoTitleText[id]:setFillColor(unpack(wordColor))
					infoBaseLine[id]:setStrokeColor(unpack(separateLineColor))
					infomationScrollView:scrollToPosition( { y = 0 ,time = 0} )
					for i = 1, #infoTitleOptions do
						if ( infoTextField[i] ) then
							infoTextField[i].isVisible = true
							infoText[i].isVisible = false
						end
					end
				end
			elseif ( phase == "ended" ) then
				--print( " infoTextField: "..phase.." TextField id is : "..id.." TextField Value is "..infoTextField[id].text )
				if ( id == 1 ) then
					infoText[1].text = infoTextField[1].text
				elseif ( id == 2 ) then
					infoText[2].text = infoTextField[2].text
				elseif ( id == 3 ) then
					infoText[3].text = infoTextField[3].text
				elseif ( id == 4 ) then
					infoText[4].text = infoTextField[4].text
				elseif ( id == 9 ) then
					infoText[9].text = infoTextField[9].text
					if ( infoText[9].text == "" ) then infoText[9].text = "請輸入您的手機號碼" end
				elseif ( id == 10 ) then
					infoText[10].text = infoTextField[10].text 
				end
			end
		end
	-- infomationScrollView內容
		local countryCover
		-- 顯示文字-姓名填寫提示訊息
		local msgBase = display.newRect( infomationGroup, infomationBaseX, infomationBaseY, screenW+ox+ox, screenH/40)
		msgBase.anchorY = 0
		infomationBaseY = msgBase.contentHeight+infomationBaseY
		local msgText = display.newText({
			parent = infomationGroup,
			text = "*中英文姓名可擇一填寫",
			x = ceil(49*wRate),
			y = msgBase.y+msgBase.contentHeight*0.5,
			font = getFont.font,
			fontSize = 10,
		})
		msgText:setFillColor(unpack(separateLineColor))
		msgText.anchorX = 0
		for i = 1, #infoTitleOptions do
			-- 必填區塊
				if (i == 5 or i == 6 or i == 7 or i == 10) then
					infoHintBase[i] = display.newRect( infomationGroup, infomationBaseX, infomationBaseY, infomationBaseWidth, msgBase.contentHeight)
					infoHintBase[i].anchorY = 0
					infoHintBase[i]:addEventListener( "touch", function ( event ) return true; end)
					infomationBaseY = infoHintBase[i].y+infoHintBase[i].contentHeight
					infoHintText[i] = display.newText({
						text = "*必填",
						x = ceil(49*wRate),
						y = infoHintBase[i].y+infoHintBase[i].contentHeight*0.5,
						font = getFont.font,
						fontSize = 10,
					})
					infomationGroup:insert(infoHintText[i])
					infoHintText[i]:setFillColor(unpack(separateLineColor))
					infoHintText[i].anchorX = 0
				end
			-- 白底
				local infoBase = display.newRect( infomationGroup, infomationBaseX, infomationBaseY, infomationBaseWidth, infomationBaseHeight)
				--infoBase:setFillColor( math.random(), math.random(), math.random() ,0.3)
				infoBase.anchorY = 0
				infoBase.id = i
				infoBase:addEventListener("touch",infoListener)
			-- 顯示文字-抬頭內容
				infoTitleText[i] = display.newText({
					text = infoTitleOptions[i],
					font = getFont.font,
					fontSize = 10,
					x = ceil(49*wRate),
					y = infoBase.y,
				})
				infomationGroup:insert(infoTitleText[i])
				infoTitleText[i]:setFillColor(unpack(wordColor))
				infoTitleText[i].anchorX = 0
				infoTitleText[i].anchorY = 0
			-- 輸入欄位(隱藏的顯示文字)或是選單
				if ( i ~= 5 and  i ~= 6 and i ~= 7 and i ~= 8 ) then
					table.insert( infoTextReverseTable, i)
					infoText[i] = display.newText({
						parent = infomationGroup,
						text = infoList[i]:match(pattern) or "",
						font = getFont.font,
						fontSize = 12,
					})
					infoText[i].isVisible = false
					infoText[i]:setFillColor(unpack(wordColor))
					infoText[i].anchorX = 0
					infoText[i].anchorY = 0

					infoTextField[i] = native.newTextField( infoTitleText[i].x, infoTitleText[i].y+infoTitleText[i].contentHeight, infomationBaseWidth*0.7, infomationBaseHeight*0.4)
					infomationGroup:insert(infoTextField[i])
					infoTextField[i].anchorX = 0
					infoTextField[i].anchorY = 0
					infoTextField[i].id = i
					infoTextField[i].text = infoList[i]:match(pattern) or ""
					infoTextField[i].hasBackground = false
					infoTextField[i].font = getFont.font
					infoTextField[i]:resizeFontToFitHeight()
					infoTextField[i]:setSelection(0,0)
					infoTextField[i]:setReturnKey( "next" )
					infoTextField[i]:setTextColor(unpack(wordColor))
					infoTextField[i].isVisible = false
					if ( i == 9 ) then
						infoTextField[i].placeholder = "請輸入您的手機號碼"
						infoTextField[i].inputType = "phone"
						if ( infoText[i].text == "" ) then infoText[i].text = "請輸入您的手機號碼" end
					end
					if ( i == 10) then
						--infoTextField[i].text = userLoginInfo.email
						--infoText[i].text = userLoginInfo.email
						infoTextField[i].inputType = "email"
						infoTextField[i]:setReturnKey( "done" )
					end
					infoTextField[i]:addEventListener("userInput",infoTextInput)

					infoText[i].x = infoTextField[i].x+1
					infoText[i].y = infoTextField[i].y+1
					infoText[i].size = infoTextField[i].size
				else
					infoSelection[i] = display.newText({
						text = infoList[i]:match(pattern) or "請選擇",
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
					infoArrow[i].width = infoArrow[i].width*0.05
					infoArrow[i].height = infoArrow[i].height*0.05
					local arrow = "infoArrow"..i
					setStatus[arrow] = "down"
				end
			-- 底線
				infoBaseLine[i] = display.newLine( ceil(49*wRate), infoBase.y+infoBase.contentHeight*0.8, screenW+ox+ox-ceil(49*wRate), infoBase.y+infoBase.contentHeight*0.8)
				infomationGroup:insert(infoBaseLine[i])
				infoBaseLine[i].strokeWidth = 1
				infoBaseLine[i]:setStrokeColor(unpack(separateLineColor))
				infomationBaseY = infomationBaseY+(infomationBaseHeight)
				infoScrollHeight = infoBase.y+infoBase.contentHeight

				if ( i == 7 ) then 
					countryCover = display.newRect( infomationGroup, infoBase.x, infoBase.y, infoBase.contentWidth, infoBase.contentHeight)
					countryCover:setFillColor( 1, 1, 1, 0.7)
					countryCover.anchorY = 0
					countryCover:addEventListener( "touch", function () return true; end)
				end
		end

		local infoCount = 1
		local differHeight = 0
		if ( infoScrollHeight > infomationScrollView.contentHeight ) then
			infomationScrollView:setScrollHeight(infoScrollHeight)
			-- 利用scrollview的實際高度差計算需要隱藏的textField
			differHeight = infoScrollHeight-infomationScrollView.contentHeight
			while ( infoCount < #infoTitleOptions ) do
				if ( infoTextField[infoCount] and infoTextField[infoCount].y < differHeight) then 
					infoDifferNum = infoDifferNum+1
					infoCount = infoCount+1
				else
					break
				end
			end
		end
	------------------ 個人訊息下拉式選單元件 -------------------
	-- 國家區碼選單 --
	-- 陰影外框
		local maxAreaCodeNum = 6
		infomationGroup:insert(areaCodeGroup)
		local areaCodeFrame = display.newImageRect( areaCodeGroup, frameName, frameWidth, (optionBaseHeight+optionPadding)*maxAreaCodeNum+optionPadding )
		areaCodeFrame:addEventListener( "touch", function (event) return true; end)
		areaCodeFrame.anchorY = 0
		areaCodeFrame.x = infomationBaseX
		areaCodeFrame.y = infoBaseLine[8].y+1
		-- scrollview
		local areaCodeScrollView = widget.newScrollView({
			id = "areaCodeScrollView",
			x = areaCodeFrame.x,
			y = areaCodeFrame.y,
			width = optionBaseWidth,
			height = areaCodeFrame.contentHeight*59/60,
			horizontalScrollDisabled = true,
			isBounceEnabled = false
		})
		areaCodeScrollView.anchorY = 0
		areaCodeGroup:insert(areaCodeScrollView)
		local areaCodeScrollGroup = display.newGroup()
		areaCodeScrollView:insert(areaCodeScrollGroup)
		local areaCodeScrollHeight = 0
	-- 國家區碼選單內容監聽事件
		local areaCodeText = {}
		local areaCodeCancel = false
		local areaCodeNowTarget, areaCodePrevTarget = nil, nil
		local function areaCodeListener( event )
			local phase = event.phase
			if ( phase == "began" ) then
				if ( areaCodeCancel == true ) then
					areaCodeCancel = false
				end
				if ( areaCodeNowTarget == nil and areaCodePrevTarget == nil ) then
					areaCodeNowTarget = event.target
					areaCodeNowTarget:setFillColor( 0, 0, 0, 0.2)
					areaCodeText[areaCodeNowTarget.id]:setFillColor(unpack(subColor2))
				end
				if ( areaCodeNowTarget == nil and areaCodePrevTarget ~= nil ) then
					if ( event.target ~= areaCodePrevTarget ) then
						areaCodePrevTarget:setFillColor(1)
						areaCodeText[areaCodePrevTarget.id]:setFillColor(unpack(wordColor))

						areaCodeNowTarget = event.target
						areaCodeNowTarget:setFillColor( 0, 0, 0, 0.2)
						areaCodeText[areaCodeNowTarget.id]:setFillColor(unpack(subColor2))
					end
				end
			elseif ( phase == "moved" ) then
				areaCodeCancel = true
				local dy = math.abs(event.yStart-event.y)
				if ( dy > 10 ) then
					areaCodeScrollView:takeFocus(event)
				end
				if ( areaCodeNowTarget ~= nil ) then
					areaCodeNowTarget = event.target
					areaCodeNowTarget:setFillColor(1)
					areaCodeText[areaCodeNowTarget.id]:setFillColor(unpack(wordColor))
					areaCodeNowTarget = nil
					if ( areaCodePrevTarget ~= nil ) then
						areaCodeText[areaCodePrevTarget.id]:setFillColor(unpack(subColor2))
					end
				end
			elseif ( phase == "ended" and areaCodeCancel == false and areaCodeNowTarget ~= nil ) then
				infoArrow[8]:rotate(180)
				setStatus["infoArrow8"] = "down"
				infoTitleText[8]:setFillColor(unpack(wordColor))
				infoSelection[8].text = areaCodeText[areaCodeNowTarget.id].text
				infoBaseLine[8]:setStrokeColor(unpack(separateLineColor))
				infoBaseLine[8].strokeWidth = 1
				for i = 8, #infoTitleOptions do 
					if ( infoTextField[i] ) then
						infoTextField[i].isVisible = true
						infoText[i].isVisible = false
					end
				end
				infoPreTarget = infoNowTarget
				infoNowTarget = nil
				areaCodeGroup.isVisible = false
				
				areaCodeNowTarget:setFillColor(1)
				areaCodePrevTarget = areaCodeNowTarget
				areaCodeNowTarget = nil
			end
			return true
		end
	-- 國家區碼選單內容
		for i = 1, #areaCode do
			local areaCodeBase = display.newRect( areaCodeScrollGroup, areaCodeScrollView.contentWidth*0.5, optionPadding+(optionPadding+optionBaseHeight)*(i-1), optionBaseWidth, optionBaseHeight )
			areaCodeBase.anchorY = 0
			areaCodeBase.id = i
			areaCodeBase:addEventListener("touch", areaCodeListener)
			--areaCodeBase:setFillColor( math.random(), math.random(), math.random() )
			areaCodeText[i] = display.newText({
				parent = areaCodeScrollGroup,
				text = areaCode[i],
				font = getFont.font,
				fontSize = 12,
				x = areaCodeBase.x,
				y = areaCodeBase.y+areaCodeBase.contentHeight*0.5,
			})
			if ( areaCodeText[i].text == infoSelection[8].text ) then
				areaCodeText[i]:setFillColor(unpack(subColor2))
				areaCodePrevTarget = areaCodeBase
			else
				areaCodeText[i]:setFillColor(unpack(wordColor))
			end
			areaCodeScrollHeight = areaCodeBase.y+areaCodeBase.contentHeight
		end
		if ( areaCodeScrollHeight > areaCodeScrollView.contentHeight ) then
			areaCodeScrollView:setScrollHeight(areaCodeScrollHeight+optionPadding)
		end
		areaCodeGroup.isVisible = false
	
	-- 洲別/國家選單 --
	-- 陰影外框
		infomationGroup:insert(continentGroup)
		local contientNum = infomationGroup.numChildren
		local contientFrame = display.newImageRect( continentGroup, frameName, frameWidth, (optionBaseHeight+optionPadding)*#continentOptions+optionPadding )
		contientFrame:addEventListener( "touch", function (event) return true; end)
		contientFrame.anchorY = 0
		contientFrame.x = infomationBaseX
		contientFrame.y = infoBaseLine[6].y+1
	-- 國家選單內容監聽事件
		local countryScrollHeight = 0
		local countryText = {}
		local countryCancel = false
		local countryNowTarget, countryPrevTarget = nil, nil
		local countryScrollView
		local countryEnglishList = {}
		local function countryListener( event )
			local phase = event.phase
			if ( phase == "began" ) then
				if ( countryCancel == true ) then
					countryCancel = false
				end
				if ( countryNowTarget == nil and countryPrevTarget == nil ) then
					countryNowTarget = event.target
					countryNowTarget:setFillColor( 0, 0, 0, 0.2)
					countryText[countryNowTarget.id]:setFillColor(unpack(subColor2))
				end
				if ( countryNowTarget == nil and countryPrevTarget ~= nil ) then
					if ( event.target ~= countryPrevTarget ) then
						countryPrevTarget:setFillColor(1)
						countryText[countryPrevTarget.id]:setFillColor(unpack(wordColor))

						countryNowTarget = event.target
						countryNowTarget:setFillColor( 0, 0, 0, 0.2)
						countryText[countryNowTarget.id]:setFillColor(unpack(subColor2))
					end
				end
			elseif ( phase == "moved" ) then
				countryCancel = true
				local dy = math.abs(event.yStart-event.y)
				if ( dy > 10 ) then
					countryScrollView:takeFocus(event)
				end
				if ( countryNowTarget ~= nil ) then
					countryNowTarget = event.target
					countryNowTarget:setFillColor(1)
					countryText[countryNowTarget.id]:setFillColor(unpack(wordColor))
					countryNowTarget = nil
					if ( countryPrevTarget ~= nil ) then
						countryText[countryPrevTarget.id]:setFillColor(unpack(subColor2))
					end
				end
			elseif ( phase == "ended" and countryCancel == false and countryNowTarget ~= nil ) then
				countryGroup.isVisible = false
				-- mainScrollView選項事件
				infoArrow[7]:rotate(180)
				setStatus["infoArrow7"] = "down"
				infoTitleText[7]:setFillColor(unpack(wordColor))
				infoSelection[7].text = countryText[countryNowTarget.id].text
				setCountry = countryEnglishList[countryNowTarget.id]
				print(setCountry)
				infoBaseLine[7]:setStrokeColor(unpack(separateLineColor))
				infoBaseLine[7].strokeWidth = 1
				for i = 7, #infoTitleOptions do 
					if ( infoTextField[i] ) then
						infoTextField[i].isVisible = true
						infoText[i].isVisible = false
					end
				end
				if ( infoHintText[7].text == "此為必填區塊" ) then
					infoHintText[7].text = "*必填"
					infoHintText[7]:setFillColor(unpack(separateLineColor))
				end
				infoPreTarget = infoNowTarget
				infoNowTarget = nil

				countryNowTarget:setFillColor(1)
				countryPrevTarget = countryNowTarget
				countryNowTarget = nil
			end
			return true
		end
	-- 洲別選單內容監聽事件
		local continentText = {}
		local contientCancel = false
		local contientNowTarget, contientPrevTarget = nil, nil
		local function contientListener( event )
			local phase = event.phase
			if ( phase == "began" ) then
				if ( contientCancel == true ) then
					contientCancel = false
				end
				if ( contientNowTarget == nil and contientPrevTarget == nil ) then
					contientNowTarget = event.target
					contientNowTarget:setFillColor( 0, 0, 0, 0.2)
					continentText[contientNowTarget.id]:setFillColor(unpack(subColor2))
				end
				if ( contientNowTarget == nil and contientPrevTarget ~= nil ) then
					if ( event.target ~= contientPrevTarget ) then
						contientPrevTarget:setFillColor(1)
						continentText[contientPrevTarget.id]:setFillColor(unpack(wordColor))

						contientNowTarget = event.target
						contientNowTarget:setFillColor( 0, 0, 0, 0.2)
						continentText[contientNowTarget.id]:setFillColor(unpack(subColor2))
					end
				end
			elseif ( phase == "moved" ) then
				contientCancel = true
				if ( contientNowTarget ~= nil ) then
					contientNowTarget = event.target
					contientNowTarget:setFillColor(1)
					continentText[contientNowTarget.id]:setFillColor(unpack(wordColor))
					contientNowTarget = nil
					if ( contientPrevTarget ~= nil ) then
						continentText[contientPrevTarget.id]:setFillColor(unpack(subColor2))
					end
				end
			elseif ( phase == "ended" and contientCancel == false and contientNowTarget ~= nil  ) then
				continentGroup.isVisible = false
				countryCover.isVisible = false
				-- mainScrollView選項事件
				infoArrow[6]:rotate(180)
				setStatus["infoArrow6"] = "down"
				infoTitleText[6]:setFillColor(unpack(wordColor))
				if ( continentText[contientNowTarget.id].text ~= infoSelection[6].text ) then
					infoSelection[7].text = "請選擇"
					countryNowTarget = nil
					countryPrevTarget = nil
				end
				infoSelection[6].text = continentText[contientNowTarget.id].text
				infoBaseLine[6]:setStrokeColor(unpack(separateLineColor))
				infoBaseLine[6].strokeWidth = 1
				for i = 6, #infoTitleOptions do 
					if ( infoTextField[i] ) then
						infoTextField[i].isVisible = true
						infoText[i].isVisible = false
					end
				end
				if ( infoHintText[6].text == "此為必填區塊" ) then
					infoHintText[6].text = "*必填"
					infoHintText[6]:setFillColor(unpack(separateLineColor))
				end
				infoPreTarget = infoNowTarget
				infoNowTarget = nil

				contientNowTarget:setFillColor(1)
				contientPrevTarget = contientNowTarget
				contientNowTarget = nil
				-- 因為要選完洲別才會產生相對應的國家，所以國家選單要在選完洲別後才會產生 --
					local continentDecode = json.decode(continentJson)
					local continentDecodeValue = infoSelection[6].text
					local countryListOptions = {}
					--local countryIdList = {}
					local function getCountryInfo( event )
						if ( event.isError ) then
							print( "Network Error: "..event.response )
						else
							--print( "Response: "..event.response )
							local countryJsonData = json.decode( event.response )
							if ( #countryEnglishList > 0 ) then
								countryEnglishList = {nil}
							end
							for key, countryTableJson in pairs(countryJsonData["list"]) do
								table.insert( countryListOptions, countryTableJson["desc"])
								--table.insert( countryIdList, countryTableJson["id"])
								table.insert( countryEnglishList, countryTableJson["country"])
							end
							print(#countryEnglishList)
						end
						-- 國家選單外框
							if ( countryGroup ) then
								countryGroup:removeSelf()
								countryGroup = nil
								countryGroup = display.newGroup()
							end
						-- 陰影外框
							local maxCountryNum = 6
							infomationGroup:insert( contientNum, countryGroup )
							local countryFrame = display.newImageRect( countryGroup, frameName, frameWidth, (optionBaseHeight+optionPadding)*maxCountryNum+optionPadding )
							countryFrame:addEventListener( "touch", function (event) return true; end)
							countryFrame.anchorY = 0
							countryFrame.x = infomationBaseX
							countryFrame.y = infoBaseLine[7].y+1
						-- scrollview
							countryScrollView = widget.newScrollView({
								id = "countryScrollView",
								x = countryFrame.x,
								y = countryFrame.y,
								width = optionBaseWidth,
								height = countryFrame.contentHeight*59/60,
								horizontalScrollDisabled = true,
								isBounceEnabled = false
							})
							countryScrollView.anchorY = 0
							countryGroup:insert(countryScrollView)
							local countryScrollGroup = display.newGroup()
							countryScrollView:insert(countryScrollGroup)
						-- 國家選單內容
							for i = 1, #countryListOptions do
								local countryBase = display.newRect( countryScrollGroup, countryScrollView.contentWidth*0.5, optionPadding+(optionPadding+optionBaseHeight)*(i-1), optionBaseWidth, optionBaseHeight )
								countryBase.anchorY = 0
								countryBase.id = i
								countryBase:addEventListener( "touch", countryListener )
								--countryBase:setFillColor( math.random(), math.random(), math.random() )
								countryText[i] = display.newText({
									parent = countryScrollGroup,
									text = countryListOptions[i],
									font = getFont.font,
									fontSize = 12,
									x = countryBase.x,
									y = countryBase.y+countryBase.contentHeight*0.5,
								})
								countryText[i]:setFillColor(unpack(wordColor))
								countryScrollHeight = countryBase.y+countryBase.contentHeight
							end
							if ( countryScrollHeight > countryScrollView.contentHeight ) then
								countryScrollView:setScrollHeight(countryScrollHeight+optionPadding)
							end
							countryGroup.isVisible = false
					end
					local getCountryUrl = optionsTable.getCountryByContinentUrl..continentDecode[continentDecodeValue]
					network.request( getCountryUrl, "GET", getCountryInfo)	
			end
			return true
		end
	-- 洲別選單內容
		for i = 1, #continentOptions do
			local contientBase = display.newRect( continentGroup, contientFrame.x, optionPadding+contientFrame.y+(optionPadding+optionBaseHeight)*(i-1), optionBaseWidth, optionBaseHeight )
			contientBase.anchorY = 0
			contientBase.id = i
			contientBase:addEventListener( "touch", contientListener)
			--contientBase:setFillColor( math.random(), math.random(), math.random() )
			continentText[i] = display.newText({
				parent = continentGroup,
				text = continentOptions[i],
				font = getFont.font,
				fontSize = 12,
				x = contientBase.x,
				y = contientBase.y+contientBase.contentHeight*0.5,
			})
			if ( continentText[i].text == infoSelection[6].text ) then
				-- 洲別如果有選項則產生國家選單
				continentText[i]:setFillColor(unpack(subColor2))
				contientPrevTarget = contientBase
				countryCover.isVisible = false
				local continentDecode = json.decode(continentJson)
				local continentDecodeValue = infoSelection[6].text
				local countryListOptions = {}
				local function getCountryInfo( event )
					if ( event.isError ) then
						print( "Network Error: "..event.response )
					else
						--print( "Response: "..event.response )
						local countryJsonData = json.decode( event.response )
						if ( #countryEnglishList > 0 ) then
							countryEnglishList = {nil}
						end
						for key, countryTableJson in pairs(countryJsonData["list"]) do
							table.insert( countryListOptions, countryTableJson["desc"])
							table.insert( countryEnglishList, countryTableJson["country"])
						end
					end
					-- 國家選單外框
						if ( countryGroup ) then
							countryGroup:removeSelf()
							countryGroup = nil
							countryGroup = display.newGroup()
						end
					-- 陰影外框
						local maxCountryNum = 6
						infomationGroup:insert( contientNum, countryGroup )
						local countryFrame = display.newImageRect( countryGroup, frameName, frameWidth, (optionBaseHeight+optionPadding)*maxCountryNum+optionPadding )
						countryFrame:addEventListener( "touch", function (event) return true; end)
						countryFrame.anchorY = 0
						countryFrame.x = infomationBaseX
						countryFrame.y = infoBaseLine[7].y+1
					-- scrollview
						countryScrollView = widget.newScrollView({
							id = "countryScrollView",
							x = countryFrame.x,
							y = countryFrame.y,
							width = optionBaseWidth,
							height = countryFrame.contentHeight*59/60,
							horizontalScrollDisabled = true,
							isBounceEnabled = false
						})
						countryScrollView.anchorY = 0
						countryGroup:insert(countryScrollView)
						local countryScrollGroup = display.newGroup()
						countryScrollView:insert(countryScrollGroup)
					-- 國家選單內容
						for i = 1, #countryListOptions do
							local countryBase = display.newRect( countryScrollGroup, countryScrollView.contentWidth*0.5, optionPadding+(optionPadding+optionBaseHeight)*(i-1), optionBaseWidth, optionBaseHeight )
							countryBase.anchorY = 0
							countryBase.id = i
							countryBase:addEventListener( "touch", countryListener )
							--countryBase:setFillColor( math.random(), math.random(), math.random() )
							countryText[i] = display.newText({
								parent = countryScrollGroup,
								text = countryListOptions[i],
								font = getFont.font,
								fontSize = 12,
								x = countryBase.x,
								y = countryBase.y+countryBase.contentHeight*0.5,
							})
							if ( countryText[i].text == infoSelection[7].text ) then
								countryText[i]:setFillColor(unpack(subColor2))
								setCountry = countryEnglishList[i]
								countryPrevTarget = countryBase
							else
								countryText[i]:setFillColor(unpack(wordColor))
							end
							countryScrollHeight = countryBase.y+countryBase.contentHeight
						end
						if ( countryScrollHeight > countryScrollView.contentHeight ) then
							countryScrollView:setScrollHeight(countryScrollHeight+optionPadding)
						end
						countryGroup.isVisible = false
				end
				local getCountryUrl = optionsTable.getCountryByContinentUrl..continentDecode[continentDecodeValue]
				network.request( getCountryUrl, "GET", getCountryInfo)	
			else
				continentText[i]:setFillColor(unpack(wordColor))
			end
		end
		continentGroup.isVisible = false
	
	-- 性別選單 --
	-- 陰影外框
		infomationGroup:insert(genderGroup)
		local genderFrame = display.newImageRect( genderGroup, frameName, frameWidth, (optionBaseHeight+optionPadding)*#genderOptions+optionPadding )
		genderFrame:addEventListener( "touch", function (event) return true; end)
		genderFrame.anchorY = 0
		genderFrame.x = infomationBaseX
		genderFrame.y = infoBaseLine[5].y+1
	-- 性別下拉選單內容監聽事件
		local genderText = {}
		local genderCancel = false
		local genderNowTarget, genderPrevTarget = nil, nil
		local function genderListener( event )
			local phase = event.phase
			if ( phase == "began" ) then
				if ( genderCancel == true ) then
					genderCancel = false
				end
				if ( genderNowTarget == nil and genderPrevTarget == nil ) then
					genderNowTarget = event.target
					genderNowTarget:setFillColor( 0, 0, 0, 0.2)
					genderText[genderNowTarget.id]:setFillColor(unpack(subColor2))
				end
				if ( genderNowTarget == nil and genderPrevTarget ~= nil ) then
					if ( event.target ~= genderPrevTarget ) then
						genderPrevTarget:setFillColor(1)
						genderText[genderPrevTarget.id]:setFillColor(unpack(wordColor))

						genderNowTarget = event.target
						genderNowTarget:setFillColor( 0, 0, 0, 0.2)
						genderText[genderNowTarget.id]:setFillColor(unpack(subColor2))
					end
				end
			elseif ( phase == "moved" ) then
				genderCancel = true
				if ( genderNowTarget ~= nil ) then
					genderNowTarget = event.target
					genderNowTarget:setFillColor(1)
					genderText[genderNowTarget.id]:setFillColor(unpack(wordColor))
					genderNowTarget = nil
					if ( genderPrevTarget ~= nil ) then
						genderText[genderPrevTarget.id]:setFillColor(unpack(subColor2))
					end
				end
			elseif ( phase == "ended" and genderCancel == false and genderNowTarget ~= nil ) then
				infoArrow[5]:rotate(180)
				setStatus["infoArrow5"] = "down"
				infoTitleText[5]:setFillColor(unpack(wordColor))
				infoSelection[5].text = genderText[genderNowTarget.id].text
				infoBaseLine[5]:setStrokeColor(unpack(separateLineColor))
				infoBaseLine[5].strokeWidth = 1
				if ( infoHintText[5].text == "此為必填區塊" ) then
					infoHintText[5].text = "*必填"
					infoHintText[5]:setFillColor(unpack(separateLineColor))
				end
				infoPreTarget = infoNowTarget
				infoNowTarget = nil
				genderGroup.isVisible = false
				
				genderNowTarget:setFillColor(1)
				genderPrevTarget = genderNowTarget
				genderNowTarget = nil
			end
			return true
		end
	-- 性別選單內容
		for i = 1, #genderOptions do
			local genderBase = display.newRect( genderGroup, infomationBaseX, optionPadding+genderFrame.y+(optionPadding+optionBaseHeight)*(i-1), optionBaseWidth, optionBaseHeight )
			genderBase.anchorY = 0
			genderBase.id = i
			genderBase:addEventListener("touch", genderListener)
			--genderBase:setFillColor( math.random(), math.random(), math.random() )
			genderText[i] = display.newText({
				parent = genderGroup,
				text = genderOptions[i],
				font = getFont.font,
				fontSize = 12,
				x = genderBase.x,
				y = genderBase.y+genderBase.contentHeight*0.5,
			})
			if ( genderText[i].text == infoSelection[5].text ) then
				genderText[i]:setFillColor(unpack(subColor2))
				genderPrevTarget = genderBase
			else
				genderText[i]:setFillColor(unpack(wordColor))
			end
		end
		genderGroup.isVisible = false
	------------------ 旅伴系統元件 -------------------
	-- 旅伴開關白底
		sceneGroup:insert(travelMateGroup)
		travelMateGroup.isVisible = false
		local trvlMateSwitchBase = display.newRect(travelMateGroup, cx, editTabBar.y+editTabBar.contentHeight*0.5, screenW+ox+ox, screenH/12)
		trvlMateSwitchBase.anchorY = 0
	-- 顯示文字-"旅伴系統"
		local trvlMateSwitchText = display.newText({
			parent = travelMateGroup,
			text = "旅伴系統",
			font = getFont.font,
			fontSize = 12,
			x = -ox+ceil(49*wRate),
			y = trvlMateSwitchBase.y+trvlMateSwitchBase.contentHeight*0.5,
		}) 
		trvlMateSwitchText:setFillColor(unpack(wordColor))
		trvlMateSwitchText.anchorX = 0
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
		local switchStatusText = display.newText({
			text = "",
			font = getFont.font,
			fontSize = 12,
		})
		travelMateGroup:insert(switchStatusText)
		switchStatusText.anchorX = 1
		if ( not getSwitchIsOn["mate"] ) then
			switchStatusText:setFillColor(unpack(wordColor))
			switchStatusText.text = "關閉"
		else
			switchStatusText:setFillColor(unpack(mainColor1))
			switchStatusText.text = "開啟"
		end
	-- 分隔線
		trvlMateSwitchBaseLine = display.newLine(-ox, trvlMateSwitchBase.y+trvlMateSwitchBase.contentHeight, screenW+ox, trvlMateSwitchBase.y+trvlMateSwitchBase.contentHeight)
		travelMateGroup:insert(trvlMateSwitchBaseLine)
		trvlMateSwitchBaseLine.strokeWidth = 1
		trvlMateSwitchBaseLine:setStrokeColor(unpack(separateLineColor))
	-- 旅伴資料的scrollView
		local partnerScrollView
		local isPtnrScrolled = 0
		local ptnrMoved = false
		local ptnrDifferNum = 0
		local function ptnrScrollListener( event )
			local phase = event.phase
			if ( phase == "began" ) then
				if ( ptnrMoved == true ) then
					ptnrMoved = false
				end
			elseif ( phase == "moved" ) then
				local x,y = partnerScrollView:getContentPosition()
				ptnrMoved = true
				if ( isPtnrScrolled ~= 0 ) then
					for i = 1, isPtnrScrolled do
						if ( partnerTextField[i] ) then
							partnerTextField[i].isVisible = true
							partnerText[i].isVisible = false
						end
					end
					isPtnrScrolled = 0
				end
				if ( ptnrDifferNum > 0 ) then
					for i = 1, ptnrDifferNum do
						local textNum = tonumber(ptnrTextReverseTable[i])
						if ( y <= -partnerTextField[textNum].y ) then
							partnerTextField[textNum].isVisible = false
							partnerText[textNum].isVisible = true
						else
							partnerTextField[textNum].isVisible = true
							partnerText[textNum].isVisible = false
						end
					end
				end
			elseif ( phase == "ended" and ptnrMoved == false ) then
				if ( isPtnrScrolled ~= 0  ) then
					partnerScrollView:scrollToPosition( { y = 0 ,time = 0} )
				end
				for i = 1, isPtnrScrolled do
					if ( partnerTextField[i] ) then
						partnerTextField[i].isVisible = true
						partnerText[i].isVisible = false
					end
				end
				isPtnrScrolled = 0
			end
			return true
		end
		partnerScrollView = widget.newScrollView({
			id = "partnerScrollView",
			x = cx,
			y = trvlMateSwitchBase.y+trvlMateSwitchBase.contentHeight,
			width = screenW+ox+ox,
			height = screenH+oy+oy-(trvlMateSwitchBase.y+trvlMateSwitchBase.contentHeight),
			horizontalScrollDisabled = true,
			isBounceEnabled = false,
			backgroundColor = {1},
			listener = ptnrScrollListener,
		})
		travelMateGroup:insert(partnerScrollView)
		partnerScrollView.anchorY = 0
	-- 旅伴資料的scrollView遮罩
		local partnerScrollViewCover = display.newRect( travelMateGroup, partnerScrollView.x,partnerScrollView.y,partnerScrollView.contentWidth,partnerScrollView.contentHeight)
		partnerScrollViewCover:setFillColor(1,1,1,0.7)
		partnerScrollViewCover.anchorY = 0
		partnerScrollViewCover:addEventListener( "touch", function() return true ; end)
		if ( not getSwitchIsOn["mate"] ) then
			partnerScrollViewCover.isVisible = true
		else
			partnerScrollViewCover.isVisible = false
		end
	-- partnerScrollView內部元件 --
	-- partnerScrollView參數
		local partnerGroup = display.newGroup()
		partnerScrollView:insert(partnerGroup)
		local partnerBaseWidth = screenW+ox+ox 
		local partnerBaseHeight = screenH/12
		local partnerBaseX = partnerBaseWidth*0.5
		local partnerBaseY = 0
		local partnerTitleText = {}
		--local partnerSelection = {}
		local partnerArrow = {}
		local partnerBaseLine = {}
		local partnerNowTarget, partnerPreTarget = nil, nil
		local ptnrScrollHeight = 0
	-- 選項背景監聽事件
		local function partnerListener( event )
			local phase = event.phase
			local id = event.target.id
			if ( phase == "moved" ) then
				local dy = math.abs(event.y-event.yStart)
				if ( dy > 10 ) then
					partnerScrollView:takeFocus(event)
				end
			elseif (phase == "ended") then
				if ( partnerTextField[id] and partnerTextField[id].isVisible == false ) then
					if ( ptnrDifferNum > 0 ) then
						if ( id <= ptnrTextReverseTable[ptnrDifferNum] ) then
							partnerScrollView:scrollToPosition( { y = 0 ,time = 0} )
						end
					end
					for i = 1, id do
						if ( partnerTextField[i] ) then
							partnerTextField[i].isVisible = true
							partnerText[i].isVisible = false
						end
					end
				end
				if ( id == 4 or id == 5 ) then
					partnerScrollView:scrollToPosition( { y = -(partnerTitleText[4].y), time = 0 })
					isPtnrScrolled = id
					for i = 1, isPtnrScrolled do
						if ( partnerTextField[i] ) then
							partnerTextField[i].isVisible = false
							partnerText[i].isVisible = true
						end
					end
				end
				if (id == 7 ) then
					partnerScrollView:scrollToPosition( { y = -(partnerTitleText[6].y), time = 0 })
					isPtnrScrolled = 5
					for i = 1, isPtnrScrolled do
						if ( partnerTextField[i] ) then
							partnerTextField[i].isVisible = false
							partnerText[i].isVisible = true
						end
					end
				end
				-- 第一次選擇選項
				if (partnerNowTarget == nil and partnerPreTarget == nil) then
					partnerNowTarget = event.target
					partnerTitleText[partnerNowTarget.id]:setFillColor(unpack(mainColor1))
					partnerBaseLine[partnerNowTarget.id]:setStrokeColor(unpack(mainColor1))
					partnerBaseLine[partnerNowTarget.id].strokeWidth = 2
					if ( partnerTextField[partnerNowTarget.id] ) then native.setKeyboardFocus( partnerTextField[partnerNowTarget.id] ) end
					if ( partnerArrow[partnerNowTarget.id] ) then 
						partnerArrow[partnerNowTarget.id]:rotate(180)
						local arrow = "partnerArrow"..partnerNowTarget.id
						setStatus[arrow] = "up"
						if ( partnerNowTarget.id == 3 ) then
							ptnrGenderGroup.isVisible = true
						end
						if ( partnerNowTarget.id == 4 or partnerNowTarget.id == 5 or partnerNowTarget.id == 7) then
							if ( partnerNowTarget.id == 4 ) then
								ptnrcontinentGroup.isVisible = true
							end
							if ( partnerNowTarget.id == 5 ) then
								ptnrCountryGroup.isVisible = true
							end
							if ( partnerNowTarget.id == 7 ) then
								travelMethodGroup.isVisible = true
							end
							for i = partnerNowTarget.id, #partnerTitleOptions do
								if ( partnerTextField[i] ) then
									partnerTextField[i].isVisible = false
									partnerText[i].isVisible = true
								end
							end
						end
					end
				-- 有選項被選擇狀態	
				elseif ( partnerNowTarget == nil and partnerPreTarget ~= nil) then
					if ( event.target.id ~= partnerPreTarget.id ) then -- 相異的選項被選擇
						partnerTitleText[partnerPreTarget.id]:setFillColor(unpack(wordColor))
						partnerBaseLine[partnerPreTarget.id]:setStrokeColor(unpack(separateLineColor))
						partnerBaseLine[partnerPreTarget.id].strokeWidth = 1
						if ( partnerTextField[partnerPreTarget.id] ) then native.setKeyboardFocus( partnerTextField[partnerPreTarget.id] ) end
						if ( partnerArrow[partnerPreTarget.id] ) then
							partnerArrow[partnerPreTarget.id]:rotate(180)
							local arrow = "partnerArrow"..partnerPreTarget.id
							setStatus[arrow] = "down"
							if ( partnerPreTarget.id == 3 ) then
								ptnrGenderGroup.isVisible = false
							end
							if ( partnerPreTarget.id == 4 or partnerPreTarget.id == 5 or partnerPreTarget.id == 7 ) then
								if ( partnerPreTarget.id == 4 ) then
									ptnrcontinentGroup.isVisible = false
								end
								if ( partnerPreTarget.id == 5 ) then
									ptnrCountryGroup.isVisible = false
								end
								if ( partnerPreTarget.id == 7 ) then
									travelMethodGroup.isVisible = false
								end
								for i = partnerPreTarget.id, #partnerTitleOptions do
									if ( partnerTextField[i] ) then
										partnerTextField[i].isVisible = true
										partnerText[i].isVisible = false
									end
								end
							end
						end

						partnerNowTarget = event.target
						partnerTitleText[partnerNowTarget.id]:setFillColor(unpack(mainColor1))
						partnerBaseLine[partnerNowTarget.id]:setStrokeColor(unpack(mainColor1))
						partnerBaseLine[partnerNowTarget.id].strokeWidth = 2
						if ( partnerTextField[partnerNowTarget.id] ) then native.setKeyboardFocus( partnerTextField[partnerNowTarget.id] ) end
						if ( partnerArrow[partnerNowTarget.id] ) then
							local arrow = "partnerArrow"..partnerNowTarget.id
							partnerArrow[partnerNowTarget.id]:rotate(180)
							setStatus[arrow] = "up"
							if ( partnerNowTarget.id == 3 ) then
								ptnrGenderGroup.isVisible = true
							end
							if ( partnerNowTarget.id == 4 or partnerNowTarget.id == 5 or partnerNowTarget.id == 7 ) then
								if ( partnerNowTarget.id == 4 ) then
									ptnrcontinentGroup.isVisible = true
								end
								if ( partnerNowTarget.id == 5 ) then
									ptnrCountryGroup.isVisible = true
								end
								if ( partnerNowTarget.id == 7 ) then
									travelMethodGroup.isVisible = true
								end
								for i = partnerNowTarget.id, #partnerTitleOptions do
									if ( partnerTextField[i] ) then
										partnerTextField[i].isVisible = false
										partnerText[i].isVisible = true
									end
								end
							end
						end
					else -- 相同的選項被選擇
						partnerTitleText[partnerPreTarget.id]:setFillColor(unpack(wordColor))
						partnerBaseLine[partnerPreTarget.id]:setStrokeColor(unpack(separateLineColor))
						partnerBaseLine[partnerPreTarget.id].strokeWidth = 1
						if ( partnerTextField[partnerPreTarget.id] ) then native.setKeyboardFocus( partnerTextField[nil] ) end
						if ( partnerArrow[partnerPreTarget.id] ) then
							local arrow = "partnerArrow"..partnerPreTarget.id
							partnerArrow[partnerPreTarget.id]:rotate(180)
							setStatus[arrow] = "down"
							if ( partnerPreTarget.id == 3 ) then
								ptnrGenderGroup.isVisible = false
							end
							if ( partnerPreTarget.id == 4 or partnerPreTarget.id == 5 or partnerPreTarget.id == 7 ) then
								if ( partnerPreTarget.id == 4 ) then
									ptnrcontinentGroup.isVisible = false
								end
								if ( partnerPreTarget.id == 5 ) then
									ptnrCountryGroup.isVisible = false
								end
								if ( partnerPreTarget.id == 7 ) then
									travelMethodGroup.isVisible = false
								end
								for i = partnerPreTarget.id, #partnerTitleOptions do
									if ( partnerTextField[i] ) then
										partnerTextField[i].isVisible = true
										partnerText[i].isVisible = true
									end
								end
							end
						end
					end
				end
				partnerPreTarget = partnerNowTarget
				partnerNowTarget = nil
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
					partnerBaseLine[partnerNowTarget.id]:setStrokeColor(unpack(mainColor1))
					partnerBaseLine[partnerNowTarget.id].strokeWidth = 2

					partnerPreTarget = partnerNowTarget
					partnerNowTarget = nil
				elseif (partnerNowTarget == nil and partnerPreTarget ~= nil) then
					if (event.target.id ~= partnerPreTarget.id ) then
						partnerTitleText[partnerPreTarget.id]:setFillColor(unpack(wordColor))
						partnerBaseLine[partnerPreTarget.id]:setStrokeColor(unpack(separateLineColor))
						partnerBaseLine[partnerPreTarget.id].strokeWidth = 1
						if (partnerArrow[partnerPreTarget.id]) then partnerArrow[partnerPreTarget.id]:rotate(180) end

						partnerNowTarget = event.target
						partnerTitleText[partnerNowTarget.id]:setFillColor(unpack(mainColor1))
						partnerBaseLine[partnerNowTarget.id]:setStrokeColor(unpack(mainColor1))
						partnerBaseLine[partnerNowTarget.id].strokeWidth = 2
						if (partnerArrow[partnerNowTarget.id]) then partnerArrow[partnerNowTarget.id]:rotate(180) end

						partnerPreTarget = partnerNowTarget
						partnerNowTarget = nil
					end
				end
			elseif ( phase == "submitted" ) then
				if ( id >= 2 ) then
					partnerScrollView:scrollToPosition( { y = -(partnerBaseLine[5].y) ,time = 0} )
				end
				if ( id == 1 ) then
					partnerText[id].text = partnerTextField[id].text
					native.setKeyboardFocus(partnerTextField[2])
				elseif ( id == 2 ) then
					partnerText[id].text = partnerTextField[id].text
					native.setKeyboardFocus(partnerTextField[6])
				elseif ( id == 6 ) then
					partnerText[id].text = partnerTextField[id].text
					if ( partnerText[id].text == "" ) then partnerText[id].text = "請填寫您的通用口語" end
					native.setKeyboardFocus(partnerTextField[8])
				elseif ( id == 8 ) then
					partnerText[id].text = partnerTextField[id].text
					if ( partnerText[id].text == "" ) then partnerText[id].text = "請填寫於此" end
					native.setKeyboardFocus(partnerTextField[9])
				elseif ( id == 9 ) then
					partnerText[id].text = partnerTextField[id].text
					if ( partnerText[id].text == "" ) then partnerText[id].text = "關於我..." end
					native.setKeyboardFocus(nil)
					partnerTitleText[id]:setFillColor(unpack(wordColor))
					partnerBaseLine[id]:setStrokeColor(unpack(separateLineColor))
					partnerScrollView:scrollToPosition( { y = 0 ,time = 0} )
					for i = 1, #partnerTitleOptions do
						if ( partnerTextField[i] ) then
							partnerTextField[i].isVisible = true
							partnerText[i].isVisible = false
						end
					end
				end
			elseif ( phase == "ended" ) then
				if ( id == 1 ) then
					partnerText[id].text = partnerTextField[id].text
				elseif ( id == 2 ) then
					partnerText[id].text = partnerTextField[id].text
				elseif ( id == 6 ) then
					partnerText[id].text = partnerTextField[id].text
					if ( partnerText[id].text == "" ) then partnerText[id].text = "請填寫您的通用口語" end
				elseif ( id == 8 ) then
					partnerText[id].text = partnerTextField[id].text
					if ( partnerText[id].text == "" ) then partnerText[id].text = "請填寫於此" end
				elseif ( id == 9 ) then
					partnerText[id].text = partnerTextField[id].text
					if ( partnerText[id].text == "" ) then partnerText[id].text = "關於我..." end
				end
			end
		end
	-- partnerScrollView內容
		local ptnrCountryCover
		for i = 1, #partnerTitleOptions do
			-- 必填區塊
				if (i == 1) then
					ptnrHintBase[i] = display.newRect( partnerGroup, partnerBaseX, partnerBaseY, partnerBaseWidth, screenH/40)
					ptnrHintBase[i].anchorY = 0
					partnerBaseY = partnerBaseY+ptnrHintBase[i].y+ptnrHintBase[i].contentHeight
					ptnrHintText[i] = display.newText({
						text = "*必填",
						x = ceil(49*wRate),
						y = ptnrHintBase[i].y+ptnrHintBase[i].contentHeight*0.5,
						font = getFont.font,
						fontSize = 10,
					})
					partnerGroup:insert(ptnrHintText[i])
					ptnrHintText[i]:setFillColor(unpack(separateLineColor))
					ptnrHintText[i].anchorX = 0
				end		
			-- 白底
				local partnerBase = display.newRect( partnerGroup, partnerBaseX, partnerBaseY, partnerBaseWidth, partnerBaseHeight)
				partnerBase.anchorY = 0
				partnerBase.id = i
				partnerBase:addEventListener( "touch", partnerListener)
				--partnerBase:setFillColor( math.random(), math.random(), math.random() )
			-- 顯示文字-抬頭內容
				partnerTitleText[i] = display.newText({
					text = partnerTitleOptions[i],
					font = getFont.font,
					fontSize = 10,
					x = ceil(49*wRate),
					y = partnerBase.y,
				})
				partnerGroup:insert(partnerTitleText[i])
				partnerTitleText[i]:setFillColor(unpack(wordColor))
				partnerTitleText[i].anchorX = 0
				partnerTitleText[i].anchorY = 0
			-- 輸入欄位(隱藏的顯示文字)或是選單
				if (i ~= 3 and  i ~= 4 and i ~= 5 and i ~= 7) then
					table.insert( ptnrTextReverseTable, i )
					partnerText[i] = display.newText({
						parent = partnerGroup,
						text = ptnrList[i]:match(pattern) or "",
						font = getFont.font,
						fontSize = 12,
					})
					if ( not getSwitchIsOn["mate"] ) then
						partnerText[i].isVisible = true
					else
						partnerText[i].isVisible = false
					end
					partnerText[i]:setFillColor(unpack(wordColor))
					partnerText[i].anchorX = 0
					partnerText[i].anchorY = 0

					partnerTextField[i] = native.newTextField( partnerTitleText[i].x, partnerTitleText[i].y+partnerTitleText[i].contentHeight, partnerBaseWidth*0.7, partnerBaseHeight*0.4)
					partnerGroup:insert(partnerTextField[i])
					partnerTextField[i].anchorX = 0
					partnerTextField[i].anchorY = 0
					partnerTextField[i].id = i
					partnerTextField[i].text = ptnrList[i]:match(pattern) or ""
					partnerTextField[i].hasBackground = false
					partnerTextField[i].font = getFont.font
					partnerTextField[i]:resizeFontToFitHeight()
					partnerTextField[i]:setSelection(0,0)
					partnerTextField[i]:setReturnKey( "next" )
					partnerTextField[i]:setTextColor(unpack(wordColor))
					partnerTextField[i].isVisible = false
					if (i == 6) then
						partnerTextField[i].placeholder = "請填寫您的通用口語"
						if ( partnerText[i].text == "" ) then partnerText[i].text = "請填寫您的通用口語" end
					elseif (i == 8) then
						partnerTextField[i].placeholder = "請填寫於此"
						if ( partnerText[i].text == "" ) then partnerText[i].text = "請填寫於此" end
					elseif (i == 9) then
						partnerTextField[i].placeholder = "關於我..."
						partnerTextField[i]:setReturnKey( "done" )
						if ( partnerText[i].text == "" ) then partnerText[i].text = "關於我..." end
					end
					partnerTextField[i]:addEventListener("userInput",partnerTextInput)

					partnerText[i].x = partnerTextField[i].x+1
					partnerText[i].y = partnerTextField[i].y+1
					partnerText[i].size = partnerTextField[i].size
				else
					partnerSelection[i] = display.newText({
						text = ptnrList[i]:match(pattern) or "請選擇",
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
					partnerArrow[i].width = partnerArrow[i].width*0.05
					partnerArrow[i].height = partnerArrow[i].height*0.05
					local arrow = "partnerArrow"..i
					setStatus[arrow] = "down"
				end		
			--底線
				partnerBaseLine[i] = display.newLine( ceil(49*wRate), partnerBase.y+partnerBase.contentHeight*0.8, screenW+ox+ox-ceil(49*wRate), partnerBase.y+partnerBase.contentHeight*0.8)
				partnerGroup:insert(partnerBaseLine[i])
				partnerBaseLine[i].strokeWidth = 1
				partnerBaseLine[i]:setStrokeColor(unpack(separateLineColor))
				partnerBaseY = partnerBaseY+partnerBaseHeight
				
				if ( i == 5 ) then
					ptnrCountryCover = display.newRect( partnerGroup, partnerBase.x, partnerBase.y, partnerBase.contentWidth, partnerBase.contentHeight)
					ptnrCountryCover:setFillColor( 1, 1, 1, 0.7)
					ptnrCountryCover.anchorY = 0
					ptnrCountryCover:addEventListener( "touch", function () return true; end)
				end	
		end
	-- 同意免責聲明 --
	-- 我同意checkBox
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
		local function checkboxListener( event )
			if ( event.target.isOn == false ) then
				getSwitchIsOn["mate"] = false
				ptnrSwitch:setState( { isOn = false, isAnimated = true })
				switchStatusText.text = "關閉"
				switchStatusText:setFillColor(unpack(wordColor))
				partnerScrollViewCover.isVisible = true
				for i = 1, #partnerTitleOptions do
					if ( partnerTextField[i] ) then partnerTextField[i].isVisible = false end
				end
				if ( ptnrHintText[1].text == "此為必填區塊" ) then
					ptnrHintText[1].text = "*必填"
					ptnrHintText[1]:setFillColor(unpack(separateLineColor))
				end
			else
				getSwitchIsOn["mate"] = true
				ptnrSwitch:setState( { isOn = true, isAnimated = true })
				switchStatusText.text = "開啟"
				switchStatusText:setFillColor(unpack(mainColor1))
				partnerScrollViewCover.isVisible = false
				for i = 1, #partnerTitleOptions do
					if ( partnerTextField[i] ) then partnerTextField[i].isVisible = true end
				end
			end
			return true
		end
		local agreeCheckBox = widget.newSwitch({
				id = "agreeCheckBox",
				style = "checkbox",
				x = ceil(50*wRate),
				y = partnerBaseY+floor(24*hRate),
				sheet = checkboxSheet,
				frameOff = 2,
				frameOn = 1,
				onRelease = checkboxListener
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
		agreeText:addEventListener( "touch", function ( event )
			local phase = event.phase
			if ( phase == "ended" ) then
				if ( agreeCheckBox.isOn == false ) then
					agreeCheckBox:setState( { isOn = true, onComplete = checkboxListener })
				else
					agreeCheckBox:setState( { isOn = false, onComplete = checkboxListener })
				end
			end
			return true
		end)
	-- 顯示文字-"<旅伴免責聲明>"
		local disclaimeText = display.newText({
			parent = partnerGroup,
			text = "<旅伴免責聲明>",
			font = getFont.font,
			fontSize = 12,
			x = agreeText.x+agreeText.contentWidth+ceil(10*wRate),
			y = agreeText.y
		})
		disclaimeText:setFillColor(unpack(subColor2))
		disclaimeText.anchorX = 0
		disclaimeText:addEventListener("touch", function (event)
				local phase = event.phase
				if (phase == "ended") then
					for i = 1, #partnerTitleOptions do
						if (partnerTextField[i]) then partnerTextField[i].isVisible = false end
					end
					local options = { isModal = true, effect = "fromLeft", time = 300 }
					composer.showOverlay( "disclaimer", options )
				end
				return true
		end)
		
		local ptnrCount = 1
		local ptnrDifferHeight = 0
		ptnrScrollHeight = agreeCheckBox.y+agreeCheckBox.contentHeight
		if ( ptnrScrollHeight > partnerScrollView.contentHeight ) then
			partnerScrollView:setScrollHeight(ptnrScrollHeight)
			ptnrDifferHeight = ptnrScrollHeight-partnerScrollView.contentHeight
			while ( ptnrCount < #partnerTitleOptions ) do
				if ( partnerTextField[ptnrCount] and partnerTextField[ptnrCount].y < ptnrDifferHeight) then 
					ptnrDifferNum = ptnrDifferNum+1
					ptnrCount = ptnrCount+1
				else
					break
				end
			end
		end
	
	-- 開關 --
	-- 開關監聽事件
		local function partnerSysSwitchListener( event )
			local phase = event.phase
			if (phase == "ended") then
				if ( event.target.isOn == true ) then
					getSwitchIsOn["mate"] = true
					agreeCheckBox:setState( { isOn = true })
					switchStatusText.text = "開啟"
					switchStatusText:setFillColor(unpack(mainColor1))
					partnerScrollViewCover.isVisible = false
					for i = 1, #partnerTitleOptions do
						if ( partnerTextField[i] ) then
							partnerTextField[i].isVisible = true
							partnerText[i].isVisible = false
						end
					end
				else
					getSwitchIsOn["mate"] = false
					agreeCheckBox:setState( { isOn = false })
					switchStatusText.text = "關閉"
					switchStatusText:setFillColor(unpack(wordColor))
					partnerScrollViewCover.isVisible = true
					local x,y = partnerScrollView:getContentPosition()
					if ( y ~= 0) then
						partnerScrollView:scrollToPosition( { y = 0, time = 0 } )
					end
					for i = 1, #partnerTitleOptions do
						partnerTitleText[i]:setFillColor(unpack(wordColor))
						partnerBaseLine[i]:setStrokeColor(unpack(separateLineColor))
						partnerBaseLine[i].strokeWidth = 1
						
						if ( partnerTextField[i] ) then
							partnerTextField[i].isVisible = false
							partnerText[i].isVisible = true
						end
						
						local arrow = "partnerArrow"..i
						if ( setStatus[arrow] ) then
							if ( setStatus[arrow] == "up" ) then
								setStatus[arrow] = "down"
								partnerArrow[i]:rotate(180)
								partnerNowTarget = nil
								partnerPreTarget = nil
							end
							if ( travelMethodGroup.isVisible == true ) then
								travelMethodGroup.isVisible = false
							elseif ( ptnrcontinentGroup.isVisible == true ) then
								ptnrcontinentGroup.isVisible = false
							elseif ( ptnrCountryGroup.isVisible == true ) then
								ptnrCountryGroup.isVisible = false
							elseif ( ptnrGenderGroup.isVisible == true ) then
								ptnrGenderGroup.isVisible = false
							end
						end
					end
					if ( ptnrHintText[1].text == "此為必填區塊" ) then
						ptnrHintText[1].text = "*必填"
						ptnrHintText[1]:setFillColor(unpack(separateLineColor))
					end			
				end		
			end
			print(getSwitchIsOn["mate"])
			return true
		end
	-- 旅伴系統開關
		ptnrSwitch = widget.newSwitch({
			id = "ptnrSwitch",
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
		travelMateGroup:insert(ptnrSwitch)
		ptnrSwitch:scale(0.6,0.6)
		ptnrSwitch.anchorX = 1
		ptnrSwitch.x = (screenW+ox)-ceil(ptnrSwitch.contentWidth*0.3)-ceil(45*wRate)
		ptnrSwitch.y = trvlMateSwitchBase.y+trvlMateSwitchBase.contentHeight*0.5
		ptnrSwitch:setState(switchOptions)
		if ( not getSwitchIsOn["mate"] ) then
			ptnrSwitch:setState( { isOn = false, isAnimated = true} )
			agreeCheckBox:setState( { isOn = false, isAnimated = true} )
		else
			ptnrSwitch:setState( { isOn = true, isAnimated = true} )
			agreeCheckBox:setState( { isOn = true, isAnimated = true} )
		end
		-- 開關狀態文字定位
		switchStatusText.x = ptnrSwitch.x-ceil(ptnrSwitch.contentWidth*0.3)-ceil(30*wRate)
		switchStatusText.y = ptnrSwitch.y
	------------------ 旅伴下拉式選單元件 -------------------
	-- 旅行方式選單 --
	-- 陰影外框
		partnerGroup:insert(travelMethodGroup)
		local travelMethodFrame = display.newImageRect( travelMethodGroup, frameName, frameWidth, (optionBaseHeight+optionPadding)*#travelMethod+optionPadding )
		travelMethodFrame:addEventListener( "touch", function (event) return true; end)
		travelMethodFrame.anchorY = 0
		travelMethodFrame.x = partnerBaseX
		travelMethodFrame.y = partnerBaseLine[7].y+1
		local travelMethodText = {}
		local travelMethodCancel = false
		local travelNowTarget, travelPrevTarget = nil, nil
	-- 旅行方式監聽事件
		local function travelMethodListener( event )
			local phase = event.phase
			if ( phase == "began" ) then
				if ( travelMethodCancel == true ) then
					travelMethodCancel = false
				end
				if ( travelNowTarget == nil and travelPrevTarget == nil ) then
					travelNowTarget = event.target
					travelNowTarget:setFillColor( 0, 0, 0, 0.2)
					travelMethodText[travelNowTarget.id]:setFillColor(unpack(subColor2))
				end
				if ( travelNowTarget == nil and travelPrevTarget ~= nil ) then
					if ( event.target ~= travelPrevTarget ) then
						travelPrevTarget:setFillColor(1)
						travelMethodText[travelPrevTarget.id]:setFillColor(unpack(wordColor))

						travelNowTarget = event.target
						travelNowTarget:setFillColor( 0, 0, 0, 0.2)
						travelMethodText[travelNowTarget.id]:setFillColor(unpack(subColor2))
					end
				end
			elseif ( phase == "moved" ) then
				travelMethodCancel = true
				if ( travelNowTarget ~= nil ) then
					travelNowTarget = event.target
					travelNowTarget:setFillColor(1)
					travelMethodText[travelNowTarget.id]:setFillColor(unpack(wordColor))
					travelNowTarget = nil
					if ( travelPrevTarget ~= nil ) then
						travelMethodText[travelPrevTarget.id]:setFillColor(unpack(subColor2))
					end
				end
			elseif ( phase == "ended" and travelMethodCancel == false and travelNowTarget ~= nil ) then
				partnerArrow[7]:rotate(180)
				setStatus["partnerArrow7"] = "down"
				partnerTitleText[7]:setFillColor(unpack(wordColor))
				partnerSelection[7].text = travelMethodText[travelNowTarget.id].text
				partnerBaseLine[7]:setStrokeColor(unpack(separateLineColor))
				partnerBaseLine[7].strokeWidth = 1
				for i = 7, #partnerTitleOptions do 
					if ( partnerTextField[i] ) then
						partnerTextField[i].isVisible = true
						partnerText[i].isVisible = false
					end
				end
				partnerPreTarget = partnerNowTarget
				partnerNowTarget = nil
				travelMethodGroup.isVisible = false
				
				travelNowTarget:setFillColor(1)
				travelPrevTarget = travelNowTarget
				travelNowTarget = nil
			end
			return true
		end
	-- 旅行方式選單內容
		for i = 1, #travelMethod do
			local travelMethodBase = display.newRect( travelMethodGroup, partnerBaseX, optionPadding+travelMethodFrame.y+(optionPadding+optionBaseHeight)*(i-1), optionBaseWidth, optionBaseHeight )
			travelMethodBase.anchorY = 0
			travelMethodBase.id = i
			travelMethodBase:addEventListener("touch", travelMethodListener)
			--travelMethodBase:setFillColor( math.random(), math.random(), math.random() )
			travelMethodText[i] = display.newText({
				parent = travelMethodGroup,
				text = travelMethod[i],
				font = getFont.font,
				fontSize = 12,
				x = travelMethodBase.x,
				y = travelMethodBase.y+travelMethodBase.contentHeight*0.5,
			})
			if ( travelMethodText[i].text == partnerSelection[7].text ) then
				travelMethodText[i]:setFillColor(unpack(subColor2))
				travelPrevTarget = travelMethodBase
			else
				travelMethodText[i]:setFillColor(unpack(wordColor))
			end
		end
		travelMethodGroup.isVisible = false

	-- 洲別/國家選單 --
	-- 陰影外框
		partnerGroup:insert(ptnrcontinentGroup)
		local contientNum = partnerGroup.numChildren
		local contientFrame = display.newImageRect( ptnrcontinentGroup, frameName, frameWidth, (optionBaseHeight+optionPadding)*#continentOptions+optionPadding )
		contientFrame:addEventListener( "touch", function (event) return true; end)
		contientFrame.anchorY = 0
		contientFrame.x = partnerBaseX
		contientFrame.y = partnerBaseLine[4].y+1
	-- 國家選單內容監聽事件
		local countryScrollHeight = 0
		local countryText = {}
		local countryCancel = false
		local countryNowTarget, countryPrevTarget = nil, nil
		local countryScrollView
		local function countryListener( event )
			local phase = event.phase
			if ( phase == "began" ) then
				if ( countryCancel == true ) then
					countryCancel = false
				end
				if ( countryNowTarget == nil and countryPrevTarget == nil ) then
					countryNowTarget = event.target
					countryNowTarget:setFillColor( 0, 0, 0, 0.2)
					countryText[countryNowTarget.id]:setFillColor(unpack(subColor2))
				end
				if ( countryNowTarget == nil and countryPrevTarget ~= nil ) then
					if ( event.target ~= countryPrevTarget ) then
						countryPrevTarget:setFillColor(1)
						countryText[countryPrevTarget.id]:setFillColor(unpack(wordColor))

						countryNowTarget = event.target
						countryNowTarget:setFillColor( 0, 0, 0, 0.2)
						countryText[countryNowTarget.id]:setFillColor(unpack(subColor2))
					end
				end
			elseif ( phase == "moved" ) then
				countryCancel = true
				local dy = math.abs(event.yStart-event.y)
				if ( dy > 10 ) then
					countryScrollView:takeFocus(event)
				end
				if ( countryNowTarget ~= nil ) then
					countryNowTarget = event.target
					countryNowTarget:setFillColor(1)
					countryText[countryNowTarget.id]:setFillColor(unpack(wordColor))
					countryNowTarget = nil
					if ( countryPrevTarget ~= nil ) then
						countryText[countryPrevTarget.id]:setFillColor(unpack(subColor2))
					end
				end
			elseif ( phase == "ended" and countryCancel == false and countryNowTarget ~= nil ) then
				ptnrCountryGroup.isVisible = false
				-- mainScrollView選項事件
				partnerArrow[5]:rotate(180)
				setStatus["partnerArrow5"] = "down"
				partnerTitleText[5]:setFillColor(unpack(wordColor))
				partnerSelection[5].text = countryText[countryNowTarget.id].text
				partnerBaseLine[5]:setStrokeColor(unpack(separateLineColor))
				partnerBaseLine[5].strokeWidth = 1
				for i = 5, #partnerTitleOptions do 
					if ( partnerTextField[i] ) then
						partnerTextField[i].isVisible = true
						partnerText[i].isVisible = false 
					end
				end
				
				partnerPreTarget = partnerNowTarget
				partnerNowTarget = nil

				countryNowTarget:setFillColor(1)
				countryPrevTarget = countryNowTarget
				countryNowTarget = nil
			end
			return true
		end
	-- 洲別選單內容監聽事件
		local continentText = {}
		local contientCancel = false
		local contientNowTarget, contientPrevTarget = nil, nil
		local function contientListener( event )
			local phase = event.phase
			if ( phase == "began" ) then
				if ( contientCancel == true ) then
					contientCancel = false
				end
				if ( contientNowTarget == nil and contientPrevTarget == nil ) then
					contientNowTarget = event.target
					contientNowTarget:setFillColor( 0, 0, 0, 0.2)
					continentText[contientNowTarget.id]:setFillColor(unpack(subColor2))
				end
				if ( contientNowTarget == nil and contientPrevTarget ~= nil ) then
					if ( event.target ~= contientPrevTarget ) then
						contientPrevTarget:setFillColor(1)
						continentText[contientPrevTarget.id]:setFillColor(unpack(wordColor))

						contientNowTarget = event.target
						contientNowTarget:setFillColor( 0, 0, 0, 0.2)
						continentText[contientNowTarget.id]:setFillColor(unpack(subColor2))
					end
				end
			elseif ( phase == "moved" ) then
				contientCancel = true
				if ( contientNowTarget ~= nil ) then
					contientNowTarget = event.target
					contientNowTarget:setFillColor(1)
					continentText[contientNowTarget.id]:setFillColor(unpack(wordColor))
					contientNowTarget = nil
					if ( contientPrevTarget ~= nil ) then
						continentText[contientPrevTarget.id]:setFillColor(unpack(subColor2))
					end
				end
			elseif ( phase == "ended" and contientCancel == false and contientNowTarget ~= nil  ) then
				ptnrcontinentGroup.isVisible = false
				ptnrCountryCover.isVisible = false
				-- mainScrollView選項事件
				partnerArrow[4]:rotate(180)
				setStatus["partnerArrow4"] = "down"
				partnerTitleText[4]:setFillColor(unpack(wordColor))
				if ( continentText[contientNowTarget.id].text ~= partnerSelection[4].text ) then
					partnerSelection[5].text = "請選擇"
					countryNowTarget = nil
					countryPrevTarget = nil
				end
				partnerSelection[4].text = continentText[contientNowTarget.id].text
				partnerBaseLine[4]:setStrokeColor(unpack(separateLineColor))
				partnerBaseLine[4].strokeWidth = 1
				for i = 4, #partnerTitleOptions do 
					if ( partnerTextField[i] ) then
						partnerTextField[i].isVisible = true
						partnerText[i].isVisible = false
					end
				end
				partnerPreTarget = partnerNowTarget
				partnerNowTarget = nil

				contientNowTarget:setFillColor(1)
				contientPrevTarget = contientNowTarget
				contientNowTarget = nil
				-- 因為要選完洲別才會產生相對應的國家，所以國家選單要在選完洲別後才會產生 --
					local continentDecode = json.decode(continentJson)
					local continentDecodeValue = partnerSelection[4].text
					local ptnrCountryListOptions = {}
					--local countryIdList = {}
					local ptnrCountryEnglishList = {}
					local function getCountryInfo( event )
						if ( event.isError ) then
							print( "Network Error: "..event.response )
						else
							--print( "Response: "..event.response )
							local countryJsonData = json.decode( event.response )
							for key, countryTableJson in pairs(countryJsonData["list"]) do
								table.insert( ptnrCountryListOptions, countryTableJson["desc"])
								--table.insert( countryIdList, countryTableJson["id"])
								table.insert( ptnrCountryEnglishList, countryTableJson["country"])
							end
						end
						-- 旅伴國家選單
							if ( ptnrCountryGroup ) then
								ptnrCountryGroup:removeSelf()
								ptnrCountryGroup = nil
								ptnrCountryGroup = display.newGroup()
							end
						-- 陰影外框
							local maxCountryNum = 6
							partnerGroup:insert( contientNum, ptnrCountryGroup )
							local countryFrame = display.newImageRect( ptnrCountryGroup, frameName, frameWidth, (optionBaseHeight+optionPadding)*maxCountryNum+optionPadding )
							countryFrame:addEventListener( "touch", function (event) return true; end)
							countryFrame.anchorY = 0
							countryFrame.x = partnerBaseX
							countryFrame.y = partnerBaseLine[5].y+1
						-- scrollview
							countryScrollView = widget.newScrollView({
								id = "countryScrollView",
								x = countryFrame.x,
								y = countryFrame.y,
								width = optionBaseWidth,
								height = countryFrame.contentHeight*59/60,
								horizontalScrollDisabled = true,
								isBounceEnabled = false
							})
							countryScrollView.anchorY = 0
							ptnrCountryGroup:insert(countryScrollView)
							local countryScrollGroup = display.newGroup()
							countryScrollView:insert(countryScrollGroup)
						-- 國家選單內容
							for i = 1, #ptnrCountryListOptions do
								
								local countryBase = display.newRect( countryScrollGroup, countryScrollView.contentWidth*0.5, optionPadding+(optionPadding+optionBaseHeight)*(i-1), optionBaseWidth, optionBaseHeight )
								countryBase.anchorY = 0
								countryBase.id = i
								countryBase:addEventListener( "touch", countryListener )
								--countryBase:setFillColor( math.random(), math.random(), math.random() )
								
								countryText[i] = display.newText({
									parent = countryScrollGroup,
									text = ptnrCountryListOptions[i],
									font = getFont.font,
									fontSize = 12,
									x = countryBase.x,
									y = countryBase.y+countryBase.contentHeight*0.5,
								})
								countryText[i]:setFillColor(unpack(wordColor))
								countryScrollHeight = countryBase.y+countryBase.contentHeight
							end
							if ( countryScrollHeight > countryScrollView.contentHeight ) then
								countryScrollView:setScrollHeight(countryScrollHeight+optionPadding)
							end
							ptnrCountryGroup.isVisible = false
					end
					local getCountryUrl = optionsTable.getCountryByContinentUrl..continentDecode[continentDecodeValue]
					network.request( getCountryUrl, "GET", getCountryInfo)				
			end
			return true
		end
	-- 洲別選單內容
		for i = 1, #continentOptions do
			
			local contientBase = display.newRect( ptnrcontinentGroup, contientFrame.x, optionPadding+contientFrame.y+(optionPadding+optionBaseHeight)*(i-1), optionBaseWidth, optionBaseHeight )
			contientBase.anchorY = 0
			contientBase.id = i
			contientBase:addEventListener( "touch", contientListener)
			--contientBase:setFillColor( math.random(), math.random(), math.random() )
			
			continentText[i] = display.newText({
				parent = ptnrcontinentGroup,
				text = continentOptions[i],
				font = getFont.font,
				fontSize = 12,
				x = contientBase.x,
				y = contientBase.y+contientBase.contentHeight*0.5,
			})
			if ( continentText[i].text == partnerSelection[4].text ) then
				continentText[i]:setFillColor(unpack(subColor2))
				contientPrevTarget = contientBase
				ptnrCountryCover.isVisible = false
				local continentDecode = json.decode(continentJson)
				local continentDecodeValue = partnerSelection[4].text
				local ptnrCountryListOptions = {}
				--local countryIdList = {}
				local ptnrCountryEnglishList = {}
				local function getCountryInfo( event )
					if ( event.isError ) then
						print( "Network Error: "..event.response )
					else
						--print( "Response: "..event.response )
						local countryJsonData = json.decode( event.response )
						for key, countryTableJson in pairs(countryJsonData["list"]) do
							table.insert( ptnrCountryListOptions, countryTableJson["desc"])
							--table.insert( countryIdList, countryTableJson["id"])
							table.insert( ptnrCountryEnglishList, countryTableJson["country"])
						end
					end
					-- 旅伴國家選單
						if ( ptnrCountryGroup ) then
							ptnrCountryGroup:removeSelf()
							ptnrCountryGroup = nil
							ptnrCountryGroup = display.newGroup()
						end
					-- 陰影外框
						local maxCountryNum = 6
						partnerGroup:insert( contientNum, ptnrCountryGroup )
						local countryFrame = display.newImageRect( ptnrCountryGroup, frameName, frameWidth, (optionBaseHeight+optionPadding)*maxCountryNum+optionPadding )
						countryFrame:addEventListener( "touch", function (event) return true; end)
						countryFrame.anchorY = 0
						countryFrame.x = partnerBaseX
						countryFrame.y = partnerBaseLine[5].y+1
					-- scrollview
						countryScrollView = widget.newScrollView({
							id = "countryScrollView",
							x = countryFrame.x,
							y = countryFrame.y,
							width = optionBaseWidth,
							height = countryFrame.contentHeight*59/60,
							horizontalScrollDisabled = true,
							isBounceEnabled = false
						})
						countryScrollView.anchorY = 0
						ptnrCountryGroup:insert(countryScrollView)
						local countryScrollGroup = display.newGroup()
						countryScrollView:insert(countryScrollGroup)
					-- 國家選單內容
						for i = 1, #ptnrCountryListOptions do
							
							local countryBase = display.newRect( countryScrollGroup, countryScrollView.contentWidth*0.5, optionPadding+(optionPadding+optionBaseHeight)*(i-1), optionBaseWidth, optionBaseHeight )
							countryBase.anchorY = 0
							countryBase.id = i
							countryBase:addEventListener( "touch", countryListener )
							--countryBase:setFillColor( math.random(), math.random(), math.random() )
							
							countryText[i] = display.newText({
								parent = countryScrollGroup,
								text = ptnrCountryListOptions[i],
								font = getFont.font,
								fontSize = 12,
								x = countryBase.x,
								y = countryBase.y+countryBase.contentHeight*0.5,
							})
							if ( countryText[i].text == partnerSelection[5].text ) then
								countryText[i]:setFillColor(unpack(subColor2))
								countryPrevTarget = countryBase
							else
								countryText[i]:setFillColor(unpack(wordColor))
							end
							countryScrollHeight = countryBase.y+countryBase.contentHeight
						end
						if ( countryScrollHeight > countryScrollView.contentHeight ) then
							countryScrollView:setScrollHeight(countryScrollHeight+optionPadding)
						end
						ptnrCountryGroup.isVisible = false
				end
				local getCountryUrl = optionsTable.getCountryByContinentUrl..continentDecode[continentDecodeValue]
				network.request( getCountryUrl, "GET", getCountryInfo)
			else
				continentText[i]:setFillColor(unpack(wordColor))
			end
		end
		ptnrcontinentGroup.isVisible = false

	-- 性別選單 --
	-- 陰影外框
		partnerGroup:insert(ptnrGenderGroup)
		local genderFrame = display.newImageRect( ptnrGenderGroup, frameName, frameWidth, (optionBaseHeight+optionPadding)*#genderOptions+optionPadding )
		genderFrame:addEventListener( "touch", function (event) return true; end)
		genderFrame.anchorY = 0
		genderFrame.x = partnerBaseX
		genderFrame.y = partnerBaseLine[3].y+1
	-- 性別下拉選單內容監聽事件
		local genderText = {}
		local genderCancel = false
		local genderNowTarget, genderPrevTarget = nil, nil
		local function genderListener( event )
			local phase = event.phase
			if ( phase == "began" ) then
				if ( genderCancel == true ) then
					genderCancel = false
				end
				if ( genderNowTarget == nil and genderPrevTarget == nil ) then
					genderNowTarget = event.target
					genderNowTarget:setFillColor( 0, 0, 0, 0.2)
					genderText[genderNowTarget.id]:setFillColor(unpack(subColor2))
				end
				if ( genderNowTarget == nil and genderPrevTarget ~= nil ) then
					if ( event.target ~= genderPrevTarget ) then
						genderPrevTarget:setFillColor(1)
						genderText[genderPrevTarget.id]:setFillColor(unpack(wordColor))

						genderNowTarget = event.target
						genderNowTarget:setFillColor( 0, 0, 0, 0.2)
						genderText[genderNowTarget.id]:setFillColor(unpack(subColor2))
					end
				end
			elseif ( phase == "moved" ) then
				genderCancel = true
				if ( genderNowTarget ~= nil ) then
					genderNowTarget = event.target
					genderNowTarget:setFillColor(1)
					genderText[genderNowTarget.id]:setFillColor(unpack(wordColor))
					genderNowTarget = nil
					if ( genderPrevTarget ~= nil ) then
						genderText[genderPrevTarget.id]:setFillColor(unpack(subColor2))
					end
				end
			elseif ( phase == "ended" and genderCancel == false and genderNowTarget ~= nil ) then
				partnerArrow[3]:rotate(180)
				setStatus["partnerArrow3"] = "down"
				partnerTitleText[3]:setFillColor(unpack(wordColor))
				partnerSelection[3].text = genderText[genderNowTarget.id].text
				partnerBaseLine[3]:setStrokeColor(unpack(separateLineColor))
				partnerBaseLine[3].strokeWidth = 1
				
				partnerPreTarget = partnerNowTarget
				partnerNowTarget = nil
				ptnrGenderGroup.isVisible = false
				
				genderNowTarget:setFillColor(1)
				genderPrevTarget = genderNowTarget
				genderNowTarget = nil
			end
			return true
		end
	-- 性別選單內容
		for i = 1, #genderOptions do
			local genderBase = display.newRect( ptnrGenderGroup, partnerBaseX, optionPadding+genderFrame.y+(optionPadding+optionBaseHeight)*(i-1), optionBaseWidth, optionBaseHeight )
			genderBase.anchorY = 0
			genderBase.id = i
			genderBase:addEventListener("touch", genderListener)
			--genderBase:setFillColor( math.random(), math.random(), math.random() )
			genderText[i] = display.newText({
				parent = ptnrGenderGroup,
				text = genderOptions[i],
				font = getFont.font,
				fontSize = 12,
				x = genderBase.x,
				y = genderBase.y+genderBase.contentHeight*0.5,
			})
			if ( genderText[i].text == partnerSelection[3].text ) then
				genderText[i]:setFillColor(unpack(subColor2))
				genderPrevTarget = genderBase
			else
				genderText[i]:setFillColor(unpack(wordColor))
			end
		end
		ptnrGenderGroup.isVisible = false
	------------------ 抬頭元件 -------------------	
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
			defaultFile = "assets/transparent.png",
			onRelease = function ( event )
				native.showAlert( "", "是否要更改現在的資訊?", { "確定", "取消" },
					function ( event )
						if ( event.action == "clicked" ) then
							local accessToken
							if ( composer.getVariable("accessToken") ) then
								if ( token.getAccessToken() and token.getAccessToken() ~= composer.getVariable("accessToken") ) then
									composer.setVariable( "accessToken", token.getAccessToken() )
								end
								accessToken = composer.getVariable("accessToken")
							end
							local headers = {}
							local body
							local params = {}
							local i = event.index
							if ( i == 1) then
								if ( not getSwitchIsOn["mate"] ) then
									if ( infoSelection[5].text == "請選擇" or infoSelection[6].text == "請選擇" or infoSelection[7].text == "請選擇" or infoTextField[10].text == "") then
										
										native.showAlert( "", "尚有資訊未填寫完整，請再次檢查", {"確定"} )

										if ( infoSelection[5].text == "請選擇" ) then
											infoHintText[5]:setFillColor( unpack(hintAlertColor) )
											infoHintText[5].text = "此為必填區塊"
										end
										if ( infoSelection[6].text == "請選擇" ) then
											infoHintText[6]:setFillColor( unpack(hintAlertColor) )
											infoHintText[6].text = "此為必填區塊"
										end
										if ( infoSelection[7].text == "請選擇" ) then
											infoHintText[7]:setFillColor( unpack(hintAlertColor) )
											infoHintText[7].text = "此為必填區塊"
										end
										if ( infoTextField[10].text == "" ) then
											infoHintText[10]:setFillColor( unpack(hintAlertColor) )
											infoHintText[10].text = "此為必填區塊"
										end
									else
										print("finished")
										-- 個人資訊
										infoFile = io.open( infoPath, "w" )
										infoFile:write( "chFirstName="..infoTextField[1].text.."\n", "chLastName="..infoTextField[2].text.."\n", "enFisrtName="..infoTextField[3].text.."\n", "enLastName="..infoTextField[4].text.."\n", "gender="..infoSelection[5].text.."\n", "contient="..infoSelection[6].text.."\n", "country="..infoSelection[7].text.."\n", "areaCode="..infoSelection[8].text.."\n", "mobile="..infoTextField[9].text.."\n", "email="..infoTextField[10].text)
										--infroList = { chFirstName = infoTextField[1].text, chLastName = infoTextField[2].text, enFisrtName = infoTextField[3].text, enLastName = infoTextField[4].text, gender = infoSelection[5].text, contient = infoSelection[6].text, country = infoSelection[7].text, areaCode = infoSelection[8].text, mobile = infoTextField[9].text, email = infoTextField[10].text }
										--infoFile:write(json.encode(infoList))
										io.close(infoFile)
										infoFile = nil

										-- 旅伴開關
										switchFile = io.open( switchPath, "w" )
										--switchFile:write( "isOn="..getSwitchIsOn )
										switchFile:write(json.encode(getSwitchIsOn))
										io.close(switchFile)
										switchFile = nil

										local setGender
										if ( infoSelection[5].text == "男" ) then
											setGender = "MALE"
										else
											setGender = "FEMALE"
										end

										body = "chFirstName="..infoTextField[1].text.."&chLastName="..infoTextField[2].text.."&enFirsName="..infoTextField[3].text.."&enLastName="..infoTextField[4].text.."&country="..setCountry.."&mobile="..infoTextField[9].text.."&email="..infoTextField[10].text.."&gender="..setGender
										print(body)

										composer.gotoScene("PC_personalCenter", { effect = "slideLeft", time = 300} )
									end
								else
									if ( partnerTextField[1].text == "" or infoSelection[5].text == "請選擇" or infoSelection[6].text == "請選擇" or infoSelection[7].text == "請選擇" or infoTextField[10].text == "" ) then
										
										native.showAlert( "", "尚有資訊未填寫完整，請再次檢查", {"確定"} )
											
										if ( partnerTextField[1].text == "" ) then
											ptnrHintText[1]:setFillColor( unpack(hintAlertColor) )
											ptnrHintText[1].text = "此為必填區塊"
										end
										if ( infoSelection[5].text == "請選擇" ) then
											infoHintText[5]:setFillColor( unpack(hintAlertColor) )
											infoHintText[5].text = "此為必填區塊"
										end
										if ( infoSelection[6].text == "請選擇" ) then
											infoHintText[6]:setFillColor( unpack(hintAlertColor) )
											infoHintText[6].text = "此為必填區塊"
										end
										if ( infoSelection[7].text == "請選擇" ) then
											infoHintText[7]:setFillColor( unpack(hintAlertColor) )
											infoHintText[7].text = "此為必填區塊"
										end
										if ( infoTextField[10].text == "" ) then
											infoHintText[10]:setFillColor( unpack(hintAlertColor) )
											infoHintText[10].text = "此為必填區塊"
										end
									else
										print("finished")
										-- 個人資訊
										infoFile = io.open( infoPath, "w" )
										infoFile:write( "chFirstName="..infoTextField[1].text.."\n", "chLastName="..infoTextField[2].text.."\n", "enFisrtName="..infoTextField[3].text.."\n", "enLastName="..infoTextField[4].text.."\n", "gender="..infoSelection[5].text.."\n", "contient="..infoSelection[6].text.."\n", "country="..infoSelection[7].text.."\n", "areaCode="..infoSelection[8].text.."\n", "mobile="..infoTextField[9].text.."\n", "email="..infoTextField[10].text)
										--infroList = { chFirstName = infoTextField[1].text, chLastName = infoTextField[2].text, enFisrtName = infoTextField[3].text, enLastName = infoTextField[4].text, gender = infoSelection[5].text, contient = infoSelection[6].text, country = infoSelection[7].text, areaCode = infoSelection[8].text, mobile = infoTextField[9].text, email = infoTextField[10].text }
										--infoFile:write(json.encode(infoList))
										io.close(infoFile)
										infoFile = nil

										-- 旅伴系統
										ptnrFile = io.open( ptnrPath, "w" )
										ptnrFile:write( "nickName="..partnerTextField[1].text.."\n", "age="..partnerTextField[2].text.."\n", "gender="..partnerSelection[3].text.."\n", "contient="..partnerSelection[4].text.."\n", "country="..partnerSelection[5].text.."\n", "language="..partnerTextField[6].text.."\n", "travelMethod="..partnerSelection[7].text.."\n", "wantedCountry="..partnerTextField[8].text.."\n", "aboutMe="..partnerTextField[9].text)
										--ptnrList = { nickName = partnerTextField[1].text, age = partnerTextField[2].text, gender = partnerSelection[3].text, contient = partnerSelection[4].text, country = partnerSelection[5].text, language = partnerTextField[6].text, travelMethod = partnerSelection[7].text, wantedCountry = partnerTextField[8].text, aboutMe = partnerTextField[9].text }
										--ptnrFile:write(json.encode(ptnrList))
										io.close(ptnrFile)
										ptnrFile = nil

										-- 旅伴開關
										switchFile = io.open( switchPath, "w" )
										--switchFile:write( "isOn="..getSwitchIsOn )
										switchFile:write(json.encode(getSwitchIsOn))
										io.close(switchFile)
										switchFile = nil

										local setGender
										if ( infoSelection[5].text == "男" ) then
											setGender = "MALE"
										else
											setGender = "FEMALE"
										end
										
										body = "chFirstName="..infoTextField[1].text.."&chLastName="..infoTextField[2].text.."&enFirsName="..infoTextField[3].text.."&enLastName="..infoTextField[4].text.."&country="..setCountry.."&mobile="..infoTextField[9].text.."&email="..infoTextField[10].text.."&gender="..setGender
										print(body)

										composer.gotoScene("PC_personalCenter", { effect = "slideLeft", time = 300} )
									end
								end
							end
						end
					end)
				return true
			end,
		})
		sceneGroup:insert(doneBtn)
		doneBtn.anchorX = 1

end

function scene:show( event )
	local sceneGroup = self.view
	local phase = event.phase
	if phase == "will" then
		if ( toMate ) then
			travelMateGroup.isVisible = true
		else
			infomationGroup.isVisible = true
			for i = 1, #infoTitleOptions do
				if ( infoTextField[i] ) then infoTextField[i].isVisible = true end
			end	
		end
	elseif phase == "did" then
	end	
end

function scene:hide( event )
	local sceneGroup = self.view
	local phase = event.phase
	if event.phase == "will" then
		composer.setVariable( "toMate", false )
	elseif phase == "did" then
		composer.removeScene("PC_personalEdit")
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