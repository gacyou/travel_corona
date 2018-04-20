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
--
local level = 1.25
local isFound = false

local searchTextField

local setStatus = {}
local queryGroup

local ceil = math.ceil
local floor = math.floor

-- create()
function scene:create( event )
	local sceneGroup = self.view
	mainTabBar.myTabBarHidden()
	local getBackScene = event.params.backScene
	-- QA-All讀檔
		local qaPattern = "(%w)%:(.+)"
		local qaPath = system.pathForFile( "Font_Data/QA-All.txt", system.ResourceDirectory )
		local qaFile = io.open(qaPath, "r")
		local qaList = {}
		if not qaFile then 
			print("File is not found")
		else
			local contents = qaFile:read("*l")
			local count = 1
			while (contents ~= nil) do
				qaList[count] = contents
				count = count+1
				contents = qaFile:read("*l")
			end
			io.close( qaFile )
			qaFile = nil
		end
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
			onRelease = function(event)
				local options = {
					effect = "fade",
					time = 200
				}
				composer.gotoScene(getBackScene,options)
				return true
			end,
		})
		sceneGroup:insert(backArrowNum,backBtn)
	-- 顯示文字-"諮詢中心"
		local titleText = display.newText({
			text = "諮詢中心",
			y = titleBase.y,
			font = getFont.font,
			fontSize = 18,
		})
		sceneGroup:insert(titleText)
		titleText:setFillColor(unpack(wordColor))
		titleText.anchorX = 0
		titleText.x = backArrow.x+backArrow.contentWidth+(30*wRate)
	-- 問題分類按鈕
		local btnDropDownPic
		local dropDownListBoundary, dropDownListGroup
		local classifiedBtn = widget.newButton({
				id = "classifiedBtn",
				defaultFile = "assets/toggle-qatopright.png",
				width = 294*wRate,
				height = 73*wRate,
				onRelease = function(event)
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
					return true
				end,
			}) 
		sceneGroup:insert(classifiedBtn)
		classifiedBtn.anchorX = 1
		classifiedBtn.x = screenW+ox-ceil(30*wRate)
		classifiedBtn.y = backBtn.y
	-- 顯示文字-"預定流程"
		local btnDropDownText = display.newText({
			text = "預定流程",
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
	------------------- 底部按鈕元件 -------------------
	-- 白底
		local buttonGroup = display.newGroup()
		sceneGroup:insert(buttonGroup)
		local btnBase = display.newRect(0,0,screenW+ox+ox,screenH/12)
		buttonGroup:insert(btnBase)
		btnBase.anchorY = 1
		btnBase.x = cx
		btnBase.y = screenH+oy
	-- 諮詢奮路鳥按鈕
		local queryBtn = widget.newButton({
			id = "queryBtn",
			defaultFile = "assets/btn-order.png",
			width = 451,
			height = 120,
			onRelease = function()
				local options = { 
					effect = "fade", 
					time = 200,
					params = {
						backScene = getBackScene
					}
				}
				composer.gotoScene("queryFunRoad", options)
				return true
			end,
		})
		buttonGroup:insert(queryBtn)
		queryBtn.width = btnBase.contentWidth/2-(22*wRate)-((22*wRate)/2)
		queryBtn.height = (120*hRate)
		queryBtn.anchorX = 0
		queryBtn.x = -ox + (22*wRate)
		queryBtn.y = btnBase.y-btnBase.contentHeight*0.5
		local queryPic = display.newImageRect("assets/commenting-o-w.png",280,240)
		buttonGroup:insert(queryPic)
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
		buttonGroup:insert(queryText)
		queryText.anchorX = 0
		queryText.x = queryPic.x+queryPic.contentWidth+(22*wRate)
		queryText.y = queryPic.y
	-- 諮詢記錄按鈕
		local queryRecordBtn = widget.newButton({
			id = "queryRecordBtn",
			defaultFile = "assets/btn-addtocart.png",
			width = 451,
			height = 120,
			onRelease = function()
				local options = { 
					effect = "fade", 
					time = 200,
					params = {
						backScene = getBackScene
					}
				}
				composer.gotoScene("queryRecord", options)
				return true
			end,
		})
		buttonGroup:insert(queryRecordBtn)
		queryRecordBtn.width = btnBase.contentWidth/2-(22*wRate)-((22*wRate)/2)
		queryRecordBtn.height = (120*hRate)
		queryRecordBtn.anchorX = 0
		queryRecordBtn.x = queryBtn.x+queryBtn.contentWidth+(22*wRate)
		queryRecordBtn.y = queryBtn.y
		local queryRecordPic = display.newImageRect("assets/file-text-o-w.png",240,280)
		buttonGroup:insert(queryRecordPic)
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
		buttonGroup:insert(queryRecordText)
		queryRecordText.anchorX = 0
		queryRecordText.x = queryRecordPic.x+queryRecordPic.contentWidth+(22*wRate)
		queryRecordText.y = queryRecordPic.y
		buttonGroup.isVisible = false
	------------------- 常見問題元件 -------------------
	-- 因為Group Hierarchy的關係，答案文字順序需由下往上增加
	-- 常見問題scrollview
		local setScrollViewHeight
		if ( buttonGroup.isVisible == false ) then
			setScrollViewHeight = screenH+oy+oy-(titleBase.contentHeight+searchBase.contentHeight)
		else
			setScrollViewHeight = screenH+oy+oy-(titleBase.contentHeight+searchBase.contentHeight+btnBase.contentHeight)
		end
		local qaScrollView = widget.newScrollView({
			id = "qaScrollView",
			top = searchBase.y+searchBase.contentHeight*0.5,
			left = -ox,
			width = screenW+ox+ox,
			height = setScrollViewHeight,
			isBounceEnabled = false,
			horizontalScrollDisabled = true,
			isLocked = true,
			backgroundColor = backgroundColor,
		})
		sceneGroup:insert(qaScrollView)
		local qaScrollViewGroup = display.newGroup()
		qaScrollView:insert(qaScrollViewGroup)
	-- 搜尋欄底部陰影
		local searchBaseShadow = display.newImage( sceneGroup, "assets/s-down.png", searchBase.x, searchBase.y+searchBase.contentHeight*0.5)
		searchBaseShadow.anchorY = 0
		searchBaseShadow.width = titleBase.contentWidth
		searchBaseShadow.height = floor(searchBaseShadow.height*0.5)
	-- 底部按鈕欄陰影
		local btnBaseShadow = display.newImage("assets/s-up.png", btnBase.x, btnBase.y-btnBase.contentHeight)
		buttonGroup  :insert(btnBaseShadow)
		btnBaseShadow.anchorY = 1
		btnBaseShadow.width = screenW+ox+ox
		btnBaseShadow.height = btnBaseShadow.height*0.5
	-- 顯示文字-"常見問題"
		local questionText = display.newText({
			--parent = qaScrollView,
			text = "常見問題",
			font = getFont.font,
			fontSize = 14,			
		})
		qaScrollView:insert(questionText)
		questionText:setFillColor(unpack(wordColor))
		questionText.anchorX = 0
		questionText.anchorY = 0
		questionText.x = ceil(30*wRate)
		questionText.y = floor(40*hRate)*level
	-- 問題集 --
	-- 處理文字檔
		local path = system.pathForFile( "Font_Data/QA-PreOrder.txt", system.ResourceDirectory )
		local file = io.open(path, "r")
		local list = {}
		if not file then 
			print("File is not found")
		else
			local contents = file:read("*l")
			local count = 1
			while (contents ~= nil) do
				list[count] = contents
				count = count+1
				contents = file:read("*l")
			end
			io.close( file )
			file = nil
		end
		local questionTable = {}
		local answerTable = {}
		for k,v in pairs(list) do
			local prefix, suffix = v:match(qaPattern)
			if ( prefix == "Q" ) then
				table.insert( questionTable, suffix)
			else
				table.insert( answerTable, suffix)
			end
		end
		list = {nil}
	-- 常見問題選單觸碰監聽事件
		local qaLocked = true
		local isExtend = false
		local qaScrollHeight = 0
		
		local QATable = {}
		local answerText = {}
		local answerContainer = {}
		local answerArrow = {}

		local searchGroupTable = {}
		local searchResultAnswerText = {}
		local searchResultContainer = {}
		local searchResultArrow = {}
		--local extendLine, shrinkLine = nil, nil
		local function questionListener( event )
			local phase = event.phase
			local index = event.target.index 
			local qaX, qaY = qaScrollView:getContentPosition()
			local num, groupTable, text, container, arrow, arrowText
			if ( phase == "moved" ) then
				qaScrollView:takeFocus(event)
			elseif ( phase == "ended" ) then
				--[[
					local hintRoundedRect = widget.newButton({
						x = cx,
						y = (screenH+oy+oy)*0.6,
						isEnabled = false,
						fillColor = { default = { 0, 0, 0, 0.6}, over = { 0, 0, 0, 0.6}},
						shape = "roundedRect",
						width = screenW*0.35,
						height = screenH/16,
						cornerRadius = 20,
					})
					local hintRoundedRectText = display.newText({
						text = "",
						font = getFont.font,
						fontSize = 14,
						x = hintRoundedRect.x,
						y = hintRoundedRect.y,
					})

					local hintRoundedRect2 = widget.newButton({
						x = cx,
						y = (screenH+oy+oy)*0.7,
						isEnabled = false,
						fillColor = { default = { 0, 0, 0, 0.6}, over = { 0, 0, 0, 0.6}},
						shape = "roundedRect",
						width = screenW*0.35,
						height = screenH/16,
						cornerRadius = 20,
					})
					local hintRoundedRectText2 = display.newText({
						text = "",
						font = getFont.font,
						fontSize = 14,
						x = hintRoundedRect2.x,
						y = hintRoundedRect2.y,
					})
				]]--
				if ( event.target.name == "problemBase") then
					num = #QATable
					groupTable = QATable
					text = answerText
					container = answerContainer
					arrow = answerArrow
					arrowText = "qaArrow"..index
				elseif ( event.target.name == "resultBase") then
					num = #searchGroupTable
					groupTable = searchGroupTable
					text = searchResultAnswerText
					container = searchResultContainer
					arrow = searchResultArrow
					arrowText = "searchArrow"..index
				end
				arrow[index]:rotate(180)
				if ( setStatus[arrowText] == "down" ) then
					-- 展開問題欄位
					setStatus[arrowText] = "up"
					transition.to( text[index], { y = 0, time = 200 } ) -- 展開答案
					event.target:removeEventListener( "touch", questionListener )
					-- 重新計算每一個問題的座標
					for i = index, num do
						if ( (i+1) <= num ) then
							transition.to( groupTable[i+1], { y = groupTable[i+1].y+container[index].contentHeight, time = 200 } )
							groupTable[i+1].y = groupTable[i+1].y+container[index].contentHeight
						end
					end
					
					if ( isExtend == false ) then
						qaScrollHeight = groupTable[index].y+container[num].y+container[index].contentHeight
						isExtend = true
					else
						qaScrollHeight = qaScrollHeight+container[index].contentHeight
					end

					if ( qaScrollHeight > qaScrollView.contentHeight ) then
						qaScrollView:setIsLocked( false, vertical )
						qaLocked = false
						qaScrollView:setScrollHeight( qaScrollHeight )
						if ( event.y > 360 ) then
							qaScrollView:scrollToPosition( { y = qaY-container[index].contentHeight, time = 200 } )
						end
						--qaScrollView:scrollToPosition( { y = -(qaScrollHeight-qaScrollView.contentHeight), time = 200 } )
					end
					timer.performWithDelay( 200, function() event.target:addEventListener( "touch", questionListener ); end)
					--[[
						if ( extendLine == nil ) then
							extendLine = display.newLine( qaScrollViewGroup, 0, qaScrollHeight, qaScrollView.contentWidth, qaScrollHeight)
							extendLine:setStrokeColor( 1, 0, 0 )
						else
							extendLine:removeSelf()
							extendLine = display.newLine( qaScrollViewGroup, 0, qaScrollHeight, qaScrollView.contentWidth, qaScrollHeight)
							extendLine:setStrokeColor( 1, 0, 0 )
						end
						hintRoundedRectText.text = "預設高度: "..qaScrollView.contentHeight
						transition.to( hintRoundedRectText, { time = 2000, alpha = 0, transition = easing.inExpo } )
						transition.to( hintRoundedRect, { time = 2000, alpha = 0, transition = easing.inExpo } )
						timer.performWithDelay( 2000, function ()
							hintRoundedRectText:removeSelf()
							hintRoundedRect:removeSelf()
						end)
						hintRoundedRectText2.text = "目前高度: "..qaScrollHeight
						transition.to( hintRoundedRectText2, { time = 2000, alpha = 0, transition = easing.inExpo } )
						transition.to( hintRoundedRect2, { time = 2000, alpha = 0, transition = easing.inExpo } )
						timer.performWithDelay( 2000, function ()
							hintRoundedRectText2:removeSelf()
							hintRoundedRect2:removeSelf()
						end)
					]]--
				else
					-- 收回問題欄位
					if ( qaY ~= 0 and event.y+container[index].contentHeight > 360 ) then
						local setY
						if ( qaY+container[index].contentHeight > 0 ) then
							setY = 0
						else
							setY = qaY+container[index].contentHeight
						end
						qaScrollView:scrollToPosition( { y = setY, time = 200 } )
					end
					setStatus[arrowText] = "down"
					transition.to( text[index], { y = -container[index].contentHeight, time = 200 } ) -- 收起答案
					event.target:removeEventListener( "touch", questionListener )
					for i = index, num do
						if ( (i+1) <= num ) then
							transition.to( groupTable[i+1], { y = groupTable[i+1].y-container[index].contentHeight, time = 200 } )
							groupTable[i+1].y = groupTable[i+1].y-container[index].contentHeight
						end
					end
					qaScrollHeight = qaScrollHeight-container[index].contentHeight
					qaScrollView:setScrollHeight( qaScrollHeight )			
					--[[
						if ( qaScrollHeight == answerContainer[num].y ) then
							isExtend = false
							qaScrollView:scrollTo( "top", { time = 0 } )
							qaScrollView:setIsLocked( true )
							qaLocked = true
							qaScrollView:setScrollHeight( qaScrollView.contentHeight )
						end
					]]--
					if ( qaLocked == false and qaScrollHeight <= qaScrollView.contentHeight ) then --and qaY == 0) then
						qaScrollView:setIsLocked( true )
						qaLocked = true
						qaScrollView:setScrollHeight( qaScrollView.contentHeight )
						qaScrollView:scrollToPosition( { y = 0, time = 200 } )
					end
					timer.performWithDelay( 200, function()	event.target:addEventListener( "touch", questionListener ); end)
					--[[
						if ( shrinkLine == nil ) then
							shrinkLine = display.newLine( qaScrollViewGroup, 0, qaScrollHeight, qaScrollView.contentWidth, qaScrollHeight)
							shrinkLine:setStrokeColor( 0, 1, 0 )
						else
							shrinkLine:removeSelf()
							shrinkLine = display.newLine( qaScrollViewGroup, 0, qaScrollHeight, qaScrollView.contentWidth, qaScrollHeight)
							shrinkLine:setStrokeColor( 0, 1, 0 )
						end
						hintRoundedRectText.text = "預設高度: "..qaScrollView.contentHeight
						transition.to( hintRoundedRectText, { time = 2000, alpha = 0, transition = easing.inExpo } )
						transition.to( hintRoundedRect, { time = 2000, alpha = 0, transition = easing.inExpo } )
						timer.performWithDelay( 2000, function ()
							hintRoundedRectText:removeSelf()
							hintRoundedRect:removeSelf()
						end)
						hintRoundedRectText2.text = "目前高度: "..qaScrollHeight
						transition.to( hintRoundedRectText2, { time = 2000, alpha = 0, transition = easing.inExpo } )
						transition.to( hintRoundedRect2, { time = 2000, alpha = 0, transition = easing.inExpo } )
						timer.performWithDelay( 2000, function ()
							hintRoundedRectText2:removeSelf()
							hintRoundedRect2:removeSelf()
						end)
					]]--
				end
			end
			return true
		end
	-- 建立常見問題
		local QAGroup = display.newGroup()
		qaScrollViewGroup:insert(QAGroup)
		for i = 1, #questionTable do
			-- 問題白底
				QATable[i] = display.newGroup()
				QAGroup:insert(QATable[i])
				local problemBase = display.newRect(0,0,screenW+ox+ox,(120*hRate)*level)
				--local problemBase = display.newImageRect( "assets/btn-bottomborder-.png", screenW+ox+ox, (120*hRate))
				QATable[i]:insert(problemBase)
				problemBase.anchorY = 0
				problemBase.x = qaScrollView.contentWidth*0.5
				problemBase.y = questionText.y+questionText.contentHeight+floor(16*hRate)+(120*hRate)*level*(i-1)
				problemBase.name = "problemBase"
				problemBase.index = i
				problemBase:addEventListener("touch",questionListener)
			-- 白底藍線
				local problemBaseLine = display.newLine( QATable[i], 0, problemBase.y+problemBase.contentHeight-1, qaScrollView.contentWidth, problemBase.y+problemBase.contentHeight-1 )
				problemBaseLine:setStrokeColor(unpack(mainColor2))
				problemBaseLine.strokeWidth = 1
			-- 顯示文字-問題
				local problemText = display.newText({
					text = questionTable[i],
					font = getFont.font,
					fontSize = 14,
					width = problemBase.contentWidth*0.9,
					height = 0,
				})
				QATable[i]:insert(problemText)
				problemText:setFillColor(unpack(wordColor))
				problemText.anchorX = 0
				problemText.x = questionText.x
				problemText.y = problemBase.y+problemBase.contentHeight*0.5
			-- 問題箭頭
				answerArrow[i] = display.newImageRect("assets/btn-dropdown-dg.png",256,168)
				QATable[i]:insert(answerArrow[i])
				answerArrow[i].width = (answerArrow[i].width*0.05)
				answerArrow[i].height = (answerArrow[i].height*0.05)
				answerArrow[i].x = screenW+ox+ox-ceil(40*wRate)-(answerArrow[i].contentWidth/2)
				answerArrow[i].y = problemText.y
				answerArrow[i].index = i
				local arrowText = "qaArrow"..i
				setStatus[arrowText] = "down"
			-- 顯示文字-答案區/答案
				answerText[i] = display.newText({
					text = answerTable[i],
					font = getFont.font,
					fontSize = 14,
					width = problemBase.contentWidth*0.9,
					height = 0,		
				})
				answerContainer[i] = display.newContainer(problemBase.contentWidth*0.9, answerText[i].contentHeight+floor(64*hRate)*level)
				QATable[i]:insert(answerContainer[i])
				answerContainer[i].anchorY = 0
				answerContainer[i].x = problemBase.x
				answerContainer[i].y = problemBase.y+problemBase.contentHeight

				answerContainer[i]:insert(answerText[i])
				answerText[i]:setFillColor(unpack(wordColor))
				answerText[i].y = -answerContainer[i].contentHeight
			-- 計算scrollHeight
				if ( i == #questionTable ) then
					qaScrollHeight = problemBase.y+problemBase.contentHeight
					if ( qaScrollHeight > qaScrollView.contentHeight ) then
						qaScrollView:setScrollHeight(qaScrollHeight)
						qaScrollView:setIsLocked( false, vertical )
						qaLocked = false
					end
				end
		end
	------------------- 搜尋元件 -------------------
	-- 搜尋按鈕
		local searchResultGroup
		local searchBtn = widget.newButton({
				id = "searchBtn",
				defaultFile = "assets/btn-search-b.png",
				width = 261,
				height = 261,
				onRelease = function()
					if ( searchTextField.text ~= "" ) then
						local textPattern = "%w%:(.+)"
						local resultQuestionList = {}
						local resultAnswerList = {}
						local keyWord = searchTextField.text
						local keyNum = 1
						for i = 1, #qaList do
							if ( string.find( qaList[i], keyWord) and i == keyNum ) then
								if ( i%2 == 0 ) then
									-- 問題有關鍵字
									table.insert( resultQuestionList, qaList[i])
									table.insert( resultAnswerList, qaList[i+1])
									keyNum = i+2 -- 跳去下一個問題
								else
									-- 答案有關鍵字
									table.insert( resultQuestionList, qaList[i-1])
									table.insert( resultAnswerList, qaList[i])
									keyNum = i+1 -- 跳去下一個問題
								end
							else
								if ( keyNum == i ) then
									keyNum = keyNum+1
								end
							end
						end
						if ( #resultQuestionList > 0 ) then
							questionText.text = "搜尋結果"
							classifiedBtn:setEnabled(false)
							qaScrollHeight = 0
							if ( searchResultGroup ) then
								searchResultGroup:removeSelf()
								searchResultGroup = nil
							end
							searchResultGroup = display.newGroup()
							qaScrollView:insert(searchResultGroup)
							
							for i = 1, #resultQuestionList do
								-- 問題白底
									searchGroupTable[i] = display.newGroup()
									searchResultGroup:insert(searchGroupTable[i])
									local resultBase = display.newRect(0,0,screenW+ox+ox,(120*hRate)*level)
									searchGroupTable[i]:insert(resultBase)
									resultBase.anchorY = 0
									resultBase.x = qaScrollView.contentWidth*0.5
									resultBase.y = questionText.y+questionText.contentHeight+floor(16*hRate)+(120*hRate)*(i-1)*level
									resultBase.name = "resultBase"
									resultBase.index = i
									resultBase:addEventListener( "touch", questionListener )
								-- 白底藍線
									local resultBaseLine = display.newLine( searchGroupTable[i], 0, resultBase.y+resultBase.contentHeight-1, qaScrollView.contentWidth, resultBase.y+resultBase.contentHeight-1 )
									resultBaseLine:setStrokeColor(unpack(mainColor2))
									resultBaseLine.strokeWidth = 1
								-- 顯示文字-問題
									local resultText = display.newText({
										text = resultQuestionList[i]:match(textPattern),
										font = getFont.font,
										fontSize = 14,
										width = resultBase.contentWidth*0.9,
										height = 0,
									})
									searchGroupTable[i]:insert(resultText)
									resultText:setFillColor(unpack(wordColor))
									resultText.anchorX = 0
									resultText.x = questionText.x
									resultText.y = resultBase.y+resultBase.contentHeight*0.5
								-- 問題箭頭
									searchResultArrow[i] = display.newImageRect("assets/btn-dropdown-dg.png",256,168)
									searchGroupTable[i]:insert(searchResultArrow[i])
									searchResultArrow[i].width = (searchResultArrow[i].width*0.05)
									searchResultArrow[i].height = (searchResultArrow[i].height*0.05)
									searchResultArrow[i].x = screenW+ox+ox-ceil(40*wRate)-(searchResultArrow[i].contentWidth/2)
									searchResultArrow[i].y = resultText.y
									searchResultArrow[i].index = i
									local arrowText = "searchArrow"..i
									setStatus[arrowText] = "down"
								-- 顯示文字-答案區/答案
									searchResultAnswerText[i] = display.newText({
										text = resultAnswerList[i]:match(textPattern),
										font = getFont.font,
										fontSize = 14,
										width = resultBase.contentWidth*0.9,
										height = 0,		
									})
									searchResultContainer[i] = display.newContainer(resultBase.contentWidth*0.9, searchResultAnswerText[i].contentHeight+floor(64*hRate))
									searchGroupTable[i]:insert(searchResultContainer[i])
									searchResultContainer[i].anchorY = 0
									searchResultContainer[i].x = resultBase.x
									searchResultContainer[i].y = resultBase.y+resultBase.contentHeight

									searchResultContainer[i]:insert(searchResultAnswerText[i])
									searchResultAnswerText[i]:setFillColor(unpack(wordColor))
									searchResultAnswerText[i].y = -searchResultContainer[i].contentHeight*level
								-- 計算scrollHeight
									if ( i == #resultQuestionList ) then
										qaScrollHeight = resultBase.y+resultBase.contentHeight
										if ( qaScrollHeight > qaScrollView.contentHeight ) then
											qaScrollView:setScrollHeight(qaScrollHeight)
											qaScrollView:setIsLocked( false, vertical )
											qaLocked = false
										end
									end
							end
							qaScrollViewGroup.isVisible = false
							searchResultGroup.isVisible = true
						else
							questionText.text = "搜尋結果"
							classifiedBtn:setEnabled(false)
							if ( searchResultGroup ) then
								searchResultGroup:removeSelf()
								searchResultGroup = nil
							end
							searchResultGroup = display.newGroup()
							qaScrollView:insert(searchResultGroup)
							local funBirdPic = display.newImageRect("assets/img-bird.png",142,229)
							searchResultGroup:insert(funBirdPic)
							funBirdPic.width = (funBirdPic.contentWidth*0.3)
							funBirdPic.height = (funBirdPic.contentHeight*0.3)
							funBirdPic.x = qaScrollView.contentWidth*0.5
							funBirdPic.y = qaScrollView.contentHeight*0.3
							local noResultText = display.newText({
									text = "找不到相關結果",
									font = getFont.font,
									fontSize = 14,				
								})
							searchResultGroup:insert(noResultText)
							noResultText:setFillColor(unpack(wordColor))
							noResultText.x = qaScrollView.contentWidth*0.5
							noResultText.y = qaScrollView.contentHeight*0.45
							qaScrollViewGroup.isVisible = false
							searchResultGroup.isVisible = true
						end
					end
				end,
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
		local clearTextBtn = widget.newButton({
			id = "clearTextBtn",
			width = 241,
			height = 240,
			defaultFile = "assets/btn-search-delete.png",
			onRelease = function()
				searchTextField.text = ""
				native.setKeyboardFocus(nil)
				searchResultGroup.isVisible = false
				qaScrollViewGroup.isVisible = true
				questionText.text = "常見問題"
				classifiedBtn:setEnabled(true)
				qaScrollView:scrollToPosition( { y = 0, time = 0 } )
				return true
			end,
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
		local questionOption = { "Font_Data/QA-PreOrder.txt", "Font_Data/QA-Payment.txt", "Font_Data/QA-Point.txt", "Font_Data/QA-Reimburse.txt", "Font_Data/QA-Account.txt"}
		local function optionSelect( event )
			local phase = event.phase
			if (phase == "began") then
				if (isCanceled == true) then
					isCanceled = false
				end
				if ( event.target ~= defaultTarget ) then
					nowTarget = event.target
					nowTarget:setFillColor( 0, 0, 0, 0.1)
					optionText[nowTarget.id]:setFillColor(unpack(subColor2))

					defaultTarget:setFillColor(1)
					optionText[defaultTarget.id]:setFillColor(unpack(wordColor))
				end
			elseif (phase == "moved") then
				isCanceled = true
				if ( event.target ~= defaultTarget and nowTarget ~= nil) then
					local dx = math.abs(event.xStart - event.x)
					local dy = math.abs(event.yStart - event.y)
					if (dy > 10 or dx > 10) then
						dropDownListScrollView:takeFocus(event)
					end
					nowTarget:setFillColor(1)
					optionText[nowTarget.id]:setFillColor(unpack(wordColor))

					defaultTarget:setFillColor(1)
					optionText[defaultTarget.id]:setFillColor(unpack(subColor2))
				end
			elseif (phase == "ended" and isCanceled == false and event.target ~= defaultTarget) then
				transition.to(dropDownListGroup, { y = -dropDownListBoundary.contentHeight, time = 200})
				timer.performWithDelay(200, function() searchTextField.isVisible = true ;end)
				nowTarget:setFillColor(1)
				setStatus["dropDown"] = "down"
				btnDropDownPic:rotate(180)
				btnDropDownText.text = optionText[nowTarget.id].text
				preTarget = defaultTarget
				defaultTarget = nowTarget
				nowTarget = nil
				--print(defaultTarget.id)
				-- 重建問題集
				qaScrollHeight = 0
				isExtend = false
				QAGroup:removeSelf()
				QAGroup = nil
				QAGroup = display.newGroup()
				qaScrollViewGroup:insert(QAGroup)
				qaScrollView:scrollToPosition( { y = 0, time = 0 } )
				qaScrollView:setIsLocked(true)
				QATable = {nil}
				questionTable = {nil}
				answerTable = {nil}
				path = system.pathForFile( questionOption[defaultTarget.id], system.ResourceDirectory )
				file = io.open(path, "r")
				if not file then 
					print("File is not found")
				else
					local contents = file:read("*l")
					local count = 1
					while (contents ~= nil) do
						list[count] = contents
						count = count+1
						contents = file:read("*l")
					end
					io.close( file )
					file = nil
				end
				
				for k,v in pairs(list) do
					local head, bottom = v:match(qaPattern)
					if ( head == "Q" ) then
						table.insert( questionTable, bottom)
					else
						table.insert( answerTable, bottom)
					end
				end
				list = {nil}
				for i = 1, #questionTable do
					-- 問題白底
						QATable[i] = display.newGroup()
						QAGroup:insert(QATable[i])
						local problemBase = display.newRect(0,0,screenW+ox+ox,(120*hRate)*level)
						--local problemBase = display.newImageRect( "assets/btn-bottomborder-.png", screenW+ox+ox, (120*hRate))
						QATable[i]:insert(problemBase)
						problemBase.anchorY = 0
						problemBase.x = qaScrollView.contentWidth*0.5
						problemBase.y = questionText.y+questionText.contentHeight+floor(16*hRate)+(120*hRate)*(i-1)*level
						problemBase.name = "problemBase"
						problemBase.index = i
						problemBase:addEventListener("touch",questionListener)
					-- 白底藍線
						local problemBaseLine = display.newLine( QATable[i], 0, problemBase.y+problemBase.contentHeight-1, qaScrollView.contentWidth, problemBase.y+problemBase.contentHeight-1 )
						problemBaseLine:setStrokeColor(unpack(mainColor2))
						problemBaseLine.strokeWidth = 1
					-- 顯示文字-問題
						local problemText = display.newText({
								text = questionTable[i],
								font = getFont.font,
								fontSize = 14,
								width = problemBase.contentWidth*0.9,
								height = 0,
							})
						QATable[i]:insert(problemText)
						problemText:setFillColor(unpack(wordColor))
						problemText.anchorX = 0
						problemText.x = questionText.x
						problemText.y = problemBase.y+problemBase.contentHeight*0.5
					-- 問題箭頭
						answerArrow[i] = display.newImageRect("assets/btn-dropdown-dg.png",256,168)
						QATable[i]:insert(answerArrow[i])
						answerArrow[i].width = (answerArrow[i].width*0.05)
						answerArrow[i].height = (answerArrow[i].height*0.05)
						answerArrow[i].x = screenW+ox+ox-ceil(40*wRate)-(answerArrow[i].contentWidth/2)
						answerArrow[i].y = problemText.y
						answerArrow[i].index = i
						local arrowText = "qaArrow"..i
						setStatus[arrowText] = "down"
					-- 顯示文字-答案
						answerText[i] = display.newText({
							text = answerTable[i],
							font = getFont.font,
							fontSize = 14,
							width = problemBase.contentWidth*0.9,
							height = 0,		
						})
						answerContainer[i] = display.newContainer(problemBase.contentWidth*0.9, answerText[i].contentHeight+floor(64*hRate)*level)
						QATable[i]:insert(answerContainer[i])
						answerContainer[i].anchorY = 0
						answerContainer[i].x = problemBase.x
						answerContainer[i].y = problemBase.y+problemBase.contentHeight

						answerContainer[i]:insert(answerText[i])
						answerText[i]:setFillColor(unpack(wordColor))
						answerText[i].y = -answerContainer[i].contentHeight
					-- 計算scrollHeight
						if ( i == #questionTable ) then
							qaScrollHeight = problemBase.y+problemBase.contentHeight
							if ( qaScrollHeight > qaScrollView.contentHeight ) then
								qaScrollView:setScrollHeight(qaScrollHeight)
								qaScrollView:setIsLocked( false, vertical )
								qaLocked = false
							end
						end
				end
			end
		end
		for i = 1, #listOptions do
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
			if ( i == 1 ) then 
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