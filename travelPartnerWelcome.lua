-----------------------------------------------------------------------------------------
--
-- travelPartnerWelcome.lua
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

local pad = 20
local mainTabBarHeight = composer.getVariable("mainTabBarHeight")
local welcomeGroup, welcomePic1, welcomePic2
local views = {}
local point = {}
local startPos, prevPos 
local viewNum = 1
local isBuonded = false
-- function Zone Start
local function ceil( value )
	return math.ceil(value)
end

local function floor( value )
	return math.floor(value)
end
local function initView(num)
	if (num < #views) then
		views[num+1].x = screenW*1.5 + pad			
	end
	if (num > 1) then
		views[num-1].x = (screenW*.5 + pad)*-1
	end
end

local function nextView()
	tween = transition.to( views[viewNum], {time = 400, x = (screenW*.5 + pad)*-1, transition = easing.outExpo } )
	tween = transition.to( views[viewNum+1], {time = 400, x = screenW*.5, transition = easing.outExpo } )
	point[viewNum]:setFillColor(unpack(wordColor))
	point[viewNum+1]:setFillColor(unpack(mainColor1))
	viewNum = viewNum + 1
	initView(viewNum)
	if (viewNum == #views) then isBuonded = true end
end

local function prevView()
	tween = transition.to( views[viewNum], {time = 400, x = screenW*1.5+pad, transition = easing.outExpo } )
	tween = transition.to( views[viewNum-1], {time = 400, x = screenW*.5, transition = easing.outExpo } )
	point[viewNum]:setFillColor(unpack(wordColor))
	point[viewNum-1]:setFillColor(unpack(mainColor1))
	viewNum = viewNum - 1
	initView(viewNum)
	isBuonded = false
end

local function cancelMove()
	tween = transition.to( views[viewNum], {time = 400, x = screenW*.5, transition = easing.outExpo } )
	tween = transition.to( views[viewNum-1], {time = 400, x = (screenW*.5 + pad)*-1, transition = easing.outExpo } )
	tween = transition.to( views[viewNum+1], {time = 400, x = screenW*1.5+pad, transition = easing.outExpo } )
end

local function onSlideListener(event)
	local phase = event.phase
	local target = event.target
	--views = { welcomePic1, welcomePic2 }
	if (phase == "began") then
		display.getCurrentStage():setFocus(target)
		target.isFocus = true
		startPos = event.x
		prevPos = event.x
	elseif (target.isFocus) then 
		if (phase == "moved") then
			if tween then transition.cancel(tween) end 
			local delta = event.x - prevPos
			prevPos = event.x
			views[viewNum].x = views[viewNum].x+delta
			if (views[viewNum-1]) then 
				views[viewNum-1].x = views[viewNum-1].x+delta 
			end
			if (views[viewNum+1]) then 
				views[viewNum+1].x = views[viewNum+1].x+delta 
			end
		elseif (phase == "ended" or phase == "cancelled") then
			dragDistance = event.x - startPos
			--print(dragDistance)
			if (isBuonded == true and dragDistance < -40) then
				local options = { effect = "fade", time = 400 }
				composer.gotoScene("findPartner",options)
			end	
			if (dragDistance < -40 and viewNum < #views ) then
				nextView()
			elseif (dragDistance > 40 and viewNum > 1) then
				prevView()
			else
				cancelMove()
			end

			if (phase == "cancelled") then
				cancelMove()
			end
			display.getCurrentStage():setFocus(nil)
			target.isFocus = false
		end
	end
	return true
end
-- function Zone End

-- create()
function scene:create( event )
 
    local sceneGroup = self.view
    -- Code here runs when the scene is first created but has not yet appeared on screen

	local background = display.newRect(cx, cy,screenW+ox+ox,screenH+oy+oy)
	sceneGroup:insert(background)
	background:setFillColor(unpack(backgroundColor))
------------------- 歡迎頁面+滑動元件 -------------------
-- 歡迎頁面+滑動元件
	local model = system.getInfo("model")
	welcomeGroup = display.newGroup()
	sceneGroup:insert(welcomeGroup)
	local picNum = 0
	welcomePic1 = display.newImageRect("assets/welcome-1.png",1080,1920)
	welcomeGroup:insert(welcomePic1)
	welcomePic1.width = screenW*0.9
	if (model == "iPad") then 
		welcomePic1.width = screenW*0.7
		welcomePic1.height = screenH*0.8
	else
		welcomePic1.height = screenH
	end
	welcomePic1.x = cx
	welcomePic1.y = cy
	picNum = picNum+1
	views[picNum] = welcomePic1 
	welcomePic1:addEventListener("touch",onSlideListener)

	welcomePic2 = display.newImageRect("assets/welcome2.png",1080,1920)
	welcomeGroup:insert(welcomePic2)
	welcomePic2.width = screenW*0.9
	if (model == "iPad") then 
		welcomePic2.width = screenW*0.7
		welcomePic2.height = screenH*0.8
	else
		welcomePic2.height = screenH
	end
	welcomePic2.x = welcomePic1.x+(screenW/2)+(screenW/2)
	welcomePic2.y = cy
	picNum = picNum+1
	views[picNum] = welcomePic2 
	welcomePic2:addEventListener("touch",onSlideListener)

	local circlePad = 14
	for i=1,picNum do
		point[i] = display.newCircle(welcomeGroup, 0, (screenH*0.86)+oy, 5)
		point[i].x = cx-((picNum-1)*0.5)*circlePad+circlePad*(i-1)	
		if (i == 1) then 
			point[i]:setFillColor(unpack(mainColor1))
		else
			point[i]:setFillColor(unpack(wordColor))
		end
	end
------------------- 旅伴系統抬頭元件 -------------------
-- 陰影
	local titleBase = display.newRect( cx, 0, screenW+ox+ox, floor(178*hRate))
	sceneGroup:insert(titleBase)
	titleBase.y = -oy+titleBase.contentHeight*0.5
	local shadow = display.newImageRect("assets/s-down.png", screenW+ox+ox, 7)
	sceneGroup:insert(shadow)
	shadow.height = ceil(shadow.height*0.5)
	shadow.anchorY = 0
	shadow.x = cx
	shadow.y = titleBase.y+titleBase.contentHeight*0.5
-- 返回按鈕(本頁不需要所以隱藏)
	local backBtn = widget.newButton({
		id = "backBtn",
		x = -ox+ceil(49*wRate),
		y = -oy+titleBase.contentHeight*0.5,
		width = 162,
		height = 252,
		defaultFile = "assets/btn-back-b.png",
		overFile = "assets/btn-back-b.png",
		onPress = onBtnListener,
	})
	sceneGroup:insert(backBtn)
	backBtn.width = (backBtn.width*0.07)
	backBtn.height = (backBtn.height*0.07)
	backBtn.anchorX = 0
	backBtn.isVisible = false

	local titleText = display.newText({
		text = "旅伴系統",
		y = backBtn.y,
		font = getFont.font,
		fontSize = 14,
	})
	sceneGroup:insert(titleText)
	titleText:setFillColor(unpack(wordColor))
	titleText.anchorX = 0
	titleText.x = backBtn.x+backBtn.contentWidth+(30*wRate)
---------------------------------------------------------------------------------------------------
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
        composer.removeScene("travelPartnerWelcome")
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