-----------------------------------------------------------------------------------------
--
-- mainTabBar.lua
--
-----------------------------------------------------------------------------------------
local widget = require ("widget")
local composer = require("composer")
local getFont = require("setFont")
local myutf8 = require("myutf8")
local json = require("json")
local token = require("token")

local ox, oy = math.abs(display.screenOriginX), math.abs(display.screenOriginY)
local cx, cy = display.contentCenterX, display.contentCenterY
local screenW, screenH = display.contentWidth, display.contentHeight

local wordColor = { 99/255, 99/255, 99/255 }
local backgroundColor = { 245/255, 245/255, 245/255 }
local mainColor1 = { 6/255, 184/255, 217/255 }
local mainColor2 = { 7/255, 162/255, 192/255 }
local subColor1 = { 246/255, 148/255, 106/255}
local subColor2 = { 250/255, 128/255, 79/255}
local separateLineColor = { 204/255, 204/255, 204/255 }

local tabBar = {}
local tabBarGroup
local myTabBar

local prevId, nowId = 1, 1
local isLogin

local function setId( prev, now )
	prevId = prev
	nowId = now
end

local function homePage( event )
	setId( nowId, event.target.id )
	composer.gotoScene( "homePage" )
end

local function hotSpot( event )
	setId( nowId, event.target.id )
	composer.gotoScene( "HS_hotSpot" )
end

local function travelPartner( event )
	setId( nowId, event.target.id )
	if (composer.getVariable("isLogin")) then 
		isLogin = composer.getVariable("isLogin")
	else
		isLogin = false
	end
	if ( isLogin == false ) then
		native.showAlert( "", "使用旅伴功能需先登入，至個人中心開啟功能，是否要登入?", { "是", "否"}, 
			function (event)
				if (event.action == "clicked") then
					local index = event.index
					if ( index == 1) then
						local options = {
							params = {
								backScene = "PC_personalCenter",
								productId = "N/A",
							}
						}
						composer.gotoScene("LN_login", options)
					elseif ( index == 2 ) then
						myTabBar:setSelected(prevId)
						setId( prevId, prevId )
					end
				end
			end)
	else
		local userLoginInfo = composer.getVariable("userLoginInfo")
		--local switchFileName = userLoginInfo.id.."_PC_travelPartnerSwitch.txt"
		--local switchPath = system.pathForFile( switchFileName, system.DocumentsDirectory )
		--local switchFile, textFileError = io.open( switchPath, "r" )
		local switchFileName = userLoginInfo.id.."_PC_travelPartnerSwitch.data"
		local switchPath = system.pathForFile( switchFileName, system.DocumentsDirectory )
		local switchFile, jsonFileError = io.open( switchPath, "r" )
		
		--local switchList = {}
		local getSwitchIsOn
		if not switchFile then
			switchFile = io.open( switchPath, "w")
			getSwitchIsOn = { mate = false }
			--switchFile:write( "isOn=false" )
			switchFile:write( json.encode(getSwitchIsOn) )
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
		if ( not getSwitchIsOn["mate"] ) then
			native.showAlert( "", "旅伴開關目前是關閉狀態，是否要去開啟?", { "是", "否"}, 
				function (event)
					if (event.action == "clicked") then
						local index = event.index
						if ( index == 1) then
							composer.setVariable( "toMate", true )
							composer.gotoScene( "PC_personalEdit" )
						elseif ( index == 2 ) then
							myTabBar:setSelected(prevId)
							setId( prevId, prevId )
						end
					end
				end)
		else
			setId( nowId, event.target.id)
			local path = system.pathForFile( "TP_welcome.data", system.DocumentsDirectory )
			local file = io.open(path, "r")
			if not file then
				composer.gotoScene( "TP_welcome")
			else	
				composer.gotoScene( "TP_findPartner")
				io.close(file)
				file = nil
			end
		end
	end
end

local function shoppingCart( event )
	setId( nowId, event.target.id)
	composer.gotoScene( "shoppingCart" )
