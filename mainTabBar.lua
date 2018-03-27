-----------------------------------------------------------------------------------------
--
-- mainTabBar.lua
--
-----------------------------------------------------------------------------------------
local widget = require ("widget")
local composer = require("composer")
local getFont = require("setFont")
local tabBar = {}
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

local tabBarGroup
local myTabBar

function tabBar:onTestView( event )
	--composer.gotoScene( "advisorCenter" )
	--composer.gotoScene( "queryFunRoad" )
	--composer.gotoScene( "queryRecord" )
	--composer.gotoScene( "findPartner" )
	--composer.gotoScene( "partnerResult" )
	--composer.gotoScene( "myInformation" )
	--composer.gotoScene( "otherSetting" )
	--composer.gotoScene( "memberSearch" )
	--composer.gotoScene( "myTripV4" )
	--composer.gotoScene( "goodPage" )
	--composer.gotoScene( "bookPage" )
	composer.gotoScene( "loginWelcome" )
	--composer.gotoScene( "personalcenter" )
	--composer.gotoScene( "editation" )
end

function tabBar:tabBarCreate()
		tabBarGroup = display.newGroup()
		local shadow = display.newImageRect("assets/tabbar-paper.png",320,60)
		tabBarGroup:insert(shadow)
		shadow.width = screenW+ox+ox
		shadow.x = cx
		shadow.y = screenH+math.floor(oy)-shadow.contentHeight*0.5
		local tabButtons = {
		{ 
			label = "首頁", 
			labelColor = { default = { 0, 0, 0, 0 }, over = mainColor1  },
			font = getFont.font,
			size = 10,
			labelYOffset = -2,
			defaultFile = "assets/tabbar/index-g.png", 
			overFile = "assets/tabbar/index-b.png", 
			width = 24,
			height = 24,
			onPress = self.onHomePageView,
			selected = true,
		},
		{ 
			label = "目的地", 
			labelColor = { default = { 0, 0, 0, 0 }, over = mainColor1 },
			font = getFont.font,
			size = 10,
			labelYOffset = -2,
			defaultFile = "assets/tabbar/location-g.png", 
			overFile = "assets/tabbar/location-b.png", 
			width = 24,
			height = 24,
			onPress = self.onHotSpotView,
			selected = false,
		},
		{ 
			label = "旅伴系統", 
			labelColor = { default = { 0, 0, 0, 0 }, over = mainColor1 },
			font = getFont.font,
			size = 10,
			labelYOffset = -2,
			defaultFile = "assets/tabbar/mate-g.png", 
			overFile = "assets/tabbar/mate-b.png", 
			width = 24,
			height = 24,
			onPress = self.onTravelPartnerView,
			selected = false,
		},
		{ 
			label = "  購物車", 
			labelColor = { default = { 0, 0, 0, 0 }, over = mainColor1 },
			font = getFont.font,
			size = 10,
			labelYOffset = -2,
			defaultFile = "assets/tabbar/cart-g.png", 
			overFile = "assets/tabbar/cart-b.png", 
			width = 24,
			height = 24,
			onPress = self.onShoppingCartView,
			selected = false,
		},
		{ 
			label = "組合優惠", 
			labelColor = { default = { 0, 0, 0, 0 }, over = mainColor1 },
			font = getFont.font,
			size = 10,
			labelYOffset = -2,
			defaultFile="assets/tabbar/sale-g.png", 
			overFile="assets/tabbar/sale-b.png", 
			width = 24,
			height = 24,
			onPress = self.onCominationOfferView,
			selected = false,
		},
		{ 
			label = "個人中心", 
			labelColor = { default = { 0, 0, 0, 0 }, over = mainColor1 },
			font = getFont.font,
			size = 10,
			labelYOffset = -2,
			defaultFile="assets/tabbar/user-g.png", 
			overFile="assets/tabbar/user-b.png", 
			width = 24, 
			height = 24, 
			onPress = self.onPersonalCenterView,
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
		buttons = tabButtons
	}
	tabBarGroup:insert(myTabBar)
	composer.setVariable("mainTabBarHeight",myTabBar.contentHeight)
	composer.setVariable("mainTabBarY",myTabBar.y)
end

function tabBar:onFirstView()
	composer.gotoScene( "view2" )
end

function tabBar:onHomePageView()
	myTabBar:setSelected(1)
	composer.gotoScene( "homePage" )
end

function tabBar:onHotSpotView()
	myTabBar:setSelected(2)
	composer.gotoScene( "hotSpot" )
end

function tabBar:onTravelPartnerView()
	myTabBar:setSelected(3)
	--composer.gotoScene( "travelPartnerWelcome")
	composer.gotoScene( "findPartner")
end

function tabBar:onShoppingCartView()
	myTabBar:setSelected(4)
	composer.gotoScene( "shoppingCart" )
end

function tabBar:onCominationOfferView()
	myTabBar:setSelected(5)
	composer.gotoScene( "combinationOffer" )
end

function tabBar:onPersonalCenterView()
	myTabBar:setSelected(6)
	composer.gotoScene( "personalcenter" )
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