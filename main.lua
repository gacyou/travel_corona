-----------------------------------------------------------------------------------------
--
-- main.lua
--
-----------------------------------------------------------------------------------------

-- show default status bar (iOS)
display.setStatusBar( display.HiddenStatusBar )
display.setDefault( "background", 245/255, 245/255, 245/255)

local widget = require("widget")
local composer = require("composer")
local mainTabBar = require("mainTabBar")
local backExit = require("backExit")

widget.setTheme("widget_theme_ios")
backExit:backExit()
mainTabBar:tabBarCreate()
--mainTabBar:onHomePageView()
--mainTabBar:onHotSpotView()
--mainTabBar:onTravelPartnerView()
--mainTabBar:onShoppingCartView()
--mainTabBar:onCominationOfferView()
mainTabBar:onPersonalCenterView()
--mainTabBar:onTestView()