#!/usr/bin/env ruby
# encoding: utf-8


require 'rubygems'
gem 'activesupport',  '~> 2.3.8'
gem 'actionpack',     '~> 2.3.8'
gem 'i18n',           '~> 0.3.5'
gem 'haml'
gem 'rb-appscript'
gem 'sinatra'


module TimeTap
  
  def self.start
    # REQUIREMENTS
  
    require 'yaml'
    require 'active_support'
    require 'time_tap/projects'
    require 'time_tap/editors'
    require 'time_tap/watcher'
    require 'time_tap/server'
  
  
  
  
    # CONFIGURATION
  
    config_file = File.exist?(user_config = File.expand_path("~/.tap_config")) ? user_config : File.expand_path('config.yaml', __FILE__)
    CONFIG = YAML.load_file(config_file)
    PORT = CONFIG['port'] || 1111
    ROOT = CONFIG['root'] || File.expand_path('~')
  
  
  
  
    # SIGNAL HANDLING
  
    Signal.trap("INT")  {exit}
    Signal.trap("TERM") {exit}
  
  
  
  
    # WEB SERVER
  
    Thread.abort_on_exception = true
  
    @server = Thread.new {
      Signal.trap("INT")  {exit}
      Signal.trap("TERM") {exit}
    
      Server.run! :host => 'localhost', :port => PORT
      exit
    }
  
  
  
  
    # WATCHER
  
    include Editors
    Watcher.keep_watching(TextMate)
  end
end
