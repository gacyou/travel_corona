-----------------------------------------------------------------------------------------
--
-- TP_memberSearch.lua
--
-----------------------------------------------------------------------------------------
local widget = require ("widget")
local composer = require ("composer")
local mainTabBar = require("mainTabBar")
local getFont = require("setFont")
local json = require("json")
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

local memberSearchGroup
local titleListBoundary, titleListGroup
local setStatus = {}

local genderOptions = { "男", "女", "不拘"}
local genderGroup
local genderSelected = false

local contientOptions = { "亞洲", ["亞洲"] = 1, "歐洲", ["歐洲"] = 2, "北美洲", ["北美洲"] = 5, "南美洲", ["南美洲"] = 7 }
local contientJson = json.encode( contientOptions )
local contientGroup
local contientSelected = false

local countryGroup
local countrySelected = false

local ceil = math.ceil
local floor = math.floor

local frameVertices = {	
	0, 0, 
	floor(826*wRate)+ox+ox, 0,
	floor(826*wRate)+ox+ox, floor(85*hRate),	 
	0, floor(85*hRate)
}
local triangleVertices = { 260, 165, 266, 165, 263, 169}

-- create()
function scene:create( event )
	local sceneGroup = self.view
	mainTabBar.myTabBarHidden()
	------------------- 抬頭元件 -------------------
	-- 白底
		local titleBase = display.newRect(0, 0, screenW+ox+ox, floor(178*hRate))
		sceneGroup:insert(titleBase)
		titleBase.x = cx
		titleBase.y = -oy+((titleBase.height)/2)
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
			onRelease = function()
				options = { time = 300, effect = "fade"}
				composer.gotoScene("TP_findPartner", options)
			end,
		})
		sceneGroup:insert(backArrowNum,backBtn)
	-- 顯示文字-"會員搜尋"
		local titleText = display.newText({
			text = "會員搜尋",
			y = titleBase.y,
			font = getFont.font,
			fontSize = 14,
		})
		sceneGroup:insert(titleText)
		titleText:setFillColor(unpack(wordColor))
		titleText.anchorX = 0
		titleText.x = backArrow.x+backArrow.contentWidth+(30*wRate)
	-- 下拉式選單按鈕圖片
		local listIcon = display.newImage( sceneGroup, "assets/btn-list.png",screenW+ox-ceil(45*wRate), backArrow.y)
		listIcon.width = (listIcon.width*0.07)
		listIcon.height = (listIcon.height*0.07)
		listIcon.anchorX = 1
		local listIconNum = sceneGroup.numChildren
	-- 下拉式選單按鈕
	 	local listBtn = widget.newButton({
	 		id = "listBtn",
	 		x = listIcon.x-listIcon.contentWidth*0.5,
	 		y = listIcon.y,
	 		shape = "rect",
	 		width =  backBtn.contentWidth,
	 		height =  titleBase.contentHeight,
	 		onRelease = function()
	 			if (setStatus["listBtn"] == "up") then 
	 				setStatus["listBtn"] = "down"
	 				transition.to(titleListGroup,{ y = -titleListBoundary.contentHeight, time = 200})
	 				timer.performWithDelay(200, function() titleListBoundary.isVisible = false ;end)
	 			else
	 				setStatus["listBtn"] = "up"
	 				titleListBoundary.isVisible = true
	 				transition.to(titleListGroup,{ y = 0, time = 200})
	 			end
	 		end,
	 	})
	 	sceneGroup:insert(listIconNum,listBtn)
	 	setStatus["listBtn"] = "down"
	------------------- 搜尋會員藍色底圖 -------------------
	-- 藍底
		local memberSearchGroup = display.newGroup()
		sceneGroup:insert(memberSearchGroup)
		local blueBase = display.newImageRect("assets/mate-bg.png",1080,506)
		memberSearchGroup:insert(blueBase)
		blueBase.width = screenW+ox+ox
		blueBase.height = ceil(455*hRate)
		blueBase.x = cx
		blueBase.y = titleBase.y+titleBase.contentHeight*0.5+(blueBase.contentHeight/2)
	-- 顯示文字
		local memberSearchTitleText = display.newEmbossedText({
				text = "來喔！來尋找會員喔!",
				font = getFont.font,
				fontSize = 18,
			})
		memberSearchGroup:insert(memberSearchTitleText)
		memberSearchTitleText.x = cx
		memberSearchTitleText.y = blueBase.y-(blueBase.contentHeight*0.15)
		local color = {
			highlight = { r=0, g=0, b=0 },
			shadow = { r=1, g=1, b=1 }
		}
		memberSearchTitleText:setEmbossColor( color )
	------------------- 會員搜尋元件(背景底圖+字) -------------------
	-- 圖示-tag-find.png
		local findTag = display.newImageRect("assets/tag-find.png", 404, 135)
		memberSearchGroup:insert(findTag)
		findTag.anchorX = 0
		findTag.anchorY = 0
		findTag.width = findTag.width*wRate+ox*0.9
		findTag.height = findTag.height*hRate
		findTag.x = -ox+ceil(20*wRate)
		findTag.y = -oy+ceil(566*hRate)
		local findTagNum = memberSearchGroup.numChildren
	-- 圖示-0301matesearch-paper.png
		local findPaper = display.newImageRect("assets/0301matesearch-paper.png", 1007, 1024)
		memberSearchGroup:insert(findTagNum, findPaper)
		findPaper.anchorX = 0
		findPaper.anchorY = 0
		findPaper.width = findPaper.width*wRate+ox+ox
		findPaper.height = findPaper.height*hRate
		findPaper.x = findTag.x+ceil(20*wRate)
		findPaper.y = findTag.y+ceil(10*hRate)
	-- 顯示文字-"會員搜尋"
		local memberSearchText = display.newText({
				text = "會員搜尋",
				font = getFont.font,
				fontSize = 14,
			})
		memberSearchGroup:insert(memberSearchText)
		memberSearchText.anchorX = 0
		memberSearchText.x = -ox+ceil(128*wRate)
		memberSearchText.y = findTag.y+floor(90*hRate)*0.5
	------------------- 會員搜尋元件 -------------------
	-- 性別元件 --
	-- 顯示文字-"性別"
		local genderText = display.newText({
			text = "性別",
			font = getFont.font,
			fontSize = 14,
		})
		memberSearchGroup:insert(genderText)
		genderText:setFillColor(unpack(wordColor))
		genderText.anchorX = 0
		genderText.anchorY = 0
		genderText.x = memberSearchText.x
		genderText.y = findTag.y+findTag.contentHeight
	-- 性別外框
		local genderFrame = display.newPolygon(cx,cy,frameVertices)
		memberSearchGroup:insert(genderFrame)
		genderFrame.name = "genderFrame"
		genderFrame.strokeWidth = 1
		genderFrame:setStrokeColor(unpack(separateLineColor))
		genderFrame.anchorX = 0
		genderFrame.anchorY = 0
		genderFrame.x = genderText.x
		genderFrame.y = genderText.y+genderText.contentHeight+floor(20*hRate)
	-- 顯示文字-請選擇
		local genderFrameText = display.newText({
			text = "請選擇",
			font = getFont.font,
			fontSize = 14,
		})
		memberSearchGroup:insert(genderFrameText)
		genderFrameText:setFillColor(unpack(wordColor))
		genderFrameText.anchorX = 0
		genderFrameText.x = genderFrame.x+ceil(25*wRate)
		genderFrameText.y = genderFrame.y+genderFrame.contentHeight*0.5
	-- 性別選項的三角形
		local genderFrameTriangle = display.newPolygon( genderFrame.x+(genderFrame.contentWidth-ceil(40*wRate)), genderFrameText.y, triangleVertices)
		memberSearchGroup:insert(genderFrameTriangle)
		genderFrameTriangle.strokeWidth = 2
		genderFrameTriangle:setStrokeColor(0)
		genderFrameTriangle:setFillColor(0)
		genderFrameTriangle.x = genderFrameTriangle.x-genderFrameTriangle.contentWidth*0.5
		setStatus["genderFrameTriangle"] = "down"
	
	-- 洲別元件 --
	-- 顯示文字-"洲別"
		local continentText = display.newText({
			text = "洲別",
			font = getFont.font,
			fontSize = 14,
		})
		memberSearchGroup:insert(continentText)
		continentText:setFillColor(unpack(wordColor))
		continentText.anchorX = 0
		continentText.anchorY = 0
		continentText.x = genderText.x
		continentText.y = genderFrame.y+genderFrame.contentHeight+floor(40*hRate)
	-- 洲別選項外框
		local continentFrame = display.newPolygon( cx, cy, frameVertices)
		memberSearchGroup:insert(continentFrame)
		continentFrame.name = "continentFrame"
		continentFrame.strokeWidth = 1
		continentFrame:setStrokeColor(unpack(separateLineColor))
		continentFrame.anchorX = 0
		continentFrame.anchorY = 0
		continentFrame.x = continentText.x
		continentFrame.y = continentText.y+continentText.contentHeight+floor(20*hRate)
	-- 顯示文字-"請選擇"
		local continentFrameText = display.newText({
			text = "請選擇",
			font = getFont.font,
			fontSize = 14,
		})
		memberSearchGroup:insert(continentFrameText)
		continentFrameText:setFillColor(unpack(wordColor))
		continentFrameText.anchorX = 0
		continentFrameText.x = genderFrameText.x
		continentFrameText.y = continentFrame.y+continentFrame.contentHeight*0.5
	-- 洲別選項的三角形
		local continentFrameTriangle = display.newPolygon( genderFrameTriangle.x, continentFrameText.y, triangleVertices)
		memberSearchGroup:insert(continentFrameTriangle)
		continentFrameTriangle.strokeWidth = 2
		continentFrameTriangle:setStrokeColor(0)
		continentFrameTriangle:setFillColor(0)
		setStatus["continentFrameTriangle"] = "down"
	
	-- 國家元件 --
	-- 顯示文字-"國家"
		local countryText = display.newText({
			text = "國家",
			font = getFont.font,
			fontSize = 14,		
		})
		memberSearchGroup:insert(countryText)
		countryText:setFillColor(unpack(wordColor))
		countryText.anchorX = 0
		countryText.anchorY = 0
		countryText.x = genderText.x
		countryText.y = continentFrame.y+continentFrame.contentHeight+ceil(40*hRate)
	-- 國家外框
		local countryFrame = display.newPolygon(cx,cy,frameVertices)
		memberSearchGroup:insert(countryFrame)
		countryFrame.name = "countryFrame"
		countryFrame.strokeWidth = 1
		countryFrame:setStrokeColor(unpack(separateLineColor))
		countryFrame.anchorX = 0
		countryFrame.anchorY = 0
		countryFrame.x = countryText.x
		countryFrame.y = countryText.y+countryText.contentHeight+floor(20*hRate)
	-- 顯示文字-請選擇
		local countryFrameText = display.newText({
			text = "請選擇",
			font = getFont.font,
			fontSize = 14,
		})
		memberSearchGroup:insert(countryFrameText)
		countryFrameText:setFillColor(unpack(wordColor))
		countryFrameText.anchorX = 0
		countryFrameText.x = continentFrameText.x
		countryFrameText.y = countryFrame.y+countryFrame.contentHeight*0.5
	-- 國家選擇外框內的三角形
		local countryFrameTriangle = display.newPolygon ( continentFrameTriangle.x, countryFrameText.y, triangleVertices)
		memberSearchGroup:insert(countryFrameTriangle)
		countryFrameTriangle.strokeWidth = 2
		countryFrameTriangle:setStrokeColor(0)
		countryFrameTriangle:setFillColor(0)
		setStatus["countryFrameTriangle"] = "down"
	-- 國家選項遮罩
		local countryCover = display.newRect( memberSearchGroup, cx, countryText.y, countryFrame.contentWidth+ox, countryFrame.y+countryFrame.contentHeight-countryText.y )
		countryCover.anchorY = 0
		countryCover:setFillColor( 1, 1, 1, 0.7)
		countryCover:addEventListener( "touch", function() return true; end)
	
	-- 搜尋按鈕 --
		local searchBtn = widget.newButton({
			id = "searchBtn",
			label = "搜尋會員",
			labelColor = { default = { 1, 1, 1}, over = { 1, 1, 1} },
			font = getFont.font,
			fontSize = 14,
			defaultFile = "assets/btn-mate.png",
			width = ceil(344*wRate),
			height = ceil(85*hRate),
			onRelease = function()
				if ( genderSelected == true and contientSelected == true and countrySelected == true) then 
					--composer.setVariable("getGender", genderFrameText.text)
					--composer.setVariable("getCountry", countryFrameText.text)
					local options = { 
						time = 200, 
						effect = "fade",
						params = {
							setFromScene = composer.getSceneName("current"),
							setContinent = continentFrameText.text,
							setCountry = countryFrameText.text,
							setCity = "N/A",
							setGender = genderFrameText.text,
						}
					}
					composer.gotoScene( "TP_searchResult", options)
					--composer.gotoScene( "TP_memberResult", options)
				end
			end,
		})
		memberSearchGroup:insert(searchBtn)
		searchBtn.anchorX = 1
		searchBtn.anchorY = 1
		searchBtn.x = screenW+ox-ceil(110*wRate)
		searchBtn.y = findPaper.y+findPaper.contentHeight-ceil(100*hRate)

	-- 選框監聽事件
		local function frameListener( event )
			local name = event.target.name
			local phase = event.phase
			if ( phase == "ended" ) then
				if ( name == "genderFrame") then
					genderFrameTriangle:rotate(180)
					if (setStatus["genderFrameTriangle"] == "up") then 
						setStatus["genderFrameTriangle"] = "down"
						genderFrame.strokeWidth = 1
						genderFrame:setStrokeColor(unpack(separateLineColor))
						genderGroup.isVisible = false
					else
						setStatus["genderFrameTriangle"] = "up"
						genderFrame.strokeWidth = 2
						genderFrame:setStrokeColor(unpack(subColor2))
						genderGroup.isVisible = true
					end
				elseif ( name == "continentFrame") then
					continentFrameTriangle:rotate(180)
					if (setStatus["continentFrameTriangle"] == "up") then 
						setStatus["continentFrameTriangle"] = "down"
						continentFrame.strokeWidth = 1
						continentFrame:setStrokeColor(unpack(separateLineColor))
						contientGroup.isVisible = false
					else
						setStatus["continentFrameTriangle"] = "up"
						continentFrame.strokeWidth = 2
						continentFrame:setStrokeColor(unpack(subColor2))
						contientGroup.isVisible = true
					end
				elseif ( name == "countryFrame") then
					countryFrameTriangle:rotate(180)
					if (setStatus["countryFrameTriangle"] == "up") then 
						setStatus["countryFrameTriangle"] = "down"
						countryFrame.strokeWidth = 1
						countryFrame:setStrokeColor(unpack(separateLineColor))
						countryGroup.isVisible = false
					else
						setStatus["countryFrameTriangle"] = "up"
						countryFrame.strokeWidth = 2
						countryFrame:setStrokeColor(unpack(subColor2))
						countryGroup.isVisible = true
					end
				end
			end
			return true
		end
		genderFrame:addEventListener( "touch", frameListener )
		continentFrame:addEventListener( "touch", frameListener )
		countryFrame:addEventListener( "touch", frameListener )
	-- 下拉式選單通用參數 --
		local listFrameWidth = continentFrame.contentWidth*0.8
		local listFrameHeight = screenH*0.28
		local listBaseWidth = listFrameWidth*0.955
		local listBaseHeight = screenH/16
		local listBasePadding = listBaseHeight/3
	-- 洲別/國家下拉式選單 --
	-- 外框
		contientGroup = display.newGroup()
		memberSearchGroup:insert(contientGroup)
		local contientGroupNum = memberSearchGroup.numChildren
		local contientListFrame = display.newImageRect( contientGroup, "assets/shadow-320480-paper.png", listFrameWidth, listFrameHeight)
		contientListFrame:addEventListener( "touch", function() return true; end)
		contientListFrame.anchorY = 0
		contientListFrame.x = cx
		contientListFrame.y = continentFrame.y+continentFrame.contentHeight

		local contientScrollView = widget.newScrollView({
			id = "contientScrollView",
			x = cx,
			y = continentFrame.y+continentFrame.contentHeight,
			width = listFrameWidth*0.95,
			height = listFrameHeight*59/60,
			isBounceEnabled = false,
			horizontalScrollDisabled = true,
			isLocked = true,
			backgroundColor = {1},
		})
		contientGroup:insert(contientScrollView)
		contientScrollView.anchorY = 0
		local contientScrollViewHeight = 0 
		local contientScrollViewGroup = display.newGroup()
		contientScrollView:insert(contientScrollViewGroup)
	-- 洲別選單內容監聽事件
		local contientListText = {}
		local cancelSelected = false
		local nowSelection, prevSelction = nil, nil
		local function contientListOptionListener( event )
			local  phase = event.phase
			if ( phase == "began" ) then
				if ( cancelSelected == true ) then
					cancelSelected = false
				end
				if ( nowSelection == nil and prevSelction == nil ) then
					nowSelection = event.target
					nowSelection:setFillColor( 0, 0, 0, 0.1)
					contientListText[nowSelection.id]:setFillColor(unpack(subColor2))
				elseif ( nowSelection == nil and prevSelction ~= nil ) then
					if ( event.target ~= prevSelction ) then
						
						contientListText[prevSelction.id]:setFillColor(unpack(wordColor))

						nowSelection = event.target
						nowSelection:setFillColor( 0, 0, 0, 0.1)
						contientListText[nowSelection.id]:setFillColor(unpack(subColor2))
					end
				end
			elseif ( phase == "moved" ) then
				cancelSelected = true
				local dx = math.abs(event.xStart-event.x)
				local dy = math.abs(event.yStart-event.y)
				if (dx > 10 or dy > 10) then
					if (nowSelection ~= nil) then
						contientScrollView:takeFocus(event)
						nowSelection:setFillColor(1)
						contientListText[nowSelection.id]:setFillColor(unpack(wordColor))
						nowSelection = nil
						if (prevSelction ~= nil) then
							contientListText[prevSelction.id]:setFillColor(unpack(subColor2))
						end
					end
				end
			elseif ( phase == "ended" and cancelSelected == false and nowSelection ~= nil ) then
				-- 洲別選框相關變化
					if ( contientListText[nowSelection.id].text ~= continentFrameText.text ) then
						countryFrameText.text = "請選擇"
					end
					continentFrameText.text = contientListText[nowSelection.id].text
					continentFrame.strokeWidth = 1
					continentFrame:setStrokeColor(unpack(separateLineColor))
					continentFrameTriangle:rotate(180)
					setStatus["continentFrameTriangle"] = "down"
				-- 選項選單變化
					nowSelection:setFillColor(1)
					prevSelction = nowSelection
					nowSelection = nil
					contientSelected = true
					contientGroup.isVisible = false

				-- 產生國家選項選單 --
				-- 接洲別產生國家API
					local contientDecode = json.decode(contientJson)
					local contientDecodeValue = continentFrameText.text
					--print( contientDecode[contientDecodeValue] )
					local countryListOptions = {}
					local countryIdList = {}
					local function getCountryInfo( event )
						if ( event.isError ) then
							print( "Network Error: "..event.response )
						else
							--print( "Response: "..event.response )
							local countryJsonData = json.decode( event.response )
							for key, countryTableJson in pairs(countryJsonData["list"]) do
								--print( key, countryTableJson)
								--print(countryTableJson)
								--for k,v in pairs(countryTableJson) do
								--	print (k,v)
								--end

								-- 利用countryTableJson對應的 key, value獲取資訊
								table.insert( countryListOptions, countryTableJson["desc"])
								table.insert( countryIdList, countryTableJson["id"])
							end
						end
						
						-- 國家選單外框
							if ( countryGroup ) then
								countryGroup:removeSelf()
								countryGroup = nil
							end
							countryGroup = display.newGroup()
							memberSearchGroup:insert( contientGroupNum, countryGroup )
							local countryListFrame = display.newImageRect( countryGroup, "assets/shadow-320480-paper.png", listFrameWidth, listFrameHeight)
							countryListFrame:addEventListener( "touch", function() return true; end )
							countryListFrame.anchorY = 0
							countryListFrame.x = cx
							countryListFrame.y = countryFrame.y+countryFrame.contentHeight

							local countryScrollView = widget.newScrollView({
								id = "countryScrollView",
								x = cx,
								y = countryFrame.y+countryFrame.contentHeight,
								width = listFrameWidth*0.95,
								height = listFrameHeight*59/60,
								isBounceEnabled = false,
								horizontalScrollDisabled = true,
								isLocked = true,
								backgroundColor = {1},
							})
							countryGroup:insert(countryScrollView)
							countryScrollView.anchorY = 0
							local countryScrollViewHeight = 0 
							local countryScrollViewGroup = display.newGroup()
							countryScrollView:insert(countryScrollViewGroup)
						-- 國家選單內容監聽事件
							local countryListText = {}
							local cancelCountrySelected = false
							local nowCountrySelection, prevCountrySelction = nil, nil
							local function countryListOptionListener( event )
								local  phase = event.phase
								if ( phase == "began" ) then
									if ( cancelCountrySelected == true ) then
										cancelCountrySelected = false
									end
									if ( nowCountrySelection == nil and prevCountrySelction == nil ) then
										nowCountrySelection = event.target
										nowCountrySelection:setFillColor( 0, 0, 0, 0.1)
										countryListText[nowCountrySelection.id]:setFillColor(unpack(subColor2))
									elseif ( nowCountrySelection == nil and prevCountrySelction ~= nil ) then
										if ( event.target ~= prevCountrySelction ) then
											
											countryListText[prevCountrySelction.id]:setFillColor(unpack(wordColor))

											nowCountrySelection = event.target
											nowCountrySelection:setFillColor( 0, 0, 0, 0.1)
											countryListText[nowCountrySelection.id]:setFillColor(unpack(subColor2))
										end
									end
								elseif ( phase == "moved" ) then
									cancelCountrySelected = true
									local dx = math.abs(event.xStart-event.x)
									local dy = math.abs(event.yStart-event.y)
									if (dx > 10 or dy > 10) then
										if (nowCountrySelection ~= nil) then
											countryScrollView:takeFocus(event)
											nowCountrySelection:setFillColor(1)
											countryListText[nowCountrySelection.id]:setFillColor(unpack(wordColor))
											nowCountrySelection = nil
											if (prevCountrySelction ~= nil) then
												countryListText[prevCountrySelction.id]:setFillColor(unpack(subColor2))
											end
										end
									end
								elseif ( phase == "ended" and cancelCountrySelected == false and nowCountrySelection ~= nil ) then
									-- 國家選框相關變化
										countryFrameText.text = countryListText[nowCountrySelection.id].text
										countryFrame.strokeWidth = 1
										countryFrame:setStrokeColor(unpack(separateLineColor))
										countryFrameTriangle:rotate(180)
										setStatus["countryFrameTriangle"] = "down"
									-- 選項選單變化
										local countryId = countryIdList[nowCountrySelection.id]
										nowCountrySelection:setFillColor(1)
										prevCountrySelction = nowCountrySelection
										nowCountrySelection = nil
										countryGroup.isVisible = false
										countrySelected = true
								end
								return true
							end
						-- 國家選單內容
							for i = 1, #countryListOptions do
								local countryListBase = display.newRect( countryScrollViewGroup, countryScrollView.contentWidth*0.5, listBasePadding+(listBaseHeight+listBasePadding)*(i-1), listBaseWidth, listBaseHeight )
								countryListBase.anchorY = 0
								countryListBase.id = i
								countryListBase:addEventListener( "touch", countryListOptionListener)
								--countryListBase:setFillColor( math.random(), math.random(), math.random())

								countryListText[i] = display.newText({
									parent = countryScrollViewGroup,
									text = countryListOptions[i],
									font = getFont.font,
									fontSize = 12,
									x = countryListBase.x,
									y = countryListBase.y+countryListBase.contentHeight*0.5,
								})
								countryListText[i]:setFillColor(unpack(wordColor))
								
								if ( i == #countryListOptions ) then
									countryScrollViewHeight = countryListBase.y+countryListBase.contentHeight+listBasePadding
									if ( countryScrollViewHeight > countryScrollView.contentHeight ) then
										countryScrollView:setScrollHeight( countryScrollViewHeight )
										countryScrollView:setIsLocked( false, "vertical")
									end
								end
							end	
							countryGroup.isVisible = false
							countryCover.isVisible = false
					end
					local getCountryUrl = "http://211.21.114.208/1.0/other/GetCountryListByContinentId/"..contientDecode[contientDecodeValue]
					network.request( getCountryUrl, "GET", getCountryInfo)	
			end
			return true
		end
	-- 洲別選單內容
		for i = 1, #contientOptions do
			local contientListBase = display.newRect( contientScrollViewGroup, contientScrollView.contentWidth*0.5, listBasePadding+(listBaseHeight+listBasePadding)*(i-1), listBaseWidth, listBaseHeight )
			contientListBase.anchorY = 0
			contientListBase.id = i
			contientListBase:addEventListener( "touch", contientListOptionListener)
			--contientListBase:setFillColor( math.random(), math.random(), math.random())

			contientListText[i] = display.newText({
				parent = contientScrollViewGroup,
				text = contientOptions[i],
				font = getFont.font,
				fontSize = 12,
				x = contientListBase.x,
				y = contientListBase.y+contientListBase.contentHeight*0.5,
			})
			contientListText[i]:setFillColor(unpack(wordColor))
			
			if ( i == #contientOptions ) then
				contientScrollViewHeight = contientListBase.y+contientListBase.contentHeight+listBasePadding
				if ( contientScrollViewHeight > contientScrollView.contentHeight ) then
					contientScrollView:setScrollHeight( contientScrollViewHeight )
					contientScrollView:setIsLocked( false, "vertical")
				end
			end
		end	
		contientGroup.isVisible = false		
	
	-- 性別下拉式選單 --
	-- 外框
		genderGroup = display.newGroup()
		memberSearchGroup:insert(genderGroup)
		local genderListFrame = display.newImageRect( genderGroup, "assets/shadow-320480-paper.png", listFrameWidth, listFrameHeight)
		genderListFrame:addEventListener("touch", function () return true ; end )
		genderListFrame.anchorY = 0
		genderListFrame.x = cx
		genderListFrame.y = genderFrame.y+genderFrame.contentHeight
	-- 性別選項 ScrollView
		local genderScrollView = widget.newScrollView({
				id = "genderScrollView",
				x = cx,
				y = genderFrame.y+genderFrame.contentHeight,
				width = listFrameWidth*0.95,
				height = listFrameHeight*59/60,
				horizontalScrollDisabled = true,
				isBounceEnabled = false,
				isLocked = true,
				backgroundColor = {1},
		})
		genderGroup:insert(genderScrollView)
		genderScrollView.anchorY = 0
		local genderScrollViewHeight = 0
		local genderScrollViewGroup = display.newGroup()
		genderScrollView:insert(genderScrollViewGroup)
	-- 觸碰性別內容的監聽事件
		local genderOptionText = {}
		local gendetCancelSelected = false
		local nowGenderSelection, prevGenderSelection = nil, nil
		local function genderListener( event )
			local phase = event.phase
			if (phase == "began") then
				if ( gendetCancelSelected == true ) then
					gendetCancelSelected = false
				end
				if ( nowGenderSelection == nil and prevGenderSelection == nil ) then
					nowGenderSelection = event.target
					nowGenderSelection:setFillColor( 0, 0, 0, 0.1)
					genderOptionText[nowGenderSelection.id]:setFillColor(unpack(subColor1))
				elseif ( nowGenderSelection == nil and prevGenderSelection ~= nil ) then
					if ( event.target ~= prevGenderSelection ) then

						genderOptionText[prevGenderSelection.id]:setFillColor(unpack(wordColor))

						nowGenderSelection = event.target
						nowGenderSelection:setFillColor( 0, 0, 0, 0.1)
						genderOptionText[nowGenderSelection.id]:setFillColor(unpack(subColor1))
					end
				end
			elseif (phase == "moved") then
				gendetCancelSelected = true
				local dx = math.abs(event.xStart-event.x)
				local dy = math.abs(event.yStart-event.y)
				if (dx > 10 or dy > 10) then
					if (nowGenderSelection ~= nil) then
						genderScrollView:takeFocus(event)
						nowGenderSelection:setFillColor(1)
						genderOptionText[nowGenderSelection.id]:setFillColor(unpack(wordColor))
						nowGenderSelection = nil
						if (prevGenderSelection ~= nil) then
							genderOptionText[prevGenderSelection.id]:setFillColor(unpack(subColor1))
						end
					end
				end
			elseif ( phase == "ended" and gendetCancelSelected == false and nowGenderSelection ~= nil ) then
				-- 性別選框相關變化
					genderFrameText.text = genderOptionText[nowGenderSelection.id].text
					genderFrame.strokeWidth = 1
					genderFrame:setStrokeColor(unpack(separateLineColor))
					genderFrameTriangle:rotate(180)
					setStatus["genderFrameTriangle"] = "down"
				-- 選項選單變化
					nowGenderSelection:setFillColor(1)
					prevGenderSelection = nowGenderSelection
					nowGenderSelection = nil
					genderSelected = true
					genderGroup.isVisible = false
			end
			return true
		end
	-- 性別選項內容
		for i = 1, #genderOptions do
			local genderListBase = display.newRect( genderScrollViewGroup, genderScrollView.contentWidth*0.5, listBasePadding+(listBaseHeight+listBasePadding)*(i-1), listBaseWidth, listBaseHeight )
			genderListBase.anchorY = 0
			genderListBase.id = i
			genderListBase:addEventListener( "touch", genderListener)
			--genderListBase:setFillColor( math.random(), math.random(), math.random())

			genderOptionText[i] = display.newText({
				parent = genderScrollViewGroup,
				text = genderOptions[i],
				font = getFont.font,
				fontSize = 12,
				x = genderListBase.x,
				y = genderListBase.y+genderListBase.contentHeight*0.5,
			})
			genderOptionText[i]:setFillColor(unpack(wordColor))
				
			if ( i == #genderOptions ) then
				genderScrollViewHeight = genderListBase.y+genderListBase.contentHeight+listBasePadding
				if ( genderScrollViewHeight > genderScrollView.contentHeight ) then
					genderScrollView:setScrollHeight( genderScrollViewHeight )
					genderScrollView:setIsLocked( false, "vertical")
				end
			end
		end	
		genderGroup.isVisible = false	
	------------------- 抬頭下拉式選單 -------------------
	-- 選單邊界
		local listOptions = optionsTable.TP_titleListOptions
		local listOptionScenes = optionsTable.TP_titleListScenes
		titleListBoundary = display.newContainer( screenW+ox+ox, screenH*0.5)
		sceneGroup:insert(titleListBoundary)
		titleListBoundary.anchorY = 0
		titleListBoundary.x = cx
		titleListBoundary.y = titleBase.y+titleBase.contentHeight*0.5
	-- 選項內容
		titleListGroup = display.newGroup()
		titleListBoundary:insert(titleListGroup)
		-- 邊界陰影
		local titleListShadow = display.newImageRect("assets/shadow-3.png", titleListBoundary.contentWidth, titleListBoundary.contentHeight)
		titleListGroup:insert(titleListShadow)
		titleListShadow:addEventListener("touch", function () return true ; end)
		titleListShadow:addEventListener("tap", function () return true ; end)
		-- 選單
		local titleListScrollView = widget.newScrollView({
			id = "titleListScrollView",
			width = titleListShadow.contentWidth*0.97,
			height = titleListShadow.contentHeight*0.98,
			isLocked = true,
			backgroundColor = {1},
		})
		titleListGroup:insert(titleListScrollView)
		titleListScrollView.x = 0
		titleListScrollView.y = 0
		local titleListScrollViewGroup = display.newGroup()
		titleListScrollView:insert(titleListScrollViewGroup)

		local optionBaseHeight = floor(titleListScrollView.contentHeight/#listOptions)
		local optionText = {}
		local defaultTarget, nowTarget, prevTarget = nil
		local isCanceled = false
		-- 選項監聽事件
		local function optionSelect( event )
			local phase = event.phase
			if (phase == "began") then
				if (isCanceled == true) then
					isCanceled = false
				end
				if (nowTarget == nil) then
					nowTarget = event.target
					nowTarget:setFillColor( 0, 0, 0, 0.1)
					optionText[nowTarget.id]:setFillColor(unpack(subColor2))

					display.getCurrentStage():setFocus(nowTarget)
				elseif (event.target ~= nowTarget and nowTarget ~= nil) then
					prevTarget = nowTarget
					optionText[prevTarget.id]:setFillColor(unpack(wordColor))

					nowTarget = event.target
					nowTarget:setFillColor( 0, 0, 0, 0.1)
					optionText[nowTarget.id]:setFillColor(unpack(subColor2))

					display.getCurrentStage():setFocus(nowTarget)
				end
			elseif (phase == "moved") then
				local dx = math.abs(event.xStart - event.x)
				local dy = math.abs(event.yStart - event.y)
				if (dy > 10 or dx > 10) then
					titleListScrollView:takeFocus(event)
					nowTarget:setFillColor(1)
					optionText[nowTarget.id]:setFillColor(unpack(wordColor))

					display.getCurrentStage():setFocus(nil)
					if (defaultTarget ~= nil) then
						optionText[defaultTarget.id]:setFillColor(unpack(subColor2))
						nowTarget = defaultTarget
					end
					isCanceled = true
				end
			elseif (phase == "ended" and isCanceled == false and nowTarget ~= defaultTarget) then
				display.getCurrentStage():setFocus(nil)
				transition.to(titleListGroup, { y = -titleListBoundary.contentHeight, time = 200})
				nowTarget:setFillColor(1)
				setStatus["listBtn"] = "down"
				if(listOptionScenes[nowTarget.id] ~= nil) then
					timer.performWithDelay(200, function() composer.gotoScene(listOptionScenes[nowTarget.id]) ; end)
				end
			end
		end
		for i = 1, #listOptions do
			-- 選項白底
			local optionBase = display.newRect(titleListScrollViewGroup, titleListScrollView.contentWidth*0.5, 0, titleListScrollView.contentWidth, optionBaseHeight)
			optionBase.y = optionBaseHeight*0.5+optionBaseHeight*(i-1)
			optionBase.id = i
			optionBase:addEventListener("touch",optionSelect)
			-- 選項文字
			optionText[i] = display.newText({
				parent = titleListScrollViewGroup,
				x = optionBase.contentWidth*0.5,
				y = optionBase.y,
				text = listOptions[i],
				font = getFont.font,
				fontSize = 12,
			})
			if (optionText[i].text == titleText.text) then 
				optionText[i]:setFillColor(unpack(subColor2))
				nowTarget = optionBase
				defaultTarget = optionBase
			else
				optionText[i]:setFillColor(unpack(wordColor))
			end
		end
		titleListGroup.y = -titleListBoundary.contentHeight
		titleListBoundary.isVisible = false
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
		composer.removeScene("TP_memberSearch")
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