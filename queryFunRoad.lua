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
-- function Zone Start
local function ceil( value )
	return math.ceil(value)
end

-- 觸碰監聽事件
local function onTouchListener( event )
	--print(event.y)
end

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
-- function Zone End
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
	-- 諮詢奮路鳥元件
	local background = display.newRect(cx,cy+oy,screenW+ox+ox,screenH+oy+oy)
	sceneGroup:insert(background)
	background:setFillColor(unpack(backgroundColor))
	local titleBackground = display.newRect(0, 0, screenW+ox+ox, ceil(178*hRate))
	sceneGroup:insert(titleBackground)
	titleBackground.x = cx
	titleBackground.y = -oy+ceil((titleBackground.height)/2)
	local titleBackgroundShadow = display.newImageRect("assets/shadow.png", 1068, 476)
	sceneGroup:insert(titleBackgroundShadow)
	titleBackgroundShadow.width = ceil(titleBackgroundShadow.width*0.33)+ox+ox
	titleBackgroundShadow.height = ceil(titleBackground.height*1.05)
	titleBackgroundShadow.x = titleBackground.x
	titleBackgroundShadow.y = titleBackground.y

	backBtn = widget.newButton({
		id = "backBtn",
		x = -ox+ceil(49*wRate),
		y = titleBackground.y,
		width = 162,
		height = 252,
		defaultFile = "assets/btn-back-b.png",
		overFile = "assets/btn-back-b.png",
		onPress = onBtnListener,
	})
	sceneGroup:insert(backBtn)
	backBtn.width = ceil(backBtn.width*0.07)
	backBtn.height = ceil(backBtn.height*0.07)
	backBtn.anchorX = 0

	local titleText = display.newText({
		text = "諮詢奮路鳥",
		y = titleBackground.y,
		font = getFont.font,
		fontSize = 16,
	})
	sceneGroup:insert(titleText)
	titleText:setFillColor(unpack(wordColor))
	titleText.anchorX = 0
	titleText.x = backBtn.x+backBtn.contentWidth+ceil(30*wRate)
---------------------------------------------------------------------------------------------------
 	-- 問題分類元件
 	local questionBase = display.newRect( 0,0, screenW+ox+ox, ceil(180*hRate))
 	sceneGroup:insert(questionBase)
 	--questionBase:setFillColor(0,1,0,0.3)
 	questionBase.x = cx
 	questionBase.y = ceil(titleBackground.y+titleBackground.contentHeight/2+(50*hRate)+questionBase.contentHeight/2)

 	local questionText1 = display.newText({
 			text = "問題分類",
 			font = getFont.font,
			fontSize = 10,
 		})
 	sceneGroup:insert(questionText1)
 	questionText1:setFillColor(unpack(wordColor))
 	questionText1.anchorX = 0
 	questionText1.x = -ox+ceil(33*wRate)
 	questionText1.y = ceil(titleBackground.y+titleBackground.contentHeight/2+(50*hRate)+(30*hRate)+questionText1.contentHeight/2)

 	local questionText2 = display.newText({
 			text = "選擇問題分類",
 			font = getFont.font,
			fontSize = 12,
 		})
 	sceneGroup:insert(questionText2)
 	questionText2:setFillColor(unpack(wordColor))
 	questionText2.anchorX = 0
 	questionText2.x = -ox+ceil(35*wRate)
 	questionText2.y = ceil(questionText1.y+questionText1.contentHeight/2+(36*hRate)+questionText2.contentHeight/2)

 	local questionLine = display.newLine( -ox+ceil(questionBase.contentWidth*0.02), questionBase.y+ceil(questionBase.contentHeight*0.4),
 		-ox+ceil(questionBase.contentWidth*0.97), questionBase.y+ceil(questionBase.contentHeight*0.4) )
 	sceneGroup:insert(questionLine)
 	questionLine:setStrokeColor(unpack(separateLineColor))

 	local questionDropDownPic = display.newImageRect("assets/btn-dropdown.png", 256, 168)
 	sceneGroup:insert(questionDropDownPic)
 	questionDropDownPic.width = ceil(questionDropDownPic.width*0.05)
 	questionDropDownPic.height = ceil(questionDropDownPic.height*0.05)
 	questionDropDownPic.x = -ox+ceil(questionBase.contentWidth*0.95)
 	questionDropDownPic.y = questionText2.y
