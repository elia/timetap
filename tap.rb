#!/usr/bin/env ruby19
# coding: utf-8

$LOAD_PATH.unshift File.expand_path("~/Code/tap")

if ARGV.include? '-f'
  go_foreground = true
  ARGV.shift
end
PORT = 1111
ROOT = "/Users/elia"

tap_app = proc {
  Signal.trap("INT")  {exit}
  Signal.trap("TERM") {exit}
  require 'active_support'
  require 'tap_projects'
  
  Thread.abort_on_exception = true
  @server = Thread.new {
    
    Signal.trap("INT")  {exit}
    Signal.trap("TERM") {exit}
    
    puts "loading sinatra..."
    require 'sinatra/base'
    require 'haml'
    require 'action_view'
    require 'tap_server'
    
    Signal.trap("INT")  {exit}
    Signal.trap("TERM") {exit}
    
    TapServer.run! :host => 'localhost', :port => PORT
    exit
  }
  
  class MateError < StandardError
  end
  
  require 'appscript'
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
        
        # Versione shell:
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


unless go_foreground
  pid = fork {
    Process.daemon(true)
    tap_app.call
  }
  # Process.detach pid
else
  puts "going foreground"
  tap_app.call
end
