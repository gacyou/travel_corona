-----------------------------------------------------------------------------------------
--
-- advisorCenter.lua
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

local isFound = false

local clearTextBtn
local showAnswerPic = {}
local classifiedBtn,btnDropDownText,btnDropDownPic

local searchTextField

local problemTableGroup = {}
local answerContain = {}
local answerText = {}
local setStatus = {}
local dropDownListBoundary, dropDownListGroup
local commonQAGroup,queryGroup
local prevScene = composer.getSceneName( "previous" )
-- function Zone Start
local function ceil( value )
	return math.ceil(value)
end

local function floor( value )
	return math.floor(value)
end

-- function Zone End

-- create()
function scene:create( event )
	local sceneGroup = self.view
	mainTabBar.myTabBarHidden()
	local getBackScene = event.params.backScene
	-- 按鈕的監聽事件
	local function onBtnListener( event )
		local id = event.target.id
		if (id == "backBtn") then
			local options = {
				effect = "fade",
				time = 200
			}
			composer.gotoScene(getBackScene,options)
		end
		if (id == "searchBtn") then
			local phase = event.phase
			if (phase == "began") then
				event.target.alpha = 0.3
			end
			if (phase == "ended") then
				event.target.alpha = 1
				commonQAGroup.isVisible = false
				problemTableGroup[1].isVisible = false
				problemTableGroup[2].isVisible = false
				problemTableGroup[3].isVisible = false
				problemTableGroup[4].isVisible = false
				if (isFound == false) then
					queryGroup.isVisible = true
				end
			end
		end
		if (id == "classifiedBtn") then 
			-- 問題分類按鍵事件
			btnDropDownPic:rotate(180)
			if (setStatus["dropDown"] == "up") then 
				setStatus["dropDown"] = "down"
				transition.to(dropDownListGroup,{ y = -dropDownListBoundary.contentHeight, time = 300})
				timer.performWithDelay(300, function() dropDownListBoundary.isVisible = false ;end)
				timer.performWithDelay(300, function() searchTextField.isVisible = true ;end)
			else
				setStatus["dropDown"] = "up"
				searchTextField.isVisible = false
				dropDownListBoundary.isVisible = true
				transition.to(dropDownListGroup,{ y = 0, time = 300})
			end
		end
		if (id == "clearTextBtn") then 
			searchTextField.text = ""
		end
		if (id == "queryBtn") then 
			local options = { 
				effect = "fade", 
				time = 200,
				params = {
					backScene = getBackScene
				}
			}
			composer.gotoScene("queryFunRoad", options)
		end
		if (id == "queryRecordBtn") then 
			--print(id)
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
------------------- 背景元件 -------------------
	local background = display.newRect(cx,cy,screenW+ox+ox,screenH+oy+oy)
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
-- 顯示文字-"諮詢中心"
	local titleText = display.newText({
		text = "諮詢中心",
		y = titleBase.y,
		font = getFont.font,
		fontSize = 14,
	})
	sceneGroup:insert(titleText)
	titleText:setFillColor(unpack(wordColor))
	titleText.anchorX = 0
	titleText.x = backArrow.x+backArrow.contentWidth+(30*wRate)
-- 問題分類按鈕
	classifiedBtn = widget.newButton({
			id = "classifiedBtn",
			defaultFile = "assets/toggle-qatopright.png",
			width = 294*wRate,
			height = 73*wRate,
			onRelease = onBtnListener,
		}) 
	sceneGroup:insert(classifiedBtn)
	classifiedBtn.anchorX = 1
	classifiedBtn.x = screenW+ox-ceil(30*wRate)
	classifiedBtn.y = backBtn.y
-- 顯示文字-"問題分類"
	btnDropDownText = display.newText({
		text = "問題分類",
		font = getFont.font,
		fontSize = 14,
	})
	sceneGroup:insert(btnDropDownText)
	btnDropDownText.x = classifiedBtn.x - classifiedBtn.contentWidth*0.58
	btnDropDownText.y = classifiedBtn.y
-- 箭頭圖片
	btnDropDownPic = display.newImageRect("assets/btn-dropdown-w.png",252,162)
	sceneGroup:insert(btnDropDownPic)
	btnDropDownPic.width = (btnDropDownPic.width*0.05)
	btnDropDownPic.height = (btnDropDownPic.height*0.05)
	btnDropDownPic.x = classifiedBtn.x-(classifiedBtn.contentWidth*0.15)
	btnDropDownPic.y = classifiedBtn.y
	setStatus["dropDown"] = "down"
