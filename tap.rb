#!/usr/bin/env ruby19
# coding: utf-8



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


__END__





@@stylesheet
html, body
  margin: 0
  padding: 0
  font-family: Helvetica, sans
  background-color: #eee

pre
  font-family: Helvetica, sans
  line-height: 1.2em
  h1, h2, h3, h4, p
    margin: 0


body
  padding: 1em

#page_contents
  background-color: #fff
  padding: 1em
  
  h2
    color: #999
    padding: 0.5em 0
    b
      color: #444
  
  th
    text-align: left
    a.project
      text-decoration: none
      color: black
      &:hover
        text-decoration: underline
  td
    padding: 0.5em
    
    i
      color: #ccc

.tip
  color: #ccc

h1 .tip
  font-size: 0.5em

.clear
  clear: both

.back
  margin-bottom: 2em
  a
    background-color: #222
    -webkit-border-radius: 0.5em
    color: white
    padding: 0.5em
    # display: block
    # float: left
    text-decoration: none
    &:hover
      background-color: #444

ul.header
  margin: 0
  padding: 0
  float: left
  display: block
  li
    list-style: none
    margin: 0
    padding: 0
    display: inline
  a
    background-color: #369

.header
  margin: 0
  padding: 0
  a, input.submit
    border: none
    margin: 0
    padding: 0
    background-color: red
    font-size: 0.6em
    text-transform: uppercase
    color: white
    text-decoration: none
    padding: 0.3em
  h1
    border-left: 15px solid #369
    margin: 0
    padding: 0.5em
    clear: both
    width: 50%
    background-color: white
    font-size: 1.3em
    margin-bottom: 0.5em

a.cancel
  background-color: #333

textarea
  margin: 0
  padding: 0
  border: none
  display: block
  width: 100%
  height: auto
  font-size: 1em
  font-family: monaco
  line-height: 1em
  .bad_content &
    width: 49%
    display: inline
    &.bad
      color: #ccc


#list
  h1
    border-color: #69c
  ul
    padding: 0
    margin: 0
    li
      padding: 0
      margin: 1px 0
      list-style: none
      a
        padding: 0.5em
        display: block
        border-left: 1em solid #ccc
        font-size: 1.3em
        font-weight: bold
        text-decoration: none
        color: #ccc
        width: 50%
        background-color: white
        line-height: 2em
        &:hover
          border-color: #369
          color: black





