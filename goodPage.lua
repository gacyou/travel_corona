-----------------------------------------------------------------------------------------
--
-- goodPage.lua
--
-----------------------------------------------------------------------------------------
local composer = require ("composer")
local widget = require ("widget")
local mainTabBar = require ("mainTabBar")
local getFont = require("setFont")
local json = require("json")
local myutf8 = require("myutf8")
local optionsTable = require("optionsTable")

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

local mainTabBarHeight = composer.getVariable("mainTabBarHeight")
local mainTabBarY = composer.getVariable("mainTabBarY")

local isLogin
if (composer.getVariable("isLogin")) then 
	isLogin = composer.getVariable("isLogin")
else
	isLogin = false
end

local ceil = math.ceil
local floor = math.floor

local scrollView = {}
local base = {}
local shadow = {}
local btn = {}
local text = {}
local line = {}
local icon = {}
local arrow = {}
local setStatus = {}

local function split(str, pat)
	local t = {}  -- NOTE: use {n = 0} in Lua-5.0
	local fpat = "(.-)" .. pat
	local last_end = 1
	local s, e, cap = str:find(fpat, 1)
	while s do
		if s ~= 1 or cap ~= "" then
			table.insert(t,cap)
		end
		last_end = e+1
		s, e, cap = str:find(fpat, last_end)
	end
	if last_end <= #str then
		cap = str:sub(last_end)
		table.insert(t, cap)
	end
	return t
end

