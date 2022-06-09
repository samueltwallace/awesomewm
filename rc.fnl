(local gears (require :gears))
(require "gears.surface")
(local  awful (require :awful))
(require "awful.autofocus")
(local  wibox (require :wibox))
(local  beautiful (require :beautiful))
(local  naughty (require :naughty))
(local  menubar (require :menubar))

(if awesome.startup_errors
    (naughty.notify { :preset naughty.config.presets.critical
                      :title "Oops, there were errors during startup!"
                      :text awesome.startup_errors }))

(let [in-error false]
  (awesome.connect_signal
   "debug::error"
   (fn [err]
     (if in-error
         nil
         (let [in-error true]
           (naughty.notify { :preset naughty.config.presets.critical
                             :title "Oops, an error happened!"
                             :text (tostring err) }))))))

(beautiful.init (.. (gears.filesystem.get_themes_dir) "zenburn/theme.lua"))

(local terminal "emacsclient -e '(shell)'")
(local editor "emacsclient")
(local editor-cmd "emacsclient")

(local modkey "Mod4")
(local fnlconf "~/.config/awesome/rc.fnl")

(tset awful :layout :layouts [awful.layout.suit.tile.right
			      awful.layout.suit.tile.top
			      awful.layout.suit.max
			      awful.layout.suit.floating])

(fn preferred-layout [s] (naughty.notify {:text (.. "width " s.geometry.width " height " s.geometry.height)})
			   (if (>= s.geometry.width s.geometry.height)
			       1
			       2))

(local menu [["quit" awesome.quit]
	     ["restart" awesome.restart]
	     ["edit config" (.. editor-cmd " " fnlconf)]
	     ["Emacs" (fn [] (awful.spawn "emacs"))]
	     ["Firefox" (fn [] (awful.spawn "firefox"))]
	     ["Zathura" (fn [] (awful.spawn "zathura"))]
	     ["Discord" (fn [] (awful.spawn "discord"))]])

(local my-perm-tags ["E" "F" "Z" "D"])

(fn set-wallpaper [s] (os.execute "/home/samueltwallace/.local/bin/fehbg"))

(local mylauncher (awful.widget.launcher {:image beautiful.awesome_icon
					  :menu (awful.menu { :items menu })}))

(local batt_bar (wibox.widget { :widget wibox.widget.progressbar
				:forced_width 200
				:shape gears.shape.rounded_bar
				:bar_shape gears.shape.rounded_bar
				:background_color "yellow"}))

(local batt_hover (awful.tooltip {
				  :objects [batt_bar]
				  :timer_function (fn []
						    (let [batt_proc (io.popen "bash -c 'acpi -b'")
							  batt_str (batt_proc:read "*a")]
						      (do
							(batt_proc:close)
							batt_str)))}))
(local mytextclock (wibox.widget.textclock))

(local taglist_buttons (gears.table.join
			(awful.button { } 1 (fn [t] (t:view_only)))
			(awful.button { } 3 awful.tag.viewtoggle)))

(var batt_low false)

(local batt_thresh 0.25)

(local weather_box (wibox.widget {:widget wibox.widget.textbox
				  :text "No weather right now"}))

(awful.screen.connect_for_each_screen
 (fn [s]
   (do
     (set-wallpaper s) ;; set wallpaper on each screen
     (awful.tag my-perm-tags s (. awful.layout.layouts (preferred-layout s)))
     (tset s :mypromptbox (awful.widget.prompt)) ;;have a prompt box
     (tset s :mylayoutbox (awful.widget.layoutbox s)) ;; have a box showing current layout
     (s.mylayoutbox:buttons (awful.button {} 1 (fn [] (awful.layout.inc 1))) ) ;;clicking on layoutbox advances the layouts through the list
     (tset s :mytaglist (awful.widget.taglist {
					     :screen s
					     :filter awful.widget.taglist.filter.noempty ;; only show tags which are not empty
					     :buttons taglist_buttons})) ;; click the taglist by the predefined buttons
     (tset s :mytasklist (awful.widget.tasklist { :screen s
						:filter awful.widget.tasklist.filter.currenttags})) ;; show the icons and names of windows in the current tag(s)
     (tset s :mywibox (awful.wibar { :position "top" ;; show bar across top of screen
				     :screen s }))
     (s.mywibox:setup { :layout wibox.layout.align.horizontal ;; horizontal layout for the whole bar
			1 { :layout wibox.layout.fixed.horizontal ;; horizontal layout for the left side
			    1 mylauncher
			    2 s.mytaglist
			    3 s.mypromptbox }
			2 s.mytasklist ;; middle widget
			3  { :layout wibox.layout.fixed.horizontal ;; horizontal layout for right side
			    1 (awful.widget.watch "bash -c 'curl -s https://wttr.in/chicago?format=3'" ;; take from wttr.in
						  600 ;;refresh every 5 mins
						  (fn [widget stdout]
						      (tset widget :text stdout)) ;; make it weather_box text
						  weather_box)
			    2 (wibox.widget.systray)
			    3 (awful.widget.watch "bash -c 'acpi -b'" ;; watching battery updates
						  30 ;; recall every 30 secs
						  (fn [widget stdout] ;; here is fn to be called after calling acpi
						    (let [batt_percent (/ (tonumber (string.match stdout "(%d+)%%")) 100)] ;; get battery percentage as decimal
						      (do
							(widget:set_value batt_percent) ;; set progressbar to show batt_percent full
							(if (and (< batt_percent batt_thresh) ;; if we are hitting batt_thresh for first time, then
								 (not batt_low))
							    (do
							      (naughty.notify {:title "Battery Low!" ;; notify about low battery
									       :preset naughty.config.presets.critical})
							      (set batt_low true)))
							(if (< batt_percent batt_thresh) ;; if low battery
							    (tset widget :color "red") ;;set bar color red
							    (do ;; otherwise set green and mark no low battery
							      (tset widget :color "green")
							      (set batt_low false)))))) ;; need to check delims here, org mode matches < and )
						  batt_bar)
			    4 mytextclock ;; clock
			    5 s.mylayoutbox}})))) ;; show layout

