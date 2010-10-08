namespace :timetap do

  plist_name  = "com.eliaesocietas.TimeTap.plist"
  home        = File.expand_path("~")
  ruby        = ENV['TAP_RUBY'] || "#{home}/.rvm/bin/ruby-1.9.2-p0@global"
  plist_path  = File.expand_path("#{home}/Library/LaunchAgents/#{plist_name}")
  launcher    = File.expand_path('../../../bin/timetap', __FILE__)
  include_dir = '-I'+File.expand_path('../../../lib', __FILE__)
  
  desc "Add a plist for OSX's launchd and have *TimeTap* launched automatically at login."
  task :launcher do
    puts "\nCreating launchd plist in\n  #{plist_path}"
  
    File.open(plist_path, 'w') do |file|
      file << <<-PLIST
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
	<key>Label</key>
	<string>com.eliaesocietas.TimeTap</string>

	<key>Program</key>
	<string>#{ruby}</string>

	<key>ProgramArguments</key>
	<array>
		<string>#{ruby}</string>
		<string>#{include_dir}</string>
		<string>#{launcher}</string>
		<string>-f</string>
	</array>

	<key>OnDemand</key>
	<false/>

	<key>RunAtLoad</key>
	<true/>
</dict>
</plist>
      PLIST
      
      puts "\nCreated. Now run:\n  launchctl load ~/Library/LaunchAgents\n\n"
    end
  end

  desc "Restarts the daemon."
  task :restart do
    command = "launchctl unload #{plist_path}; launchctl load #{plist_path}"
    puts command
    exec command
  end

  desc "Stops the daemon."
  task :start do
    command = "launchctl unload #{plist_path}"
    puts command
    exec command
  end

  desc "Starts the daemon."
  task :start do
    command = "launchctl load #{plist_path}"
    puts command
    exec command
  end
  
end
