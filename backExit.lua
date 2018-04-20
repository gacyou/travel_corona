-----------------------------------------------------------------------------------------
--
-- backExit.lua
--
-----------------------------------------------------------------------------------------

-- Your code here
local widget = require("widget")
local getFont = require("setFont")

local ox, oy = math.abs(display.screenOriginX), math.abs(display.screenOriginY)
local cx, cy = display.contentCenterX, display.contentCenterY
local screenW, screenH = display.contentWidth, display.contentHeight

local t = {}
-- Called when a key event has been received
function t:backExit()
	local backTouchNum = 0
	local function onKeyEvent( event )
		-- If the "back" key was pressed on Android, prevent it from backing out of the app
		if ( event.keyName == "back" ) then
			if ( system.getInfo("platform") == "android" ) then
				if ( event.phase == "up") then
					backTouchNum = backTouchNum+1
					if ( backTouchNum == 1) then
						local hintRoundedRect = widget.newButton({
							x = cx,
							y = (screenH+oy+oy)*0.7,
							isEnabled = false,
							fillColor = { default = { 0, 0, 0, 0.6}, over = { 0, 0, 0, 0.6}},
							shape = "roundedRect",
							width = screenW*0.35,
							height = screenH/16,
							cornerRadius = 20,
						})
						local hintRoundedRectText = display.newText({
							text = "再按一次退出",
							font = getFont.font,
							fontSize = 14,
							x = hintRoundedRect.x,
							y = hintRoundedRect.y,
						})
						if ( hintRoundedRectText.contentWidth > hintRoundedRect.contentWidth ) then
							hintRoundedRect.width = hintRoundedRectText.contentWidth*1.5
						end
						timer.performWithDelay( 1700, function ()
							hintRoundedRectText.alpha = 0.3
							hintRoundedRect.alpha = 0.3
						end)
						timer.performWithDelay( 1800, function ()
							hintRoundedRectText.alpha = 0.2
							hintRoundedRect.alpha = 0.2
						end)
						timer.performWithDelay( 1900, function ()
							hintRoundedRectText.alpha = 0.1
							hintRoundedRect.alpha = 0.1
						end)
						timer.performWithDelay( 2000, function ()
							hintRoundedRectText:removeSelf()
							hintRoundedRect:removeSelf()
							backTouchNum = 0
						end)
					else
						native.requestExit()
					end
				end
				return true
			end
		end

		-- IMPORTANT! Return false to indicate that this app is NOT overriding the received key
		-- This lets the operating system execute its default handling of the key
		return false
	end
	
	-- Add the key event listener
	Runtime:addEventListener( "key", onKeyEvent )
end

return t