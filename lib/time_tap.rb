module TimeTap
  extend self


  # Configuration
  require 'time_tap/config'
  extend Config

  # Launcher
  require 'time_tap/launcher'
  extend Launcher

  # Logger
  require 'logger'
  attr_accessor :logger
  @logger = Logger.new($stdout)

  # Backend
  def backend
    require 'time_tap/backend'
    @backend = Backend.load config[:backend], config[:backend_options]
  end

  # Editor
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
end