------------------- 搜尋元件 -------------------
-- 白底	
	local searchBase = display.newRect(0, 0, screenW+ox+ox, floor(178*hRate))
	sceneGroup:insert(searchBase)
	searchBase.x = cx
	searchBase.y = titleBase.y+titleBase.contentHeight*0.5+searchBase.contentHeight*0.5
-- 抬頭陰影	
	local titleBaseShadow = display.newImage( sceneGroup, "assets/s-down.png", titleBase.x, titleBase.y+titleBase.contentHeight*0.5)
	titleBaseShadow.anchorY = 0
	titleBaseShadow.width = titleBase.contentWidth
	titleBaseShadow.height = floor(titleBaseShadow.height*0.5)
-- 搜尋按鈕	
	local searchBtn = widget.newButton({
			id = "searchBtn",
			defaultFile = "assets/btn-search-b.png",
			width = 261,
			height = 261,
			onEvent = onBtnListener,
		})
	sceneGroup:insert(searchBtn)
	searchBtn.width = (searchBtn.width*0.07)
	searchBtn.height = (searchBtn.height*0.07)
	searchBtn.anchorX = 0
	searchBtn.x = -ox+(45*wRate)
	searchBtn.y = searchBase.y
-- 輸入外框圖
	local searchFrame = display.newImageRect("assets/enter-search-b-short.png",648,108)
	sceneGroup:insert(searchFrame)
	searchFrame.width = screenW+ox-(30*wRate)-(searchBtn.x+searchBtn.contentWidth+ceil(30*wRate))
	searchFrame.height = searchBase.contentHeight*0.7
	searchFrame.anchorX = 0
	searchFrame.x = searchBtn.x+searchBtn.contentWidth+ceil(30*wRate)
	searchFrame.y = searchBtn.y
-- 輸入方框
	searchTextField = native.newTextField( searchFrame.x+ceil(30*wRate), searchBtn.y, searchFrame.contentWidth*0.85, searchFrame.contentHeight*0.8)
	sceneGroup:insert(searchTextField)
	searchTextField.anchorX = 0
	searchTextField.font = getFont.font
	--searchTextField.size = 18
	searchTextField.hasBackground = false
	searchTextField.placeholder = "輸入關鍵字搜尋問題與答案"
	searchTextField:setSelection(1,1)
	searchTextField:resizeFontToFitHeight()
	searchTextField.isVisible = false
-- 清除所有輸入文字的按鈕 
	clearTextBtn = widget.newButton({
			id = "clearTextBtn",
			width = 241,
			height = 240,
			defaultFile = "assets/btn-search-delete.png",
			onPress = onBtnListener
		})
	sceneGroup:insert(clearTextBtn)
	clearTextBtn.width = (clearTextBtn.width*0.09)
	clearTextBtn.height = (clearTextBtn.height*0.09)
	clearTextBtn.anchorX = 0 
	clearTextBtn.x = searchTextField.x + searchTextField.contentWidth +(searchFrame.contentWidth*0.01)
	clearTextBtn.y = searchBtn.y
	clearTextBtn.isVisible = false
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
	searchTextField:addEventListener("userInput",textListener)
------------------- 常見問題元件 -------------------
-- 常見問題答案元件
-- 因為Group Hierarchy的關係，答案文字順序需由下往上增加
-- 常見問題
	commonQAGroup = display.newGroup()
	sceneGroup:insert(commonQAGroup)	
	local questionTextBkg = display.newRect( 0, 0, screenW+ox+ox, 30)
	commonQAGroup:insert(questionTextBkg)
	questionTextBkg:setFillColor(unpack(backgroundColor))
	questionTextBkg.x = cx 
	questionTextBkg.y = searchBase.y+(searchBase.contentHeight/2)+(questionTextBkg.contentHeight/2)
-- 搜尋陰影	
	local searchBaseShadow = display.newImage( sceneGroup, "assets/s-down.png", searchBase.x, searchBase.y+searchBase.contentHeight*0.5)
	searchBaseShadow.anchorY = 0
	searchBaseShadow.width = titleBase.contentWidth
	searchBaseShadow.height = floor(searchBaseShadow.height*0.5)
