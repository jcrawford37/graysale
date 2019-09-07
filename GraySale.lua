-- Gray Sale. Add a little sell junk button on vendor
-- Updated for 1.13.2 Classic Wow 
-- 06 SEP 2019
-- Hateduck / Souldoubt


--=================== Saved Variables (saved between sessions) ==========================================
trashList = {};
totalTrashMoney = 0
totalTransactions = 0
largestTrans = 0

--======================================== Slash Command ================================================
function GraySale_OnLoad()
	MerchantFrameSellGrays:SetFrameStrata("HIGH")
	SLASH_GRAYSALEADD1, SLASH_GRAYSALEREM1, SLASH_GRAYSALEPRINT1 = "/addtotrash", "/removefromtrash", "/printtrash";
	SLASH_GRAYSALEPRINTCOINGAIN1, SLASH_GRAYSALERESETCOIN1 = "/printcoin", "/resetcoin";
	SLASH_GRAYSALEUSAGE1 = "/graysale"

	local function graySaleAdd(msg, editbox)
		addToTrashList(msg)
	end
	
	local function graySaleRemove(msg, editbox)
		removeFromTrashList(msg)
	end
	
	local function graySalePrint(msg, editbox)
		printTrashList()
	end

	local function graySalePrintCoin(msg, editbox)
		printCoinInfo()
	end

	local function graySaleResetCoin(msg, editbox)
		resetCoinStats()
	end

	local function graySaleUsage(msg, editbox)
		printGraySaleUsage()
	end


	-- Register function to slash command
	SlashCmdList["GRAYSALEADD"] = graySaleAdd
	SlashCmdList["GRAYSALEREM"] = graySaleRemove
	SlashCmdList["GRAYSALEPRINT"] = graySalePrint
	SlashCmdList["GRAYSALEPRINTCOINGAIN"] = graySalePrintCoin
	SlashCmdList["GRAYSALERESETCOIN"] = graySaleResetCoin
	SlashCmdList["GRAYSALEUSAGE"] = graySaleUsage
	-- Print usage on log in
	printcolor(cYELLOW, "Welcome to GraySale! Visit any vendor and use the 'Sell Junk' button in the bottom left of the window.")
	printcolor(cYELLOW, "Type /graysale for more options")
end


--=========================Add commonly sold Item to the Trash List to be treated as a gray ============
function addToTrashList(itemLink)
	local found = false
	for i,v in pairs(trashList) do
		if (v == itemLink) then
			found = true;
			break;
		end
	end
	if (found) then
		printf("Item already on Trash List.")
	else
		printf("Added item "..itemLink.." to trash list.")
		table.insert(trashList, itemLink)
	end
end

--===================================== Remove an Item from the Trash List =============================
function removeFromTrashList(itemLink)
	local found = false
	if itemLink == "*" then
		for k in pairs(trashList) do
			trashList[k] = nil
		end
		printf("Trash List Cleared!")
		return
	end

	for i,v in pairs(trashList) do
		if (v == itemLink) then
			found = true;
			table.remove(trashList, i)
			printf("Item "..v.." removed from Trash List.")
			break;
		end
	end
	if not (found) then
		printf("Item is not on Trash List.")
	end
end


--===================================== Print Functions ===========================================
function printTrashList()
	printf("========$$ Trash List $$========")
	for i,v in pairs(trashList) do
		printf("Item "..i..": "..v)
	end
end

function printCoinInfo()
	printcolor(cGOLD2, "=========$$ GraySale Coin Stats $$=========")
	printcolor(cGREENYELLOW, "Cummulative Gray Sale Profits: ")
	printf(GetCoinTextureString(totalTrashMoney))
	printcolor(cGREENYELLOW, "Total Successful Transaction:")
	printf(totalTransactions)
	printcolor(cGREENYELLOW, "Most items sold in single transaction: ")
	printf(largestTrans)
end

function printGraySaleUsage()
	printf("==========$$ GRAYSALE COMMANDS $$==========")
	printf("/addtotrash <ctrl+click itemlink>")
	printcolor(cGREENYELLOW, "    Adds an item to the trash list to be treated as a gray")
	printf("/printtrash")
	printcolor(cGREENYELLOW, "    Displays trash list\n(tip: use this to find itemlink for /removetrash command")
	printf("/removefromtrash <ctrl+click itemlink>")
	printcolor(cGREENYELLOW, "    Removes the item from the trash list\nuse /removefromtrash * to clear entire trash list")
	printf("/printcoin")
	printcolor(cGREENYELLOW, "    Prints total amount of coin earned with GraySale and amount of successful transactions")
	printf("/resetcoin")
	printcolor(cGREENYELLOW, "    Resets stats from /printcoin command")
