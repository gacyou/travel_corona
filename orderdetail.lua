-----------------------------------------------------------------------------------------
--
-- orderdetail.lua
-- 
-----------------------------------------------------------------------------------------

local composer = require( "composer" )
local widget = require("widget")
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

local vBlankPad = math.ceil(25*hRate)
local usedPoint = 10000
local categoryGroup

-- function Zone Start
local function ceil( value )
	return math.ceil(value)
end

-- 按鈕的監聽事件
local function onBtnListener( event )
	local targetId = event.target.id
	if( targetId == "backBtn") then 
		composer.gotoScene(prevScene,{effect="slideLeft",time=300})
	end
	if( targetId == "categoryAppointmentInfoBtn") then 
		composer.showOverlay("appointmentInfo",{ isModal = true, effect = "fromLeft", time = 300})
	end
end

-- function Zone End
function scene:create( event )
	local sceneGroup = self.view
	-- Called when the scene's view does not exist.
	local background = display.newRect(cx,cy+oy,screenW+ox+ox,screenH+oy+oy)
	sceneGroup:insert(background)
	background:setFillColor(unpack(backgroundColor))
	local titleBackground = display.newRect(0, 0, screenW+ox+ox, ceil(178*hRate))
	sceneGroup:insert(titleBackground)
	titleBackground:setFillColor(1)
	titleBackground.x = cx
	titleBackground.y = -oy+(titleBackground.height)/2
	
	local titleText = display.newText({
		text = "訂單明細",
		y = -oy+ceil(cy*0.1),
		font = getFont.font,
		fontSize = 14,
	})
	sceneGroup:insert(titleText)
	titleText:setFillColor(unpack(wordColor))
	titleText.anchorX = 0
	titleText.x = -ox+ceil(cx*0.25)

	local backBtn = widget.newButton({
		id = "backBtn",
		x = -ox+ceil(cx*0.14),
		y = -oy+ceil(cy*0.1),
		width = 162,
		height = 252,
		defaultFile = "assets/btn-back-b.png",
		overFile = "assets/btn-back-b.png",
		onPress = onBtnListener,
	})
	sceneGroup:insert(backBtn)
	backBtn.width = ceil(backBtn.width*0.07)
	backBtn.height = ceil(backBtn.height*0.07)

	local btnBase = display.newRect( 0, 0, ox+screenW+ox, ceil(screenH*0.052))
	sceneGroup:insert(btnBase)
	btnBase:setFillColor(1)
	btnBase.x = cx 
	btnBase.y = titleBackground.y+titleBackground.contentHeight/2+vBlankPad+btnBase.contentHeight/2

	local copyOrderNumText = display.newText({
			text = "複製訂單編號",
			font = getFont.font,
			fontSize = 12,
		})
	copyOrderNumText.isVisible = false
	local copyOrderNumBtn = widget.newButton({
			id = "copyOrderNumBtn",
			label = "複製訂單編號",
			labelColor = { default = wordColor, over = mainColor1 },
			font = getFont.font,
			fontSize = 12,
			x = cx,
			y = btnBase.y,
			width = copyOrderNumText.contentWidth,
			height = ceil(screenH*0.052),
			shape = "rect",
			fillColor = { default = { 1, 1, 1, 0}, over = { 1, 1, 1, 0} },
		})
	sceneGroup:insert(copyOrderNumBtn)
	copyOrderNumBtn.anchorX = 0
	copyOrderNumBtn.x = -ox+ceil(40*wRate)

	local verticalLine1 = display.newLine((copyOrderNumBtn.x+(copyOrderNumText.contentWidth)+ceil(30*wRate)), (copyOrderNumBtn.y-(copyOrderNumBtn.height*0.25)),
		(copyOrderNumBtn.x+(copyOrderNumText.contentWidth)+ceil(30*wRate)), (copyOrderNumBtn.y+(copyOrderNumBtn.height*0.25)))
	sceneGroup:insert(verticalLine1)
	verticalLine1:setStrokeColor(unpack(separateLineColor))

	local contactSrvText = display.newText({
			text = "聯絡客服",
			font = getFont.font,
			fontSize = 12,
		})
	contactSrvText.isVisible = false
	local contactSrvBtn = widget.newButton({
			id = "contactSrvBtn",
			label = "聯絡客服",
			labelColor = { default = wordColor, over = mainColor1 },
			font = getFont.font,
			fontSize = 12,
			x = cx,
			y = btnBase.y,
			width = contactSrvText.contentWidth,
			height = ceil(screenH*0.052),
			shape = "rect",
			fillColor = { default = { 1, 1, 1, 0}, over = { 1, 1, 1, 0} },
		})
	sceneGroup:insert(contactSrvBtn)
	contactSrvBtn.anchorX = 0
	contactSrvBtn.x = verticalLine1.x+ceil(30*wRate)

	-- 積分的文字
	local pointText = display.newText({
			text = "積分",
			font = getFont.font,
			fontSize = 12,
		})
	sceneGroup:insert(pointText)
	pointText:setFillColor(unpack(wordColor))
	pointText.anchorX = 1
	pointText.x = screenW+ox-ceil(40*wRate)
	pointText.y = btnBase.y
	-- 使用的積分數字
	local usedPointText = display.newText({
			text = usedPoint,
			font = getFont.font,
			fontSize = 12,
		})
	sceneGroup:insert(usedPointText)
	usedPointText:setFillColor(unpack(subColor1))
	usedPointText.anchorX = 1
	usedPointText.x = pointText.x-pointText.contentWidth
	usedPointText.y = btnBase.y
	-- 此訂單使用的文字
	local orderUsedText = display.newText({
			text = "此訂單使用",
			font = getFont.font,
			fontSize = 12,
		})
	sceneGroup:insert(orderUsedText)
	orderUsedText:setFillColor(unpack(wordColor))
	orderUsedText.anchorX = 1
	orderUsedText.x = usedPointText.x-usedPointText.width
	orderUsedText.y = btnBase.y
	-- 灰色的禮物icon
	local giftPic = display.newImageRect("assets/gift-g.png", 240, 210)
	sceneGroup:insert(giftPic)
	giftPic.width = giftPic.width*0.05
	giftPic.height = giftPic.height*0.05
	giftPic.anchorX = 1
	giftPic.x = orderUsedText.x-orderUsedText.contentWidth-ceil(15*wRate)
	giftPic.y = btnBase.y

	-- 明細列表
	local categoryView = widget.newScrollView({
			id = "categoryView",
			top = -oy+titleBackground.contentHeight+vBlankPad+btnBase.contentHeight+vBlankPad,
			left = -ox,
			width = ox+screenW+ox,
			height = oy+screenH+oy-(titleBackground.contentHeight+vBlankPad+btnBase.contentHeight+vBlankPad+mainTabBarHeight),
			backgroundColor = backgroundColor,
			horizontalScrollDisabled = true,
			isBounceEnabled = false,
		})
	sceneGroup:insert(categoryView)

	local categoryBaseWhite
	local categoryBaseShadow
	local categoryPicBase
	local categoryTitle
	local categoryStatus
	local categoryPriceText
	local categoryDiscountText
	local categoryComboText
	local categoryAppointmentInfoBtn
	local pad
	for i=1,6 do

		if (i==1) then 
			pad = 0
		else
			pad = ceil(396*hRate)*(i-1)
		end
		categoryBaseWhite = display.newRect(0,0,ox+screenW+ox,ceil(374*hRate))
		categoryView:insert(categoryBaseWhite)
		categoryBaseWhite:setFillColor(1)
		categoryBaseWhite.x = categoryBaseWhite.width/2
		categoryBaseWhite.y = categoryBaseWhite.height/2+pad

		categoryBaseShadow = display.newImageRect("assets/shadow.png",1068,476)
		categoryView:insert(categoryBaseShadow)
		categoryBaseShadow.width = ceil((categoryBaseShadow.width)*0.3)+ox+ox
		categoryBaseShadow.height = ceil((categoryBaseShadow.height)*0.83*hRate)
		categoryBaseShadow.x = categoryBaseShadow.width/2
		categoryBaseShadow.y = categoryBaseShadow.height/2+pad

	 	categoryPicBase = display.newRoundedRect( 0, 0, ceil(435*wRate), ceil(304*hRate), 3)
		categoryView:insert(categoryPicBase)
		categoryPicBase:setFillColor(unpack(separateLineColor))
		categoryPicBase.x = ceil(40*wRate)+(categoryPicBase.width)/2
		categoryPicBase.y = ceil(35*hRate)+(categoryPicBase.height)/2+pad

		categoryTitle = display.newText({
				text = "柬埔寨5日遊",
				font = getFont.font,
				fontSize = 10,
			})
		categoryView:insert(categoryTitle)
		categoryTitle:setFillColor(unpack(wordColor))
		categoryTitle.anchorX = 0
		categoryTitle.x = ceil(40*wRate)+(categoryPicBase.width)+ceil(33*wRate)
		categoryTitle.y = ceil(35*hRate)+(categoryTitle.height)/2+pad

		categoryStatus = display.newText({
				text = "(未付款)",
				font = getFont.font,
				fontSize = 10,
			})
		categoryView:insert(categoryStatus)
		categoryStatus:setFillColor(unpack(subColor1))
		categoryStatus.anchorX = 0
		categoryStatus.x = categoryTitle.x+categoryTitle.width
		categoryStatus.y = ceil(35*hRate)+(categoryTitle.height)/2+pad

		categoryPriceText = display.newText({
				text = "付款金額：",
				font = getFont.font,
				fontSize = 10,
			})
		categoryView:insert(categoryPriceText)
		categoryPriceText:setFillColor(unpack(wordColor))
		categoryPriceText.anchorX = 0
		categoryPriceText.x = ceil(40*wRate)+(categoryPicBase.width)+ceil(33*wRate)
		categoryPriceText.y = categoryTitle.y+(categoryTitle.height)/2+ceil(15*hRate)+(categoryPriceText.height)/2
		
		categoryDiscountText = display.newText({
				text = "折扣折抵：",
				font = getFont.font,
				fontSize = 10,
			})
		categoryView:insert(categoryDiscountText)
		categoryDiscountText:setFillColor(unpack(wordColor))
		categoryDiscountText.anchorX = 0
		categoryDiscountText.x = ceil(40*wRate)+(categoryPicBase.width)+ceil(33*wRate)
		categoryDiscountText.y = categoryPriceText.y+(categoryPriceText.height)/2+ceil(15*hRate)+(categoryDiscountText.height)/2

		categoryComboText = display.newText({
				text = "組合優惠：NT$ -2000",
				font = getFont.font,
				fontSize = 10,
			})
		categoryView:insert(categoryComboText)
		categoryComboText:setFillColor(unpack(wordColor))
		categoryComboText.anchorX = 0
		categoryComboText.x = ceil(40*wRate)+(categoryPicBase.width)+ceil(33*wRate)
		categoryComboText.y = categoryDiscountText.y+(categoryDiscountText.height)/2+ceil(15*hRate)+(categoryComboText.height)/2

		categoryAppointmentInfoBtn = widget.newButton({
				id = "categoryAppointmentInfoBtn",
				label = "查看預定資料",
				labelColor = { default = subColor1, over = subColor2},
				font = getFont.font,
				fontSize = 10,
				width = 80,
				height = 20,
				defaultFile = "assets/btn-ghost3.png",
				onPress = onBtnListener,
			})
		categoryView:insert(categoryAppointmentInfoBtn)
		categoryAppointmentInfoBtn.anchorX = 1
		categoryAppointmentInfoBtn.x = categoryBaseWhite.contentWidth-ceil(40*wRate)
		categoryAppointmentInfoBtn.anchorY = 1
		categoryAppointmentInfoBtn.y = categoryBaseWhite.contentHeight-ceil(35*hRate)+pad
	end
	print(categoryBaseWhite.y)

	local buyerInfoBase = display.newRect(0,0,ox+screenW+ox,ceil(415*hRate))
	categoryView:insert(buyerInfoBase)
	buyerInfoBase.x = (buyerInfoBase.width)/2
	buyerInfoBase.y = categoryBaseWhite.y+(categoryBaseWhite.height)/2+ceil(25*hRate)+(buyerInfoBase.height)/2

	local buyerInfoBaseShadow = display.newImageRect("assets/shadow.png",1068,476)
	categoryView:insert(buyerInfoBaseShadow)
	buyerInfoBaseShadow.width = ceil((buyerInfoBaseShadow.width)*0.3)+ox+ox
	buyerInfoBaseShadow.height = ceil((buyerInfoBaseShadow.height)*0.83*hRate)
	buyerInfoBaseShadow.x = buyerInfoBaseShadow.width/2
	buyerInfoBaseShadow.y = categoryBaseWhite.y+(categoryBaseWhite.height)/2+ceil(25*hRate)+(buyerInfoBase.height)/2

	local buyerInfoTitleText = display.newText({
			text = "聯絡人資料",
			font = getFont.font,
			fontSize = 12,
		})
	categoryView:insert(buyerInfoTitleText)
	buyerInfoTitleText:setFillColor(unpack(mainColor1))
	buyerInfoTitleText.anchorX = 0
	buyerInfoTitleText.x = ceil(40*wRate)
	buyerInfoTitleText.y = categoryBaseWhite.y+(categoryBaseWhite.height)/2+ceil(68*hRate)+(buyerInfoTitleText.height)/2

	local buyerInfoNameText = display.newText({
			text = "訂購人姓名：",
			font = getFont.font,
			fontSize = 12,
		})
	categoryView:insert(buyerInfoNameText)
	buyerInfoNameText:setFillColor(unpack(wordColor))
	buyerInfoNameText.anchorX = 0
	buyerInfoNameText.x = ceil(40*wRate)
	buyerInfoNameText.y = buyerInfoTitleText.y+(buyerInfoTitleText.height)/2+ceil(20*hRate)+(buyerInfoNameText.height)/2

	local buyerInfoPayText = display.newText({
			text = "支付方式：",
			font = getFont.font,
			fontSize = 12,
		})
	categoryView:insert(buyerInfoPayText)
	buyerInfoPayText:setFillColor(unpack(wordColor))
	buyerInfoPayText.anchorX = 0
	buyerInfoPayText.x = ceil(40*wRate)
	buyerInfoPayText.y = buyerInfoNameText.y+(buyerInfoNameText.height)/2+ceil(20*hRate)+(buyerInfoPayText.height)/2

	local buyerInfoPhoneText = display.newText({
			text = "聯絡電話：",
			font = getFont.font,
			fontSize = 12,
		})
	categoryView:insert(buyerInfoPhoneText)
	buyerInfoPhoneText:setFillColor(unpack(wordColor))
	buyerInfoPhoneText.anchorX = 0
	buyerInfoPhoneText.x = ceil(40*wRate)
	buyerInfoPhoneText.y = buyerInfoPayText.y+(buyerInfoPayText.height)/2+ceil(20*hRate)+(buyerInfoPhoneText.height)/2

	local buyerInfoEmailText = display.newText({
			text = "電子信箱：",
			font = getFont.font,
			fontSize = 12,
		})
	categoryView:insert(buyerInfoEmailText)
	buyerInfoEmailText:setFillColor(unpack(wordColor))
	buyerInfoEmailText.anchorX = 0
	buyerInfoEmailText.x = ceil(40*wRate)
	buyerInfoEmailText.y = buyerInfoPhoneText.y+(buyerInfoPhoneText.height)/2+ceil(20*hRate)+(buyerInfoEmailText.height)/2
end

function scene:show( event )
	local sceneGroup = self.view
	local phase = event.phase
	if phase == "will" then
		-- Called when the scene is still off screen and is about to move on screen
	elseif phase == "did" then
		-- Called when the scene is now on screen
	end	
end

function scene:hide( event )
	local sceneGroup = self.view
	local phase = event.phase
	if event.phase == "will" then
		-- Called when the scene is on screen and is about to move off screen
		--
		-- INSERT code here to pause the scene
		-- e.g. stop timers, stop animation, unload sounds, etc.)
	elseif phase == "did" then
		-- Called when the scene is now off screen
	end
end

function scene:destroy( event )
	local sceneGroup = self.view
	-- Called prior to the removal of scene's "view" (sceneGroup)
	-- 
	-- INSERT code here to cleanup the scene
	-- e.g. remove display objects, remove touch listeners, save state, etc.
end

---------------------------------------------------------------------------------

-- Listener setup
scene:addEventListener( "create", scene )
scene:addEventListener( "show", scene )
scene:addEventListener( "hide", scene )
scene:addEventListener( "destroy", scene )

-----------------------------------------------------------------------------------------

return scene