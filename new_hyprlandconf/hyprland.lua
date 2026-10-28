-- ~/.config/hypr/hyprland.lua — native Hyprland Lua configuration

-- Change these if you use different applications.
local terminal = "kitty"
local file_manager = "nemo"
local mod = "SUPER + "

-- Monitor
hl.monitor({
    output = "DP-2",
    mode = "1920x1080@170",
    position = "0x0",
    scale = "auto",
})

-- Read nwg-look's XCursor settings; GTK 4 overrides GTK 3 when both exist.
local config_dir = os.getenv("XDG_CONFIG_HOME") or (os.getenv("HOME") .. "/.config")
local cursor_theme, cursor_size = "BreezeX-Black", "24"

for _, gtk in ipairs({ "gtk-3.0", "gtk-4.0" }) do
    local file = io.open(config_dir .. "/" .. gtk .. "/settings.ini", "r")
    if file then
        for line in file:lines() do
            local key, value = line:match("^%s*([%w%-]+)%s*=%s*(.-)%s*$")
            if key == "gtk-cursor-theme-name" and value ~= "" then
                cursor_theme = value
            elseif key == "gtk-cursor-theme-size" and value:match("^%d+$") then
                if tonumber(value) > 0 then cursor_size = value end
            end
        end
        file:close()
    end
end

hl.env("XCURSOR_THEME", cursor_theme)
hl.env("XCURSOR_SIZE", cursor_size)

-- Settings
hl.config({
    input = {
        kb_layout = "no,ru",
        follow_mouse = 1,
        sensitivity = 0,
        accel_profile = "flat",
        force_no_accel = true,
        touchpad = { natural_scroll = false },
    },
    cursor = {
        enable_hyprcursor = false, -- Use the XCursor theme selected in nwg-look.
    },
    misc = {
        disable_hyprland_logo = true,
        disable_splash_rendering = true,
    },
    general = {
        gaps_in = 5,
        gaps_out = 10,
        border_size = 2,
        layout = "dwindle",

        col = {
            active_border = "rgb(268bd2)",
            inactive_border = "rgb(1a1a1a)",
        },
            },
    decoration = {
        rounding = 5,
        active_opacity = 1.0,
        inactive_opacity = 1.0,
        blur = {
            enabled = true,
            size = 10,
            passes = 1,
            new_optimizations = true,
        },
        shadow = {
            enabled = true,
            range = 4,
            offset = { 2, 2 },
            render_power = 2,
            color = 0x66000000,
        },
    },
    animations = { enabled = true },
    dwindle = { preserve_split = true },
    master = { new_status = "master", new_on_top = true },
})

-- Startup: runs once per session, not on config reload.
hl.on("hyprland.start", function()
    -- Import the environment before starting the authentication agent.
    hl.exec_cmd([[dbus-update-activation-environment --systemd WAYLAND_DISPLAY XDG_CURRENT_DESKTOP; systemctl --user start hyprpolkitagent]])
    for _, command in ipairs({
        "gnome-keyring-daemon --start --components=secrets",
        "nm-applet --indicator",
        "waybar",
        "swaync",
        "waytrogen --restore",
        "google-chrome-stable --restore-last-session",
        "spotify",
    }) do
        hl.exec_cmd(command)
    end
end)

-- Keyboard and mouse shortcuts
hl.bind("F2", hl.dsp.exec_cmd("~/.config/hypr/scripts/toggle-waybar.sh"))
hl.bind("F3", hl.dsp.exec_cmd("hyprctl switchxkblayout all next"))
hl.bind("F11", hl.dsp.exec_cmd("hyprshot -m region"))
hl.bind("F12", hl.dsp.exec_cmd("hyprlock"))

hl.bind(mod .. "Q", hl.dsp.exec_cmd(terminal))
hl.bind(mod .. "E", hl.dsp.exec_cmd(file_manager))
hl.bind(mod .. "space", hl.dsp.exec_cmd("rofi -show drun"))
hl.bind(mod .. "C", hl.dsp.window.close())
hl.bind(mod .. "F", hl.dsp.window.fullscreen({ action = "toggle" }))
hl.bind(mod .. "V", hl.dsp.window.float({ action = "toggle" }))
hl.bind(mod .. "P", hl.dsp.window.pseudo())
hl.bind(mod .. "SHIFT + J", hl.dsp.layout("togglesplit"))
hl.bind(mod .. "M", hl.dsp.exec_cmd(
    [[if command -v hyprshutdown >/dev/null 2>&1; then hyprshutdown; else hyprctl dispatch 'hl.dsp.exit()'; fi]]
))

-- Focus with Super + H/J/K/L.
hl.bind(mod .. "h", hl.dsp.focus({ direction = "left" }))
hl.bind(mod .. "l", hl.dsp.focus({ direction = "right" }))
hl.bind(mod .. "k", hl.dsp.focus({ direction = "up" }))
hl.bind(mod .. "j", hl.dsp.focus({ direction = "down" }))

