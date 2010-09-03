task :launcher do
  home = File.expand_path("~")
  ruby = ENV['TAP_RUBY'] || "#{home}/.rvm/bin/ruby-1.9.2-p0@global"
  
  File.open(File.expand_path("#{home}/Library/LaunchAgents/com.eliaesocietas.TimeTap.plist"), 'w') do |file|
    
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
    		<string>#{File.expand_path('tap.rb', __FILE__)}</string>
    		<string>-f</string>
    	</array>

    	<key>OnDemand</key>
    	<false/>

    	<key>RunAtLoad</key>
    	<true/>
    </dict>
    </plist>
    PLIST
  end
end