---------------------------------------------------------------------------------------------------
	-- 訂單編號欄位
	local orderNumBase = display.newRect( 0,0, screenW+ox+ox, ceil(180*hRate))
 	sceneGroup:insert(orderNumBase)
 	--orderNumBase:setFillColor(1,0,0,0.3)
 	orderNumBase.x = cx
 	orderNumBase.y = ceil(questionBase.y+questionBase.contentHeight/2+orderNumBase.contentHeight/2)
 	-- 訂單編號
 	local orderNumText1 = display.newText({
 			text = "訂單編號",
 			font = getFont.font,
			fontSize = 10,
 		})
 	sceneGroup:insert(orderNumText1)
 	orderNumText1:setFillColor(unpack(wordColor))
 	orderNumText1.anchorX = 0
 	orderNumText1.x = -ox+ceil(33*wRate)
 	orderNumText1.y = ceil(questionBase.y+questionBase.contentHeight/2+(30*hRate)+orderNumText1.contentHeight/2)
 	
 	-- 訂單編號輸入欄位
 	orderNumTextField = native.newTextField( 0, 0, ceil(orderNumBase.contentWidth*0.7), questionText2.height)
 	sceneGroup:insert(orderNumTextField)
 	orderNumTextField.anchorX = 0 
 	orderNumTextField.x = -ox+ceil(35*wRate)
 	orderNumTextField.y = ceil(orderNumText1.y+orderNumText1.contentHeight/2+(36*hRate)+orderNumTextField.contentHeight/2)
 	orderNumTextField.font = getFont.font
 	orderNumTextField.size = 12
 	orderNumTextField.placeholder = "請輸入您的訂單編號(選填)"
 	orderNumTextField.hasBackground = false
 	orderNumTextField:setSelection(1,1)
 	orderNumTextField:resizeHeightToFitFont()
 	-- 隱藏的字體，在隱藏orderNumTextField後顯示
 	orderNumBackroundText = display.newText({
 			text = "請輸入您的訂單編號(選填)",
 			font = getFont.font,
			fontSize = 12,
 		})
 	sceneGroup:insert(orderNumBackroundText)
 	orderNumBackroundText:setFillColor( unpack(wordColor))
 	orderNumBackroundText.anchorX = 0
 	orderNumBackroundText.x = -ox+ceil(44*wRate)
 	orderNumBackroundText.y = ceil(orderNumText1.y+orderNumText1.contentHeight/2+(36*hRate)+orderNumBackroundText.contentHeight/2)
 	orderNumBackroundText.isVisible = false

 	local orderNumLine = display.newLine( -ox+ceil(orderNumBase.contentWidth*0.02), orderNumBase.y+ceil(orderNumBase.contentHeight*0.4),
 		-ox+ceil(orderNumBase.contentWidth*0.75), orderNumBase.y+ceil(orderNumBase.contentHeight*0.4) )
 	sceneGroup:insert(orderNumLine)
 	orderNumLine:setStrokeColor(unpack(separateLineColor))

 	local myOrderBtn = widget.newButton({
 			id = "myOrderBtn",
 			label = "我的訂單",
 			labelColor = { default = mainColor1, over = mainColor2 },
 			font = getFont.font,
			fontSize = 36,
 			defaultFile = "assets/btn-ghost4.png",
 			width = 216,
 			height = 67,
 		})
 	sceneGroup:insert(myOrderBtn)
 	myOrderBtn.width = ceil(myOrderBtn.width*wRate)
 	myOrderBtn.height = ceil(myOrderBtn.height*0.3)
 	myOrderBtn.anchorX = 1
 	myOrderBtn.x = -ox+orderNumBase.contentWidth-ceil(35*wRate)
 	myOrderBtn.y = orderNumTextField.y
