-----------------------------------------------------------------------------------------
--
-- disclaimer.lua
-- 
-----------------------------------------------------------------------------------------
local composer = require( "composer" )
local widget = require("widget")
local mainTabBar = require("mainTabBar")
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


-- function Zone Start
local function ceil( value )
	return math.ceil(value)
end

local function floor( value )
	return math.floor(value)
end

-- 按鈕的監聽事件
local function onBtnListener( event )
	local targetId = event.target.id
	if( targetId == "backBtn") then 
		composer.hideOverlay("zoomOutIn",300)
	end
end

-- function Zone End

-- create()
function scene:create( event )
	local sceneGroup = self.view
	mainTabBar.myTabBarHidden()
------------------- 背景元件 -------------------
	local background = display.newRect(cx, cy, screenW+ox+ox, screenH+oy+oy)
	sceneGroup:insert(background)
	background:setFillColor(unpack(backgroundColor))
------------------- 抬頭元件 -------------------
-- 白底
	local titleBase = display.newRect(0, 0, screenW+ox+ox, floor(178*hRate))
	sceneGroup:insert(titleBase)
	titleBase.x = cx
	titleBase.y = -oy+titleBase.contentHeight*0.5
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
		onRelease = onBtnListener,
	})
	sceneGroup:insert(backArrowNum,backBtn)
-- 顯示文字-"旅伴免責聲明"
	local titleText = display.newText({
		text = "旅伴免責聲明",
		y = titleBase.y,
		font = getFont.font,
		fontSize = 14,
	})
	sceneGroup:insert(titleText)
	titleText:setFillColor(unpack(wordColor))
	titleText.anchorX = 0
	titleText.x = backArrow.x+backArrow.contentWidth+ceil(30*wRate)
------------------- 免責聲明文字 ------------------
-- 免責聲明讀檔	
	local path = system.pathForFile( "Font_Data/disclaime.txt", system.ResourceDirectory )
	local file = io.open(path, "r")
	local list = {}
	if not file then 
		print("File is not found")
	else
		local contents = file:read("*l")
		local count = 1
		while (contents ~= nil) do
			list[count] = contents
			count = count+1
			contents = file:read("*l")
		end
	end
	io.close( file )
	file = nil
	--for k,v in pairs(list) do
	--	print(k,v)
	--end
-- 建立免責聲明
	local disclaimerWhiteBase = display.newRect( 0, 0, screenW+ox+ox, titleBase.contentHeight)
	sceneGroup:insert(disclaimerWhiteBase)
	disclaimerWhiteBase.x = cx
	disclaimerWhiteBase.y = titleBase.y+(titleBase.contentHeight*0.5)+floor(40*hRate)+(disclaimerWhiteBase.contentHeight*0.5)
	local disclaimerText = display.newText({
		text = list[1],
		font = getFont.font,
		fontSize = 12,
	})
	sceneGroup:insert(disclaimerText)
	disclaimerText:setFillColor(unpack(mainColor2))
	disclaimerText.anchorX = 0
	disclaimerText.x = -ox+ceil(50*wRate)
	disclaimerText.y = disclaimerWhiteBase.y
-- 分隔線
	local line = display.newLine( -ox, disclaimerWhiteBase.y+disclaimerWhiteBase.contentHeight*0.5, screenW+ox, disclaimerWhiteBase.y+disclaimerWhiteBase.contentHeight*0.5)
	sceneGroup:insert(line)
	line.strokeWidth = 1
	line:setStrokeColor(unpack(separateLineColor))
-- 免責聲明scrollview
	local scrollView = widget.newScrollView({
		id = "scrollView",
		width = screenW+ox+ox,
		height = screenH+oy+oy-(disclaimerWhiteBase.y+disclaimerWhiteBase.contentHeight*0.5),
		x = cx,
		y = line.y,
		isBounceEnabled = false,
		horizontalScrollDisabled = true,
		backgroundColor = {1},
	})
	sceneGroup:insert(scrollView)
	scrollView.anchorY = 0
-- 免責說明內容	
	local disclaimeGroup = display.newGroup()
	scrollView:insert(disclaimeGroup)
	local scrollViewHeight
	local textPadding = floor(40*hRate)
	local textX = scrollView.contentWidth*0.5
	local textY = textPadding
	local textWidth = scrollView.contentWidth*0.9

	for i=3,#list do
		local disclaimeText = display.newText({
			text = list[i],
			font = getFont.font,
			fontSize = 12,
			x = textX,
			y = textY,
			width = textWidth,
		})
		disclaimeGroup:insert(disclaimeText)
		disclaimeText:setFillColor(unpack(wordColor))
		disclaimeText.anchorY = 0
		textY = textY+disclaimeText.contentHeight+textPadding
		if (i == #list) then
			scrollViewHeight = textY+disclaimeText.contentHeight+textPadding
		end
	end
	local updateDayText = display.newText({
		text = list[2],
		font = getFont.font,
		fontSize = 12,
		x = textX,
		y = textY,
		width = textWidth,
		align = "right"
	})
	disclaimeGroup:insert(updateDayText)
	updateDayText:setFillColor(unpack(mainColor2))
	updateDayText.anchorY = 0
	scrollViewHeight = scrollViewHeight+updateDayText.contentHeight+textPadding
	scrollView:setScrollHeight( scrollViewHeight )
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
 	local parent = event.parent
    if ( phase == "will" ) then
        -- Code here runs when the scene is on screen (but is about to go off screen)
 		 parent:recover()
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