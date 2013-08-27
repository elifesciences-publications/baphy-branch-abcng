README.txt -- Revised SVD 2012-05-25
Added support for multiple configurations.

Configuration files for a lab exist in a subdirectory from Config/<BAPHY_CONFIG_PATH>/.  The correct directory BAPHY_CONFIG_PATH is specified in BaphyConfigPath.m, which is not saved in the svn respository.  If nothing is specified, then BAPHY_CONFIG_PATH defaults to 'default'

<BAPHY_CONFIG_PATH>/BaphyMainGuiItems: 
Status: LAB
	This m file contains the items of BaphyMainGui. By editing this file, you can	
	add new users, new ferrets, new Modules, etc.

<BAPHY_CONFIG_PATH>/BaphyRefTarGuiItems: 
Status: LAB
	This m file contains the items of BaphyRefTarGui. By editing this file, you can
	modify the items that are displayed in RefTarGui.

<BAPHY_CONFIG_PATH>/RunClassTable 
Status: LAB
	This m file contains the mapping for reference/target pairs to a runclass

<BAPHY_CONFIG_PATH>/InitializeHW
Status: LAB
	This m file sets up hardware for the currently chosen Hardware Setup (the possibilities for which are stored in BaphyMainGuiItems

BaphyMainGuiSettings:
Status: LOCAL
	This .mat file keeps a profile for each tester and loads the menu items based on
	their last settings.

BaphyHWSetup: (OBSOLETE??)
status: LOCAL
	This .mat file stores the hardware initialization data. Its used mostly for shutting
	down the hardware if the program crashes.



--------- OLD README.txt follow ------------


Config directory contains all the configuration files and data for baphy.
Some of the files are global (for all hardware setups) and some are local. 
Only the global configuation files should be added to version control software (SVN).

contents:

BaphyMainGuiItems: 
Status: GLOBAL
	This m file contains the items of BaphyMainGui. By editing this file, you can	
	add new users, new ferrets, new Modules, etc.

BaphyRefTarGuiItems: 
Status: GLOBAL
	This m file contains the items of BaphyRefTarGui. By editing this file, you can
	modify the items that are displayed in RefTarGui.

Baphy.mat: 
Status: LOCAL
	This .mat file contains the values of globalparameters and quit_baphy. It is used
	to pas information from BaphyMainGui to the main script, baphy.

BaphyMainGuiSettings:
Status: LOCAL
	This .mat file keeps a profile for each tester and loads the menu items based on
	their last settings.

BaphyHWSetup: 
status: LOCAL
	This .mat file stores the hardware initialization data. Its used mostly for shutting
	down the hardware if the program crashes.