end

function resetCoinStats()
	totalTrashMoney = 0
	totalTransactions = 0
	largestTrans = 0
	printcolor(cSEXBLUE, "===$$ Historical coin stats have been reset $$===")
end


--============================= Boolean to see if an item is on trashList ==============================
function isTrash(itemLink)
	local itemIsTrash = false;
	--This function used to just compare itemLink string
	--In the newer client, it somehow adds the level of the toon making strings non-unique
	--Just convert crazy link string to text of item name and compare those.
	if (itemLink ~= nil) then
		local itemNameOnly = GetItemInfo(itemLink)  --convert to text only name
		for i,v in pairs(trashList) do
			local listItemNameOnly = GetItemInfo(v) --convert to text only name
			if (itemNameOnly==listItemNameOnly) then
				itemIsTrash = true
				break
			end
		end	
	end
	return itemIsTrash
end

--======================= Function to fire off when "Sell Junk" button is clicked ======================
function fastPingSell()
	local soldItemCount = 0
	profit =0
	for bag = 0, 4 do 
		for slot = 1, GetContainerNumSlots(bag) do 
			local bagItem = GetContainerItemLink(bag,slot) 
			if bagItem and string.find(bagItem,"ff9d9d9d") or isTrash(bagItem) then 
				local stackCount = GetItemCount(bagItem)
				printcolor(cSEXGREEN, "Sold: "..bagItem.."|"..cSEXGREEN.."x"..stackCount)
				UseContainerItem(bag,slot)
				soldItemCount = soldItemCount + 1
				profit = profit + getVendorPrice(bagItem, stackCount)
			end 
		end 
	end

	if soldItemCount == 0 then
		printcolor(cSEXGREEN, "No grays to sell")
	else
		printcolor(cSEXGREEN,"Sold "..soldItemCount.." trash items!")
		printf("Profit: "..GetCoinTextureString(profit))
		totalTrashMoney = totalTrashMoney + profit
		totalTransactions = totalTransactions + 1
		if (soldItemCount > largestTrans) then
			largestTrans = soldItemCount
		end
		profit = 0
	end
end


--======================== Find out price of item ======================
function getVendorPrice(itemLink, numStacks)
	--select() doesn't seem to work the same in this client version
	--so i have to do this long gross variable return thingy
	local _,_,_,_,_,_,_,_,_,_,coppers = GetItemInfo(itemLink)
	return coppers * numStacks
end

--==================== MISC Printf Wrapper stuff==================================
function printf(guts)
	DEFAULT_CHAT_FRAME:AddMessage(guts);
end

function printcolor(hex, guts)
	DEFAULT_CHAT_FRAME:AddMessage("|"..hex..guts);	
end

function printbox(guts)
	message(guts);
end

--======================= Color Codes for print color ==============================================

cLIGHTRED     	=	"cffff6060"
cLIGHTBLUE    	=	"cff00ccff"
cTORQUISEBLUE	=	"cff00C78C"
cSPRINGGREEN	=	"cff00FF7F"
cGREENYELLOW  	=	"cffADFF2F"
cBLUE         	=	"cff0000ff"
cPURPLE			=	"cffDA70D6"
cGREEN	    	=	"cff00ff00"
cRED          	=	"cffff0000"
cGOLD         	=	"cffffcc00"
cGOLD2			=	"cffFFC125"
cGREY         	=	"cff888888"
cWHITE        	=	"cffffffff"
cSUBWHITE     	=	"cffbbbbbb"
cMAGENTA      	=	"cffff00ff"
cYELLOW       	=	"cffffff00"
cORANGEY		=	"cffFF4500"
cCHOCOLATE		=	"cffCD661D"
cCYAN         	=	"cff00ffff"
cIVORY			=	"cff8B8B83"
cLIGHTYELLOW	=	"cffFFFFE0"
cSEXGREEN		=	"cff71C671"
cSEXTEAL		=	"cff388E8E"
cSEXPINK		=	"cffC67171"
cSEXBLUE		=	"cff00E5EE"
cSEXHOTPINK		=	"cffFF6EB4"