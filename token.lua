-----------------------------------------------------------------------------------------
--
-- token.lua
--
-----------------------------------------------------------------------------------------
local optionsTable = require("optionsTable")
local json = require("json")

local M = {}

local prevToken = nil
local nowToken = nil
local refresh

function M.doRefreshToken( acceessToken, refreshToken, time )
	prevToken = acceessToken
	nowToken = acceessToken
	local t = {}
	local expireTime = time
	
	function t:timer( event )
		expireTime = expireTime-1
		--print(expireTime)
		if ( expireTime < 300 ) then
			--expireTime = 3600
			local function getTokenListener( event )
				if ( event.isError ) then
					print("Network Error： ", event.response)
				else
					-- get token
					-- print ("RESPONSE: " .. event.response)
					local decodedData = json.decode(event.response)
					prevToken = nowToken
					nowToken = decodedData["access_token"]
					if ( refreshToken ~= decodedData["refresh_token"] ) then
						refreshToken = decodedData["refresh_token"]
					end
					expireTime = decodedData["expires_in"]
				end
			end
			local headers = {}
			local body = "grant_type=refresh_token&refresh_token="..refreshToken
			local params = {}
			params.headers = headers
			params.body = body
			local getTokenUrl = optionsTable.getTokenUrl
			network.request( getTokenUrl, "POST", getTokenListener, params)
		end
	end

	refresh = timer.performWithDelay( 1000, t, 0 )
end

function M.getAccessToken()
	return nowToken
end

function M.stopRefresh()
	timer.cancel(refresh)
end

return M