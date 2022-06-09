local gears = require("gears")
require("gears.surface")
local awful = require("awful")
require("awful.autofocus")
local wibox = require("wibox")
local beautiful = require("beautiful")
local naughty = require("naughty")
local menubar = require("menubar")
if awesome.startup_errors then
  naughty.notify({preset = naughty.config.presets.critical, title = "Oops, there were errors during startup!", text = awesome.startup_errors})
else
end
do
  local in_error = false
  local function _2_(err)
    if in_error then
      return nil
    else
      local in_error0 = true
      return naughty.notify({preset = naughty.config.presets.critical, title = "Oops, an error happened!", text = tostring(err)})
    end
  end
  awesome.connect_signal("debug::error", _2_)
end
beautiful.init((gears.filesystem.get_themes_dir() .. "zenburn/theme.lua"))
local terminal = "emacsclient -e '(shell)'"
local editor = "emacsclient"
local editor_cmd = "emacsclient"
local modkey = "Mod4"
local fnlconf = "~/.config/awesome/rc.fnl"
awful["layout"]["layouts"] = {awful.layout.suit.tile.right, awful.layout.suit.tile.top, awful.layout.suit.max, awful.layout.suit.floating}
local function preferred_layout(s)
  naughty.notify({text = ("width " .. s.geometry.width .. " height " .. s.geometry.height)})
  if (s.geometry.width >= s.geometry.height) then
    return 1
  else
    return 2
  end
end
local menu
local function _5_()
  return awful.spawn("emacs")
end
local function _6_()
  return awful.spawn("firefox")
end
local function _7_()
  return awful.spawn("zathura")
end
local function _8_()
  return awful.spawn("discord")
end
menu = {{"quit", awesome.quit}, {"restart", awesome.restart}, {"edit config", (editor_cmd .. " " .. fnlconf)}, {"Emacs", _5_}, {"Firefox", _6_}, {"Zathura", _7_}, {"Discord", _8_}}
local my_perm_tags = {"E", "F", "Z", "D"}
local function set_wallpaper(s)
  return os.execute("/home/samueltwallace/.local/bin/fehbg")
end
local mylauncher = awful.widget.launcher({image = beautiful.awesome_icon, menu = awful.menu({items = menu})})
local batt_bar = wibox.widget({widget = wibox.widget.progressbar, forced_width = 200, shape = gears.shape.rounded_bar, bar_shape = gears.shape.rounded_bar, background_color = "yellow"})
local batt_hover
local function _9_()
  local batt_proc = io.popen("bash -c 'acpi -b'")
  local batt_str = batt_proc:read("*a")
  batt_proc:close()
  return batt_str
end
batt_hover = awful.tooltip({objects = {batt_bar}, timer_function = _9_})
local mytextclock = wibox.widget.textclock()
local taglist_buttons
local function _10_(t)
  return t:view_only()
end
taglist_buttons = gears.table.join(awful.button({}, 1, _10_), awful.button({}, 3, awful.tag.viewtoggle))
local batt_low = false
local batt_thresh = 0.25
local weather_box = wibox.widget({widget = wibox.widget.textbox, text = "No weather right now"})
local function _11_(s)
  set_wallpaper(s)
  awful.tag(my_perm_tags, s, awful.layout.layouts[preferred_layout(s)])
  do end (s)["mypromptbox"] = awful.widget.prompt()
  do end (s)["mylayoutbox"] = awful.widget.layoutbox(s)
  local function _12_()
    return awful.layout.inc(1)
  end
  do end (s.mylayoutbox):buttons(awful.button({}, 1, _12_))
  do end (s)["mytaglist"] = awful.widget.taglist({screen = s, filter = awful.widget.taglist.filter.noempty, buttons = taglist_buttons})
  do end (s)["mytasklist"] = awful.widget.tasklist({screen = s, filter = awful.widget.tasklist.filter.currenttags})
  do end (s)["mywibox"] = awful.wibar({position = "top", screen = s})
  local function _13_(widget, stdout)
    widget["text"] = stdout
    return nil
  end
  local function _14_(widget, stdout)
    local batt_percent = (tonumber(string.match(stdout, "(%d+)%%")) / 100)
    widget:set_value(batt_percent)
    if ((batt_percent < batt_thresh) and not batt_low) then
      naughty.notify({title = "Battery Low!", preset = naughty.config.presets.critical})
      batt_low = true
    else
    end
    if (batt_percent < batt_thresh) then
      widget["color"] = "red"
      return nil
    else
      widget["color"] = "green"
      batt_low = false
      return nil
    end
  end
  return (s.mywibox):setup({layout = wibox.layout.align.horizontal, {layout = wibox.layout.fixed.horizontal, mylauncher, s.mytaglist, s.mypromptbox}, s.mytasklist, {layout = wibox.layout.fixed.horizontal, awful.widget.watch("bash -c 'curl -s https://wttr.in/chicago?format=3'", 600, _13_, weather_box), wibox.widget.systray(), awful.widget.watch("bash -c 'acpi -b'", 30, _14_, batt_bar), mytextclock, s.mylayoutbox}})
