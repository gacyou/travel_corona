-----------------------------------------------------------------------------------------
--
-- personalcenter.lua
--
-----------------------------------------------------------------------------------------
local composer = require( "composer" )
local widget = require( "widget" )
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

local nameText,edit

local isLogin
if (composer.getVariable("isLogin")) then 
	isLogin = composer.getVariable("isLogin")
else
	isLogin = false
end

local nickName
if (composer.getVariable("nickName")) then
	nickName = composer.getVariable("nickName")
else
	nickName = "登入/註冊"
end

local ceil = math.ceil
local floor = math.floor

function scene:create( event )
	local sceneGroup = self.view
	if ( composer.getVariable("mainTabBarStatus") and composer.getVariable("mainTabBarStatus") == "hidden" ) then
		mainTabBar.myTabBarScrollShown()
		mainTabBar.setSelectedPersonalCenter()
		composer.setVariable("mainTabBarStatus", "shown")
	else
		mainTabBar.myTabBarShown()
		mainTabBar.setSelectedPersonalCenter()
	end
	local function onBtnListener( event )
		local targetId = event.target.id
		if (targetId == "myOrderBtn") then
			-- 我的訂單
			composer.gotoScene("myorderList",{effect = "fade", time = 200})	
		elseif (targetId == "hopeListBtn") then
			-- 願望清單
			composer.gotoScene("hopelist",{effect = "fromLeft", time = 200})
		elseif ( targetId == "accSettingBtn" and isLogin == true ) then
			-- 帳戶設定
			composer.showOverlay("accountSetting",
				{ isModal = true, effect = "zoomOutIn", time = 200})
		elseif (targetId == "advisoryCenterBtn") then 
			-- 諮詢中心
			options = {
				effect = "fade", 
				time = 200,
				params = {
					backScene = "personalcenter"
				}
			}
			composer.gotoScene("advisorCenter", options)
		elseif (targetId == "chgLanguageBtn") then
			-- 更改語言/貨幣
			--composer.gotoScene("chglanguage",{ effect = "fromLeft", time = 200})
			composer.showOverlay("chglanguage", { isModal = true, effect = "fromLeft", time = 200})
		elseif ( targetId == "logoutBtn" and isLogin == true ) then
			-- 登出帳號
			local logoutAlert = native.showAlert( "登出", "確定登出當前帳號嗎?", { "登出", "取消"}, 
				function (event)
					if (event.action == "clicked") then
						local index = event.index
						if ( index == 1) then
							if ( composer.getVariable("accessToken") and composer.getVariable("accessToken") ~= "N/A" ) then
								composer.setVariable("accessToken", "N/A")
							end
							isLogin = false
							composer.setVariable("isLogin", false)
							composer.setVariable("nickName","登入/註冊")
							nameText.text = "登入/註冊"
							edit.fill = {type = "image", filename = "assets/user.jpg"}
						end
					end
				end )
		end
		return true
	end
	------------------ 抬頭元件 -------------------
	-- 個人訊息藍色背景
		local personalCenterPic = display.newImageRect( "assets/bg-personalcenter.png", screenW+ox+ox, floor(450*hRate))
		sceneGroup:insert(personalCenterPic)
		personalCenterPic.x = cx
		personalCenterPic.y = -oy+personalCenterPic.contentHeight*0.5	
	-- 頭像外框
		local userFrame = display.newImageRect("assets/user-pictureframe.png", 170, 170)
		sceneGroup:insert(userFrame)
		userFrame.width = floor(userFrame.width*wRate)
		userFrame.height = floor(userFrame.height*wRate)
		userFrame.anchorX = 0
		userFrame.anchorY = 0
		userFrame.x = -ox+floor(68*wRate)
		userFrame.y = floor(-oy)+ceil(65*wRate)
	-- 小白筆
		local pencilPic = display.newImageRect("assets/pencil-w.png", 45, 50)
		sceneGroup:insert(pencilPic)
		pencilPic.width = ceil(pencilPic.width*wRate)
		pencilPic.height = floor(pencilPic.height*wRate)
		pencilPic.anchorX = 0
		pencilPic.anchorY = 1
		pencilPic.x = userFrame.x+userFrame.contentWidth+ceil(4*wRate)
		pencilPic.y = userFrame.y+userFrame.contentHeight
	-- 圖片
		edit = display.newRoundedRect( 0, 0, 0, 0, 1)
		sceneGroup:insert(edit)
		edit.width = userFrame.contentWidth*0.925
		edit.height = userFrame.contentHeight*0.925
		edit.x = userFrame.x+userFrame.contentWidth*0.5
		edit.y = userFrame.y+userFrame.contentHeight*0.5
		edit:setFillColor(0.3)
	-- 顯示文字-名字(暱稱)
		nameText = display.newText(
		{
			text = nickName,
			font = getFont.font,
			fontSize = 22,
		})
		sceneGroup:insert(nameText)
		nameText.anchorX = 0
		nameText.anchorY = 0
		nameText.x = userFrame.x+userFrame.contentWidth+ceil(61*wRate)
		nameText.y = floor(-oy)+ceil(108*hRate)
		if (nickName ~= "登入/註冊") then
			edit.fill = {type = "image", filename = "assets/wow.jpg"}
		else
			edit.fill = {type = "image", filename = "assets/user.jpg"}
		end
	-- 登入或編輯監聽事件
		local function loginOrEditation( event )
			if ( event.phase == "ended" ) then
				if (nameText.text == "登入/註冊") then
					local options = {
						params = {
							backScene = "personalcenter",
						}
					}
					composer.gotoScene("loginWelcome", options)
				else
					local options = { 
						effect = "fromLeft", 
						time = 300,
					}
					composer.gotoScene("editation",options)
					--composer.showOverlay("editation",{ isModal = true, effect = "fromLeft", time = 400})
				end
			end
			return true
		end
		edit:addEventListener("touch", loginOrEditation)
	-- 優惠碼
		local couponBase = display.newRect( screenW+ox-ceil(49*wRate), personalCenterPic.y+personalCenterPic.contentHeight*0.5-ceil(60*hRate), screenW/8, screenH/16)
		sceneGroup:insert(couponBase)
		couponBase.anchorX = 1
		couponBase.anchorY = 1
		couponBase.fill = { type = "image", filename = "assets/transparent.png"}

		local couponText = display.newText({
			text = "優惠碼",
			x = couponBase.x,
			y = couponBase.y,
			font = getFont.font,
			fontSize = 12,
		})
		sceneGroup:insert(couponText)
		couponText.anchorX = 1
		couponText.anchorY = 1
		
		local couponNumText = display.newText({
			text = "0",
			x = couponText.x-couponText.contentWidth*0.5,
			y = couponText.y-couponText.contentHeight-ceil(14*hRate),
			font = getFont.font,
			fontSize = 18,
		})
		sceneGroup:insert(couponNumText)
		couponNumText.anchorY = 1

		couponBase:addEventListener("touch", 
			function (event)
				local phase = event.phase
				if (phase == "began") then
					couponText:setFillColor( 0, 0, 0, 0.3)
					couponNumText:setFillColor( 0, 0, 0, 0.3)
				elseif (phase == "moved") then
					couponText:setFillColor(1)
					couponNumText:setFillColor(1)				
				elseif (phase == "ended") then
					couponText:setFillColor(1)
					couponNumText:setFillColor(1)
					composer.showOverlay("coupon",
						{ isModal = true, effect = "fromLeft", time = 300})
				end
			end
		)
	-- 分隔線
		local whiteLine = display.newLine( couponText.x-couponText.contentWidth-ceil(35*wRate), couponText.y, couponText.x-couponText.contentWidth-ceil(35*wRate), couponText.y-ceil(116*hRate))
		sceneGroup:insert(whiteLine)
		whiteLine:setStrokeColor(1)
	-- 積分
		local padding = couponBase.x - couponBase.contentWidth - whiteLine.x
		local pointBase = display.newRect( whiteLine.x-padding, couponBase.y, screenW/8, screenH/16)
		sceneGroup:insert(pointBase)
		pointBase.anchorX = 1
		pointBase.anchorY = 1
		pointBase.fill = { type = "image", filename = "assets/transparent.png"}

		local pointText = display.newText({
			text = "積分",
			x = whiteLine.x-ceil(35*wRate),
			y = couponText.y,
			font = getFont.font,
			fontSize = 12,
		})
		sceneGroup:insert(pointText)
		pointText.anchorX = 1
		pointText.anchorY = 1

		local pointNumText = display.newText({
			text = "0",
			x = pointText.x-pointText.contentWidth*0.5,
			y = couponNumText.y,
			font = getFont.font,
			fontSize = 18,
		})
		sceneGroup:insert(pointNumText)
		pointNumText.anchorY = 1

		pointBase:addEventListener("touch", 
			function (event)
				local phase = event.phase
				if (phase == "began") then
					pointText:setFillColor( 0, 0, 0, 0.3)
					pointNumText:setFillColor( 0, 0, 0, 0.3)
				elseif (phase == "moved") then
					pointText:setFillColor(1)
					pointNumText:setFillColor(1)				
				elseif (phase == "ended") then
					pointText:setFillColor(1)
					pointNumText:setFillColor(1)
					local options = { 
						isModal = true,
						effect = "fromLeft",
						time = 300,
						params = {
							point = pointNumText.text
						}
					}
					composer.showOverlay("mypoint",	options)
				end
			end
		)
	------------------ 中間按鈕元件 -------------------
	-- 陰影
		local btnRowShadow = display.newImageRect("assets/shadow0205.png", screenW+ox+ox, floor(178*hRate))
		sceneGroup:insert(btnRowShadow)
		btnRowShadow.x = cx
		btnRowShadow.y = personalCenterPic.y+personalCenterPic.contentHeight*0.5+btnRowShadow.contentHeight*0.5
	-- 我的訂單按鈕
		local myOrderBtn = widget.newButton({
			id = "myOrderBtn",
			shape = "Rect",
			width = (screenW+ox+ox)*0.5, 
			height = ceil(btnRowShadow.contentHeight*0.9),
			fillColor = { default = { 1, 1, 1, 1 }, over = { 1, 1, 1, 1 } },
			onRelease = onBtnListener,
		}) 
		sceneGroup:insert(myOrderBtn)
		myOrderBtn.x = -ox+myOrderBtn.contentWidth*0.5
		myOrderBtn.y = personalCenterPic.y+personalCenterPic.contentHeight*0.5+myOrderBtn.contentHeight*0.5
	-- 按鈕上的圖示
		local myOrderPic = display.newImageRect("assets/myorder-personalcenter.png",200,237) 
		sceneGroup:insert(myOrderPic)
		myOrderPic.anchorX = 0
		myOrderPic.anchorY = 0
		myOrderPic.width = myOrderPic.width*0.06
		myOrderPic.height = myOrderPic.height*0.06
		myOrderPic.x = -ox+ceil(62*wRate)
		myOrderPic.y = personalCenterPic.y+personalCenterPic.contentHeight*0.5+ceil(52*hRate)
	-- 顯示文字-"我的訂單"
		local myOrderText = display.newText({
			text = "我的訂單",
			font = getFont.font,
			fontSize = 10,
		})
		sceneGroup:insert(myOrderText)
		myOrderText:setFillColor(unpack(wordColor))
		myOrderText.anchorX = 0
		myOrderText.x = myOrderPic.x+myOrderPic.contentWidth+ceil(23*wRate)
		myOrderText.y = myOrderPic.y+myOrderPic.contentHeight*0.6
	-- 顯示文字-訂單數量
		local myOrderCountText = display.newText({
			text = "0",
			font = getFont.font,
			fontSize = 18,
		})
		sceneGroup:insert(myOrderCountText)
		myOrderCountText:setFillColor(unpack(wordColor))
		myOrderCountText.anchorX = 0
		myOrderCountText.x = myOrderText.x+myOrderText.contentWidth+ceil(60*wRate)
		myOrderCountText.y = myOrderText.y
	-- 我的訂單跟願望清單中間的分隔線
			local grayLine = display.newLine( cx, personalCenterPic.y+personalCenterPic.contentHeight*0.5+ceil(35*hRate),
				cx, personalCenterPic.y+personalCenterPic.contentHeight*0.5+myOrderBtn.contentHeight-ceil(35*hRate))
			sceneGroup:insert(grayLine)
			grayLine.strokeWidth = 1
			grayLine:setStrokeColor(unpack(separateLineColor))
	-- 願望清單按鈕
		local hopeListBtn = widget.newButton({
			id = "hopeListBtn",
			shape = "Rect",
			width = (screenW+ox+ox)*0.5, 
			height = ceil(btnRowShadow.contentHeight*0.9),
			fillColor = { default = { 1, 1, 1, 1 }, over = { 1, 1, 1, 1 } },
			onRelease = onBtnListener,
		}) 
		sceneGroup:insert(hopeListBtn)
		hopeListBtn.x = grayLine.x + hopeListBtn.contentWidth*0.5
		hopeListBtn.y = myOrderBtn.y
	-- 圖示 
		local hopeListPic = display.newImageRect("assets/heart-personalcenter.png",280,240) 
		sceneGroup:insert(hopeListPic)
		hopeListPic.anchorX = 0
		hopeListPic.anchorY = 0
		hopeListPic.width = hopeListPic.width*0.06
		hopeListPic.height = hopeListPic.height*0.06
		hopeListPic.x = grayLine.x+ceil(62*wRate)
		hopeListPic.y = myOrderPic.y
	-- 顯示文字-"願望清單"
		local hopeListText = display.newText({
			text = "願望清單",
			font = getFont.font,
			fontSize = 10,
		})
		sceneGroup:insert(hopeListText)
		hopeListText:setFillColor(unpack(wordColor))
		hopeListText.anchorX = 0
		hopeListText.x = hopeListPic.x+hopeListPic.contentWidth+ceil(23*wRate)
		hopeListText.y = myOrderText.y
	-- 顯示文字-願望清單數量
		local hopeListCountText = display.newText({
			text = "0",
			font = getFont.font,
			fontSize = 18,
		})
		sceneGroup:insert(hopeListCountText)
		hopeListCountText:setFillColor(unpack(wordColor))
		hopeListCountText.anchorX = 0
		hopeListCountText.x = hopeListText.x+hopeListText.contentWidth+ceil(60*wRate)
		hopeListCountText.y = hopeListText.y
	------------------ 四排按鈕元件 -------------------
	-- 帳戶設定按鈕元件 --	
	-- 按鈕
		local accSettingBtn = widget.newButton({
			id = "accSettingBtn",
			width = (screenW+ox+ox), 
			height = 120*hRate,
			shape = "Rect",
			fillColor = { default = { 1, 1, 1, 1 }, over = { 204/255, 204/255, 204/255, 0.2 } },
			onRelease = onBtnListener,
		}) 
		sceneGroup:insert(accSettingBtn)
		accSettingBtn.x = cx
		accSettingBtn.y = btnRowShadow.y+btnRowShadow.contentHeight*0.5+floor(25*hRate)+accSettingBtn.contentHeight*0.5
	-- 上陰影
		local shadowUp = display.newImage(sceneGroup,"assets/s-up.png",accSettingBtn.x,accSettingBtn.y-accSettingBtn.contentHeight*0.5)
		shadowUp.anchorY = 1
		shadowUp.width = screenW+ox+ox
		shadowUp.height = shadowUp.contentHeight*0.5
	-- 圖示 
		local accSettingPic = display.newImageRect("assets/cog-g.png",240,240) 
		sceneGroup:insert(accSettingPic)
		accSettingPic.width = accSettingPic.width*0.06
		accSettingPic.height = accSettingPic.height*0.06
		accSettingPic.anchorX = 0
		accSettingPic.x = -ox+ceil(60*wRate)
		accSettingPic.y = accSettingBtn.y
	-- 顯示文字-"帳戶設定"
		local accSettingText = display.newText({
			text = "帳戶設定",
			font = getFont.font,
			fontSize = 12,
		})
		sceneGroup:insert(accSettingText)
		accSettingText:setFillColor(unpack(wordColor))
		accSettingText.anchorX = 0
		accSettingText.x = accSettingPic.x+accSettingPic.contentWidth+ceil(22*wRate)
		accSettingText.y = accSettingBtn.y
	-- 底線
		local accSettingUnderLine = display.newLine(-ox, accSettingBtn.y+accSettingBtn.contentHeight*0.5,
			screenW+ox, accSettingBtn.y+accSettingBtn.contentHeight*0.5)
		sceneGroup:insert(accSettingUnderLine)
		accSettingUnderLine:setStrokeColor(unpack(separateLineColor))
		accSettingUnderLine.strokeWidth = 1
		local accSettingUnderLineNum = sceneGroup.numChildren
	-- 諮詢中心按鈕元件 --	
	-- 按鈕
		local advisoryCenterBtn = widget.newButton({
			id = "advisoryCenterBtn",
			width = screenW+ox+ox, 
			height = 120*hRate,
			shape = "Rect",
			fillColor = { default = { 1, 1, 1, 1 }, over = { 204/255, 204/255, 204/255, 0.2 } },
			onRelease = onBtnListener,
		}) 
		sceneGroup:insert( accSettingUnderLineNum, advisoryCenterBtn)
		advisoryCenterBtn.x = cx
		advisoryCenterBtn.y = accSettingUnderLine.y+advisoryCenterBtn.contentHeight*0.5
	-- 按鈕上的圖示 
		local advisoryCenterPic = display.newImageRect("assets/qa-g.png",220,278) 
		sceneGroup:insert(advisoryCenterPic)
		advisoryCenterPic.width = advisoryCenterPic.width*0.06
		advisoryCenterPic.height = advisoryCenterPic.height*0.06
		advisoryCenterPic.anchorX = 0
		advisoryCenterPic.x = accSettingPic.x
		advisoryCenterPic.y = advisoryCenterBtn.y
	-- 顯示文字-"諮詢中心"	
		local advisoryCenterText = display.newText(	{
			text = "諮詢中心",
			font = getFont.font,
			fontSize = 12,
		})
		sceneGroup:insert(advisoryCenterText)
		advisoryCenterText:setFillColor(unpack(wordColor))
		advisoryCenterText.anchorX = 0
		advisoryCenterText.x = accSettingText.x
		advisoryCenterText.y = advisoryCenterBtn.y
	-- 底線
		local advisoryCenterUnderLine = display.newLine( -ox, advisoryCenterBtn.y+advisoryCenterBtn.contentHeight*0.5,
			screenW+ox, advisoryCenterBtn.y+advisoryCenterBtn.contentHeight*0.5)
		sceneGroup:insert(advisoryCenterUnderLine)
		advisoryCenterUnderLine:setStrokeColor(unpack(separateLineColor))
		advisoryCenterUnderLine.strokeWidth = 1
		local advisoryCenterUnderLineNum = sceneGroup.numChildren
	-- 更換語言/貨幣按鈕元件 --
	-- 按鈕
		local chgLanguageBtn = widget.newButton({
			id = "chgLanguageBtn",
			width = screenW+ox+ox, 
			height = 120*hRate,
			shape = "Rect",
			fillColor = { default = { 1, 1, 1, 1 }, over = {204/255, 204/255, 204/255, 0.2 } },
			onRelease = onBtnListener,
		}) 
		sceneGroup:insert( advisoryCenterUnderLineNum, chgLanguageBtn)
		chgLanguageBtn.x = cx
		chgLanguageBtn.y = advisoryCenterUnderLine.y+chgLanguageBtn.contentHeight*0.5
	-- 圖示	
		local chgLanguagePic = display.newImageRect("assets/refresh-g.png",240,240) 
		sceneGroup:insert(chgLanguagePic)
		chgLanguagePic.width = ceil(chgLanguagePic.width*0.06)
		chgLanguagePic.height = ceil(chgLanguagePic.height*0.06)
		chgLanguagePic.anchorX = 0
		chgLanguagePic.x = accSettingPic.x
		chgLanguagePic.y = chgLanguageBtn.y
	-- 顯示文字-"更改語言/貨幣"
		local chgLanguageText = display.newText({
			text = "更改語言/貨幣",
			font = getFont.font,
			fontSize = 12,
		})
		sceneGroup:insert(chgLanguageText)
		chgLanguageText:setFillColor(unpack(wordColor))
		chgLanguageText.anchorX = 0
		chgLanguageText.x = accSettingText.x
		chgLanguageText.y = chgLanguageBtn.y
	-- 底線
		local chgLanguageUnderLine = display.newLine( -ox, chgLanguageBtn.y+chgLanguageBtn.contentHeight*0.5,
			screenW+ox, chgLanguageBtn.y+chgLanguageBtn.contentHeight*0.5)
		sceneGroup:insert(chgLanguageUnderLine)
		chgLanguageUnderLine:setStrokeColor(unpack(separateLineColor))
		chgLanguageUnderLine.strokeWidth = 1
		local chgLanguageUnderLineNum = sceneGroup.numChildren
	-- 登出帳號按鈕元件 --
	-- 按鈕
		local logoutBtn = widget.newButton({
			id = "logoutBtn",
			width = screenW+ox+ox,
			height = screenH/16,
			shape = "Rect",
			fillColor = { default = { 1, 1, 1, 1 }, over = { 204/255, 204/255, 204/255, 0.2 } },
			onRelease = onBtnListener,
		}) 
		sceneGroup:insert( chgLanguageUnderLineNum, logoutBtn)
		logoutBtn.x = cx
		logoutBtn.y = chgLanguageUnderLine.y+logoutBtn.contentHeight*0.5
	-- 下陰影
		local shadowDown = display.newImage(sceneGroup,"assets/s-down.png",logoutBtn.x,logoutBtn.y+logoutBtn.contentHeight*0.5)
		shadowDown.anchorY = 0
		shadowDown.width = screenW+ox+ox
		shadowDown.height = shadowDown.contentHeight*0.5
	-- 圖示
		local logoutPic = display.newImageRect("assets/sign-out-g.png",245,200) 
		sceneGroup:insert(logoutPic)
		logoutPic.width = ceil(logoutPic.width*0.06)
		logoutPic.height = ceil(logoutPic.height*0.06)
		logoutPic.anchorX = 0
		logoutPic.x = accSettingPic.x
		logoutPic.y = logoutBtn.y
	-- 顯示文字-"登出帳號"
		local logoutText = display.newText({
			text = "登出帳號",
			font = getFont.font,
			fontSize = 12,
		})
		sceneGroup:insert(logoutText)
		logoutText:setFillColor(unpack(wordColor))
		logoutText.anchorX = 0
		logoutText.x = accSettingText.x
		logoutText.y = logoutBtn.y
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
		composer.removeScene("personalcenter")
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