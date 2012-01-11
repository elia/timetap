require 'active_support/core_ext/hash/indifferent_access'
require 'logger'

module TimeTap
  @config = {
    :root => "~",
    # root is where the logs will be saved

    :code => 'Code',
    # code is where all your projects live
    :code_folders => [
      '~/Code/Mikamai', 
      '~/Code'
    ],
    
    :nested_project_layers => 1,
    # see below about nested projects

    :port => 1111,
    # the port on localhost for the web interface

    :ruby => '/usr/bin/ruby',
    # the ruby you want to use

    :textmate => {
      # where you keep your .tmproj files
      :projects => '~/Development/Current Projects'
    },
    
    :backend         => :file_system,
    :backend_options => { :file_name => '~/.timetap.history' },
    :editor          => :text_mate,
    :log_file        => '~/.timetap.log'
  }.with_indifferent_access
  attr_accessor :config
  
  
  @logger = Logger.new($stdout)
  attr_accessor :logger
  
  
  extend self
  
  
  # CONFIGURATION

  # Are we on 1.9?
  # FIXME: this is wrong! :)
  RUBY19 = RUBY_VERSION.to_f >= 1.9
  
  def config= options = {}
    require 'active_support'
    
    # CONFIG
    @config = HashWithIndifferentAccess.new(options)
    @config[:root] = File.expand_path(config[:root])
    @config[:port] = config[:port].to_i
  end
  
  
  
  # BACKEND
    
  def backend
    require 'time_tap/backend'
    @backend = Backend.load config[:backend], config[:backend_options]
  end
  
  def editor
    require 'time_tap/editor'
    @backend = Editor.load config[:editor], config[:editor_options]
  end
    
  
  # START
  
  def start options = {}
    # REQUIREMENTS
  
    require 'yaml'
    require 'time_tap/project'
    require 'time_tap/watcher'
    require 'time_tap/server'
    
    logger.info "[TimeTap] config: #{config.to_yaml}"
    # SIGNAL HANDLING
    
    Signal.trap('INT')  {exit}
    Signal.trap('TERM') {exit}
  
  
    # WEB SERVER
      
    Thread.abort_on_exception = true
      
    @server = Thread.new {
      Signal.trap("INT")  {exit}
      Signal.trap("TERM") {exit}
    
      Server.run! :host => 'localhost', :port => TimeTap.config[:port]
      exit
    }
  
    
    # WATCHER
  
    watcher = Watcher.new(editor, backend)
    watcher.keep_watching
  end
  
  
  # Add a plist for OSX's launchd and have *TimeTap* launched automatically at login.
  def install_launcher!
    load_plist_info!
    ruby        = config[:ruby] || "/usr/bin/ruby"
    include_dir = '-I'+File.expand_path('../../lib', __FILE__)
    launcher    = File.expand_path('../../bin/timetap', __FILE__)

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
    end
  end
  
  def reload_launcher!
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
