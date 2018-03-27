-----------------------------------------------------------------------------------------
--
-- login.lua
--
-----------------------------------------------------------------------------------------
local widget = require ("widget")
local composer = require("composer")
local getFont = require("setFont")
local mainTabBar = require("mainTabBar")
local json = require("json")
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
	------------------- 登入元件 -------------------
	-- 登入頁背景
		local loginGroup = display.newGroup()
		sceneGroup:insert(loginGroup)	
		local loginBackGround = display.newImage("assets/login-bg.png",cx,cy)
		loginGroup:insert(loginBackGround)
		loginBackGround.width = screenW+ox+ox
		loginBackGround.height = screenH+oy+oy
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
		loginGroup:insert(closeBtn)
		closeBtn.anchorX = 0
		closeBtn.anchorY = 0
	-- 圖示-login-logo.png
		local loginLogo = display.newImage("assets/login-logo.png",cx, floor(234*hRate))
		loginGroup:insert(loginLogo)
		loginLogo.width = loginLogo.width*0.1
		loginLogo.height = loginLogo.height*0.1
		loginLogo.anchorY = 0
	-- 圖示-login-paper.png
		local loginPaper = display.newImage("assets/login-paper.png",cx, loginLogo.y+loginLogo.contentHeight+floor(91*hRate))
		loginGroup:insert(loginPaper)
		loginPaper.width = loginPaper.width*wRate
		loginPaper.height = loginPaper.height*hRate
		loginPaper.anchorY = 0
	-- login-paper部分資訊
		local paperShadowWidth = ceil(loginPaper.contentWidth*0.05)
		local paperBaseX = loginPaper.x-loginPaper.contentWidth*0.5+paperShadowWidth
		local paperShadowHeight = floor(loginPaper.contentHeight*0.07)
		local paperBaseY = loginPaper.y+paperShadowHeight
	-- 圖示-e-mail.png
		local loginEmail = display.newImage("assets/e-mail.png", loginPaper.x, paperBaseY+floor(80*hRate))
		loginGroup:insert(loginEmail)
		loginEmail.width = loginEmail.width*wRate
		loginEmail.height = loginEmail.height*hRate
		loginEmail.anchorY = 0
	-- email輸入欄位
		local emailTextField = native.newTextField( loginEmail.x, loginEmail.y+loginEmail.contentHeight*0.7, loginEmail.contentWidth*0.95, loginEmail.contentHeight*0.5)
		loginGroup:insert(emailTextField)
		emailTextField.hasBackground = false
		emailTextField.font = getFont.font
		emailTextField.size = 16
		emailTextField.inputType = "email"
		emailTextField:resizeFontToFitHeight()
		emailTextField:setSelection(0,0)
		--emailTextField.placeholder = "12345"
	-- 圖示-password.png
		local loginPassword = display.newImage("assets/password.png", loginEmail.x, loginEmail.y+loginEmail.contentHeight+floor(45*hRate))
		loginGroup:insert(loginPassword)
		loginPassword.width = loginPassword.width*wRate
		loginPassword.height = loginPassword.height*hRate
		loginPassword.anchorY = 0
	-- password輸入欄位
		local passwordTextField = native.newTextField( loginPassword.x, loginPassword.y+loginPassword.contentHeight*0.7, loginPassword.contentWidth*0.95, loginPassword.contentHeight*0.5)
		loginGroup:insert(passwordTextField)
		passwordTextField.hasBackground = false
		passwordTextField.font = getFont.font
		passwordTextField.size = 16
		passwordTextField.isSecure = true
		passwordTextField:resizeFontToFitHeight()
		passwordTextField:setSelection(0,0)
	-- 記住我checkBox
		local checkboxOptions = {
			frames = 
			{
				{
					x = 0,
					y = 0,
					width = 91,
					height = 91
				},
				{
					x = 116,
					y = 0,
					width = 91,
					height = 91
				},
				{
					x = 0,
					y = 104,
					width = 48,
					height = 48
				},
				{
					x = 60,
					y = 104,
					width = 48,
					height = 48
				},
			}
		}
		local checkboxSheet = graphics.newImageSheet("assets/checkbox.png",checkboxOptions)
		local remCheckBox = widget.newSwitch({
				id = "remCheckBox",
				style = "checkbox",
				x = loginPassword.x-loginPassword.contentWidth*0.5,
				y = loginPassword.y+loginPassword.contentHeight+ceil(60*hRate),
				sheet = checkboxSheet,
				frameOff = 2,
				frameOn = 1
			})
		loginGroup:insert(remCheckBox)
		remCheckBox.anchorX = 0
		remCheckBox.anchorY = 0
		remCheckBox:scale(0.4,0.4)
	-- 顯示文字-"記住我"
		local rememberMeWord = display.newText({
			text = "記住我",
			font = getFont.font,
			fontSize = 10,
			x = remCheckBox.x+remCheckBox.contentWidth+ceil(13*wRate),
			y = remCheckBox.y+remCheckBox.contentHeight*0.5,
		})
		loginGroup:insert(rememberMeWord)
		rememberMeWord:setFillColor(unpack(wordColor))
		rememberMeWord.anchorX = 0
	-- 記住我監聽事件
		local function rememberListener( event )
			local phase = event.phase
			if (phase == "ended") then
				if (remCheckBox.isOn == false) then
					--remCheckBox.isOn = true
					remCheckBox:setState({
							isOn = true,
						})
				else
					--remCheckBox.isOn = false
					remCheckBox:setState({
							isOn = false,
						})
				end
			end
			return true
		end
		rememberMeWord:addEventListener("touch",rememberListener)
	-- 顯示文字-"忘記密碼"
		local forgetPassword = display.newText({
			text = "忘記密碼?",
			font = getFont.font,
			fontSize = 10,
			x = loginPassword.x-loginPassword.contentWidth*0.5,
			y = loginPaper.y+loginPaper.contentHeight-paperShadowHeight-floor(60*hRate),
		})
		loginGroup:insert(forgetPassword)
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
				composer.gotoScene("forgetPassword", options)
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
		loginGroup:insert(mark)
		mark:setFillColor(unpack(wordColor))
		mark.anchorX = 0
	-- 顯示文字-"註冊帳號"
		local register = display.newText({
			text = "註冊帳號",
			font = getFont.font,
			fontSize = 10,
			x = mark.x+mark.contentWidth+ceil(10*wRate),
			y = forgetPassword.y
		})
		loginGroup:insert(register)
		register:setFillColor(unpack(wordColor))
		register.anchorX = 0
		register.anchorY = 1
	-- 註冊帳號監聽事件
		local function registerListener( event )
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
				composer.gotoScene("register", options)
			end
		end
		register:addEventListener("touch",registerListener)
	-- 登入監聽事件
		local function loginListener( event )
			if ( emailTextField.text ~= "" and passwordTextField.text ~= "") then
				local function getTokenListener( event )
					if (event.isError) then
						print("Network Error： ", event.response)
					else
						-- get accessToken
						print ("RESPONSE: " .. event.response)
						local decodedData = (json.decode(event.response))
						local accessToken = decodedData["access_token"]
						composer.setVariable("accessToken", accessToken)
						if (accessToken) then
							-- get userData
							local function getUserDataListener( event )
								if (event.isError) then
									print("Network Error：", event.response)
								else
									--print ("RESPONSE: " .. event.response)
									local decodedData = (json.decode(event.response))
									local nickName = decodedData["name"]
									composer.setVariable("isLogin", true)
									composer.setVariable("nickName", nickName)
									if ( getBackScene == "goodPage" ) then
										local options = {
											params = {
												productId = getProductId,
											}
										}
										composer.gotoScene(getBackScene, options)
									else
										mainTabBar.setSelectedHomePage()
										composer.gotoScene("homePage")
									end
								end
							end
							local headers = {}
							headers["Authorization"] = "Bearer "..accessToken
							local params = {}
							params.headers = headers
							local getUserDataUrl = "http://211.21.114.208/1.0/user/GetLoginUserInfo/"
							network.request( getUserDataUrl, "GET", getUserDataListener,params)
						end
					end
				end
				local headers = {}
				local body = "grant_type=password&scope=normal&username="..emailTextField.text.."&password="..passwordTextField.text
				local params = {}
				params.headers = headers
				params.body = body
				local getTokenUrl = "http://211.21.114.208/oauth/token?client_id=blissangkor&client_secret=bGl2ZS10ZXN0"
				network.request( getTokenUrl, "POST", getTokenListener, params)
			end
		end
	-- 登入按鈕
		local loginBtn = widget.newButton({
			id = "loginBtn",
			label = "登入",
			labelColor = { default = {1,1,1}, over = {1,1,1}},
			font = getFont.font,
			fontSize  = 14,
			defaultFile = "assets/login-btn.png",
			x = register.x+register.contentWidth+ceil(40*wRate),
			y = loginPaper.y+loginPaper.contentHeight-paperShadowHeight-floor(50*hRate),
			width = 338*wRate,
			height = 84*hRate,
			onRelease = loginListener,
		})
		loginGroup:insert(loginBtn)
		loginBtn.anchorX = 0
		loginBtn.anchorY = 1
	------------------- 第三方登入元件 -------------------
	-- 顯示文字-"或"
		local orText = display.newText({
			text = "或",
			font = getFont.font,
			fontSize = 12,
			x = cx,
			y = loginPaper.y+loginPaper.contentHeight
		})
		loginGroup:insert(orText)
		orText.anchorY = 0
	-- 左邊白線
		local leftLine = display.newLine( paperBaseX, orText.y+orText.contentHeight*0.5, paperBaseX+loginPaper.contentWidth*0.4, orText.y+orText.contentHeight*0.5)
		loginGroup:insert(leftLine)
		leftLine.strokeWidth = 1
	-- 右邊白線
		local rightLine = display.newLine( loginPaper.x+loginPaper.contentWidth*0.5-paperShadowWidth, orText.y+orText.contentHeight*0.5, loginPaper.x+loginPaper.contentWidth*0.5-paperShadowWidth-loginPaper.contentWidth*0.4, orText.y+orText.contentHeight*0.5)
		loginGroup:insert(rightLine)
		rightLine.strokeWidth = 1
	-- google
		local google = display.newImage("assets/google.png", cx, orText.y+orText.contentHeight+floor(35*hRate))
		loginGroup:insert(google)
		google.anchorY = 0
		google.width = google.width*math.sqrt(wRate*hRate)
		google.height = google.height*math.sqrt(wRate*hRate)
	-- facebook
		local facebook = display.newImage("assets/facebook.png", google.x-google.contentWidth*0.5-ceil(36*wRate), google.y)
		loginGroup:insert(facebook)
		facebook.anchorX = 1
		facebook.anchorY = 0
		facebook.width = facebook.width*math.sqrt(wRate*hRate)
		facebook.height = facebook.height*math.sqrt(wRate*hRate)
	-- wechat
		local wechat = display.newImage("assets/wechat.png", google.x+google.contentWidth*0.5+ceil(36*wRate), google.y)
		loginGroup:insert(wechat)
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
		composer.removeScene("login")
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