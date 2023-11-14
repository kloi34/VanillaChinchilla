-- VanillaChinchilla v0.0 (13 November 2023)
-- by kloi34

---------------------------------------------------------------------------------------------------
-- Plugin Info ------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------

-- This is an editor plugin for Quaver, the ultimate community-driven and open-source competitive
-- rhythm game. The plugin provides various tools to place and edit regular notes and long notes
-- in a variety of ways.

-- If you have any feature suggestions or issues with the plugin, please open an issue at 
-- https://github.com/kloi34/VanillaChinchilla/issues

---------------------------------------------------------------------------------------------------
-- Global Constants -------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------

--------------------------------------------------------------------------------------- IMGUI / GUI

DEFAULT_WIDGET_HEIGHT = 26         -- value determining the height of GUI widgets
DEFAULT_WIDGET_WIDTH = 160         -- value determining the width of GUI widgets
PADDING_WIDTH = 8                  -- value determining window and frame padding
RADIO_BUTTON_SPACING = 7.5         -- value determining spacing between radio buttons
SAMELINE_SPACING = 5               -- value determining spacing between GUI items on the same row
ACTION_BUTTON_SIZE = {             -- dimensions of the button that does important things
    1.6 * DEFAULT_WIDGET_WIDTH - 1,
    1.6 * DEFAULT_WIDGET_HEIGHT
}
HALF_BUTTON_SIZE = {               -- dimensions of a button that does less important things
    0.8 * DEFAULT_WIDGET_WIDTH - 2.5,
    DEFAULT_WIDGET_HEIGHT - 2
}
LANE_BUTTON_SIZE = {30, 30}

--------------------------------------------------------------------------------------------- Other

MINIMUM_RGB_CYCLE_TIME = 6         -- minimum seconds for one complete RGB color cycle
MAXIMUM_RGB_CYCLE_TIME = 300       -- maximum seconds for one complete RGB color cycle

STYLE_THEMES = {                   -- available style/appearance themes for the plugin
    "Rounded",
    "Boxed",
    "Rounded + Border",
    "Boxed + Border"
}
COLOR_THEMES = {                   -- available color themes for the plugin
    "Strawberry",
    "Amethyst",
    "Tree",
    "Incognito",
    "Incognito + RGB",
    "Glass",
    "Glass + RGB",
    "RGB Gamer Mode"
}

TAB_MENUS = {                      -- tab names for different SV menus
    " Info",
    "Place Notes",
    "Edit Notes",
    "Extras"
}
PLACE_TOOLS = {                    -- available tools to place notes with
    "None"
}
EDIT_TOOLS = {                     -- available tools to edit notes with
    "Adjust LN Lengths",
    "Shift Notes Left/Right",
    "Shift Notes Up/Down",
    "Flip Notes Vertically",
    "Switch Note Lanes"
}

---------------------------------------------------------------------------------------------------
-- Plugin Appearance, Styles and Colors -----------------------------------------------------------
---------------------------------------------------------------------------------------------------

-- Returns coordinates relative to the plugin window [Table]
-- Parameters
--    x : x coordinate relative to the plugin window [Int]
--    y : y coordinate relative to the plugin window [Int]
function coordsRelativeToWindow(x, y)
    local newX = x + imgui.GetWindowPos()[1]
    local newY = y + imgui.GetWindowPos()[2]
    return {newX, newY}
end
-- Returns the RGB colors based on the current time [Table]
-- Parameters
--    rgbPeriod : length in seconds for one complete RGB cycle (i.e. period) [Int/Float]
function getCurrentRGBColors(rgbPeriod)
    local currentTime = imgui.GetTime()
    local percentIntoCycle = (currentTime % rgbPeriod) / rgbPeriod
    local stageNumberIntoCycle = math.floor(percentIntoCycle * 6)
    local percentIntoStage = percentIntoCycle * 6 - stageNumberIntoCycle
    percentIntoStage = clampToInterval(percentIntoStage, 0, 1)
    local red
    local green
    local blue
    if stageNumberIntoCycle == 0 then
        red = 0
        green = 1 - percentIntoStage
        blue = 1
    elseif stageNumberIntoCycle == 1 then
        blue = 1
        green = 0
        red = percentIntoStage
    elseif stageNumberIntoCycle == 2 then
        blue = 1 - percentIntoStage
        green = 0
        red = 1
    elseif stageNumberIntoCycle == 3 then
        blue = 0
        green = percentIntoStage
        red = 1
    elseif stageNumberIntoCycle == 4 then
        blue = 0
        green = 1
        red = 1 - percentIntoStage
    else
        blue = percentIntoStage
        green = 1
        red = 0
    end
    return {red = red, green = green, blue = blue}
