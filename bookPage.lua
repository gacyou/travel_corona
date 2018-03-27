-----------------------------------------------------------------------------------------
--
-- bookPage.lua
--
-----------------------------------------------------------------------------------------
local widget = require ("widget")
local composer = require ("composer")
local mainTabBar = require ("mainTabBar")
--local json = require("json")
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

local function ceil( value )
	return math.ceil( value )
end
-- create()
function scene:create( event )
	local sceneGroup = self.view
------------------- 抬頭元件 -------------------
	local base = {}
	local shadow = {}
	local btn = {}
	local text = {}
	local line = {}
	local icon = {}
	local arrow = {}
	local setStatus = {}
		-- 抬頭陰影
		shadow["title"] = display.newImageRect("assets/shadow0205.png", 320, 60)
		sceneGroup:insert(shadow["title"])
			shadow["title"].width = screenW+ox+ox
			shadow["title"].height = ceil(200*hRate)
			shadow["title"].x = cx
			shadow["title"].y = math.floor(-oy)+shadow["title"].contentHeight*0.5
		-- 返回按鈕
			btn["back"] = widget.newButton({
				id = "backBtn",
				x = -ox+ceil(35*wRate),
				y = -oy+ceil(36*hRate),
				width = 162,
				height = 252,
				defaultFile = "assets/btn-back-b.png",
				onRelease = onBtnListener,
			})
			sceneGroup:insert(btn["back"])
			btn["back"].width = btn["back"].width*0.1
			btn["back"].height = btn["back"].height*0.1
			btn["back"].anchorX = 0
			btn["back"].anchorY = 0
		-- 抬頭文字
			text["title"] = display.newText({
				text = "訂購選項",
				height = 0,
				font = native.newFont("Font_Data/GenJyuuGothicX-P-Medium"),
				fontSize = 20,
			})
			sceneGroup:insert(text["title"])
			text["title"]:setFillColor(unpack(wordColor))
			text["title"].anchorX = 0
			text["title"].x = btn["back"].x+btn["back"].contentWidth+ceil(40*wRate)
			text["title"].y = btn["back"].y+btn["back"].contentHeight*0.5
end

-- show()
function scene:show( event )
    local sceneGroup = self.view
    local phase = event.phase
 
    if ( phase == "will" ) then
        -- Code here runs when the scene is still off screen (but is about to come on screen)
 
    elseif ( phase == "did" ) then
        -- Code here runs when the scene is entirely on screen
 
    end
end

-- hide()
function scene:hide( event )
 
    local sceneGroup = self.view
    local phase = event.phase
 
    if ( phase == "will" ) then
        -- Code here runs when the scene is on screen (but is about to go off screen)
 
    elseif ( phase == "did" ) then
        -- Code here runs immediately after the scene goes entirely off screen
 
    end
end

-- destroy()
function scene:destroy( event )
 
    local sceneGroup = self.view
    -- Code here runs prior to the removal of scene's view
 
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