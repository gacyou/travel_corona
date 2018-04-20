-----------------------------------------------------------------------------------------
--
-- homePageV2.lua
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

local scrollView = {}
local base = {}
local shadow = {}
local btn = {}
local text = {}
local textFiled = {}
local line = {}
local icon = {}
local picUrl = {}
local setStatus = {}
local rotationPlay
local setChangeScene = false
local isStart = false

local ceil = math.ceil
local floor = math.floor

-- create()
function scene:create( event )
	local sceneGroup = self.view
	mainTabBar.myTabBarShown()
	-- API POST 參數 --
	local headers = {}
	headers["Content-Type"] = "application/json"
	local body = "{\"lang\":\"zh_TW\"}"
	local parms = {}
	parms.headers = headers
	parms.body = body
	local urlGetFileNamePattern = "%a+://%w+%.%w+[%.%w]*%:?%d*[/%w]*/(.+%.%a+)"
	local hotSpotTable, themeTable, productTable = {}, {}, {}
	-- 讀取頁面 --
	-- 奮路鳥
		local coverGroup = display.newGroup()
		local welcomeBackGround = display.newImage( "assets/login-bg.png", cx, cy )
		welcomeBackGround:addEventListener("touch", function () return true; end)
		coverGroup:insert(welcomeBackGround)
		welcomeBackGround.width = screenW+ox+ox
		welcomeBackGround.height = screenH+oy+oy
	-- 圖示-login-logo.png
		local welcomeLogo = display.newImage( "assets/login-logo.png", cx, -oy+floor(362*hRate) )
		coverGroup:insert(welcomeLogo)
		welcomeLogo.width = welcomeLogo.width*0.1
		welcomeLogo.height = welcomeLogo.height*0.1
		welcomeLogo.anchorY = 0
	-- 顯示文字-"探索你的精彩旅程"
		local welcomeWord = display.newText({
			text = "探索你的精彩旅程",
			font = getFont.font,
			fontSize = 14,
			x = cx,
			y = welcomeLogo.y+welcomeLogo.contentHeight+floor(105*hRate)
		})
		coverGroup:insert(welcomeWord)
		welcomeWord:setFillColor(unpack(wordColor))
		welcomeWord.anchorY = 0
	-- 讀取條
		local progressView = widget.newProgressView({
			x = cx,
			y = cy*1.5,
			width = 220,
			isAnimated = true,
		})
		coverGroup:insert(progressView)
	local function hotSpotListener( event )
		if ( event.isError ) then
			print( "Network Error: "..event.response )
		else
			--print ("RESPONSE: "..event.response)
			local hotSpotTable = json.decode(event.response)
			local function themeListener( event )
				if ( event.isError ) then
					print( "Network Error: "..event.response )
				else
					--print ("RESPONSE: "..event.response)
					local themeTable = json.decode(event.response)
					
					finishCount = 0
					for i, _ in ipairs(themeTable) do
						local function getProductInfo( event )
							if ( event.isError ) then
								print( "Network Error: "..event.response )
							end
							if ( event.phase == "ended" ) then
								productTable[i] = json.decode(event.response)
								finishCount = finishCount + 1
								--[[if ( finishCount == #themeTable ) then
									for k,v in pairs(productTable[3]["itemImgs"][1]) do
										print(k,v)
									end
								end--]]
								if ( finishCount == #themeTable ) then
									local picUrl, productPicTable = {}, {}
									for i, _ in pairs( productTable ) do
										picUrl[i] = productTable[i]["itemImgs"][1].url
									end					
									------------------- 背景拖曳用scrollView -------------------
									-- backgroundScrollView 監聽事件
										setStatus["mainTabBar"] = "shown" 
										local function backgrondScrollviewListener( event )
											local phase = event.phase
											--print(event.limitReached)
											if (phase == "moved") then
												native.setKeyboardFocus(nil)
												if (event.direction == "up" and setStatus["mainTabBar"] == "shown") then
													mainTabBar.myTabBarScrollHidden()
													setStatus["mainTabBar"] = "hidden"
												end
												if (event.direction == "down" and setStatus["mainTabBar"] == "hidden") then
													mainTabBar.myTabBarScrollShown()
													setStatus["mainTabBar"] = "shown"
												end
											end
											if (event.limitReached) then
												mainTabBar.myTabBarScrollShown()
												setStatus["mainTabBar"] = "shown"
											end
											return true
										end
									-- 上下滑動的scrollView
										scrollView["background"] = widget.newScrollView({
											id = "backgrondScrollview",
											width = screenW+ox+ox,
											height = screenH+oy+oy,
											horizontalScrollDisabled = true,
											isBounceEnabled = false,
											backgroundColor = backgroundColor,
											listener = backgrondScrollviewListener,
										})
										sceneGroup:insert(scrollView["background"])
										scrollView["background"].anchorY = 0
										scrollView["background"].x = -ox+scrollView["background"].contentWidth*0.5
										scrollView["background"].y = -oy
									-- backgroundScrollView元件 --
										local bkgScrollViewGroup = display.newGroup()
										scrollView["background"]:insert(bkgScrollViewGroup)
										local bkgScrollViewCX = scrollView["background"].contentWidth*0.5
									------------------- 搜尋欄元件 -------------------
									-- 搜尋按鈕
										btn["search"] = widget.newButton({
											id = "searchBtn",
											x = -ox,
											y = -oy,
											defaultFile = "assets/btn-search.png",
											width = ceil(125*wRate),
											height = ceil(125*wRate),
										})
										sceneGroup:insert(btn["search"])
										btn["search"].anchorX = 0
										btn["search"].anchorY = 0
									-- 搜尋Bar背景
										base["search"] = display.newRect(sceneGroup, btn["search"].x+btn["search"].contentWidth, btn["search"].y, screenW+ox+ox-btn["search"].contentWidth, btn["search"].contentHeight)
										base["search"]:setFillColor( 1, 1, 1, 0.4)
										base["search"].anchorX = 0
										base["search"].anchorY = 0
									-- 搜尋Bar輸入欄位
										textFiled["search"] = native.newTextField( base["search"].x, base["search"].y, base["search"].contentWidth, floor(base["search"].contentHeight*0.7))
										textFiled["search"].y = textFiled["search"].y + (base["search"].contentHeight-textFiled["search"].contentHeight)*0.5
										sceneGroup:insert(textFiled["search"])
										textFiled["search"].anchorX = 0
										textFiled["search"].anchorY = 0
										textFiled["search"].hasBackground = false
										textFiled["search"].font = getFont.font
										textFiled["search"].size = 16
										textFiled["search"]:resizeFontToFitHeight()
										textFiled["search"]:setSelection(0,0)
										textFiled["search"].placeholder = "輸入目的地、景點或活動..."
										textFiled["search"].isVisible = false
									------------------- 諮詢中心 -------------------
									-- 按鈕
										btn["advisoryCenter"] = widget.newButton({
											id = "advisoryCenterBtn",
											x = screenW+ox,
											y = -oy+740*hRate-ceil(50*hRate),
											defaultFile = "assets/btn-qa.png",
											width = floor(144*wRate),
											height = floor(217*wRate),
											onEvent = function ( event )
												local phase = event.phase
												if ( phase == "ended" ) then
													local options = {
														time = 200,
														effect = "fade",
														params = {
															backScene = "homePage"
														}
													}
													composer.gotoScene("advisorCenter",options)
												end
												return true
											end
										})
										sceneGroup:insert(btn["advisoryCenter"])
										btn["advisoryCenter"].anchorX = 1
										btn["advisoryCenter"].anchorY = 1
									------------------- 輪播/廣告區域 -------------------
									-- 輪播圖片切換(function)
										local sliderPic = {}
										local sliderBase = {}
										local viewNum = 1
										local function nextView()
											transition.to( sliderBase.now, { time = 500, x = ((screenW+ox+ox)*0.5)*-1, transition = easing.outExpo } )
											transition.to( sliderBase.next, { time = 500, x = (screenW+ox+ox)*0.5, transition = easing.outExpo } )
											sliderBase.prev = sliderBase.now
											sliderBase.now = sliderBase.next
											if ( sliderPic[viewNum+1] ) then
												sliderBase.next = sliderPic[viewNum+1]
												sliderBase["next"].x = (screenW+ox+ox)*1.5
											else
												sliderBase.next = sliderPic[1]
												sliderBase["next"].x = (screenW+ox+ox)*1.5
											end
											
											if (viewNum < #sliderPic) then
												viewNum = viewNum + 1
											else
												viewNum = 1
											end
										end
									-- 固定時間換頁(table Listener)
										local t = {}
										function t:timer( event )
											local count = event.count
											if ( count % 5 == 0 ) then
												nextView()
											end
										end
									-- 輪播區域
										base["slider"] = display.newRect( bkgScrollViewGroup, bkgScrollViewCX, 0, scrollView["background"].contentWidth, 740*hRate)
										base["slider"].y = base["slider"].y + base["slider"].contentHeight*0.5
										local sliderGroup = display.newGroup()
										bkgScrollViewGroup:insert(sliderGroup)
									-- 廣告區域 
										shadow["advertisementMain"] = display.newImageRect("assets/shadow-3.png", 1039*wRate+ox+ox, 447*wRate)
										bkgScrollViewGroup:insert(shadow["advertisementMain"])
										shadow["advertisementMain"].x = scrollView["background"].contentWidth*0.5
										shadow["advertisementMain"].y = base["slider"].y+base["slider"].contentHeight*0.5+ceil(22*hRate)+shadow["advertisementMain"].contentHeight*0.5
										base["advertisementMain"] = display.newRect( bkgScrollViewGroup, shadow["advertisementMain"].x, shadow["advertisementMain"].y, shadow["advertisementMain"].contentWidth*0.96875, shadow["advertisementMain"].contentHeight*0.98)
									------------------- 熱門目的地 -------------------
									-- mainScrollview內部元件監聽事件
										local function internalScrollviewObject( event )
											local phase = event.phase
											local name = event.target.name
											local id = event.target.id
											if ( phase == "moved" ) then
												if ( name == "hotSpot" ) then
													local dy = math.abs(event.yStart-event.y)
													if (dy > 10) then
														scrollView["background"]:takeFocus(event)
													end
													local dx = math.abs(event.xStart-event.x)
													if (dx > 10) then
														scrollView["hotSpot"]:takeFocus(event)
													end
												end
												if ( name == "uniqueTheme" ) then
													local dy = math.abs(event.yStart-event.y)
													if (dy > 10) then
														scrollView["background"]:takeFocus(event)
													end
													local dx = math.abs(event.xStart-event.x)
													if (dx > 10) then
														scrollView["uniqueTheme"]:takeFocus(event)
													end
												end
												if ( name == "hotJourney" ) then
													local dy = math.abs(event.yStart-event.y)
													if (dy > 10) then
														scrollView["background"]:takeFocus(event)
													end
													local dx = math.abs(event.xStart-event.x)
													if (dx > 10) then
														scrollView["hotJourney"]:takeFocus(event)
													end
												end
												if ( name == "advertisementBottom" ) then
													local dy = math.abs(event.yStart-event.y)
													if (dy > 10) then
														scrollView["background"]:takeFocus(event)
													end
													local dx = math.abs(event.xStart-event.x)
													if (dx > 10) then
														scrollView["advertisementBottom"]:takeFocus(event)
													end
												end
											elseif ( phase == "ended") then
												if ( name == "uniqueTheme" ) then
													print(themeTable[id]["itemId"])
													composer.setVariable("mainTabBarStatus", setStatus["mainTabBar"])
													local options = {
														effect = "fade",
														time = 200,
														params = {
															productId = themeTable[id]["itemId"],
														}
													}
													composer.gotoScene("goodPage",options)
												elseif ( name == "hotJourney" ) then
													composer.setVariable("mainTabBarStatus", setStatus["mainTabBar"])
													local options = {
														effect = "fade",
														time = 200,
														params = {
															productId = themeTable[id]["itemId"],
														}
													}
													composer.gotoScene("goodPage",options)
												end
											end
											return true
										end
									-- 顯示文字-"熱門目的地"
										text["hotSpot"] = display.newText({
											parent = bkgScrollViewGroup,
											text = "熱門目的地",
											font = getFont.font,
											fontSize = 14,
										})
										text["hotSpot"]:setFillColor(unpack(mainColor1))
										text["hotSpot"].anchorX = 0
										text["hotSpot"].anchorY = 0
										text["hotSpot"].x = ceil(22*wRate)
										text["hotSpot"].y = base["advertisementMain"].y+base["advertisementMain"].contentHeight*0.5+ceil(65*hRate)
									-- 顯示文字-"查看全部"
										text["hotSpotAll"] = display.newText({
											parent = bkgScrollViewGroup,
											text = "查看全部",
											font = getFont.font,
											fontSize = 14,
										})
										text["hotSpotAll"]:setFillColor(unpack(wordColor))
										text["hotSpotAll"].anchorX = 1
										text["hotSpotAll"].anchorY = 0
										text["hotSpotAll"].x = scrollView["background"].contentWidth-ceil(30*wRate)
										text["hotSpotAll"].y = text["hotSpot"].y
										local function gotoHotSpot( event )
											local phase = event.phase 
											if (phase == "ended") then
												composer.setVariable("mainTabBarStatus", setStatus["mainTabBar"])
												composer.gotoScene("HS_hotSpot")
											end
											return true
										end
										text["hotSpotAll"]:addEventListener("touch", gotoHotSpot)
									-- 熱門目的地ScrollView
										scrollView["hotSpot"] = widget.newScrollView({
											id = "hotSpotScrollview",
											width = screenW+ox+ox,
											height = floor(338*wRate),
											verticalScrollDisabled = true,
											isBounceEnabled = false,
											backgroundColor = backgroundColor,
											--listener = scrollListener,
										})
										bkgScrollViewGroup:insert(scrollView["hotSpot"])
										scrollView["hotSpot"].anchorX = 0
										scrollView["hotSpot"].anchorY = 0
										scrollView["hotSpot"].x = ceil(22*wRate)
										scrollView["hotSpot"].y = text["hotSpot"].y+text["hotSpot"].contentHeight+ceil(30*hRate)
										local hotSpotGroup = display.newGroup()
										scrollView["hotSpot"]:insert(hotSpotGroup)
										local hotSpotSrollWidth = 0
									-- 熱門目的地ScrollView內部元件
										for i = 1, #hotSpotTable do
											-- 背景
											base["hotSpot"] = display.newRect(hotSpotGroup, 0+(ceil(358*wRate)+ceil(10*wRate))*(i-1), 0, ceil(358*wRate), scrollView["hotSpot"].contentHeight)
											base["hotSpot"]:setFillColor(math.random(),math.random(),math.random())
											base["hotSpot"].anchorX = 0
											base["hotSpot"].anchorY = 0 
											base["hotSpot"].id = hotSpotTable[i]["id"]
											base["hotSpot"].name = "hotSpot"
											base["hotSpot"]:addEventListener("touch",internalScrollviewObject)
											if ( i == #hotSpotTable ) then 
												base["hotSpotPadding"] = display.newRect(hotSpotGroup, base["hotSpot"].x+base["hotSpot"].contentWidth, 0, ceil(22*wRate),base["hotSpot"].contentHeight)
												base["hotSpotPadding"].anchorX = 0
												base["hotSpotPadding"].anchorY = 0
												hotSpotSrollWidth = base["hotSpotPadding"].x+base["hotSpotPadding"].contentWidth
												scrollView["hotSpot"]:setScrollWidth(hotSpotSrollWidth+10)
											end
											-- 黑色文字底層
											shadow["hotSpot"] = display.newImageRect("assets/index-mask.png",357,84)
											hotSpotGroup:insert(shadow["hotSpot"])
											shadow["hotSpot"].anchorX = 0
											shadow["hotSpot"].anchorY = 1
											shadow["hotSpot"].x = base["hotSpot"].x
											shadow["hotSpot"].y = base["hotSpot"].contentHeight
											shadow["hotSpot"].width = base["hotSpot"].contentWidth
											shadow["hotSpot"].height = ceil(shadow["hotSpot"].height*wRate)
											-- 顯示文字-熱門目的地地名
											text["hotSpot"] = display.newText({
												parent = hotSpotGroup,
												x = base["hotSpot"].x+base["hotSpot"].contentWidth*0.5,
												y = shadow["hotSpot"].y-shadow["hotSpot"].contentHeight*0.3,
												text = hotSpotTable[i]["title"],
												font = getFont.font,
												fontSize = 12,
											})
										end
									------------------- 獨家主題 -------------------
									-- 顯示文字-"獨家主題"
										text["uniqueTheme"] = display.newText({
											parent = bkgScrollViewGroup,
											text = "獨家主題",
											font = getFont.font,
											fontSize = 14,
										})
										text["uniqueTheme"]:setFillColor(unpack(mainColor1))
										text["uniqueTheme"].anchorX = 0
										text["uniqueTheme"].anchorY = 0
										text["uniqueTheme"].x = ceil(22*wRate)
										text["uniqueTheme"].y = scrollView["hotSpot"].y+scrollView["hotSpot"].contentHeight+floor(65*hRate)
									-- 顯示文字-"查看全部"
										text["uniqueThemeAll"] = display.newText({
											parent = bkgScrollViewGroup,
											text = "查看全部",
											font = getFont.font,
											fontSize = 14,
										})
										text["uniqueThemeAll"]:setFillColor(unpack(wordColor))
										text["uniqueThemeAll"].anchorX = 1
										text["uniqueThemeAll"].anchorY = 0
										text["uniqueThemeAll"].x = scrollView["background"].contentWidth-ceil(30*wRate)
										text["uniqueThemeAll"].y = text["uniqueTheme"].y
									-- 獨家主題ScrollView
										scrollView["uniqueTheme"] = widget.newScrollView({
											id = "uniqueThemeScrollview",
											width = screenW+ox+ox,
											height = floor(663*wRate),
											verticalScrollDisabled = true,
											isBounceEnabled = false,
											backgroundColor = backgroundColor,
										})
										bkgScrollViewGroup:insert(scrollView["uniqueTheme"])
										scrollView["uniqueTheme"].anchorX = 0
										scrollView["uniqueTheme"].anchorY = 0
										scrollView["uniqueTheme"].x = ceil(22*wRate)
										scrollView["uniqueTheme"].y = text["uniqueTheme"].y+text["uniqueTheme"].contentHeight+ceil(30*hRate)
										local uniqueThemeGroup = display.newGroup()
										scrollView["uniqueTheme"]:insert(uniqueThemeGroup)
										local uniqueThemeSrollWidth = 0
										local uniqueThemeNum = 4
										base["uniqueThemePic"] = {}
									-- 獨家主題ScrollView內部元件
										for i = 1, uniqueThemeNum do
											-- 陰影
												shadow["uniqueTheme"] = display.newImageRect("assets/shadow-3.png", 1080, 1920)
												uniqueThemeGroup:insert(shadow["uniqueTheme"])
												shadow["uniqueTheme"].anchorX = 0
												shadow["uniqueTheme"].anchorY = 0
												shadow["uniqueTheme"].width = ceil(984*wRate)
												shadow["uniqueTheme"].height = scrollView["uniqueTheme"].contentHeight
												shadow["uniqueTheme"].x = 0+(shadow["uniqueTheme"].contentWidth+ceil(22*wRate))*(i-1)
												shadow["uniqueTheme"].y = 0
											-- 增加scrollview width的邊界
												if (i == uniqueThemeNum) then 
													shadow["uniqueThemePadding"] = display.newRect(uniqueThemeGroup, shadow["uniqueTheme"].x+shadow["uniqueTheme"].contentWidth, 0, ceil(22*wRate),base["uniqueTheme"].contentHeight)
													shadow["uniqueThemePadding"].anchorX = 0
													shadow["uniqueThemePadding"].anchorY = 0
													uniqueThemeSrollWidth = shadow["uniqueThemePadding"].x+shadow["uniqueThemePadding"].contentWidth+ceil(22*wRate)
													scrollView["uniqueTheme"]:setScrollWidth(uniqueThemeSrollWidth)
												end
											-- 白底
												base["uniqueTheme"] = display.newRect(uniqueThemeGroup, shadow["uniqueTheme"].x+shadow["uniqueTheme"].contentWidth*0.5, shadow["uniqueTheme"].y+shadow["uniqueTheme"].contentHeight*0.5, shadow["uniqueTheme"].contentWidth*0.96875, shadow["uniqueTheme"].contentHeight*0.98)
												base["uniqueTheme"].id = i
												base["uniqueTheme"].name = "uniqueTheme"
												base["uniqueTheme"]:addEventListener("touch",internalScrollviewObject)
											-- 顯示的圖片位置
												base["uniqueThemePic"][i] = display.newRect(uniqueThemeGroup, base["uniqueTheme"].x, 0, floor(955*wRate)-floor(30*wRate), floor(390*wRate))
												base["uniqueThemePic"][i].y = base["uniqueThemePic"][i].contentHeight*0.5+floor(15*wRate)+floor(shadow["uniqueTheme"].contentHeight*0.02)*0.5	
											-- 顯示文字-行程抬頭
												text["uniqueThemeTitle"] = display.newText({
													parent = uniqueThemeGroup,
													text = myutf8.textToUtf8( themeTable[i]["title"], 15 ),
													font = getFont.font,
													fontSize = 14,
													x = base["uniqueThemePic"][i].x-base["uniqueThemePic"][i].contentWidth*0.5+floor(30*wRate),
													y = base["uniqueThemePic"][i].y+base["uniqueThemePic"][i].contentHeight*0.5+floor(20*hRate),
												})
												text["uniqueThemeTitle"]:setFillColor(unpack(wordColor))
												text["uniqueThemeTitle"].anchorX = 0
												text["uniqueThemeTitle"].anchorY = 0
											-- 顯示文字-行程內文
												text["uniqueThemeContent"] = display.newText({
													parent = uniqueThemeGroup,
													text = myutf8.textToUtf8( themeTable[i]["desc"], 20 ),
													font = getFont.font,
													fontSize = 12,
													x = text["uniqueThemeTitle"].x,
													y = text["uniqueThemeTitle"].y+text["uniqueThemeTitle"].contentHeight+floor(10*hRate),
												})
												text["uniqueThemeContent"]:setFillColor(unpack(wordColor))
												text["uniqueThemeContent"].anchorX = 0
												text["uniqueThemeContent"].anchorY = 0
											-- 圖示-地點
												icon["uniqueThemePlace"] = display.newImageRect("assets/tag-location.png", 240, 240)
												uniqueThemeGroup:insert(icon["uniqueThemePlace"])
												icon["uniqueThemePlace"].anchorX = 0
												icon["uniqueThemePlace"].anchorY = 0
												icon["uniqueThemePlace"].width = icon["uniqueThemePlace"].width*0.05
												icon["uniqueThemePlace"].height = icon["uniqueThemePlace"].height*0.05
												icon["uniqueThemePlace"].x = text["uniqueThemeContent"].x
												icon["uniqueThemePlace"].y = text["uniqueThemeContent"].y+text["uniqueThemeContent"].contentHeight+floor(15*hRate)
											-- 顯示文字-地點
												text["uniqueThemePlace"] = display.newText({
													parent = uniqueThemeGroup,
													x = icon["uniqueThemePlace"].x+icon["uniqueThemePlace"].contentWidth+ceil(10*wRate),
													y = icon["uniqueThemePlace"].y+icon["uniqueThemePlace"].contentHeight*0.5,
													text = "柬埔寨",
													font = getFont.font,
													fontSize = 12,
												})
												text["uniqueThemePlace"]:setFillColor(unpack(wordColor))
												text["uniqueThemePlace"].anchorX = 0
											-- 圖示-勾勾
												icon["uniqueThemeTag"] = display.newImageRect("assets/tag-theme &checkbox.png", 240, 240)
												uniqueThemeGroup:insert(icon["uniqueThemeTag"])
												icon["uniqueThemeTag"].anchorX = 0
												icon["uniqueThemeTag"].anchorY = 0
												icon["uniqueThemeTag"].width = icon["uniqueThemeTag"].width*0.05
												icon["uniqueThemeTag"].height = icon["uniqueThemeTag"].height*0.05
												icon["uniqueThemeTag"].x = icon["uniqueThemePlace"].x
												icon["uniqueThemeTag"].y = icon["uniqueThemePlace"].y+icon["uniqueThemePlace"].contentHeight+floor(15*hRate)
											-- 顯示文字-"主題玩法"
												text["uniqueThemeTag"] = display.newText({
													parent = uniqueThemeGroup,
													x = icon["uniqueThemeTag"].x+icon["uniqueThemeTag"].contentWidth+ceil(10*wRate),
													y = icon["uniqueThemeTag"].y+icon["uniqueThemeTag"].contentHeight*0.5,
													text = "主題玩法",
													font = getFont.font,
													fontSize = 12,
												})
												text["uniqueThemeTag"]:setFillColor(unpack(wordColor))
												text["uniqueThemeTag"].anchorX = 0
											-- 圖示-火熱
												icon["uniqueThemeJoin"] = display.newImageRect("assets/tag-join.png", 240, 240)
												uniqueThemeGroup:insert(icon["uniqueThemeJoin"])
												icon["uniqueThemeJoin"].anchorX = 0
												icon["uniqueThemeJoin"].anchorY = 0
												icon["uniqueThemeJoin"].width = icon["uniqueThemeJoin"].width*0.05
												icon["uniqueThemeJoin"].height = icon["uniqueThemeJoin"].height*0.05
												icon["uniqueThemeJoin"].x = base["uniqueTheme"].contentWidth*0.67+(shadow["uniqueTheme"].contentWidth+ceil(22*wRate))*(i-1)
												icon["uniqueThemeJoin"].y = icon["uniqueThemePlace"].y+icon["uniqueThemePlace"].contentHeight+floor(15*hRate)
											-- 顯示文字-火熱
												text["uniqueThemeJoin"] = display.newText({
													parent = uniqueThemeGroup,
													x = base["uniqueTheme"].contentWidth-40*wRate+(shadow["uniqueTheme"].contentWidth+ceil(22*wRate))*(i-1),
													y = icon["uniqueThemeJoin"].y+icon["uniqueThemeJoin"].contentHeight*0.5,
													text = "1.5k人參加",
													font = getFont.font,
													fontSize = 12,
												})
												text["uniqueThemeJoin"]:setFillColor(unpack(wordColor))
												text["uniqueThemeJoin"].anchorX = 1
											-- 價位標籤
												icon["uniqueThemePriceTag"] = display.newImageRect("assets/tag-price.png", 189, 97)
												uniqueThemeGroup:insert(icon["uniqueThemePriceTag"])
												icon["uniqueThemePriceTag"].width = ceil(icon["uniqueThemePriceTag"].width*wRate)
												icon["uniqueThemePriceTag"].height = floor(icon["uniqueThemePriceTag"].height*wRate)
												icon["uniqueThemePriceTag"].anchorX = 1
												icon["uniqueThemePriceTag"].anchorY = 0
												icon["uniqueThemePriceTag"].x = base["uniqueTheme"].x+base["uniqueTheme"].contentWidth*0.5
												icon["uniqueThemePriceTag"].y = base["uniqueTheme"].y-base["uniqueTheme"].contentHeight*0.5+40*hRate
											-- 顯示文字-幣別
												text["uniqueThemeCurrency"] = display.newText({
													parent = uniqueThemeGroup,
													x = icon["uniqueThemePriceTag"].x-icon["uniqueThemePriceTag"].contentWidth+floor(20*wRate),
													y = icon["uniqueThemePriceTag"].y,
													text = "NT$",
													font = getFont.font,
													fontSize = 12,
												})
												text["uniqueThemeCurrency"].anchorX = 0
												text["uniqueThemeCurrency"].anchorY = 0
											-- 顯示文字-價位
												text["uniqueThemePrice"] = display.newText({
													parent = uniqueThemeGroup,
													x = text["uniqueThemeCurrency"].x,
													y = text["uniqueThemeCurrency"].y+text["uniqueThemeCurrency"].contentHeight,
													text = productTable[i]["twd"],
													font = getFont.font,
													fontSize = 12,
												})
												text["uniqueThemePrice"].anchorX = 0
												text["uniqueThemePrice"].anchorY = 0
										end
									------------------- 熱門行程 -------------------
									-- 顯示文字-"熱門行程"
										text["hotJourney"] = display.newText({
											parent = bkgScrollViewGroup,
											text = "熱門行程",
											font = getFont.font,
											fontSize = 14,
										})
										text["hotJourney"]:setFillColor(unpack(mainColor1))
										text["hotJourney"].anchorX = 0
										text["hotJourney"].anchorY = 0
										text["hotJourney"].x = ceil(22*wRate)
										text["hotJourney"].y = scrollView["uniqueTheme"].y+scrollView["uniqueTheme"].contentHeight+ceil(65*hRate)
									-- 顯示文字-"查看全部"
										text["hotJourneyAll"] = display.newText({
											parent = bkgScrollViewGroup,
											text = "查看全部",
											font = getFont.font,
											fontSize = 14,
										})
										text["hotJourneyAll"]:setFillColor(unpack(wordColor))
										text["hotJourneyAll"].anchorX = 1
										text["hotJourneyAll"].anchorY = 0
										text["hotJourneyAll"].x = scrollView["background"].contentWidth-ceil(30*wRate)
										text["hotJourneyAll"].y = text["hotJourney"].y
									-- 熱門行程ScrollView
										scrollView["hotJourney"] = widget.newScrollView({
											id = "hotJourneyScrollview",
											width = screenW+ox+ox,
											height = floor(663*wRate),
											verticalScrollDisabled = true,
											isBounceEnabled = false,
											backgroundColor = backgroundColor,
										})
										bkgScrollViewGroup:insert(scrollView["hotJourney"])
										scrollView["hotJourney"].anchorX = 0
										scrollView["hotJourney"].anchorY = 0
										scrollView["hotJourney"].x = ceil(22*wRate)
										scrollView["hotJourney"].y = text["hotJourney"].y+text["hotJourney"].contentHeight+ceil(30*hRate)
										local hotJourneyGroup = display.newGroup()
										scrollView["hotJourney"]:insert(hotJourneyGroup)
										local hotJourneySrollWidth = 0
										base["hotJourneyPic"] = {}
									-- 熱門行程ScrollView內部元件
										for i = 5, #themeTable do
											-- 陰影
												shadow["hotJourney"] = display.newImageRect("assets/shadow-3.png", 1080, 1920)
												hotJourneyGroup:insert(shadow["hotJourney"])
												shadow["hotJourney"].anchorX = 0
												shadow["hotJourney"].anchorY = 0
												shadow["hotJourney"].width = ceil(984*wRate)
												shadow["hotJourney"].height = scrollView["hotJourney"].contentHeight
												shadow["hotJourney"].x = 0+(shadow["hotJourney"].contentWidth+ceil(22*wRate))*(i-5)
												shadow["hotJourney"].y = 0
												if (i == #themeTable) then 
													shadow["hotJourneyPadding"] = display.newRect(hotJourneyGroup, shadow["hotJourney"].x+shadow["hotJourney"].contentWidth, 0, ceil(22*wRate),base["hotJourney"].contentHeight)
													shadow["hotJourneyPadding"].anchorX = 0
													shadow["hotJourneyPadding"].anchorY = 0
													hotJourneySrollWidth = shadow["hotJourneyPadding"].x+shadow["hotJourneyPadding"].contentWidth+ceil(22*wRate)
													scrollView["hotJourney"]:setScrollWidth(hotJourneySrollWidth)
												end
											-- 白底
												base["hotJourney"] = display.newRect(hotJourneyGroup, shadow["hotJourney"].x+shadow["hotJourney"].contentWidth*0.5, shadow["hotJourney"].y+shadow["hotJourney"].contentHeight*0.5, shadow["hotJourney"].contentWidth*0.96875, shadow["hotJourney"].contentHeight*0.98)
												base["hotJourney"].id = themeTable[i]["id"]
												base["hotJourney"].name = "hotJourney"
												base["hotJourney"]:addEventListener("touch",internalScrollviewObject)
											-- 圖片位置
												base["hotJourneyPic"][i] = display.newRect(hotJourneyGroup, base["hotJourney"].x, 0, floor(955*wRate)-floor(30*wRate), floor(390*wRate))
												base["hotJourneyPic"][i].y = base["hotJourneyPic"][i].contentHeight*0.5+floor(15*wRate)+floor(shadow["hotJourney"].contentHeight*0.02)*0.5	
											-- 顯示文字-行程抬頭
												text["hotJourneyTitle"] = display.newText({
													parent = hotJourneyGroup,
													text = myutf8.textToUtf8(themeTable[i]["title"], 15),
													font = getFont.font,
													fontSize = 14,
													x = base["hotJourneyPic"][i].x-base["hotJourneyPic"][i].contentWidth*0.5+floor(30*wRate),
													y = base["hotJourneyPic"][i].y+base["hotJourneyPic"][i].contentHeight*0.5+floor(20*hRate),
												})
												text["hotJourneyTitle"]:setFillColor(unpack(wordColor))
												text["hotJourneyTitle"].anchorX = 0
												text["hotJourneyTitle"].anchorY = 0
											-- 顯示文字-行程內文
												text["hotJourneyContent"] = display.newText({
													parent = hotJourneyGroup,
													text = myutf8.textToUtf8( themeTable[i]["desc"], 20),
													font = getFont.font,
													fontSize = 12,
													x = text["hotJourneyTitle"].x,
													y = text["hotJourneyTitle"].y+text["hotJourneyTitle"].contentHeight+floor(10*hRate),
												})
												text["hotJourneyContent"]:setFillColor(unpack(wordColor))
												text["hotJourneyContent"].anchorX = 0
												text["hotJourneyContent"].anchorY = 0
											-- 圖示-地點
												icon["hotJourneyPlace"] = display.newImageRect("assets/tag-location.png", 240, 240)
												hotJourneyGroup:insert(icon["hotJourneyPlace"])
												icon["hotJourneyPlace"].anchorX = 0
												icon["hotJourneyPlace"].anchorY = 0
												icon["hotJourneyPlace"].width = icon["hotJourneyPlace"].width*0.05
												icon["hotJourneyPlace"].height = icon["hotJourneyPlace"].height*0.05
												icon["hotJourneyPlace"].x = text["hotJourneyContent"].x
												icon["hotJourneyPlace"].y = text["hotJourneyContent"].y+text["hotJourneyContent"].contentHeight+floor(15*hRate)
											-- 顯示文字-地點
												text["hotJourneyPlace"] = display.newText({
													parent = hotJourneyGroup,
													x = icon["hotJourneyPlace"].x+icon["hotJourneyPlace"].contentWidth+ceil(10*wRate),
													y = icon["hotJourneyPlace"].y+icon["hotJourneyPlace"].contentHeight*0.5,
													text = "柬埔寨",
													font = getFont.font,
													fontSize = 12,
												})
												text["hotJourneyPlace"]:setFillColor(unpack(wordColor))
												text["hotJourneyPlace"].anchorX = 0
											-- 圖示-標示
												icon["hotJourneyTag"] = display.newImageRect("assets/tag-theme &checkbox.png", 240, 240)
												hotJourneyGroup:insert(icon["hotJourneyTag"])
												icon["hotJourneyTag"].anchorX = 0
												icon["hotJourneyTag"].anchorY = 0
												icon["hotJourneyTag"].width = icon["hotJourneyTag"].width*0.05
												icon["hotJourneyTag"].height = icon["hotJourneyTag"].height*0.05
												icon["hotJourneyTag"].x = icon["hotJourneyPlace"].x
												icon["hotJourneyTag"].y = icon["hotJourneyPlace"].y+icon["hotJourneyPlace"].contentHeight+floor(15*hRate)
											-- 顯示文字-標示
												text["hotJourneyTag"] = display.newText({
													parent = hotJourneyGroup,
													x = icon["hotJourneyTag"].x+icon["hotJourneyTag"].contentWidth+ceil(10*wRate),
													y = icon["hotJourneyTag"].y+icon["hotJourneyTag"].contentHeight*0.5,
													text = "主題玩法",
													font = getFont.font,
													fontSize = 12,
												})
												text["hotJourneyTag"]:setFillColor(unpack(wordColor))
												text["hotJourneyTag"].anchorX = 0
											-- 圖示-火熱
												icon["hotJourneyJoin"] = display.newImageRect("assets/tag-join.png", 240, 240)
												hotJourneyGroup:insert(icon["hotJourneyJoin"])
												icon["hotJourneyJoin"].anchorX = 0
												icon["hotJourneyJoin"].anchorY = 0
												icon["hotJourneyJoin"].width = icon["hotJourneyJoin"].width*0.05
												icon["hotJourneyJoin"].height = icon["hotJourneyJoin"].height*0.05
												icon["hotJourneyJoin"].x = base["hotJourney"].contentWidth*0.67+(shadow["hotJourney"].contentWidth+ceil(22*wRate))*(i-1)
												icon["hotJourneyJoin"].y = icon["hotJourneyPlace"].y+icon["hotJourneyPlace"].contentHeight+floor(15*hRate)
											-- 顯示文字-火熱
												text["hotJourneyJoin"] = display.newText({
													parent = hotJourneyGroup,
													x = base["hotJourney"].contentWidth-40*wRate+(shadow["hotJourney"].contentWidth+ceil(22*wRate))*(i-1),
													y = icon["hotJourneyJoin"].y+icon["hotJourneyJoin"].contentHeight*0.5,
													text = "1.5k人參加",
													font = getFont.font,
													fontSize = 12,
												})
												text["hotJourneyJoin"]:setFillColor(unpack(wordColor))
												text["hotJourneyJoin"].anchorX = 1
											-- 價位標籤
												icon["hotJourneyPriceTag"] = display.newImageRect("assets/tag-price.png", 189, 97)
												hotJourneyGroup:insert(icon["hotJourneyPriceTag"])
												icon["hotJourneyPriceTag"].width = ceil(icon["hotJourneyPriceTag"].width*wRate)
												icon["hotJourneyPriceTag"].height = floor(icon["hotJourneyPriceTag"].height*wRate)
												icon["hotJourneyPriceTag"].anchorX = 1
												icon["hotJourneyPriceTag"].anchorY = 0
												icon["hotJourneyPriceTag"].x = base["hotJourney"].x+base["hotJourney"].contentWidth*0.5
												icon["hotJourneyPriceTag"].y = base["hotJourney"].y-base["hotJourney"].contentHeight*0.5+40*hRate
											-- 顯示文字-幣別
												text["hotJourneyCurrency"] = display.newText({
													parent = hotJourneyGroup,
													x = icon["hotJourneyPriceTag"].x-icon["hotJourneyPriceTag"].contentWidth+floor(20*wRate),
													y = icon["hotJourneyPriceTag"].y,
													text = "NT$",
													font = getFont.font,
													fontSize = 12,
												})
												text["hotJourneyCurrency"].anchorX = 0
												text["hotJourneyCurrency"].anchorY = 0
											-- 顯示文字-價位
												text["hotJourneyPrice"] = display.newText({
													parent = hotJourneyGroup,
													x = text["hotJourneyCurrency"].x,
													y = text["hotJourneyCurrency"].y+text["hotJourneyCurrency"].contentHeight,
													text = productTable[i]["twd"],
													font = getFont.font,
													fontSize = 12,
												})
												text["hotJourneyPrice"].anchorX = 0
												text["hotJourneyPrice"].anchorY = 0
										end
									------------------- 頁尾廣告區 -------------------
									-- 頁尾廣告ScrollView
										scrollView["advertisementBottom"] = widget.newScrollView({
											id = "advertisementBottomScrollview",
											width = screenW+ox+ox,
											height = ceil(363*wRate),
											verticalScrollDisabled = true,
											isBounceEnabled = false,
											backgroundColor = backgroundColor,
											--listener = scrollListener,
										})
										bkgScrollViewGroup:insert(scrollView["advertisementBottom"])
										scrollView["advertisementBottom"].anchorX = 0
										scrollView["advertisementBottom"].anchorY = 0
										scrollView["advertisementBottom"].x = ceil(22*wRate)
										scrollView["advertisementBottom"].y = scrollView["hotJourney"].y+scrollView["hotJourney"].contentHeight+ceil(85*hRate)
										local backgroundScrollHeight = scrollView["advertisementBottom"].y+scrollView["advertisementBottom"].contentHeight+10+mainTabBarHeight
										scrollView["background"]:setScrollHeight(backgroundScrollHeight)
									-- 頁尾廣告ScrollView元件
										local advertisementBottomGroup = display.newGroup()
										scrollView["advertisementBottom"]:insert(advertisementBottomGroup)
										local advertisementBottomSrollWidth = 0
										for i = 1, 3 do
											-- 陰影
											shadow["advertisementBottom"] = display.newImageRect("assets/shadow-3.png", 1080, 1920)
											advertisementBottomGroup:insert(shadow["advertisementBottom"])
											shadow["advertisementBottom"].width = floor(493*wRate)
											shadow["advertisementBottom"].height = scrollView["advertisementBottom"].contentHeight
											shadow["advertisementBottom"].x = shadow["advertisementBottom"].contentWidth*0.5+(shadow["advertisementBottom"].contentWidth+ceil(20*wRate))*(i-1)
											shadow["advertisementBottom"].y = shadow["advertisementBottom"].contentHeight*0.5
											-- 實際空間
											base["advertisementBottom"] = display.newRect(advertisementBottomGroup, shadow["advertisementBottom"].x, shadow["advertisementBottom"].y, shadow["advertisementBottom"].contentWidth*0.96875, shadow["advertisementBottom"].contentHeight*0.98)
											base["advertisementBottom"]:setFillColor(unpack(separateLineColor))
											base["advertisementBottom"].name = "advertisementBottom"
											base["advertisementBottom"].id = i
											base["advertisementBottom"]:addEventListener("touch",internalScrollviewObject)
											if ( i == 3 ) then
												advertisementBottomSrollWidth = shadow["advertisementBottom"].x+shadow["advertisementBottom"].contentWidth*0.5+ceil(20*wRate)+ceil(22*wRate)
												scrollView["advertisementBottom"]:setScrollWidth(advertisementBottomSrollWidth)
											end
										end		
									------------------- 處理圖片 -------------------
									-- 下載圖片
										local sliderUrl = {}
										for i = 1, 5 do
											sliderUrl[i] = "http://traveltest.1758play.com:8080/img/slider"..i..".jpg"
										end
										local picTotalNum = #sliderUrl+#picUrl
										local picCount = 0
										for i = 1, #picUrl do
											local function getProductPic( event )
												if (event.isError) then 
													print( "Network Error - Download Failed : "..event.response )
												end
												if (event.phase == "ended" ) then
													--print( "Get product image file "..i)
													picCount = picCount +1
													progressView:setProgress( picCount/picTotalNum )
													local paint = { type = "image", filename = event.response.filename, baseDir = event.response.baseDirectory}
													-- 顯示圖片
													if ( i <= 4 ) then
														base["uniqueThemePic"][i].fill = paint
													else
														base["hotJourneyPic"][i].fill = paint
													end
													if ( picCount == #picUrl ) then
														for i = 1, #sliderUrl do
															local function getRotationPlayPic( event )
																if (event.isError) then 
																	print( "Network Error - Download Failed : "..event.response )
																end
																if (event.phase == "ended" ) then
																	picCount = picCount+1 
																	progressView:setProgress(picCount/picTotalNum)
																	--print( "Get rotation image file " ..i)
																	local p = display.newImage(event.response.filename, event.response.baseDirectory, cx, cy)
																	sliderGroup:insert(p)
																	p.width = base["slider"].contentWidth
																	p.height =  base["slider"].contentHeight
																	if ( i > 1 ) then 
																		p.x = base["slider"].x + base["slider"].contentWidth
																	else
																		p.x = base["slider"].x
																	end
																	p.y = base["slider"].y
																	sliderPic[i] = p
																	sliderBase.now = sliderPic[1]
																	sliderBase.next = sliderPic[2]
																	if ( picCount == picTotalNum ) then
																		coverGroup.isVisible = false
																		textFiled["search"].isVisible = true
																		isStart = true
																		print("Rotation Play Start")
																		rotationPlay = timer.performWithDelay( 1000, t, 0 )
																	end
																end
															end
															local picName = string.match( sliderUrl[i], urlGetFileNamePattern)
															network.download( sliderUrl[i], "GET", getRotationPlayPic, picName, system.TemporaryDirectory )
														end
													end
												end
											end
											local picName = string.match( picUrl[i], urlGetFileNamePattern)
											network.download( picUrl[i], "GET",	getProductPic, picName, system.TemporaryDirectory )
										end
								end
							end
						end	
						local productUrl = optionsTable.getProductUrl..themeTable[i]["itemId"]
						network.request( productUrl, "GET", getProductInfo)	
					end		
				end
			end
			local themeUrl = optionsTable.getThemeUrl
			network.request(themeUrl, "POST", themeListener, parms)
		end
	end
	local hotSpotUrl = optionsTable.getHotSoptUrl
	network.request( hotSpotUrl, "POST", hotSpotListener, parms)
end

-- show()
function scene:show( event )
	local sceneGroup = self.view
	local phase = event.phase
	if ( phase == "will" ) then
		if ( isStart == true and setChangeScene == true ) then
			scrollView["background"]:scrollTo("top", { time = 0 , onComplete = function ()
				scrollView["hotSpot"]:scrollTo("left", { time = 0 , onComplete = function ()
					scrollView["uniqueTheme"]:scrollTo("left", { time = 0, onComplete = function ()
						scrollView["hotJourney"]:scrollTo("left", { time = 0 })
					end })
				end })
			end})
		end
		if ( setStatus["mainTabBar"] == "hidden" ) then
			mainTabBar.myTabBarScrollShown()
			setStatus["mainTabBar"] = "shown"
		else
			mainTabBar.myTabBarShown()
		end
	elseif ( phase == "did" ) then
		if ( isStart == true and setChangeScene == true ) then
			setChangeScene = false
			textFiled["search"].isVisible = true
			timer.resume(rotationPlay)
		end
	end
end

-- hide()
function scene:hide( event )
	local sceneGroup = self.view
	local phase = event.phase
	if ( phase == "will" ) then
		textFiled["search"].isVisible = false
	elseif ( phase == "did" ) then
		--composer.removeScene("homePage")
		setChangeScene = true
		timer.pause(rotationPlay)
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