---------------------------------------------------------------------------------------------------
	-- 問題描述元件
 	local problemBase = display.newRect( 0,0, screenW+ox+ox, ceil(720*hRate))
 	sceneGroup:insert(problemBase)
 	--problemBase:setFillColor(0,0,1,0.3)
 	problemBase.x = cx
 	problemBase.y = math.floor(orderNumBase.y+orderNumBase.contentHeight/2+problemBase.contentHeight/2)

 	local problemText1 = display.newText({
 			text = "問題描述",
 			font = getFont.font,
			fontSize = 10,
 		})
 	sceneGroup:insert(problemText1)
 	problemText1:setFillColor(unpack(wordColor))
 	problemText1.anchorX = 0
 	problemText1.x = -ox+ceil(33*wRate)
 	problemText1.y = ceil(orderNumBase.y+orderNumBase.contentHeight/2+(30*hRate)+problemText1.contentHeight/2)

 	-- 問題描述輸入欄位
	problemTextBox = native.newTextBox( 0, 0, ceil(problemBase.contentWidth*0.93), ceil(problemBase.contentHeight*0.6))
	sceneGroup:insert(problemTextBox)
	problemTextBox.anchorX = 0
	problemTextBox.x = -ox+ceil(35*wRate)
	problemTextBox.y = ceil(problemText1.y+problemText1.contentHeight/2+(36*hRate)+problemTextBox.contentHeight/2)
	problemTextBox.isEditable = true
	problemTextBox.font = getFont.font
	problemTextBox.size = 12
	problemTextBox.placeholder = "請輸入問題描述(1000字以內)"
	problemTextBox:setSelection(1,1)
 	
 	-- 隱藏的字體，在隱藏problemTextBox後顯示
 	local vertices = { -ox+11, 110, 309+ox, 110, 309+ox, 224, -ox+11, 224 }
 	problemTextFrame = display.newPolygon( cx, ceil(problemText1.y+problemText1.contentHeight/2+(36*hRate)+problemTextBox.contentHeight/2),vertices)
 	sceneGroup:insert(problemTextFrame)
 	problemTextFrame.strokeWidth = 1
 	problemTextFrame:setStrokeColor(unpack(separateLineColor))
 	problemTextFrame.isVisible = false
 	problemBackroundText = display.newText({
 			text = "請輸入問題描述(1000字以內)",
 			font = getFont.font,
			fontSize = 12,
 		})
 	sceneGroup:insert(problemBackroundText)
 	problemBackroundText:setFillColor(unpack(wordColor))
 	problemBackroundText.anchorX = 0
 	problemBackroundText.x = -ox+ceil(44*wRate)
 	problemBackroundText.y = ceil(problemText1.y+problemText1.contentHeight/2+(36*hRate)+problemBackroundText.contentHeight/2)
 	problemBackroundText.isVisible = false
	-- 送出按鍵
	local sendBtn = widget.newButton({
 			id = "sendBtn",
 			label = "送出",
 			labelColor = { default = {1,1,1,1}, over = {1,1,1,0.6} },
 			font = getFont.font,
			fontSize = 36,
 			defaultFile = "assets/btn-send.png",
 			width = 216,
 			height = 67,
 			onPress = onBtnListener,
 		})
 	sceneGroup:insert(sendBtn)
 	sendBtn.width = ceil(sendBtn.width*wRate)
 	sendBtn.height = ceil(sendBtn.height*0.3)
 	sendBtn.anchorX = 1
 	sendBtn.x = -ox+problemBase.contentWidth-ceil(35*wRate)
 	sendBtn.y = ceil(myOrderBtn.y+problemBase.contentHeight*0.95)

 	-- 陰影
	local optionShadow = display.newImageRect("assets/shadow.png",1068,476)
	sceneGroup:insert(optionShadow)
	optionShadow.width = ceil(problemBase.contentWidth*1.1)
	optionShadow.height = ceil((questionBase.contentHeight+orderNumBase.contentHeight+problemBase.contentHeight)*1.05)
	optionShadow.x = cx
	optionShadow.y = ceil(titleBackground.y+titleBackground.contentHeight/2+(50*hRate)+(questionBase.contentHeight+orderNumBase.contentHeight+problemBase.contentHeight)/2)
---------------------------------------------------------------------------------------------------
	-- 觸發事件所顯示的圖形
	sendViewGroup = display.newGroup()
	-- 對透明的黑框進行只回傳true的觸碰事件的監聽
	local sendViewOverlay = display.newRect(sendViewGroup, cx, cy, screenW+ox+ox, screenH+oy+oy)
	sendViewOverlay:setFillColor( 0, 0, 0, 0.3)
--[[sendViewOverlay.touch = function ( self , event )
		return true
	end
	sendViewOverlay:addEventListener("touch",sendViewOverlay)
]]	
	sendViewOverlay:addEventListener("touch", function() return true; end)
	local sendViewBkg = display.newRect(sendViewGroup, cx, -oy+ceil((screenH+oy+oy-mainTabBarHeight)*0.5), ceil((screenW+ox+ox)*0.5), ceil((screenH+oy+oy)*0.25))
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
 	--print(sendViewBtn.contentWidth,sendViewBtn.contentHeight)
	--sceneGroup:insert(sendViewGroup)
	sendViewGroup.isVisible = false
end

-- show()
function scene:show( event )
	local sceneGroup = self.view
	local phase = event.phase
	if ( phase == "will" ) then
		orderNumTextField.isVisible = true
		problemTextBox.isVisible = true
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