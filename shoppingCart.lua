-----------------------------------------------------------------------------------------
--
-- shoppingCart.lua
--
-----------------------------------------------------------------------------------------
local widget = require ("widget")
local composer = require ("composer")
local mainTabBar = require ("mainTabBar")
local getFont = require("setFont")
local json = require("json")
local utf8 = require("plugin.utf8")
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
local sRate = math.sqrt(wRate*hRate)

local isLogin
if (composer.getVariable("isLogin")) then 
	isLogin = composer.getVariable("isLogin")
else
	isLogin = false
end

local ceil = math.ceil
local floor = math.floor

-- create()
function scene:create( event )
	local sceneGroup = self.view
	-------------------  參數 -------------------
	if ( composer.getVariable("mainTabBarStatus") and composer.getVariable("mainTabBarStatus") == "hidden" ) then
		mainTabBar.myTabBarScrollShown()
		mainTabBar.setShoppingCart()
		composer.setVariable("mainTabBarStatus", "shown")
	else
		mainTabBar.myTabBarShown()
		mainTabBar.setShoppingCart()
	end
	local urlGetFileNamePattern = "%a+://%w+%.%w+[%.%w]*%:?%d*[/%w]*/(.+%.%a+)"
	local datePattern = "(%d%d%d%d)(%d%d)(%d%d)[%d]+"
	local mainTabBarHeight = composer.getVariable("mainTabBarHeight")
	local mainTabBarY = composer.getVariable("mainTabBarY")
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
	-- 按鈕監聽事件	
		local titleSelection, titleGroup,invitedGroup
		local function onBtnListener( event )
			local id = event.target.id 
			if (id == "backBtn") then
				mainTabBar.setSelectedHomePage()
				--local options = { time = 200, effect = "fade"}
				composer.gotoScene("homePage")
			end
			return true
		end	
	------------------- 抬頭元件 -------------------
	-- 白色底圖
		local titleBase = display.newRect( cx, 0, screenW+ox+ox, floor(178*hRate))
		sceneGroup:insert(titleBase)
		titleBase.y = -oy+titleBase.contentHeight*0.5
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
	-- 顯示文字-購物車
		local titleText = display.newText({
			text = "購物車",
			height = 0,
			y = backBtn.y,
			font = getFont.font,
			fontSize = 14,
		})
		sceneGroup:insert(titleText)
		titleText:setFillColor(unpack(wordColor))
		titleText.anchorX = 0
		titleText.x = backArrow.x+backArrow.contentWidth+ceil(30*wRate)
	-- 顯示文字-選擇條件
		local allSelectedText = display.newText({
			text = "取消全選",
			height = 0,
			y = backBtn.y,
			font = getFont.font,
			fontSize = 12,
		})
		sceneGroup:insert(allSelectedText)
		allSelectedText:setFillColor(unpack(mainColor1))
		allSelectedText.anchorX = 1
		allSelectedText.x = titleBase.contentWidth-ceil(49*wRate)
		allSelectedText.isVisible = false
	-- 陰影
		local titleBaseShadow = display.newImage( sceneGroup, "assets/s-down.png", titleBase.x, titleBase.y+titleBase.contentHeight*0.5)
		titleBaseShadow.anchorY = 0
		titleBaseShadow.width = titleBase.contentWidth
		titleBaseShadow.height = floor(titleBaseShadow.height*0.5)
		local titleShadowNum = sceneGroup.numChildren
	------------------- 購物車元件 -------------------
	-- 登入與否 --
	if ( isLogin == false ) then
		-- 未登入
		-- 奮路鳥圖	
			local funloadBird = display.newImage( sceneGroup, "assets/img-bird.png" , cx, cy)
			funloadBird.anchorY = 1
			funloadBird.width = funloadBird.width*0.35
			funloadBird.height = funloadBird.height*0.35
		-- 顯示文字-"您的購物車空空如也~"
			local noGoodText = display.newText({
				text = "您的購物車空空如也~",
				font = getFont.font,
				fontSize = 14,
			})
			sceneGroup:insert(noGoodText)
			noGoodText:setFillColor(unpack(wordColor))
			noGoodText.anchorX = 0
			noGoodText.anchorY = 0
			noGoodText.x = titleBase.contentWidth*0.2
			noGoodText.y = funloadBird.y+floor(40*hRate)
		-- 顯示文字-"去逛逛"
			local goShoppingText = display.newText({
				text = "去逛逛",
				font = getFont.font,
				fontSize = 14,
			})
			sceneGroup:insert(goShoppingText)
			goShoppingText:setFillColor(unpack(mainColor1))
			goShoppingText.anchorX = 0
			goShoppingText.anchorY = 0
			goShoppingText.x = noGoodText.x+noGoodText.contentWidth
			goShoppingText.y = noGoodText.y
		-- 顯示文字-"吧"
			local wowText = display.newText({
				text = "吧",
				font = getFont.font,
				fontSize = 14,
			})
			sceneGroup:insert(wowText)
			wowText:setFillColor(unpack(wordColor))
			wowText.anchorX = 0
			wowText.anchorY = 0
			wowText.x = goShoppingText.x+goShoppingText.contentWidth
			wowText.y = goShoppingText.y
	else
		local accessToken
		if ( composer.getVariable("accessToken") and  composer.getVariable("accessToken") ~= "N/A") then
			accessToken =  composer.getVariable("accessToken")
		end
		local headers = {}
		headers["Authorization"] = "Bearer "..accessToken
		local params = {}
		params.headers = headers
		local cartInfoTable = {}
		local dataCount = 0 
		local function getCartInfo( event )
			if ( event.isError ) then
				print("Network Error: "..event.response)
			elseif ( event.phase == "ended" ) then
				-- 取得購物車數量跟商品基本資訊
				--print ("RESPONSE: "..event.response)
				local shoppingCartData = json.decode(event.response)
				if ( #shoppingCartData["shoppingCartItems"] > 0 ) then
					-- 有商品 --
					-- 取得並儲存購物車相關資訊
					for i = 1, #shoppingCartData["shoppingCartItems"] do
						cartInfoTable[i] = {}
						local objectId = shoppingCartData["shoppingCartItems"][i]["id"]
						cartInfoTable[i]["objectId"] = shoppingCartData["shoppingCartItems"][i]["id"]

						local productId = shoppingCartData["shoppingCartItems"][i]["itemId"]
						cartInfoTable[i]["productId"] = shoppingCartData["shoppingCartItems"][i]["itemId"]
						
						local useBegin = shoppingCartData["shoppingCartItems"][i]["useBegin"]
						cartInfoTable[i]["useBegin"] = shoppingCartData["shoppingCartItems"][i]["useBegin"]
						
						local productAmount = shoppingCartData["shoppingCartItems"][i]["count"]
						cartInfoTable[i]["productAmount"] = shoppingCartData["shoppingCartItems"][i]["count"]
						-- 取得並儲存商品詳細資訊
						local function getItemInfo( event )
							if (event.isError) then
								print("Network Error: "..event.response)
							elseif ( event.phase == "ended" ) then
								local decodedData = json.decode(event.response)
								cartInfoTable[i]["picUrl"] = decodedData["itemImgs"][1]["url"]
								cartInfoTable[i]["itemPrice"] = decodedData["twd"]
								cartInfoTable[i]["itemTitle"] = decodedData["title"]
								cartInfoTable[i]["subTitle"] = decodedData["subTitle"]
								dataCount = dataCount+1
							end
							-- 資料儲存完畢進行處理
							if ( dataCount == #shoppingCartData["shoppingCartItems"]) then
								allSelectedText.isVisible = true
								------------------- 購物車底部元件 -------------------
								-- 顯示商品數量，金額，結算 --
									local bottomBase = display.newRect( sceneGroup, cx, mainTabBarY-mainTabBarHeight*0.5, screenW+ox+ox, screenH/10)
									bottomBase.anchorY = 1
									local bottomAmountText = display.newText({
										parent = sceneGroup,
										text = "0件商品",
										font = getFont.font,
										fontSize = 12,
										x = backArrow.x,
										y = bottomBase.y-bottomBase.contentHeight*0.6,
									})
									bottomAmountText:setFillColor(unpack(wordColor))
									bottomAmountText.anchorX = 0
									local bottomBaseText = display.newText({
										parent = sceneGroup,
										text = "合計",
										font = getFont.font,
										fontSize = 12,
										x = bottomAmountText.x+bottomAmountText.contentWidth,
										y = bottomAmountText.y,
									})
									bottomBaseText:setFillColor(unpack(wordColor))
									bottomBaseText.anchorX = 0
									local bottomMoneySignText = display.newText({
										parent = sceneGroup,
										text = "NT$",
										font = getFont.font,
										fontSize = 12,
										x = backArrow.x,
										y = bottomBase.y-bottomBase.contentHeight*0.3,
									})
									bottomMoneySignText:setFillColor(unpack(subColor2))
									bottomMoneySignText.anchorX = 0
									local bottomPriceText = display.newText({
										parent = sceneGroup,
										text = "0",
										font = getFont.font,
										fontSize = 12,
										x = bottomMoneySignText.x+bottomMoneySignText.contentWidth+ceil(10*wRate),
										y = bottomMoneySignText.y,
									})
									bottomPriceText:setFillColor(unpack(subColor2))
									bottomPriceText.anchorX = 0
									local calculateBtn = widget.newButton({
										id = "calculateBtn",
										x = screenW+ox-ceil(25*wRate),
										y = bottomBase.y-bottomBase.contentHeight*0.5,
										label = "結算",
										labelColor = { default = { 1, 1, 1}, over = { 1, 1, 1, 0.6}},
										font = getFont.font,
										fontSize = 12,
										defaultFile = "assets/btn-settlement.png",
										width = bottomBase.contentWidth*0.35,
										height = bottomBase.contentHeight*0.5,
									})
									sceneGroup:insert(calculateBtn)
									calculateBtn.anchorX = 1
								-- 顯示獲得積分 --
									local pointBase = display.newRect( sceneGroup, cx, bottomBase.y-bottomBase.contentHeight, bottomBase.contentWidth, bottomBase.contentHeight*0.5)
									pointBase.anchorY = 1
									local pointBaseShadow = display.newImage( sceneGroup, "assets/s-up.png", pointBase.x, pointBase.y-pointBase.contentHeight)
									pointBaseShadow.anchorY = 1
									pointBaseShadow.width = pointBase.contentWidth
									pointBaseShadow.height = pointBaseShadow.height*0.2
									local pointBaseLine = display.newLine( sceneGroup, -ox, pointBase.y, screenW+ox, pointBase.y)
									pointBaseLine:setStrokeColor(unpack(separateLineColor))
									pointBaseLine.strokeWidth = 1
									local hintText = display.newText({
										parent = sceneGroup,
										text = "您可獲得",
										font = getFont.font,
										fontSize = 12,
										x = bottomAmountText.x,
										y = pointBase.y-pointBase.contentHeight*0.5,
									})
									hintText:setFillColor(unpack(wordColor))
									hintText.anchorX = 0
									local pointText = display.newText({
										parent = sceneGroup,
										text = "0",
										font = getFont.font,
										fontSize = 12,
										x = hintText.x+hintText.contentWidth+ceil(10*wRate),
										y = hintText.y,
									})
									pointText:setFillColor(unpack(mainColor1))
									pointText.anchorX = 0
									local pointStringText = display.newText({
										parent = sceneGroup,
										text = "積分",
										font = getFont.font,
										fontSize = 12,
										x = pointText.x+pointText.contentWidth+ceil(10*wRate),
										y = hintText.y,
									})
									pointStringText:setFillColor(unpack(wordColor))
									pointStringText.anchorX = 0
								-- 顯示購物車商品 --
									local cartScrollView = widget.newScrollView({
										id = "cartScrollView",
										width = screenW+ox+ox,
										height = pointBaseShadow.y-(titleBase.y+titleBase.contentHeight*0.5),
										isBounceEnabled = false,
										backgroundColor = backgroundColor,
									})
									sceneGroup:insert( titleShadowNum, cartScrollView)
									cartScrollView.x = cx
									cartScrollView.y = titleBase.y+titleBase.contentHeight*0.5
									cartScrollView.anchorY = 0
								-- scrollViewCart 參數 --
									local cartGroup = display.newGroup()
									cartScrollView:insert(cartGroup)
									local productBaseX = cartScrollView.contentWidth*0.5
									local productBaseY, cartScrollViewHeight = 0, 0
									local totalPrice = 0							
								for i=1, #cartInfoTable do
									------------------- 購物車內容元件 -------------------
									-- 陰影+白底
										local productShadowBase = display.newImageRect( cartGroup, "assets/shadow-3.png", screenW+ox+ox, floor(442*hRate))
										productShadowBase.anchorY = 0
										productShadowBase.x = productBaseX
										productShadowBase.y = productBaseY+floor(24*hRate)
										productBaseY = productShadowBase.y+productShadowBase.contentHeight
										cartScrollViewHeight = productBaseY
										local productBase = display.newRect( cartGroup, productShadowBase.x, productShadowBase.y+productShadowBase.contentHeight*0.5, productShadowBase.contentWidth*0.96875, productShadowBase.contentHeight*0.98)
									-- 圖片顯示區
										local productPicBase = display.newRoundedRect( cartGroup, productBase.x-productBase.contentWidth*0.5+ceil(30*sRate), productBase.y-productBase.contentHeight*0.5+floor(30*sRate), floor(340*wRate), floor(280*hRate), 2)
										productPicBase.anchorX = 0
										productPicBase.anchorY = 0
										productPicBase:setFillColor(unpack(separateLineColor))
									-- 處理圖片
										local picUrl = cartInfoTable[i]["picUrl"]
										local picName = string.match(picUrl,urlGetFileNamePattern)
										local function picNetworkListener(event)
											if ( event.isError ) then
												print( "Network error! -- Download Failed")
											end
											if (event.phase == "ended" ) then
												local paint = { type = "image", filename = event.response.filename, baseDir = event.response.baseDirectory}
												productPicBase.fill = paint
											end
										end
										network.download( 
											picUrl, 
											"GET", 
											picNetworkListener, 
											picName,
											system.TemporaryDirectory)
									-- 橫分隔線
										local productBaseLine = display.newLine( cartGroup, productBase.x-productBase.contentWidth*0.49, productPicBase.y+productPicBase.contentHeight+floor(30*sRate), productBase.x+productBase.contentWidth*0.49, productPicBase.y+productPicBase.contentHeight+floor(30*sRate))
										productBaseLine:setStrokeColor(unpack(separateLineColor))
										productBaseLine.strokeWidth = 1
									-- 核選區塊
										local checkBox = widget.newSwitch({
											id = "checkBox"..i,
											style = "checkbox",
											initialSwitchState = true,
											sheet = checkboxSheet,
											frameOff = 2,
											frameOn = 1,
											x = productBase.x+productBase.width*0.5-floor(30*sRate),
											y = productPicBase.y+productPicBase.contentHeight*0.5,
											width = 30*sRate,
											height = 30*sRate,
										})
										cartGroup:insert(checkBox)
										checkBox.anchorX = 1
									-- 顯示文字-"更改"
										local functionWordY = ((productBase.y+productBase.contentHeight*0.5)+productBaseLine.y)*0.5
										local modifyText = display.newText({
											parent = cartGroup,
											text = "更改",
											font = getFont.font,
											fontSize = 12,
											x = productPicBase.x,
											y = functionWordY,
										})
										modifyText:setFillColor(unpack(wordColor))
										modifyText.anchorX = 0
										modifyText.id = i
										modifyText:addEventListener( "touch", 
											function ( event )
												local phase = event.phase
												local id = event.target.id
												local year, month, day = cartInfoTable[id]["useBegin"]:match(datePattern)
												if ( phase == "ended" ) then
													local options = {
														effect = "fade",
														time = 200,
														params = {
															objectId = cartInfoTable[id]["objectId"],
															productTitle = cartInfoTable[id]["itemTitle"],
															productId = cartInfoTable[id]["productId"],
															singlePrice = cartInfoTable[id]["itemPrice"],
															productAmount = cartInfoTable[id]["productAmount"],
															fromScene = "shoppingCart",
															orderDate = year.."/"..month.."/"..day,
														}
													}
													composer.gotoScene("orderOptions", options)
												end
												return true
											end)
									-- 直分隔線
										local functionWordSepLine = display.newLine( cartGroup, modifyText.x+modifyText.contentWidth+floor(30*sRate), functionWordY-modifyText.contentHeight*0.6, modifyText.x+modifyText.contentWidth+floor(30*sRate), functionWordY+modifyText.contentHeight*0.6)
										functionWordSepLine:setStrokeColor(unpack(separateLineColor))
										functionWordSepLine.strokeWidth = 1
									-- 顯示文字-"刪除"
										local deleteText = display.newText({
											parent = cartGroup,
											text = "刪除",
											font = getFont.font,
											fontSize = 12,
											x = functionWordSepLine.x+floor(30*sRate),
											y = functionWordY,
										})
										deleteText:setFillColor(unpack(wordColor))
										deleteText.anchorX = 0
										deleteText.id = i
										deleteText:addEventListener( "touch", function ( event )
											local phase = event.phase
											local id = event.target.id
											if ( phase == "ended" ) then
												native.showAlert( "", "是否刪除該商品?", { "刪除", "取消"}, 
													function (event)
														if (event.action == "clicked") then
															local index = event.index
															if ( index == 1) then
																local headers = {}
																headers["Authorization"] = "Bearer "..accessToken
																local params = {}
																params.headers = headers
																local url = "http://211.21.114.208:80/1.0/ShoppingCart/del/"..cartInfoTable[id]["objectId"]
																--network.request( url, "GET", upDateProduct, params)
															end
														end
													end)
											end
											return true
										end)
									-- 顯示金額
										local priceText = display.newText({
											parent = cartGroup,
											text = cartInfoTable[i]["itemPrice"]*tonumber(cartInfoTable[i]["productAmount"]),
											font = getFont.font,
											fontSize = 12,
											x = productBase.x+productBase.contentWidth*0.5-floor(30*sRate),
											y = functionWordY,
										})
										priceText:setFillColor(unpack(subColor2))
										priceText.anchorX = 1
										totalPrice = totalPrice+tonumber(priceText.text)
									-- 顯示文字-貨幣符號
										local currencyMarkText = display.newText({
											parent = cartGroup,
											text = "NT$",
											font = getFont.font,
											fontSize = 12,
											x = priceText.x-priceText.contentWidth,
											y = functionWordY,
										})
										currencyMarkText:setFillColor(unpack(subColor2))
										currencyMarkText.anchorX = 1
									-- 產品訊息相關參數 --
										local stringX = productPicBase.x+productPicBase.contentWidth+floor(30*sRate)
										local stringWidth = (checkBox.x-checkBox.contentWidth-floor(30*sRate))- stringX
									-- 顯示主標
										local productTitleText = display.newText({
											parent = cartGroup,
											text = cartInfoTable[i]["itemTitle"],
											font = getFont.font,
											fontSize = 12,
											x = stringX,
											y = productBase.y-productBase.contentHeight*0.5+floor(4*hRate),
											width = stringWidth,
											height = 0,
										})
										productTitleText:setFillColor(unpack(wordColor))
										productTitleText.anchorX = 0
										productTitleText.anchorY = 0
									-- 將副標文字轉成UTF8處理後再顯示
										local utf8Table = {}
										for k,v in utf8.codes(cartInfoTable[i]["subTitle"]) do
											table.insert(utf8Table,v)
										end
										local subTextNum = 0
										if (#utf8Table > 30) then
											subTextNum = 30
										else
											subTextNum = #utf8Table
										end
										local subText = ""
										for i=1, subTextNum do
											subText = subText..utf8.escape("%"..utf8Table[i])
											if ( i == subTextNum ) then
												subText = subText.."..."
											end
										end
									-- 顯示副標
										local productSubText = display.newText({
											parent = cartGroup,
											text = subText,
											font = getFont.font,
											fontSize = 10,
											x = stringX,
											y = productTitleText.y+productTitleText.contentHeight+floor(16*hRate),
											width = stringWidth,
											height = 0,
										})
										productSubText:setFillColor(unpack(wordColor))
										productSubText.anchorX = 0
										productSubText.anchorY = 0
									-- 處理日期
										local bYear, bMonth, bDay = cartInfoTable[i]["useBegin"]:match(datePattern)
										local dateString = bYear.."年"..bMonth.."月"..bDay.."日"
									-- 顯示日期
										local productDateText = display.newText({
											parent = cartGroup,
											text = dateString,
											font = getFont.font,
											fontSize = 10,
											x = stringX,
											y = productSubText.y+productSubText.contentHeight+floor(12*hRate),
											width = stringWidth,
											height = 0,
										})
										productDateText:setFillColor(unpack(wordColor))
										productDateText.anchorX = 0
										productDateText.anchorY = 0
									-- 顯示數量
										local productAmountText = display.newText({
											parent = cartGroup,
											text = "數量："..cartInfoTable[i]["productAmount"],
											font = getFont.font,
											fontSize = 10,
											x = stringX,
											y = productDateText.y+productDateText.contentHeight+floor(12*hRate),
											width = stringWidth,
											height = 0,
										})
										productAmountText:setFillColor(unpack(wordColor))
										productAmountText.anchorX = 0
										productAmountText.anchorY = 0
									-- 判斷是否要增加cartScrollView的高度
										if ( cartScrollViewHeight > cartScrollView.contentHeight ) then
											cartScrollView:setScrollHeight(cartScrollViewHeight+floor(24*hRate))
										end
									-- 積分、商品重新給值 --
									-- 商品件數
										bottomAmountText.text = #cartInfoTable.."件商品"
										bottomBaseText.x = bottomAmountText.x+bottomAmountText.contentWidth
									-- 商品總額
										bottomPriceText.text = totalPrice

								end
							end
						end
						local productUrl = "http://211.21.114.208/1.0/GetItem/"..cartInfoTable[i]["productId"]
						network.request( productUrl, "GET", getItemInfo)
					end
				else
					-- 無商品 --
					-- 奮路鳥圖	
						local funloadBird = display.newImage( sceneGroup, "assets/img-bird.png" , cx, cy)
						funloadBird.anchorY = 1
						funloadBird.width = funloadBird.width*0.35
						funloadBird.height = funloadBird.height*0.35
					-- 顯示文字-"您的購物車空空如也~"
						local noGoodText = display.newText({
							text = "您的購物車空空如也~",
							font = getFont.font,
							fontSize = 14,
						})
						sceneGroup:insert(noGoodText)
						noGoodText:setFillColor(unpack(wordColor))
						noGoodText.anchorX = 0
						noGoodText.anchorY = 0
						noGoodText.x = titleBase.contentWidth*0.2
						noGoodText.y = funloadBird.y+floor(40*hRate)
					-- 顯示文字-"去逛逛"
						local goShoppingText = display.newText({
							text = "去逛逛",
							font = getFont.font,
							fontSize = 14,
						})
						sceneGroup:insert(goShoppingText)
						goShoppingText:setFillColor(unpack(mainColor1))
						goShoppingText.anchorX = 0
						goShoppingText.anchorY = 0
						goShoppingText.x = noGoodText.x+noGoodText.contentWidth
						goShoppingText.y = noGoodText.y
					-- 顯示文字-"吧"
						local wowText = display.newText({
							text = "吧",
							font = getFont.font,
							fontSize = 14,
						})
						sceneGroup:insert(wowText)
						wowText:setFillColor(unpack(wordColor))
						wowText.anchorX = 0
						wowText.anchorY = 0
						wowText.x = goShoppingText.x+goShoppingText.contentWidth
						wowText.y = goShoppingText.y
				end
			end
		end
		local url = "http://211.21.114.208/1.0/ShoppingCart/get"
		network.request( url, "POST", getCartInfo, params)
	end
end

-- show()
function scene:show( event )
	local sceneGroup = self.view
	local phase = event.phase
	if ( phase == "will" ) then
	elseif ( phase == "did" ) then
	end
end

-- hide()
function scene:hide( event )
	local sceneGroup = self.view
	local phase = event.phase
	if ( phase == "will" ) then
	elseif ( phase == "did" ) then
		composer.removeScene("shoppingCart")
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