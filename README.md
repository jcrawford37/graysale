# graysale
WoW Classic Add-on to vendor grays and keep a trash list of things you want sold at the vendor. This add-on will create a small button on a vendor sales window in classic wow. It sells grays and anything you deem to be trash that you add to your list.

If you download the zip from here, GitHub will append the text  "-master" (or -branchname). Delete that from the extracted folder before you put it in your interface/addons folder.  The extracted folder should just be "GraySale".  There should only be the .lua, .toc, and .xml files inside of that folder. 

## Commands
/graysale

prints the usage of the commands listed below in game in the chat window.

/printtrash

prints the trash list. Anything on this list is treated like a gray when you vendor.

/addtotrash <ctrl+click item>

This adds items to the trash list from your bag or from item links in chat.

/removefromtrash <ctrl+click item>

This removes a single item from the trash list if it matches the link.

/removefromtrash *

This removes the entire trash list. This means graysale will only sell gray items.

/printcoin

Prints some fun stats like the biggest amount of grays sold at once, total transactions and total profit made using the Sell Junk button.

/resetcoin

Resets the stats presented by the /printcoin ability
