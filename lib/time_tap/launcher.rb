module TimeTap
  module Launcher
    # Add a plist for OSX's launchd and have *TimeTap* launched automatically at login.
    def install_launcher!
      puts 'Installing launcher...'

      load_plist_info!
      ruby        = config[:ruby] || "/usr/bin/ruby"
      include_dir = '-I'+File.expand_path('../../lib', __FILE__)
      launcher    = File.expand_path('../../bin/timetap', __FILE__)
      working_directory = File.expand_path('../../', __FILE__)

      puts "\nCreating launchd plist in\n  #{plist_path}"

      File.open(plist_path, 'w') do |file|
        file << <<-PLIST
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
	<key>Label</key>
	<string>com.eliaesocietas.TimeTap</string>

	<key>ProgramArguments</key>
	<array>
		<string>#{ruby}</string>
		<string>#{include_dir}</string>
		<string>-S</string>
		<string>bundle</string>
		<string>exec</string>
		<string>#{launcher}</string>
		<string>-f</string>
	</array>


  <key>WorkingDirectory</key>
  <string>#{working_directory}</string>
  <key>StandardErrorPath</key>
  <string>/usr/local/var/log/timetap.log</string>
  <key>StandardOutPath</key>
  <string>/usr/local/var/log/timetap.log</string>

	<key>OnDemand</key>
	<false/>

	<key>RunAtLoad</key>
	<true/>
</dict>
</plist>
        PLIST
      end
    end

    def reload_launcher!
      puts 'Reloading system launcher...'

      load_plist_info!
      command = "launchctl unload #{plist_path}; launchctl load #{plist_path}"
      exec command
    end




    private

    attr_reader :plist_path, :plist_name

    def load_plist_info!
      @plist_name ||= "com.eliaesocietas.TimeTap.plist"
      @plist_path ||= File.expand_path("~/Library/LaunchAgents/#{plist_name}")
    end

  end
end
