local function dist_table_prefix(bigtbl, names)
  local tbl_15_auto = {}
  local i_16_auto = #tbl_15_auto
  for _, name in ipairs(names) do
    local val_17_auto
    if (type(name) == "table") then
      val_17_auto = bigtbl[table.unpack(name)]
    else
      val_17_auto = bigtbl[name]
    end
    if (nil ~= val_17_auto) then
      i_16_auto = (i_16_auto + 1)
      do end (tbl_15_auto)[i_16_auto] = val_17_auto
    else
    end
  end
  return tbl_15_auto
end
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
  local function _4_(err)
    if in_error then
      return nil
    else
      local in_error0 = true
      return naughty.notify({preset = naughty.config.presets.critical, title = "Oops, an error happened!", text = tostring(err)})
    end
  end
  awesome.connect_signal("debug::error", _4_)
end
beautiful.init((gears.filesystem.get_themes_dir() .. "zenburn/theme.lua"))
local terminal = "emacsclient -e '(shell)'"
local editor = "emacsclient"
local editor_cmd = "emacsclient"
local modkey = "Mod4"
local fnlconf = "~/.config/awesome/rc.fnl"
awful.layout.layouts = dist_table_prefix(awful.layout.suit, {{"tile", "right"}, "max", "floating"})
local menu
local function _6_()
  return awful.spawn("emacs")
end
local function _7_()
  return awful.spawn("firefox")
end
local function _8_()
  return awful.spawn("zathura")
end
local function _9_()
  return awful.spawn("discord")
end
menu = {{"quit", awesome.quit}, {"restart", awesome.restart}, {"edit config", (editor_cmd .. " " .. fnlconf)}, {"Emacs", _6_}, {"Firefox", _7_}, {"Zathura", _8_}, {"Discord", _9_}}
local myawesomemenu = table.insert(menu, {"restart", awesome.restart})
local mymainmenu = awful.menu({items = menu})
local mylauncher = awful.widget.launcher({image = beautiful.awesome_icon, menu = mymainmenu})
menubar.utils.terminal = terminal
local function set_wallpaper(s)
  return os.execute("/home/samueltwallace/.local/bin/fehbg")
end
local my_tags = {"E", "F", "Z", "D"}
screen.connect_signal("property::geometry", set_wallpaper)
local batt_bar = wibox.widget({widget = wibox.widget.progressbar, forced_width = 200, shape = gears.shape.rounded_bar, bar_shape = gears.shape.rounded_bar, background_color = "yellow"})
local batt_hover
local function _10_()
  local batt_proc = io.popen("bash -c 'acpi -b'")
  local batt_str = batt_proc:read("*a")
  batt_proc:close()
  return batt_str
end
batt_hover = awful.tooltip({objects = {batt_bar}, timer_function = _10_})
local mytextclock = wibox.widget.textclock()
local taglist_buttons
local function _11_(t)
  return t:view_only()
end
taglist_buttons = gears.table.join(awful.button({}, 1, _11_), awful.button({}, 3, awful.tag.viewtoggle))
local batt_low = false
local batt_thresh = 0.25
local function _12_(s)
  set_wallpaper(s)
  awful.tag(my_tags, s, awful.layout.layouts[1])
  do end (s)["mypromptbox"] = awful.widget.prompt()
  do end (s)["mylayoutbox"] = awful.widget.layoutbox(s)
  local function _13_()
    return awful.layout.inc(1)
  end
  do end (s.mylayoutbox):buttons(awful.button({}, 1, _13_))
  do end (s)["mytaglist"] = awful.widget.taglist({screen = s, filter = awful.widget.taglist.filter.noempty, buttons = taglist_buttons})
  do end (s)["mytasklist"] = awful.widget.tasklist({screen = s, filter = awful.widget.tasklist.filter.currenttags})
  do end (s)["mywibox"] = awful.wibar({position = "top", screen = s})
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
  return (s.mywibox):setup({layout = wibox.layout.align.horizontal, {layout = wibox.layout.fixed.horizontal, mylauncher, s.mytaglist, s.mypromptbox}, s.mytasklist, {layout = wibox.layout.fixed.horizontal, wibox.widget.systray(), awful.widget.watch("bash -c 'acpi -b'", 30, _14_, batt_bar), mytextclock, s.mylayoutbox}})
end
awful.screen.connect_for_each_screen(_12_)
local globalkeys
local function _17_()
  return awful.client.focus.byidx(1)
end
local function _18_()
  return awful.client.focus.byidx(-1)
end
local function _19_()
  return mymainmenu:show()
end
local function _20_()
  return awful.client.swap.byidx(1)
end
local function _21_()
  return awful.client.swap.byidx(-1)
end
local function _22_()
  return awful.screen.focus_relative(1)
end
local function _23_()
  return awful.spawn("i3lock -c 000000")
end
local function _24_()
  return menubar.show()
end
globalkeys = gears.table.join(awful.key({modkey}, "Left", awful.tag.viewprev), awful.key({modkey}, "Right", awful.tag.viewnext), awful.key({modkey}, "Escape", awful.tag.history.restore), awful.key({modkey}, "j", _17_), awful.key({modkey}, "k", _18_), awful.key({modkey}, "x", _19_), awful.key({modkey, "Control"}, "r", awesome.restart), awful.key({modkey, "Shift"}, "j", _20_), awful.key({modkey, "Shift"}, "k", _21_), awful.key({modkey}, "Tab", _22_), awful.key({modkey}, "u", awful.client.urgent.jumpto), awful.key({modkey}, "g", _23_), awful.key({modkey}, "space", _24_))
local clientkeys
local function _25_(c)
  c["fullscreen"] = not c.fullscreen
  return c:raise()
end
clientkeys = gears.table.join(awful.key({modkey}, "f", _25_))
for idx, tag_name in pairs(my_tags) do
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
    local t = awful.tag.add(c.class, {screen = c.screen, icon = gears.surface.duplicate_surface(c.icon), layout = awful.layout.layouts[1]})
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
