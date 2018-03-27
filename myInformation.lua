-----------------------------------------------------------------------------------------
--
-- myInformation.lua
--
-----------------------------------------------------------------------------------------
local widget = require ("widget")
local composer = require ("composer")
local mainTabBar = require("mainTabBar")
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
local squareRate = math.sqrt(wRate*hRate)

if (composer.getVariable("getCountry")) then 
	getCountry = composer.getVariable("getCountry")
else
	getCountry = "鬼島"
end

local titleListBoundary, titleListGroup
local setStatus = {}
local gender

-- function Zone Start
local function ceil( value )
	return math.ceil(value)
end

local function floor( value )
	return math.floor(value)
end

local function onBtnListener( event )
	local id = event.target.id 
	if (id == "backBtn") then
		--mainTabBar.myTabBarShown()
		options = { time = 200, effect = "fade"}
		composer.gotoScene("findPartner", options)
	end
	if (id == "listBtn") then
		if (setStatus["listBtn"] == "up") then 
			setStatus["listBtn"] = "down"
			transition.to(titleListGroup,{ y = -titleListBoundary.contentHeight, time = 200})
			timer.performWithDelay(200, function() titleListBoundary.isVisible = false ;end)
		else
			setStatus["listBtn"] = "up"
			titleListBoundary.isVisible = true
			transition.to(titleListGroup,{ y = 0, time = 200})
		end
	end
	return true
end
-- function Zone End

-- create()
function scene:create( event )
    local sceneGroup = self.view
	mainTabBar.myTabBarHidden()
------------------- 背景元件 -------------------
	local background = display.newRect(cx,cy+oy,screenW+ox+ox,screenH+oy+oy)
	sceneGroup:insert(background)
	background:setFillColor(unpack(backgroundColor))
------------------- 抬頭元件 -------------------
-- 白底
	local titleBase = display.newRect(0, 0, screenW+ox+ox, floor(178*hRate))
	sceneGroup:insert(titleBase)
	titleBase.x = cx
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
-- 顯示文字-"我的資料"
	local titleText = display.newText({
		text = "我的資料",
		y = titleBase.y,
		font = getFont.font,
		fontSize = 14,
	})
	sceneGroup:insert(titleText)
	titleText:setFillColor(unpack(wordColor))
	titleText.anchorX = 0
	titleText.x = backArrow.x+backArrow.contentWidth+ceil(30*wRate)
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
 		onRelease = onBtnListener,
 	})
 	sceneGroup:insert(listIconNum,listBtn)
 	setStatus["listBtn"] = "down"
------------------- 第一區塊背景元件 -------------------
-- 藍底
	local blueBase = display.newImageRect("assets/bg-personalcenter.png",1080,506)
	sceneGroup:insert(blueBase)
	blueBase.width = (screenW+ox+ox)
	blueBase.height = floor(270*hRate)
	blueBase.x = cx
	blueBase.y = titleBase.y+(titleBase.contentHeight/2)+(blueBase.contentHeight/2)
-- 頭框
	local userPhotoFrame = display.newRoundedRect( -ox+ceil(40*wRate), -oy+floor(270*hRate), 318, 318, 4)
	sceneGroup:insert(userPhotoFrame)
	userPhotoFrame.anchorX = 0
	userPhotoFrame.anchorY = 0
	userPhotoFrame.width = userPhotoFrame.width*squareRate
	userPhotoFrame.height = userPhotoFrame.height*squareRate
-- 頭像
	local userPhotoArea = display.newRoundedRect( 0, 0, userPhotoFrame.contentWidth*0.95, userPhotoFrame.contentHeight*0.95, 2)
	sceneGroup:insert(userPhotoArea)
	userPhotoArea:setFillColor(unpack(separateLineColor))
	userPhotoArea.x = userPhotoFrame.x+userPhotoFrame.contentWidth*0.5
	userPhotoArea.y = userPhotoFrame.y+userPhotoFrame.contentHeight*0.5
	userPhotoArea.fill = { type = "image", filename = "assets/wow.jpg"}
-- 圖示-edit.png
	local editPic = display.newImageRect("assets/edit.png", 148, 148)
	sceneGroup:insert(editPic)
	editPic.width = ceil(editPic.width*0.2)
	editPic.height = ceil(editPic.height*0.2)
	editPic.anchorX = 1 
	editPic.anchorY = 1
	editPic.x = (screenW+ox)-ceil(35*wRate)
	editPic.y = -oy+titleBase.contentHeight+blueBase.contentHeight-ceil(30*hRate)
-- 顯示文字-用戶姓名	
	local nameText = display.newText({
		text = "妳的名字",
		font = getFont.font,
		fontSize = 18,
	})
	sceneGroup:insert(nameText)
	nameText:setFillColor(unpack(wordColor))
	nameText.anchorX = 0
	nameText.anchorY = 0
	nameText.x = userPhotoFrame.x+userPhotoFrame.contentWidth+ceil(30*wRate)
	nameText.y = -oy+titleBase.contentHeight+blueBase.contentHeight+ceil(60*hRate)