end
-- Converts an RGBA color value into uint (unsigned integer) and returns the converted value [Int]
-- Parameters
--    r : red value [Int]
--    g : green value [Int]
--    b : blue value [Int]
--    a : alpha value [Int]
function rgbaToUint(r, g, b, a) return a*16^6 + b*16^4 + g*16^2 + r end
-- Configures the plugin GUI appearance
-- Parameters
--    globalVars : list of variables used globally across all menus [Table]
function setPluginAppearance(globalVars)
    local colorTheme = COLOR_THEMES[globalVars.colorThemeIndex]
    local styleTheme = STYLE_THEMES[globalVars.styleThemeIndex]
    
    setPluginAppearanceStyles(styleTheme)
    setPluginAppearanceColors(globalVars, colorTheme)
end
-- Configures the plugin GUI styles
-- Parameters
--    styleTheme : name of the desired style theme [String]
function setPluginAppearanceStyles(styleTheme)
    local boxed = styleTheme == "Boxed" or styleTheme == "Boxed + Border"
    local cornerRoundnessValue = 5 -- up to 12, 14 for WindowRounding and 16 for ChildRounding
    if boxed then cornerRoundnessValue = 0 end
    
    local addBorder = styleTheme == "Rounded + Border" or styleTheme == "Boxed + Border"
    local borderSize = 0
    if addBorder then borderSize = 1 end

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
    
    -- not working? TabBorderSize doesn't exist? But it's changeable in the style editor demo?
    -- imgui.PushStyleVar( imgui_style_var.TabBorderSize,      borderSize           ) 
end
-- Configures the plugin GUI colors
-- Parameters
--    globalVars : list of variables used globally across all menus [Table]
--    colorTheme : name of the target color theme [String]
function setPluginAppearanceColors(globalVars, colorTheme)
    if colorTheme == "Strawberry" then
        imgui.PushStyleColor( imgui_col.WindowBg,               { 0.00, 0.00, 0.00, 1.00 } )
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
    elseif colorTheme == "Amethyst" then
        imgui.PushStyleColor( imgui_col.WindowBg,               { 0.16, 0.00, 0.20, 1.00 } )
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
    elseif colorTheme == "Tree" then
        imgui.PushStyleColor( imgui_col.WindowBg,               { 0.20, 0.16, 0.00, 1.00 } )
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
    elseif colorTheme == "Incognito" then
        local black = {0.00, 0.00, 0.00, 1.00}
        local white = {1.00, 1.00, 1.00, 1.00}
        local grey = {0.20, 0.20, 0.20, 1.00}
        local whiteTint = {1.00, 1.00, 1.00, 0.40}
        local red = {1.00, 0.00, 0.00, 1.00}
        
        imgui.PushStyleColor( imgui_col.WindowBg,               black     )
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
    elseif colorTheme == "Incognito + RGB" then
        local black = {0.00, 0.00, 0.00, 1.00}
        local white = {1.00, 1.00, 1.00, 1.00}
        local grey = {0.20, 0.20, 0.20, 1.00}
        local whiteTint = {1.00, 1.00, 1.00, 0.40}
        local currentRGB = getCurrentRGBColors(globalVars.rgbPeriod)
        local rgbColor = {currentRGB.red, currentRGB.green, currentRGB.blue, 0.8}
        
        imgui.PushStyleColor( imgui_col.WindowBg,               black     )
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
    elseif colorTheme == "Glass" then
        local transparent = {0.00, 0.00, 0.00, 0.25}
        local transparentWhite = {1.00, 1.00, 1.00, 0.70}
        local whiteTint = {1.00, 1.00, 1.00, 0.30}
        local white = {1.00, 1.00, 1.00, 1.00}
        
        imgui.PushStyleColor( imgui_col.WindowBg,               transparent      )
        imgui.PushStyleColor( imgui_col.Border,                 transparentWhite )
        imgui.PushStyleColor( imgui_col.FrameBg,                transparent      )
        imgui.PushStyleColor( imgui_col.FrameBgHovered,         whiteTint        )
        imgui.PushStyleColor( imgui_col.FrameBgActive,          whiteTint        )
        imgui.PushStyleColor( imgui_col.TitleBg,                transparent      )
        imgui.PushStyleColor( imgui_col.TitleBgActive,          transparent      )
        imgui.PushStyleColor( imgui_col.TitleBgCollapsed,       transparent      )
        imgui.PushStyleColor( imgui_col.CheckMark,              transparentWhite )
        imgui.PushStyleColor( imgui_col.SliderGrab,             whiteTint        )
        imgui.PushStyleColor( imgui_col.SliderGrabActive,       transparentWhite )
        imgui.PushStyleColor( imgui_col.Button,                 transparent      )
        imgui.PushStyleColor( imgui_col.ButtonHovered,          whiteTint        )
        imgui.PushStyleColor( imgui_col.ButtonActive,           whiteTint        )
        imgui.PushStyleColor( imgui_col.Tab,                    transparent      )
        imgui.PushStyleColor( imgui_col.TabHovered,             whiteTint        )
        imgui.PushStyleColor( imgui_col.TabActive,              whiteTint        )
        imgui.PushStyleColor( imgui_col.Header,                 transparent      )
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
    elseif colorTheme == "Glass + RGB" then
        local currentRGB = getCurrentRGBColors(globalVars.rgbPeriod)
        local activeColor = {currentRGB.red, currentRGB.green, currentRGB.blue, 0.8}
        local colorTint = {currentRGB.red, currentRGB.green, currentRGB.blue, 0.3}
        local transparent = {0.00, 0.00, 0.00, 0.25}
        local white = {1.00, 1.00, 1.00, 1.00}
        
        imgui.PushStyleColor( imgui_col.WindowBg,               transparent )
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
    elseif colorTheme == "RGB Gamer Mode" then
        local currentRGB = getCurrentRGBColors(globalVars.rgbPeriod)
        local activeColor = {currentRGB.red, currentRGB.green, currentRGB.blue, 0.8}
        local inactiveColor = {currentRGB.red, currentRGB.green, currentRGB.blue, 0.5}
        local white = {1.00, 1.00, 1.00, 1.00}
        local clearWhite = {1.00, 1.00, 1.00, 0.40}
        local black = {0.00, 0.00, 0.00, 1.00}
        
        imgui.PushStyleColor( imgui_col.WindowBg,               black         )
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
end

