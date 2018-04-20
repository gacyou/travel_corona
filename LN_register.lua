-----------------------------------------------------------------------------------------
--
-- LN_register.lua
--
-----------------------------------------------------------------------------------------
-- show default status bar (iOS)
display.setStatusBar( display.HiddenStatusBar )

local widget = require ("widget")
local composer = require("composer")
local getFont = require("setFont")
local mainTabBar = require("mainTabBar")
local json = require("json")
local optionsTable = require("optionsTable")
local scene = composer.newScene()

local wordColor = { 99/255, 99/255, 99/255 }
local backgroundColor = { 245/255, 245/255, 245/255 }
local mainColor1 = { 6/255, 184/255, 217/255 }
local mainColor2 = { 7/255, 162/255, 192/255 }
local subColor1 = { 246/255, 148/255, 106/255}
local subColor2 = { 250/255, 128/255, 79/255}
local separateLineColor = { 204/255, 204/255, 204/255 }
local hintAlertColor = { 247/255, 86/255, 86/255}

local ox, oy = math.abs(display.screenOriginX), math.abs(display.screenOriginY)
local cx, cy = display.contentCenterX, display.contentCenterY
local screenW, screenH = display.contentWidth, display.contentHeight
local wRate = screenW/1080
local hRate = screenH/1920

local ceil = math.ceil
local floor = math.floor

