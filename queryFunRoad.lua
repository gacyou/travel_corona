-----------------------------------------------------------------------------------------
--
-- queryFunRoad.lua
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

local sendViewGroup
local orderNumTextField, problemTextBox
local orderNumBackroundText, problemTextFrame, problemBackroundText

local ceil = math.ceil
local floor = math.floor

-- TextField 監聽事件
local function textListener ( event )
	local phase = event.phase
	if ( phase == "editing" and event.text ~= "" ) then
		clearTextBtn.isVisible = true
	else
		clearTextBtn.isVisible = false
	end
	
	if ( phase == "ended" or phase == "submitted") then 
		event.target.text = ""
		clearTextBtn.isVisible = false
	end
end

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
			composer.gotoScene("advisorCenter", options)
		end

		if (targetId == "sendBtn") then
			orderNumTextField.isVisible = false
			orderNumBackroundText.isVisible = true
			problemTextBox.isVisible = false
			problemTextFrame.isVisible = true
			problemBackroundText.isVisible = true
			sendViewGroup.isVisible = true
		end

		if(targetId == "sendViewBtn") then
			sendViewGroup.isVisible = false
			local options = { 
				effect = "fade", 
				time = 200,
				params = {
					backScene = getBackScene
				}
			}
			composer.gotoScene("queryRecord", options)		
		end
	end
	------------------- 抬頭元件 -------------------
	-- 白底
		local titleBase = display.newRect(0, 0, screenW+ox+ox, ceil(178*hRate))
		sceneGroup:insert(titleBase)
		titleBase.x = cx
		titleBase.y = -oy+titleBase.contentHeight*0.5
	-- 陰影
		local titleBaseShadow = display.newImage("assets/s-down.png", cx, titleBase.y+titleBase.contentHeight*0.5)
		sceneGroup:insert(titleBaseShadow)
		titleBaseShadow.anchorY = 0
		titleBaseShadow.width = screenW+ox+ox
		titleBaseShadow.height = titleBaseShadow.height*0.5
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
	-- 顯示文字-"諮詢奮路鳥"
		local titleText = display.newText({
			text = "諮詢奮路鳥",
			y = titleBase.y,
			font = getFont.font,
			fontSize = 14,
		})
		sceneGroup:insert(titleText)
		titleText:setFillColor(unpack(wordColor))
		titleText.anchorX = 0
		titleText.x = backArrow.x+backArrow.contentWidth+ceil(30*wRate)
	------------------- 選項元件 -------------------
	-- 問題分類元件 --
	-- 白底
		local questionBase = display.newRect( sceneGroup, cx, titleBaseShadow.y+floor(52*hRate), screenW+ox+ox, floor(180*hRate))
		sceneGroup:insert(questionBase)
		questionBase.anchorY = 0
	-- 顯示文字-"問題分類"
		local questionText1 = display.newText({
			parent = sceneGroup,
			text = "問題分類",
			font = getFont.font,
			fontSize = 10,
		})
		questionText1:setFillColor(unpack(wordColor))
		questionText1.anchorX = 0
		questionText1.anchorY = 0
		questionText1.x = -ox+ceil(30*wRate)
		questionText1.y = questionBase.y+floor(32*hRate)
	-- 顯示文字-"選擇問題分類"
		local questionText2 = display.newText({
			text = "選擇問題分類",
			font = getFont.font,
			fontSize = 12,
		})
		sceneGroup:insert(questionText2)
		questionText2:setFillColor(unpack(wordColor))
		questionText2.anchorX = 0
		questionText2.anchorY = 0
		questionText2.x = -ox+ceil(40*wRate)
		questionText2.y = questionText1.y+questionText1.contentHeight+floor(16*hRate)
	-- 底線
		local questionLine = display.newLine( -ox+ceil(30*wRate), questionBase.y+questionBase.contentHeight*0.9,
			screenW+ox-ceil(30*wRate), questionBase.y+questionBase.contentHeight*0.9 )
		sceneGroup:insert(questionLine)
		questionLine:setStrokeColor(unpack(separateLineColor))
	-- 箭頭
		local questionDropDownPic = display.newImage("assets/btn-dropdown.png", screenW+ox-ceil(30*wRate), questionText2.y+questionText2.contentHeight*0.5 )
		sceneGroup:insert(questionDropDownPic)
		questionDropDownPic.width = questionDropDownPic.width*0.05
		questionDropDownPic.height = questionDropDownPic.height*0.05
		questionDropDownPic.x = questionDropDownPic.x-questionDropDownPic.contentWidth*0.5
	-- 訂單編號元件 --
		local orderNumBase = display.newRect( sceneGroup, questionBase.x, questionBase.y+questionBase.contentHeight, screenW+ox+ox, ceil(180*hRate))
		orderNumBase.anchorY = 0
 	-- 顯示文字-"訂單編號"
		local orderNumText1 = display.newText({
			text = "訂單編號",
			font = getFont.font,
			fontSize = 10,
		})
		sceneGroup:insert(orderNumText1)
		orderNumText1:setFillColor(unpack(wordColor))
		orderNumText1.anchorX = 0
		orderNumText1.anchorY = 0
		orderNumText1.x = questionText1.x
		orderNumText1.y = orderNumBase.y+floor(32*hRate)
 	-- 訂單編號輸入欄位
		orderNumTextField = native.newTextField( questionText2.x, orderNumText1.y+orderNumText1.contentHeight+floor(12*hRate), orderNumBase.contentWidth*0.7, orderNumBase.contentHeight*0.35 )
		sceneGroup:insert(orderNumTextField)
		orderNumTextField.anchorX = 0
		orderNumTextField.anchorY = 0
		orderNumTextField.font = getFont.font
		orderNumTextField.size = 12
		orderNumTextField.placeholder = "請輸入您的訂單編號(選填)"
		orderNumTextField.hasBackground = false
		orderNumTextField:setSelection(1,1)
		--orderNumTextField:resizeFontToFitHeight()
 	-- 隱藏的字體，在隱藏orderNumTextField後顯示
		orderNumBackroundText = display.newText({
			parent = sceneGroup,
			text = "請輸入您的訂單編號(選填)",
			font = getFont.font,
			fontSize = 12,
		})
		orderNumBackroundText:setFillColor( unpack(wordColor))
		orderNumBackroundText.anchorX = 0
		orderNumBackroundText.anchorY = 0
		orderNumBackroundText.x = orderNumTextField.x+1
		orderNumBackroundText.y = orderNumTextField.y+1
		orderNumBackroundText.isVisible = false
	-- 按鈕-我的訂單
		local myOrderBtn = widget.newButton({
			id = "myOrderBtn",
			label = "我的訂單",
			labelColor = { default = mainColor1, over = mainColor2 },
			font = getFont.font,
			fontSize = 12,
			defaultFile = "assets/btn-ghost4.png",
			width = 216*wRate,
			height = 67*hRate,
		})
		sceneGroup:insert(myOrderBtn)
		myOrderBtn.anchorX = 1
		myOrderBtn.x = screenW+ox-ceil(30*wRate)
		myOrderBtn.y = orderNumTextField.y+orderNumTextField.contentHeight*0.5
	-- 底線
		local orderNumLine = display.newLine( -ox+ceil(30*wRate), orderNumBase.y+orderNumBase.contentHeight*0.9,
			myOrderBtn.x-myOrderBtn.contentWidth-ceil(20*wRate), orderNumBase.y+orderNumBase.contentHeight*0.9 )
		sceneGroup:insert(orderNumLine)
		orderNumLine:setStrokeColor(unpack(separateLineColor))
	-- 問題描述元件 --
	-- 白底
		local problemBase = display.newRect( sceneGroup, cx, orderNumBase.y+orderNumBase.contentHeight, screenW+ox+ox, floor(600*hRate))
		problemBase.anchorY = 0
	-- 顯示文字-"問題描述"
		local problemText1 = display.newText({
			parent = sceneGroup,
			text = "問題描述",
			font = getFont.font,
			fontSize = 10,
		})
		problemText1:setFillColor(unpack(wordColor))
		problemText1.anchorX = 0
		problemText1.anchorY = 0
		problemText1.x = orderNumText1.x
		problemText1.y = problemBase.y+floor(32*hRate)
 	-- 問題描述輸入欄位
		problemTextBox = native.newTextBox( orderNumTextField.x, problemText1.y+problemText1.contentHeight+floor(24*hRate), problemBase.contentWidth*0.93, problemBase.contentHeight*0.6 )
		sceneGroup:insert(problemTextBox)
		problemTextBox.anchorX = 0
		problemTextBox.anchorY = 0
		problemTextBox.isEditable = true
		problemTextBox.hasBackground = false
		problemTextBox.font = getFont.font
		problemTextBox.size = 12
		problemTextBox.placeholder = "請輸入問題描述(1000字以內)"
		problemTextBox:setSelection(1,1)
 	-- 隱藏的字體，在隱藏problemTextBox後顯示
		local vertices = { problemTextBox.x, problemTextBox.y, problemTextBox.x+problemTextBox.contentWidth, problemTextBox.y, problemTextBox.x+problemTextBox.contentWidth, problemTextBox.y+problemTextBox.contentHeight, problemTextBox.x, problemTextBox.y+problemTextBox.contentHeight }
		problemTextFrame = display.newPolygon( cx, problemTextBox.y, vertices)
		sceneGroup:insert(problemTextFrame)
		problemTextFrame.anchorY = 0
		problemTextFrame.strokeWidth = 2
		problemTextFrame:setStrokeColor(unpack(separateLineColor))
		--problemTextFrame.isVisible = false
		problemBackroundText = display.newText({
			text = "請輸入問題描述(1000字以內)",
			font = getFont.font,
			fontSize = 12,
		})
		sceneGroup:insert(problemBackroundText)
		problemBackroundText:setFillColor(unpack(wordColor))
		problemBackroundText.anchorX = 0
		problemBackroundText.anchorY = 0
		problemBackroundText.x = problemTextBox.x+1
		problemBackroundText.y = problemTextBox.y+1
		problemBackroundText.isVisible = false
	-- 送出按鍵
		local sendBtn = widget.newButton({
			id = "sendBtn",
			label = "送出",
			labelColor = { default = { 1, 1, 1, 1 }, over = { 1, 1, 1, 0.6 } },
			font = getFont.font,
			fontSize = 12,
			defaultFile = "assets/btn-send.png",
			width = 216*wRate,
			height = 67*hRate,
			onPress = onBtnListener,
		})
		sceneGroup:insert(sendBtn)
		sendBtn.anchorX = 1
		sendBtn.anchorY = 0
		sendBtn.x = problemTextBox.x+problemTextBox.contentWidth
		sendBtn.y = problemTextBox.y+problemTextBox.contentHeight+floor(32*hRate)
	-- 觸發事件所顯示的圖形
	-- 對透明的黑框進行只回傳true的觸碰事件的監聽
		sendViewGroup = display.newGroup()
		local sendViewOverlay = display.newRect(sendViewGroup, cx, cy, screenW+ox+ox, screenH+oy+oy)
		sendViewOverlay:setFillColor( 0, 0, 0, 0.3)
		--sendViewOverlay.touch = function ( self , event )
		--	return true
		--end
		--sendViewOverlay:addEventListener("touch", sendViewOverlay)
		sendViewOverlay:addEventListener("touch", function() return true; end)
		local sendViewBkg = display.newRect( sendViewGroup, cx, cy, (screenW+ox+ox)*0.6, (screenH+oy+oy)*0.2)
		local sendViewText = display.newText({
			text = "表單已成功送出 !",
			font = getFont.font,
			fontSize = 14,
		})
		sendViewGroup:insert(sendViewText)
		sendViewText:setFillColor(unpack(wordColor))
		sendViewText.x = cx
		sendViewText.y = sendViewBkg.y-ceil(sendViewBkg.contentHeight*0.1)
		local sendViewLine = display.newLine( sendViewBkg.x-ceil(sendViewBkg.contentWidth/2), sendViewBkg.y+ceil(sendViewBkg.contentHeight*0.25), 
				sendViewBkg.x+ceil(sendViewBkg.contentWidth/2), sendViewBkg.y+ceil(sendViewBkg.contentHeight*0.25) )
		sendViewGroup:insert(sendViewLine)
		sendViewLine:setStrokeColor(unpack(separateLineColor))
	-- 前往諮詢紀錄按鍵
		local text = display.newText({
				text = "前往諮詢紀錄",
				font = getFont.font,
				fontSize = 14,
			})
		text.isVisible = false
		local sendViewBtn = widget.newButton({
			id = "sendViewBtn",
			label = "前往諮詢紀錄",
			labelColor = { default = mainColor1, over = mainColor2 },
			font = getFont.font,
			fontSize = 14,
			defaultFile = "assets/transparent.png",
			width = text.width,
			height = text.height,
			onPress = onBtnListener,
		})
		sendViewGroup:insert(sendViewBtn)
		sendViewBtn.x = cx
		sendViewBtn.y = sendViewLine.y+ceil(sendViewBkg.contentHeight*0.25*0.5)
		sendViewGroup.isVisible = false
end

-- show()
function scene:show( event )
	local sceneGroup = self.view
	local phase = event.phase
	if ( phase == "will" ) then
		--orderNumTextField.isVisible = true
		--problemTextBox.isVisible = true
	elseif ( phase == "did" ) then
	end
end

-- hide()
function scene:hide( event )
	local sceneGroup = self.view
	local phase = event.phase
	if ( phase == "will" ) then 
	elseif ( phase == "did" ) then
		composer.removeScene("queryFunRoad")
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