---------------------------------------------------------------------------------------------------
-- Variable Management ----------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------

-- Retrieves variables from the state
-- Parameters
--    listName  : name of the variable list [String]
--    variables : list of variables [Table]
function getVariables(listName, variables) 
    for key, value in pairs(variables) do
        variables[key] = state.GetValue(listName..key) or value
    end
end
-- Saves variables to the state
-- Parameters
--    listName  : name of the variable list [String]
--    variables : list of variables [Table]
function saveVariables(listName, variables)
    for key, value in pairs(variables) do
        state.SetValue(listName..key, value)
    end
end

---------------------------------------------------------------------------------------------------
-- Handy GUI elements -----------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------

-- Adds vertical blank space/padding on the GUI
function addPadding()
    imgui.Dummy({0, 0})
end
-- Draws a horizontal line separator on the GUI
function addSeparator()
    addPadding()
    imgui.Separator()
    addPadding()
end
-- Creates a tooltip box when the last (most recently created) item is hovered over
-- Parameters
--    text : text to appear in the tooltip box [String]
function toolTip(text)
    if not imgui.IsItemHovered() then return end
    imgui.BeginTooltip()
    imgui.PushTextWrapPos(imgui.GetFontSize() * 20)
    imgui.Text(text)
    imgui.PopTextWrapPos()
    imgui.EndTooltip()
end
-- Creates an inline, grayed-out '(?)' symbol that shows a tooltip box when hovered over
-- Parameters
--    text : text to appear in the tooltip box [String]
function helpMarker(text)
    imgui.SameLine(0, SAMELINE_SPACING)
    imgui.TextDisabled("(?)")
    toolTip(text)
