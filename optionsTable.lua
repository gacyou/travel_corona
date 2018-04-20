-----------------------------------------------------------------------------------------
--
-- optionsTable.lua
--
-----------------------------------------------------------------------------------------

local optionsTable = {}

-- 檢查密碼英數混和樣式 --
optionsTable.pwdMixPattern = "^%d*%a+%d+%w*$"

-- 旅伴抬頭下拉式選單選項 --
optionsTable.TP_titleListOptions = { "尋找旅伴", "我的資料", "訊息中心", "我的相簿", "我的收藏", "會員搜尋", "其他設定", "免責聲明"}

-- 旅伴抬頭下拉式選單選項對應的Scene --
optionsTable.TP_titleListScenes = { "TP_findPartner", "TP_myInformation", nil, "TP_myAlbum", nil, "TP_memberSearch", "TP_otherSetting", "TP_disclaimer"}

-- 服務條款 --
optionsTable.disclaimerWeb = "http://traveltest.1758play.com:8080/Home/Disclaimer"

-- 熱門目的地 --
optionsTable.getHotSoptUrl = "http://211.21.114.208/1.0/GetTopDestinationList"

-- 獨家主題/熱門行程 --
optionsTable.getThemeUrl = "http://211.21.114.208/1.0/GetExclusiveTopicList"

-- 商品資訊 --
optionsTable.getProductUrl = "http://211.21.114.208/1.0/GetItem/"

-- 新增商品至購物車 --
optionsTable.addToCartUrl = "http://211.21.114.208/1.0/ShoppingCart/add"

-- 更新購物車商品資訊 --
optionsTable.editCartItemUrl = "http://211.21.114.208:80/1.0/ShoppingCart/edit"

-- 刪除購物車商品 --
optionsTable.deleteCartItemUrl = "http://211.21.114.208:80/1.0/ShoppingCart/del/"

-- 取得購物車商品資訊 -- 
optionsTable.getItemsInCartUrl = "http://211.21.114.208/1.0/ShoppingCart/get"

-- 計算購物車商品金額 -- 
optionsTable.calculateItemsInCartUrl = "http://211.21.114.208/1.0/ShoppingCart/calList"

-- 取得使用者登入資訊 --
optionsTable.getUserLonigInfoUrl = "http://211.21.114.208/1.0/user/GetLoginUserInfo/"

-- 更新個人訊息 -- 
optionsTable.updateUserInfoUrl = "http://211.21.114.208/1.0/user/UpdateUserInfo"

-- 取得/刷新 Token -- 
optionsTable.getTokenUrl = "http://211.21.114.208/oauth/token?client_id=blissangkor&client_secret=bGl2ZS10ZXN0"

-- 登出 Token --
optionsTable.revokeTokenUrl = "http://211.21.114.208/tokens/revoke/"

-- 取得旅行計畫 --
optionsTable.getTripPlanUrl = "http://211.21.114.208/1.0/mate/GetMyTripList"

-- 新增旅行計畫 --
optionsTable.setTripPlanUrl = "http://211.21.114.208/1.0/mate/AddMyTrip"

-- 會員註冊 --
optionsTable.memberRegister = "http://211.21.114.208/1.0/login/Register"

-- 洲別對應的國家 -- 
optionsTable.getCountryByContinentUrl = "http://211.21.114.208/1.0/other/GetCountryListByContinentId/"

-- 國家對應的城市 --
optionsTable.getCityByCountryUrl = "http://211.21.114.208/1.0/other/GetCityListByCountryId/"

return optionsTable