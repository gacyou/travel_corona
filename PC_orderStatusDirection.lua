-----------------------------------------------------------------------------------------
--
-- PC_orderStatusDirection.lua
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
local wRate = screenW/1080
local hRate = screenH/1920

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

local ceil = math.ceil
local floor = math.floor

function scene:create( event )
	local sceneGroup = self.view
	local infoBackground = display.newRect( cx, cy, screenW+ox+ox, screenH+oy+oy)
	sceneGroup:insert(infoBackground)
	infoBackground:setFillColor( 0, 0, 0, 0.6)
	-- 說明列的白底
	local infoBase = display.newRect( cx, -oy+floor(190*hRate), (screenW+ox+ox)*0.7, floor(110*hRate))
	sceneGroup:insert(infoBase)
	infoBase.anchorY = 0
	-- 訂單狀態說明文字
	local infoTitleText = display.newText({
			text = "訂單狀態說明",
			font = getFont.font,
			fontSize = 12,
		})
	sceneGroup:insert(infoTitleText)
	infoTitleText:setFillColor(unpack(wordColor))
	infoTitleText.anchorX = 0
	infoTitleText.x = infoBase.x-infoBase.contentWidth*0.5+ceil(40*wRate)
	infoTitleText.y = infoBase.y+infoBase.contentHeight*0.5
	-- 橫線1
	local horizontalLine1 
	horizontalLine1 = display.newLine( infoBase.x-infoBase.contentWidth*0.5, infoBase.y+infoBase.contentHeight, infoBase.x+infoBase.contentWidth*0.5, infoBase.y+infoBase.contentHeight)
	sceneGroup:insert(horizontalLine1)
	horizontalLine1:setStrokeColor(unpack(separateLineColor))
	horizontalLine1.strokeWidth = 1
	local horizontalLine1Num = sceneGroup.numChildren
	-- 各個狀態說明
	local showInfoBaseY = horizontalLine1.y
	for i = 1, #infoText do
		local showInfoText = display.newText({
				text = infoText[i],
				font = getFont.font,
				fontSize = 12,
			})
		sceneGroup:insert(showInfoText)
		showInfoText:setFillColor(unpack(infoTextColor[i]))
		showInfoText.anchorX = 0
		showInfoText.anchorY = 0
		showInfoText.x = infoTitleText.x
		showInfoText.y = showInfoBaseY+floor(35*hRate)
		local showInfoTextNum = sceneGroup.numChildren

		local colonText = display.newText({
				parent = sceneGroup,
				text = "：",
				font = getFont.font,
				fontSize = 12,
			})
		colonText:setFillColor(unpack(wordColor))
		colonText.anchorX = 0
		colonText.anchorY = 0
		colonText.x = showInfoText.x+showInfoText.contentWidth
		colonText.y = showInfoText.y

		local infoContentTextBase = display.newRoundedRect( infoBase.x, showInfoText.y+showInfoText.contentHeight, infoBase.contentWidth-(ceil(30*wRate*2)), 40, 2)
		sceneGroup:insert(infoContentTextBase)
		infoContentTextBase:setFillColor(unpack(separateLineColor))
		infoContentTextBase.anchorY = 0

		local showInfoContentText = display.newText({
				text = infoContent[i],
				font = getFont.font,
				fontSize = 12,
				width = infoContentTextBase.contentWidth*0.9,
				height = 0,
			})
		sceneGroup:insert(showInfoContentText)
		showInfoContentText:setFillColor(unpack(wordColor))
		showInfoContentText.x = infoContentTextBase.x
		showInfoContentText.y = infoContentTextBase.y+infoContentTextBase.contentHeight*0.5

		local showInfoBaseHeight = infoContentTextBase.y+infoContentTextBase.contentHeight-showInfoBaseY
		local showInfoBase = display.newRect( infoBase.x, showInfoBaseY, infoBase.contentWidth, showInfoBaseHeight)
		showInfoBase.anchorY = 0
		if ( i == 1 ) then
			sceneGroup:insert( horizontalLine1Num, showInfoBase)
		else
			sceneGroup:insert( showInfoTextNum, showInfoBase)
		end
		showInfoBaseY = infoContentTextBase.y+infoContentTextBase.contentHeight
		if ( i == #infoText ) then
			local bottomInfoBase = display.newRect( sceneGroup, infoBase.x, showInfoBaseY, infoBase.contentWidth, showInfoBaseHeight*0.7)
			bottomInfoBase.anchorY = 0
			-- 橫線2
			local horizontalLine2
				horizontalLine2 = display.newLine(infoBase.x-infoBase.contentWidth*0.5, bottomInfoBase.y+floor(35*hRate), infoBase.x+infoBase.contentWidth*0.5, bottomInfoBase.y+floor(35*hRate))
			sceneGroup:insert(horizontalLine2)
			horizontalLine2:setStrokeColor(unpack(separateLineColor))
			--確定按鈕
			local confirmBtn = widget.newButton({
				id = "confirmBtn",
				label = "確認",
				labelColor = { default = mainColor1, over = mainColor2},
				font = getFont.font,
				fontSize = 14,
				x = infoBase.x+infoBase.contentWidth*0.5-ceil(30*wRate),
				y = horizontalLine2.y+floor(35*hRate),
				width = 40,
				height = 20,
				defaultfile = "assets/transparent.png",
				shape = "rect",
				onPress = function()
					composer.hideOverlay( "zoomOutIn", 300 )
				end,
			})
			sceneGroup:insert(confirmBtn)
			confirmBtn.anchorX = 1
			confirmBtn.anchorY = 0
		end
	end
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
		composer.removeScene("PC_orderStatusDirection")
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