-----------------------------------------------------------------------------------------
--
-- myutf8.lua
--
-----------------------------------------------------------------------------------------
local utf8 = require("plugin.utf8")

local M = {}

function M.textToUtf8( string, num )
	local utf8Table = {}
	for k,v in utf8.codes(string) do
		table.insert(utf8Table,v)
	end
	local textNum = 0
	if ( #utf8Table > num) then
		textNum = num
	else
		textNum = #utf8Table
	end
	local utf8Text = ""
	for i = 1, textNum do
		utf8Text = utf8Text..utf8.escape("%"..utf8Table[i])
		if ( i == textNum and #utf8Table > num ) then
			utf8Text = utf8Text.."..."
		end
	end
	return utf8Text 
end

return M