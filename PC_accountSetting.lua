-----------------------------------------------------------------------------------------
--
-- PC_accountSetting.lua
--
-----------------------------------------------------------------------------------------

local composer = require("composer")
local widget = require("widget")
local getFont = require("setFont")
local tabBar = require("mainTabBar")

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

local pwdTableView
local pwdTextField = {}

local ceil = math.ceil
local floor = math.floor

--	TextField 的 userInput監聽事件
local function onTextListener( event )
	local phase = event.phase
	if( phase == "began") then

	elseif (phase == "editing") then

	elseif (phase == "ended") then

	end
end

-- pwdRowRender
local function pwdRowRender( event )
	local row = event.row
	local rowHeight = row.contentHeight
    local rowWidth = row.contentWidth
    -- 加入TextField
    local pwdText = {"輸入當前密碼", "輸入新的密碼", "確認新的密碼",} 
    pwdTextField[row.index] = native.newTextField( 0, 0, rowWidth*0.9, rowHeight/2)
    row:insert(pwdTextField[row.index])
    pwdTextField[row.index].inputType = "default"
    pwdTextField[row.index].hasBackground = false
	pwdTextField[row.index].x = rowWidth/2
    pwdTextField[row.index].y = rowHeight*0.7
    pwdTextField[row.index].placeholder = pwdText[row.index]
    pwdTextField[row.index].isSecure = true
    pwdTextField[row.index]:setSelection(0,0)

    -- 顯示在TableView的字
    local title = { "當前密碼", "新的密碼", "",}
    local rowTitle = display.newText( row, title[row.index], 0, 0, getFont.font, 10 )
    rowTitle:setFillColor(unpack(separateLineColor))
    -- Align the label left and vertically centered
    rowTitle.anchorX = 0
    rowTitle.x = rowWidth*0.05
    rowTitle.y = rowHeight*0.3
end

function scene:create( event )
	local sceneGroup = self.view
	tabBar.myTabBarHidden()
	------------------ 背景元件 -------------------
		local background = display.newRect( cx, cy, screenW+ox+ox, screenH+oy+oy)
		sceneGroup:insert(background)
		background:setFillColor(unpack(backgroundColor))
	------------------ 抬頭元件 -------------------
	-- 陰影
		local titleBaseShadow = display.newImageRect("assets/shadow0205.png", 320, 60)
		sceneGroup:insert(titleBaseShadow)
		titleBaseShadow.height = floor(178*hRate)
		titleBaseShadow.x = cx
		titleBaseShadow.y = -oy+titleBaseShadow.contentHeight*0.5
	-- 白底
		local titleBase = display.newRect(cx, 0, screenW+ox+ox, titleBaseShadow.contentHeight*0.9)
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
			x = -ox+ceil(49*wRate),
			y = titleBase.y,
			width = 162,
			height = 252,
			defaultFile = "assets/btn-back-b.png",
			overFile = "assets/btn-back-b.png",
			onRelease = function()
				tabBar.myTabBarShown()
				composer.hideOverlay("zoomOutIn",300)
			end,
		})
		sceneGroup:insert( backArrowNum, backBtn)
		backBtn.anchorX = 0
		backBtn.width = ceil(backBtn.width*0.07)
		backBtn.height = ceil(backBtn.height*0.07)
	-- 顯示文字-"帳戶設定"
		local titleText = display.newText({
			text = "帳戶設定",
			font = getFont.font,
			fontSize = 14,
		})
		sceneGroup:insert(titleText)
		titleText:setFillColor(unpack(wordColor))
		titleText.anchorX = 0
		titleText.x = backArrow.x+backArrow.contentWidth+ceil(30*wRate)
		titleText.y = titleBase.y
	-- 確認修改
		local doneBtn = widget.newButton({
			id = "doneBtn",
			x = screenW+ox-ceil(49*wRate),
			y = titleBase.y,
			width = screenW/16,
			height = screenH/16,
			label = "確認修改",
			labelColor = { default = mainColor1 , over = mainColor2 },
			font = getFont.font,
			fontSize = 14,
			defaultFile= "assets/transparent.png",
			onPress = function()
				tabBar.myTabBarShown()
				composer.hideOverlay("zoomOutIn",300)
			end,
		})
		sceneGroup:insert(doneBtn)
		doneBtn.anchorX = 1
	------------------ 密碼修改元件 -------------------
	-- 密碼修改
		local pwdBackgroundShadowTop = display.newImageRect("assets/s-up.png", screenW+ox+ox, 7)
		sceneGroup:insert(pwdBackgroundShadowTop)
		pwdBackgroundShadowTop.height = ceil(pwdBackgroundShadowTop.height*0.5)
		pwdBackgroundShadowTop.anchorY = 1
		pwdBackgroundShadowTop.x = cx
		pwdBackgroundShadowTop.y = titleBaseShadow.y+titleBaseShadow.contentHeight*0.5+ceil(25*hRate)

		local pwdTableView = widget.newTableView({
			id = "pwdTableView",
			top = -oy+titleBaseShadow.contentHeight+ceil(25*hRate),
			left = -ox,
			width = screenW+ox+ox,
			height = (screenH/10*3),
			isLocked = true,
			onRowRender = pwdRowRender,
		})
		sceneGroup:insert(pwdTableView)
		local tableViewNum = sceneGroup.numChildren
		for i=1,3 do
			pwdTableView:insertRow({
				rowHeigh = screenH/10,
				lineColor = separateLineColor,
			})
		end

		local pwdBackgroundShadowBottom = display.newImageRect("assets/s-down.png", screenW+ox+ox, 7)
		sceneGroup:insert(pwdBackgroundShadowBottom)
		pwdBackgroundShadowBottom.height = ceil(pwdBackgroundShadowBottom.height*0.5)
		pwdBackgroundShadowBottom.anchorY = 0
		pwdBackgroundShadowBottom.x = cx
		pwdBackgroundShadowBottom.y = pwdTableView.y+pwdTableView.contentHeight*0.5
end

function scene:show( event )
	local sceneGroup = self.view
	local phase = event.phase
	if phase == "will" then
	elseif phase == "did" then
	end	
end

function scene:hide( event )
	local sceneGroup = self.view
	local phase = event.phase
	if event.phase == "will" then
	elseif phase == "did" then
		composer.removeScene("PC_accountSetting")
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