end
awful.screen.connect_for_each_screen(_11_)
local globalkeys
local function _17_()
  return awful.client.focus.byidx(1)
end
local function _18_()
  return awful.client.focus.byidx(-1)
end
local function _19_()
  return awful.client.swap.byidx(1)
end
local function _20_()
  return awful.client.swap.byidx(-1)
end
local function _21_()
  return awful.screen.focus_relative(1)
end
local function _22_()
  return awful.spawn("i3lock -c 000000")
end
local function _23_()
  return menubar.show()
end
globalkeys = gears.table.join(awful.key({modkey}, "Left", awful.tag.viewprev), awful.key({modkey}, "Right", awful.tag.viewnext), awful.key({modkey}, "Escape", awful.tag.history.restore), awful.key({modkey}, "j", _17_), awful.key({modkey}, "k", _18_), awful.key({modkey, "Control"}, "r", awesome.restart), awful.key({modkey, "Shift"}, "j", _19_), awful.key({modkey, "Shift"}, "k", _20_), awful.key({modkey}, "Tab", _21_), awful.key({modkey}, "u", awful.client.urgent.jumpto), awful.key({modkey}, "g", _22_), awful.key({modkey}, "space", _23_))
local clientkeys
local function _24_(c)
  return c:move_to_screen()
end
local function _25_(c)
  c["fullscreen"] = not c.fullscreen
  return c:raise()
end
clientkeys = gears.table.join(awful.key({modkey, "Shift"}, "Tab", _24_), awful.key({modkey}, "f", _25_))
for idx, tag_name in pairs(my_perm_tags) do
  local function _26_()
    local screen = awful.screen.focused()
    local tag = screen.tags[idx]
    if tag then
      return tag:view_only()
    else
      return nil
    end
  end
  local function _28_()
    local screen = awful.screen.focused()
    local tag = screen.tags[idx]
    if tag then
      return awful.tag.viewtoggle(tag)
    else
      return nil
    end
  end
  local function _30_()
    if client.focus then
      local tag = client.focus.screen.tags[i]
      if tag then
        return (client.focus):move_to_tag(tag)
      else
        return nil
      end
    else
      return nil
    end
  end
  globalkeys = gears.table.join(globalkeys, awful.key({modkey}, ("#" .. (idx + 9)), _26_), awful.key({modkey, "Control"}, ("#" .. (idx + 9)), _28_), awful.key({modkey, "Shift"}, ("#" .. (idx + 9)), _30_))
end
root.keys(globalkeys)
do end (awful.rules)["rules"] = {{rule = {}, properties = {border_width = beautiful.border_width, border_color = beautiful.border_normal, focus = awful.client.focus.filter, raise = true, keys = clientkeys, screen = awful.screen.preferred, placement = (awful.placement.no_overlap + awful.placement.no_offscreen)}}, {rule = {class = "Emacs"}, properties = {screen = screen.count(), tag = "E"}}, {rule = {class = "firefox"}, properties = {tag = "F"}}, {rule = {class = "Zathura"}, properties = {tag = "Z"}}, {rule = {class = "discord"}, properties = {tag = "D"}}}
local function _33_(c)
  if (awesome.startup and not c.size_hints.user_position and not c.size_hints.program_position) then
    awful.placement.no_offscreen(c)
  else
  end
  if not ((c.class == "Emacs") or (c.class == "Zathura") or (c.class == "firefox") or (c.class == "discord")) then
    local t = awful.tag.add(c.class, {screen = c.screen, icon = gears.surface.duplicate_surface(c.icon)})
    return c:tags({t})
  else
    return nil
  end
end
client.connect_signal("manage", _33_)
local function is_tag_by_name(tag, name)
  return (tag == awful.tag.find_by_name(awful.screen.focused(), name))
end
local function _36_(c)
  for _, tag in ipairs(c.screen.tags) do
    if not (tag:clients()[1] or is_tag_by_name(tag, "E") or is_tag_by_name(tag, "F") or is_tag_by_name(tag, "Z") or is_tag_by_name(tag, "D")) then
      tag:delete()
      naughty.notify({text = ("tag " .. tag.name .. " deleted!"), preset = naughty.config.presets.critical})
    else
    end
  end
  return nil
end
client.connect_signal("unmanage", _36_)
local function _38_(c)
  c:emit_signal("request::activate", "mouse_enter", {raise = false})
  return nil
end
client.connect_signal("mouse::enter", _38_)
return awful.spawn("pgrep emacs || emacs")