-- 顯示文字-"常見問題"
	local questionText = display.newText({
			text = "常見問題",
			font = getFont.font,
			fontSize = 10,			
		})
	commonQAGroup:insert(questionText)
	questionText:setFillColor(unpack(wordColor))
	questionText.anchorX = 0
	questionText.anchorY = 0
	questionText.x = -ox+ceil(30*wRate)
	questionText.y = searchBase.y+(searchBase.contentHeight/2)+floor(40*hRate)
-- 常見問題選單觸碰監聽事件
	local function questionListener( event )
		local phase = event.phase
		if (phase == "ended") then
			local index = event.target.index
			local num = #problemTableGroup
			if ( event.target.name == "problemBase") then
				showAnswerPic[index]:rotate(180)
				if (setStatus[index] == "down") then
					-- 展開問題欄位
					transition.to( answerText[index], { y = 0, time = 300})
					event.target:removeEventListener("touch",questionListener)
					for i = index, num do
						if ( (i+1) <= num ) then
							transition.to( problemTableGroup[i+1], { y = problemTableGroup[i+1].y+answerText[i].contentHeight, time = 300})
							problemTableGroup[i+1].y = problemTableGroup[i+1].y+answerText[i].contentHeight
						end
					end
					setStatus[index] = "up"
					timer.performWithDelay(300, function ()
						event.target:addEventListener("touch",questionListener)
					end)
				else
					-- 收回問題欄位
					transition.to( answerText[index], { y = -answerText[index].contentHeight, time = 300})
					event.target:removeEventListener("touch",questionListener)
					for i=index, num do
						if ( (i+1) <= num ) then
							transition.to( problemTableGroup[i+1], { y = problemTableGroup[i+1].y-answerText[i].contentHeight, time = 300})
							problemTableGroup[i+1].y = problemTableGroup[i+1].y-answerText[i].contentHeight
						end
					end
					setStatus[index] = "down"
					timer.performWithDelay(300, function ()
						event.target:addEventListener("touch",questionListener)
					end)
				end
			end
		end
		return true
	end
-- 常見問題選單
	local problemNum
	for i=1,4 do
		-- 問題的欄位跟箭頭
		problemTableGroup[i] = display.newGroup()
		if (i == 1 ) then
			sceneGroup:insert(problemTableGroup[i])
			problemNum = sceneGroup.numChildren
		else
			sceneGroup:insert(problemNum,problemTableGroup[i])
		end
		-- 問題白底
		local problemBase = display.newRect(0,0,screenW+ox+ox,(120*hRate))
		problemTableGroup[i]:insert(problemBase)
		problemBase.anchorY = 0
		problemBase.x = cx
		problemBase.y = questionText.y+questionText.contentHeight+floor(10*hRate)+(120*hRate)*(i-1)
		problemBase.name = "problemBase"
		problemBase.index = i
		problemBase:addEventListener("touch",questionListener)
		-- 白底陰影
		local problemBaseShadow = display.newImage( problemTableGroup[i], "assets/s-down.png", problemBase.x, problemBase.y+problemBase.contentHeight)
		problemBaseShadow.anchorY = 0
		problemBaseShadow.width = problemBase.contentWidth
		problemBaseShadow.height = floor(problemBaseShadow.height*0.5)
		-- 顯示文字-問題
		local problemText = display.newText({
				text = "我是常見問題我是常見問題我是常見問題"..i,
				font = getFont.font,
				fontSize = 10,
			})
		problemTableGroup[i]:insert(problemText)
		problemText:setFillColor(unpack(wordColor))
		problemText.anchorX = 0
		problemText.x = questionText.x
		problemText.y = problemBase.y+problemBase.contentHeight*0.5
		-- 問題箭頭
		showAnswerPic[i] = display.newImageRect("assets/btn-dropdown-dg.png",256,168)
		problemTableGroup[i]:insert(showAnswerPic[i])
		showAnswerPic[i].width = (showAnswerPic[i].width*0.05)
		showAnswerPic[i].height = (showAnswerPic[i].height*0.05)
		showAnswerPic[i].x = screenW+ox-ceil(40*wRate)-(showAnswerPic[i].contentWidth/2)
		showAnswerPic[i].y = problemText.y
		showAnswerPic[i].index = i
		setStatus[i] = "down"
		-- 顯示文字-答案
		answerText[i] = display.newText({
			text = "1.常見問題答案常見問題答案常見問題答案常見問題答案\n2.常見問題答案常見問題答案常見問題答案常見問題答案\n3.常見問題答案常見問題答案常見問題答案常見問題答案\n4.常見問題答案常見問題答案常見問題答案常見問題答案\n5.常見問題答案常見問題答案常見問題答案常見問題答案\n6.常見問題答案常見問題答案常見問題答案常見問題答案\n",
			font = getFont.font,
			fontSize = 10,
			width = problemBase.contentWidth*0.9,
			height = 0,		
		})
		answerText[i]:setFillColor(unpack(wordColor))
		answerContain[i] = display.newContainer(problemBase.contentWidth*0.9, answerText[i].contentHeight)
		problemTableGroup[i]:insert(answerContain[i])
		answerContain[i]:insert(answerText[i])
		answerContain[i].anchorY = 0
		answerContain[i].x = cx
		answerContain[i].y = problemBaseShadow.y+problemBaseShadow.contentHeight
		answerText[i].y = -answerText[i].contentHeight
	end
