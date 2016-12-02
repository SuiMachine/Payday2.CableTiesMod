-------------------------------------------------
--  Menu Logic
-------------------------------------------------
_G.SuiCableTies = _G.SuiCableTies or {}
SuiCableTies._path = ModPath
SuiCableTies._data_path = SavePath .. "suicableties.txt"
SuiCableTies.settings = {}

--Loads the options from blt
function SuiCableTies:Load()
    self.settings["enabled"] = true

    local file = io.open(self._data_path, "r")
    if (file) then
        for k, v in pairs(json.decode(file:read("*all"))) do
            self.settings[k] = v
        end
    end
end

--Saves the options
function SuiCableTies:Save()
    local file = io.open(self._data_path, "w+")
    if file then
        file:write(json.encode(self.settings))
        file:close()
    end
end

--Loads the data table for the menuing system.  Menus are
--ones based
function SuiCableTies:getCompleteTable()
    local tbl = {}
    for i, v in pairs(SuiCableTies.settings) do
        if true then
            tbl[i] = v
        end
    end

    return tbl
end

--Sets number of pagers.  Called from the menu system.  Menus are all ones
--based
function setEnabled(this, item)
    local value = item:value() == "on" and true or false
    SuiCableTies.settings["enabled"] = value
end

--Load locatization strings
Hooks:Add("LocalizationManagerPostInit", "LocalizationManagerPostInit_SuiCableTies", function(loc)
    loc:load_localization_file(SuiCableTies._path.."loc/en.txt")
end)

--Set up the menu
Hooks:Add("MenuManagerInitialize", "MenuManagerInitialize_SuiCableTies", function(menu_manager)
    MenuCallbackHandler.SuiCableTies_enabledToggle = setEnabled

    MenuCallbackHandler.SuiCableTies_Close = function(this)
        SuiCableTies:Save()
    end

    SuiCableTies:Load()
    MenuHelper:LoadFromJsonFile(SuiCableTies._path.."options.txt", SuiCableTies, SuiCableTies:getCompleteTable())
end)

-- gets the number of pagers, triggering a load if necessary.  Called
-- by clients
function isSuiCableTiesEnabled()
    if not SuiCableTies.settings["enabled"] then
        SuiCableTies:Load()
    end
    return SuiCableTies.settings["enabled"]
end

-------------------------------------------------
--  Handler for shit
-------------------------------------------------
if RequiredScript == "lib/tweak_data/upgradestweakdata" then
	if isSuiCableTiesEnabled() then
		local old_init_pd2_values = UpgradesTweakData._init_pd2_values
		function UpgradesTweakData:_init_pd2_values(...)
			old_init_pd2_values(self, ...)
		self.values.cable_tie.quantity_1 = {50}
		self.values.cable_tie.quantity_2 = {50}
		end
		
	end
end



-------------------------------------------------
--  Network Nonsense
-------------------------------------------------

Hooks:Add("NetworkManagerOnPeerAdded", "NetworkManagerOnPeerAdded_SuiCableTies", function(peer, peer_id)
	if Network:is_server() and isSuiCableTiesEnabled() then
        local suiCT = isSuiCableTiesEnabled()

		DelayedCalls:Add("DelayedSuiCableTiesAnnounce" .. tostring(peer_id), 2, function()

			local message = "Host is running Sui's CableTies Mod. "

			local peer2 = managers.network:session() and managers.network:session():peer(peer_id)
			if peer2 then
				peer2:send("send_chat_message", ChatManager.GAME, message)
			end
		end)
	end
end)