-- 圖示-性別
	local genderPic
	gender = "g"
	if (gender == "boy") then 
		genderPic = display.newImageRect("assets/boy.png", 320, 320)
	else
		genderPic = display.newImageRect("assets/girl.png", 320, 320)
	end
	sceneGroup:insert(genderPic)
	genderPic.width = genderPic.width*0.05
	genderPic.height = genderPic.height*0.05
	genderPic.anchorX = 0
	genderPic.x = nameText.x+nameText.contentWidth+ceil(30*wRate)
	genderPic.y = nameText.y+(nameText.contentHeight*0.5)
-- 分隔線1
	local sectorLine1 = display.newLine (-ox+blueBase.contentWidth*0.02, blueBase.y+blueBase.contentHeight*0.5+ceil(180*hRate), screenW+ox-blueBase.contentWidth*0.02, blueBase.y+blueBase.contentHeight*0.5+ceil(180*hRate))
	sceneGroup:insert(sectorLine1)
	sectorLine1:setStrokeColor(unpack(separateLineColor))
	sectorLine1.strokeWidth = 1
------------------- 個人訊息 (接API) -------------------
-- 顯示文字-年齡
	local ageInfoText = display.newText({
		text = "年齡：??歲",
		font = getFont.font,
		fontSize = 12,
	})
	sceneGroup:insert(ageInfoText)
	ageInfoText:setFillColor(unpack(wordColor))
	ageInfoText.anchorX = 0
	ageInfoText.anchorY = 0
	ageInfoText.x = -ox+ceil(49*wRate)
	ageInfoText.y = sectorLine1.y+floor(30*hRate)
-- 顯示文字-洲別
	local continentInfoText = display.newText({
		text = "洲別："..getCountry,
		font = getFont.font,
		fontSize = 12,
	})
	sceneGroup:insert(continentInfoText)
	continentInfoText:setFillColor(unpack(wordColor))
	continentInfoText.anchorX = 0
	continentInfoText.anchorY = 0
	continentInfoText.x = -ox+ceil(49*wRate)
	continentInfoText.y = ageInfoText.y+ageInfoText.contentHeight+floor(20*hRate)
-- 顯示文字-國家
	local countryInfoText = display.newText({
		text = "國家："..getCountry,
		font = getFont.font,
		fontSize = 12,
	})
	sceneGroup:insert(countryInfoText)
	countryInfoText:setFillColor(unpack(wordColor))
	countryInfoText.anchorX = 0
	countryInfoText.anchorY = 0
	countryInfoText.x = -ox+ceil(49*wRate)
	countryInfoText.y = continentInfoText.y+continentInfoText.contentHeight+floor(20*hRate)
-- 顯示文字-通用口語
	local languageInfoText = display.newText({
		text = "通用口語：鬼話",
		font = getFont.font,
		fontSize = 12,
	})
	sceneGroup:insert(languageInfoText)
	languageInfoText:setFillColor(unpack(wordColor))
	languageInfoText.anchorX = 0
	languageInfoText.anchorY = 0
	languageInfoText.x = -ox+ceil(49*wRate)
	languageInfoText.y = countryInfoText.y+countryInfoText.contentHeight+floor(20*hRate)
-- 顯示文字-喜歡旅行方式
	local tripInfoText = display.newText({
		text = "喜歡的旅行方式：飄阿飄阿飄阿飄!!",
		font = getFont.font,
		fontSize = 12,
	})
	sceneGroup:insert(tripInfoText)
	tripInfoText:setFillColor(unpack(wordColor))
	tripInfoText.anchorX = 0
	tripInfoText.anchorY = 0
	tripInfoText.x = -ox+ceil(49*wRate)
	tripInfoText.y = languageInfoText.y+languageInfoText.contentHeight+floor(20*hRate)
-- 分隔線2
	local sectorLine2 = display.newLine (-ox+blueBase.contentWidth*0.02, tripInfoText.y+tripInfoText.contentHeight+floor(30*hRate), screenW+ox-blueBase.contentWidth*0.02, tripInfoText.y+tripInfoText.contentHeight+floor(30*hRate))
	sceneGroup:insert(sectorLine2)
	sectorLine2:setStrokeColor(unpack(separateLineColor))
	sectorLine2.strokeWidth = 1
------------------- 關於我 -------------------
-- 圖示
	local aboutMePic = display.newImageRect("assets/tag-aboutme.png", 240, 240)
	sceneGroup:insert(aboutMePic)
	aboutMePic.width = aboutMePic.width*0.07
	aboutMePic.height = aboutMePic.height*0.07
	aboutMePic.anchorX = 0
	aboutMePic.x = -ox+ceil(40*wRate)
-- 顯示文字-關於我
	local aboutMeText = display.newText({
			text = "關於我",
			font = getFont.font,
			fontSize = 12,
		})
	sceneGroup:insert(aboutMeText)
	aboutMeText:setFillColor(unpack(wordColor))
	aboutMeText.anchorX = 0
	aboutMeText.anchorY = 0
	aboutMeText.x = aboutMePic.x+aboutMePic.contentWidth+ceil(30*wRate)
	aboutMeText.y = sectorLine2.y+floor(30*hRate)
	aboutMePic.y = aboutMeText.y+aboutMeText.contentHeight*0.5
