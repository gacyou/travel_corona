-----------------------------------------------------------------------------------------
--
-- setFont.lua
--
-----------------------------------------------------------------------------------------

local setFont = {}

--print( system.getPreference( "locale", "language" ))
--print( system.getPreference( "ui", "language" ))
setFont.font = native.newFont("Font_Data/cwheib")

return setFont