------------------- 底部按鈕元件 -------------------
-- 白底
	local btnBase = display.newRect(0,0,screenW+ox+ox,screenH/12)
	sceneGroup:insert(btnBase)
	btnBase.anchorY = 1
	btnBase.x = cx
	btnBase.y = screenH+oy
	local btnBaseShadow = display.newImageRect("assets/shadow.png", 1068, 476)
	sceneGroup:insert(btnBaseShadow)
	btnBaseShadow.width = (btnBaseShadow.width*0.33)+ox+ox
	btnBaseShadow.height = (btnBase.height*1.05)
	btnBaseShadow.x = btnBase.x
	btnBaseShadow.y = btnBase.y
-- 諮詢奮路鳥按鈕
	local queryBtn = widget.newButton({
			id = "queryBtn",
			defaultFile = "assets/btn-order.png",
			width = 451,
			height = 120,
			onPress = onBtnListener,
		})
	sceneGroup:insert(queryBtn)
	queryBtn.width = btnBase.contentWidth/2-(22*wRate)-((22*wRate)/2)
	queryBtn.height = (120*hRate)
	queryBtn.anchorX = 0
	queryBtn.x = -ox + (22*wRate)
	queryBtn.y = btnBase.y-btnBase.contentHeight*0.5
	local queryPic = display.newImageRect("assets/commenting-o-w.png",280,240)
	sceneGroup:insert(queryPic)
	queryPic.anchorX = 0
	queryPic.x = queryBtn.x+(queryBtn.contentWidth*0.2)
	queryPic.y = queryBtn.y
	queryPic.width = (queryPic.width*0.05)
	queryPic.height = (queryPic.height*0.05)
	local queryText = display.newText({
			text = "諮詢奮路鳥",
			font = getFont.font,
			fontSize = 14,			
		})
	sceneGroup:insert(queryText)
	queryText.anchorX = 0
	queryText.x = queryPic.x+queryPic.contentWidth+(22*wRate)
	queryText.y = queryPic.y
-- 諮詢記錄按鈕
	local queryRecordBtn = widget.newButton({
			id = "queryRecordBtn",
			defaultFile = "assets/btn-addtocart.png",
			width = 451,
			height = 120,
			onPress = onBtnListener,
		})
	sceneGroup:insert(queryRecordBtn)
	queryRecordBtn.width = btnBase.contentWidth/2-(22*wRate)-((22*wRate)/2)
	queryRecordBtn.height = (120*hRate)
	queryRecordBtn.anchorX = 0
	queryRecordBtn.x = queryBtn.x+queryBtn.contentWidth+(22*wRate)
	queryRecordBtn.y = queryBtn.y
	local queryRecordPic = display.newImageRect("assets/file-text-o-w.png",240,280)
	sceneGroup:insert(queryRecordPic)
	queryRecordPic.anchorX = 0
	queryRecordPic.x = queryRecordBtn.x+(queryRecordBtn.contentWidth*0.2)
	queryRecordPic.y = queryRecordBtn.y
	queryRecordPic.width = (queryRecordPic.width*0.05)
	queryRecordPic.height = (queryRecordPic.height*0.05)
	local queryRecordText = display.newText({
			text = "諮詢紀錄",
			font = getFont.font,
			fontSize = 14,		
		})
	sceneGroup:insert(queryRecordText)
	queryRecordText.anchorX = 0
	queryRecordText.x = queryRecordPic.x+queryRecordPic.contentWidth+(22*wRate)
	queryRecordText.y = queryRecordPic.y
