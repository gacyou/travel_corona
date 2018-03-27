-----------------------------------------------------------------------------------------
--
-- orderInfomation.lua
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
local embellishColor = { 249/255, 220/255, 119/255}
local hintAlertColor = { 247/255, 86/255, 86/255}

local ox, oy = math.abs(display.screenOriginX), math.abs(display.screenOriginY)
local cx, cy = display.contentCenterX, display.contentCenterY
local screenW, screenH = display.contentWidth, display.contentHeight

local infoText = {"未付款","已付款","預定成功","部分商品預定失敗","取消預定","逾時未付"}
local infoTextColor = { subColor1, mainColor1, mainColor2, embellishColor, separateLineColor, hintAlertColor }
local infoContent = {
	"此筆訂單尚未完成付款，請盡速完\n成付款。",
	"此筆訂單已完成付款，商品資料確\n認中。",
	"此筆訂單已全部確認完畢，成功預\n訂商品。",
	"此筆訂單有預定失敗的商品，請確\n認定單明細。",
	"此筆訂單已被用戶主動取消。",
	"此筆訂單超過付款期限，請重新選\n購。"
}

local getModel = system.getInfo("model")
-- function Zone Start
local function ceil( value )
	return math.ceil(value)
end

-- 按鈕的監聽事件
local function onBtnListener( event )
	local targetId = event.target.id
	if( targetId == "confirmBtn") then
		print(targetId)
		composer.hideOverlay("zoomOutIn", 300)
	end
end
-- function Zone End
function scene:create( event )
	local sceneGroup = self.view
	-- Called when the scene's view does not exist.

	print(getModel)

	local infoBackground = display.newRect(cx,cy,ox+screenW+ox,oy+screenH+oy)
	sceneGroup:insert(infoBackground)
	infoBackground.fill = { type = "image", filename="assets/black.png"}
	
	-- 說明列的白底
	local infoBase = display.newRect( cx, -oy+cy, screenW*0.66, (screenH)*0.9)
	sceneGroup:insert(infoBase)
	infoBase:setFillColor(1)
	if (getModel == "iPad") then infoBase.y = cy-20 end
	
	-- 訂單狀態說明文字
	local infoTitleText = display.newText({
			text = "訂單狀態說明",
			font = getFont.font,
			fontSize = 12,
		})
	sceneGroup:insert(infoTitleText)
	infoTitleText:setFillColor(unpack(wordColor))
	infoTitleText.anchorX = 0
	infoTitleText.x = ceil(cx*0.40625)
	infoTitleText.y = -oy+ceil(cy*0.166)
	if (getModel == "iPad") then infoTitleText.y = -oy+ceil(cy*0.166)-20 end
	
	-- 橫線1
	local horizontalLine1 
	if (getModel == "iPad") then
		horizontalLine1 = display.newLine(cx-(infoBase.width/2),-oy+55-20,
		cx+(infoBase.width/2),-oy+55-20)
	else
		horizontalLine1 = display.newLine(cx-(infoBase.width/2),-oy+55,
		cx+(infoBase.width/2),-oy+55)
	end
	sceneGroup:insert(horizontalLine1)
	horizontalLine1:setStrokeColor(unpack(separateLineColor))
	
	-- 各個狀態說明
	local pad
	for i=1,6 do
		if i == 1 then 
			pad = 0
		else
			pad = 60*(i-1)
		end
		local showInfoText = display.newText({
				text = infoText[i].."：",
				font = getFont.font,
				fontSize = 12,
			})
		sceneGroup:insert(showInfoText)
		showInfoText:setFillColor(unpack(infoTextColor[i]))
		showInfoText.anchorX = 0
		showInfoText.x = ceil(cx*0.40625)
		showInfoText.y = -oy+65+pad
		if (getModel == "iPad") then showInfoText.y = -oy+65+pad-20 end

		local infoContentTextBase = display.newRoundedRect(0,0,screenW*0.6, 40, 2)
		sceneGroup:insert(infoContentTextBase)
		infoContentTextBase:setFillColor(unpack(separateLineColor))
		infoContentTextBase.anchorX = 0
		infoContentTextBase.x = ceil(cx*0.40625)
		infoContentTextBase.y = -oy+95+pad
		if (getModel == "iPad") then infoContentTextBase.y = -oy+95+pad-20 end

		local showInfoContentText = display.newText({
				text = infoContent[i],
				font = getFont.font,
				fontSize = 12,
			})
		sceneGroup:insert(showInfoContentText)
		showInfoContentText:setFillColor(unpack(wordColor))
		showInfoContentText.anchorX = 0
		showInfoContentText.x = ceil(cx*0.45)
		showInfoContentText.y = -oy+95+pad
		if (getModel == "iPad") then showInfoContentText.y = -oy+95+pad-20 end
	end

	-- 橫線2
	local horizontalLine2
	if (getModel == "iPad") then
		horizontalLine2 = display.newLine(cx-(infoBase.width/2),-oy+425-20,
		cx+(infoBase.width/2),-oy+425-20)
	else
		horizontalLine2 = display.newLine(cx-(infoBase.width/2),-oy+425,
		cx+(infoBase.width/2),-oy+425)
	end
	sceneGroup:insert(horizontalLine2)
	horizontalLine2:setStrokeColor(unpack(separateLineColor))

	--確定按鈕
	local confirmBtn = widget.newButton({
		id = "confirmBtn",
		label = "確認",
		labelColor = { default = mainColor1, over = mainColor2},
		font = getFont.font,
		fontSize = 14,
		x = ceil(cx*1.5),
		y = -oy+440,
		width = 40,
		height = 20,
		defaultfile = "assets/transparent.png",
		shape = "rect",
		onPress = onBtnListener,
	})
	sceneGroup:insert(confirmBtn)
	if (getModel == "iPad") then confirmBtn.y = -oy+440-20 end
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