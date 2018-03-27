-----------------------------------------------------------------------------------------
--
-- forgetPassword.lua
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
	local getProductId = event.params.productId
	mainTabBar.myTabBarHidden()
------------------- 註冊元件 -------------------
	local resetPasswordGroup = display.newGroup()
	sceneGroup:insert(resetPasswordGroup)
-- 註冊頁背景
	local resetPasswordBackGround = display.newImage("assets/login-bg.png",cx,cy)
	resetPasswordGroup:insert(resetPasswordBackGround)
	resetPasswordBackGround.width = screenW+ox+ox
	resetPasswordBackGround.height = screenH+oy+oy
-- 關閉按鈕
	local closeBtn = widget.newButton({
		id = "closeBtn",
		x = -ox+50*math.sqrt(wRate*hRate),
		y = -oy+50*math.sqrt(wRate*hRate),
		defaultFile = "assets/close.png",
		width = 61*math.sqrt(wRate*hRate),
		height = 61*math.sqrt(wRate*hRate),
		onRelease = function ()
			local options
			if ( getBackScene == "goodPage" ) then
				options = {
					params = {
						productId = event.params.productId,
					}
				}
			end
			composer.gotoScene(getBackScene, options)
		end
	})
	resetPasswordGroup:insert(closeBtn)
	closeBtn.anchorX = 0
	closeBtn.anchorY = 0
-- 圖示-login-logo.png
	local resetPasswordLogo = display.newImage("assets/login-logo.png",cx, floor(234*hRate))
	resetPasswordGroup:insert(resetPasswordLogo)
	resetPasswordLogo.width = resetPasswordLogo.width*0.1
	resetPasswordLogo.height = resetPasswordLogo.height*0.1
	resetPasswordLogo.anchorY = 0
-- 圖示-login-paper.png
	local resetPasswordPaper = display.newImage("assets/login-paper.png",cx, resetPasswordLogo.y+resetPasswordLogo.contentHeight+floor(91*hRate))
	resetPasswordGroup:insert(resetPasswordPaper)
	resetPasswordPaper.width = resetPasswordPaper.width*wRate
	resetPasswordPaper.height = resetPasswordPaper.height*hRate
	resetPasswordPaper.anchorY = 0
-- resetPasswordPaper部分資訊
	local paperShadowWidth = ceil(resetPasswordPaper.contentWidth*0.05)
	local paperBaseX = resetPasswordPaper.x-resetPasswordPaper.contentWidth*0.5+paperShadowWidth
	local paperShadowHeight = floor(resetPasswordPaper.contentHeight*0.07)
	local paperBaseY = resetPasswordPaper.y+paperShadowHeight
-- 顯示文字-"忘記密碼"
	local forgetPasswordText = display.newText({
		text = "忘記密碼",
		font = getFont.font,
		fontSize = 14,
		x = cx,
		y = paperBaseY+floor(80*hRate),
	})
	resetPasswordGroup:insert(forgetPasswordText)
	forgetPasswordText:setFillColor(unpack(wordColor))
	forgetPasswordText.anchorY = 0
-- 圖示-e-mailreset.png
	local resetEmail = display.newImage("assets/e-mailreset.png", forgetPasswordText.x, forgetPasswordText.y+forgetPasswordText.contentHeight+floor(115*hRate))
	resetPasswordGroup:insert(resetEmail)
	resetEmail.width = resetEmail.width*wRate
	resetEmail.height = resetEmail.height*hRate
	resetEmail.anchorY = 0
-- email輸入欄位
	local emailTextField = native.newTextField( resetEmail.x, resetEmail.y+resetEmail.contentHeight*0.7, resetEmail.contentWidth*0.95, resetEmail.contentHeight*0.5)
	resetPasswordGroup:insert(emailTextField)
	emailTextField.hasBackground = false
	emailTextField.font = getFont.font
	emailTextField.size = 16
	emailTextField.inputType = "email"
	emailTextField:resizeFontToFitHeight()
	emailTextField:setSelection(0,0)
-- 發送重置信件按鈕
	local resetPasswordBtn = widget.newButton({
		id = "resetPasswordBtn",
		label = "發送重置信件",
		labelColor = { default = {1,1,1}, over = {1,1,1}},
		font = getFont.font,
		fontSize  = 14,
		defaultFile = "assets/login-btn.png",
		x = cx,
		y = resetEmail.y+resetEmail.contentHeight+floor(145*hRate),
		width = 338*wRate,
		height = 84*hRate,
	})
	resetPasswordGroup:insert(resetPasswordBtn)
	resetPasswordBtn.anchorY = 0
------------------- 第三方登入元件 -------------------
-- 顯示文字-"或"
	local orText = display.newText({
		text = "或",
		font = getFont.font,
		fontSize = 12,
		x = cx,
		y = resetPasswordPaper.y+resetPasswordPaper.contentHeight
	})
	resetPasswordGroup:insert(orText)
	orText.anchorY = 0
-- 左邊白線
	local leftLine = display.newLine( paperBaseX, orText.y+orText.contentHeight*0.5, paperBaseX+resetPasswordPaper.contentWidth*0.4, orText.y+orText.contentHeight*0.5)
	resetPasswordGroup:insert(leftLine)
	leftLine.strokeWidth = 1
-- 右邊白線
	local rightLine = display.newLine( resetPasswordPaper.x+resetPasswordPaper.contentWidth*0.5-paperShadowWidth, orText.y+orText.contentHeight*0.5, resetPasswordPaper.x+resetPasswordPaper.contentWidth*0.5-paperShadowWidth-resetPasswordPaper.contentWidth*0.4, orText.y+orText.contentHeight*0.5)
	resetPasswordGroup:insert(rightLine)
	rightLine.strokeWidth = 1
-- google
	local google = display.newImage("assets/google.png", cx, orText.y+orText.contentHeight+floor(35*hRate))
	resetPasswordGroup:insert(google)
	google.anchorY = 0
	google.width = google.width*math.sqrt(wRate*hRate)
	google.height = google.height*math.sqrt(wRate*hRate)
-- facebook
	local facebook = display.newImage("assets/facebook.png", google.x-google.contentWidth*0.5-ceil(36*wRate), google.y)
	resetPasswordGroup:insert(facebook)
	facebook.anchorX = 1
	facebook.anchorY = 0
	facebook.width = facebook.width*math.sqrt(wRate*hRate)
	facebook.height = facebook.height*math.sqrt(wRate*hRate)
-- wechat
	local wechat = display.newImage("assets/wechat.png", google.x+google.contentWidth*0.5+ceil(36*wRate), google.y)
	resetPasswordGroup:insert(wechat)
	wechat.anchorX = 0
	wechat.anchorY = 0
	wechat.width = wechat.width*math.sqrt(wRate*hRate)
	wechat.height = wechat.height*math.sqrt(wRate*hRate)
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
		composer.removeScene("forgetPassword")
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