-- 顯示文字-關於我內容
	local aboutMeInfo = display.newText({
			text = "我好無聊喔我好無聊喔我好無聊喔我好無聊喔我好無聊喔我好無聊喔我好無聊喔我好無聊喔我好無聊喔我好無聊喔我好無聊喔我好無聊喔我好無聊喔我好無聊喔我好無聊喔我好無聊喔我好無聊喔我好無聊喔我好無聊喔我好無聊喔我好無聊喔我好無聊喔我好無聊喔我好無聊喔我好無聊喔我好無聊喔我好無聊喔我好無聊喔我好無聊喔我好無聊喔我好無聊喔我好無聊喔我好無聊喔我好無聊喔我好無聊喔我好無聊喔我好無聊喔",
			font = getFont.font,
			fontSize = 12,
			width = (screenW+ox+ox)-ceil(40*wRate)*2,
			height = 0,
		})
	sceneGroup:insert(aboutMeInfo)
	aboutMeInfo:setFillColor(unpack(wordColor))
	aboutMeInfo.anchorX = 0
	aboutMeInfo.anchorY = 0
	aboutMeInfo.x = aboutMePic.x
	aboutMeInfo.y = aboutMeText.y+aboutMeText.contentHeight+floor(30*hRate)
-- 分隔線3
	local sectorLine3 = display.newLine (-ox+blueBase.contentWidth*0.02, aboutMeInfo.y+aboutMeText.contentHeight*10, screenW+ox-blueBase.contentWidth*0.02, aboutMeInfo.y+aboutMeText.contentHeight*10)
	sceneGroup:insert(sectorLine3)
	sectorLine3:setStrokeColor(unpack(separateLineColor))
	sectorLine3.strokeWidth = 1
------------------- 相簿 -------------------
-- 圖示
	local albumPic = display.newImageRect("assets/tag-album.png", 300, 240)
	sceneGroup:insert(albumPic)
	albumPic.width = albumPic.width*0.07
	albumPic.height = albumPic.height*0.07
	albumPic.anchorX = 0
	albumPic.x = -ox+ceil(40*wRate)
-- 顯示文字-相簿
	local albumText = display.newText({
			text = "相簿",
			font = getFont.font,
			fontSize = 12,
		})
	sceneGroup:insert(albumText)
	albumText:setFillColor(unpack(wordColor))
	albumText.anchorX = 0
	albumText.anchorY = 0
	albumText.x = albumPic.x+albumPic.contentWidth+ceil(30*wRate)
	albumText.y = sectorLine3.y+floor(30*hRate)
	albumPic.y = albumText.y+albumText.contentHeight*0.5

	local albumView1 = display.newRect( 0, 0, 100, 75)
	sceneGroup:insert(albumView1)
	albumView1:setFillColor(unpack(separateLineColor))
	albumView1.anchorX = 0
	albumView1.anchorY = 0
	albumView1.x = -ox+ceil(15*wRate)
	albumView1.y = albumText.y+albumText.contentHeight+ceil(25*wRate)

	local albumView2 = display.newRect( 0, 0, 100, 75)
	sceneGroup:insert(albumView2)
	albumView2:setFillColor(unpack(separateLineColor))
	albumView2.anchorX = 0
	albumView2.anchorY = 0
	albumView2.x = albumView1.x+albumView1.contentWidth+ceil(15*wRate)
	albumView2.y = albumView1.y

	local albumView3 = display.newRect( 0, 0, 100, 75)
	sceneGroup:insert(albumView3)
	albumView3:setFillColor(unpack(separateLineColor))
	albumView3.anchorX = 0
	albumView3.anchorY = 0
	albumView3.x = albumView2.x+albumView2.contentWidth+ceil(15*wRate)
	albumView3.y = albumView2.y
------------------- 抬頭下拉式選單 -------------------
-- 選單邊界
	local listOptions = { "尋找旅伴", "我的資料", "訊息中心", "我的相簿", "我的收藏", "會員搜尋", "其他設定", "免責聲明"}
	local listOptionScenes = { "findPartner", "myInformation", nil, "myAlbum", nil, "memberSearch", "otherSetting", "partnerDisclaimer"}
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
	--titleListScrollView.anchorY = 0
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
	for i=1,#listOptions do
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
        -- Code here runs when the scene is still off screen (but is about to come on screen)
 
    elseif ( phase == "did" ) then
        -- Code here runs when the scene is entirely on screen
 
    end
end

-- hide()
function scene:hide( event )
 
    local sceneGroup = self.view
    local phase = event.phase
 
    if ( phase == "will" ) then
        -- Code here runs when the scene is on screen (but is about to go off screen)
 
    elseif ( phase == "did" ) then
        -- Code here runs immediately after the scene goes entirely off screen
 		composer.removeScene("myInformation")
    end
end

-- destroy()
function scene:destroy( event )
 
    local sceneGroup = self.view
    -- Code here runs prior to the removal of scene's view
 
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