end
-- Creates a copy-pastable link
-- Parameters
--    text : text to describe the url [String]
--    url  : url [String]
function provideLink(text, url)
    addPadding()
    imgui.TextWrapped(text)
    imgui.PushItemWidth(imgui.GetContentRegionAvailWidth())
    imgui.InputText("##"..url, url, #url, imgui_input_text_flags.AutoSelectAll)
    imgui.PopItemWidth()
    addPadding()
end

---------------------------------------------------------------------------------------------------
-- Plugin Convenience Functions -------------------------------------------------------------------
---------------------------------------------------------------------------------------------------

-- Makes the next plugin window not collapsed when it's first opened
-- Parameters
--    windowName : name of the next plugin window [String]
function startNextWindowNotCollapsed(windowName)
    if state.GetValue(windowName) then return end
    imgui.SetNextWindowCollapsed(false)
    state.SetValue(windowName, true)
end
-- Makes the plugin window focused/active if Shift + Tab is pressed
function focusWindowIfHotkeysPressed()
    local shiftKeyPressedDown = utils.IsKeyDown(keys.LeftShift) or
                                utils.IsKeyDown(keys.RightShift)
    local tabKeyPressed = utils.IsKeyPressed(keys.Tab)
    if shiftKeyPressedDown and tabKeyPressed then imgui.SetNextWindowFocus() end
end
-- Makes the plugin window centered if Ctrl + Shift + Tab is pressed
function centerWindowIfHotkeysPressed()
    local ctrlPressedDown = utils.IsKeyDown(keys.LeftControl) or
                            utils.IsKeyDown(keys.RightControl)
    local shiftPressedDown = utils.IsKeyDown(keys.LeftShift) or
                             utils.IsKeyDown(keys.RightShift)
    local tabPressed = utils.IsKeyPressed(keys.Tab)
    if not (ctrlPressedDown and shiftPressedDown and tabPressed) then return end
    
    local windowWidth, windowHeight = table.unpack(state.WindowSize)
    local pluginWidth, pluginHeight = table.unpack(imgui.GetWindowSize())
    local centeringX = (windowWidth - pluginWidth) / 2
    local centeringY = (windowHeight - pluginHeight) / 2
    local coordinatesToCenter = {centeringX, centeringY}
    imgui.SetWindowPos("VanillaChinchilla", coordinatesToCenter)
end

---------------------------------------------------------------------------------------------------
-- Plugin Menus -----------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------

-- Creates the plugin window
function draw()
    local globalVars = {
        placeToolIndex = 1,
        editToolIndex = 1,
        colorThemeIndex = 1,
        styleThemeIndex = 1,
        rgbPeriod = 60
    }
    getVariables("globalVars", globalVars)
    setPluginAppearance(globalVars)
    startNextWindowNotCollapsed("MainWindow")
    focusWindowIfHotkeysPressed()
    
    imgui.Begin("VanillaChinchilla", imgui_window_flags.AlwaysAutoResize)
    centerWindowIfHotkeysPressed()
    imgui.PushItemWidth(DEFAULT_WIDGET_WIDTH)
    imgui.BeginTabBar("SV tabs")
    for i = 1, #TAB_MENUS do
        createMenuTab(globalVars, TAB_MENUS[i])
    end
    imgui.EndTabBar()
    state.IsWindowHovered = imgui.IsWindowHovered()
    imgui.End()
    
    saveVariables("globalVars", globalVars)
end

----------------------------------------------------------------------------------------- Tab stuff

-- Creates a menu tab
-- Parameters
--    globalVars : list of variables used globally across all menus [Table]
--    tabName    : name of the tab currently being created [String]
function createMenuTab(globalVars, tabName)
    if not imgui.BeginTabItem(tabName) then return end
    addPadding()
    if tabName == " Info"       then infoTab(globalVars) end
    if tabName == "Place Notes" then placeNotesTab(globalVars) end
    if tabName == "Edit Notes"  then editNotesTab(globalVars) end
    if tabName == "Extras"      then extrasTab(globalVars) end
    imgui.EndTabItem()
end
-- Creates the "Info" tab
-- Parameters
--    globalVars : list of variables used globally across all menus [Table]
function infoTab(globalVars)
    listShortcuts()
    showInfoLinks()
    choosePluginAppearance(globalVars)
end
-- Lists out keyboard shortcuts for the plugin
function listShortcuts()
    if not imgui.CollapsingHeader("Key Shortcuts") then return end
    local indentWidth = -6
    imgui.Indent(indentWidth)
    addSeparator()
    imgui.BulletText("T = activate the big button doing stuff")
    toolTip("Use this for a quick workflow")
    addPadding()
    imgui.BulletText("Ctrl + Shift + Tab = center plugin window")
    toolTip("Useful if the plugin begins or ends up offscreen")
    addSeparator()
    imgui.BulletText("Shift + Tab = focus plugin + navigate inputs")
    toolTip("Useful if you click off the plugin but want to quickly change an input value")
    addPadding()
    imgui.Unindent(indentWidth)
end
-- Explains to the user how to change default settings
function explainHowToChangeDefaults()
    imgui.TextDisabled("How to permanently change default settings?")
    if not imgui.IsItemHovered() then return end
    imgui.BeginTooltip()
    imgui.BulletText("Open the plugin file \"plugin.lua\" in a text editor or code editor")
    imgui.BulletText("Find the line with \"local globalVars = { \"")
    imgui.BulletText("Edit values in globalVars that correspond to a plugin setting")
    imgui.BulletText("Save the file with changes and reload the plugin")
    imgui.Text("Example: change \"colorThemeIndex = 1,\" to \"colorThemeIndex = 2,\"")
    imgui.EndTooltip()
end
-- Provides links relevant to the plugin
function showInfoLinks()
    if not imgui.CollapsingHeader("Links") then return end
    provideLink("GitHub Repository", "https://github.com/kloi34/VanillaChinchilla")
    provideLink("Chinchilla Photo", "https://www.facebook.com/cameronschinchillas/photos/a.678128788890667/1876978765672324/")
end
-- Lets you choose global plugin appearance settings
-- Parameters
--    globalVars : list of variables used globally across all menus [Table]
function choosePluginAppearance(globalVars)
    if not imgui.CollapsingHeader("Plugin Appearance") then return end
    addPadding()
    chooseStyleTheme(globalVars)
    chooseColorTheme(globalVars)
    addSeparator()
    explainHowToChangeDefaults()
end
-- Creates the "Place Notes" tab
-- Parameters
--    globalVars : list of variables used globally across all menus [Table]
function placeNotesTab(globalVars)
    --[[
    choosePlaceTool(globalVars)
    addSeparator()
    local toolName = PLACE_TOOLS[globalVars.placeToolIndex]
    --]]
    imgui.Text("Coming soon, check back on the GitHub page")
end
-- Creates the "Edit Notes" tab
-- Parameters
--    globalVars : list of variables used globally across all menus [Table]
function editNotesTab(globalVars)
    chooseEditTool(globalVars)
    addSeparator()
    local toolName = EDIT_TOOLS[globalVars.editToolIndex]
    if toolName == "Adjust LN Lengths"      then adjustLNLengthsMenu() end
    if toolName == "Shift Notes Left/Right" then shiftLeftRightMenu() end
    if toolName == "Shift Notes Up/Down"    then shiftUpDownMenu() end
    if toolName == "Flip Notes Vertically"  then flipVerticallyMenu() end
    if toolName == "Switch Note Lanes"      then switchNoteLanesMenu() end
end
-- Creates the "Extras" tab
-- Parameters
--    globalVars : list of variables used globally across all menus [Table]
function extrasTab(globalVars)
    imgui.Text("Coming soon, check back on the GitHub page")
end

--------------------------------------------------------------------------------------------- Menus

-- Creates the menu for adjusting LN lengths
function adjustLNLengthsMenu()
    local menuVars = {
        endRadio = false,
        msToMove = 1
    }
    getVariables("adjustLNLengthsMenu", menuVars)
    chooseWhichLNEnd(menuVars)
    addSeparator()
    chooseMilliseconds(menuVars)
    saveVariables("adjustLNLengthsMenu", menuVars)
    
    addSeparator()
    local enoughtNotesSelected = checkEnoughSelectedNotes(1)
    if not enoughtNotesSelected then imgui.Text("Select 1 or more notes") return end
    
    local buttonText = "Change selected notes' lengths by "
    if menuVars.msToMove > 0 then buttonText = buttonText.."+" end
    buttonText = buttonText..menuVars.msToMove.." ms"
    if menuVars.msToMove == 0 then buttonText = buttonText.." :jerry:" end
    button(buttonText, ACTION_BUTTON_SIZE, adjustLNLengths, nil, menuVars)
end
-- Creates the menu for shifting notes horizontally
function shiftLeftRightMenu()
    local menuVars = {
        rightRadio = false
    }
    getVariables("shiftLeftRightMenu", menuVars)
    chooseWhichSide(menuVars)
    saveVariables("shiftLeftRightMenu", menuVars)
    
    addSeparator()
    local enoughtNotesSelected = checkEnoughSelectedNotes(1)
    if not enoughtNotesSelected then imgui.Text("Select 1 or more notes") return end
    
    if menuVars.rightRadio then
        button("Shift selected notes right", ACTION_BUTTON_SIZE, shiftNotesRight, nil, nil)
    else
        button("Shift selected notes left", ACTION_BUTTON_SIZE, shiftNotesLeft, nil, nil)
    end
end
-- Creates the menu for shifting notes vertically
function shiftUpDownMenu()
    local menuVars = {
        msToMove = 1
    }
    getVariables("shiftUpDownMenu", menuVars)
    chooseMilliseconds(menuVars)
    saveVariables("shiftUpDownMenu", menuVars)
    
    addSeparator()
    local enoughtNotesSelected = checkEnoughSelectedNotes(1)
    if not enoughtNotesSelected then imgui.Text("Select 1 or more notes") return end
    
    local buttonText = "Shift selected notes by "
    if menuVars.msToMove > 0 then buttonText = buttonText.."+" end
    buttonText = buttonText..menuVars.msToMove.." ms"
    if menuVars.msToMove == 0 then buttonText = buttonText.." :jerry:" end
    button(buttonText, ACTION_BUTTON_SIZE, shiftNotesVertically, nil, menuVars)
end
-- Creates the menu for vertically flipping notes
function flipVerticallyMenu()
    local enoughtNotesSelected = checkEnoughSelectedNotes(1)
    if not enoughtNotesSelected then imgui.Text("Select 1 or more notes") return end
    
    local buttonText = "Flip selected notes vertically"
    button(buttonText, ACTION_BUTTON_SIZE, flipNotesVertically, nil, nil)
end
-- Creates the menu for switching notes' lanes
function switchNoteLanesMenu()
    local menuVars = {
        newLanes = enumeratedList(map.GetKeyCount()),
        selectedLaneIndexes = {}
    }
    getVariables("switchNoteLanesMenu", menuVars)
    displayOldLanesButtons()
    displayNewLanesButtons(menuVars)
    showSwappingLane(menuVars)
    
    addSeparator()
    randomizeNoteLanesButton(menuVars)
    imgui.SameLine(0, SAMELINE_SPACING)
    resetNoteLanesButton(menuVars)
    saveVariables("switchNoteLanesMenu", menuVars)
    
    addSeparator()
    local enoughtNotesSelected = checkEnoughSelectedNotes(1)
    if not enoughtNotesSelected then imgui.Text("Select 1 or more notes") return end
    
    local buttonText = "Switch selected notes from old to new lanes"
    button(buttonText, ACTION_BUTTON_SIZE, switchNoteLanes, nil, menuVars)
end

---------------------------------------------------------------------------------------------------
-- General Utility Functions ----------------------------------------------------------------------
---------------------------------------------------------------------------------------------------

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
-- Rounds a number to a given amount of decimal places
-- Returns the rounded number [Int/Float]
-- Parameters
--    number        : number to round [Int/Float]
--    decimalPlaces : number of decimal places to round the number to [Int]
function round(number, decimalPlaces)
    local multiplier = 10 ^ decimalPlaces
    return math.floor(number * multiplier + 0.5) / multiplier
end
-- Creates a button that can also be activated when 'T' is pressed
-- Parameters
--    text       : text on the button [String]
--    size       : dimensions of the button [Table: {width, height}]
--    func       : function to execute once button is pressed [Function]
--    globalVars : list of variables used globally across all menus [Table]
--    menuVars   : list of variables used for the current menu [Table]
function button(text, size, func, globalVars, menuVars)
    if not (imgui.Button(text, size) or utils.IsKeyPressed(keys.T)) then return end
    if globalVars and menuVars then func(globalVars, menuVars) return end
    if globalVars then func(globalVars) return end
    if menuVars then func(menuVars) return end
    func()
end
-- Checks to see if enough notes are selected
-- Returns whether or not there are enough notes [Boolean]
-- Parameters
--    minimumNotes : minimum number of notes needed to select [Int]
function checkEnoughSelectedNotes(minimumNotes)
    local selectedNotes = state.SelectedHitObjects
    local numSelectedNotes = #selectedNotes
    if numSelectedNotes == 0 then return false end
    if numSelectedNotes > map.GetKeyCount() then return true end
    if minimumNotes == 1 then return true end
    return selectedNotes[1].StartTime ~= selectedNotes[numSelectedNotes].StartTime
end
-- Returns an ascending list of whole numbers starting from 1 [Table]
-- Parameters
--    number : final number in the list (1 to number) [Int]
function enumeratedList(number)
    local numbersList = {}
    for i = 1, number do
        numbersList[i] = i
    end
    return numbersList
end

---------------------------------------------------------------------------------------------------
-- Choose Functions (Sorted Alphabetically) -------------------------------------------------------
---------------------------------------------------------------------------------------------------

-- Lets you choose the color theme of the plugin
-- Parameters
--    globalVars : list of variables used globally across all menus [Table]
function chooseColorTheme(globalVars)
    local comboIndex = globalVars.colorThemeIndex - 1
    _, comboIndex = imgui.Combo("Color Theme", comboIndex, COLOR_THEMES, #COLOR_THEMES)
    globalVars.colorThemeIndex = comboIndex + 1
    local currentTheme = COLOR_THEMES[globalVars.colorThemeIndex]
    local isRGBColorTheme = currentTheme == "Glass + RGB" or  
                            currentTheme == "Incognito + RGB" or
                            currentTheme == "RGB Gamer Mode"
    if not isRGBColorTheme then return end
    chooseRGBPeriod(globalVars)
end
-- Lets you choose which note-editing tool to use
-- Parameters
--    globalVars : list of variables used globally across all menus [Table]
function chooseEditTool(globalVars)
    imgui.AlignTextToFramePadding()
    imgui.Text("Current Tool:")
    imgui.SameLine(0, SAMELINE_SPACING)
    local comboIndex =  globalVars.editToolIndex - 1
    _, comboIndex = imgui.Combo("##edittool", comboIndex, EDIT_TOOLS, #EDIT_TOOLS)
    globalVars.editToolIndex = comboIndex + 1
end
-- Lets you choose an integer number of milliseconds (to move)
-- Parameters
--    menuVars : list of variables used for the current menu [Table]
function chooseMilliseconds(menuVars)
    _, menuVars.msToMove = imgui.InputInt("Milliseconds", menuVars.msToMove, 1, 1)
end
-- Lets you choose which note-placing tool to use
-- Parameters
--    globalVars : list of variables used globally across all menus [Table]
function choosePlaceTool(globalVars)
    imgui.AlignTextToFramePadding()
    imgui.Text("Current Tool:")
    imgui.SameLine(0, SAMELINE_SPACING)
    local comboIndex =  globalVars.placeToolIndex - 1
    _, comboIndex = imgui.Combo("##placetool", comboIndex, PLACE_TOOLS, #PLACE_TOOLS)
    globalVars.placeToolIndex = comboIndex + 1
end
-- Lets you choose the length in seconds of one RGB color cycle
-- Parameters
--    globalVars : list of variables used globally across all menus [Table]
function chooseRGBPeriod(globalVars)
    _, globalVars.rgbPeriod = imgui.InputFloat("RGB cycle length", globalVars.rgbPeriod, 0, 0,
                                               "%.0f seconds")
    globalVars.rgbPeriod = clampToInterval(globalVars.rgbPeriod, MINIMUM_RGB_CYCLE_TIME,
                                            MAXIMUM_RGB_CYCLE_TIME)
end
-- Lets you choose the style theme of the plugin
-- Parameters
--    globalVars : list of variables used globally across all menus [Table]
function chooseStyleTheme(globalVars)
    local comboIndex = globalVars.styleThemeIndex - 1
    _, comboIndex = imgui.Combo("Style Theme", comboIndex, STYLE_THEMES, #STYLE_THEMES)
    globalVars.styleThemeIndex = comboIndex + 1
end
-- Lets you choose LN start or LN end
-- Parameters
--    menuVars : list of variables used for the current menu [Table]
function chooseWhichLNEnd(menuVars)
    imgui.AlignTextToFramePadding()
    imgui.Text("Keep in place: ")
    imgui.SameLine(0, SAMELINE_SPACING)
    if imgui.RadioButton("LN Start", not menuVars.endRadio) then menuVars.endRadio = false end
    imgui.SameLine(0, RADIO_BUTTON_SPACING)
    if imgui.RadioButton("LN End", menuVars.endRadio) then menuVars.endRadio = true end
end
-- Lets you choose a side (left or right)
-- Parameters
--    menuVars : list of variables used for the current menu [Table]
function chooseWhichSide(menuVars)
    imgui.AlignTextToFramePadding()
    imgui.Text("Shift notes one lane")
    imgui.SameLine(0, SAMELINE_SPACING)
    if imgui.RadioButton("Left", not menuVars.rightRadio) then menuVars.rightRadio = false end
    imgui.SameLine(0, RADIO_BUTTON_SPACING)
    if imgui.RadioButton("Right", menuVars.rightRadio) then menuVars.rightRadio = true end
end
---------------------------------------------------------------------------------------------------
-- Do-er Functions --------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------

-- Changes selected notes' lengths (note end times) by a specified amount
-- Parameters
--    menuVars : list of variables used for the "Stretch Notes" menu [Table]
function adjustLNLengths(menuVars)
    local msToMove = menuVars.msToMove
    local keepLNEndInPlace = menuVars.endRadio
    if msToMove == 0 then return end
    local notesToRemove = state.SelectedHitObjects
    local notesToAdd = {}
    for _, note in pairs(notesToRemove) do
        local isRiceNote = note.EndTime == 0
        local newStartTime = note.StartTime
        local newEndTime = note.EndTime
        if keepLNEndInPlace then
            newStartTime = newStartTime - msToMove
            if isRiceNote then
                newEndTime = note.StartTime
            end
            if newStartTime >= newEndTime then
                newEndTime = 0
                if not isRiceNote then
                    newStartTime = note.EndTime
                else
                    newStartTime = note.StartTime
                end
            end
        else
            newEndTime = newEndTime + msToMove
            if isRiceNote then
                newEndTime = note.StartTime + msToMove
            end
            if newEndTime <= note.StartTime then
                newEndTime = 0
            end
        end
        table.insert(notesToAdd, utils.CreateHitObject(newStartTime, note.Lane, newEndTime,
                                                       note.HitSound, note.EditorLayer))
    end
    removeAndAddNotes(notesToRemove, notesToAdd)
end
-- Shift selected notes left one lane
function shiftNotesLeft()
    shiftNotesHorizontally(-1)
end
-- Shift selected notes right one lane
function shiftNotesRight()
    shiftNotesHorizontally(1)
end
-- Shifts selected notes horizontally across lane(s)
-- Parameters
--    laneShift : amount of lanes and direction to shift notes by [Int]
function shiftNotesHorizontally(laneShift)
    local notesToRemove = state.SelectedHitObjects
    local notesToAdd = {}
    local totalNumLanes = map.GetKeyCount()
    for _, note in pairs(notesToRemove) do
        local newLane = ((note.Lane + laneShift - 1) % totalNumLanes) + 1
        table.insert(notesToAdd, utils.CreateHitObject(note.StartTime, newLane, note.EndTime,
                                                       note.HitSound, note.EditorLayer))
    end
    removeAndAddNotes(notesToRemove, notesToAdd)
end
-- Shifts selected notes down or up by a specified amount
-- Parameters
--    menuVars : list of variables used for the "Shift Notes Up/Down" menu [Table]
function shiftNotesVertically(menuVars)
    local msToMove = menuVars.msToMove
    if msToMove == 0 then return end
    local notesToRemove = state.SelectedHitObjects
    local notesToAdd = {}
    for _, note in pairs(notesToRemove) do
        local newStartTime = note.StartTime + msToMove
        local newEndTime = note.EndTime
        if note.EndTime ~= 0 then newEndTime = note.EndTime + msToMove end
        table.insert(notesToAdd, utils.CreateHitObject(newStartTime, note.Lane, newEndTime,
                                                       note.HitSound, note.EditorLayer))
    end
    removeAndAddNotes(notesToRemove, notesToAdd)
end
-- Flips selected notes vertically
function flipNotesVertically()
    local notesToRemove = state.SelectedHitObjects
    local notesToAdd = {}
    local boundaryTimes = findMinMaxTime(notesToRemove)
    local midPoint = (boundaryTimes.max + boundaryTimes.min) / 2
    for _, note in pairs(notesToRemove) do
        local noteIsLN = note.EndTime ~= 0
        local newStartTime = 2 * midPoint - note.StartTime
        local newEndTime = 0
        if noteIsLN then
            newEndTime = 2 * midPoint - note.StartTime
            newStartTime = 2 * midPoint - note.EndTime
        end
        table.insert(notesToAdd, utils.CreateHitObject(newStartTime, note.Lane, newEndTime,
                                                       note.HitSound, note.EditorLayer))
    end
    removeAndAddNotes(notesToRemove, notesToAdd)
end
-- Returns a table of minimum and maximum times of a list of notes [Table]
-- Parameters
--    notes : notes to find minimum and maximum times of [Table]
function findMinMaxTime(notes)
    local min = math.huge
    local max = -math.huge
    for _, note in pairs(notes) do
        min = math.min(note.StartTime, min)
        max = math.max(note.StartTime, max)
        if note.EndTime ~= 0 then
            max = math.max(note.EndTime, max)
        end
    end
    return {min = min, max = max}
end
-- Switches the lanes/columns of the selected notes
-- Parameters
--    menuVars : list of variables used for the "Switch Note Lanes" menu [Table]
function switchNoteLanes(menuVars)
    local notesToRemove = state.SelectedHitObjects
    local notesToAdd = {}
    local reverseLookupLane = {}
    for i = 1, #menuVars.newLanes do
        local newLaneValue = menuVars.newLanes[i]
        reverseLookupLane[newLaneValue] = i
    end
    for _, note in pairs(notesToRemove) do
        local newLane = reverseLookupLane[note.Lane]
        table.insert(notesToAdd, utils.CreateHitObject(note.StartTime, newLane, note.EndTime,
                                                       note.HitSound, note.EditorLayer))
    end
    removeAndAddNotes(notesToRemove, notesToAdd)
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

---------------------------------------------------------------------------------------------------
-- Other Functions --------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------

-- Creates a button that randomizes new lanes to switch to
-- Parameters
--    menuVars : list of variables used for the "Switch Note Lanes" menu [Table]
function randomizeNoteLanesButton(menuVars)
    if not imgui.Button("Randomize", HALF_BUTTON_SIZE) then return end
    local lanes = enumeratedList(map.GetKeyCount())
    menuVars.newLanes = {}
    while #lanes > 0 do
        table.insert(menuVars.newLanes, table.remove(lanes, math.random(1, #lanes)))
    end
end

-- Creates a button that resets the new lanes to switch to
-- Parameters
--    menuVars : list of variables used for the "Switch Note Lanes" menu [Table]
function resetNoteLanesButton(menuVars)
    if not imgui.Button("Reset", HALF_BUTTON_SIZE) then return end
    menuVars.newLanes = enumeratedList(map.GetKeyCount())
end
-- Creates buttons that show the old lane order
function displayOldLanesButtons()
    for i = 1, map.GetKeyCount() do
        imgui.Button(i.."##1", LANE_BUTTON_SIZE)
        imgui.SameLine(0, SAMELINE_SPACING)
    end
    helpMarker("Old lane order (top)\nNew lane order (bottom)\nClick on new lane order buttons "..
               "to switch lanes")
    local indentAmount = (map.GetKeyCount() + 0.7) * LANE_BUTTON_SIZE[1] / 2
    imgui.Indent(indentAmount)
    imgui.Text("V")
    imgui.Unindent(indentAmount)
end
-- Creates buttons that show the new lane order and can be switched around
-- Parameters
--    menuVars : list of variables used for the "Switch Note Lanes" menu [Table]
function displayNewLanesButtons(menuVars)
    for i = 1, map.GetKeyCount() do
        if i ~= 1 then imgui.SameLine(0, SAMELINE_SPACING) end
        newLaneButton(menuVars, i)
    end
end
-- Creates a new lane button
-- Parameters
--    menuVars : list of variables used for the "Switch Note Lanes" menu [Table]
--    i        : current new lane button number to create [Int]
function newLaneButton(menuVars, i)
    local currentLane = menuVars.newLanes[i]
    if not imgui.Button(currentLane.."##2", LANE_BUTTON_SIZE) then return end
    
    table.insert(menuVars.selectedLaneIndexes, i)
    if #menuVars.selectedLaneIndexes < 2 then return end
    
    local lanePosition1 = menuVars.selectedLaneIndexes[1]
    local lanePosition2 = menuVars.selectedLaneIndexes[2]
    local firstLane = menuVars.newLanes[lanePosition1]
    local secondLane = menuVars.newLanes[lanePosition2]
    menuVars.newLanes[lanePosition1] = secondLane
    menuVars.newLanes[lanePosition2] = firstLane
    menuVars.selectedLaneIndexes = {}
end
-- Shows the lane currently being swapped
-- Parameters
--    menuVars : list of variables used for the "Switch Note Lanes" menu [Table]
function showSwappingLane(menuVars)
    if #menuVars.selectedLaneIndexes == 0 then return end
    imgui.BeginTooltip()
    imgui.Button(menuVars.newLanes[menuVars.selectedLaneIndexes[1]], LANE_BUTTON_SIZE)
    imgui.EndTooltip()
end