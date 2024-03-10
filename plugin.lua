--[[
VanillaChinchilla v1.0: Quaver plugin for placing/editing notes
Copyright (C) 2024  kloi34

This program is free software: you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation, either version 3 of the License, or
(at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with this program.  If not, see <https://www.gnu.org/licenses/>.
--]]

---------------------------------------------------------------------------------------------------
-- Plugin Info ------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------

-- Many ideas for this plugin were stolen from other plugins that were created by these people:
---------------------------------------------------------------------------------------------------
--    IceDynamix             @ https://github.com/IceDynamix
--    Illuminati-CRAZ        @ https://github.com/Illuminati-CRAZ
---------------------------------------------------------------------------------------------------
-- You can find many (but maybe not all) of their plugins on GitHub or Quaver's Steam Workshop.

---------------------------------------------------------------------------------------------------

-- This is a plugin for Quaver, the ultimate community-driven and open-source competitive
-- rhythm game. The plugin provides various tools to place and edit notes quickly and efficiently
-- when making maps in the editor.

-- If you have any feature suggestions or issues with the plugin, please open an issue at 
-- https://github.com/kloi34/VanillaChinchilla/issues

---------------------------------------------------------------------------------------------------
-- Global Constants -------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------

PLUGIN_NAME = "VanillaChinchilla"
FUNNY_NUMBER = 727 -- arbitrary funny prime number, used as an arbitrary large value

----------------------------------------------------------------------------------------------- GUI

DEFAULT_WIDGET_HEIGHT = 26          -- value determining the default height of GUI widgets
DEFAULT_WIDGET_WIDTH = 160          -- value determining the default width of GUI widgets
MAX_WIDGET_WIDTH = 255              -- value determining the max width of GUI widgets
PADDING_WIDTH = 8                   -- value determining window and frame padding
RADIO_BUTTON_SPACING = 7.5          -- value determining spacing between radio buttons
SAMELINE_SPACING = 5                -- value determining spacing between GUI items on the same row
ACTION_BUTTON_SIZE = {255, 42}      -- dimensions of the button that does important things
HALF_BUTTON_SIZE = {125, 30}        -- dimensions of a button that does kinda important things
SECONDARY_BUTTON_SIZE = {60, 24}    -- dimensions of a button that does less important things
LANE_BUTTON_SIZE = {30, 30}         -- dimensions of the button representing a note lane

------------------------------------------------------------------------------- Number restrictions

MIN_RGB_CYCLE_TIME = 6              -- minimum seconds for one complete RGB color cycle
MAX_RGB_CYCLE_TIME = 300            -- maximum seconds for one complete RGB color cycle
MIN_LN_LENGTH = 36                  -- default minimum millisecond duration of LNs
MIN_LN_GAP_LENGTH = 36              -- default minimum millisecond duration of LN gaps
SMALL_NUMBER_TOLERANCE = 0.001      -- smallest number allowed for specific calculations

-------------------------------------------------------------------------------------- Menu related

BEHAVIORS = {                       -- behaviors of notes/time
    "Slow down",
    "Speed up"
}
COLOR_THEMES = {                    -- available color themes for the plugin
    "Classic",          -- 1
    "Strawberry",       -- 2
    "Amethyst",         -- 3
    "Tree",             -- 4
    "Barbie",           -- 5
    "Incognito",        -- 6
    "Incognito + RGB",  -- 7
    "Tobi's Glass",     -- 8
    "Tobi's RGB Glass", -- 9
    "Glass",            -- 10
    "Glass + RGB",      -- 11
    "RGB Gamer Mode",   -- 12
    "edom remag BGR",   -- 13
    "BGR + otingocnI",  -- 14
    "otingocnI"         -- 15
}
PLACE_NOTES_BETWEEN_GENERAL_MENUS = {
    -- "Place Notes By Snap",
    "Place Notes By Number"
}
EDIT_GENERAL_MENUS = {              -- sub-menus within the "Edit Notes (General)" menu
    "Shift Notes Up/Down",
    "Shift Notes Left/Right",
    "Switch Note Lanes",
    "Flip Notes Vertically",
    "Scale Note Spacing",
    "Shear Lane Positions"
}
EDIT_LNS_MENUS = {                  -- sub-menus within the "Edit Notes (LNs)" menu
    "Apply Full LN",
    "Apply Inverse LN",
    "Adjust LN Lengths",
    "Change LNs to Rice"
}
INFO_MENUS = {                      -- sub-menus within the "Plugin Info" menu
    "How To Use VanillaChinchilla",
    "Keyboard Shortcuts",
    "Links",
    "Plugin Appearance Settings",
    "Plugin Behavior Settings",
    "Extra Goodies"
}
MENUS = {                           -- high-level menus for the plugin
    "Plugin Info & Settings",
    "Place Notes (Between Notes)",
    --"Place Notes (Around Note)",
    --"Place Notes (From Scratch)",
    "Edit Notes (General)",
    "Edit Notes (LNs)"
}
SCALE_TYPES = {                     -- ways to scale note spacing
    "Exponential",
    "Polynomial",
    "Circular"
}
STYLE_THEMES = {                    -- available style/appearance themes for the plugin
    "Rounded",
    "Boxed",
    "Rounded + Border",
    "Boxed + Border"
}

---------------------------------------------------------------------------------------------------
-- The Plugin & Menus -----------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------

-- Creates the plugin
function draw()
    local globalVars = {
        menuIndex = 1,
        colorThemeIndex = 1,
        styleThemeIndex = 1,
        rgbPeriod = 60,
        hideNoteInfoTooltip = false,
    }
    getVariables("globalVars", globalVars)
    
    state.SetValue("uiTooltipActive", false)
    
    autoOpenNextWindow(PLUGIN_NAME)
    setPluginAppearanceStyles(globalVars)
    setPluginAppearanceColors(globalVars)
    focusWindowOnHotkeyPress()
    centerWindowOnHotkeyPress()
    drawChinchillaStartupAnimation()
    
    imgui.Begin(PLUGIN_NAME, imgui_window_flags.AlwaysAutoResize)
    imgui.PushItemWidth(DEFAULT_WIDGET_WIDTH)
    chooseMenu(globalVars)
    local currentMenu = MENUS[globalVars.menuIndex]
    if currentMenu == "Plugin Info & Settings"      then pluginInfoMenu(globalVars) end
    if currentMenu == "Place Notes (Between Notes)" then placeNotesBetweenGeneralMenu(globalVars) end
    --if currentMenu == "Place Notes (Around Note)"   then end
    --if currentMenu == "Place Notes (From Scratch)"  then end
    if currentMenu == "Edit Notes (General)"        then editNotesGeneralMenu(globalVars) end
    if currentMenu == "Edit Notes (LNs)"            then editNotesLNsMenu(globalVars) end
    state.IsWindowHovered = imgui.IsWindowHovered()
    imgui.End()
    
    displayNoteInfoTooltip(globalVars)
    
    saveVariables("globalVars", globalVars)
end

---------------------------------------------------------------------------- Plugin Info & Settings

-- Creates the "Plugin Info & Settings" menu
-- Parameters
--    globalVars : list of variables used globally across all menus [Table]
function pluginInfoMenu(globalVars)
    local menuVars = {
        subMenuIndex = 1
    }
    getVariables("infoMenuVars", menuVars)
    chooseSubMenu(menuVars, INFO_MENUS)
    saveVariables("infoMenuVars", menuVars)
    local currentMenu = INFO_MENUS[menuVars.subMenuIndex]
    if currentMenu == "How To Use VanillaChinchilla" then howToUseVanillaChinchillaMenu() end
    if currentMenu == "Keyboard Shortcuts"           then keyboardShortcutsMenu() end
    if currentMenu == "Links"                        then linksMenu() end
    if currentMenu == "Plugin Appearance Settings"   then pluginAppearanceMenu(globalVars) end
    if currentMenu == "Plugin Behavior Settings"     then pluginBehaviorMenu(globalVars) end
    if currentMenu == "Extra Goodies"                then extraGoodiesMenu(globalVars) end
end
-- Creates the "How To Use VanillaChinchilla" menu
function howToUseVanillaChinchillaMenu()
    imgui.Text("1.  Choose a tool from the dropdown menus")
    imgui.Text("2.  Adjust the tool's settings")
    imgui.Text("3.  Select notes to use the tool at/between")
    imgui.Text("4.  Press ' T ' on your keyboard to use the tool")
end
-- Creates the "Keyboard Shortcuts" menu
function keyboardShortcutsMenu()
    local indentAmount = -6
    imgui.Indent(indentAmount)
    imgui.BulletText("Alt + (Q or W) = navigate menu")
    addSeparator()
    imgui.BulletText("Alt + (A or S) = navigate sub-menu")
    addSeparator()
    imgui.BulletText("Alt + Z = change a tool setting (sometimes)")
    addSeparator()
    imgui.BulletText("Alt + X = change a tool setting (sometimes)")
    addSeparator()
    imgui.BulletText("Alt + C = change a tool setting (sometimes)")
    addSeparator()
    imgui.BulletText("T = activate the big button that does stuff")
    addSeparator()
    imgui.BulletText("Shift + Tab = focus plugin + navigate inputs")
    tooltip("Useful when you click off the plugin but want to quickly change an input value")
    addSeparator()
    imgui.BulletText("Ctrl + Shift + Tab = center plugin window")
    tooltip("Useful when the plugin becomes offscreen")
    imgui.Unindent(indentAmount)
end
-- Creates the "Links" menu
function linksMenu()
    linkBox("GitHub Repository", "https://github.com/kloi34/VanillaChinchilla")
    local photoLink = "https://www.facebook.com/cameronschinchillas/photos/1876978765672324"
    linkBox("Cute Photo from Cameron's Chinchillas UK", photoLink) -- chinchilla bombs
end
-- Creates the "Plugin Appearance Settings" menu
-- Parameters
--    globalVars : list of variables used globally across all menus [Table]
function pluginAppearanceMenu(globalVars)
    chooseStyleTheme(globalVars)
    chooseColorTheme(globalVars)
    globalVars.styleThemeIndex = getNewComboIndexOnKeyPress(keys.Z, globalVars.styleThemeIndex,
                                                            STYLE_THEMES)
    globalVars.colorThemeIndex = getNewComboIndexOnKeyPress(keys.X, globalVars.colorThemeIndex,
                                                            COLOR_THEMES)
end
-- Creates the "Plugin Behavior Settings" menu
-- Parameters
--    globalVars : list of variables used globally across all menus [Table]
function pluginBehaviorMenu(globalVars)
    chooseNoteInfoTooltipVisibility(globalVars)
    globalVars.hideNoteInfoTooltip = getNewBooleanOnKeyPress(keys.Z, globalVars.hideNoteInfoTooltip)
end
-- Creates the "Extra Goodies" menu
-- Parameters
--    globalVars : list of variables used globally across all menus [Table]
function extraGoodiesMenu(globalVars)
    imgui.Text("No extra goodies implemented yet!")
    imgui.Text("Come back soon...")
end

----------------------------------------------------------------------- Place Notes (Between Notes)

-- Creates the "Place Notes (Between Notes)" menu
-- Parameters
--    globalVars : list of variables used globally across all menus [Table]
function placeNotesBetweenGeneralMenu(globalVars)
    local menuVars = {
        subMenuIndex = 1
    }
    getVariables("placeNotesBetweenMenuVars", menuVars)
    chooseSubMenu(menuVars, PLACE_NOTES_BETWEEN_GENERAL_MENUS)
    saveVariables("placeNotesBetweenMenuVars", menuVars)
    local currentMenu = PLACE_NOTES_BETWEEN_GENERAL_MENUS[menuVars.subMenuIndex]
    -- if currentMenu == "Shift Notes Up/Down"    then placeNotesBetweenSnapMenu() end
    if currentMenu == "Place Notes By Number" then placeNotesBetweenNumberMenu() end
end

function placeNotesBetweenNumberMenu()
    local settingVars = {
        noteCount = 1,
    }
    getVariables("placeNotesBetweenNumberVars", settingVars)
    chooseNoteCount(settingVars)
    saveVariables("placeNotesBetweenNumberVars", settingVars)
    addSeparator()
    local buttonText = "Place " .. settingVars.noteCount .. " notes between selected notes"
    local minimumNotes = 2
    simpleActionMenu(buttonText, minimumNotes, placeNotesBetweenNumber, nil, settingVars)
end
------------------------------------------------------------------------- Place Notes (Around Note)



------------------------------------------------------------------------ Place Notes (From Scratch)



------------------------------------------------------------------------------ Edit Notes (General)

-- Creates the "Edit Notes (General)" menu
-- Parameters
--    globalVars : list of variables used globally across all menus [Table]
function editNotesGeneralMenu(globalVars)
    local menuVars = {
        subMenuIndex = 1
    }
    getVariables("editGeneralMenuVars", menuVars)
    chooseSubMenu(menuVars, EDIT_GENERAL_MENUS)
    saveVariables("editGeneralMenuVars", menuVars)
    local currentMenu = EDIT_GENERAL_MENUS[menuVars.subMenuIndex]
    if currentMenu == "Shift Notes Up/Down"    then shiftNotesVerticallyMenu() end
    if currentMenu == "Shift Notes Left/Right" then shiftNotesHorizontallyMenu() end
    if currentMenu == "Switch Note Lanes"      then switchNoteLanesMenu() end
    if currentMenu == "Flip Notes Vertically"  then flipNotesVerticallyMenu() end
    if currentMenu == "Scale Note Spacing"     then scaleNoteSpacingMenu() end
    if currentMenu == "Shear Lane Positions"   then shearLanePositionsMenu() end
end
-- Creates the "Shift Notes Up/Down" menu
function shiftNotesVerticallyMenu()
    local settingVars = {
        milliseconds = 1
    }
    getVariables("shiftVertSettingVars", settingVars)
    chooseMilliseconds(settingVars)
    saveVariables("shiftVertSettingVars", settingVars)
    addSeparator()
    if settingVars.milliseconds == 0 then imgui.Text(":jerry:") return end
    
    local buttonText = getShiftVerticalButtonText(settingVars)
    local minimumNotes = 1
    simpleActionMenu(buttonText, minimumNotes, shiftNotesVertically, nil, settingVars)
end
-- Creates the "Shift Notes Left/Right" menu
function shiftNotesHorizontallyMenu()
    local settingVars = {
        directionRight = false
    }
    getVariables("shiftHorzSettingVars", settingVars)
    chooseDirection(settingVars)
    settingVars.directionRight = getNewBooleanOnKeyPress(keys.Z, settingVars.directionRight)
    saveVariables("shiftHorzSettingVars", settingVars)
    addSeparator()
    local buttonText = "Shift selected notes horizontally"
    local minimumNotes = 1
    simpleActionMenu(buttonText, minimumNotes, shiftNotesHorizontally, nil, settingVars)
end
-- Creates the "Switch Note Lanes" menu
function switchNoteLanesMenu()
    local settingVars = {
        oldLanesInNewLanes = enumeratedList(map.GetKeyCount()),
        importText = "Enter lane numbers here",
        selectedLaneIndexes = {}
    }
    getVariables("switchLanesSettingVars", settingVars)
    importLanesWidget(settingVars)
    addSeparator()
    imgui.Text("New positions of old lanes:")
    helpMarker("Click on the numbers to swap positions")
    displayOldLanesInNewLanes(settingVars)
    updateSelectedLaneIndexes(settingVars)
    addSeparator()
    button("Randomize", HALF_BUTTON_SIZE, randomizeOldLanesInNewLanes, nil, settingVars)
    executeFunctionOnKeyPress(keys.Z, randomizeOldLanesInNewLanes, nil, settingVars)
    imgui.SameLine(0, SAMELINE_SPACING)
    button("Reset", HALF_BUTTON_SIZE, resetOldLanesInNewLanes, nil, settingVars)
    executeFunctionOnKeyPress(keys.X, resetOldLanesInNewLanes, nil, settingVars)
    saveVariables("switchLanesSettingVars", settingVars)
    addSeparator()
    local buttonText = "Switch lanes of selected notes"
    local minimumNotes = 1
    simpleActionMenu(buttonText, minimumNotes, switchNoteLanes, nil, settingVars)
    showSwappingLane(settingVars)
end
-- Creates the "Flip Notes Vertically" menu
function flipNotesVerticallyMenu()
    local buttonText = "Flip selected notes vertically"
    local minimumNotes = 1
    simpleActionMenu(buttonText, minimumNotes, flipNotesVertically, nil, nil)
end
-- Creates the "Scale Note Spacing" menu
function scaleNoteSpacingMenu()
    local settingVars = {
        behaviorIndex = 1,
        scaleTypeIndex = 1,
        intensity = 0.5,
        minLNLength = MIN_LN_LENGTH
    }
    getVariables("scaleSpacingSettingVars", settingVars)
    chooseBehavior(settingVars)
    settingVars.behaviorIndex = getNewComboIndexOnKeyPress(keys.Z, settingVars.behaviorIndex,
                                                           BEHAVIORS)
    chooseScaleType(settingVars)
    settingVars.scaleTypeIndex = getNewComboIndexOnKeyPress(keys.X, settingVars.scaleTypeIndex,
                                                            SCALE_TYPES)
    chooseIntensity(settingVars)
    chooseMinLNLength(settingVars)
    saveVariables("scaleSpacingSettingVars", settingVars)
    addSeparator()
    local invalidIntensity = settingVars.intensity < SMALL_NUMBER_TOLERANCE
    if invalidIntensity then imgui.Text(":jerry:") return end
    
    local buttonText = "Scale spacing between selected notes"
    local minimumNotes = 2
    simpleActionMenu(buttonText, minimumNotes, scaleNoteSpacing, nil, settingVars)
end
-- Creates the "Shear Lane Positions" menu
function shearLanePositionsMenu()
    local settingVars = {
        directionRight = false,
        behaviorIndex = 1,
        scaleTypeIndex = 1,
        intensity = 0.5,
        milliseconds = 100
    }
    getVariables("shearPositionsSettingVars", settingVars)
    chooseDirection(settingVars)
    settingVars.directionRight = getNewBooleanOnKeyPress(keys.Z, settingVars.directionRight)
    addSeparator()
    chooseBehavior(settingVars)
    settingVars.behaviorIndex = getNewComboIndexOnKeyPress(keys.X, settingVars.behaviorIndex,
                                                           BEHAVIORS)
    chooseScaleType(settingVars)
    settingVars.scaleTypeIndex = getNewComboIndexOnKeyPress(keys.C, settingVars.scaleTypeIndex,
                                                            SCALE_TYPES)
    chooseIntensity(settingVars)
    chooseMilliseconds(settingVars)
    settingVars.milliseconds = clampToInterval(settingVars.milliseconds, 1, 10 * FUNNY_NUMBER)
    saveVariables("shearPositionsSettingVars", settingVars)
    addSeparator()
    local buttonText = "Shear positions of selected notes"
    local minimumNotes = 1
    simpleActionMenu(buttonText, minimumNotes, shearLanePositions, nil, settingVars)
end

---------------------------------------------------------------------------------- Edit Notes (LNs)

-- Creates the "Edit Notes (LNs)" menu
-- Parameters
--    globalVars : list of variables used globally across all menus [Table]
function editNotesLNsMenu(globalVars)
    local menuVars = {
        subMenuIndex = 1
    }
    getVariables("editLNsMenuVars", menuVars)
    chooseSubMenu(menuVars, EDIT_LNS_MENUS)
    saveVariables("editLNsMenuVars", menuVars)
    local currentMenu = EDIT_LNS_MENUS[menuVars.subMenuIndex]
    if currentMenu == "Apply Full LN"      then applyFullLNMenu() end
    if currentMenu == "Apply Inverse LN"   then applyInverseLNMenu() end
    if currentMenu == "Adjust LN Lengths"  then adjustLNLengthsMenu() end
    if currentMenu == "Change LNs to Rice" then changeLNsToRiceMenu() end
end
-- Creates the "Apply Full LN" menu
function applyFullLNMenu()
    local settingVars = {
        beatSnapGap = 4,
        minLNLength = MIN_LN_LENGTH,
        minLNGapTime = MIN_LN_GAP_LENGTH
    }
    getVariables("applyFullLNSettingVars", settingVars)
    chooseBeatSnapGap(settingVars)
    chooseMinLNLength(settingVars)
    chooseMinLNGapTime(settingVars)
    saveVariables("applyFullLNSettingVars", settingVars)
    addSeparator()
    local buttonText = "Apply full LN mod to selected notes"
    local minimumNotes = 2
    simpleActionMenu(buttonText, minimumNotes, applyFullLN, nil, settingVars)
end
-- Creates the "Apply Inverse LN" menu
function applyInverseLNMenu()
    local settingVars = {
        beatSnapGap = 4,
        minLNLength = MIN_LN_LENGTH,
        minLNGapTime = MIN_LN_GAP_LENGTH
    }
    getVariables("applyInverseLNSettingVars", settingVars)
    chooseBeatSnapGap(settingVars)
    chooseMinLNLength(settingVars)
    chooseMinLNGapTime(settingVars)
    saveVariables("applyInverseLNSettingVars", settingVars)
    addSeparator()
    local buttonText = "Apply inverse LN mod to selected notes"
    local minimumNotes = 2
    simpleActionMenu(buttonText, minimumNotes, applyInverseLN, nil, settingVars)
end
-- Creates the "Adjust LN Lengths" menu
function adjustLNLengthsMenu()
    local settingVars = {
        targetLNStart = false,
        milliseconds = 42
    }
    getVariables("LNsToRiceSettingVars", settingVars)
    chooseTargetLNSpot(settingVars)
    settingVars.targetLNStart = getNewBooleanOnKeyPress(keys.Z, settingVars.targetLNStart)
    addSeparator()
    chooseMilliseconds(settingVars)
    saveVariables("LNsToRiceSettingVars", settingVars)
    addSeparator()
    if settingVars.milliseconds == 0 then imgui.Text(":jerry:") return end
    
    local buttonText = getAdjustLNLengthsButtonText(settingVars)
    local minimumNotes = 1
    simpleActionMenu(buttonText, minimumNotes, adjustLNLengths, nil, settingVars)
end
-- Creates the "Change LNs to Rice" menu
function changeLNsToRiceMenu()
    local buttonText = "Change selected notes to rice"
    local minimumNotes = 1
    simpleActionMenu(buttonText, minimumNotes, changeLNsToRice, nil, nil)
end

---------------------------------------------------------------------------------------------------
-- Note Manipulation & Wizardry -------------------------------------------------------------------
---------------------------------------------------------------------------------------------------

function placeNotesBetweenNumber(settingVars)
    local selectedStartTime = state.SelectedHitObjects[1].StartTime
    local timeDifferencePerNote = (state.SelectedHitObjects[#state.SelectedHitObjects].StartTime - selectedStartTime) / (settingVars.noteCount + 1)
    local notesToAdd = {}
    for i = 1, settingVars.noteCount, 1 do
        local noteStartTime = selectedStartTime + i * timeDifferencePerNote
        addNoteToList(notesToAdd, state.SelectedHitObjects[1], math.floor(noteStartTime), (i + state.SelectedHitObjects[1].Lane - 1) % 4 + 1, nil, nil, nil)
    end
    addNotes(notesToAdd)
end

-- Shifts selected notes vertically
-- Parameters
--    settingVars : list of variables used for the current menu [Table]
function shiftNotesVertically(settingVars)
    local msToShift = settingVars.milliseconds
    local notesToAdd = {}
    local notesToRemove = state.SelectedHitObjects
    for _, note in pairs(notesToRemove) do
        local newStartTime = note.StartTime + msToShift
        local newEndTime = note.EndTime
        local noteIsLN = isLN(note)
        if noteIsLN then newEndTime = note.EndTime + msToShift end
        addNoteToList(notesToAdd, note, newStartTime, nil, newEndTime, nil, nil)
    end
    removeAndAddNotes(notesToRemove, notesToAdd)
end
-- Shifts selected notes horizontally across lanes
-- Parameters
--    settingVars : list of variables used for the current menu [Table]
function shiftNotesHorizontally(settingVars)
    local totalNumLanes = map.GetKeyCount()
    local laneShift = -1
    if settingVars.directionRight then laneShift = 1 end
    local notesToAdd = {}
    local notesToRemove = state.SelectedHitObjects
    for _, note in pairs(notesToRemove) do
        local newLane = shiftWrapLaneNum(note.Lane, laneShift, totalNumLanes)
        addNoteToList(notesToAdd, note, nil, newLane, nil, nil, nil)
    end
    removeAndAddNotes(notesToRemove, notesToAdd)
end
-- Switches the lanes of selected notes
-- Parameters
--    settingVars : list of variables used for the current menu [Table]
function switchNoteLanes(settingVars)
    local oldLaneToNewLane = {}
    for newLane = 1, #settingVars.oldLanesInNewLanes do
        local oldLane = settingVars.oldLanesInNewLanes[newLane]
        oldLaneToNewLane[oldLane] = newLane
    end
    local notesToAdd = {}
    local notesToRemove = state.SelectedHitObjects
    for _, note in pairs(notesToRemove) do
        local newLane = oldLaneToNewLane[note.Lane]
        addNoteToList(notesToAdd, note, nil, newLane, nil, nil, nil)
    end
    removeAndAddNotes(notesToRemove, notesToAdd)
end
-- Flips selected notes vertically
function flipNotesVertically()
    local notesToAdd = {}
    local notesToRemove = state.SelectedHitObjects
    local boundaryTimes = getBoundaryTimes(notesToRemove)
    -- 2 * average(boundaryTimes.max, boundaryTimes.min) = 2 * midpointTime = doubleMidpointTime
    local doubleMidpointTime = boundaryTimes.max + boundaryTimes.min
    for _, note in pairs(notesToRemove) do
        local noteIsLN = isLN(note)
        local newStartTime = doubleMidpointTime - note.StartTime
        local newEndTime = 0
        if noteIsLN then
            newStartTime = doubleMidpointTime - note.EndTime
            newEndTime = doubleMidpointTime - note.StartTime
        end
        addNoteToList(notesToAdd, note, newStartTime, nil, newEndTime, nil, nil)
    end
    removeAndAddNotes(notesToRemove, notesToAdd)
end
-- Scales note spacing between selected notes
-- Parameters
--    settingVars : list of variables used for the current menu [Table]
function scaleNoteSpacing(settingVars)
    local notesToAdd = {}
    local notesToRemove = state.SelectedHitObjects
    local boundaryTimes = getBoundaryTimes(notesToRemove)
    local totalIntervalTime = boundaryTimes.max - boundaryTimes.min
    for _, note in pairs(notesToRemove) do
        local startTimeFromStart = note.StartTime - boundaryTimes.min
        local startPercentFromStart = startTimeFromStart / totalIntervalTime
        local newStartPercentFromStart = scalePercent(settingVars, startPercentFromStart)
        local newStartTime = boundaryTimes.min + newStartPercentFromStart * totalIntervalTime
        local newEndTime = 0
        local noteIsLN = isLN(note)
        if noteIsLN then
            local endTimeFromStart = note.EndTime - boundaryTimes.min
            local endPercentFromStart = endTimeFromStart / totalIntervalTime
            local newEndPercentFromStart = scalePercent(settingVars, endPercentFromStart)
            newEndTime = boundaryTimes.min + newEndPercentFromStart * totalIntervalTime
            local newLNLength = newEndTime - newStartTime
            if newLNLength < settingVars.minLNLength then newEndTime = 0 end
        end
        addNoteToList(notesToAdd, note, newStartTime, nil, newEndTime, nil, nil)
    end
    removeAndAddNotes(notesToRemove, notesToAdd)
end
-- Shears positions across the lanes of selected notes
-- Parameters
--    settingVars : list of variables used for the current menu [Table]
function shearLanePositions(settingVars)
    local totalNumLanes = map.GetKeyCount()
    local notesToAdd = {}
    local notesToRemove = state.SelectedHitObjects
    local isLaneSelected = {}
    for _, note in pairs(notesToRemove) do
        isLaneSelected[note.Lane] = true
    end
    local totalLanesSelected = 0
    for lane = 1, totalNumLanes do
        if isLaneSelected[lane] then
            totalLanesSelected = totalLanesSelected + 1
        end
    end
    local totalInterval = settingVars.milliseconds
    local shearAmounts = generateLinearSet(0, totalInterval, totalLanesSelected)
    if not settingVars.directionRight then shearAmounts = getReverseList(shearAmounts) end
    for i = 1, #shearAmounts do
        local oldShearAmount = shearAmounts[i]
        local oldPercentFromStart = oldShearAmount / totalInterval
        local newPercentFromStart = scalePercent(settingVars, oldPercentFromStart)
        local newShearAmount = newPercentFromStart * totalInterval
        shearAmounts[i] = newShearAmount
    end
    local laneToShearAmount = {}
    for lane = 1, totalNumLanes do
        if isLaneSelected[lane] then
            laneToShearAmount[lane] = table.remove(shearAmounts, 1)
        end
    end
    for _, note in pairs(notesToRemove) do
        local shearAmount = laneToShearAmount[note.Lane]
        local noteIsLN = isLN(note)
        local newStartTime = note.StartTime + shearAmount
        local newEndTime = 0
        if noteIsLN then newEndTime = note.EndTime + shearAmount end
        addNoteToList(notesToAdd, note, newStartTime, nil, newEndTime, nil, nil)
    end
    removeAndAddNotes(notesToRemove, notesToAdd)
end
-- Applies the full LN mod onto selected notes
function applyFullLN(settingVars)
    local totalNumLanes = map.GetKeyCount()
    local notesInLanes = {}
    for lane = 1, totalNumLanes do
        notesInLanes[lane] = {}
    end
    local notesToAdd = {}
    local notesToRemove = state.SelectedHitObjects
    for _, note in pairs(notesToRemove) do
        table.insert(notesInLanes[note.Lane], note)
    end
    for lane = 1, totalNumLanes do
        local notesInCurrentLane = notesInLanes[lane]
        convertLaneToFullLN(settingVars, notesToAdd, notesInCurrentLane)
    end
    removeAndAddNotes(notesToRemove, notesToAdd)
end
-- Converts a single list of notes from the same lane to full LN
-- Algorithm is based on the inverse LN algorithm in convertLaneToInverseLN()
-- Parameters
--    settingVars     : list of variables used for the current menu [Table]
--    notesToAdd      : list of all notes to add for inverse LN [Table]
--    notesInSameLane : list of notes in the same lane to convert and add for inverse LN [Table]
function convertLaneToFullLN(settingVars, notesToAdd, notesInSameLane)
    if #notesInSameLane == 0 then return end
    
    table.sort(notesInSameLane, sortAscendingStartTime)
    for i = 1, #notesInSameLane - 1 do
        local currentNote = notesInSameLane[i]
        local currentNoteTime = currentNote.StartTime
        local nextNote = notesInSameLane[i + 1]
        local nextNoteTime = nextNote.StartTime
        local timeGap = calculateLNGapTime(settingVars, currentNoteTime, nextNoteTime)
        
        local newEndTime = nextNoteTime - timeGap
        local newEndTimeUnacceptable = (newEndTime - currentNoteTime) < settingVars.minLNLength
        if newEndTimeUnacceptable then newEndTime = 0 end
        addNoteToList(notesToAdd, currentNote, nil, nil, newEndTime, nil, nil)
    end
    local lastNote = notesInSameLane[#notesInSameLane]
    addNoteToList(notesToAdd, lastNote, nil, nil, nil, nil, nil)
end
-- Applies the inverse LN mod onto selected notes
-- Parameters
--    settingVars : list of variables used for the current menu [Table]
function applyInverseLN(settingVars)
    local totalNumLanes = map.GetKeyCount()
    local notesInLanes = {}
    for lane = 1, totalNumLanes do
        notesInLanes[lane] = {}
    end
    local notesToAdd = {}
    local notesToRemove = state.SelectedHitObjects
    for _, note in pairs(notesToRemove) do
        table.insert(notesInLanes[note.Lane], note)
    end
    for lane = 1, totalNumLanes do
        local notesInCurrentLane = notesInLanes[lane]
        convertLaneToFullLN(settingVars, notesToAdd, notesInCurrentLane)
    end
    removeAndAddNotes(notesToRemove, notesToAdd)
end
-- Converts a single list of notes from the same lane to inverse LN
--[[
NOTE: Calculations/algorithms are mostly based on the ApplyInverse() method at
https://github.com/Quaver/Quaver.API/blob/master/Quaver.API/Maps/Qua.cs
There are some notable differences though, so keep that in mind.

One interesting difference is the difficulty calculation (as of March 2024) that results
from the inversing of the whole map. The built-in inverse mod tool applied to the whole map
can output the same map as using this plugin's inverse tool on the whole map, but the resulting
difficulty calculations might not be the same (because of how LN notes with the same start time
but different end times are ordered in the .qua file)

Relevant comments from the ApplyInverse() method:

// Summary of the changes:
// Regular 1 -> Regular 2 => LN until 2 - time gap
// Regular 1 -> LN 2      => LN until 2
//      LN 1 -> Regular 2 => LN from 1 end until 2 - time gap
//      LN 1 -> LN 2      => LN from 1 end until 2
//
// Exceptions:
// - last LNs are kept (treated as regular 2)
// - last regular objects are removed and treated as LN 2
--]]
-- Parameters
--    settingVars     : list of variables used for the current menu [Table]
--    notesToAdd      : list of all notes to add for inverse LN [Table]
--    notesInSameLane : list of notes in the same lane to convert and add for inverse LN [Table]
function convertLaneToInverseLN(settingVars, notesToAdd, notesInSameLane)
    if #notesInSameLane == 0 then return end
    
    table.sort(notesInSameLane, sortAscendingStartTime)
    for i = 1, #notesInSameLane - 1 do
        local currentNote = notesInSameLane[i]
        local currentNoteTime = currentNote.StartTime
        local nextNote = notesInSameLane[i + 1]
        local nextNoteTime = nextNote.StartTime
        
        local newStartTime = currentNoteTime
        local newEndTime = nextNoteTime
        local currentNoteIsLN = isLN(currentNote)
        local nextNoteIsLN = isLN(nextNote)
        local isLastInversion = (i == #notesInSameLane - 1)
        local timeGapNeeded = not nextNoteIsLN or (isLastInversion and nextNoteIsLN)
        local timeGap = calculateLNGapTime(settingVars, currentNoteTime, nextNoteTime)
        
        if currentNoteIsLN then newStartTime = currentNote.EndTime end
        if isLastInversion and (not nextNoteIsLN) then timeGap = 0 end
        if timeGapNeeded then newEndTime = newEndTime - timeGap end
        
        local newEndTimeUnacceptable = (newEndTime - newStartTime) < settingVars.minLNLength
        if newEndTimeUnacceptable and (not currentNoteIsLN) then newEndTime = 0 end
        
        if not (newEndTimeUnacceptable and currentNoteIsLN) then
            addNoteToList(notesToAdd, currentNote, newStartTime, nil, newEndTime, nil, nil)
        end
    end
    local lastNote = notesInSameLane[#notesInSameLane]
    local lastNoteIsLN = isLN(lastNote)
    if lastNoteIsLN or #notesInSameLane == 1 then table.insert(notesToAdd, lastNote) end
end
-- Adjusts the lengths of LNs of selected notes
-- Parameters
--    settingVars : list of variables used for the current menu [Table]
function adjustLNLengths(settingVars)
    local msToMove = settingVars.milliseconds
    local notesToAdd = {}
    local notesToRemove = state.SelectedHitObjects
    for _, note in pairs(notesToRemove) do
        local noteIsLN = isLN(note)
        local newStartTime = note.StartTime
        local newEndTime = note.StartTime
        if noteIsLN then newEndTime = note.EndTime end
        if settingVars.targetLNStart then
            newStartTime = newStartTime + msToMove
        else
            newEndTime = newEndTime + msToMove
        end
        if newStartTime >= newEndTime then newEndTime = 0 end
        addNoteToList(notesToAdd, note, newStartTime, nil, newEndTime, nil, nil)
    end
    removeAndAddNotes(notesToRemove, notesToAdd)
end
-- Changes selected notes to rice
function changeLNsToRice()
    local notesToAdd = {}
    local notesToRemove = state.SelectedHitObjects
    for _, note in pairs(notesToRemove) do
        local newEndTime = 0
        addNoteToList(notesToAdd, note, nil, nil, newEndTime, nil, nil)
    end
    removeAndAddNotes(notesToRemove, notesToAdd)
end

---------------------------------------------------------------------------------------------------
-- Plugin Accesibility ----------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------

-- Automatically expands the next plugin window, making it not start collapsed
-- Parameters
--    windowName : name of the next plugin window [String]
function autoOpenNextWindow(windowName)
    if state.GetValue(windowName) then return end
    
    imgui.SetNextWindowCollapsed(false)
    state.SetValue(windowName, true)
end
-- Makes the next plugin window focused/active if Shift + Tab is pressed
function focusWindowOnHotkeyPress()
    local shiftKeyDown = utils.IsKeyDown(keys.LeftShift) or
                         utils.IsKeyDown(keys.RightShift)
    local tabKeyPressed = utils.IsKeyPressed(keys.Tab)
    if shiftKeyDown and tabKeyPressed then imgui.SetNextWindowFocus() end
end
-- Centers the main plugin window if Ctrl + Shift + Tab is pressed
function centerWindowOnHotkeyPress()
    local ctrlKeyDown = utils.IsKeyDown(keys.LeftControl) or
                        utils.IsKeyDown(keys.RightControl)
    local shiftKeyDown = utils.IsKeyDown(keys.LeftShift) or
                         utils.IsKeyDown(keys.RightShift)
    local tabKeyPressed = utils.IsKeyPressed(keys.Tab)
    if not (ctrlKeyDown and shiftKeyDown and tabKeyPressed) then return end
    
    local windowWidth, windowHeight = table.unpack(state.WindowSize)
    local pluginWidth, pluginHeight = table.unpack(imgui.GetWindowSize())
    local centeringX = (windowWidth - pluginWidth) / 2
    local centeringY = (windowHeight - pluginHeight) / 2
    local centeringCoords = {centeringX, centeringY}
    imgui.SetWindowPos(PLUGIN_NAME, centeringCoords)
end
-- Changes the highest level menu if Alt + (Q or W) is pressed
-- Parameters
--    globalVars : list of variables used globally across all menus [Table]
function changeMenuOnHotkeyPress(globalVars)
    local altKeyDown = utils.IsKeyDown(keys.LeftAlt) or
                       utils.IsKeyDown(keys.RightAlt)
    local qKeyPressed = utils.IsKeyPressed(keys.Q)
    local wKeyPressed = utils.IsKeyPressed(keys.W)
    if not (altKeyDown and (qKeyPressed or wKeyPressed)) then return end
    
    local newMenuIndex
    if qKeyPressed then newMenuIndex = globalVars.menuIndex - 1 end
    if wKeyPressed then newMenuIndex = globalVars.menuIndex + 1 end
    globalVars.menuIndex = wrapToInterval(newMenuIndex, 1, #MENUS)
end
-- Changes the sub menu if Alt + (A or S) is pressed
-- Parameters
--    menuVars     : list of variables used for the current menu [Table]
--    subMenusList : list of sub-menus to chose from [Table]
function changeSubMenuOnHotkeyPress(menuVars, subMenusList)
    local altKeyDown = utils.IsKeyDown(keys.LeftAlt) or
                       utils.IsKeyDown(keys.RightAlt)
    local aKeyPressed = utils.IsKeyPressed(keys.A)
    local sKeyPressed = utils.IsKeyPressed(keys.S)
    if not (altKeyDown and (aKeyPressed or sKeyPressed)) then return end
    
    local newSubMenuIndex
    if aKeyPressed then newSubMenuIndex = menuVars.subMenuIndex - 1 end
    if sKeyPressed then newSubMenuIndex = menuVars.subMenuIndex + 1 end
     menuVars.subMenuIndex = wrapToInterval(newSubMenuIndex, 1, #subMenusList)
end
-- Executes a function if a key is pressed
-- Parameters
--    key         : key to be pressed [keys.~, from Quaver's MonoGame.Framework.Input.Keys enum]
--    func        : function to execute once key is pressed [Function]
--    globalVars  : list of variables used globally across all menus [Table]
--    settingVars : list of variables used for the current menu [Table]
function executeFunctionOnKeyPress(key, func, globalVars, settingVars)
    if not utils.IsKeyPressed(key) then return end
    
    if globalVars and settingVars then func(globalVars, settingVars) return end
    if globalVars then func(globalVars) return end
    if settingVars then func(settingVars) return end
    func()
end
-- Returns the new combo index when ALT + a specific key is pressed [Int]
-- Parameters
--    key        : key to be pressed [keys.~, from Quaver's MonoGame.Framework.Input.Keys enum]
--    comboIndex : current index of the combo [Int]
--    comboList  : list used by the combo [Table]
function getNewComboIndexOnKeyPress(key, comboIndex, comboList)
    local altKeyDown = utils.IsKeyDown(keys.LeftAlt) or
                       utils.IsKeyDown(keys.RightAlt)
    if not altKeyDown then return comboIndex end
    
    if not utils.IsKeyPressed(key) then return comboIndex end
    
    local newComboIndex = comboIndex + 1
    return wrapToInterval(newComboIndex, 1, #comboList)
end
-- Returns the opposite boolean when ALT + a specific key is pressed [Int]
-- Parameters
--    key     : key to be pressed [keys.~, from Quaver's MonoGame.Framework.Input.Keys enum]
--    boolean : [Boolean]
function getNewBooleanOnKeyPress(key, boolean)
    local altKeyDown = utils.IsKeyDown(keys.LeftAlt) or
                       utils.IsKeyDown(keys.RightAlt)
    if not altKeyDown then return boolean end
    
    if not utils.IsKeyPressed(key) then return boolean end
    
    return not boolean
end

---------------------------------------------------------------------------------------------------
-- Abstractions -----------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------

------------------------------------------------------------------------ Menu encapsulation/cleanup

-- Shows note info in a tooltip for a single selected note if enabled
-- Parameters
--    globalVars : list of variables used globally across all menus [Table]
function displayNoteInfoTooltip(globalVars)
    if globalVars.hideNoteInfoTooltip then return end
    
    local oneNoteSelected = #state.SelectedHitObjects == 1
    if not oneNoteSelected then return end
    
    local uiTooltipAlreadyActive = isTooltipAlreadyActive()
    if uiTooltipAlreadyActive then return end
    
    setTooltipActive()
    imgui.BeginTooltip()
    imgui.Text("Note Info:")
    local selectedNote = state.SelectedHitObjects[1]
    imgui.Text(table.concat({"StartTime = ", selectedNote.StartTime, " ms"}))
    local noteIsNotLN = not isLN(selectedNote)
    if noteIsNotLN then imgui.EndTooltip() return end
    
    local lnLength = selectedNote.EndTime - selectedNote.StartTime
    imgui.Text(table.concat({"EndTime = ", selectedNote.EndTime, " ms"}))
    imgui.Text(table.concat({"LN Length = ", lnLength, " ms"}))
    imgui.EndTooltip()
end
-- Returns text for the action button of the "Shift Notes Up/Down" menu [String]
-- Parameters
--    settingVars : list of variables used for the current menu [Table]
function getShiftVerticalButtonText(settingVars)
    local buttonTextTable = {"Shift selected notes by "}
    if settingVars.milliseconds > 0 then buttonTextTable[#buttonTextTable + 1] = "+" end
    buttonTextTable[#buttonTextTable + 1] = settingVars.milliseconds
    buttonTextTable[#buttonTextTable + 1] = " ms"
    return table.concat(buttonTextTable)
end
-- Creates the widget for importing old lanes in new positions
-- Parameters
--    settingVars : list of variables used for the current menu [Table]
function importLanesWidget(settingVars)
    local imguiFlag = imgui_input_text_flags.AutoSelectAll
    local label = "Import Lanes"
    local oldImportText = settingVars.importText
    local importTextChanged, newImportText = imgui.InputText(label, oldImportText, 100, imguiFlag)
    settingVars.importText = newImportText
    if importTextChanged then importLaneNumbers(settingVars) end
    helpMarker("Import space-separated numbers\n\nExamples (4K & 7K):\n2 1 4 3\n3 2 1 4 7 6 5")
end
-- Imports lane numbers for the switch note lanes menu
-- Parameters
--    settingVars : list of variables used for the current menu [Table]
function importLaneNumbers(settingVars)
    local totalNumLanes = map.GetKeyCount()
    local regex = "(%d+)"
    local importedLaneNumbers = {}
    for laneNumberString, _ in string.gmatch(settingVars.importText, regex) do
        local laneNumber = tonumber(laneNumberString)
        if laneNumber > 0 and laneNumber <= totalNumLanes then
            table.insert(importedLaneNumbers, laneNumber)
        end
    end
    local laneNumbersNoDuplicates = removeDuplicateValues(importedLaneNumbers)
    if #laneNumbersNoDuplicates ~= totalNumLanes then return end
    
    settingVars.oldLanesInNewLanes = laneNumbersNoDuplicates
end
-- Shows the old lanes in the new lane positions as buttons (for switching note lanes)
-- Parameters
--    settingVars : list of variables used for the current menu [Table]
function displayOldLanesInNewLanes(settingVars)
    local totalNumLanes = map.GetKeyCount() 
    for i = 1, totalNumLanes do
        if i ~= 1 then imgui.SameLine(0, SAMELINE_SPACING) end
        newLaneButton(settingVars, i)
    end
end
-- Creates a new lane button (for switching note lanes)
-- Parameters
--    settingVars : list of variables used for the current menu [Table]
--    i           : current new lane button number to create [Int]
function newLaneButton(settingVars, i)
    local currentOldLane = settingVars.oldLanesInNewLanes[i]
    local buttonText = table.concat({currentOldLane, "##oldLaneInNewLaneButton"})
    if not imgui.Button(buttonText, LANE_BUTTON_SIZE) then return end
    
    table.insert(settingVars.selectedLaneIndexes, i)
end
-- Updates selected lane indexes (for switching note lanes)
-- Parameters
--    settingVars : list of variables used for the current menu [Table]
function updateSelectedLaneIndexes(settingVars)
    if #settingVars.selectedLaneIndexes < 2 then return end
    
    local laneIndex1 = settingVars.selectedLaneIndexes[1]
    local laneIndex2 = settingVars.selectedLaneIndexes[2]
    local oldLane1 = settingVars.oldLanesInNewLanes[laneIndex1]
    local oldLane2 = settingVars.oldLanesInNewLanes[laneIndex2]
    settingVars.oldLanesInNewLanes[laneIndex1] = oldLane2
    settingVars.oldLanesInNewLanes[laneIndex2] = oldLane1
    settingVars.selectedLaneIndexes = {}
end
-- Shows the currently selected lane to be swapped (for switching note lanes)
-- Parameters
--    settingVars : list of variables used for the current menu [Table]
function showSwappingLane(settingVars)
    if #settingVars.selectedLaneIndexes == 0 then return end
    
    local uiTooltipAlreadyActive = isTooltipAlreadyActive()
    if uiTooltipAlreadyActive then return end
    
    setTooltipActive()
    imgui.BeginTooltip()
    local selectedLaneIndex = settingVars.selectedLaneIndexes[1]
    local selectedOldLane = settingVars.oldLanesInNewLanes[selectedLaneIndex]
    imgui.Button(selectedOldLane, LANE_BUTTON_SIZE)
    imgui.EndTooltip()
end
-- Randomizes the old lanes in new lanes list
-- Parameters
--    settingVars : list of variables used for the current menu [Table]
function randomizeOldLanesInNewLanes(settingVars)
    local newLanes = enumeratedList(map.GetKeyCount())
    settingVars.oldLanesInNewLanes = {}
    while #newLanes > 0 do
        local randomIndex = math.random(1, #newLanes)
        local randomLane = table.remove(newLanes, randomIndex)
        table.insert(settingVars.oldLanesInNewLanes, randomLane)
    end
end
-- Resets the old lanes in new lanes list
-- Parameters
--    settingVars : list of variables used for the current menu [Table]
function resetOldLanesInNewLanes(settingVars)
    settingVars.oldLanesInNewLanes = enumeratedList(map.GetKeyCount())
end
-- Returns text for the action button of the "Adjust LN Lengths" menu [String]
-- Parameters
--    settingVars : list of variables used for the current menu [Table]
function getAdjustLNLengthsButtonText(settingVars)
    local buttonTextTable = {"Change selected notes' LN "}
    if settingVars.targetLNStart then
        table.insert(buttonTextTable, "start ")
    else
        table.insert(buttonTextTable, "end ")
    end
    table.insert(buttonTextTable, "by ")
    if settingVars.milliseconds > 0 then buttonTextTable[#buttonTextTable + 1] = "+" end
    buttonTextTable[#buttonTextTable + 1] = settingVars.milliseconds
    buttonTextTable[#buttonTextTable + 1] = " ms"
    return table.concat(buttonTextTable)
end

--------------------------------------------------------------------------------------- Map related

-- Adds a new note to a list based on an existing note
-- Parameters
--    noteList    : list to add the new note to [Table]
--    defaultNote : the default note attributes to use for the new note [Quaver HitObject]
--    startTime   : new start offset (milliseconds) of the note to add [Int(/Float?)]
--    lane        : new lane of the note to add [Int]
--    endTime     : new end offset (milliseconds) of the note to add [Int(/Float?)]
--    hitSound    : new hitsound of the note to add [Quaver HitSound]
--    editorLayer : new editor layer of the note to add [Quaver EditorLayer]
function addNoteToList(noteList, defaultNote, startTime, lane, endTime, hitSound, editorLayer)
    local newStartTime = startTime or defaultNote.StartTime
    local newLane = lane or defaultNote.Lane
    local newEndTime = endTime or defaultNote.EndTime
    local newHitSound = hitSound or defaultNote.HitSound
    local newEditorLayer = editorLayer or defaultNote.EditorLayer
    local newNote = utils.CreateHitObject(newStartTime, newLane, newEndTime,
                                          newHitSound, newEditorLayer)
    table.insert(noteList, newNote)
end
-- Calculates and returns the current note's LN gap time based on the beat snap [Int]
-- Parameters
--    settingVars     : list of variables used for the current menu [Table]
--    currentNoteTime : millisecond time of the current note [Int]
--    nextNoteTime    : millisecond time of the next note [Int]
function calculateLNGapTime(settingVars, currentNoteTime, nextNoteTime)
    local beatSnap = settingVars.beatSnapGap
    if beatSnap == 0 then return settingVars.minLNGapTime end
    
    local timingPointAtCurrentNote = map.GetTimingPointAt(currentNoteTime)
    if timingPointAtCurrentNote == nil then timingPointAtCurrentNote = map.TimingPoints[1] end
    local timingPointAtNextNote = map.GetTimingPointAt(nextNoteTime)
    if timingPointAtNextNote == nil then timingPointAtNextNote = timingPointAtCurrentNote end
    
    -- The larger BPM gives us the shortest duration to use for calculations that are safe
    local maxBPM = math.max(timingPointAtCurrentNote.Bpm, timingPointAtNextNote.Bpm)
    local millisecondsInMinute = 60000
    local snapGapDuration = millisecondsInMinute / (beatSnap * maxBPM)
    local roundedSnapGapDuration = round(snapGapDuration, 0)
    local timeGap = math.max(settingVars.minLNGapTime, roundedSnapGapDuration)
    return timeGap
end
-- Returns whether or not there's enough selected notes [Boolean]
-- Parameters
--    minimumNotes : minimum number of notes needed to be selected [Int]
function checkEnoughSelectedNotes(minimumNotes)
    local selectedNotes = state.SelectedHitObjects
    local numSelectedNotes = #selectedNotes
    if numSelectedNotes == 0 then return false end
    
    if numSelectedNotes > map.GetKeyCount() then return true end
    
    if minimumNotes == 1 then return true end
    
    local firstSelectedStartTime = selectedNotes[1].StartTime
    local lastSelectedStartTime = selectedNotes[numSelectedNotes].StartTime
    return firstSelectedStartTime ~= lastSelectedStartTime
end
-- Returns a table with the minimum time and maximum time of a list of notes [Table]
-- Parameters
--    notes : list of notes [Table]
function getBoundaryTimes(notes)
    local min = math.huge
    local max = -math.huge
    for _, note in pairs(notes) do
        min = math.min(note.StartTime, min)
        max = math.max(note.StartTime, note.EndTime, max)
    end
    return {min = min, max = max}
end
-- Returns whether or not the given note is a LN [Boolean]
-- Parameters
--    note : [Quaver HitObject]
function isLN(note) return note.EndTime ~= 0 end
-- Adds the given notes
-- Parameters
--    notesToAdd    : list of notes to add [Table]
function addNotes(notesToAdd)
   actions.PlaceHitObjectBatch(notesToAdd)
end
-- Removes and adds the given notes (and auto-selects the newly added notes)
-- Parameters
--    notesToRemove : list of notes to remove [Table]
--    notesToAdd    : list of notes to add [Table]
function removeAndAddNotes(notesToRemove, notesToAdd)
    local editorActions = {
        utils.CreateEditorAction(action_type.RemoveHitObjectBatch, notesToRemove),
        utils.CreateEditorAction(action_type.PlaceHitObjectBatch, notesToAdd)
    }
    actions.PerformBatch(editorActions)
    actions.SetHitObjectSelection(notesToAdd)
end

----------------------------------------------------------------------------------------------- GUI

-- Creates an imgui button
-- Parameters
--    text        : text on the button [String]
--    size        : dimensions of the button [Table]
--    func        : function to execute once button is pressed [Function]
--    globalVars  : list of variables used globally across all menus [Table]
--    settingVars : list of variables used for the current menu [Table]
function button(text, size, func, globalVars, settingVars)
    if not imgui.Button(text, size) then return end
    if globalVars and settingVars then func(globalVars, settingVars) return end
    if globalVars then func(globalVars) return end
    if settingVars then func(settingVars) return end
    func()
end
-- Creates an imgui combo (dropdown list)
-- Returns the updated index of the item in the list that is selected [Int]
-- Parameters
--    label     : label for the combo [String]
--    list      : list for the combo to use [Table]
--    listIndex : current index of the item from the list being selected in the combo [Int]
function combo(label, list, listIndex)
    local currentComboItem = list[listIndex]
    local comboFlag = imgui_combo_flags.HeightLarge
    if not imgui.BeginCombo(label, currentComboItem, comboFlag) then return listIndex end
    
    local newListIndex = listIndex
    for i = 1, #list do
        local listItem = list[i]
        if imgui.Selectable(listItem) then newListIndex = i end
    end
    imgui.EndCombo()
    return newListIndex
end
-- Creates a simple action menu + button that does things
-- Parameters
--    buttonText   : text on the button that appears [String]
--    minimumNotes : minimum number of notes to select before the action button appears [Int/Float]
--    actionfunc   : function to execute once button is pressed [Function]
--    globalVars   : list of variables used globally across all menus [Table]
--    settingVars  : list of variables used for the current menu [Table]
function simpleActionMenu(buttonText, minimumNotes, actionfunc, globalVars, settingVars)    
    local enoughSelectedNotes = checkEnoughSelectedNotes(minimumNotes)
    local infoText = table.concat({"Select ", minimumNotes, " or more notes"})
    if not enoughSelectedNotes then imgui.Text(infoText) return end
    
    button(buttonText, ACTION_BUTTON_SIZE, actionfunc, globalVars, settingVars)
    tooltip("Press ' T ' on your keyboard to do the same thing as this button")
    executeFunctionOnKeyPress(keys.T, actionfunc, globalVars, settingVars)
end
-- Returns whether or not a tooltip is already active [Boolean]
function isTooltipAlreadyActive() return state.GetValue("uiTooltipActive") end
-- Sets the state to recognize that a tooltip is active
function setTooltipActive() state.SetValue("uiTooltipActive", true) end


---------------------------------------------------------------------------------------------- Math

-- Returns a set of linear values [Table]
-- Parameters
--    startValue : starting value of the linear set [Int/Float]
--    endValue   : ending value of the linear set [Int/Float]
--    numValues  : total number of values in the linear set [Int]
function generateLinearSet(startValue, endValue, numValues)
    local linearSet = {startValue}
    if numValues < 2 then return linearSet end
    
    local increment = (endValue - startValue) / (numValues - 1)
    for i = 1, (numValues - 1) do
        table.insert(linearSet, startValue + i * increment)
    end
    return linearSet
end
-- Scales a percent value based on the selected scale type
-- Scaling graphs on Desmos: https://www.desmos.com/calculator/nw0lpykb9r
-- Parameters
--    settingVars : list of variables used for the current menu [Table]
--    percent     : percent value to scale [Int/Float]
function scalePercent(settingVars, percent)
    local behaviorType = BEHAVIORS[settingVars.behaviorIndex]
    local speedUpType = behaviorType == "Speed up"
    local workingPercent = percent
    if speedUpType then workingPercent = 1 - percent end
    local newPercent
    local a = settingVars.intensity
    local scaleType = SCALE_TYPES[settingVars.scaleTypeIndex]
    if scaleType == "Exponential" then
        local exponent = a * (workingPercent - 1)
        newPercent = (workingPercent * math.exp(exponent))
    elseif scaleType == "Polynomial" then
        local exponent = a + 1
        newPercent = workingPercent ^ exponent
    elseif scaleType == "Circular" then
        if a == 0 then return percent end
        
        local b = 1 / (a ^ (a + 1))
        local radicand = (b + 1) ^ 2 + b ^ 2 - (workingPercent + b) ^ 2
        newPercent = b + 1 - math.sqrt(radicand)
    end
    if speedUpType then newPercent = 1 - newPercent end
    return clampToInterval(newPercent, 0, 1)
end
-- Returns the average of two numbers [Int/Float]
-- Parameters
--    x : first number [Int/Float]
--    y : second number [Int/Float]
function average(x, y) return (x + y) / 2 end
-- Rounds a number to a given amount of decimal places
-- Returns the rounded number [Int/Float]
-- Parameters
--    number        : number to round [Int/Float]
--    decimalPlaces : number of decimal places to round the number to [Int]
function round(number, decimalPlaces)
    local multiplier = 10 ^ decimalPlaces
    return math.floor(multiplier * number + 0.5) / multiplier
end
-- Shifts and wraps a lane number to still be within the map's lanes
-- Returns the wrapped lane number [Int]
-- Parameters
--    laneNum       : column/lane number [Int]
--    laneNumChange : amount to change the lane number [Int]
--    totalNumLanes : total number of lanes to wrap (starting from the left) [Int]
function shiftWrapLaneNum(laneNum, laneNumChange, totalNumLanes)
    local unwrappedNewLane = laneNum + laneNumChange
    return ((unwrappedNewLane - 1) % totalNumLanes) + 1
end
-- Restricts a number to be within a closed interval
-- Returns the result of the restriction [Int/Float]
-- Parameters
--    number     : number to keep within the interval [Int/Float]
--    lowerBound : lower bound of the interval [Int/Float]
--    upperBound : upper bound of the interval [Int/Float]
function clampToInterval(number, lowerBound, upperBound)
    if number < lowerBound then return lowerBound end
    if number > upperBound then return upperBound end
    return number
end
-- Restricts a number to be within a closed interval that wraps around
-- Returns the result of the restriction [Int/Float]
-- Parameters
--    number     : number to keep within the interval [Int/Float]
--    lowerBound : lower bound of the interval [Int/Float]
--    upperBound : upper bound of the interval [Int/Float]
function wrapToInterval(number, lowerBound, upperBound)
    if number < lowerBound then return upperBound end
    if number > upperBound then return lowerBound end
    return number
end
-- Sorting function for objects 'a' and 'b' that returns whether a.StartTime < b.StartTime [Boolean]
-- Parameters
--    a : first SV
--    b : second SV
function sortAscendingStartTime(a, b) return a.StartTime < b.StartTime end

--------------------------------------------------------------------------------- General utilities

-- Constructs a new reverse-order list from an existing list
-- Returns the reversed list [Table]
-- Parameters
--    list : list to be reversed [Table]
function getReverseList(list)
    local reverseList = {}
    for i = 1, #list do
        table.insert(reverseList, list[#list + 1 - i])
    end
    return reverseList
end
-- Returns an ascending list of whole numbers starting from 1 [Table]
-- Parameters
--    finalNumber : final number of the list [Int]
function enumeratedList(finalNumber)
    local numbersList = {}
    for i = 1, finalNumber do
        numbersList[i] = i
    end
    return numbersList
end
-- Combs through a list and locates unique values
-- Returns a list of only unique values (no duplicates) [Table]
-- Parameters
--    list : list of values [Table]
function removeDuplicateValues(list)
    local hash = {}
    local newList = {}
    for _, value in ipairs(list) do
        if (not hash[value]) then
            newList[#newList + 1] = value
            hash[value] = true
        end
    end
    return newList
end

---------------------------------------------------------------------------------------------------
-- Choose Functions (Sorted Alphabetically) -------------------------------------------------------
---------------------------------------------------------------------------------------------------

-- Lets you choose the beat snap gap
-- Parameters
--    settingVars : list of variables used for the current menu [Table]
function chooseBeatSnapGap(settingVars)
    local _, newBeatSnapGap = imgui.inputFloat("Snap Gap", settingVars.beatSnapGap, 1, 1, "%.2f")
    settingVars.beatSnapGap = clampToInterval(newBeatSnapGap, 0, FUNNY_NUMBER)
    helpMarker("Beat snap gap between LNs when applying inverse.\n"..
               "If beat snap gap is 0, the minimum LN gap will be used instead.")
end
-- Lets you choose the behavior of something (speed up or slow down)
-- Parameters
--    settingVars : list of variables used for the current menu [Table]
function chooseBehavior(settingVars)
    settingVars.behaviorIndex = combo("Behavior", BEHAVIORS, settingVars.behaviorIndex)
end
-- Lets you choose the color theme of the plugin
-- Parameters
--    globalVars : list of variables used globally across all menus [Table]
function chooseColorTheme(globalVars)
    globalVars.colorThemeIndex = combo("Color Theme", COLOR_THEMES, globalVars.colorThemeIndex)
    local currentTheme = COLOR_THEMES[globalVars.colorThemeIndex]
    local isRGBColorTheme = currentTheme == "Tobi's RGB Glass" or
                            currentTheme == "Glass + RGB" or  
                            currentTheme == "Incognito + RGB" or
                            currentTheme == "RGB Gamer Mode" or
                            currentTheme == "edom remag BGR" or
                            currentTheme == "BGR + otingocnI"
    if not isRGBColorTheme then return end
    
    chooseRGBPeriod(globalVars)
end
-- Lets you choose number of notes to place
-- Parameters
--    settingVars : list of variables used for the current menu [Table]
function chooseNoteCount(settingVars) 
    _, noteCount = imgui.InputInt("Note Count", settingVars.noteCount, 1, 1)
    settingVars.noteCount = clampToInterval(noteCount, 1, 1000)
end

-- Lets you choose the intensity of something
-- Parameters
--    settingVars : list of variables used for the current menu [Table]
function chooseIntensity(settingVars)
    _, settingVars.intensity = imgui.InputFloat("Intensity", settingVars.intensity, 0, 0,
                                                 "%.3f")
    settingVars.intensity = clampToInterval(settingVars.intensity, 0, FUNNY_NUMBER)
end
-- Lets you choose the highest-level menu
-- Parameters
--    globalVars : list of variables used globally across all menus [Table]
function chooseMenu(globalVars)
    imgui.PushItemWidth(MAX_WIDGET_WIDTH)
    globalVars.menuIndex = combo("##menu", MENUS, globalVars.menuIndex)
    imgui.PopItemWidth()
    changeMenuOnHotkeyPress(globalVars)
end
-- Lets you choose an integer number of milliseconds
-- Parameters
--    settingVars : list of variables used for the current menu [Table]
function chooseMilliseconds(settingVars)
    _, settingVars.milliseconds = imgui.InputInt("Milliseconds", settingVars.milliseconds, 1, 1)
end
-- Lets you choose the minimum LN gap length in milliseconds
-- Parameters
--    settingVars : list of variables used for the current menu [Table]
function chooseMinLNGapTime(settingVars)
    local _, newLNGapTime = imgui.InputInt("Min LN Gap", settingVars.minLNGapTime, 1, 1)
    settingVars.minLNGapTime = clampToInterval(newLNGapTime, 0, FUNNY_NUMBER)
    helpMarker("Minimum allowed LN gap length in millseconds")
end
-- Lets you choose the minimum LN length in milliseconds
-- Parameters
--    settingVars : list of variables used for the current menu [Table]
function chooseMinLNLength(settingVars)
    local _, newLNLength = imgui.InputInt("Min LN Time", settingVars.minLNLength, 1, 1)
    settingVars.minLNLength = clampToInterval(newLNLength, 0, FUNNY_NUMBER)
    helpMarker("Minimum allowed LN length in millseconds")
end
-- Lets you choose the note info tooltip visibility
-- Parameters
--    globalVars : list of variables used globally across all menus [Table]
function chooseNoteInfoTooltipVisibility(globalVars)
    local label = "Hide note info tooltip"
    _, globalVars.hideNoteInfoTooltip = imgui.Checkbox(label, globalVars.hideNoteInfoTooltip)
    helpMarker("Selecting a single note shows its info in a tooltip")
end
-- Lets you choose the length in seconds of one RGB color cycle
-- Parameters
--    globalVars : list of variables used globally across all menus [Table]
function chooseRGBPeriod(globalVars)
    _, globalVars.rgbPeriod = imgui.InputFloat("RGB cycle length", globalVars.rgbPeriod, 0, 0,
                                               "%.0f seconds")
    globalVars.rgbPeriod = clampToInterval(globalVars.rgbPeriod, MIN_RGB_CYCLE_TIME,
                                           MAX_RGB_CYCLE_TIME)
end
-- Lets you choose how to scale note spacing
-- Parameters
--    settingVars : list of variables used for the current menu [Table]
function chooseScaleType(settingVars)
    settingVars.scaleTypeIndex = combo("Scale Type", SCALE_TYPES, settingVars.scaleTypeIndex)
end
-- Lets you choose a direction
-- Parameters
--    settingVars : list of variables used for the current menu [Table]
function chooseDirection(settingVars)
    imgui.AlignTextToFramePadding()
    imgui.Text("Direction:")
    imgui.SameLine(0, RADIO_BUTTON_SPACING)
    if imgui.RadioButton("Left", not settingVars.directionRight) then
        settingVars.directionRight = false
    end
    imgui.SameLine(0, RADIO_BUTTON_SPACING)
    if imgui.RadioButton("Right", settingVars.directionRight) then
        settingVars.directionRight = true
    end
end
-- Lets you choose the style theme of the plugin
-- Parameters
--    globalVars : list of variables used globally across all menus [Table]
function chooseStyleTheme(globalVars)
    globalVars.styleThemeIndex = combo("Style Theme", STYLE_THEMES, globalVars.styleThemeIndex)
end
-- Lets you choose the sub-menu
-- Parameters
--    menuVars     : list of variables used for the current menu [Table]
--    subMenusList : list of sub-menus to chose from [Table]
function chooseSubMenu(menuVars, subMenusList)
    imgui.PushItemWidth(MAX_WIDGET_WIDTH)
    menuVars.subMenuIndex = combo("##subMenu", subMenusList, menuVars.subMenuIndex)
    imgui.PopItemWidth()
    changeSubMenuOnHotkeyPress(menuVars, subMenusList)
    addSeparator()
end
-- Lets you choose the target LN spot to change
-- Parameters
--    settingVars : list of variables used for the current menu [Table]
function chooseTargetLNSpot(settingVars)
    imgui.AlignTextToFramePadding()
    imgui.Text("Target:")
    imgui.SameLine(0, RADIO_BUTTON_SPACING)
    if imgui.RadioButton("LN Start", settingVars.targetLNStart) then
        settingVars.targetLNStart = true
    end
    imgui.SameLine(0, RADIO_BUTTON_SPACING)
    if imgui.RadioButton("LN End", not settingVars.targetLNStart) then
        settingVars.targetLNStart = false
    end
end

---------------------------------------------------------------------------------------------------
-- Plugin Appearance (Styles and Colors) ----------------------------------------------------------
---------------------------------------------------------------------------------------------------

-- Configures the plugin GUI styles
-- Parameters
--    globalVars : list of variables used globally across all menus [Table]
function setPluginAppearanceStyles(globalVars)
    local styleTheme = STYLE_THEMES[globalVars.styleThemeIndex]
    
    local boxedStyle = styleTheme == "Boxed" or
                       styleTheme == "Boxed + Border"
    local cornerRoundnessValue = 5 -- up to 12, 14 for WindowRounding and 16 for ChildRounding
    if boxedStyle then cornerRoundnessValue = 0 end
    
    local borderedStyle = styleTheme == "Rounded + Border" or
                          styleTheme == "Boxed + Border"
    local borderSize = 0
    if borderedStyle then borderSize = 1 end
    
    imgui.PushStyleVar( imgui_style_var.FrameBorderSize,    borderSize           )
    imgui.PushStyleVar( imgui_style_var.WindowPadding,      { PADDING_WIDTH, 8 } )
    imgui.PushStyleVar( imgui_style_var.FramePadding,       { PADDING_WIDTH, 5 } )
    imgui.PushStyleVar( imgui_style_var.ItemSpacing,        { DEFAULT_WIDGET_HEIGHT / 2 - 1, 4 } )
    imgui.PushStyleVar( imgui_style_var.ItemInnerSpacing,   { SAMELINE_SPACING, 6 } )
    imgui.PushStyleVar( imgui_style_var.WindowRounding,     cornerRoundnessValue )
    imgui.PushStyleVar( imgui_style_var.ChildRounding,      cornerRoundnessValue )
    imgui.PushStyleVar( imgui_style_var.FrameRounding,      cornerRoundnessValue )
    imgui.PushStyleVar( imgui_style_var.GrabRounding,       cornerRoundnessValue )
    imgui.PushStyleVar( imgui_style_var.ScrollbarRounding,  cornerRoundnessValue )
    imgui.PushStyleVar( imgui_style_var.TabRounding,        cornerRoundnessValue )
    
    -- Doesn't work even though TabBorderSize is changeable in the style editor demo
    -- imgui.PushStyleVar( imgui_style_var.TabBorderSize,      borderSize           ) 
    
    -- https://github.com/ocornut/imgui/issues/7297
    -- Apparently TabBorderSize doesn't have a imgui_style_var, so it can only be changed with
    -- imgui.GetStyle() which hasn't worked from my testing in Quaver plugins
end
-- Configures the plugin GUI colors
-- Parameters
--    globalVars : list of variables used globally across all menus [Table]
function setPluginAppearanceColors(globalVars)
    local colorTheme = COLOR_THEMES[globalVars.colorThemeIndex]
    local rgbPeriod = globalVars.rgbPeriod
    if colorTheme == "Classic"          then setClassicColors() end
    if colorTheme == "Strawberry"       then setStrawberryColors() end
    if colorTheme == "Amethyst"         then setAmethystColors() end
    if colorTheme == "Tree"             then setTreeColors() end
    if colorTheme == "Barbie"           then setBarbieColors() end
    if colorTheme == "Incognito"        then setIncognitoColors() end
    if colorTheme == "Incognito + RGB"  then setIncognitoRGBColors(rgbPeriod) end
    if colorTheme == "Tobi's Glass"     then setTobiGlassColors() end
    if colorTheme == "Tobi's RGB Glass" then setTobiRGBGlassColors(rgbPeriod) end
    if colorTheme == "Glass"            then setGlassColors() end
    if colorTheme == "Glass + RGB"      then setGlassRGBColors(rgbPeriod) end
    if colorTheme == "RGB Gamer Mode"   then setRGBGamerColors(rgbPeriod) end
    if colorTheme == "edom remag BGR"   then setInvertedRGBGamerColors(rgbPeriod) end
    if colorTheme == "BGR + otingocnI"  then setInvertedIncognitoRGBColors(rgbPeriod) end
    if colorTheme == "otingocnI"        then setInvertedIncognitoColors() end
end
-- Sets plugin colors to the "Classic" theme
function setClassicColors()
    imgui.PushStyleColor( imgui_col.WindowBg,               { 0.00, 0.00, 0.00, 1.00 } )
    imgui.PushStyleColor( imgui_col.PopupBg,                { 0.08, 0.08, 0.08, 0.94 } )
    imgui.PushStyleColor( imgui_col.Border,                 { 0.81, 0.88, 1.00, 0.30 } )
    imgui.PushStyleColor( imgui_col.FrameBg,                { 0.14, 0.24, 0.28, 1.00 } )
    imgui.PushStyleColor( imgui_col.FrameBgHovered,         { 0.24, 0.34, 0.38, 1.00 } )
    imgui.PushStyleColor( imgui_col.FrameBgActive,          { 0.29, 0.39, 0.43, 1.00 } )
    imgui.PushStyleColor( imgui_col.TitleBg,                { 0.41, 0.48, 0.65, 1.00 } )
    imgui.PushStyleColor( imgui_col.TitleBgActive,          { 0.51, 0.58, 0.75, 1.00 } )
    imgui.PushStyleColor( imgui_col.TitleBgCollapsed,       { 0.51, 0.58, 0.75, 0.50 } )
    imgui.PushStyleColor( imgui_col.CheckMark,              { 0.81, 0.88, 1.00, 1.00 } )
    imgui.PushStyleColor( imgui_col.SliderGrab,             { 0.56, 0.63, 0.75, 1.00 } )
    imgui.PushStyleColor( imgui_col.SliderGrabActive,       { 0.61, 0.68, 0.80, 1.00 } )
    imgui.PushStyleColor( imgui_col.Button,                 { 0.31, 0.38, 0.50, 1.00 } )
    imgui.PushStyleColor( imgui_col.ButtonHovered,          { 0.41, 0.48, 0.60, 1.00 } )
    imgui.PushStyleColor( imgui_col.ButtonActive,           { 0.51, 0.58, 0.70, 1.00 } )
    imgui.PushStyleColor( imgui_col.Tab,                    { 0.31, 0.38, 0.50, 1.00 } )
    imgui.PushStyleColor( imgui_col.TabHovered,             { 0.51, 0.58, 0.75, 1.00 } )
    imgui.PushStyleColor( imgui_col.TabActive,              { 0.51, 0.58, 0.75, 1.00 } )
    imgui.PushStyleColor( imgui_col.Header,                 { 0.81, 0.88, 1.00, 0.40 } )
    imgui.PushStyleColor( imgui_col.HeaderHovered,          { 0.81, 0.88, 1.00, 0.50 } )
    imgui.PushStyleColor( imgui_col.HeaderActive,           { 0.81, 0.88, 1.00, 0.54 } )
    imgui.PushStyleColor( imgui_col.Separator,              { 0.81, 0.88, 1.00, 0.30 } )
    imgui.PushStyleColor( imgui_col.Text,                   { 1.00, 1.00, 1.00, 1.00 } )
    imgui.PushStyleColor( imgui_col.TextSelectedBg,         { 0.81, 0.88, 1.00, 0.40 } )
    imgui.PushStyleColor( imgui_col.ScrollbarGrab,          { 0.31, 0.38, 0.50, 1.00 } )
    imgui.PushStyleColor( imgui_col.ScrollbarGrabHovered,   { 0.41, 0.48, 0.60, 1.00 } )
    imgui.PushStyleColor( imgui_col.ScrollbarGrabActive,    { 0.51, 0.58, 0.70, 1.00 } )
    imgui.PushStyleColor( imgui_col.PlotLines,              { 0.61, 0.61, 0.61, 1.00 } )
    imgui.PushStyleColor( imgui_col.PlotLinesHovered,       { 1.00, 0.43, 0.35, 1.00 } )
    imgui.PushStyleColor( imgui_col.PlotHistogram,          { 0.90, 0.70, 0.00, 1.00 } )
    imgui.PushStyleColor( imgui_col.PlotHistogramHovered,   { 1.00, 0.60, 0.00, 1.00 } )
end
-- Sets plugin colors to the "Strawberry" theme 
function setStrawberryColors()
    imgui.PushStyleColor( imgui_col.WindowBg,               { 0.00, 0.00, 0.00, 1.00 } )
    imgui.PushStyleColor( imgui_col.PopupBg,                { 0.08, 0.08, 0.08, 0.94 } )
    imgui.PushStyleColor( imgui_col.Border,                 { 1.00, 0.81, 0.88, 0.30 } )
    imgui.PushStyleColor( imgui_col.FrameBg,                { 0.28, 0.14, 0.24, 1.00 } )
    imgui.PushStyleColor( imgui_col.FrameBgHovered,         { 0.38, 0.24, 0.34, 1.00 } )
    imgui.PushStyleColor( imgui_col.FrameBgActive,          { 0.43, 0.29, 0.39, 1.00 } )
    imgui.PushStyleColor( imgui_col.TitleBg,                { 0.65, 0.41, 0.48, 1.00 } )
    imgui.PushStyleColor( imgui_col.TitleBgActive,          { 0.75, 0.51, 0.58, 1.00 } )
    imgui.PushStyleColor( imgui_col.TitleBgCollapsed,       { 0.75, 0.51, 0.58, 0.50 } )
    imgui.PushStyleColor( imgui_col.CheckMark,              { 1.00, 0.81, 0.88, 1.00 } )
    imgui.PushStyleColor( imgui_col.SliderGrab,             { 0.75, 0.56, 0.63, 1.00 } )
    imgui.PushStyleColor( imgui_col.SliderGrabActive,       { 0.80, 0.61, 0.68, 1.00 } )
    imgui.PushStyleColor( imgui_col.Button,                 { 0.50, 0.31, 0.38, 1.00 } )
    imgui.PushStyleColor( imgui_col.ButtonHovered,          { 0.60, 0.41, 0.48, 1.00 } )
    imgui.PushStyleColor( imgui_col.ButtonActive,           { 0.70, 0.51, 0.58, 1.00 } )
    imgui.PushStyleColor( imgui_col.Tab,                    { 0.50, 0.31, 0.38, 1.00 } )
    imgui.PushStyleColor( imgui_col.TabHovered,             { 0.75, 0.51, 0.58, 1.00 } )
    imgui.PushStyleColor( imgui_col.TabActive,              { 0.75, 0.51, 0.58, 1.00 } )
    imgui.PushStyleColor( imgui_col.Header,                 { 1.00, 0.81, 0.88, 0.40 } )
    imgui.PushStyleColor( imgui_col.HeaderHovered,          { 1.00, 0.81, 0.88, 0.50 } )
    imgui.PushStyleColor( imgui_col.HeaderActive,           { 1.00, 0.81, 0.88, 0.54 } )
    imgui.PushStyleColor( imgui_col.Separator,              { 1.00, 0.81, 0.88, 0.30 } )
    imgui.PushStyleColor( imgui_col.Text,                   { 1.00, 1.00, 1.00, 1.00 } )
    imgui.PushStyleColor( imgui_col.TextSelectedBg,         { 1.00, 0.81, 0.88, 0.40 } )
    imgui.PushStyleColor( imgui_col.ScrollbarGrab,          { 0.50, 0.31, 0.38, 1.00 } )
    imgui.PushStyleColor( imgui_col.ScrollbarGrabHovered,   { 0.60, 0.41, 0.48, 1.00 } )
    imgui.PushStyleColor( imgui_col.ScrollbarGrabActive,    { 0.70, 0.51, 0.58, 1.00 } )
    imgui.PushStyleColor( imgui_col.PlotLines,              { 0.61, 0.61, 0.61, 1.00 } )
    imgui.PushStyleColor( imgui_col.PlotLinesHovered,       { 1.00, 0.43, 0.35, 1.00 } )
    imgui.PushStyleColor( imgui_col.PlotHistogram,          { 0.90, 0.70, 0.00, 1.00 } )
    imgui.PushStyleColor( imgui_col.PlotHistogramHovered,   { 1.00, 0.60, 0.00, 1.00 } )
end
-- Sets plugin colors to the "Amethyst" theme 
function setAmethystColors()
    imgui.PushStyleColor( imgui_col.WindowBg,               { 0.16, 0.00, 0.20, 1.00 } )
    imgui.PushStyleColor( imgui_col.PopupBg,                { 0.08, 0.08, 0.08, 0.94 } )
    imgui.PushStyleColor( imgui_col.Border,                 { 0.90, 0.00, 0.81, 0.30 } )
    imgui.PushStyleColor( imgui_col.FrameBg,                { 0.40, 0.20, 0.40, 1.00 } )
    imgui.PushStyleColor( imgui_col.FrameBgHovered,         { 0.50, 0.30, 0.50, 1.00 } )
    imgui.PushStyleColor( imgui_col.FrameBgActive,          { 0.55, 0.35, 0.55, 1.00 } )
    imgui.PushStyleColor( imgui_col.TitleBg,                { 0.31, 0.11, 0.35, 1.00 } )
    imgui.PushStyleColor( imgui_col.TitleBgActive,          { 0.41, 0.21, 0.45, 1.00 } )
    imgui.PushStyleColor( imgui_col.TitleBgCollapsed,       { 0.41, 0.21, 0.45, 0.50 } )
    imgui.PushStyleColor( imgui_col.CheckMark,              { 1.00, 0.80, 1.00, 1.00 } )
    imgui.PushStyleColor( imgui_col.SliderGrab,             { 0.95, 0.75, 0.95, 1.00 } )
    imgui.PushStyleColor( imgui_col.SliderGrabActive,       { 1.00, 0.80, 1.00, 1.00 } )
    imgui.PushStyleColor( imgui_col.Button,                 { 0.60, 0.40, 0.60, 1.00 } )
    imgui.PushStyleColor( imgui_col.ButtonHovered,          { 0.70, 0.50, 0.70, 1.00 } )
    imgui.PushStyleColor( imgui_col.ButtonActive,           { 0.80, 0.60, 0.80, 1.00 } )
    imgui.PushStyleColor( imgui_col.Tab,                    { 0.50, 0.30, 0.50, 1.00 } )
    imgui.PushStyleColor( imgui_col.TabHovered,             { 0.70, 0.50, 0.70, 1.00 } )
    imgui.PushStyleColor( imgui_col.TabActive,              { 0.70, 0.50, 0.70, 1.00 } )
    imgui.PushStyleColor( imgui_col.Header,                 { 1.00, 0.80, 1.00, 0.40 } )
    imgui.PushStyleColor( imgui_col.HeaderHovered,          { 1.00, 0.80, 1.00, 0.50 } )
    imgui.PushStyleColor( imgui_col.HeaderActive,           { 1.00, 0.80, 1.00, 0.54 } )
    imgui.PushStyleColor( imgui_col.Separator,              { 1.00, 0.80, 1.00, 0.30 } )
    imgui.PushStyleColor( imgui_col.Text,                   { 1.00, 1.00, 1.00, 1.00 } )
    imgui.PushStyleColor( imgui_col.TextSelectedBg,         { 1.00, 0.80, 1.00, 0.40 } )
    imgui.PushStyleColor( imgui_col.ScrollbarGrab,          { 0.60, 0.40, 0.60, 1.00 } )
    imgui.PushStyleColor( imgui_col.ScrollbarGrabHovered,   { 0.70, 0.50, 0.70, 1.00 } )
    imgui.PushStyleColor( imgui_col.ScrollbarGrabActive,    { 0.80, 0.60, 0.80, 1.00 } )
    imgui.PushStyleColor( imgui_col.PlotLines,              { 1.00, 0.80, 1.00, 1.00 } )
    imgui.PushStyleColor( imgui_col.PlotLinesHovered,       { 1.00, 0.70, 0.30, 1.00 } )
    imgui.PushStyleColor( imgui_col.PlotHistogram,          { 1.00, 0.80, 1.00, 1.00 } )
    imgui.PushStyleColor( imgui_col.PlotHistogramHovered,   { 1.00, 0.70, 0.30, 1.00 } )
end
-- Sets plugin colors to the "Tree" theme 
function setTreeColors()
    imgui.PushStyleColor( imgui_col.WindowBg,               { 0.20, 0.16, 0.00, 1.00 } )
    imgui.PushStyleColor( imgui_col.PopupBg,                { 0.08, 0.08, 0.08, 0.94 } )
    imgui.PushStyleColor( imgui_col.Border,                 { 0.81, 0.90, 0.00, 0.30 } )
    imgui.PushStyleColor( imgui_col.FrameBg,                { 0.40, 0.40, 0.20, 1.00 } )
    imgui.PushStyleColor( imgui_col.FrameBgHovered,         { 0.50, 0.50, 0.30, 1.00 } )
    imgui.PushStyleColor( imgui_col.FrameBgActive,          { 0.55, 0.55, 0.35, 1.00 } )
    imgui.PushStyleColor( imgui_col.TitleBg,                { 0.35, 0.31, 0.11, 1.00 } )
    imgui.PushStyleColor( imgui_col.TitleBgActive,          { 0.45, 0.41, 0.21, 1.00 } )
    imgui.PushStyleColor( imgui_col.TitleBgCollapsed,       { 0.45, 0.41, 0.21, 0.50 } )
    imgui.PushStyleColor( imgui_col.CheckMark,              { 1.00, 1.00, 0.80, 1.00 } )
    imgui.PushStyleColor( imgui_col.SliderGrab,             { 0.95, 0.95, 0.75, 1.00 } )
    imgui.PushStyleColor( imgui_col.SliderGrabActive,       { 1.00, 1.00, 0.80, 1.00 } )
    imgui.PushStyleColor( imgui_col.Button,                 { 0.60, 0.60, 0.40, 1.00 } )
    imgui.PushStyleColor( imgui_col.ButtonHovered,          { 0.70, 0.70, 0.50, 1.00 } )
    imgui.PushStyleColor( imgui_col.ButtonActive,           { 0.80, 0.80, 0.60, 1.00 } )
    imgui.PushStyleColor( imgui_col.Tab,                    { 0.50, 0.50, 0.30, 1.00 } )
    imgui.PushStyleColor( imgui_col.TabHovered,             { 0.70, 0.70, 0.50, 1.00 } )
    imgui.PushStyleColor( imgui_col.TabActive,              { 0.70, 0.70, 0.50, 1.00 } )
    imgui.PushStyleColor( imgui_col.Header,                 { 1.00, 1.00, 0.80, 0.40 } )
    imgui.PushStyleColor( imgui_col.HeaderHovered,          { 1.00, 1.00, 0.80, 0.50 } )
    imgui.PushStyleColor( imgui_col.HeaderActive,           { 1.00, 1.00, 0.80, 0.54 } )
    imgui.PushStyleColor( imgui_col.Separator,              { 1.00, 1.00, 0.80, 0.30 } )
    imgui.PushStyleColor( imgui_col.Text,                   { 1.00, 1.00, 1.00, 1.00 } )
    imgui.PushStyleColor( imgui_col.TextSelectedBg,         { 1.00, 1.00, 0.80, 0.40 } )
    imgui.PushStyleColor( imgui_col.ScrollbarGrab,          { 0.60, 0.60, 0.40, 1.00 } )
    imgui.PushStyleColor( imgui_col.ScrollbarGrabHovered,   { 0.70, 0.70, 0.50, 1.00 } )
    imgui.PushStyleColor( imgui_col.ScrollbarGrabActive,    { 0.80, 0.80, 0.60, 1.00 } )
    imgui.PushStyleColor( imgui_col.PlotLines,              { 1.00, 1.00, 0.80, 1.00 } )
    imgui.PushStyleColor( imgui_col.PlotLinesHovered,       { 0.30, 1.00, 0.70, 1.00 } )
    imgui.PushStyleColor( imgui_col.PlotHistogram,          { 1.00, 1.00, 0.80, 1.00 } )
    imgui.PushStyleColor( imgui_col.PlotHistogramHovered,   { 0.30, 1.00, 0.70, 1.00 } )
end
-- Sets plugin colors to the "Barbie" theme 
function setBarbieColors()
    local pink = {0.79, 0.31, 0.55, 1.00}
    local white = {0.95, 0.85, 0.87, 1.00}
    local blue = {0.37, 0.64, 0.84, 1.00}
    local pinkTint = {1.00, 0.86, 0.86, 0.40}
    
    imgui.PushStyleColor( imgui_col.WindowBg,               pink     )
    imgui.PushStyleColor( imgui_col.PopupBg,                { 0.08, 0.08, 0.08, 0.94 } )
    imgui.PushStyleColor( imgui_col.Border,                 pinkTint )
    imgui.PushStyleColor( imgui_col.FrameBg,                blue     )
    imgui.PushStyleColor( imgui_col.FrameBgHovered,         pinkTint )
    imgui.PushStyleColor( imgui_col.FrameBgActive,          pinkTint )
    imgui.PushStyleColor( imgui_col.TitleBg,                blue     )
    imgui.PushStyleColor( imgui_col.TitleBgActive,          blue     )
    imgui.PushStyleColor( imgui_col.TitleBgCollapsed,       pink     )
    imgui.PushStyleColor( imgui_col.CheckMark,              blue     )
    imgui.PushStyleColor( imgui_col.SliderGrab,             blue     )
    imgui.PushStyleColor( imgui_col.SliderGrabActive,       pinkTint )
    imgui.PushStyleColor( imgui_col.Button,                 blue     )
    imgui.PushStyleColor( imgui_col.ButtonHovered,          pinkTint )
    imgui.PushStyleColor( imgui_col.ButtonActive,           pinkTint )
    imgui.PushStyleColor( imgui_col.Tab,                    blue     )
    imgui.PushStyleColor( imgui_col.TabHovered,             pinkTint )
    imgui.PushStyleColor( imgui_col.TabActive,              pinkTint )
    imgui.PushStyleColor( imgui_col.Header,                 blue     )
    imgui.PushStyleColor( imgui_col.HeaderHovered,          pinkTint )
    imgui.PushStyleColor( imgui_col.HeaderActive,           pinkTint )
    imgui.PushStyleColor( imgui_col.Separator,              pinkTint )
    imgui.PushStyleColor( imgui_col.Text,                   white    )
    imgui.PushStyleColor( imgui_col.TextSelectedBg,         pinkTint )
    imgui.PushStyleColor( imgui_col.ScrollbarGrab,          pinkTint )
    imgui.PushStyleColor( imgui_col.ScrollbarGrabHovered,   white    )
    imgui.PushStyleColor( imgui_col.ScrollbarGrabActive,    white    )
    imgui.PushStyleColor( imgui_col.PlotLines,              pink     )
    imgui.PushStyleColor( imgui_col.PlotLinesHovered,       pinkTint )
    imgui.PushStyleColor( imgui_col.PlotHistogram,          pink     )
    imgui.PushStyleColor( imgui_col.PlotHistogramHovered,   pinkTint )
end
-- Sets plugin colors to the "Incognito" theme 
function setIncognitoColors()
    local black = {0.00, 0.00, 0.00, 1.00}
    local white = {1.00, 1.00, 1.00, 1.00}
    local grey = {0.20, 0.20, 0.20, 1.00}
    local whiteTint = {1.00, 1.00, 1.00, 0.40}
    local red = {1.00, 0.00, 0.00, 1.00}
    
    imgui.PushStyleColor( imgui_col.WindowBg,               black     )
    imgui.PushStyleColor( imgui_col.PopupBg,                { 0.08, 0.08, 0.08, 0.94 } )
    imgui.PushStyleColor( imgui_col.Border,                 whiteTint )
    imgui.PushStyleColor( imgui_col.FrameBg,                grey      )
    imgui.PushStyleColor( imgui_col.FrameBgHovered,         whiteTint )
    imgui.PushStyleColor( imgui_col.FrameBgActive,          whiteTint )
    imgui.PushStyleColor( imgui_col.TitleBg,                grey      )
    imgui.PushStyleColor( imgui_col.TitleBgActive,          grey      )
    imgui.PushStyleColor( imgui_col.TitleBgCollapsed,       black     )
    imgui.PushStyleColor( imgui_col.CheckMark,              white     )
    imgui.PushStyleColor( imgui_col.SliderGrab,             grey      )
    imgui.PushStyleColor( imgui_col.SliderGrabActive,       whiteTint )
    imgui.PushStyleColor( imgui_col.Button,                 grey      )
    imgui.PushStyleColor( imgui_col.ButtonHovered,          whiteTint )
    imgui.PushStyleColor( imgui_col.ButtonActive,           whiteTint )
    imgui.PushStyleColor( imgui_col.Tab,                    grey      )
    imgui.PushStyleColor( imgui_col.TabHovered,             whiteTint )
    imgui.PushStyleColor( imgui_col.TabActive,              whiteTint )
    imgui.PushStyleColor( imgui_col.Header,                 grey      )
    imgui.PushStyleColor( imgui_col.HeaderHovered,          whiteTint )
    imgui.PushStyleColor( imgui_col.HeaderActive,           whiteTint )
    imgui.PushStyleColor( imgui_col.Separator,              whiteTint )
    imgui.PushStyleColor( imgui_col.Text,                   white     )
    imgui.PushStyleColor( imgui_col.TextSelectedBg,         whiteTint )
    imgui.PushStyleColor( imgui_col.ScrollbarGrab,          whiteTint )
    imgui.PushStyleColor( imgui_col.ScrollbarGrabHovered,   white     )
    imgui.PushStyleColor( imgui_col.ScrollbarGrabActive,    white     )
    imgui.PushStyleColor( imgui_col.PlotLines,              white     )
    imgui.PushStyleColor( imgui_col.PlotLinesHovered,       red       )
    imgui.PushStyleColor( imgui_col.PlotHistogram,          white     )
    imgui.PushStyleColor( imgui_col.PlotHistogramHovered,   red       )
end
-- Sets plugin colors to the "Incognito + RGB" theme 
-- Parameters
--    rgbPeriod : length in seconds of one RGB color cycle [Int/Float]
function setIncognitoRGBColors(rgbPeriod)
    local currentRGB = getCurrentRGBColors(rgbPeriod)
    local rgbColor = {currentRGB.red, currentRGB.green, currentRGB.blue, 0.8}
    local black = {0.00, 0.00, 0.00, 1.00}
    local white = {1.00, 1.00, 1.00, 1.00}
    local grey = {0.20, 0.20, 0.20, 1.00}
    local whiteTint = {1.00, 1.00, 1.00, 0.40}
    
    imgui.PushStyleColor( imgui_col.WindowBg,               black     )
    imgui.PushStyleColor( imgui_col.PopupBg,                { 0.08, 0.08, 0.08, 0.94 } )
    imgui.PushStyleColor( imgui_col.Border,                 rgbColor  )
    imgui.PushStyleColor( imgui_col.FrameBg,                grey      )
    imgui.PushStyleColor( imgui_col.FrameBgHovered,         whiteTint )
    imgui.PushStyleColor( imgui_col.FrameBgActive,          rgbColor  )
    imgui.PushStyleColor( imgui_col.TitleBg,                grey      )
    imgui.PushStyleColor( imgui_col.TitleBgActive,          grey      )
    imgui.PushStyleColor( imgui_col.TitleBgCollapsed,       black     )
    imgui.PushStyleColor( imgui_col.CheckMark,              white     )
    imgui.PushStyleColor( imgui_col.SliderGrab,             grey      )
    imgui.PushStyleColor( imgui_col.SliderGrabActive,       rgbColor  )
    imgui.PushStyleColor( imgui_col.Button,                 grey      )
    imgui.PushStyleColor( imgui_col.ButtonHovered,          whiteTint )
    imgui.PushStyleColor( imgui_col.ButtonActive,           rgbColor  )
    imgui.PushStyleColor( imgui_col.Tab,                    grey      )
    imgui.PushStyleColor( imgui_col.TabHovered,             whiteTint )
    imgui.PushStyleColor( imgui_col.TabActive,              rgbColor  )
    imgui.PushStyleColor( imgui_col.Header,                 grey      )
    imgui.PushStyleColor( imgui_col.HeaderHovered,          whiteTint )
    imgui.PushStyleColor( imgui_col.HeaderActive,           rgbColor  )
    imgui.PushStyleColor( imgui_col.Separator,              rgbColor  )
    imgui.PushStyleColor( imgui_col.Text,                   white     )
    imgui.PushStyleColor( imgui_col.TextSelectedBg,         rgbColor  )
    imgui.PushStyleColor( imgui_col.ScrollbarGrab,          whiteTint )
    imgui.PushStyleColor( imgui_col.ScrollbarGrabHovered,   white     )
    imgui.PushStyleColor( imgui_col.ScrollbarGrabActive,    rgbColor  )
    imgui.PushStyleColor( imgui_col.PlotLines,              white     )
    imgui.PushStyleColor( imgui_col.PlotLinesHovered,       rgbColor  )
    imgui.PushStyleColor( imgui_col.PlotHistogram,          white     )
    imgui.PushStyleColor( imgui_col.PlotHistogramHovered,   rgbColor  )
end
-- Sets plugin colors to the "Tobi's Glass" theme
function setTobiGlassColors()
    local transparentBlack = {0.00, 0.00, 0.00, 0.70}
    local transparentWhite = {0.30, 0.30, 0.30, 0.50}
    local whiteTint = {1.00, 1.00, 1.00, 0.30}
    local buttonColor = {0.14, 0.24, 0.28, 0.80}
    local frameColor = {0.24, 0.34, 0.38, 1.00}
    local white = {1.00, 1.00, 1.00, 1.00}  

    imgui.PushStyleColor( imgui_col.WindowBg,               transparentBlack )
    imgui.PushStyleColor( imgui_col.PopupBg,                { 0.08, 0.08, 0.08, 0.94 } )
    imgui.PushStyleColor( imgui_col.Border,                 frameColor       )
    imgui.PushStyleColor( imgui_col.FrameBg,                buttonColor      )
    imgui.PushStyleColor( imgui_col.FrameBgHovered,         whiteTint        )
    imgui.PushStyleColor( imgui_col.FrameBgActive,          whiteTint        )
    imgui.PushStyleColor( imgui_col.TitleBg,                transparentBlack )
    imgui.PushStyleColor( imgui_col.TitleBgActive,          transparentBlack )
    imgui.PushStyleColor( imgui_col.TitleBgCollapsed,       transparentBlack )
    imgui.PushStyleColor( imgui_col.CheckMark,              white            )
    imgui.PushStyleColor( imgui_col.SliderGrab,             whiteTint        )
    imgui.PushStyleColor( imgui_col.SliderGrabActive,       transparentWhite )
    imgui.PushStyleColor( imgui_col.Button,                 buttonColor      )
    imgui.PushStyleColor( imgui_col.ButtonHovered,          whiteTint        )
    imgui.PushStyleColor( imgui_col.ButtonActive,           whiteTint        )
    imgui.PushStyleColor( imgui_col.Tab,                    transparentBlack )
    imgui.PushStyleColor( imgui_col.TabHovered,             whiteTint        )
    imgui.PushStyleColor( imgui_col.TabActive,              whiteTint        )
    imgui.PushStyleColor( imgui_col.Header,                 transparentBlack )
    imgui.PushStyleColor( imgui_col.HeaderHovered,          whiteTint        )
    imgui.PushStyleColor( imgui_col.HeaderActive,           whiteTint        )
    imgui.PushStyleColor( imgui_col.Separator,              whiteTint        )
    imgui.PushStyleColor( imgui_col.Text,                   white            )
    imgui.PushStyleColor( imgui_col.TextSelectedBg,         whiteTint        )
    imgui.PushStyleColor( imgui_col.ScrollbarGrab,          whiteTint        )
    imgui.PushStyleColor( imgui_col.ScrollbarGrabHovered,   transparentWhite )
    imgui.PushStyleColor( imgui_col.ScrollbarGrabActive,    transparentWhite )
    imgui.PushStyleColor( imgui_col.PlotLines,              whiteTint        )
    imgui.PushStyleColor( imgui_col.PlotLinesHovered,       transparentWhite )
    imgui.PushStyleColor( imgui_col.PlotHistogram,          whiteTint        )
    imgui.PushStyleColor( imgui_col.PlotHistogramHovered,   transparentWhite )
end
-- Sets plugin colors to the "Tobi's RGB Glass" theme 
-- Parameters
--    rgbPeriod : length in seconds of one RGB color cycle [Int/Float]
function setTobiRGBGlassColors(rgbPeriod)
    local currentRGB = getCurrentRGBColors(rgbPeriod)
    local activeColor = {currentRGB.red, currentRGB.green, currentRGB.blue, 0.8}
    local colorTint = {currentRGB.red, currentRGB.green, currentRGB.blue, 0.3}
    local transparent = {0.00, 0.00, 0.00, 0.85}
    local white = {1.00, 1.00, 1.00, 1.00}
    
    imgui.PushStyleColor( imgui_col.WindowBg,               transparent )
    imgui.PushStyleColor( imgui_col.PopupBg,                { 0.08, 0.08, 0.08, 0.94 } )
    imgui.PushStyleColor( imgui_col.Border,                 activeColor )
    imgui.PushStyleColor( imgui_col.FrameBg,                transparent )
    imgui.PushStyleColor( imgui_col.FrameBgHovered,         colorTint   )
    imgui.PushStyleColor( imgui_col.FrameBgActive,          colorTint   )
    imgui.PushStyleColor( imgui_col.TitleBg,                transparent )
    imgui.PushStyleColor( imgui_col.TitleBgActive,          transparent )
    imgui.PushStyleColor( imgui_col.TitleBgCollapsed,       transparent )
    imgui.PushStyleColor( imgui_col.CheckMark,              activeColor )
    imgui.PushStyleColor( imgui_col.SliderGrab,             colorTint   )
    imgui.PushStyleColor( imgui_col.SliderGrabActive,       activeColor )
    imgui.PushStyleColor( imgui_col.Button,                 transparent )
    imgui.PushStyleColor( imgui_col.ButtonHovered,          colorTint   )
    imgui.PushStyleColor( imgui_col.ButtonActive,           colorTint   )
    imgui.PushStyleColor( imgui_col.Tab,                    transparent )
    imgui.PushStyleColor( imgui_col.TabHovered,             colorTint   )
    imgui.PushStyleColor( imgui_col.TabActive,              colorTint   )
    imgui.PushStyleColor( imgui_col.Header,                 transparent )
    imgui.PushStyleColor( imgui_col.HeaderHovered,          colorTint   ) 
    imgui.PushStyleColor( imgui_col.HeaderActive,           colorTint   )
    imgui.PushStyleColor( imgui_col.Separator,              colorTint   )
    imgui.PushStyleColor( imgui_col.Text,                   white       )
    imgui.PushStyleColor( imgui_col.TextSelectedBg,         colorTint   )
    imgui.PushStyleColor( imgui_col.ScrollbarGrab,          colorTint   )
    imgui.PushStyleColor( imgui_col.ScrollbarGrabHovered,   activeColor )
    imgui.PushStyleColor( imgui_col.ScrollbarGrabActive,    activeColor )
    imgui.PushStyleColor( imgui_col.PlotLines,              activeColor )
    imgui.PushStyleColor( imgui_col.PlotLinesHovered,       colorTint   )
    imgui.PushStyleColor( imgui_col.PlotHistogram,          activeColor )
    imgui.PushStyleColor( imgui_col.PlotHistogramHovered,   colorTint   )
end
-- Sets plugin colors to the "Glass" theme 
function setGlassColors()
    local transparentBlack = {0.00, 0.00, 0.00, 0.25}
    local transparentWhite = {1.00, 1.00, 1.00, 0.70}
    local whiteTint = {1.00, 1.00, 1.00, 0.30}
    local white = {1.00, 1.00, 1.00, 1.00}
    
    imgui.PushStyleColor( imgui_col.WindowBg,               transparentBlack )
    imgui.PushStyleColor( imgui_col.PopupBg,                { 0.08, 0.08, 0.08, 0.94 } )
    imgui.PushStyleColor( imgui_col.Border,                 transparentWhite )
    imgui.PushStyleColor( imgui_col.FrameBg,                transparentBlack )
    imgui.PushStyleColor( imgui_col.FrameBgHovered,         whiteTint        )
    imgui.PushStyleColor( imgui_col.FrameBgActive,          whiteTint        )
    imgui.PushStyleColor( imgui_col.TitleBg,                transparentBlack )
    imgui.PushStyleColor( imgui_col.TitleBgActive,          transparentBlack )
    imgui.PushStyleColor( imgui_col.TitleBgCollapsed,       transparentBlack )
    imgui.PushStyleColor( imgui_col.CheckMark,              transparentWhite )
    imgui.PushStyleColor( imgui_col.SliderGrab,             whiteTint        )
    imgui.PushStyleColor( imgui_col.SliderGrabActive,       transparentWhite )
    imgui.PushStyleColor( imgui_col.Button,                 transparentBlack )
    imgui.PushStyleColor( imgui_col.ButtonHovered,          whiteTint        )
    imgui.PushStyleColor( imgui_col.ButtonActive,           whiteTint        )
    imgui.PushStyleColor( imgui_col.Tab,                    transparentBlack )
    imgui.PushStyleColor( imgui_col.TabHovered,             whiteTint        )
    imgui.PushStyleColor( imgui_col.TabActive,              whiteTint        )
    imgui.PushStyleColor( imgui_col.Header,                 transparentBlack )
    imgui.PushStyleColor( imgui_col.HeaderHovered,          whiteTint        )
    imgui.PushStyleColor( imgui_col.HeaderActive,           whiteTint        )
    imgui.PushStyleColor( imgui_col.Separator,              whiteTint        )
    imgui.PushStyleColor( imgui_col.Text,                   white            )
    imgui.PushStyleColor( imgui_col.TextSelectedBg,         whiteTint        )
    imgui.PushStyleColor( imgui_col.ScrollbarGrab,          whiteTint        )
    imgui.PushStyleColor( imgui_col.ScrollbarGrabHovered,   transparentWhite )
    imgui.PushStyleColor( imgui_col.ScrollbarGrabActive,    transparentWhite )
    imgui.PushStyleColor( imgui_col.PlotLines,              whiteTint        )
    imgui.PushStyleColor( imgui_col.PlotLinesHovered,       transparentWhite )
    imgui.PushStyleColor( imgui_col.PlotHistogram,          whiteTint        )
    imgui.PushStyleColor( imgui_col.PlotHistogramHovered,   transparentWhite )
end
-- Sets plugin colors to the "Glass + RGB" theme 
-- Parameters
--    rgbPeriod : length in seconds of one RGB color cycle [Int/Float]
function setGlassRGBColors(rgbPeriod)
    local currentRGB = getCurrentRGBColors(rgbPeriod)
    local activeColor = {currentRGB.red, currentRGB.green, currentRGB.blue, 0.8}
    local colorTint = {currentRGB.red, currentRGB.green, currentRGB.blue, 0.3}
    local transparent = {0.00, 0.00, 0.00, 0.25}
    local white = {1.00, 1.00, 1.00, 1.00}
    
    imgui.PushStyleColor( imgui_col.WindowBg,               transparent )
    imgui.PushStyleColor( imgui_col.PopupBg,                { 0.08, 0.08, 0.08, 0.94 } )
    imgui.PushStyleColor( imgui_col.Border,                 activeColor )
    imgui.PushStyleColor( imgui_col.FrameBg,                transparent )
    imgui.PushStyleColor( imgui_col.FrameBgHovered,         colorTint   )
    imgui.PushStyleColor( imgui_col.FrameBgActive,          colorTint   )
    imgui.PushStyleColor( imgui_col.TitleBg,                transparent )
    imgui.PushStyleColor( imgui_col.TitleBgActive,          transparent )
    imgui.PushStyleColor( imgui_col.TitleBgCollapsed,       transparent )
    imgui.PushStyleColor( imgui_col.CheckMark,              activeColor )
    imgui.PushStyleColor( imgui_col.SliderGrab,             colorTint   )
    imgui.PushStyleColor( imgui_col.SliderGrabActive,       activeColor )
    imgui.PushStyleColor( imgui_col.Button,                 transparent )
    imgui.PushStyleColor( imgui_col.ButtonHovered,          colorTint   )
    imgui.PushStyleColor( imgui_col.ButtonActive,           colorTint   )
    imgui.PushStyleColor( imgui_col.Tab,                    transparent )
    imgui.PushStyleColor( imgui_col.TabHovered,             colorTint   )
    imgui.PushStyleColor( imgui_col.TabActive,              colorTint   )
    imgui.PushStyleColor( imgui_col.Header,                 transparent )
    imgui.PushStyleColor( imgui_col.HeaderHovered,          colorTint   ) 
    imgui.PushStyleColor( imgui_col.HeaderActive,           colorTint   )
    imgui.PushStyleColor( imgui_col.Separator,              colorTint   )
    imgui.PushStyleColor( imgui_col.Text,                   white       )
    imgui.PushStyleColor( imgui_col.TextSelectedBg,         colorTint   )
    imgui.PushStyleColor( imgui_col.ScrollbarGrab,          colorTint   )
    imgui.PushStyleColor( imgui_col.ScrollbarGrabHovered,   activeColor )
    imgui.PushStyleColor( imgui_col.ScrollbarGrabActive,    activeColor )
    imgui.PushStyleColor( imgui_col.PlotLines,              activeColor )
    imgui.PushStyleColor( imgui_col.PlotLinesHovered,       colorTint   )
    imgui.PushStyleColor( imgui_col.PlotHistogram,          activeColor )
    imgui.PushStyleColor( imgui_col.PlotHistogramHovered,   colorTint   )
end
-- Sets plugin colors to the "RGB Gamer Mode" theme 
-- Parameters
--    rgbPeriod : length in seconds of one RGB color cycle [Int/Float]
function setRGBGamerColors(rgbPeriod)
    local currentRGB = getCurrentRGBColors(rgbPeriod)
    local activeColor = {currentRGB.red, currentRGB.green, currentRGB.blue, 0.8}
    local inactiveColor = {currentRGB.red, currentRGB.green, currentRGB.blue, 0.5}
    local white = {1.00, 1.00, 1.00, 1.00}
    local clearWhite = {1.00, 1.00, 1.00, 0.40}
    local black = {0.00, 0.00, 0.00, 1.00}
    
    imgui.PushStyleColor( imgui_col.WindowBg,               black         )
    imgui.PushStyleColor( imgui_col.PopupBg,                { 0.08, 0.08, 0.08, 0.94 } )
    imgui.PushStyleColor( imgui_col.Border,                 inactiveColor )
    imgui.PushStyleColor( imgui_col.FrameBg,                inactiveColor )
    imgui.PushStyleColor( imgui_col.FrameBgHovered,         activeColor   )
    imgui.PushStyleColor( imgui_col.FrameBgActive,          activeColor   )
    imgui.PushStyleColor( imgui_col.TitleBg,                inactiveColor )
    imgui.PushStyleColor( imgui_col.TitleBgActive,          activeColor   )
    imgui.PushStyleColor( imgui_col.TitleBgCollapsed,       inactiveColor )
    imgui.PushStyleColor( imgui_col.CheckMark,              white         )
    imgui.PushStyleColor( imgui_col.SliderGrab,             activeColor   )
    imgui.PushStyleColor( imgui_col.SliderGrabActive,       white         )
    imgui.PushStyleColor( imgui_col.Button,                 inactiveColor )
    imgui.PushStyleColor( imgui_col.ButtonHovered,          activeColor   )
    imgui.PushStyleColor( imgui_col.ButtonActive,           activeColor   )
    imgui.PushStyleColor( imgui_col.Tab,                    inactiveColor )
    imgui.PushStyleColor( imgui_col.TabHovered,             activeColor   )
    imgui.PushStyleColor( imgui_col.TabActive,              activeColor   )
    imgui.PushStyleColor( imgui_col.Header,                 inactiveColor )
    imgui.PushStyleColor( imgui_col.HeaderHovered,          inactiveColor )
    imgui.PushStyleColor( imgui_col.HeaderActive,           activeColor   )
    imgui.PushStyleColor( imgui_col.Separator,              inactiveColor )
    imgui.PushStyleColor( imgui_col.Text,                   white         )
    imgui.PushStyleColor( imgui_col.TextSelectedBg,         clearWhite    )
    imgui.PushStyleColor( imgui_col.ScrollbarGrab,          inactiveColor )
    imgui.PushStyleColor( imgui_col.ScrollbarGrabHovered,   activeColor   )
    imgui.PushStyleColor( imgui_col.ScrollbarGrabActive,    activeColor   )
    imgui.PushStyleColor( imgui_col.PlotLines,              { 0.61, 0.61, 0.61, 1.00 } )
    imgui.PushStyleColor( imgui_col.PlotLinesHovered,       { 1.00, 0.43, 0.35, 1.00 } )
    imgui.PushStyleColor( imgui_col.PlotHistogram,          { 0.90, 0.70, 0.00, 1.00 } )
    imgui.PushStyleColor( imgui_col.PlotHistogramHovered,   { 1.00, 0.60, 0.00, 1.00 } )
end
-- Sets plugin colors to the "edom remag BGR" theme 
-- Parameters
--    rgbPeriod : length in seconds of one RGB color cycle [Int/Float]
function setInvertedRGBGamerColors(rgbPeriod)
    local currentRGB = getCurrentRGBColors(rgbPeriod)
    local activeColor = {currentRGB.red, currentRGB.green, currentRGB.blue, 0.8}
    local inactiveColor = {currentRGB.red, currentRGB.green, currentRGB.blue, 0.5}
    local white = {1.00, 1.00, 1.00, 1.00}
    local clearBlack = {0.00, 0.00, 0.00, 0.40}
    local black = {0.00, 0.00, 0.00, 1.00}
    
    imgui.PushStyleColor( imgui_col.WindowBg,               white         )
    imgui.PushStyleColor( imgui_col.PopupBg,                { 0.92, 0.92, 0.92, 0.94 } )
    imgui.PushStyleColor( imgui_col.Border,                 inactiveColor )
    imgui.PushStyleColor( imgui_col.FrameBg,                inactiveColor )
    imgui.PushStyleColor( imgui_col.FrameBgHovered,         activeColor   )
    imgui.PushStyleColor( imgui_col.FrameBgActive,          activeColor   )
    imgui.PushStyleColor( imgui_col.TitleBg,                inactiveColor )
    imgui.PushStyleColor( imgui_col.TitleBgActive,          activeColor   )
    imgui.PushStyleColor( imgui_col.TitleBgCollapsed,       inactiveColor )
    imgui.PushStyleColor( imgui_col.CheckMark,              black         )
    imgui.PushStyleColor( imgui_col.SliderGrab,             activeColor   )
    imgui.PushStyleColor( imgui_col.SliderGrabActive,       black         )
    imgui.PushStyleColor( imgui_col.Button,                 inactiveColor )
    imgui.PushStyleColor( imgui_col.ButtonHovered,          activeColor   )
    imgui.PushStyleColor( imgui_col.ButtonActive,           activeColor   )
    imgui.PushStyleColor( imgui_col.Tab,                    inactiveColor )
    imgui.PushStyleColor( imgui_col.TabHovered,             activeColor   )
    imgui.PushStyleColor( imgui_col.TabActive,              activeColor   )
    imgui.PushStyleColor( imgui_col.Header,                 inactiveColor )
    imgui.PushStyleColor( imgui_col.HeaderHovered,          inactiveColor )
    imgui.PushStyleColor( imgui_col.HeaderActive,           activeColor   )
    imgui.PushStyleColor( imgui_col.Separator,              inactiveColor )
    imgui.PushStyleColor( imgui_col.Text,                   black         )
    imgui.PushStyleColor( imgui_col.TextSelectedBg,         clearBlack    )
    imgui.PushStyleColor( imgui_col.ScrollbarGrab,          inactiveColor )
    imgui.PushStyleColor( imgui_col.ScrollbarGrabHovered,   activeColor   )
    imgui.PushStyleColor( imgui_col.ScrollbarGrabActive,    activeColor   )
    imgui.PushStyleColor( imgui_col.PlotLines,              { 0.39, 0.39, 0.39, 1.00 } )
    imgui.PushStyleColor( imgui_col.PlotLinesHovered,       { 0.00, 0.57, 0.65, 1.00 } )
    imgui.PushStyleColor( imgui_col.PlotHistogram,          { 0.10, 0.30, 1.00, 1.00 } )
    imgui.PushStyleColor( imgui_col.PlotHistogramHovered,   { 0.00, 0.40, 1.00, 1.00 } )
end
-- Sets plugin colors to the "BGR + otingocnI" theme
-- Parameters
--    rgbPeriod : length in seconds of one RGB color cycle [Int/Float]
function setInvertedIncognitoRGBColors(rgbPeriod)
    local currentRGB = getCurrentRGBColors(rgbPeriod)
    local rgbColor = {currentRGB.red, currentRGB.green, currentRGB.blue, 0.8}
    local black = {0.00, 0.00, 0.00, 1.00}
    local white = {1.00, 1.00, 1.00, 1.00}
    local grey = {0.80, 0.80, 0.80, 1.00}
    local blackTint = {0.00, 0.00, 0.00, 0.40}
    
    imgui.PushStyleColor( imgui_col.WindowBg,               white     )
    imgui.PushStyleColor( imgui_col.PopupBg,                { 0.92, 0.92, 0.92, 0.94 } )
    imgui.PushStyleColor( imgui_col.Border,                 rgbColor  )
    imgui.PushStyleColor( imgui_col.FrameBg,                grey      )
    imgui.PushStyleColor( imgui_col.FrameBgHovered,         blackTint )
    imgui.PushStyleColor( imgui_col.FrameBgActive,          rgbColor  )
    imgui.PushStyleColor( imgui_col.TitleBg,                grey      )
    imgui.PushStyleColor( imgui_col.TitleBgActive,          grey      )
    imgui.PushStyleColor( imgui_col.TitleBgCollapsed,       white     )
    imgui.PushStyleColor( imgui_col.CheckMark,              black     )
    imgui.PushStyleColor( imgui_col.SliderGrab,             grey      )
    imgui.PushStyleColor( imgui_col.SliderGrabActive,       rgbColor  )
    imgui.PushStyleColor( imgui_col.Button,                 grey      )
    imgui.PushStyleColor( imgui_col.ButtonHovered,          blackTint )
    imgui.PushStyleColor( imgui_col.ButtonActive,           rgbColor  )
    imgui.PushStyleColor( imgui_col.Tab,                    grey      )
    imgui.PushStyleColor( imgui_col.TabHovered,             blackTint )
    imgui.PushStyleColor( imgui_col.TabActive,              rgbColor  )
    imgui.PushStyleColor( imgui_col.Header,                 grey      )
    imgui.PushStyleColor( imgui_col.HeaderHovered,          blackTint )
    imgui.PushStyleColor( imgui_col.HeaderActive,           rgbColor  )
    imgui.PushStyleColor( imgui_col.Separator,              rgbColor  )
    imgui.PushStyleColor( imgui_col.Text,                   black     )
    imgui.PushStyleColor( imgui_col.TextSelectedBg,         rgbColor  )
    imgui.PushStyleColor( imgui_col.ScrollbarGrab,          blackTint )
    imgui.PushStyleColor( imgui_col.ScrollbarGrabHovered,   black     )
    imgui.PushStyleColor( imgui_col.ScrollbarGrabActive,    rgbColor  )
    imgui.PushStyleColor( imgui_col.PlotLines,              black     )
    imgui.PushStyleColor( imgui_col.PlotLinesHovered,       rgbColor  )
    imgui.PushStyleColor( imgui_col.PlotHistogram,          black     )
    imgui.PushStyleColor( imgui_col.PlotHistogramHovered,   rgbColor  )
end
-- Sets plugin colors to the "otingocnI" theme
function setInvertedIncognitoColors()
    local black = {0.00, 0.00, 0.00, 1.00}
    local white = {1.00, 1.00, 1.00, 1.00}
    local grey = {0.80, 0.80, 0.80, 1.00}
    local blackTint = {0.00, 0.00, 0.00, 0.40}
    local notRed = {0.00, 1.00, 1.00, 1.00}
    
    imgui.PushStyleColor( imgui_col.WindowBg,               white     )
    imgui.PushStyleColor( imgui_col.PopupBg,                { 0.92, 0.92, 0.92, 0.94 } )
    imgui.PushStyleColor( imgui_col.Border,                 blackTint )
    imgui.PushStyleColor( imgui_col.FrameBg,                grey      )
    imgui.PushStyleColor( imgui_col.FrameBgHovered,         blackTint )
    imgui.PushStyleColor( imgui_col.FrameBgActive,          blackTint )
    imgui.PushStyleColor( imgui_col.TitleBg,                grey      )
    imgui.PushStyleColor( imgui_col.TitleBgActive,          grey      )
    imgui.PushStyleColor( imgui_col.TitleBgCollapsed,       white     )
    imgui.PushStyleColor( imgui_col.CheckMark,              black     )
    imgui.PushStyleColor( imgui_col.SliderGrab,             grey      )
    imgui.PushStyleColor( imgui_col.SliderGrabActive,       blackTint )
    imgui.PushStyleColor( imgui_col.Button,                 grey      )
    imgui.PushStyleColor( imgui_col.ButtonHovered,          blackTint )
    imgui.PushStyleColor( imgui_col.ButtonActive,           blackTint )
    imgui.PushStyleColor( imgui_col.Tab,                    grey      )
    imgui.PushStyleColor( imgui_col.TabHovered,             blackTint )
    imgui.PushStyleColor( imgui_col.TabActive,              blackTint )
    imgui.PushStyleColor( imgui_col.Header,                 grey      )
    imgui.PushStyleColor( imgui_col.HeaderHovered,          blackTint )
    imgui.PushStyleColor( imgui_col.HeaderActive,           blackTint )
    imgui.PushStyleColor( imgui_col.Separator,              blackTint )
    imgui.PushStyleColor( imgui_col.Text,                   black     )
    imgui.PushStyleColor( imgui_col.TextSelectedBg,         blackTint )
    imgui.PushStyleColor( imgui_col.ScrollbarGrab,          blackTint )
    imgui.PushStyleColor( imgui_col.ScrollbarGrabHovered,   black     )
    imgui.PushStyleColor( imgui_col.ScrollbarGrabActive,    black     )
    imgui.PushStyleColor( imgui_col.PlotLines,              black     )
    imgui.PushStyleColor( imgui_col.PlotLinesHovered,       notRed    )
    imgui.PushStyleColor( imgui_col.PlotHistogram,          black     )
    imgui.PushStyleColor( imgui_col.PlotHistogramHovered,   notRed    )
end
-- Returns the RGB colors based on the current time [Table]
-- Parameters
--    rgbPeriod : length in seconds for one complete RGB cycle (i.e. period) [Int/Float]
function getCurrentRGBColors(rgbPeriod)
    local totalRGBStages = 6
    local currentTime = imgui.GetTime()
    local percentIntoRGBCycle = (currentTime % rgbPeriod) / rgbPeriod
    local stagesElapsed = totalRGBStages * percentIntoRGBCycle
    local currentStageNumber = math.floor(stagesElapsed)
    local percentIntoStage = stagesElapsed - currentStageNumber
    percentIntoStage = clampToInterval(percentIntoStage, 0, 1)
    
    local red = 0 
    local green = 0
    local blue = 0
    if currentStageNumber == 0 then
        green = 1 - percentIntoStage
        blue = 1
    elseif currentStageNumber == 1 then
        blue = 1
        red = percentIntoStage
    elseif currentStageNumber == 2 then
        blue = 1 - percentIntoStage
        red = 1
    elseif currentStageNumber == 3 then
        green = percentIntoStage
        red = 1
    elseif currentStageNumber == 4 then
        green = 1
        red = 1 - percentIntoStage
    else
        blue = percentIntoStage
        green = 1
    end
    return {red = red, green = green, blue = blue}
end

---------------------------------------------------------------------------------------------------
-- Handy GUI elements -----------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------

-- Adds vertical blank space/padding on the GUI
function addPadding()
    imgui.Dummy({0, 0})
end
-- Creates a horizontal line separator on the GUI
function addSeparator()
    addPadding()
    imgui.Separator()
    addPadding()
end
-- Creates a tooltip box when the last (most recently created) GUI item is hovered over
-- Parameters
--    text : text to appear in the tooltip box [String]
function tooltip(text)
    if not imgui.IsItemHovered() then return end
    
    setTooltipActive()
    imgui.BeginTooltip()
    local tooltipWidth = 20 * imgui.GetFontSize()
    imgui.PushTextWrapPos(tooltipWidth)
    imgui.Text(text)
    imgui.PopTextWrapPos()
    imgui.EndTooltip()
end
-- Creates an inline, grayed-out '(?)' symbol that shows a tooltip box when hovered over
-- Parameters
--    text : text to show in the tooltip box [String]
function helpMarker(text)
    imgui.SameLine(0, SAMELINE_SPACING)
    imgui.TextDisabled("(?)")
    tooltip(text)
end
-- Creates a copy-pastable text box
-- Parameters
--    text    : text to put above the box [String]
--    label   : label of the input text [String]
--    content : content to put in the box [String]
function copiableBox(text, label, content)
    imgui.TextWrapped(text)
    local boxWidth = imgui.GetContentRegionAvailWidth()
    imgui.PushItemWidth(boxWidth)
    imgui.InputText(label, content, #content, imgui_input_text_flags.AutoSelectAll)
    imgui.PopItemWidth()
    addPadding()
end
-- Creates a copy-pastable link box
-- Parameters
--    text : text to describe the link [String]
--    url  : link [String]
function linkBox(text, url)
    copiableBox(text, "##"..url, url)
end

---------------------------------------------------------------------------------------------------
-- Variable Management ----------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------

-- Retrieves a list of variables from the state
-- Parameters
--    listName  : name of the variable list [String]
--    variables : list of variables [Table]
function getVariables(listName, variables) 
    for key, value in pairs(variables) do
        variables[key] = state.GetValue(listName..key) or value
    end
end
-- Saves a list of variables to the state
-- Parameters
--    listName  : name of the variable list [String]
--    variables : list of variables [Table]
function saveVariables(listName, variables)
    for key, value in pairs(variables) do
        state.SetValue(listName..key, value)
    end
end

---------------------------------------------------------------------------------------------------
-- Drawing (excuse the messy code) ----------------------------------------------------------------
---------------------------------------------------------------------------------------------------

-- Converts an RGBA color value into uint (unsigned integer) and returns the converted value [Int]
-- Parameters
--    r : red value [Int]
--    g : green value [Int]
--    b : blue value [Int]
--    a : alpha value [Int]
function rgbaToUint(r, g, b, a) return a*16^6 + b*16^4 + g*16^2 + r end
-- Draws an animation of a chinchilla when the plugin first starts up
function drawChinchillaStartupAnimation()
    local pluginTime = imgui.GetTime()-- % n -- you can make it appear every n seconds
    local animationFPS = 24
    local totalFrames = 16
    local animationDuration = (totalFrames + 1) / animationFPS
    if pluginTime > animationDuration then return end

    local o = imgui.GetOverlayDrawList()
    local chinchillaSize = 200
    local windowSize = state.WindowSize
    local windowHeight = windowSize[2]
    local chinchillaXPosition = windowSize[1] / 3
    local chinchillaColors = getChinchillaColorsList()
    local animationFrameFuncs = getStartupFrameFunctionsList()
    for frameNum = 1, totalFrames do
        local frameTime = frameNum / animationFPS
        local frameFunc = animationFrameFuncs[frameNum]
        if pluginTime < frameTime then
            frameFunc(o, chinchillaSize, chinchillaXPosition, chinchillaColors, windowHeight)
            return
        end
    end
end
-- Draws frame 1 of the chinchilla startup animation
-- Parameters
--    o                   : [imgui overlay drawlist]
--    chinchillaSize      : size of the chinchilla [Int/Float]
--    chinchillaXPosition : x coordinate of the center of the chinchilla [Int/Float]
--    chinchillaColors    : list of uint (unsigned integer) color values of the chinchilla [Table]
--    windowHeight        : height of the quaver window [Int]
function drawChinchillaAnimationFrame1(o, chinchillaSize, chinchillaXPosition, chinchillaColors,
                                       windowHeight)
    return -- empty frame lol
end
-- Draws frame 2 of the chinchilla startup animation
-- Parameters
--    o                   : [imgui overlay drawlist]
--    chinchillaSize      : size of the chinchilla [Int/Float]
--    chinchillaXPosition : x coordinate of the center of the chinchilla [Int/Float]
--    chinchillaColors    : list of uint (unsigned integer) color values of the chinchilla [Table]
--    windowHeight        : height of the quaver window [Int]
function drawChinchillaAnimationFrame2(o, chinchillaSize, chinchillaXPosition, chinchillaColors,
                                       windowHeight)
    local bodyCenterCoords = {chinchillaXPosition, windowHeight}
    drawMainChinchilla(o, bodyCenterCoords, chinchillaSize, chinchillaColors)
end
-- Draws frame 3 of the chinchilla startup animation
-- Parameters
--    o                   : [imgui overlay drawlist]
--    chinchillaSize      : size of the chinchilla [Int/Float]
--    chinchillaXPosition : x coordinate of the center of the chinchilla [Int/Float]
--    chinchillaColors    : list of uint (unsigned integer) color values of the chinchilla [Table]
--    windowHeight        : height of the quaver window [Int]
function drawChinchillaAnimationFrame3(o, chinchillaSize, chinchillaXPosition, chinchillaColors,
                                       windowHeight)
    local bodyCenterCoords = {chinchillaXPosition, windowHeight - 220}
    drawChinchillaTail(o, bodyCenterCoords, chinchillaColors, 1)
    drawMainChinchilla(o, bodyCenterCoords, chinchillaSize, chinchillaColors)
end
-- Draws frame 4 of the chinchilla startup animation
-- Parameters
--    o                   : [imgui overlay drawlist]
--    chinchillaSize      : size of the chinchilla [Int/Float]
--    chinchillaXPosition : x coordinate of the center of the chinchilla [Int/Float]
--    chinchillaColors    : list of uint (unsigned integer) color values of the chinchilla [Table]
--    windowHeight        : height of the quaver window [Int]
function drawChinchillaAnimationFrame4(o, chinchillaSize, chinchillaXPosition, chinchillaColors,
                                       windowHeight)
    local bodyCenterCoords = {chinchillaXPosition, windowHeight - 264}
    drawChinchillaTail(o, bodyCenterCoords, chinchillaColors, 2)
    drawMainChinchilla(o, bodyCenterCoords, chinchillaSize, chinchillaColors)
end
-- Draws frame 5 of the chinchilla startup animation
-- Parameters
--    o                   : [imgui overlay drawlist]
--    chinchillaSize      : size of the chinchilla [Int/Float]
--    chinchillaXPosition : x coordinate of the center of the chinchilla [Int/Float]
--    chinchillaColors    : list of uint (unsigned integer) color values of the chinchilla [Table]
--    windowHeight        : height of the quaver window [Int]
function drawChinchillaAnimationFrame5(o, chinchillaSize, chinchillaXPosition, chinchillaColors,
                                       windowHeight)
    local bodyCenterCoords = {chinchillaXPosition, windowHeight - 284}
    drawChinchillaTail(o, bodyCenterCoords, chinchillaColors, 3)
    drawMainChinchilla(o, bodyCenterCoords, chinchillaSize, chinchillaColors)
end
-- Draws frame 6 of the chinchilla startup animation
-- Parameters
--    o                   : [imgui overlay drawlist]
--    chinchillaSize      : size of the chinchilla [Int/Float]
--    chinchillaXPosition : x coordinate of the center of the chinchilla [Int/Float]
--    chinchillaColors    : list of uint (unsigned integer) color values of the chinchilla [Table]
--    windowHeight        : height of the quaver window [Int]
function drawChinchillaAnimationFrame6(o, chinchillaSize, chinchillaXPosition, chinchillaColors,
                                       windowHeight)
    local bodyCenterCoords = {chinchillaXPosition, windowHeight - 294}
    drawChinchillaTail(o, bodyCenterCoords, chinchillaColors, 5)
    drawMainChinchilla(o, bodyCenterCoords, chinchillaSize, chinchillaColors)
end
-- Draws frame 7 of the chinchilla startup animation
-- Parameters
--    o                   : [imgui overlay drawlist]
--    chinchillaSize      : size of the chinchilla [Int/Float]
--    chinchillaXPosition : x coordinate of the center of the chinchilla [Int/Float]
--    chinchillaColors    : list of uint (unsigned integer) color values of the chinchilla [Table]
--    windowHeight        : height of the quaver window [Int]
function drawChinchillaAnimationFrame7(o, chinchillaSize, chinchillaXPosition, chinchillaColors,
                                       windowHeight)
    local bodyCenterCoords = {chinchillaXPosition, windowHeight - 304}
    drawChinchillaTail(o, bodyCenterCoords, chinchillaColors, 4)
    drawMainChinchilla(o, bodyCenterCoords, chinchillaSize, chinchillaColors)
end
-- Draws frame 8 of the chinchilla startup animation
-- Parameters
--    o                   : [imgui overlay drawlist]
--    chinchillaSize      : size of the chinchilla [Int/Float]
--    chinchillaXPosition : x coordinate of the center of the chinchilla [Int/Float]
--    chinchillaColors    : list of uint (unsigned integer) color values of the chinchilla [Table]
--    windowHeight        : height of the quaver window [Int]
function drawChinchillaAnimationFrame8(o, chinchillaSize, chinchillaXPosition, chinchillaColors,
                                       windowHeight)
    local bodyCenterCoords = {chinchillaXPosition, windowHeight - 308}
    drawChinchillaTail(o, bodyCenterCoords, chinchillaColors, 3)
    drawMainChinchilla(o, bodyCenterCoords, chinchillaSize, chinchillaColors)
end
-- Draws frame 9 of the chinchilla startup animation
-- Parameters
--    o                   : [imgui overlay drawlist]
--    chinchillaSize      : size of the chinchilla [Int/Float]
--    chinchillaXPosition : x coordinate of the center of the chinchilla [Int/Float]
--    chinchillaColors    : list of uint (unsigned integer) color values of the chinchilla [Table]
--    windowHeight        : height of the quaver window [Int]
function drawChinchillaAnimationFrame9(o, chinchillaSize, chinchillaXPosition, chinchillaColors,
                                       windowHeight)
    local bodyCenterCoords = {chinchillaXPosition, windowHeight - 312}
    drawChinchillaTail(o, bodyCenterCoords, chinchillaColors, 1)
    drawMainChinchilla(o, bodyCenterCoords, chinchillaSize, chinchillaColors)
end
-- Draws frame 10 of the chinchilla startup animation
-- Parameters
--    o                   : [imgui overlay drawlist]
--    chinchillaSize      : size of the chinchilla [Int/Float]
--    chinchillaXPosition : x coordinate of the center of the chinchilla [Int/Float]
--    chinchillaColors    : list of uint (unsigned integer) color values of the chinchilla [Table]
--    windowHeight        : height of the quaver window [Int]
function drawChinchillaAnimationFrame10(o, chinchillaSize, chinchillaXPosition, chinchillaColors,
                                        windowHeight)
    local bodyCenterCoords = {chinchillaXPosition, windowHeight - 308}
    drawChinchillaTail(o, bodyCenterCoords, chinchillaColors, 2)
    drawMainChinchilla(o, bodyCenterCoords, chinchillaSize, chinchillaColors)
end
-- Draws frame 11 of the chinchilla startup animation
-- Parameters
--    o                   : [imgui overlay drawlist]
--    chinchillaSize      : size of the chinchilla [Int/Float]
--    chinchillaXPosition : x coordinate of the center of the chinchilla [Int/Float]
--    chinchillaColors    : list of uint (unsigned integer) color values of the chinchilla [Table]
--    windowHeight        : height of the quaver window [Int]
function drawChinchillaAnimationFrame11(o, chinchillaSize, chinchillaXPosition, chinchillaColors,
                                        windowHeight)
    local bodyCenterCoords = {chinchillaXPosition, windowHeight - 304}
    drawChinchillaTail(o, bodyCenterCoords, chinchillaColors, 3)
    drawMainChinchilla(o, bodyCenterCoords, chinchillaSize, chinchillaColors)
end
-- Draws frame 12 of the chinchilla startup animation
-- Parameters
--    o                   : [imgui overlay drawlist]
--    chinchillaSize      : size of the chinchilla [Int/Float]
--    chinchillaXPosition : x coordinate of the center of the chinchilla [Int/Float]
--    chinchillaColors    : list of uint (unsigned integer) color values of the chinchilla [Table]
--    windowHeight        : height of the quaver window [Int]
function drawChinchillaAnimationFrame12(o, chinchillaSize, chinchillaXPosition, chinchillaColors,
                                        windowHeight)
    local bodyCenterCoords = {chinchillaXPosition, windowHeight - 294}
    drawChinchillaTail(o, bodyCenterCoords, chinchillaColors, 5)
    drawMainChinchilla(o, bodyCenterCoords, chinchillaSize, chinchillaColors)
end
-- Draws frame 13 of the chinchilla startup animation
-- Parameters
--    o                   : [imgui overlay drawlist]
--    chinchillaSize      : size of the chinchilla [Int/Float]
--    chinchillaXPosition : x coordinate of the center of the chinchilla [Int/Float]
--    chinchillaColors    : list of uint (unsigned integer) color values of the chinchilla [Table]
--    windowHeight        : height of the quaver window [Int]
function drawChinchillaAnimationFrame13(o, chinchillaSize, chinchillaXPosition, chinchillaColors,
                                        windowHeight)
    local bodyCenterCoords = {chinchillaXPosition, windowHeight - 284}
    drawChinchillaTail(o, bodyCenterCoords, chinchillaColors, 4)
    drawMainChinchilla(o, bodyCenterCoords, chinchillaSize, chinchillaColors)
end
-- Draws frame 14 of the chinchilla startup animation
-- Parameters
--    o                   : [imgui overlay drawlist]
--    chinchillaSize      : size of the chinchilla [Int/Float]
--    chinchillaXPosition : x coordinate of the center of the chinchilla [Int/Float]
--    chinchillaColors    : list of uint (unsigned integer) color values of the chinchilla [Table]
--    windowHeight        : height of the quaver window [Int]
function drawChinchillaAnimationFrame14(o, chinchillaSize, chinchillaXPosition, chinchillaColors,
                                        windowHeight)
    local bodyCenterCoords = {chinchillaXPosition, windowHeight - 264}
    drawChinchillaTail(o, bodyCenterCoords, chinchillaColors, 3)
    drawMainChinchilla(o, bodyCenterCoords, chinchillaSize, chinchillaColors)
end
-- Draws frame 15 of the chinchilla startup animation
-- Parameters
--    o                   : [imgui overlay drawlist]
--    chinchillaSize      : size of the chinchilla [Int/Float]
--    chinchillaXPosition : x coordinate of the center of the chinchilla [Int/Float]
--    chinchillaColors    : list of uint (unsigned integer) color values of the chinchilla [Table]
--    windowHeight        : height of the quaver window [Int]
function drawChinchillaAnimationFrame15(o, chinchillaSize, chinchillaXPosition, chinchillaColors,
                                        windowHeight)
    local bodyCenterCoords = {chinchillaXPosition, windowHeight - 220}
    drawChinchillaTail(o, bodyCenterCoords, chinchillaColors, 1)
    drawMainChinchilla(o, bodyCenterCoords, chinchillaSize, chinchillaColors)
end
-- Draws frame 16 of the chinchilla startup animation
-- Parameters
--    o                   : [imgui overlay drawlist]
--    chinchillaSize      : size of the chinchilla [Int/Float]
--    chinchillaXPosition : x coordinate of the center of the chinchilla [Int/Float]
--    chinchillaColors    : list of uint (unsigned integer) color values of the chinchilla [Table]
--    windowHeight        : height of the quaver window [Int]
function drawChinchillaAnimationFrame16(o, chinchillaSize, chinchillaXPosition, chinchillaColors,
                                        windowHeight)
    local bodyCenterCoords = {chinchillaXPosition, windowHeight}
    drawMainChinchilla(o, bodyCenterCoords, chinchillaSize, chinchillaColors)
end
-- Returns a list of animation frames for the startup animation [Table]
function getChinchillaColorsList()
    local chinchillaColors = {}
    chinchillaColors[1] = rgbaToUint(202, 211, 229, 255)
    chinchillaColors[2] = rgbaToUint(138, 141, 158, 255)
    chinchillaColors[3] = rgbaToUint(74, 83, 74, 255)
    chinchillaColors[4] = rgbaToUint(128, 128, 128, 255)
    chinchillaColors[5] = rgbaToUint(171, 165, 165, 255)
    chinchillaColors[6] = rgbaToUint(198, 196, 200, 255)
    return chinchillaColors
end
-- Returns a list of animation frames for the startup animation [Table]
function getStartupFrameFunctionsList()
    local animationFrames = {}
    animationFrames[1] = drawChinchillaAnimationFrame1
    animationFrames[2] = drawChinchillaAnimationFrame2
    animationFrames[3] = drawChinchillaAnimationFrame3
    animationFrames[4] = drawChinchillaAnimationFrame4
    animationFrames[5] = drawChinchillaAnimationFrame5
    animationFrames[6] = drawChinchillaAnimationFrame6
    animationFrames[7] = drawChinchillaAnimationFrame7
    animationFrames[8] = drawChinchillaAnimationFrame8
    animationFrames[9] = drawChinchillaAnimationFrame9
    animationFrames[10] = drawChinchillaAnimationFrame10
    animationFrames[11] = drawChinchillaAnimationFrame11
    animationFrames[12] = drawChinchillaAnimationFrame12
    animationFrames[13] = drawChinchillaAnimationFrame13
    animationFrames[14] = drawChinchillaAnimationFrame14
    animationFrames[15] = drawChinchillaAnimationFrame15
    animationFrames[16] = drawChinchillaAnimationFrame16
    return animationFrames
end
-- Returns coordinates relative to a given coordinate [Table]
-- Parameters
--    point   : (x, y) coordinates [Table]
--    xChange : change in x coordinate [Int]
--    yChange : change in y coordinate [Int]
function relativeCoords(point, xChange, yChange)
    return {point[1] + xChange, point[2] + yChange}
end
-- Draws the static, main parts of the chinchilla
-- Parameters
--    o                : [imgui overlay drawlist]
--    bodyCenterCoords : coordinates of the center of the body of the chinchilla [Table]
--    size             : size of the chinchilla [Int]
--    chinchillaColors : list of uint (unsigned integer) color values of the chinchilla [Table]
function drawMainChinchilla(o, bodyCenterCoords, size, chinchillaColors)
    local ear1Coords = relativeCoords(bodyCenterCoords, -99, -32)
    local ear2Coords = relativeCoords(bodyCenterCoords, -4, -106)
    local earColor = chinchillaColors[2]
    local earRadius = 40
    local earSegments = 32
    o.AddCircleFilled(ear1Coords, earRadius, earColor, earSegments)
    o.AddCircleFilled(ear2Coords, earRadius, earColor, earSegments)
    local bodyRadius = size / 2
    local bodyColor = chinchillaColors[1]
    local bodyCircleSegments = 40
    o.AddCircleFilled(bodyCenterCoords, bodyRadius, bodyColor, bodyCircleSegments)
    local eyeP1 = relativeCoords(bodyCenterCoords, 22, -69)
    local eyeP2 = relativeCoords(bodyCenterCoords, 7, -71)
    local eyeP3 = relativeCoords(bodyCenterCoords, 5, -56)
    local eyeP4 = relativeCoords(bodyCenterCoords, -53, -10)
    local eyeP5 = relativeCoords(bodyCenterCoords, -68, -12)
    local eyeP6 = relativeCoords(bodyCenterCoords, -70, 3)
    local eyeRadius = 7.5
    local eyeColor = chinchillaColors[3]
    local eyeSegments = 12
    drawPill(o, eyeP1, eyeP2, eyeRadius, eyeColor, eyeSegments)
    drawPill(o, eyeP2, eyeP3, eyeRadius, eyeColor, eyeSegments)
    drawPill(o, eyeP4, eyeP5, eyeRadius, eyeColor, eyeSegments)
    drawPill(o, eyeP5, eyeP6, eyeRadius, eyeColor, eyeSegments)
    local whiskerP1 = relativeCoords(bodyCenterCoords, -24, -4)
    local whiskerP2 = relativeCoords(bodyCenterCoords, -39, 20)
    local whiskerP3 = relativeCoords(bodyCenterCoords, -12, -2)
    local whiskerP4 = relativeCoords(bodyCenterCoords, -20, 27)
    local whiskerP5 = relativeCoords(bodyCenterCoords, 4, -26)
    local whiskerP6 = relativeCoords(bodyCenterCoords, 31, -35)
    local whiskerP7 = relativeCoords(bodyCenterCoords, 4, -15)
    local whiskerP8 = relativeCoords(bodyCenterCoords, 34, -15)
    local whiskerColor = chinchillaColors[4]
    local whiskerThickness = 1
    o.AddLine(whiskerP1, whiskerP2, whiskerColor, whiskerThickness)
    o.AddLine(whiskerP3, whiskerP4, whiskerColor, whiskerThickness)
    o.AddLine(whiskerP5, whiskerP6, whiskerColor, whiskerThickness)
    o.AddLine(whiskerP7, whiskerP8, whiskerColor, whiskerThickness)
    local noseCoords = relativeCoords(bodyCenterCoords, -13, -20)
    local noseRadius = 10
    local noseColor = chinchillaColors[2]
    local noseSegments = 16
    o.AddCircleFilled(noseCoords, noseRadius, noseColor, noseSegments)
    local feetP1 = relativeCoords(bodyCenterCoords, 24, 75)
    local feetP2 = relativeCoords(bodyCenterCoords, -5, 74)
    local feetP3 = relativeCoords(bodyCenterCoords, 71, 38)
    local feetP4 = relativeCoords(bodyCenterCoords, 77, 10)
    local feetRadius = 9
    local feetColor = chinchillaColors[5]
    local feetSegments = 16
    drawPill(o, feetP1, feetP2, feetRadius, feetColor, feetSegments)
    drawPill(o, feetP3, feetP4, feetRadius, feetColor, feetSegments)
    local toeP1 = relativeCoords(bodyCenterCoords, 84, 3)
    local toeP2 = relativeCoords(bodyCenterCoords, 79, -1)
    local toeP3 = relativeCoords(bodyCenterCoords, 73, 1)
    local toeP4 = relativeCoords(bodyCenterCoords, -12, 68)
    local toeP5 = relativeCoords(bodyCenterCoords, -16, 73)
    local toeP6 = relativeCoords(bodyCenterCoords, -13, 79)
    local toeCircleRadius = 2.5
    local feetToeCircleRadius = 5
    local toeColor = chinchillaColors[6]
    local toeSegments = 8
    o.AddCircleFilled(toeP1, feetToeCircleRadius, feetColor, toeSegments)
    o.AddCircleFilled(toeP2, feetToeCircleRadius, feetColor, toeSegments)
    o.AddCircleFilled(toeP3, feetToeCircleRadius, feetColor, toeSegments)
    o.AddCircleFilled(toeP4, feetToeCircleRadius, feetColor, toeSegments)
    o.AddCircleFilled(toeP5, feetToeCircleRadius, feetColor, toeSegments)
    o.AddCircleFilled(toeP6, feetToeCircleRadius, feetColor, toeSegments)
    o.AddCircleFilled(toeP3, toeCircleRadius, toeColor, toeSegments)
    o.AddCircleFilled(toeP1, toeCircleRadius, toeColor, toeSegments)
    o.AddCircleFilled(toeP2, toeCircleRadius, toeColor, toeSegments)
    o.AddCircleFilled(toeP4, toeCircleRadius, toeColor, toeSegments)
    o.AddCircleFilled(toeP5, toeCircleRadius, toeColor, toeSegments)
    o.AddCircleFilled(toeP6, toeCircleRadius, toeColor, toeSegments)
end
-- Draws a pill shape between two points
-- Parameters
--    o              : [imgui overlay drawlist]
--    p1             : coordinates of the first point [Table]
--    p2             : coordinates of the second point [Table]
--    radius         : radius of the circles of the pill [Int/Float]
--    color          : uint (unsigned integer) color value of the pill [Int]
--    circleSegments : number of segments on the circles of the pill [Int]
function drawPill(o, p1, p2, radius, color, circleSegments)
    local p1ToP2 = addVectors(p2, vectorRotated180Degrees(p1))
    local p1ToP2Length = vectorLength(p1ToP2)
    local p1ToP2ClockwiseRotated = vectorRotated90DegreesClockwise(p1ToP2)
    local radiusNormalizingFactor = radius / p1ToP2Length
    
    local v1 = vectorScaled(p1ToP2ClockwiseRotated, radiusNormalizingFactor)
    local v2 = vectorRotated180Degrees(v1)
    local p3 = addVectors(p1, v1)
    local p4 = addVectors(p1, v2)
    local p5 = addVectors(p2, v1)
    local p6 = addVectors(p2, v2)
    o.AddCircleFilled(p1, radius, color, circleSegments)
    o.AddQuadFilled(p3, p4, p6, p5, color)
    o.AddCircleFilled(p2, radius, color, circleSegments)
end
-- Returns a 2D vector/point rotated 90 degrees clockwise [Table]
-- Parameters
--    vector : a 2 dimensional vector [Table]
function vectorRotated90DegreesClockwise(vector)
    return {vector[2], -vector[1]}
end
-- Rotates a 2D vector/point rotated 180 degrees [Table]
-- Parameters
--    vector : a 2 dimensional vector [Table]
function vectorRotated180Degrees(vector)
    return {-vector[1], -vector[2]}
end
-- Returns the length of a vector [Int]
-- Parameters
--    vector : vector of any dimensions [Table]
function vectorLength(vector)
    local sumOfSquareLengths = 0
    for i = 1, #vector do
        sumOfSquareLengths = sumOfSquareLengths + (vector[i]) ^ 2
    end
    return math.sqrt(sumOfSquareLengths)
end
-- Returns a scaled vector [Table]
function vectorScaled(vector, scalingFactor)
    local newVector = {}
    for i = 1, #vector do
        newVector[i] = scalingFactor * vector[i]
    end
    return newVector
end
-- Returns the result of two vectors of same dimension being added [Table]
-- Parameters
--    vector1 : first vector [Table]
--    vector2 : second vector [Table]
function addVectors(vector1, vector2)
    local newVector = {}
    for i = 1, #vector1 do
        newVector[i] = vector1[i] +  vector2[i]
    end
    return newVector
end
-- Draws the tail of the chinchilla
-- Parameters
--    o                : [imgui overlay drawlist]
--    bodyCenterCoords : coordinates of the center of the body of the chinchilla [Table]
--    chinchillaColors : list of uint (unsigned integer) color values of the chinchilla [Table]
--    frameNum         : frame of the tail [Int]
function drawChinchillaTail(o, bodyCenterCoords, chinchillaColors, frameNum)
    local p1 = relativeCoords(bodyCenterCoords, 28, 34)
    local p2
    local p3
    if frameNum == 1 then
        p2 = relativeCoords(bodyCenterCoords, 199, -3)
        p3 = relativeCoords(bodyCenterCoords, 199, 74)
    elseif frameNum == 2 then
        p2 = relativeCoords(bodyCenterCoords, 201, 25)
        p3 = relativeCoords(bodyCenterCoords, 192, 94)
    elseif frameNum == 3 then
        p2 = relativeCoords(bodyCenterCoords, 167, 130)
        p3 = relativeCoords(bodyCenterCoords, 91, 193)
    elseif frameNum == 4 then
        p2 = relativeCoords(bodyCenterCoords, -24, 198)
        p3 = relativeCoords(bodyCenterCoords, 48, 207)
    elseif frameNum == 5 then
        p2 = relativeCoords(bodyCenterCoords, -51, 192)
        p3 = relativeCoords(bodyCenterCoords, 24, 210)
    end
    local tailColor = chinchillaColors[1]
    o.AddTriangleFilled(p1, p2, p3, tailColor)
end