local function validemail(str)
	if str == nil then return nil end
	if (type(str) ~= 'string') then
		error("Expected string")
		return nil
	end
	local lastAt = str:find("[^%@]+$")
	local localPart = str:sub(1, (lastAt - 2)) -- Returns the substring before '@' symbol
	local domainPart = str:sub(lastAt, #str) -- Returns the substring after '@' symbol
	-- we werent able to split the email properly
	if localPart == nil then
		return nil, "Local name is invalid"
	end

	if domainPart == nil then
		return nil, "Domain is invalid"
	end
	-- local part is maxed at 64 characters
	if #localPart > 64 then
		return nil, "Local name must be less than 64 characters"
	end
	-- domains are maxed at 253 characters
	if #domainPart > 253 then
		return nil, "Domain must be less than 253 characters"
	end
	-- somthing is wrong
	if lastAt >= 65 then
		return nil, "Invalid @ symbol usage"
	end
	-- quotes are only allowed at the beginning of a the local name
	local quotes = localPart:find("[\"]")
	if type(quotes) == 'number' and quotes > 1 then
		return nil, "Invalid usage of quotes"
	end
	-- no @ symbols allowed outside quotes
	if localPart:find("%@+") and quotes == nil then
		return nil, "Invalid @ symbol usage in local part"
	end
	-- no dot found in domain name
	if not domainPart:find("%.") then
		return nil, "No TLD found in domain"
	end
	-- only 1 period in succession allowed
	if domainPart:find("%.%.") then
		return nil, "Too many periods in domain"
	end
	if localPart:find("%.%.") then
		return nil, "Too many periods in local part"
	end
	-- just a general match
	if not str:match("[%w%p]*%w+%@[%.%w]*%.%a+") then
		return nil, "Email pattern test failed"
	end
	-- all our tests passed, so we are ok
	return true
end
-- create()
function scene:create( event )
	local sceneGroup = self.view
	--local getBackScene
	--local getProductId
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
				composer.gotoScene( getBackScene, options )
			end
		})
		registerGroup:insert(closeBtn)
		closeBtn.anchorX = 0
		closeBtn.anchorY = 0
	-- 圖示-login-logo.png
		local registerLogo = display.newImage( "assets/login-logo.png", cx, floor(234*hRate))
		registerGroup:insert(registerLogo)
		registerLogo.width = registerLogo.width*0.1
		registerLogo.height = registerLogo.height*0.1
		registerLogo.anchorY = 0
	-- 圖示-login-paper.png
		local registerPaper = display.newImage( "assets/login-paper.png", cx, registerLogo.y+registerLogo.contentHeight)
		registerGroup:insert(registerPaper)
		registerPaper.width = registerPaper.width*wRate
		registerPaper.height = registerPaper.height*hRate*1.6
		registerPaper.anchorY = 0
	-- registerPaper參數
		local paperShadowWidth = ceil(registerPaper.contentWidth*0.05)
		local paperBaseX = registerPaper.x-registerPaper.contentWidth*0.5+paperShadowWidth
		local paperShadowHeight = floor(registerPaper.contentHeight*0.07)
		local paperBaseY = registerPaper.y+paperShadowHeight
	-- 圖示-account.png
		local registerAccount = display.newImage("assets/account.png", registerPaper.x, paperBaseY+floor(40*hRate))
		registerGroup:insert(registerAccount)
		registerAccount.width = registerAccount.width*wRate
		registerAccount.height = registerAccount.height*hRate
		registerAccount.anchorY = 0
	-- 提示文字
		local hintText = display.newText({
			parent = registerGroup,
			text = "*所有欄位皆為必填項目",
			font = getFont.font,
			fontSize = 10,
			x = registerAccount.x-registerAccount.contentWidth*0.5,
			y = registerAccount.y,
		})
		hintText:setFillColor(unpack(hintAlertColor))
		hintText.anchorX = 0
		hintText.anchorY = 1
	-- 帳號輸入欄位
		local accountTextField = native.newTextField( registerAccount.x, registerAccount.y+registerAccount.contentHeight*0.7, registerAccount.contentWidth*0.95, registerAccount.contentHeight*0.5)
		registerGroup:insert(accountTextField)
		accountTextField.name = "account"
		accountTextField.hasBackground = false
		accountTextField.font = getFont.font
		accountTextField.size = 16
		accountTextField.placeholder = "帳號長度至少為4，不可以有任何符號"
		accountTextField:resizeFontToFitHeight()
		accountTextField:setSelection(0,0)
		accountTextField:setReturnKey("next")
	-- 圖示-password.png
		local registerPassword = display.newImage("assets/password.png", registerAccount.x, registerAccount.y+registerAccount.contentHeight+floor(45*hRate))
		registerGroup:insert(registerPassword)
		registerPassword.width = registerPassword.width*wRate
		registerPassword.height = registerPassword.height*hRate
		registerPassword.anchorY = 0
	-- password輸入欄位
		local passwordTextField = native.newTextField( registerPassword.x, registerPassword.y+registerPassword.contentHeight*0.7, registerPassword.contentWidth*0.95, registerPassword.contentHeight*0.5)
		registerGroup:insert(passwordTextField)
		passwordTextField.name = "password"
		passwordTextField.hasBackground = false
		passwordTextField.font = getFont.font
		passwordTextField.size = 16
		passwordTextField.placeholder = "密碼長度為8~16的英數混合字元"
		passwordTextField.isSecure = true
		passwordTextField:resizeFontToFitHeight()
		passwordTextField:setSelection(0,0)
		passwordTextField:setReturnKey("next")
	-- 圖示-confirmpwd.png
		local registerConfirmPassword = display.newImage("assets/confirmpwd.png", registerPassword.x, registerPassword.y+registerPassword.contentHeight+floor(45*hRate))
		registerGroup:insert(registerConfirmPassword)
		registerConfirmPassword.width = registerConfirmPassword.width*wRate
		registerConfirmPassword.height = registerConfirmPassword.height*hRate
		registerConfirmPassword.anchorY = 0
	-- confirnPassword輸入欄位
		local confirmPasswordTextField = native.newTextField( registerConfirmPassword.x, registerConfirmPassword.y+registerConfirmPassword.contentHeight*0.7, registerConfirmPassword.contentWidth*0.95, registerConfirmPassword.contentHeight*0.5)
		registerGroup:insert(confirmPasswordTextField)
		confirmPasswordTextField.name = "confirmPassword"
		confirmPasswordTextField.hasBackground = false
		confirmPasswordTextField.font = getFont.font
		confirmPasswordTextField.size = 16
		confirmPasswordTextField.placeholder = "請再輸入一次密碼，進行確認"
		confirmPasswordTextField.isSecure = true
		confirmPasswordTextField:resizeFontToFitHeight()
		confirmPasswordTextField:setSelection(0,0)
		confirmPasswordTextField:setReturnKey("next")	
	-- 圖示-e-mail.png
		local registerEmail = display.newImage("assets/e-mail.png", registerConfirmPassword.x, registerConfirmPassword.y+registerConfirmPassword.contentHeight+floor(45*hRate))
		registerGroup:insert(registerEmail)
		registerEmail.width = registerEmail.width*wRate
		registerEmail.height = registerEmail.height*hRate
		registerEmail.anchorY = 0
	-- Email輸入欄位
		local emailTextField = native.newTextField( registerEmail.x, registerEmail.y+registerEmail.contentHeight*0.7, registerEmail.contentWidth*0.95, registerEmail.contentHeight*0.5)
		registerGroup:insert(emailTextField)
		emailTextField.name = "email"
		emailTextField.hasBackground = false
		emailTextField.font = getFont.font
		emailTextField.size = 16
		emailTextField.placeholder = "請輸入電子郵件信箱"
		emailTextField.inputType = "email"
		emailTextField:resizeFontToFitHeight()
		emailTextField:setSelection(0,0)
		emailTextField:setReturnKey("next")
	-- 圖示-nickname.png
		local registerNickname = display.newImage("assets/nickname.png", registerEmail.x, registerEmail.y+registerEmail.contentHeight+floor(45*hRate))
		registerGroup:insert(registerNickname)
		registerNickname.width = registerNickname.width*wRate
		registerNickname.height = registerNickname.height*hRate
		registerNickname.anchorY = 0
	-- 暱稱輸入欄位
		local nicknameTextField = native.newTextField( registerNickname.x, registerNickname.y+registerNickname.contentHeight*0.7, registerNickname.contentWidth*0.95, registerNickname.contentHeight*0.5)
		registerGroup:insert(nicknameTextField)
		nicknameTextField.name = "nickname"	
		nicknameTextField.hasBackground = false
		nicknameTextField.font = getFont.font
		nicknameTextField.size = 16
		nicknameTextField.placeholder = "請輸入暱稱"
		nicknameTextField:resizeFontToFitHeight()
		nicknameTextField:setSelection(0,0)
		nicknameTextField:setReturnKey("done")
	-- 輸入欄位監聽事件
		local function textFieldListner( event )
			local phase = event.phase
			local name = event.target.name
			if ( phase == "submitted" ) then
				if ( name == "account" ) then
					native.setKeyboardFocus( passwordTextField )
				elseif ( name == "password" ) then
					native.setKeyboardFocus( confirmPasswordTextField )
				elseif ( name == "confirmPassword" ) then
					native.setKeyboardFocus( emailTextField )
				elseif ( name == "email" ) then
					native.setKeyboardFocus( nicknameTextField )
				elseif ( name == "nickname" ) then
					native.setKeyboardFocus( nil )
				end
			end
		end
		accountTextField:addEventListener("userInput", textFieldListner)
		passwordTextField:addEventListener("userInput", textFieldListner)
		confirmPasswordTextField:addEventListener("userInput", textFieldListner)
		emailTextField:addEventListener("userInput", textFieldListner)
		nicknameTextField:addEventListener("userInput", textFieldListner)
	-- 顯示文字-服務條款前文
		local serviceDescriptionText = display.newText({
			text = "通過電子信箱或第三方平台註冊奮路鳥旅遊平台帳號，代表您已閱讀及同意奮路鳥旅遊平台的",
			font = getFont.font,
			fontSize = 10,
			x = cx,
			y = registerNickname.y+registerNickname.contentHeight+floor(40*hRate),
			width = registerNickname.contentWidth,
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
			width = registerNickname.contentWidth,
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
				system.openURL( optionsTable.disclaimerWeb )
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
				composer.gotoScene( "LN_forgetPassword", options)
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
				composer.gotoScene( "LN_login", options)
			end
		end
		login:addEventListener( "touch",loginListener )
	-- 註冊按鈕
		--local checkPwdPattern = "%d*%a+%d+%w*"
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
			onRelease = 
			function( event )
				if ( accountTextField.text == "" or passwordTextField.text == "" or confirmPasswordTextField.text == "" or emailTextField.text == "" or nicknameTextField.text == "" ) then
					native.showAlert( "", "所有欄位為必填項目，請將未填寫的項目填寫完畢", { "確定" } )
				else
					if ( string.len(accountTextField.text) < 4 ) then
						native.showAlert( "", "帳號長度輸入過短，請重新輸入", { "確定" }, 
							function ( event )
								if ( event.action == "clicked" ) then
									accountTextField.text = ""
								end
							end)
					elseif ( not accountTextField.text:match("^[%w%_]*%w+$") ) then
						native.showAlert( "", "帳號內有_以外的符號或是其他非英文字元，請重新輸入", { "確定" }, 
							function ( event )
								if ( event.action == "clicked" ) then
									accountTextField.text = ""
								end
							end)
					elseif ( string.len(passwordTextField.text) < 8 or string.len(passwordTextField.text) > 16 ) then
						native.showAlert( "", "密碼長度過短或是過長，請重新輸入", { "確定" }, 
							function ( event )
								if ( event.action == "clicked" ) then
									passwordTextField.text = ""
									confirmPasswordTextField.text = ""
								end
							end)
					elseif (  passwordTextField.text == accountTextField.text ) then
						native.showAlert( "", "密碼不可以與帳號相同，請重新輸入", { "確定" }, 
							function ( event )
								if ( event.action == "clicked" ) then
									passwordTextField.text = ""
									confirmPasswordTextField.text = ""
								end
							end)
					elseif (  not passwordTextField.text:match("^%d*%a+%d+%w*$") ) then
						native.showAlert( "", "密碼裡面至少要有一個英文字母跟一個數字，請重新輸入", { "確定" }, 
							function ( event )
								if ( event.action == "clicked" ) then
									passwordTextField.text = ""
									confirmPasswordTextField.text = ""
								end
							end)
					elseif ( passwordTextField.text ~= confirmPasswordTextField.text ) then
						native.showAlert( "", "密碼兩次輸入為不同，請重新輸入", { "確定" }, 
							function ( event )
								if ( event.action == "clicked" ) then
									passwordTextField.text = ""
									confirmPasswordTextField.text = ""
								end
							end)
					elseif ( not validemail( emailTextField.text ) ) then
							native.showAlert( "", "電子郵件輸入格式有誤，請重新輸入", { "確定" }, 
							function ( event )
								if ( event.action == "clicked" ) then
									emailTextField.text = ""
								end
							end)
					else
						print("OK")
						local function memberRegister( event )
							if ( event.isError ) then
								print( "NetWork Error："..event.response )
							else
								print( "Response："..event.response )
								native.showAlert( "", "註冊完成，可以進行登入來體驗更多的樂趣", { "確定" }, 
								function ( event )
									if ( event.action == "clicked" ) then
										local options = {
											time = 200, 
											effect = "fade",
											params = {
												backScene = getBackScene,
												productId = getProductId,
											}
										}
										composer.gotoScene("LN_login", options)
									end
								end)
							end
						end
						local headers = {}
						local body = "name="..nicknameTextField.text.."&email="..emailTextField.text.."&account="..accountTextField.text.."&password="..passwordTextField.text
						local params = {}
						params.headers = headers
						params.body = body
						local registerUrl = optionsTable.memberRegister
						network.request( registerUrl, "POST", memberRegister, params )
					end			
				end
			end
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
		composer.removeScene("LN_register")
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