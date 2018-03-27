-----------------------------------------------------------------------------------------
--
-- register.lua
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
-- 註冊頁背景
	local registerGroup = display.newGroup()
	sceneGroup:insert(registerGroup)
	local registerBackGround = display.newImage("assets/login-bg.png",cx,cy)
	registerGroup:insert(registerBackGround)
	registerBackGround.width = screenW+ox+ox
	registerBackGround.height = screenH+oy+oy
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
	registerGroup:insert(closeBtn)
	closeBtn.anchorX = 0
	closeBtn.anchorY = 0
-- 圖示-login-logo.png
	local registerLogo = display.newImage("assets/login-logo.png",cx, floor(234*hRate))
	registerGroup:insert(registerLogo)
	registerLogo.width = registerLogo.width*0.1
	registerLogo.height = registerLogo.height*0.1
	registerLogo.anchorY = 0
-- 圖示-login-paper.png
	local registerPaper = display.newImage("assets/login-paper.png",cx, registerLogo.y+registerLogo.contentHeight+floor(91*hRate))
	registerGroup:insert(registerPaper)
	registerPaper.width = registerPaper.width*wRate
	registerPaper.height = registerPaper.height*hRate
	registerPaper.anchorY = 0
-- registerPaper部分資訊
	local paperShadowWidth = ceil(registerPaper.contentWidth*0.05)
	local paperBaseX = registerPaper.x-registerPaper.contentWidth*0.5+paperShadowWidth
	local paperShadowHeight = floor(registerPaper.contentHeight*0.07)
	local paperBaseY = registerPaper.y+paperShadowHeight
-- 圖示-e-mail.png
	local registerEmail = display.newImage("assets/e-mail.png", registerPaper.x, paperBaseY+floor(80*hRate))
	registerGroup:insert(registerEmail)
	registerEmail.width = registerEmail.width*wRate
	registerEmail.height = registerEmail.height*hRate
	registerEmail.anchorY = 0
-- email輸入欄位
	local emailTextField = native.newTextField( registerEmail.x, registerEmail.y+registerEmail.contentHeight*0.7, registerEmail.contentWidth*0.95, registerEmail.contentHeight*0.5)
	registerGroup:insert(emailTextField)
	emailTextField.hasBackground = false
	emailTextField.font = getFont.font
	emailTextField.size = 16
	emailTextField.inputType = "email"
	emailTextField:resizeFontToFitHeight()
	emailTextField:setSelection(0,0)
-- 圖示-password.png
	local registerPassword = display.newImage("assets/password.png", registerEmail.x, registerEmail.y+registerEmail.contentHeight+floor(45*hRate))
	registerGroup:insert(registerPassword)
	registerPassword.width = registerPassword.width*wRate
	registerPassword.height = registerPassword.height*hRate
	registerPassword.anchorY = 0
-- password輸入欄位
	local passwordTextField = native.newTextField( registerPassword.x, registerPassword.y+registerPassword.contentHeight*0.7, registerPassword.contentWidth*0.95, registerPassword.contentHeight*0.5)
	registerGroup:insert(passwordTextField)
	passwordTextField.hasBackground = false
	passwordTextField.font = getFont.font
	passwordTextField.size = 16
	passwordTextField.isSecure = true
	passwordTextField:resizeFontToFitHeight()
	passwordTextField:setSelection(0,0)
-- 顯示文字-服務條款前文
	local serviceDescriptionText = display.newText({
		text = "通過電子信箱或第三方平台註冊奮路鳥旅遊平台帳號，代表您已閱讀及同意奮路鳥旅遊平台的",
		font = getFont.font,
		fontSize = 10,
		x = cx,
		y = registerPassword.y+registerPassword.contentHeight+floor(40*hRate),
		width = registerPassword.contentWidth,
		height = 0
	})
	registerGroup:insert(serviceDescriptionText)
	serviceDescriptionText.anchorY = 0
	serviceDescriptionText:setFillColor(unpack(wordColor))
-- 顯示文字-"服務條款"
	local serviceText = display.newText({
		text = "<服務條款>",
		font = getFont.font,
		fontSize = 10,
		x = serviceDescriptionText.x-serviceDescriptionText.contentWidth*0.5,
		y = serviceDescriptionText.y+serviceDescriptionText.contentHeight,
		width = registerPassword.contentWidth,
		height = 0
	})
	registerGroup:insert(serviceText)
	serviceText.anchorX = 0
	serviceText.anchorY = 0
	serviceText:setFillColor(unpack(mainColor1))
-- 服務條款監聽事件
	local function serviceListener( event )
		local phase = event.phase
		if (phase == "began") then
			event.target.alpha = 0.4
		elseif (phase == "ended") then
			event.target.alpha = 1
			--composer.gotoScene("login")
		end
	end
	serviceText:addEventListener("touch",serviceListener)
