-----------------------------------------------------------------------------------------
--
-- LN_login.lua
--
-----------------------------------------------------------------------------------------
local widget = require ("widget")
local composer = require("composer")
local getFont = require("setFont")
local mainTabBar = require("mainTabBar")
local json = require("json")
local optionsTable = require("optionsTable")
local token = require("token")

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

local accountTextField, remCheckBox
-- create()
function scene:create( event )
	local sceneGroup = self.view
	local getBackScene = event.params.backScene
	local getProductId = event.params.productId
	mainTabBar.myTabBarHidden()
	-- 讀檔/建檔 --
		local path = system.pathForFile( "login.data", system.DocumentsDirectory )
		local file = io.open(path, "r")
		local list = {}
		if not file then
			file = io.open( path, "w")
			file:write( "isOn=false\n", "id=N/A")
			io.close(file)
			file = nil
			file = io.open(path, "r")
		end
		local contents = file:read("*l")
		local count = 1
		while (contents ~= nil) do
			list[count] = contents
			count = count+1
			contents = file:read("*l")
		end
		io.close(file)
		file = nil
		
		local contentPattern = "%a+%=(.+)"
		local getIsOn = list[1]:match(contentPattern)
		local getId = list[2]:match(contentPattern)
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
		local loginLogo = display.newImage( "assets/login-logo.png", cx, floor(234*hRate))
		loginGroup:insert(loginLogo)
		loginLogo.width = loginLogo.width*0.1
		loginLogo.height = loginLogo.height*0.1
		loginLogo.anchorY = 0
	-- 圖示-login-paper.png
		local loginPaper = display.newImage( "assets/login-paper.png", cx, loginLogo.y+loginLogo.contentHeight+floor(91*hRate))
		loginGroup:insert(loginPaper)
		loginPaper.width = loginPaper.width*wRate
		loginPaper.height = loginPaper.height*hRate
		loginPaper.anchorY = 0
	-- login-paper部分資訊
		local paperShadowWidth = ceil(loginPaper.contentWidth*0.05)
		local paperBaseX = loginPaper.x-loginPaper.contentWidth*0.5+paperShadowWidth
		local paperShadowHeight = floor(loginPaper.contentHeight*0.07)
		local paperBaseY = loginPaper.y+paperShadowHeight
	-- 圖示-account.png
		local loginAccount = display.newImage("assets/account.png", loginPaper.x, paperBaseY+floor(80*hRate))
		loginGroup:insert(loginAccount)
		loginAccount.width = loginAccount.width*wRate
		loginAccount.height = loginAccount.height*hRate
		loginAccount.anchorY = 0
	-- account輸入欄位
		accountTextField = native.newTextField( loginAccount.x, loginAccount.y+loginAccount.contentHeight*0.7, loginAccount.contentWidth*0.95, loginAccount.contentHeight*0.5)
		loginGroup:insert(accountTextField)
		accountTextField.hasBackground = false
		accountTextField.font = getFont.font
		accountTextField.size = 16
		accountTextField:resizeFontToFitHeight()
		accountTextField:setSelection(0,0)
		accountTextField:setReturnKey("next")
	-- 圖示-password.png
		local loginPassword = display.newImage("assets/password.png", loginAccount.x, loginAccount.y+loginAccount.contentHeight+floor(45*hRate))
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
		passwordTextField:setReturnKey("done")
	-- 欄位監聽事件
		accountTextField:addEventListener( "userInput", function ( event )
			local phase = event.phase
			if ( phase == "submitted" ) then
				 native.setKeyboardFocus( passwordTextField )
			end 
		end)
		passwordTextField:addEventListener( "userInput", function ( event )
			local phase = event.phase
			if ( phase == "submitted" ) then
				 native.setKeyboardFocus( nil )
			end 
		end)
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
			}
		}
		local checkboxSheet = graphics.newImageSheet("assets/checkbox.png",checkboxOptions)
		remCheckBox = widget.newSwitch({
				id = "remCheckBox",
				style = "checkbox",
				x = loginPassword.x-loginPassword.contentWidth*0.5,
				y = loginPassword.y+loginPassword.contentHeight+ceil(60*hRate),
				sheet = checkboxSheet,
				frameOff = 2,
				frameOn = 1,
			})
		loginGroup:insert(remCheckBox)
		remCheckBox.anchorX = 0
		remCheckBox.anchorY = 0
		remCheckBox:scale(0.4,0.4)
		if ( getIsOn == "false" ) then
			remCheckBox:setState( { isOn = false, isAnimate = true } )
		else
			remCheckBox:setState( { isOn = true, isAnimate = true } )
			accountTextField.text = getId
		end
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
							--onComplete = checkboxListener,
						})
				else
					--remCheckBox.isOn = false
					remCheckBox:setState({
							isOn = false,
							--onComplete = checkboxListener,
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
				composer.gotoScene("LN_forgetPassword", options)
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
				composer.gotoScene("LN_register", options)
			end
		end
		register:addEventListener("touch",registerListener)
	-- 登入監聽事件
		local loginBtn
		local function loginListener( event )
			loginBtn:setEnabled(false)
			if ( accountTextField.text == "" or passwordTextField.text == "" ) then
				native.showAlert( "", "帳號或是密碼未填寫，請重新確認", { "確定" }, 
					function( event )
						if ( event.action == "clicked" ) then
							loginBtn:setEnabled(true)
						end
					end)
			elseif ( accountTextField.text ~= "" and passwordTextField.text ~= "" ) then
				local function getTokenListener( event )
					if ( event.isError ) then
						print("Network Error： ", event.response)
					else
						-- get token
						--print ("GetTokenPhase RESPONSE: " .. event.response)
						local decodedData = json.decode(event.response)
						if ( decodedData["error"] ) then
							native.showAlert( "", "帳號或是密碼錯誤，請重新確認", { "確定" },
								function( event )
									if ( event.action == "clicked" ) then
										loginBtn:setEnabled(true)
									end
								end)
						else
							local toastGroup = display.newGroup()
							local toastRoundedRect = widget.newButton({
								x = cx,
								y = (screenH+oy+oy)*0.7,
								isEnabled = false,
								fillColor = { default = { 0, 0, 0, 0.6 }, over = { 0, 0, 0, 0.6 } },
								shape = "roundedRect",
								width = screenW*0.35,
								height = screenH/16,
								cornerRadius = 20,
							})
							toastGroup:insert(toastRoundedRect)
							local toastText = display.newText({
								text = "成功登入",
								font = getFont.font,
								fontSize = 14,
								x = toastRoundedRect.x,
								y = toastRoundedRect.y,
							})
							toastGroup:insert(toastText)
							transition.to( toastGroup, { time = 1000, alpha = 0, transition = easing.inExpo } )
							timer.performWithDelay( 1000, function ()
								toastGroup:removeSelf()
							end)
							local accessToken = decodedData["access_token"]
							local refreshToken = decodedData["refresh_token"]
							local expireTime = decodedData["expires_in"]
							token.doRefreshToken( accessToken, refreshToken, expireTime )
							
							composer.setVariable( "accessToken", accessToken )
							--composer.setVariable( "refreshToken", refreshToken )
							if ( accessToken ) then
								-- get userData
								local function getUserDataListener( event )
									if (event.isError) then
										print("Network Error：", event.response)
									else
										--print ("RESPONSE: " .. event.response)
										local decodedData = json.decode(event.response)
										--print( decodedData["id"], decodedData["name"], decodedData["email"])
										--local nickName = decodedData["name"]
										composer.setVariable("isLogin", true)
										local userLoginInfo = {}
										userLoginInfo.id = decodedData["id"]
										userLoginInfo.name = decodedData["id"]
										userLoginInfo.email = decodedData["email"]
										userLoginInfo.mobile = decodedData["mobile"]
										userLoginInfo.score = decodedData["score"]
										userLoginInfo.chFirstName = decodedData["chFirstName"]
										userLoginInfo.chLastName = decodedData["chLastName"]
										userLoginInfo.enFirstName = decodedData["enFirstName"]
										userLoginInfo.enLastName = decodedData["enLastName"]
										userLoginInfo.gender = decodedData["gender"]
										composer.setVariable( "userLoginInfo", userLoginInfo )
										
										--composer.setVariable("userId", decodedData["id"])
										composer.setVariable("userNickName", decodedData["name"])
										--composer.setVariable("userMail", decodedData["email"])
										loginBtn:setEnabled(true)
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
								headers["authorization"] = "Bearer "..accessToken
								local params = {}
								params.headers = headers
								local getUserDataUrl = optionsTable.getUserLonigInfoUrl
								network.request( getUserDataUrl, "POST", getUserDataListener, params)
							end
						end	
					end
				end
				local headers = {}
				local body = "grant_type=password&scope=normal&username="..accountTextField.text.."&password="..passwordTextField.text
				local params = {}
				params.headers = headers
				params.body = body
				local getTokenUrl = optionsTable.getTokenUrl
				network.request( getTokenUrl, "POST", getTokenListener, params)
			end
		end
	-- 登入按鈕
		loginBtn = widget.newButton({
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
		local path = system.pathForFile( "login.data", system.DocumentsDirectory )
		local file = io.open(path, "w")
		if ( remCheckBox.isOn == true ) then
			if ( accountTextField.text ~= "" ) then
				file:write("isOn=true\n", "id="..accountTextField.text.."\n")
			else
				file:write("isOn=false\n", "id=N/A\n")
			end
		else
			file:write("isOn=false\n", "id=N/A\n")
		end
		io.close(file)
		file = nil
	elseif (phase == "did") then
		composer.removeScene("LN_login")
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