#!/usr/bin/env ruby
# encoding: utf-8


require 'rubygems'
gem 'activesupport',  '~> 2.3.8'
gem 'actionpack',     '~> 2.3.8'
gem 'i18n',           '~> 0.3.5'
gem 'haml'
gem 'rb-appscript'
gem 'sinatra'


$LOAD_PATH.unshift File.expand_path("~/Code/tap")

if ARGV.include? '-f'
  go_foreground = true
  ARGV.shift
end

RUBY19 = RUBY_VERSION.to_f >= 1.9

tap_app = proc {
  
  # REQUIREMENTS
  
  require 'appscript'
  require 'active_support'
  require 'tap_projects'
  require 'sinatra/base'
  require 'haml'
  require 'sass'
  require 'action_view'
  require 'tap_server'
  require 'yaml'
  
  
  
  
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
    
    TapServer.run! :host => 'localhost', :port => PORT
    exit
  }
  
  class MateError < StandardError
  end
  
  include Appscript
  last = nil
  File.open(File.expand_path("#{ROOT}/.tap_history"), 'a') do |history|
    loop do
      exit if $stop
      begin
        raise(MateError) if mate_isnt_running = `ps -ax -o comm|grep TextMate`.chomp.strip.empty?
        mate = app('TextMate')
        document = mate.document.get
        raise(MateError) if document.blank?
        path = document.first.path.get rescue nil
        raise(MateError) if path.blank?
        mtime = File.stat(path).mtime
        current = [path, mtime]
        
        # The following equals to this shell code:
        # 
        #   `echo \`date +%s\`: \`pwd\``
        # 
        history << "#{mtime.to_i}: #{path}\n" unless current == last
        history.flush
        last = [path, mtime]
      rescue MateError
        # do nothing
      rescue
        puts Time.now.to_s
        puts $!.to_s
        puts $!.backtrace.join("\n")
        
        File.open(File.expand_path("#{ROOT}/.tap_errors"), "w") do |file|
          file.puts Time.now.to_s
          file.puts $!.to_s
          file.puts $!.backtrace.join("\n")
        end
        
        raise if $!.kind_of?(SignalException)
      end
      sleep 30
    end
  end
}


# Try to replace "ruby" with "TimeTap" in the command string (for "ps -A" & co.)
$0 = 'TimeTap'

unless go_foreground
  pid = fork {
    
    # Define Process::daemon without waiting for active support to be loaded
    # so that the "tap" command exits immediatly.
    # from active_support-3
    def Process.daemon(nochdir = nil, noclose = nil)
      exit if fork                     # Parent exits, child continues.
      Process.setsid                   # Become session leader.
      exit if fork                     # Zap session leader. See [1].
    
      unless nochdir
        Dir.chdir "/"                  # Release old working directory.
      end
    
      File.umask 0000                  # Ensure sensible umask. Adjust as needed.
    
      unless noclose
        STDIN.reopen "/dev/null"       # Free file descriptors and
        STDOUT.reopen "/dev/null", "a" # point them somewhere sensible.
        STDERR.reopen '/dev/null', 'a'
      end
    
      trap("TERM") { exit }
    
      return 0
    end
    
    Process.daemon(true)
    tap_app.call
  }
else
  puts "going foreground"
  tap_app.call
end