(var globalkeys (gears.table.join
		   (awful.key [modkey] "Left" awful.tag.viewprev)
		   (awful.key [modkey] "Right" awful.tag.viewnext)
		   (awful.key [modkey] "Escape" awful.tag.history.restore)
		   (awful.key [modkey] "j" (fn [] (awful.client.focus.byidx 1)))
		   (awful.key [modkey] "k" (fn [] (awful.client.focus.byidx -1)))
		   (awful.key [modkey "Control"] "r" awesome.restart)
		   (awful.key [modkey "Shift"] "j" (fn [] (awful.client.swap.byidx 1)))
		   (awful.key [modkey "Shift"] "k" (fn [] (awful.client.swap.byidx -1)))
		   (awful.key [modkey] "Tab" (fn [] (awful.screen.focus_relative 1)))
		   (awful.key [modkey] "u" awful.client.urgent.jumpto)
		   (awful.key [modkey] "g" (fn [] (awful.spawn "i3lock -c 000000")))
		   (awful.key [modkey] "space" (fn [] (menubar.show)))))

(local clientkeys (gears.table.join
		   (awful.key [modkey "Shift"] "Tab" (fn [c] (c:move_to_screen)))
		   (awful.key [modkey] "f" (fn [c] (do
						     (tset c :fullscreen (not c.fullscreen))
						     (c:raise))))))

(each [idx tag-name (pairs my-perm-tags)]
  (set globalkeys (gears.table.join globalkeys
                                    (awful.key [modkey] (.. "#" (+ idx 9)) (fn [] ;; on modkey + number keypress, 
                                                                       (let [screen (awful.screen.focused)
                                                                             tag (. screen.tags idx)]
                                                                         (if tag
                                                                             (tag:view_only)) ;; view only the pressed tag.
                                                                       )))
                                    (awful.key [modkey "Control"] (.. "#" (+ idx 9)) (fn [] ;; on modkey + control + number,
                                                                                 (let [screen (awful.screen.focused)
                                                                                       tag (. screen.tags idx)]
                                                                                   (if tag
                                                                                       (awful.tag.viewtoggle tag))))) ;; view pressed tag as well.
                                    (awful.key [modkey "Shift"] (.. "#" (+ idx 9)) (fn [] ;; on modkey + shift + number,
                                                                               (if client.focus
                                                                                   (let [tag (. client.focus.screen.tags i)]
                                                                                     (if tag
                                                                                         (client.focus:move_to_tag tag))))))))) ;; move client to pressed tag.

(root.keys globalkeys)

(tset awful.rules :rules [
                         { :rule { } ;; default for all windows
                           :properties {
                                        :border_width beautiful.border_width
                                        :border_color beautiful.border_normal
                                        :focus awful.client.focus.filter
                                        :raise true
                                        :keys clientkeys
                                        :screen awful.screen.preferred
                                        :placement (+ awful.placement.no_overlap awful.placement.no_offscreen)}}
                         { :rule { :class "Emacs" } ;; emacs will end up
                           :properties { :screen (screen.count) ;; on highest number screen
                                         :tag "E" }} ;; on tag "E"
                         {:rule { :class "firefox" } ;; firefox will end up
                          :properties { :tag "F" }} ;; on tag "F"
                         {:rule { :class "Zathura"} ;; Zathura will end up
                          :properties {:tag "Z"}} ;; on tag "Z"
                         {:rule {:class "discord" } ;; and discord
                          :properties {:tag "D"}} ]) ;; on tag "D"

(client.connect_signal "manage" (fn [c]
                                  (if (and
                                       awesome.startup
                                       (not c.size_hints.user_position)
                                       (not c.size_hints.program_position))
                                      (awful.placement.no_offscreen c))
                                  (if (not (or
                                       (= c.class "Emacs")
                                       (= c.class "Zathura")
                                       (= c.class "firefox")
                                       (= c.class "discord")))
                                      (let [t (awful.tag.add c.class {:screen c.screen
                                                                      :icon (gears.surface.duplicate_surface c.icon)})]
                                        (c:tags [t])))))

(fn is-tag-by-name [tag name]
  (= tag (awful.tag.find_by_name (awful.screen.focused) name)))


(client.connect_signal "unmanage" (fn [c]
                                    (each [_ tag (ipairs c.screen.tags)]
                                      (if (not (or
                                           (. (tag:clients) 1)
                                           (is-tag-by-name tag "E")
                                           (is-tag-by-name tag "F")
                                           (is-tag-by-name tag "Z")
                                           (is-tag-by-name tag "D")))
                                          (do (tag:delete)
                                              (naughty.notify {:text (.. "tag " tag.name " deleted!")
                                                               :preset naughty.config.presets.critical}))))))

(client.connect_signal "mouse::enter" (fn [c]
                                        (c:emit_signal
                                         "request::activate"
                                         "mouse_enter"
                                         {:raise false})
nil))

(awful.spawn "pgrep emacs || emacs")