end

local function cominationOffer( event )
	setId( nowId, event.target.id)
	composer.gotoScene( "combinationOffer" )
end

local function personalCenter( event )
	setId( nowId, event.target.id)
	composer.gotoScene( "PC_personalCenter" )
end

function tabBar:tabBarCreate()
	tabBarGroup = display.newGroup()
	local shadow = display.newImageRect("assets/tabbar-paper.png",320,60)
	tabBarGroup:insert(shadow)
	shadow.width = screenW+ox+ox
	shadow.x = cx
	shadow.y = screenH+oy-shadow.contentHeight*0.5

	local tabButtons = {
		{ 
			id = 1,
			label = "首頁", 
			labelColor = { default = { 0, 0, 0, 0 }, over = mainColor1  },
			font = getFont.font,
			size = 10,
			labelYOffset = -2,
			defaultFile = "assets/tabbar/index-g.png", 
			overFile = "assets/tabbar/index-b.png", 
			width = 24,
			height = 24,
			onPress = homePage,
			selected = true,
		},
		{ 
			id = 2,
			label = "目的地", 
			labelColor = { default = { 0, 0, 0, 0 }, over = mainColor1 },
			font = getFont.font,
			size = 10,
			labelYOffset = -2,
			defaultFile = "assets/tabbar/location-g.png", 
			overFile = "assets/tabbar/location-b.png", 
			width = 24,
			height = 24,
			onPress = hotSpot,
			selected = false,
		},
		{ 
			id = 3,
			label = "旅伴系統", 
			labelColor = { default = { 0, 0, 0, 0 }, over = mainColor1 },
			font = getFont.font,
			size = 10,
			labelYOffset = -2,
			defaultFile = "assets/tabbar/mate-g.png", 
			overFile = "assets/tabbar/mate-b.png", 
			width = 24,
			height = 24,
			onPress = travelPartner,
			selected = false,
		},
		{ 
			id = 4,
			label = "  購物車", 
			labelColor = { default = { 0, 0, 0, 0 }, over = mainColor1 },
			font = getFont.font,
			size = 10,
			labelYOffset = -2,
			defaultFile = "assets/tabbar/cart-g.png", 
			overFile = "assets/tabbar/cart-b.png", 
			width = 24,
			height = 24,
			onPress = shoppingCart,
			selected = false,
		},
		{ 
			id = 5,
			label = "組合優惠", 
			labelColor = { default = { 0, 0, 0, 0 }, over = mainColor1 },
			font = getFont.font,
			size = 10,
			labelYOffset = -2,
			defaultFile="assets/tabbar/sale-g.png", 
			overFile="assets/tabbar/sale-b.png", 
			width = 24,
			height = 24,
			onPress = cominationOffer,
			selected = false,
		},
		{ 
			id = 6,
			label = "個人中心", 
			labelColor = { default = { 0, 0, 0, 0 }, over = mainColor1 },
			font = getFont.font,
			size = 10,
			labelYOffset = -2,
			defaultFile="assets/tabbar/user-g.png", 
			overFile="assets/tabbar/user-b.png", 
			width = 24, 
			height = 24, 
			onPress = personalCenter,
			selected = false,
		},
	}
	-- create the actual tabBar widget
	myTabBar = widget.newTabBar{
		top = screenH + math.floor(oy)-screenH*0.1125,
		left = -ox,
		width = screenW+ox+ox, 
		height = screenH*0.1125,
		backgroundFile = "assets/white.png",
		tabSelectedLeftFile = "assets/Left.png",
		tabSelectedMiddleFile = "assets/Middle.png",
		tabSelectedRightFile = "assets/Right.png",
		tabSelectedFrameWidth = 20,
		tabSelectedFrameHeight = 52,
		buttons = tabButtons,
		onPress = tabBarListener,
	}
	tabBarGroup:insert(myTabBar)
	composer.setVariable("mainTabBarHeight",myTabBar.contentHeight)
	composer.setVariable("mainTabBarY",myTabBar.y)
