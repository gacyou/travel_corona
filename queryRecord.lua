-----------------------------------------------------------------------------------------
--
-- queryRecord.lua
--
-----------------------------------------------------------------------------------------
local widget = require ("widget")
local composer = require ("composer")
local getFont = require("setFont")
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

local prevScene = composer.getSceneName("previous")

local mainTabBarHeight = composer.getVariable("mainTabBarHeight")

local hasQueryRecord = false
-- function Zone Start
local function ceil( value )
	return math.ceil(value)
end

-- 觸碰監聽事件
local function onTouchListener( event )
	--print(event.y)
end

-- function Zone End
-- create()
function scene:create( event )
    local sceneGroup = self.view
    local getBackScene = event.params.backScene
    -- 按鈕的監聽事件
    local function onBtnListener( event )
    	local targetId = event.target.id
    	if (targetId == "backBtn") then 
    		local options = { 
    			effect = "fade", 
    			time = 200,
    			params = {
    				backScene = getBackScene
    			}
			}
    		composer.gotoScene(prevScene, options)
    	end
    end
    -- 諮詢奮路鳥元件
	local background = display.newRect(cx,cy+oy,screenW+ox+ox,screenH+oy+oy)
	sceneGroup:insert(background)
	background:setFillColor(unpack(backgroundColor))
	local titleBackground = display.newRect(0, 0, screenW+ox+ox, ceil(178*hRate))
	sceneGroup:insert(titleBackground)
	titleBackground.x = cx
	titleBackground.y = -oy+ceil((titleBackground.height)/2)
	local titleBackgroundShadow = display.newImageRect("assets/shadow.png", 1068, 476)
	sceneGroup:insert(titleBackgroundShadow)
	titleBackgroundShadow.width = ceil(titleBackgroundShadow.width*0.33)+ox+ox
	titleBackgroundShadow.height = ceil(titleBackground.height*1.05)
	titleBackgroundShadow.x = titleBackground.x
	titleBackgroundShadow.y = titleBackground.y

	local backBtn = widget.newButton({
		id = "backBtn",
		x = -ox+ceil(49*wRate),
		y = titleBackground.y,
		width = 162,
		height = 252,
		defaultFile = "assets/btn-back-b.png",
		overFile = "assets/btn-back-b.png",
		onPress = onBtnListener,
	})
	sceneGroup:insert(backBtn)
	backBtn.width = ceil(backBtn.width*0.07)
	backBtn.height = ceil(backBtn.height*0.07)
	backBtn.anchorX = 0

	local titleText = display.newText({
		text = "諮詢紀錄",
		y = titleBackground.y,
		font = getFont.font,
		fontSize = 16,
	})
	sceneGroup:insert(titleText)
	titleText:setFillColor(unpack(wordColor))
	titleText.anchorX = 0
	titleText.x = backBtn.x+backBtn.contentWidth+ceil(30*wRate)
---------------------------------------------------------------------------------------------------
	-- 諮詢紀錄
	-- 沒有諮詢紀錄
	if (hasQueryRecord == false) then
		local funBirdPic = display.newImageRect("assets/img-bird.png",142,229)
		sceneGroup:insert(funBirdPic)
		funBirdPic.width = ceil(funBirdPic.contentWidth*0.3)
		funBirdPic.height = ceil(funBirdPic.contentHeight*0.3)
		funBirdPic.x = cx
		funBirdPic.y = -oy+ ceil(cy*0.9)
		local text1 = display.newText({
				text = "您尚無諮詢紀錄",
				font = getFont.font,
				fontSize = 14,				
			})
		sceneGroup:insert(text1)
		text1:setFillColor(unpack(wordColor))
		text1.x = cx
		text1.y = -oy+ceil(cy*1.15)
	else
	-- 顯示諮詢紀錄

	end
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
        composer.removeScene("queryRecord")
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