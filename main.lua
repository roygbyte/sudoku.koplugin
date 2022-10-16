--[[--
   This plugin lets you play sudoku puzzles on your e-reader.

    @module koplugin.sudoku
--]]--

local DataStorage = require("datastorage")
local LuaSettings = require("frontend/luasettings")
local UIManager = require("ui/uimanager")
local WidgetContainer = require("ui/widget/container/widgetcontainer")
local logger = require("logger")
local _ = require("gettext")

local Sudoku = WidgetContainer:extend{
    name = "sudoku",
    settings = nil,
    puzzle_library_path = nil,
    active_puzzle = nil,
    -- Static vars
    DEFAULT_PATH_TO_PUZZLE_LIBRARY = "%s/plugins/sudoku.koplugin/puzzles",
    SETTINGS_FILENAME = "sudoku_settings.lua",
    SETTINGS_KEYS = {
        PUZZLES_LIBRARY_DIR = "sudoku_library_dir"
    },
}

function Sudoku:init()
    self:lazyInitialization()
    self.ui.menu:registerToMainMenu(self)
end

function Sudoku:addToMainMenu(menu_items)
    menu_items.sudoku = {
        text = _("Sudoku"),
        sorting_hint = "tools",
        sub_item_table_func = function()
            return self:getSubMenuItems()
        end
    }
end

function Sudoku:getSubMenuItems()
    local sub_menu_items = {
        {
            text = _("Puzzle Library"),
            callback = function()
                self:showLibraryView()
            end
        },
        {
            text = _("Settings"),
            sub_item_table = {
                {
                    text = _("Set puzzles folder"),
                    keep_menu_open = true,
                    callback = function()
                        self:setPuzzlesDirectory()
                    end
                }
            }
        }
    }
    return sub_menu_items
end

function Sudoku:lazyInitialization()
   self.settings = LuaSettings:open(("%s/%s"):format(DataStorage:getSettingsDir(), Sudoku.SETTINGS_FILENAME))
   self.puzzle_dir = Sudoku.SETTINGS_KEYS.PUZZLES_LIBRARY_DIR and
       self.settings:readSetting(Sudoku.SETTINGS_KEYS.PUZZLES_LIBRARY_DIR) or
       (Sudoku.DEFAULT_PATH_TO_PUZZLE_LIBRARY):format(DataStorage:getFullDataDir())
end

function Sudoku:setPuzzlesDirectory()
   local downloadmgr = require("ui/downloadmgr")
   downloadmgr:new{
      onConfirm = function(path)
         self.settings:saveSetting(Sudoku.SETTINGS_KEYS.PUZZLES_LIBRARY_DIR, ("%s/"):format(path))
         self.settings:flush()
      end
   }:chooseDir()
   -- After the user selects a directory, we will re-initialize the plugin so the
   -- directory variable is updated.
   self:lazyInitialization()
end

return Sudoku