end

function tabBar:onHomePageView()
	myTabBar:setSelected(1)
	setId( 1, 1)
	composer.gotoScene( "homePage" )
end

function tabBar:onHotSpotView()
	myTabBar:setSelected(2)
	setId( 2, 2)
	composer.gotoScene( "HS_hotSpot" )
end

function tabBar:onTravelPartnerView()
	myTabBar:setSelected(3)
	setId( 3, 3)
	if (composer.getVariable("isLogin")) then 
		isLogin = composer.getVariable("isLogin")
	else
		isLogin = false
	end
	if ( isLogin == false) then
		native.showAlert( "", "使用旅伴功能需登入，至個人中心開啟功能，是否要登入?", { "是", "否"}, 
			function (event)
				if (event.action == "clicked") then
					local index = event.index
					if ( index == 1) then
						local options = {
							params = {
								backScene = "PC_personalCenter",
								productId = "N/A",
							}
						}
						composer.gotoScene("LN_login", options)
					elseif ( index == 2 ) then
						myTabBar:setSelected(prevId)
						setId( prevId, prevId )
					end
				end
			end)
	else
		local path = system.pathForFile( "TP_welcome.txt", system.DocumentsDirectory )
		local file = io.open(path, "r")
		if not file then
			composer.gotoScene( "TP_welcome")
		else	
			composer.gotoScene( "TP_findPartner")
			io.close(file)
			file = nil
		end
	end
end

function tabBar:onShoppingCartView()
	myTabBar:setSelected(4)
	setId( 4, 4)
	composer.gotoScene( "shoppingCart" )
end

function tabBar:onCominationOfferView()
	myTabBar:setSelected(5)
	setId( 5, 5)
	composer.gotoScene( "combinationOffer" )
end

function tabBar:onPersonalCenterView()
	myTabBar:setSelected(6)
	setId( 6, 6)
	composer.gotoScene( "PC_personalCenter" )
end

function tabBar.setSelectedHomePage()
	myTabBar:setSelected(1)
end

function tabBar.setSelectedHotSpot()
	myTabBar:setSelected(2)
end

function tabBar.setTravelPartner()
	myTabBar:setSelected(3)
end

function tabBar.setShoppingCart()
	myTabBar:setSelected(4)
end

function tabBar.setCominationOffer()
	myTabBar:setSelected(5)
end

function tabBar.setSelectedPersonalCenter()
	myTabBar:setSelected(6)
end

function tabBar:onTestView( event )
	--composer.gotoScene( "TP_welcome" )
	--composer.gotoScene( "TP_findPartner" )
	--composer.gotoScene( "partnerResult" )
	--composer.gotoScene( "TP_myInformation" )
	--composer.gotoScene( "otherSetting" )
	--composer.gotoScene( "memberSearch" )
	--composer.gotoScene( "myTripV6" )
	--composer.gotoScene( "goodPage" )
	--composer.gotoScene( "bookPage" )
	--composer.gotoScene( "LN_register" )
	--composer.gotoScene( "PC_personalCenter" )
	--composer.gotoScene( "PC_personalEdit" )
	--composer.gotoScene( "disclaimer" )
	--composer.gotoScene( "myTripPlan" )
	composer.gotoScene( "homePageV2" )
end

function tabBar.myTabBarHidden()
	tabBarGroup.isVisible = false
end

function tabBar.myTabBarShown()
	tabBarGroup.isVisible = true
end

function tabBar.myTabBarScrollHidden()
	transition.to(tabBarGroup, { time = 200, y = myTabBar.contentHeight})
	timer.performWithDelay( 200, function() tabBarGroup.isVisible = false ; end)
end

function tabBar.myTabBarScrollShown()
	tabBarGroup.isVisible = true
	transition.to(tabBarGroup, { time = 200, y = 0})
end

return tabBar