---------------------------------------------------------------------------------------------------
-- 搜尋結果
-- 找不到任何結果
	queryGroup = display.newGroup()
	sceneGroup:insert(queryGroup)
	local funBirdPic = display.newImageRect("assets/img-bird.png",142,229)
	queryGroup:insert(funBirdPic)
	funBirdPic.width = (funBirdPic.contentWidth*0.3)
	funBirdPic.height = (funBirdPic.contentHeight*0.3)
	funBirdPic.x = cx
	funBirdPic.y = -oy+(cy*0.9)
	local text1 = display.newText({
			text = "找不到相關結果",
			font = getFont.font,
			fontSize = 14,				
		})
	queryGroup:insert(text1)
	text1:setFillColor(unpack(wordColor))
	text1.x = cx
	text1.y = -oy+(cy*1.15)
	queryGroup.isVisible = false
------------------- 問題下拉式選單 -------------------
-- 選單邊界
	local listOptions = { "預訂流程", "支付", "優惠&積分", "退改活動", "帳戶設置"}
	dropDownListBoundary = display.newContainer( screenW+ox+ox, screenH*0.4)
	sceneGroup:insert(dropDownListBoundary)
	dropDownListBoundary.anchorY = 0
	dropDownListBoundary.x = cx
	dropDownListBoundary.y = titleBase.y+titleBase.contentHeight*0.5
-- 選單外框
	dropDownListGroup = display.newGroup()
	dropDownListBoundary:insert(dropDownListGroup)
	-- 邊界陰影
	local textBaseShadow = display.newImageRect("assets/shadow-3.png", dropDownListBoundary.contentWidth, dropDownListBoundary.contentHeight)
	dropDownListGroup:insert(textBaseShadow)
	textBaseShadow:addEventListener("touch", function () return true ; end)
	textBaseShadow:addEventListener("tap", function () return true ; end)
	-- 選單
	local dropDownListScrollView = widget.newScrollView({
		id = "dropDownListScrollView",
		width = textBaseShadow.contentWidth*0.96875,
		height = textBaseShadow.contentHeight*0.98,
		isLocked = true,
		backgroundColor = {1},
	})
	dropDownListGroup:insert(dropDownListScrollView)
	dropDownListScrollView.x = 0
	dropDownListScrollView.y = 0
	local dropDownListScrollViewGroup = display.newGroup()
	dropDownListScrollView:insert(dropDownListScrollViewGroup)

	local optionBaseHeight = floor(dropDownListScrollView.contentHeight/#listOptions)
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
				dropDownListScrollView:takeFocus(event)
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
			transition.to(dropDownListGroup, { y = -dropDownListBoundary.contentHeight, time = 200})
			timer.performWithDelay(200, function() searchTextField.isVisible = true ;end)
			nowTarget:setFillColor(1)
			setStatus["dropDown"] = "down"
		end
	end
	for i=1,#listOptions do
		-- 選項白底
		local optionBase = display.newRect(dropDownListScrollViewGroup, dropDownListScrollView.contentWidth*0.5, 0, dropDownListScrollView.contentWidth, optionBaseHeight)
		optionBase.y = optionBaseHeight*0.5+optionBaseHeight*(i-1)
		optionBase.id = i
		optionBase:addEventListener("touch",optionSelect)
		-- 選項文字
		optionText[i] = display.newText({
			parent = dropDownListScrollViewGroup,
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
	dropDownListGroup.y = -dropDownListBoundary.contentHeight
	dropDownListBoundary.isVisible = false
end

-- show()
function scene:show( event )
	local sceneGroup = self.view
	local phase = event.phase
	if ( phase == "will" ) then
	elseif ( phase == "did" ) then
		searchTextField.isVisible = true
	end
end

-- hide()
function scene:hide( event )
	local sceneGroup = self.view
	local phase = event.phase
	if ( phase == "will" ) then
 		searchTextField.isVisible = false
	elseif ( phase == "did" ) then
		composer.removeScene("advisorCenter")
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