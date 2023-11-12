-- VanillaChinchilla v0.0 Beta (11 November 2023)
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
SECONDARY_BUTTON_SIZE = {          -- dimensions of a button that does less important things
    0.3 * DEFAULT_WIDGET_WIDTH,
    DEFAULT_WIDGET_HEIGHT - 2
}

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
    "Chocolate",
    "Cookie Dough",
    "Vanilla",
    "Incognito",
    "Incognito + RGB",
    "Glass",
    "Glass + RGB",
    "RGB Gamer Mode"
}

TAB_MENUS = {                      -- tab names for different SV menus
    "Settings + Info",
    "Place Notes",
    "Edit Notes"
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
    local percentIntoStage = clampToInterval(percentIntoCycle * 6 - stageNumberIntoCycle, 0, 1)
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
    if colorTheme == "Chocolate" then
        imgui.PushStyleColor( imgui_col.WindowBg,               { 0.00, 0.00, 0.00, 1.00 } )
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
    elseif colorTheme == "Cookie Dough" then
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
    elseif colorTheme == "Vanilla" then
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
        colorThemeIndex = 1,
        styleThemeIndex = 1,
        rgbPeriod = 30,
        debugText = "debuggy capybara"
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
    if tabName == "Settings + Info" then settingsAndInfoTab(globalVars) end
    if tabName == "Place Notes"     then placeNotesTab(globalVars) end
    if tabName == "Edit Notes"      then editNotesTab(globalVars) end
    imgui.EndTabItem()
end
-- Creates the "Settings + Info" tab
-- Parameters
--    globalVars : list of variables used globally across all menus [Table]
function settingsAndInfoTab(globalVars)
    listShortcuts()
    showInfoLinks()
    choosePluginAppearance(globalVars)
end
-- Lists out keyboard shortcuts for the plugin
function listShortcuts()
    if not imgui.CollapsingHeader("Key Shortcuts") then return end
    local indentWidth = -6
    imgui.Indent(indentWidth)
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
    provideLink("Capybara Photo", "https://www.flickr.com/photos/wwarby/19609144476")
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
    imgui.Text(globalVars.debugText)
end
-- Creates the "Edit Notes" tab
-- Parameters
--    globalVars : list of variables used globally across all menus [Table]
function editNotesTab(globalVars)
    imgui.Text(globalVars.debugText)
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