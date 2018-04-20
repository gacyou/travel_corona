-----------------------------------------------------------------------------------------
--
-- LN_welcome.lua
--
-----------------------------------------------------------------------------------------
-- show default status bar (iOS)
display.setStatusBar( display.HiddenStatusBar )

local widget = require ("widget")
local composer = require("composer")
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

local ceil = math.ceil
local floor = math.floor

-- create()
function scene:create( event )
	local sceneGroup = self.view
	local getBackScene = event.params.backScene
	mainTabBar.myTabBarHidden()
	------------------- 歡迎元件 -------------------
	-- 登入歡迎背景	
		local welcomeGroup = display.newGroup()
		sceneGroup:insert(welcomeGroup)
		local welcomeBackGround = display.newImage("assets/login-bg.png",cx,cy)
		welcomeGroup:insert(welcomeBackGround)
		welcomeBackGround.width = screenW+ox+ox
		welcomeBackGround.height = screenH+oy+oy
	-- 圖示-login-logo.png
		local welcomeLogo = display.newImage("assets/login-logo.png",cx, -oy+floor(362*hRate))
		welcomeGroup:insert(welcomeLogo)
		welcomeLogo.width = welcomeLogo.width*0.1
		welcomeLogo.height = welcomeLogo.height*0.1
		welcomeLogo.anchorY = 0
	-- 顯示文字-"探索你的精彩旅程"
		local welcomeWord = display.newText({
			text = "探索你的精彩旅程",
			font = getFont.font,
			fontSize = 14,
			x = cx,
			y = welcomeLogo.y+welcomeLogo.contentHeight+floor(105*hRate)
		})
		welcomeGroup:insert(welcomeWord)
		welcomeWord:setFillColor(unpack(wordColor))
		welcomeWord.anchorY = 0
		timer.performWithDelay( 500, function ()
			local options = {
				params = {
					backScene = getBackScene,
					productId = "N/A",
				}
			}
			composer.gotoScene("LN_login", options)
		end)
end

-- show()
function scene:show( event )
local sceneGroup = self.view
	local phase = event.phase
	if (phase == "will") then
	elseif (phase == "did") then
	end
end

-- hide()
function scene:hide( event )
	local sceneGroup = self.view
	local phase = event.phase
	if (phase == "will") then
	elseif (phase == "did") then
		composer.removeScene("LN_welcome")
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