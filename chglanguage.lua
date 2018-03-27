-----------------------------------------------------------------------------------------
--
-- chglanguage.lua
--
-----------------------------------------------------------------------------------------

local composer = require("composer")
local widget = require("widget")
local getFont = require("setFont")
local tabBar = require("mainTabBar")
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

local sceneGroup,choiceLanguageGroup,choiceCurrencyGroup
local listTableView
local language 
local currency
local languageList = {"繁體中文","簡體中文","英文"}
local currencyList = {"台幣","美金","港幣","人民幣"} 
local title = { "更改語言", "更改貨幣" }

local prevScene = composer.getSceneName("previous")
local checkboxOptions = {
	frames = 
	{
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
-- default value
language = languageList[1]
currency = currencyList[1]

local ceil = math.ceil
local floor = math.floor

-- 按鈕的監聽事件
local function onBtnListener( event )
	local id = event.target.id
	if( id == "backBtn") then
		tabBar.myTabBarShown()
		--composer.gotoScene(prevScene,{ effect = "slideLeft", time = 200})
		composer.hideOverlay("slideLeft", 200)
	end
end

function scene:create( event )
	local sceneGroup = self.view
	tabBar.myTabBarHidden()
	local setStatus = {}
	------------------ 背景元件 -------------------
		local background = display.newRect( cx, cy, screenW+ox+ox, screenH+oy+oy)
		background:setFillColor(unpack(backgroundColor))
		sceneGroup:insert(background)
	------------------ 抬頭元件 -------------------
	-- 陰影
		local titleBaseShadow = display.newImageRect("assets/shadow0205.png", 320, 60)
		sceneGroup:insert(titleBaseShadow)
		titleBaseShadow.width = screenW+ox+ox
		titleBaseShadow.height = floor(178*hRate)
		titleBaseShadow.x = cx
		titleBaseShadow.y = -oy+titleBaseShadow.height*0.5
	-- 白底
		local titleBase = display.newRect( cx, 0, screenW+ox+ox, titleBaseShadow.contentHeight*0.9)
		sceneGroup:insert(titleBase)
		titleBase.y = -oy+titleBase.contentHeight*0.5
	-- 返回按鈕	
		local backBtn = widget.newButton({
			id = "backBtn",
			x = -ox+ceil(49*wRate),
			y = titleBase.y,
			width = 162,
			height = 252,
			defaultFile = "assets/btn-back-b.png",
			overFile = "assets/btn-back-b.png",
			onRelease = onBtnListener,
		})
		sceneGroup:insert(backBtn)
		backBtn.anchorX = 0
		backBtn.width = backBtn.width*0.07
		backBtn.height = backBtn.height*0.07
	-- 顯示文字-"更改語言/貨幣"
		local titleText = display.newText({
			text = "更改語言/貨幣",
			font = getFont.font,
			fontSize = 14,
		})
		sceneGroup:insert(titleText)
		titleText:setFillColor(unpack(wordColor))
		titleText.anchorX = 0
		titleText.x = backBtn.x+backBtn.contentWidth+ceil(30*wRate)
		titleText.y = titleBase.y
	------------------ 更改語言元件 -------------------
	-- 白底
		local chglanguageBase = display.newRect(sceneGroup, cx, titleBase.y+titleBase.contentHeight*0.5+ceil(30*hRate), screenW+ox+ox, screenH/10)
		chglanguageBase.anchorY = 0
	-- 陰影
		local chglanguageBaseTopShadow = display.newImage( sceneGroup, "assets/s-up.png", cx, chglanguageBase.y)
		chglanguageBaseTopShadow.anchorY = 1
		chglanguageBaseTopShadow.width = screenW+ox+ox
		chglanguageBaseTopShadow.height = ceil(chglanguageBaseTopShadow.height*0.5)
	-- 顯示文字-"更改語言"
		local chglanguageTitleText = display.newText({
			parent = sceneGroup,
			text = "更改語言",
			font = getFont.font,
			fontSize = 10,
		})
		chglanguageTitleText:setFillColor(unpack(wordColor))
		chglanguageTitleText.anchorX = 0
		chglanguageTitleText.anchorY = 0
		chglanguageTitleText.x = backBtn.x
		chglanguageTitleText.y = chglanguageBase.y+chglanguageBase.contentHeight*0.2
	-- 顯示文字-語言選項
		local chglanguageOptionText = display.newText({
			parent = sceneGroup,
			text = language,
			font = getFont.font,
			fontSize = 14,
		})
		chglanguageOptionText:setFillColor(unpack(wordColor))
		chglanguageOptionText.anchorX = 0
		chglanguageOptionText.anchorY = 0
		chglanguageOptionText.x = backBtn.x
		chglanguageOptionText.y = chglanguageBase.y+chglanguageBase.contentHeight*0.5
	-- 圖示-箭頭
		local chglanguageArrow = display.newImage(sceneGroup, "assets/btn-dropdown-dg.png",screenW+ox-ceil(49*wRate), chglanguageOptionText.y+chglanguageOptionText.contentHeight*0.5)
		chglanguageArrow.width = chglanguageArrow.width*0.05
		chglanguageArrow.height = chglanguageArrow.height*0.05
		chglanguageArrow.x = chglanguageArrow.x - chglanguageArrow.contentWidth*0.5
		setStatus["chglanguageArrow"] = "down"
	-- 更改語言-底線
		local chglanguageBaseLine = display.newLine( backBtn.x, chglanguageBase.y+chglanguageBase.contentHeight*0.85, screenW+ox-ceil(49*wRate), chglanguageBase.y+chglanguageBase.contentHeight*0.85)
		sceneGroup:insert(chglanguageBaseLine)
		chglanguageBaseLine:setStrokeColor(unpack(separateLineColor))
		chglanguageBaseLine.strokeWidth = 1
	-- 更改語言觸碰監聽事件
		local function chglanguageListener( event )
			local phase = event.phase
			if (phase == "ended") then
				chglanguageBaseLine.strokeWidth = 2
				chglanguageBaseLine:setStrokeColor(unpack(mainColor2))
				if(setStatus["chglanguageArrow"] == "down") then
					setStatus["chglanguageArrow"] = "up"
					chglanguageArrow:rotate(180)
				end
				choiceLanguageGroup = display.newGroup()
			-- 透明黑背景
				local choiceLanguageBackground = display.newRect(cx,cy,screenW+ox+ox,screenH+oy+oy)
				choiceLanguageGroup:insert(choiceLanguageBackground)
				choiceLanguageBackground:addEventListener("touch", function () return true; end)
				choiceLanguageBackground:addEventListener("tap", function () return true; end)
				choiceLanguageBackground:setFillColor( 0, 0, 0, 0.3)
			-- 建立語言選單 --
			-- 白底
				local languageBase = display.newRect(choiceLanguageGroup, cx, cy*0.7, (screenW+ox+ox)*0.6, screenH*0.4)
			-- 選擇語言的抬頭文字
				local languageSlctTitle = display.newText({
					text = "選擇語言",
					font = getFont.font,
					fontSize = 14,
				})
				choiceLanguageGroup:insert(languageSlctTitle)
				languageSlctTitle:setFillColor(unpack(wordColor))
				languageSlctTitle.anchorX = 0
				languageSlctTitle.anchorY = 0
				languageSlctTitle.x = languageBase.x-languageBase.contentWidth*0.5+ceil(40*wRate)
				languageSlctTitle.y = languageBase.y-languageBase.contentHeight*0.5+ceil(40*hRate)
			-- 分隔線
				local languageSeparatedLine = display.newLine( languageBase.x-languageBase.contentWidth*0.5, languageSlctTitle.y+languageSlctTitle.contentHeight+ceil(40*hRate),
					languageBase.x+languageBase.contentWidth*0.5, languageSlctTitle.y+languageSlctTitle.contentHeight+ceil(40*hRate))
				choiceLanguageGroup:insert(languageSeparatedLine)
				languageSeparatedLine:setStrokeColor(unpack(separateLineColor))
				languageSeparatedLine.strokeWidth = 1	
			-- 選擇語言選項字體的觸碰監聽事件
				local choiceLanguageRadio = {}
				local function languageTextOptionListener( event )
					local phase = event.phase
					local id = event.target.id
					if (phase == "began") then
						choiceLanguageRadio[id]:setState({
								isOn = true
							})
					elseif (phase == "ended") then
						choiceLanguageGroup.isVisible = false
						chglanguageArrow:rotate(180)
						setStatus["chglanguageArrow"] = "down"
						chglanguageBaseLine.strokeWidth = 1
						chglanguageBaseLine:setStrokeColor(unpack(separateLineColor))
						chglanguageOptionText.text = languageList[id]
						choiceLanguageGroup:removeSelf()
					end
					return true
				end	
			-- 選擇語言的文字選項	
				for i = 1, #languageList do			
					choiceLanguageRadio[i] = widget.newSwitch({
						id = i,
						style = "radio",
						sheet = checkboxSheet,
						frameOff = 2,
						frameOn = 1,
						onRelease = function ( event )
							local id = event.target.id
							choiceLanguageGroup.isVisible = false
							chglanguageArrow:rotate(180)
							setStatus["chglanguageArrow"] = "down"
							chglanguageBaseLine.strokeWidth = 1
							chglanguageBaseLine:setStrokeColor(unpack(separateLineColor))
							chglanguageOptionText.text = languageList[id]
							choiceLanguageGroup:removeSelf()
						end
					})
					choiceLanguageGroup:insert(choiceLanguageRadio[i])
					choiceLanguageRadio[i].anchorX = 0
					choiceLanguageRadio[i].x = languageSlctTitle.x
					choiceLanguageRadio[i].y = languageSeparatedLine.y+floor(40*hRate)+choiceLanguageRadio[i].contentHeight*0.5+(i-1)*40
					choiceLanguageRadio[i]:scale(0.7, 0.7)

					local showLanguageText = display.newText({
						text = languageList[i],
						font = getFont.font,
						fontSize = 12,
					})
					choiceLanguageGroup:insert(showLanguageText)
					showLanguageText.id = i
					showLanguageText:setFillColor(unpack(wordColor))
					showLanguageText.anchorX = 0
					showLanguageText.x = choiceLanguageRadio[i].x+choiceLanguageRadio[i].contentWidth+ceil(30*wRate)
					showLanguageText.y = choiceLanguageRadio[i].y+choiceLanguageRadio[i].contentHeight*0.1
					showLanguageText:addEventListener("touch",languageTextOptionListener)
				end
				return true
			end
		end
		chglanguageBase:addEventListener("touch", chglanguageListener)
	------------------ 更改貨幣元件 -------------------
	-- 白底
		local chgCurrencyBase = display.newRect(sceneGroup, cx, chglanguageBase.y+chglanguageBase.contentHeight, screenW+ox+ox, screenH/10)
		chgCurrencyBase.anchorY = 0
	-- 顯示文字-"更改貨幣"
		local chgCurrencyTitleText = display.newText({
			parent = sceneGroup,
			text = "更改貨幣",
			font = getFont.font,
			fontSize = 10,
		})
		chgCurrencyTitleText:setFillColor(unpack(wordColor))
		chgCurrencyTitleText.anchorX = 0
		chgCurrencyTitleText.anchorY = 0
		chgCurrencyTitleText.x = backBtn.x
		chgCurrencyTitleText.y = chgCurrencyBase.y+chgCurrencyBase.contentHeight*0.2
	-- 顯示文字-貨幣選項
		local chgCurrencyOptionText = display.newText({
			parent = sceneGroup,
			text = currency,
			font = getFont.font,
			fontSize = 14,
		})
		chgCurrencyOptionText:setFillColor(unpack(wordColor))
		chgCurrencyOptionText.anchorX = 0
		chgCurrencyOptionText.anchorY = 0
		chgCurrencyOptionText.x = backBtn.x
		chgCurrencyOptionText.y = chgCurrencyBase.y+chgCurrencyBase.contentHeight*0.5
	-- 圖示-箭頭
		local chgCurrencyArrow = display.newImage(sceneGroup, "assets/btn-dropdown-dg.png",screenW+ox-ceil(49*wRate), chgCurrencyOptionText.y+chgCurrencyOptionText.contentHeight*0.5)
		chgCurrencyArrow.width = chgCurrencyArrow.width*0.05
		chgCurrencyArrow.height = chgCurrencyArrow.height*0.05
		chgCurrencyArrow.x = chgCurrencyArrow.x - chgCurrencyArrow.contentWidth*0.5
		setStatus["chgCurrencyArrow"] = "down"
	-- 更改貨幣-底線	
		local chgCurrencyBaseLine = display.newLine( backBtn.x, chgCurrencyBase.y+chgCurrencyBase.contentHeight*0.85, screenW+ox-ceil(49*wRate), chgCurrencyBase.y+chgCurrencyBase.contentHeight*0.85)
		sceneGroup:insert(chgCurrencyBaseLine)
		chgCurrencyBaseLine:setStrokeColor(unpack(separateLineColor))
		chgCurrencyBaseLine.strokeWidth = 1
	-- 更改貨幣觸碰監聽事件
		local function chgCurrencyListener( event )
			local phase = event.phase
			if (phase == "ended") then
				chgCurrencyBaseLine.strokeWidth = 2
				chgCurrencyBaseLine:setStrokeColor(unpack(mainColor2))
				if(setStatus["chgCurrencyArrow"] == "down") then
					setStatus["chgCurrencyArrow"] = "up"
					chgCurrencyArrow:rotate(180)
				end
				choiceCurrencyGroup = display.newGroup()
			-- 透明黑背景
				local choiceCurrencyBackground = display.newRect(cx,cy,screenW+ox+ox,screenH+oy+oy)
				choiceCurrencyGroup:insert(choiceCurrencyBackground)
				choiceCurrencyBackground:addEventListener("touch", function () return true; end)
				choiceCurrencyBackground:addEventListener("tap", function () return true; end)
				choiceCurrencyBackground:setFillColor( 0, 0, 0, 0.3)
			-- 建立幣別選單
			-- 白底
				local currencyBase = display.newRect(choiceCurrencyGroup, cx, cy*0.7, (screenW+ox+ox)*0.6, screenH*0.5)
			-- 選擇幣別的抬頭文字
				local currencySlctTitle = display.newText({
					text = "選擇幣別",
					font = getFont.font,
					fontSize = 14,
				})
				choiceCurrencyGroup:insert(currencySlctTitle)
				currencySlctTitle:setFillColor(unpack(wordColor))
				currencySlctTitle.anchorX = 0
				currencySlctTitle.anchorY = 0
				currencySlctTitle.x = currencyBase.x-currencyBase.contentWidth*0.5+ceil(40*wRate)
				currencySlctTitle.y = currencyBase.y-currencyBase.contentHeight*0.5+ceil(40*hRate)
			-- 分隔線
				local currencySeparatedLine = display.newLine( currencyBase.x-currencyBase.contentWidth*0.5, currencySlctTitle.y+currencySlctTitle.contentHeight+ceil(40*hRate),
					currencyBase.x+currencyBase.contentWidth*0.5, currencySlctTitle.y+currencySlctTitle.contentHeight+ceil(40*hRate))
				choiceCurrencyGroup:insert(currencySeparatedLine)
				currencySeparatedLine:setStrokeColor(unpack(separateLineColor))
				currencySeparatedLine.strokeWidth = 1
			
				local choiceCurrencyRadio = {}
			-- 選擇語言選項字體的觸碰監聽事件
				local function currencyTextOptionListener( event )
					local phase = event.phase
					local id = event.target.id
					if (phase == "began") then
						choiceCurrencyRadio[id]:setState({
								isOn = true
							})
					elseif (phase == "ended") then
						choiceCurrencyGroup.isVisible = false
						chgCurrencyArrow:rotate(180)
						setStatus["chgCurrencyArrow"] = "down"
						chgCurrencyBaseLine.strokeWidth = 1
						chgCurrencyBaseLine:setStrokeColor(unpack(separateLineColor))
						chgCurrencyOptionText.text = currencyList[id]
						choiceCurrencyGroup:removeSelf()
					end
					return true
				end
			-- 選擇幣別的文字選項	
				for i=1,4 do				
					choiceCurrencyRadio[i] = widget.newSwitch({
						id = i,
						style = "radio",
						sheet = checkboxSheet,
						frameOff = 2,
						frameOn = 1,
						onRelease = function ( event )
							local id = event.target.id
							choiceCurrencyGroup.isVisible = false
							chgCurrencyArrow:rotate(180)
							setStatus["chgCurrencyArrow"] = "down"
							chgCurrencyBaseLine.strokeWidth = 1
							chgCurrencyBaseLine:setStrokeColor(unpack(separateLineColor))
							chgCurrencyOptionText.text = currencyList[id]
							choiceCurrencyGroup:removeSelf()
						end
					})
					choiceCurrencyGroup:insert(choiceCurrencyRadio[i])
					choiceCurrencyRadio[i].anchorX = 0
					choiceCurrencyRadio[i].x = currencySlctTitle.x
					choiceCurrencyRadio[i].y = currencySeparatedLine.y+ceil(40*hRate)+choiceCurrencyRadio[i].contentHeight*0.5+(i-1)*40
					choiceCurrencyRadio[i]:scale(0.7, 0.7)
					local showCurrencyText = display.newText({
						text = currencyList[i],
						font = getFont.font,
						fontSize = 12,
					})
					choiceCurrencyGroup:insert(showCurrencyText)
					showCurrencyText.id = i
					showCurrencyText:setFillColor(unpack(wordColor))
					showCurrencyText.anchorX = 0
					showCurrencyText.x = choiceCurrencyRadio[i].x+choiceCurrencyRadio[i].contentWidth+ceil(30*wRate)
					showCurrencyText.y = choiceCurrencyRadio[i].y+choiceCurrencyRadio[i].contentHeight*0.1
					showCurrencyText:addEventListener("touch",currencyTextOptionListener)
				end
				return true
			end
		end
		chgCurrencyBase:addEventListener("touch", chgCurrencyListener)
	------------------ 底部元件 -------------------
	-- 白底
		local bottomBase = display.newRect(sceneGroup, cx, chgCurrencyBase.y+chgCurrencyBase.contentHeight, screenW+ox+ox, (screenH/10)*0.5)
		bottomBase.anchorY = 0
	-- 陰影
		local bottomBaseShadow = display.newImage( sceneGroup, "assets/s-down.png", cx, bottomBase.y+bottomBase.contentHeight)
		bottomBaseShadow.anchorY = 0
		bottomBaseShadow.width = screenW+ox+ox
		bottomBaseShadow.height = ceil(bottomBaseShadow.height*0.5)
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