-- Super + number: switch workspace. Add Shift to move the active window.
for workspace = 1, 10 do
    local key = tostring(workspace % 10)
    hl.bind(mod .. key, hl.dsp.focus({ workspace = workspace }))
    hl.bind(mod .. "SHIFT + " .. key, hl.dsp.window.move({ workspace = workspace }))
end

hl.bind(mod .. "S", hl.dsp.workspace.toggle_special("magic"))
hl.bind(mod .. "SHIFT + S", hl.dsp.window.move({ workspace = "special:magic" }))
hl.bind(mod .. "mouse_down", hl.dsp.focus({ workspace = "e+1" }))
hl.bind(mod .. "mouse_up", hl.dsp.focus({ workspace = "e-1" }))
hl.bind(mod .. "mouse:272", hl.dsp.window.drag(), { mouse = true })
hl.bind(mod .. "mouse:273", hl.dsp.window.resize(), { mouse = true })

-- Media keys. Only volume and brightness adjustments repeat while held.
for _, bind in ipairs({
    { "XF86AudioRaiseVolume", "wpctl set-volume -l 1 @DEFAULT_AUDIO_SINK@ 5%+", true },
    { "XF86AudioLowerVolume", "wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-", true },
    { "XF86AudioMute", "wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle" },
    { "XF86AudioMicMute", "wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle" },
    { "XF86MonBrightnessUp", "brightnessctl -e4 -n2 set 5%+", true },
    { "XF86MonBrightnessDown", "brightnessctl -e4 -n2 set 5%-", true },
    { "XF86AudioNext", "playerctl next" },
    { "XF86AudioPause", "playerctl play-pause" },
    { "XF86AudioPlay", "playerctl play-pause" },
    { "XF86AudioPrev", "playerctl previous" },
}) do
    hl.bind(bind[1], hl.dsp.exec_cmd(bind[2]), {
        locked = true,
        repeating = bind[3] == true,
    })
end

hl.gesture({ fingers = 3, direction = "horizontal", action = "workspace" })

-- Animations
hl.curve("myBezier", {
    type = "bezier",
    points = { { 0.05, 0.9 }, { 0.1, 1.05 } },
})
hl.animation({ leaf = "windows", enabled = true, speed = 7, bezier = "myBezier" })
hl.animation({ leaf = "windowsOut", enabled = true, speed = 7, bezier = "default", style = "popin 80%" })
hl.animation({ leaf = "border", enabled = true, speed = 10, bezier = "default" })
hl.animation({ leaf = "borderangle", enabled = true, speed = 8, bezier = "default" })
hl.animation({ leaf = "fade", enabled = true, speed = 7, bezier = "default" })
hl.animation({ leaf = "workspaces", enabled = true, speed = 6, bezier = "default" })

-- Windows and workspaces
-- Normal apps use the dwindle layout and share the current workspace's space.
-- Do not force file managers, viewers, or all .exe windows to float.
hl.window_rule({
    name = "suppress-maximize-events",
    match = { class = ".*" },
    suppress_event = "maximize",
})

hl.window_rule({
    name = "fix-xwayland-drags",
    match = {
        class = "^$",
        title = "^$",
        xwayland = true,
        float = true,
        fullscreen = false,
        pin = false,
    },
    no_focus = true,
})

-- Only dialogs, the launcher, and these small utility windows float.
hl.window_rule({ match = { modal = true }, float = true })
hl.window_rule({ match = { class = "^(floating|Rofi|pavucontrol(-qt)?)$" }, float = true })
hl.window_rule({ match = { float = true }, border_size = 0 })

local floating_titles = {
    "Open File", "branchdialog", "Volume Control", "Picture-in-Picture",
    "Firefox — Sharing Indicator",
}
for _, title in ipairs(floating_titles) do
    hl.window_rule({ match = { title = title }, float = true })
end

hl.window_rule({ match = { class = "Rofi" }, no_anim = true })
hl.window_rule({ match = { class = "wlogout" }, fullscreen = true })
hl.window_rule({ match = { title = "wlogout" }, fullscreen = true })
hl.window_rule({ match = { class = "mpv" }, idle_inhibit = "focus" })
hl.window_rule({ match = { class = "firefox" }, idle_inhibit = "fullscreen" })
hl.window_rule({ match = { title = "Firefox — Sharing Indicator" }, move = { 0, 0 } })
hl.window_rule({
    match = { title = "Volume Control" },
    size = { 800, 600 },
    move = { 75, "monitor_h*0.44" },
})

-- JetBrains popups should not steal focus; Toolbox is exempt.
hl.window_rule({
    match = { class = "jetbrains-.*", float = true, title = "win[0-9]+" },
    no_focus = true,
})
hl.window_rule({
    match = { class = "jetbrains-toolbox.*", float = true, title = "win[0-9]+" },
    no_focus = false,
})