-- 顯示文字-"忘記密碼"
	local forgetPassword = display.newText({
		text = "忘記密碼?",
		font = getFont.font,
		fontSize = 10,
		x = registerPassword.x-registerPassword.contentWidth*0.5,
		y = registerPaper.y+registerPaper.contentHeight-paperShadowHeight-floor(60*hRate),
	})
	registerGroup:insert(forgetPassword)
	forgetPassword:setFillColor(unpack(wordColor))
	forgetPassword.anchorX = 0
	forgetPassword.anchorY = 1
-- 忘記密碼監聽事件
	local function passwordListener( event )
		local phase = event.phase
		if (phase == "began") then
			event.target.alpha = 0.4
		elseif (phase == "ended") then
			event.target.alpha = 1
			local options = {
				params = {
					backScene = getBackScene,
					productId = getProductId,
				}
			}
			composer.gotoScene( "forgetPassword", options)
		end
	end
	forgetPassword:addEventListener("touch",passwordListener)
-- 顯示文字-"|"
	local mark = display.newText({
		text = "|",
		font = getFont.font,
		fontSize = 12,
		x = forgetPassword.x+forgetPassword.contentWidth+ceil(10*wRate),
		y = forgetPassword.y-forgetPassword.contentHeight*0.6,
	})
	registerGroup:insert(mark)
	mark:setFillColor(unpack(wordColor))
	mark.anchorX = 0
-- 顯示文字-"登入帳號"
	local login = display.newText({
		text = "登入帳號",
		font = getFont.font,
		fontSize = 10,
		x = mark.x+mark.contentWidth+ceil(10*wRate),
		y = forgetPassword.y
	})
	registerGroup:insert(login)
	login:setFillColor(unpack(wordColor))
	login.anchorX = 0
	login.anchorY = 1
-- 登入帳號監聽事件
	local function loginListener( event )
		local phase = event.phase
		if (phase == "began") then
			event.target.alpha = 0.4
		elseif (phase == "ended") then
			event.target.alpha = 1
			local options = {
				params = {
					backScene = getBackScene,
					productId = getProductId,
				}
			}
			composer.gotoScene( "login", options)
		end
	end
	login:addEventListener("touch",loginListener)
-- 註冊按鈕
	local registerBtn = widget.newButton({
		id = "registerBtn",
		label = "註冊",
		labelColor = { default = {1,1,1}, over = {1,1,1}},
		font = getFont.font,
		fontSize  = 14,
		defaultFile = "assets/login-btn.png",
		x = login.x+login.contentWidth+ceil(40*wRate),
		y = registerPaper.y+registerPaper.contentHeight-paperShadowHeight-floor(50*hRate),
		width = 338*wRate,
		height = 84*hRate,
	})
	registerGroup:insert(registerBtn)
	registerBtn.anchorX = 0
	registerBtn.anchorY = 1
------------------- 第三方登入元件 -------------------
-- 顯示文字-"或"
	local orText = display.newText({
		text = "或",
		font = getFont.font,
		fontSize = 12,
		x = cx,
		y = registerPaper.y+registerPaper.contentHeight
	})
	registerGroup:insert(orText)
	orText.anchorY = 0
-- 左邊白線
	local leftLine = display.newLine( paperBaseX, orText.y+orText.contentHeight*0.5, paperBaseX+registerPaper.contentWidth*0.4, orText.y+orText.contentHeight*0.5)
	registerGroup:insert(leftLine)
	leftLine.strokeWidth = 1
-- 右邊白線
	local rightLine = display.newLine( registerPaper.x+registerPaper.contentWidth*0.5-paperShadowWidth, orText.y+orText.contentHeight*0.5, registerPaper.x+registerPaper.contentWidth*0.5-paperShadowWidth-registerPaper.contentWidth*0.4, orText.y+orText.contentHeight*0.5)
	registerGroup:insert(rightLine)
	rightLine.strokeWidth = 1
-- google
	local google = display.newImage("assets/google.png", cx, orText.y+orText.contentHeight+floor(35*hRate))
	registerGroup:insert(google)
	google.anchorY = 0
	google.width = google.width*math.sqrt(wRate*hRate)
	google.height = google.height*math.sqrt(wRate*hRate)
-- facebook
	local facebook = display.newImage("assets/facebook.png", google.x-google.contentWidth*0.5-ceil(36*wRate), google.y)
	registerGroup:insert(facebook)
	facebook.anchorX = 1
	facebook.anchorY = 0
	facebook.width = facebook.width*math.sqrt(wRate*hRate)
	facebook.height = facebook.height*math.sqrt(wRate*hRate)
-- wechat
	local wechat = display.newImage("assets/wechat.png", google.x+google.contentWidth*0.5+ceil(36*wRate), google.y)
	registerGroup:insert(wechat)
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
		composer.removeScene("register")
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