-- create()
function scene:create( event )
	local sceneGroup = self.view
	mainTabBar.myTabBarHidden()
	local getProductId = event.params.productId
	local urlGetFileNamePattern = "%a+://%w+%.%w+[%.%w]*%:?%d*[/%w]*/(.+%.%a+)"
	local coverGroup = display.newGroup()
	local coverBase = display.newRect( coverGroup, cx, cy, screenW+ox+ox, screenH+oy+oy )
	coverBase:setFillColor( 0, 0, 0, 0.2 )
	coverBase:addEventListener("touch", function () return true; end)
	local coverSpinner = widget.newSpinner({
		id = "coverSpinner",
		x = cx,
		y = cy,
	})
	coverGroup:insert(coverSpinner)
	coverSpinner:scale( 0.6, 0.6 )
	coverSpinner:start()

	local function networkListener( event )
		if ( event.isError ) then
			print( "Network error!")
        else
			--print ("RESPONSE: "..event.response)
			local decodedData = json.decode(event.response)
			--for k,v in pairs(decodedData) do
			--	print(k)
			--end
			--print(decodedData["desc"])
		-- scrollViewListener
			local backBtnNum, backArrowWhite, backArrowBlue, cartWhite, cartBlue
			local function scrollListener( event )
				local phase = event.phase
				local x,y = event.target:getContentPosition()
				if ( phase == "moved" ) then
					if (y > -90) then
						shadow["title"]:setFillColor( 1, 1, 1, 0)
						btn["dropDown"].isVisible = false
						text["title"].isVisible = false
					end
					if (y <= -90) then 
						shadow["title"]:setFillColor( 1, 1, 1, 0.2)
						btn["dropDown"].isVisible = false
						text["title"].isVisible = false
					end
					if (y < -95) then 
						shadow["title"]:setFillColor( 1, 1, 1, 0.3)
						btn["dropDown"].isVisible = false
						text["title"].isVisible = false
					end
					if (y < -100) then 
						shadow["title"]:setFillColor( 1, 1, 1, 0.4)
						btn["dropDown"].isVisible = false
						text["title"].isVisible = false
					end
					if (y < -105) then 
						shadow["title"]:setFillColor( 1, 1, 1, 0.5)
						btn["dropDown"].isVisible = false
						text["title"].isVisible = false
					end
					if (y < -110) then 
						shadow["title"]:setFillColor( 1, 1, 1, 0.6)
						btn["dropDown"].isVisible = false
						text["title"].isVisible = false
					end
					if (y < -115) then 
						shadow["title"]:setFillColor( 1, 1, 1, 0.8)
						btn["dropDown"].isVisible = false
						text["title"].isVisible = false
					end
					if (y < -120) then
						shadow["title"]:setFillColor( 1, 1, 1, 1)
						btn["dropDown"].isVisible = true
						text["title"].isVisible = true
					end
					if (y < -105) then
						--返回按鍵變成藍色
						backArrowWhite.isVisible = false
						backArrowBlue.isVisible = true
						--購物車按鍵變成藍色
						cartWhite.isVisible = false
						cartBlue.isVisible = true
					else
						--返回按鍵變成白色
						backArrowBlue.isVisible = false
						backArrowWhite.isVisible = true
						--購物車按鍵變成白色
						cartBlue.isVisible = false
						cartWhite.isVisible = true
					end
				end
			end
		-- 背景拖曳用scrollView
			scrollView["background"] = widget.newScrollView({
					id = "backgrondScrollview",
					width = screenW+ox+ox,
					height = screenH+oy+oy-mainTabBarHeight,
					backgroundColor = backgroundColor,
					horizontalScrollDisabled = true,
					isBounceEnabled = false,
					listener = scrollListener,
				})
			sceneGroup:insert(scrollView["background"])
			scrollView["background"].anchorY = 0
			scrollView["background"].x = -ox+scrollView["background"].contentWidth*0.5
			scrollView["background"].y = -oy	
		------------------- 抬頭元件 -------------------
		-- 抬頭陰影
			shadow["title"] = display.newImageRect("assets/shadow0205.png", screenW+ox+ox, ceil(200*hRate))
			sceneGroup:insert(shadow["title"])
			shadow["title"].x = cx
			shadow["title"].y = -oy+shadow["title"].contentHeight*0.5
			shadow["title"]:setFillColor( 1, 1, 1, 0)
		-- 返回按鈕圖片
		-- 藍色箭頭
			backArrowBlue = display.newImage( sceneGroup, "assets/btn-back-b.png",-ox+ceil(35*wRate), -oy+(shadow["title"].contentHeight*0.9)*0.5)
			backArrowBlue.width = (backArrowBlue.width*0.07)
			backArrowBlue.height = (backArrowBlue.height*0.07)
			backArrowBlue.anchorX = 0
			backArrowBlue.anchorX = 0
			backArrowBlue.isVisible = false
			local backArrowNum = sceneGroup.numChildren
		-- 白色箭頭
			backArrowWhite = display.newImage( sceneGroup, "assets/btn-back-w.png",-ox+ceil(35*wRate), -oy+(shadow["title"].contentHeight*0.9)*0.5)
			backArrowWhite.width = (backArrowWhite.width*0.07)
			backArrowWhite.height = (backArrowWhite.height*0.07)
			backArrowWhite.anchorX = 0
		-- 返回按鈕
			btn["back"] = widget.newButton({
				id = "backBtn",
				x = backArrowWhite.x+backArrowWhite.contentWidth*0.5,
				y = backArrowWhite.y,
				defaultFile = "assets/transparent.png",
				--shape = "rect",
				width = screenW*0.1,
				height = shadow["title"].contentHeight,
				onRelease = function ()
					options = { time = 200, effect = "fade"}
					composer.gotoScene("homePage", options)
					return true
				end,
			})
			sceneGroup:insert(backArrowNum,btn["back"])
		-- 購物車按鈕圖片
		-- 藍色
			cartBlue = display.newImage( sceneGroup, "assets/btn-cart-b.png",-ox+shadow["title"].contentWidth-ceil(50*wRate), btn["back"].y)
			cartBlue.width = (cartBlue.width*0.07)
			cartBlue.height = (cartBlue.height*0.07)
			cartBlue.anchorX = 1
			cartBlue.isVisible = false
			local cartNum = sceneGroup.numChildren
		-- 白色	
			cartWhite = display.newImage( sceneGroup, "assets/btn-cart-w.png",-ox+shadow["title"].contentWidth-ceil(50*wRate), btn["back"].y)
			cartWhite.width = (cartWhite.width*0.07)
			cartWhite.height = (cartWhite.height*0.07)
			cartWhite.anchorX = 1
		-- 購物車按鈕
			btn["cart"] = widget.newButton({
				id = "cartBtn",
				x = cartWhite.x-cartWhite.contentWidth*0.5,
				y = cartWhite.y,
				defaultFile = "assets/transparent.png",
				--shape = "rect",
				width = screenW*0.1,
				height = shadow["title"].contentHeight,
				onRelease = function ()
					options = { time = 200, effect = "fade"}
					composer.gotoScene("shoppingCart", options)
				end,
			})
			sceneGroup:insert(cartNum,btn["cart"])
			btn["cart"]:setFillColor(1,0,0,0.3)
		-- 下拉式按鈕
			btn["dropDown"] = widget.newButton({
				id = "dropDownBtn",
				x = cartWhite.x-cartWhite.contentWidth-ceil(40*wRate),
				y = btn["cart"].y,
				width = 280,
				height = 220,
				defaultFile = "assets/btn-list.png",		
			})
			sceneGroup:insert(btn["dropDown"])
			btn["dropDown"].width = btn["dropDown"].width*0.07
			btn["dropDown"].height = btn["dropDown"].height*0.07
			btn["dropDown"].anchorX = 1
			btn["dropDown"].isVisible = false
			setStatus["dropDownList"] = "up"
		-- 下拉式選單
		-- 選單邊界
			local listBaseHeight = screenH/16
			local listOption = { "行程介紹", "注意事項", "如何使用", "常見問題"}
			local titleListBoundary = display.newContainer( screenW+ox+ox, listBaseHeight*#listOption+listBaseHeight*0.3)
			sceneGroup:insert(titleListBoundary)
			titleListBoundary.anchorY = 0
			titleListBoundary.x = cx 
			titleListBoundary.y = shadow["title"].y+shadow["title"].contentHeight*0.9*0.5
			titleListBoundary.anchorChildren = false
		-- 選單監聽事件
			local nowTarget, prevTarget, targetSelected,titleListGroup
			local listText = {}
			local function listListener( event )
				local phase = event.phase
				if (phase == "began" or phase == "moved") then
					if (nowTarget == nil and prevTarget == nil) then
						-- 第一次選擇選項，選項字體跟背景變色
						event.target:setFillColor( 0, 0, 0, 0.1)
						listText[event.target.id]:setFillColor(unpack(subColor2))
						nowTarget = event.target
						targetSelected = true
					end
					--[[
					if (event.target == nowTarget) then
						-- for moved event
						event.target:setFillColor( 0, 0, 0, 0.1)
						listText[event.target.id]:setFillColor(unpack(subColor2))
					end]]
					if (event.target ~= nowTarget) then
						-- 移動到新的選項
						prevTarget = nowTarget
						prevTarget:setFillColor(1)
						listText[prevTarget.id]:setFillColor(unpack(wordColor))
						
						event.target:setFillColor( 0, 0, 0, 0.1)
						listText[event.target.id]:setFillColor(unpack(subColor2))
						nowTarget = event.target
					end
				end
				if( phase == "ended" ) then 
					setStatus["dropDownList"] = "up"
					transition.to(titleListGroup,{ y = -titleListBoundary.contentHeight, time = 0})
					--timer.performWithDelay(300, function() titleGroup.isVisible = false ; end)
					timer.performWithDelay(0, function() titleListBoundary.isVisible = false ; end)
					timer.performWithDelay(0, function() 
						nowTarget:setFillColor(1)
						listText[nowTarget.id]:setFillColor(unpack(wordColor))
						local yPosition
						if (listText[nowTarget.id].text == text["introduced"].text) then
							yPosition = base["introducedTop"].y-shadow["title"].contentHeight
						elseif (listText[nowTarget.id].text == text["caution"].text) then
							yPosition = base["cautionTop"].y-shadow["title"].contentHeight
						elseif (listText[nowTarget.id].text == text["howToUse"].text) then
							yPosition = base["howToUseTop"].y-shadow["title"].contentHeight
						elseif (listText[nowTarget.id].text == text["question"].text) then
							yPosition = base["questionTop"].y-shadow["title"].contentHeight
						end
						scrollView["background"]:scrollToPosition({
								y = -yPosition,
								time = 0
							})
						nowTarget = nil
						prevTarget = nil
						targetSelected = false
						end)
				end
				return true
			end
		-- 選單內容
			titleListGroup = display.newGroup()
			titleListBoundary:insert(titleListGroup)
			shadow["titleList"] = display.newImageRect("assets/shadow-320480-paper.png", titleListBoundary.contentWidth, titleListBoundary.contentHeight)
			titleListGroup:insert(shadow["titleList"])
			shadow["titleList"].y = shadow["titleList"].contentHeight*0.5
			for i=1,#listOption do
				base["dropDown"] = display.newRect(titleListGroup, 0, 0, shadow["titleList"].contentWidth*0.95, listBaseHeight)
				base["dropDown"].id = i
				base["dropDown"].y = (base["dropDown"].contentHeight*0.5)*i+(base["dropDown"].contentHeight*0.5)*(i-1)
				base["dropDown"]:addEventListener("touch", listListener)
				listText[i] = display.newText({
					text = listOption[i],
					font = getFont.font,
					fontSize = 14,
				})
				titleListGroup:insert(listText[i])
				listText[i]:setFillColor(unpack(wordColor))
				listText[i].x = base["dropDown"].x
				listText[i].y = base["dropDown"].y
			end
			titleListGroup.y = -titleListBoundary.contentHeight
			titleListBoundary.isVisible = false
		-- 下拉式選單按鈕監聽事件
			local function dropDownBtnListener( event )
				local phase = event.phase
				if (phase == "ended") then 
					if (setStatus["dropDownList"] == "down") then 
						setStatus["dropDownList"] = "up"
						transition.to(titleListGroup,{ y = -titleListBoundary.contentHeight, time = 200})
						--timer.performWithDelay(210, function() titleListGroup.isVisible = false ;end)
						timer.performWithDelay(210, function() titleListBoundary.isVisible = false ;end)
					else
						setStatus["dropDownList"] = "down"
						titleListBoundary.isVisible = true
						--titleListGroup.isVisible = true
						transition.to(titleListGroup,{ y = 0, time = 200})
					end
				end
			end
			btn["dropDown"]:addEventListener("touch",dropDownBtnListener)
		-- 抬頭文字
			text["title"] = display.newText({
				text = myutf8.textToUtf8( decodedData["title"], 12),
				height = 0,
				font = getFont.font,
				fontSize = 14,
			})
			sceneGroup:insert(text["title"])
			text["title"]:setFillColor(unpack(wordColor))
			text["title"].anchorX = 0
			text["title"].x = backArrowWhite.x+backArrowWhite.contentWidth+ceil(40*wRate)
			text["title"].y = backArrowWhite.y
			text["title"].isVisible = false
			--if (string.len(text["title"].text) > 30) then
			--	text["title"].text = text["title"].text:sub(1,30).."..."
			--end
		------------------- 購物按鈕列 -------------------
		-- 我的最愛
			base["buy"] = display.newRect(sceneGroup, cx, mainTabBarY, screenW+ox+ox, mainTabBarHeight)
			--base["buy"]:setFillColor( 1, 0, 1, 0.3)
			icon["myFavorite"] = display.newImageRect("assets/heart-personalcenter.png", 280, 240)
			sceneGroup:insert(icon["myFavorite"])
			icon["myFavorite"].anchorX = 0
			icon["myFavorite"].anchorY = 1
			icon["myFavorite"].width = icon["myFavorite"].width*0.1
			icon["myFavorite"].height = icon["myFavorite"].height*0.1
			icon["myFavorite"].x = ceil(35*wRate)
			icon["myFavorite"].y = screenH+oy-ceil(56*hRate)	
		-- 加入購物車
			btn["addCart"] = widget.newButton({
					id = "addCartBtn",
					label = "加入購物車",
					labelColor = { default = { 1, 1, 1}, over = { 1, 1, 1, 0.6} },
					labelAlign = "center",
					font = getFont.font,
					fontSize = 18,
					defaultFile = "assets/btn-addtocart.png",
					width = screenW*0.4,
					height = screenH/12,
					onRelease = function ()
						if ( isLogin == false) then
							native.showAlert( "登入提醒", "尚未登入或是登入逾時，是否進行登入", { "是", "否"}, 
								function (event)
									if (event.action == "clicked") then
										local index = event.index
										if ( index == 1) then
											options = {
												params = {
													productId = getProductId,
													backScene = "goodPage",
												}
											}
											composer.gotoScene("LN_login", options)
										end
									end
								end)
						else
							local setPrice
							if ( decodedData["discountTwd"] ~= 0 ) then
								setPrice = decodedData["discountTwd"]
							else
								setPrice = decodedData["twd"]
							end
							print(setPrice)
							options = {
								params = {
									objectId = "N/A",
									productTitle = decodedData["title"],
									productId = getProductId,
									singlePrice = setPrice,
									productAmount = 1,
									fromScene = "goodPage",
									orderDate = os.date("%Y").."/"..os.date("%m").."/"..os.date("%d"),
								}
							}
							composer.gotoScene("orderOptions", options)
						end
					end,
				})
			sceneGroup:insert(btn["addCart"])
			btn["addCart"].anchorX = 0
			btn["addCart"].x = icon["myFavorite"].x + icon["myFavorite"].contentWidth + ceil(20*wRate)
			btn["addCart"].y = mainTabBarY
		-- 立即預定
			btn["book"] = widget.newButton({
					id = "bookBtn",
					label = "立即預訂",
					labelColor = { default = { 1, 1, 1}, over = { 1, 1, 1} },
					labelAlign = "center",
					font = getFont.font,
					fontSize = 18,
					defaultFile = "assets/btn-order.png",
					width = screenW*0.4,
					height = screenH/12,
				})
			btn["book"].anchorX = 0
			btn["book"].x = btn["addCart"].x + btn["addCart"].contentWidth + ceil(15*wRate)
			btn["book"].y = mainTabBarY
			sceneGroup:insert(btn["book"])
		------------------- backgroundScrollView元件 -------------------
		------------------- 主圖(影音)+標題+副標題 -------------------
		-- 放產品圖或是影音的位置
			local goodsGroup = display.newGroup()
			scrollView["background"]:insert(goodsGroup)
			base["titleVision"] = display.newRect( scrollView["background"].contentWidth*0.5, 0, scrollView["background"].contentWidth, screenH*0.35)
			goodsGroup:insert(base["titleVision"])
			base["titleVision"].y = base["titleVision"].contentHeight*0.5
			local function picNetworkListener(event)
				if ( event.isError ) then
					print( "Network error! -- Download Failed")
				elseif ( event.phase == "ended" ) then
					if ( event.target ) then
						coverGroup.isVisible = false
						coverSpinner:stop()
						goodsGroup:insert(event.target)
						event.target.x = base["titleVision"].x
						event.target.y = base["titleVision"].y
						event.target.width = base["titleVision"].contentWidth
						event.target.height = base["titleVision"].contentHeight
					end
				end
			end
			local picUrl = decodedData["itemImgs"][1]["url"]
			local picName = string.match(picUrl,urlGetFileNamePattern)
			display.loadRemoteImage( picUrl, "GET",	picNetworkListener,	picName, system.TemporaryDirectory )
		-- 商品描述區塊
		-- 陰影
			shadow["description"] = display.newImageRect("assets/shadow-4.png", 1079, 1881)
			goodsGroup:insert(shadow["description"])
			shadow["description"].width = math.floor((screenW+ox+ox)*1.1)
			shadow["description"].height = math.floor(screenH*0.43)
			shadow["description"].x = scrollView["background"].contentWidth*0.5
			shadow["description"].y = base["titleVision"].y+base["titleVision"].contentHeight*0.5+shadow["description"].contentHeight*0.5
		-- 白色區塊
			base["description"] = display.newRect( scrollView["background"].contentWidth*0.5, 0, scrollView["background"].contentWidth, ceil(shadow["description"].contentHeight*0.99))
			goodsGroup:insert(base["description"])
			base["description"].y = base["titleVision"].y+base["titleVision"].contentHeight*0.5+base["description"].contentHeight*0.5
		-- 商品名稱邊界
			base["nameOfGoodBounded"] = display.newRect( scrollView["background"].contentWidth*0.5, 0, base["description"].contentWidth*0.9, ceil(base["description"].contentHeight*0.24))
			goodsGroup:insert(base["nameOfGoodBounded"])
			base["nameOfGoodBounded"].y = base["titleVision"].y+base["titleVision"].contentHeight*0.5+ceil(40*hRate)+base["nameOfGoodBounded"].contentHeight*0.5
			base["nameOfGoodBounded"]:setFillColor( 1, 0, 0, 0.3)
			base["nameOfGoodBounded"].isVisible = false
		-- 顯示文字-商品名稱-主標題
			text["nameOfGood"] = display.newText ({
					text = decodedData["title"],
					width = base["nameOfGoodBounded"].contentWidth,
					height = base["nameOfGoodBounded"].contentHeight,
					font = getFont.font,
					fontSize = 16,
					align = "left",
				})
			goodsGroup:insert(text["nameOfGood"])
			text["nameOfGood"]:setFillColor(unpack(mainColor1))
			text["nameOfGood"].x = base["nameOfGoodBounded"].x
			text["nameOfGood"].y = base["nameOfGoodBounded"].y
		-- 商品內文邊界
			base["contentOfGoodBounded"] = display.newRect( scrollView["background"].contentWidth*0.5, 0, base["description"].contentWidth*0.9, math.floor(base["description"].contentHeight*0.31))
			goodsGroup:insert(base["contentOfGoodBounded"])
			base["contentOfGoodBounded"].y = base["nameOfGoodBounded"].y+base["nameOfGoodBounded"].contentHeight*0.5+base["contentOfGoodBounded"].contentHeight*0.5
			base["contentOfGoodBounded"]:setFillColor( 0, 1, 0, 0.3)
			base["contentOfGoodBounded"].isVisible = false
		-- 顯示文字-商品內文-副標題
			text["contentOfGood"] = display.newText ({
					text = decodedData["subTitle"],
					width =base["contentOfGoodBounded"].contentWidth,
					height = base["contentOfGoodBounded"].contentHeight,
					font = getFont.font,
					fontSize = 12,
					align = "left",
				})
			goodsGroup:insert(text["contentOfGood"])
			text["contentOfGood"]:setFillColor(unpack(wordColor))
			text["contentOfGood"].x = base["contentOfGoodBounded"].x
			text["contentOfGood"].y = base["contentOfGoodBounded"].y
		-- 商品區塊分隔線
			line["goodSeparated"] = display.newLine( 0, base["contentOfGoodBounded"].y+base["contentOfGoodBounded"].contentHeight*0.5, (screenW+ox+ox), base["contentOfGoodBounded"].y+base["contentOfGoodBounded"].contentHeight*0.5)
			goodsGroup:insert(line["goodSeparated"])
			line["goodSeparated"].strokeWidth = 1
			line["goodSeparated"]:setStrokeColor(unpack(separateLineColor))

		------------------- 商品價位區塊 -------------------
		-- 顯示文字-"NT$"
			text["NT"] = display.newText({
					text = "NT$",
					font = getFont.font,
					fontSize = 16,
				})
			goodsGroup:insert(text["NT"])
			text["NT"]:setFillColor(unpack(subColor2))
			text["NT"].anchorX = 0
			text["NT"].anchorY = 1
			text["NT"].x = ceil(49*wRate)
			text["NT"].y = line["goodSeparated"].y+ceil(32*hRate)+text["NT"].contentHeight
		-- 顯示文字-金額
			text["price"] = display.newText({
					text = decodedData["twd"],
					font = getFont.font,
					fontSize = 16,
				})
			goodsGroup:insert(text["price"])
			text["price"]:setFillColor(unpack(subColor2))
			text["price"].anchorX = 0
			text["price"].anchorY = 1
			text["price"].x = text["NT"].x+text["NT"].contentWidth+ceil(20*wRate)
			text["price"].y = text["NT"].y
		-- 顯示文字-組合價
		-- "/"
			local comboPriceGroup = display.newGroup()
			goodsGroup:insert(comboPriceGroup)
			text["slashLine"] = display.newText({
					text = "/",
					font = getFont.font,
					fontSize = 16,
				})
			comboPriceGroup:insert(text["slashLine"])
			text["slashLine"]:setFillColor(unpack(wordColor))
			text["slashLine"].anchorX = 0
			text["slashLine"].anchorY = 1
			text["slashLine"].x = text["price"].x+text["price"].contentWidth+ceil(10*wRate)
			text["slashLine"].y = text["price"].y
		-- "組合價"
			text["combo"] = display.newText({
					text = "組合價 ",
					font = getFont.font,
					fontSize = 12,
				})
			comboPriceGroup:insert(text["combo"])
			text["combo"]:setFillColor(unpack(subColor1))
			text["combo"].anchorX = 0
			text["combo"].anchorY = 1
			text["combo"].x = text["slashLine"].x+text["slashLine"].contentWidth+ceil(15*wRate)
			text["combo"].y = text["slashLine"].y
		-- 組合價金額
			text["comboPrice"] = display.newText({
					text = decodedData["discountTwd"],
					font = getFont.font,
					fontSize = 12,
				})
			comboPriceGroup:insert(text["comboPrice"])
			text["comboPrice"]:setFillColor(unpack(subColor1))
			text["comboPrice"].anchorX = 0
			text["comboPrice"].anchorY = 1
			text["comboPrice"].x = text["combo"].x+text["combo"].contentWidth
			text["comboPrice"].y = text["combo"].y
			if ( decodedData["discountTwd"] == 0 ) then
				comboPriceGroup.isVisible = false
			end
		-- 按鈕-組合價提示
			btn["comboInfo"] = widget.newButton({
				id = "comboInfoBtn",
				x = text["comboPrice"].x+text["comboPrice"].contentWidth+ceil(15*wRate),
				y = text["comboPrice"].y-text["comboPrice"].contentHeight*0.5,
				width = 240,
				height = 240,
				defaultFile = "assets/btn-informationicon.png",
				onPress = onBtnListener,
			})
			comboPriceGroup:insert(btn["comboInfo"])
			btn["comboInfo"].width = btn["comboInfo"].width*0.05
			btn["comboInfo"].height = btn["comboInfo"].height*0.05
			btn["comboInfo"].anchorX = 0
		-- 圖示-參加熱情
			icon["passion"] = display.newImageRect("assets/tag-join.png", 221, 280)
			goodsGroup:insert(icon["passion"])
			icon["passion"].width = icon["passion"].width*0.06
			icon["passion"].height = icon["passion"].height*0.06
			icon["passion"].anchorX = 0
			icon["passion"].anchorY = 1
			icon["passion"].x = text["NT"].x
			icon["passion"].y = base["description"].y+base["description"].contentHeight*0.5-ceil(50*hRate)
		-- 顯示文字-參加人數+"人參加過"
			local hasJoinedPeople = "100k"
			text["joinedPeople"] = display.newText({
					text = hasJoinedPeople.."人參加過",
					font = getFont.font,
					fontSize = 12,
				})
			goodsGroup:insert(text["joinedPeople"])
			text["joinedPeople"]:setFillColor(unpack(wordColor))
			text["joinedPeople"].anchorX = 0
			text["joinedPeople"].anchorY = 1
			text["joinedPeople"].x = icon["passion"].x+icon["passion"].contentWidth+ceil(15*wRate)
			text["joinedPeople"].y = icon["passion"].y
		-- 圖示-可使用折扣券
			icon["discount"] = display.newImageRect("assets/forapp-tag-coupon.png", 200, 156)
			goodsGroup:insert(icon["discount"])
			icon["discount"].width = icon["discount"].width*0.3
			icon["discount"].height = icon["discount"].height*0.3
			icon["discount"].anchorX = 1
			icon["discount"].anchorY = 1
			icon["discount"].x = (screenW+ox+ox)-ceil(46*wRate)
			icon["discount"].y = base["description"].y+base["description"].contentHeight*0.5
		-- 圖示-可使用積分
			icon["point"] = display.newImageRect("assets/forapp-tag-point.png", 200, 156)
			goodsGroup:insert(icon["point"])
			icon["point"].width = icon["point"].width*0.3
			icon["point"].height = icon["point"].height*0.3	
			icon["point"].anchorX = 1
			icon["point"].anchorY = 1
			icon["point"].x = icon["discount"].x-icon["discount"].contentWidth-ceil(30*wRate)
			icon["point"].y = icon["discount"].y
		------------------- 商品詳細說明區塊 -------------------
		-- 白色區塊
			base["detail"] = display.newRect( scrollView["background"].contentWidth*0.5, 0, scrollView["background"].contentWidth, math.floor(screenH*0.45))
			goodsGroup:insert(base["detail"])
			base["detail"].y = base["description"].y+base["description"].contentHeight*0.5+ceil(35*hRate)+base["detail"].contentHeight*0.5
			--base["detail"]:setFillColor( 1, 0, 0, 0.3)
		-- 圖示-modify.png
			icon["modify"] = display.newImageRect("assets/modify.png", 38, 42)
			goodsGroup:insert(icon["modify"])
			icon["modify"].anchorX = 0
			icon["modify"].anchorY = 0
			icon["modify"].width = icon["modify"].width*0.4
			icon["modify"].height = icon["modify"].height*0.4
			icon["modify"].x = ceil(49*wRate)
			icon["modify"].y = base["description"].y+base["description"].contentHeight*0.5+ceil(35*hRate)+ceil(45*hRate)
		-- 顯示文字-行程可退改與否
			text["modified"] = display.newText({
					text = "行程可退改與否",
					font = getFont.font,
					fontSize = 12,
				})
			goodsGroup:insert(text["modified"])
			text["modified"]:setFillColor(unpack(wordColor))
			text["modified"].anchorX = 0
			text["modified"].x = icon["modify"].x+icon["modify"].contentWidth+ceil(10*wRate)
			text["modified"].y = icon["modify"].y+icon["modify"].contentHeight*0.5
		-- 圖示-time.png
			icon["time"] = display.newImageRect("assets/time.png", 38, 42)
			goodsGroup:insert(icon["time"])
			icon["time"].anchorX = 0
			icon["time"].anchorY = 0
			icon["time"].width = icon["time"].width*0.4
			icon["time"].height = icon["time"].height*0.4
			icon["time"].x = ceil(49*wRate)
			icon["time"].y = icon["modify"].y+icon["modify"].contentHeight+ceil(35*hRate)
		-- 顯示文字-行程時長
			text["time"] = display.newText({
					text = "行程時長",
					font = getFont.font,
					fontSize = 12,
				})
			goodsGroup:insert(text["time"])
			text["time"]:setFillColor(unpack(wordColor))
			text["time"].anchorX = 0
			text["time"].x = icon["time"].x+icon["time"].contentWidth+ceil(10*wRate)
			text["time"].y = icon["time"].y+icon["time"].contentHeight*0.5
		-- 圖示-locale.png
			icon["locale"] = display.newImageRect("assets/locale.png", 38, 42)
			goodsGroup:insert(icon["locale"])
			icon["locale"].anchorX = 0
			icon["locale"].anchorY = 0
			icon["locale"].width = icon["locale"].width*0.4
			icon["locale"].height = icon["locale"].height*0.4
			icon["locale"].x = ceil(49*wRate)
			icon["locale"].y = icon["time"].y+icon["time"].contentHeight+ceil(35*hRate)
		-- 顯示文字-導覽語系
			text["locale"] = display.newText({
					text = "導覽語系",
					font = getFont.font,
					fontSize = 12,
				})
			goodsGroup:insert(text["locale"])
			text["locale"]:setFillColor(unpack(wordColor))
			text["locale"].anchorX = 0
			text["locale"].x = icon["locale"].x+icon["locale"].contentWidth+ceil(10*wRate)
			text["locale"].y = icon["locale"].y+icon["locale"].contentHeight*0.5
		-- 圖示-guide.png
			icon["guide"] = display.newImageRect("assets/guide.png", 38, 42)
			goodsGroup:insert(icon["guide"])
			icon["guide"].anchorX = 0
			icon["guide"].anchorY = 0
			icon["guide"].width = icon["guide"].width*0.4
			icon["guide"].height = icon["guide"].height*0.4
			icon["guide"].x = ceil(49*wRate)
			icon["guide"].y = icon["locale"].y+icon["locale"].contentHeight+ceil(35*hRate)
		-- 顯示文字-導覽類型
			text["guide"] = display.newText({
					text = "導覽類型",
					font = getFont.font,
					fontSize = 12,
				})
			goodsGroup:insert(text["guide"])
			text["guide"]:setFillColor(unpack(wordColor))
			text["guide"].anchorX = 0
			text["guide"].x = icon["guide"].x+icon["guide"].contentWidth+ceil(10*wRate)
			text["guide"].y = icon["guide"].y+icon["guide"].contentHeight*0.5
		-- 圖示-departure.png
			icon["departure"] = display.newImageRect("assets/departure.png", 38, 42)
			goodsGroup:insert(icon["departure"])
			icon["departure"].anchorX = 0
			icon["departure"].anchorY = 0
			icon["departure"].width = icon["departure"].width*0.4
			icon["departure"].height = icon["departure"].height*0.4
			icon["departure"].x = ceil(49*wRate)
			icon["departure"].y = icon["guide"].y+icon["guide"].contentHeight+ceil(35*hRate)
		-- 顯示文字-成團條件
			text["departure"] = display.newText({
					text = "成團條件",
					font = getFont.font,
					fontSize = 12,
				})
			goodsGroup:insert(text["departure"])
			text["departure"]:setFillColor(unpack(wordColor))
			text["departure"].anchorX = 0
			text["departure"].x = icon["departure"].x+icon["departure"].contentWidth+ceil(10*wRate)
			text["departure"].y = icon["departure"].y+icon["departure"].contentHeight*0.5
		-- 圖示-traffic.png
			icon["traffic"] = display.newImageRect("assets/traffic.png", 38, 42)
			goodsGroup:insert(icon["traffic"])
			icon["traffic"].anchorX = 0
			icon["traffic"].anchorY = 0
			icon["traffic"].width = icon["traffic"].width*0.4
			icon["traffic"].height = icon["traffic"].height*0.4
			icon["traffic"].x = ceil(49*wRate)
			icon["traffic"].y = icon["departure"].y+icon["departure"].contentHeight+ceil(35*hRate)
		-- 顯示文字-交通方式
			text["traffic"] = display.newText({
					text = "交通方式",
					font = getFont.font,
					fontSize = 12,
				})
			goodsGroup:insert(text["traffic"])
			text["traffic"]:setFillColor(unpack(wordColor))
			text["traffic"].anchorX = 0
			text["traffic"].x = icon["traffic"].x+icon["traffic"].contentWidth+ceil(10*wRate)
			text["traffic"].y = icon["traffic"].y+icon["traffic"].contentHeight*0.5
		-- 圖示-ticket.png
			icon["ticket"] = display.newImageRect("assets/ticket.png", 38, 42)
			goodsGroup:insert(icon["ticket"])
			icon["ticket"].anchorX = 0
			icon["ticket"].anchorY = 0
			icon["ticket"].width = icon["ticket"].width*0.4
			icon["ticket"].height = icon["ticket"].height*0.4
			icon["ticket"].x = ceil(49*wRate)
			icon["ticket"].y = icon["traffic"].y+icon["traffic"].contentHeight+ceil(35*hRate)
		-- 顯示文字-票券類型
			text["ticket"] = display.newText({
					text = "票券類型",
					font = getFont.font,
					fontSize = 12,
				})
			goodsGroup:insert(text["ticket"])
			text["ticket"]:setFillColor(unpack(wordColor))
			text["ticket"].anchorX = 0
			text["ticket"].x = icon["ticket"].x+icon["ticket"].contentWidth+ceil(10*wRate)
			text["ticket"].y = icon["ticket"].y+icon["ticket"].contentHeight*0.5
		-- 圖示-confirm.png
			icon["confirm"] = display.newImageRect("assets/confirm.png", 38, 42)
			goodsGroup:insert(icon["confirm"])
			icon["confirm"].anchorX = 0
			icon["confirm"].anchorY = 0
			icon["confirm"].width = icon["confirm"].width*0.4
			icon["confirm"].height = icon["confirm"].height*0.4
			icon["confirm"].x = ceil(49*wRate)
			icon["confirm"].y = icon["ticket"].y+icon["ticket"].contentHeight+ceil(35*hRate)
		-- 顯示文字-回覆訂購結果
			text["confirm"] = display.newText({
					text = "回覆訂購結果",
					font = getFont.font,
					fontSize = 12,
				})
			goodsGroup:insert(text["confirm"])
			text["confirm"]:setFillColor(unpack(wordColor))
			text["confirm"].anchorX = 0
			text["confirm"].x = icon["confirm"].x+icon["confirm"].contentWidth+ceil(10*wRate)
			text["confirm"].y = icon["confirm"].y+icon["confirm"].contentHeight*0.5
		-- 詳細說明區塊分隔線
			line["detail"] = display.newLine( 0, icon["confirm"].y+icon["confirm"].contentHeight+ceil(35*hRate), (screenW+ox+ox), icon["confirm"].y+icon["confirm"].contentHeight+ceil(35*hRate))
			goodsGroup:insert(line["detail"])
			line["detail"].strokeWidth = 1
			line["detail"]:setStrokeColor(unpack(separateLineColor))
		-- 間距參數
			local topHeight = ceil(35*hRate)
			local paddingHeight = floor(40*hRate)
			local bottomHeight = floor(45*hRate)
			local num = {}
		-- 詳細說明區塊分隔線商品說明上端留白
			base["detailTop"] = display.newRect( scrollView["background"].contentWidth*0.5, 0, scrollView["background"].contentWidth, topHeight)
			goodsGroup:insert(base["detailTop"])
			base["detailTop"].y = line["detail"].y+base["detailTop"].contentHeight*0.5
			--base["detailTop"]:setFillColor(1,0,0,0.3)
		-- 詳細說明區塊分隔線商品說明
			--print(decodedData["context"])
			local result = split(decodedData["context"], "|")
			local contextBaseY = base["detailTop"].y+base["detailTop"].contentHeight*0.5
			local contextBaseHeight = screenH/20
			for i=1,#result do
				-- 白底
				base["context"] = display.newRect( goodsGroup, base["detailTop"].x, contextBaseY, scrollView["background"].contentWidth, contextBaseHeight)
				base["context"].anchorY = 0
				-- 點點
				text["contextPoint"] = display.newText({
					parent = goodsGroup,
					text = "‧",
					font = getFont.font,
					fontSize = 12,
					x = icon["confirm"].x,
					y = base["context"].y,
				})
				text["contextPoint"]:setFillColor(unpack(wordColor))
				text["contextPoint"].anchorX = 0
				text["contextPoint"].anchorY = 0
				-- 顯示文字說明
				text["context"] = display.newText({
					parent = goodsGroup,
					text = result[i],
					font = getFont.font,
					fontSize = 12,
					width = base["context"].contentWidth*0.9,
					height = 0,
					x = text["contextPoint"].x+text["contextPoint"].contentWidth+ceil(10*wRate),
					y = text["contextPoint"].y,
				})
				text["context"]:setFillColor(unpack(wordColor))
				text["context"].anchorX = 0
				text["context"].anchorY = 0
				if ( base["context"].contentHeight ~= text["context"].contentHeight) then
					base["context"].height = text["context"].contentHeight
					contextBaseHeight = base["context"].contentHeight
				end
				contextBaseY = contextBaseY+contextBaseHeight
			end
		-- 詳細說明區塊分隔線商品說明底部留白
			base["detailBottom"] = display.newRect(base["context"].x, base["context"].y+base["context"].contentHeight+bottomHeight*0.5, base["context"].contentWidth, bottomHeight)
			goodsGroup:insert(base["detailBottom"])
		-- 行程介紹 --處理html
		-- 置頂白色區域
			base["introducedTop"] = display.newRect( scrollView["background"].contentWidth*0.5, 0, scrollView["background"].contentWidth, topHeight)
			--if (hasAddtion ==  true) then 
				base["introducedTop"].y = base["detailBottom"].y+base["detailBottom"].contentHeight*0.5+ceil(35*hRate)+topHeight*0.5
			--else
				--base["introducedTop"].y = base["orderBottom"].y+base["orderBottom"].contentHeight*0.5+ceil(35*hRate)+topHeight*0.5
			--end
			goodsGroup:insert(base["introducedTop"])
		-- 圖示-小翅膀
			icon["introduced"] = display.newImageRect("assets/titleimg.png", 42, 40)
			goodsGroup:insert(icon["introduced"])
			icon["introduced"].anchorX = 0
			icon["introduced"].anchorY = 0
			icon["introduced"].width = icon["introduced"].width*0.4
			icon["introduced"].height = icon["introduced"].height*0.4
			icon["introduced"].x = ceil(30*wRate)
			icon["introduced"].y = base["introducedTop"].y + base["introducedTop"].contentHeight*0.5
			num["introducedIcon"] = goodsGroup.numChildren
		-- 顯示文字-"行程介紹"
			text["introduced"] = display.newText({
					text = "行程介紹",
					font = getFont.font,
					fontSize = 16,
				})
			goodsGroup:insert(text["introduced"])
			text["introduced"]:setFillColor(unpack(wordColor))
			text["introduced"].anchorX = 0
			text["introduced"].x = icon["introduced"].x+icon["introduced"].contentWidth+ceil(13*wRate)
			text["introduced"].y = icon["introduced"].y+icon["introduced"].contentHeight*0.5
		-- 白色背景
			base["introduced"] = display.newRect( scrollView["background"].contentWidth*0.5, text["introduced"].y, scrollView["background"].contentWidth, text["introduced"].contentHeight)
			goodsGroup:insert( num["introducedIcon"], base["introduced"])
		-- 與文字間隔的白色區域
			base["introducedPadding"] = display.newRect( scrollView["background"].contentWidth*0.5, base["introduced"].y+base["introduced"].contentHeight*0.5+paddingHeight*0.5, scrollView["background"].contentWidth, paddingHeight)
			goodsGroup:insert(base["introducedPadding"])
			--base["introducedPadding"]:setFillColor( 1, 0, 0, 0.3)
		-- 底部白色間距
			base["introducedBottom"] = display.newRect(base["introducedPadding"].x, base["introducedPadding"].y+base["introducedPadding"].contentHeight*0.5+bottomHeight*0.5, base["introducedPadding"].contentWidth, bottomHeight)
			goodsGroup:insert(base["introducedBottom"])
			--base["introducedBottom"]:setFillColor( 0, 1, 0, 0.3)
		
		-- 注意事項
		-- 置頂米色區域
			base["cautionTop"] = display.newRect( scrollView["background"].contentWidth*0.5, base["introducedBottom"].y + base["introducedBottom"].contentHeight*0.5+ceil(35*hRate)+topHeight*0.5, scrollView["background"].contentWidth, topHeight)
			goodsGroup:insert(base["cautionTop"])
			base["cautionTop"]:setFillColor( 255/255, 241/255, 214/255)
		-- 圖示-title-notice.png
			icon["caution"] = display.newImageRect("assets/title-notice.png", 240, 240)
			goodsGroup:insert(icon["caution"])
			icon["caution"].anchorX = 0
			icon["caution"].anchorY = 0
			icon["caution"].width = icon["caution"].width*0.08
			icon["caution"].height = icon["caution"].height*0.08
			icon["caution"].x = ceil(49*wRate)
			icon["caution"].y = base["cautionTop"].y + base["cautionTop"].contentHeight*0.5
			num["cautionIcon"] = goodsGroup.numChildren
		-- 顯示文字-"注意事項"
			text["caution"] = display.newText({
					text = "注意事項",
					font = getFont.font,
					fontSize = 16,
				})
			goodsGroup:insert(text["caution"])
			text["caution"]:setFillColor(unpack(subColor2))
			text["caution"].anchorX = 0
			text["caution"].x = icon["caution"].x+icon["caution"].contentWidth+ceil(13*wRate)
			text["caution"].y = icon["caution"].y+icon["caution"].contentHeight*0.5
		-- 米色背景
			base["caution"] = display.newRect( scrollView["background"].contentWidth*0.5, text["caution"].y, scrollView["background"].contentWidth, icon["caution"].contentHeight)
			goodsGroup:insert( num["cautionIcon"], base["caution"])
			base["caution"]:setFillColor( 255/255, 241/255, 214/255)
		-- 與文字間隔的米色區域
			base["cautionPadding"] = display.newRect( scrollView["background"].contentWidth*0.5, base["caution"].y+base["caution"].contentHeight*0.5+paddingHeight*0.5, scrollView["background"].contentWidth, paddingHeight)
			goodsGroup:insert(base["cautionPadding"])
			base["cautionPadding"]:setFillColor( 255/255, 241/255, 214/255)
			--base["cautionPadding"]:setFillColor( 1, 0, 0, 0.3)
		-- 底部米色間距cautionPadding
			base["cautionBottom"] = display.newRect(base["cautionPadding"].x, base["cautionPadding"].y+base["cautionPadding"].contentHeight*0.5+bottomHeight*0.5, base["cautionPadding"].contentWidth, bottomHeight)
			goodsGroup:insert(base["cautionBottom"])
			base["cautionBottom"]:setFillColor( 255/255, 241/255, 214/255)

		-- 如何使用
		-- 置頂白色區域
			base["howToUseTop"] = display.newRect( scrollView["background"].contentWidth*0.5, base["cautionBottom"].y + base["cautionBottom"].contentHeight*0.5+ceil(35*hRate)+topHeight*0.5, scrollView["background"].contentWidth, topHeight)
			goodsGroup:insert(base["howToUseTop"])
		-- 圖示-小翅膀
			icon["howToUse"] = display.newImageRect("assets/titleimg.png", 42, 40)
			goodsGroup:insert(icon["howToUse"])
			icon["howToUse"].anchorX = 0
			icon["howToUse"].anchorY = 0
			icon["howToUse"].width = icon["howToUse"].width*0.4
			icon["howToUse"].height = icon["howToUse"].height*0.4
			icon["howToUse"].x = ceil(30*wRate)
			icon["howToUse"].y = base["howToUseTop"].y + base["howToUseTop"].contentHeight*0.5
			num["howToUseIcon"] = goodsGroup.numChildren
		-- 顯示文字-"如何使用"
			text["howToUse"] = display.newText({
					text = "如何使用",
					font = getFont.font,
					fontSize = 16,
				})
			goodsGroup:insert(text["howToUse"])
			text["howToUse"]:setFillColor(unpack(wordColor))
			text["howToUse"].anchorX = 0
			text["howToUse"].x = icon["howToUse"].x+icon["howToUse"].contentWidth+ceil(13*wRate)
			text["howToUse"].y = icon["howToUse"].y+icon["howToUse"].contentHeight*0.5
		-- 白色背景
			base["howToUse"] = display.newRect( scrollView["background"].contentWidth*0.5, text["howToUse"].y, scrollView["background"].contentWidth, text["howToUse"].contentHeight)
			goodsGroup:insert( num["howToUseIcon"], base["howToUse"])
		-- 與文字間隔的白色區域
			base["howToUsePadding"] = display.newRect( scrollView["background"].contentWidth*0.5, base["howToUse"].y+base["howToUse"].contentHeight*0.5+paddingHeight*0.5, scrollView["background"].contentWidth, paddingHeight)
			goodsGroup:insert(base["howToUsePadding"])
		-- 底部白色間距
			base["howToUseBottom"] = display.newRect(base["howToUsePadding"].x, base["howToUsePadding"].y+base["howToUsePadding"].contentHeight*0.5+bottomHeight*0.5, base["howToUsePadding"].contentWidth, bottomHeight)
			goodsGroup:insert(base["howToUseBottom"])

		-- 常見問題
		-- 置頂白色區域
			base["questionTop"] = display.newRect( scrollView["background"].contentWidth*0.5, base["howToUseBottom"].y + base["howToUseBottom"].contentHeight*0.5+ceil(35*hRate)+topHeight*0.5, scrollView["background"].contentWidth, topHeight)
			goodsGroup:insert(base["questionTop"])
		-- 圖示-小翅膀
			icon["question"] = display.newImageRect("assets/titleimg.png", 42, 40)
			goodsGroup:insert(icon["question"])
			icon["question"].anchorX = 0
			icon["question"].anchorY = 0
			icon["question"].width = icon["question"].width*0.4
			icon["question"].height = icon["question"].height*0.4
			icon["question"].x = ceil(30*wRate)
			icon["question"].y = base["questionTop"].y + base["questionTop"].contentHeight*0.5
			num["questionIcon"] = goodsGroup.numChildren
		-- 顯示文字-"常見問題"
			text["question"] = display.newText({
					text = "常見問題",
					font = getFont.font,
					fontSize = 16,
				})
			goodsGroup:insert(text["question"])
			text["question"]:setFillColor(unpack(wordColor))
			text["question"].anchorX = 0
			text["question"].x = icon["question"].x+icon["question"].contentWidth+ceil(13*wRate)
			text["question"].y = icon["question"].y+icon["question"].contentHeight*0.5
		-- 白色背景
			base["question"] = display.newRect( scrollView["background"].contentWidth*0.5, text["question"].y, scrollView["background"].contentWidth, text["question"].contentHeight)
			goodsGroup:insert( num["questionIcon"], base["question"])
		-- 與文字間隔的白色區域
			base["questionPadding"] = display.newRect( scrollView["background"].contentWidth*0.5, base["question"].y+base["question"].contentHeight*0.5+paddingHeight*0.5, scrollView["background"].contentWidth, paddingHeight)
			goodsGroup:insert(base["questionPadding"])
		-- 底部白色間距
			base["questionBottom"] = display.newRect(base["questionPadding"].x, base["questionPadding"].y+base["questionPadding"].contentHeight*0.5+bottomHeight*0.5, base["questionPadding"].contentWidth, bottomHeight)
			goodsGroup:insert(base["questionBottom"])
        end
	end 
	local url = optionsTable.getProductUrl..getProductId
	network.request( url, "GET", networkListener)
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
		composer.removeScene("goodPage")
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