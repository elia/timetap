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
  attr_accessor :config
  
  extend self
  
  
  # CONFIGURATION

  # Are we on 1.9?
  # FIXME: this is wrong! :)
  RUBY19 = RUBY_VERSION.to_f >= 1.9


  def start options = {}
    # REQUIREMENTS
  
    require 'yaml'
    require 'active_support'
    require 'time_tap/project'
    require 'time_tap/editors'
    require 'time_tap/watcher'
    require 'time_tap/server'
    
    
    # CONFIG
    self.config = HashWithIndifferentAccess.new(options)
    self.config[:root] = File.expand_path(config[:root])
    self.config[:port] = config[:port].to_i
    
  
    # SIGNAL HANDLING
  
    Signal.trap("INT")  {exit}
    Signal.trap("TERM") {exit}
  
  
    # WEB SERVER
  
    Thread.abort_on_exception = true
  
    @server = Thread.new {
      Signal.trap("INT")  {exit}
      Signal.trap("TERM") {exit}
    
      Server.run! :host => 'localhost', :port => TimeTap.config[:port]
      exit
    }
  
  
    # WATCHER
  
    include Editors
    Watcher.keep_watching(TextMate)
  end
end
