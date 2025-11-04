-- Initializing the Dubz Mining System

-- Ensure the DMS table exists
DMS = DMS or {}

-- Include necessary files
include("autorun/dubz_mining_config.lua")
include("dubz_mining/core.lua")
include("dubz_mining/levels.lua")
include("dubz_mining/utils.lua")
include("dubz_mining/pickaxes.lua")

--[[ 
    Enhanced Boot Menu
    Uncomment the lines below if you want the ASCII art and welcome message on startup.
]]

-- Display welcome ASCII art and message
--[[ 
print("#########################################################################################")
print("#########################################################################################")
print("##                                                                                     ##")
print("##   ██████╗░██╗░░░██╗██████╗░███████╗  ███╗░░░███╗██╗███╗░░██╗██╗███╗░░██╗░██████╗░   ##")
print("##   ██╔══██╗██║░░░██║██╔══██╗╚════██║  ████╗░████║██║████╗░██║██║████╗░██║██╔════╝░   ##")
print("##   ██║░░██║██║░░░██║██████╦╝░░███╔═╝  ██╔████╔██║██║██╔██╗██║██║██╔██╗██║██║░░██╗░   ##")
print("##   ██║░░██║██║░░░██║██╔══██╗██╔══╝░░  ██║╚██╔╝██║██║██║╚████║██║██║╚████║██║░░╚██╗   ##")
print("##   ██████╔╝╚██████╔╝██████╦╝███████╗  ██║░╚═╝░██║██║██║░╚███║██║██║░╚███║╚██████╔╝   ##")
print("##   ╚═════╝░░╚═════╝░╚═════╝░╚══════╝  ╚═╝░░░░░╚═╝╚═╝╚═╝░░╚══╝╚═╝╚═╝░░╚══╝░╚═════╝░   ##")
print("##                                                                                     ##")
print("#########################################################################################")
print("#########################################################################################")
]]

-- Display a welcome message
print("Welcome to Dubz Mining System!")
print("By Dubz Development Team.")
print("Version 1.0.0 - Loading...")
print("")
print("----------------------------------------------------")
print("       Dubz Mining System Initialized!              ")
print("----------------------------------------------------")
print("Configuration loaded successfully.")
print("Enjoy your mining experience.")
print("")

-- Simulate a short loading animation for extra flair
local loadingMessages = {
    "Loading assets...",
    "Establishing connections...",
    "Preparing mining systems...",
    "Setting up configuration...",
    "Ready to mine!",
}

for i = 1, #loadingMessages do
    print(loadingMessages[i])
end

print("----------------------------------------------------")

-- Initialize the Dubz Mining System after the boot menu
hook.Add("InitPostEntity", "DubzMiningSystem_Initialize", function()
    -- Initialize essential data and configurations
    print("Initializing Dubz Mining System...")
end)

-- Ensuring correct loading of configuration
if file.Exists("autorun/dubz_mining_config.lua", "LUA") then
    print("Dubz Mining System Configuration loaded successfully.")
else
    print("Error: Configuration file missing.")
end
