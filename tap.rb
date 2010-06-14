#!/usr/bin/env ruby19
# coding: utf-8


class Project
  attr_reader :pinches
  class << self
    def projects
      @projects ||= {}
    end
    alias all projects
    def [] path
      path = File.expand_path(path)

      mid_path, project = path.scan(              /(Code)\/([^\/]+)/).flatten
      mid_path, project = path.scan(/Users\/elia\/([^\/]+)\/([^\/]+)/).flatten if project.nil?
      if project
        project.chomp!
        projects[project] ||= Project.new mid_path, project
      else
        nil
      end
    end
  end
  
  def initialize mid_path, project
    @name = project
    @path = File.expand_path("~/#{mid_path}/#{project}/")
    @pinches = []
  end
  
  class Pinch
    attr_accessor :start_time, :end_time
    def initialize start_time
      @end_time = @start_time = start_time
    end
    
    def duration
      end_time ? end_time - start_time : 30.seconds
    end
  end
  
  def << time
    time = Time.at time
    last_pinch = pinches.last
    
    if pinches.empty?
      pinches << Pinch.new(time)
    else
      last_time = last_pinch.end_time
      return unless time > last_time
    
      if (time - last_time) < 15.minutes
        last_pinch.end_time = time
      else
        pinches << Pinch.new(time)
      end
    end
  end
  
  def work_time
    pinches.map(&:duration).inject(0.seconds, &:+)
  end
end



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
  
  Thread.abort_on_exception = true
  @server = Thread.new {
    
    Signal.trap("INT")  {exit}
    Signal.trap("TERM") {exit}
    
    puts "loading sinatra..."
    require 'sinatra/base'
    require 'haml'
    require 'action_view'
    
    
    class TapServer < Sinatra::Application
      
      def work_time timestamps
        elapsed_time = 0
        last_time = nil
        
        timestamps.each do |time|
          if last_time
            current_elapsed_time = time - last_time
            if current_elapsed_time.seconds > 30.minutes or current_elapsed_time < 0
              elapsed_time += 30.seconds
            end
            elapsed_time += current_elapsed_time
          else
            elapsed_time += 30.seconds
          end
          last_time = time
        end
        elapsed_time.seconds
      end
      
      # def projects
      #   if @projects.nil?
      #     File.open(File.expand_path("~/.tap_history"), 'r') do |file|
      #       last_line = {}
      #       @projects = Hash.new
      # 
      #       file.each_line do |line|
      #         time, path = line.split(": ")
      #         path = File.expand_path(path)
      #         
      #         mid_path, project = path.scan(              /(Code)\/([^\/]+)/).flatten
      #         mid_path, project = path.scan(/Users\/elia\/([^\/]+)\/([^\/]+)/).flatten if project.nil?
      #         project.chomp! if project
      #         
      #         time = time.to_i
      #         
      #         if project and project == last_line[:project]
      #           elapsed_time = time - last_line[:time]
      #           if elapsed_time.seconds > 30.minutes or elapsed_time < 0
      #             elapsed_time = 30.seconds
      #           end
      #         else
      #           elapsed_time = 30.seconds
      #         end
      #         
      #         # puts "#{project}: #{elapsed_time}s (#{time})"
      #         
      #         @projects[project] ||= {
      #           :name => project.to_s, 
      #           :path => File.expand_path("~/#{mid_path}/#{project}/"),
      #           :since => time,
      #           :elapsed => 0,
      #           :pinches => []
      #         }
      #         
      #         @projects[project][:pinches] << time
      #         @projects[project][:last]     = time
      #         @projects[project][:elapsed] += elapsed_time
      #         
      #         last_line = {:project => project, :time => time}
      #       end
      #     end
      #   end
      #   @projects
      # end
      def projects
        File.open(File.expand_path("~/.tap_history"), 'r') do |file|
          file.each_line do |line|
            time, path = line.split(": ")
            project = Project[path]
            project << time.to_i if project
          end
        end
        @projects = Project.all
      end
      
      include ActionView::Helpers::DateHelper
      set :haml, { :format        => :html5,
                   :attr_wrapper  => '"'     }
      use_in_file_templates!
      
      before do
        content_type "text/html", :charset => "utf-8"
      end
      
      get "/stylesheet.css" do
        content_type "text/css", :charset => "utf-8"
        sass :stylesheet
      end
      
      get '/mate' do
        tm_project = File.expand_path("~/Sviluppo/Current Projects/#{File.basename(params[:path])}.tmproj")
        if File.exist?(tm_project)
          `open "#{tm_project}"`
        else
          `mate "#{params[:path]}"`
        end
        redirect '/'
      end
      
      get '/stop' do
        $stop = true
        Process.exit
      end
      
      get '/project/:name' do
        @project = projects[params[:name]]
        
        def @project.days
          self[:pinches].group_by do |pinch|
            Time.at(pinch).to_date
          end
        end
        
        haml :project
      end
      
      get '/' do
        # @projects = projects.to_a.sort_by do |(project,attributes)|
        #   sort = (params[:sort] || :last).to_sym
        #   
        #   case sort
        #   when :last; -attributes[:last]
        #   else         attributes[sort] || ''
        #   end
        #   
        # end.select do |(project,times)|
        #   params.key?('full') or times[:elapsed] > 30.minutes
        # end
        @projects = Project.all
        haml :index
      end
      
    end
    
    
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


@@index
%table
  %tr.header
    %th
      %a{:href => '/?'+params.merge('sort' => :name).map{|pair| pair.join('=')}.join(';')} Project
    %th
      %a{:href => '/?'+params.merge('sort' => :elapsed).map{|pair| pair.join('=')}.join(';')} Work Time
    %th
      %a{:href => '/?'+params.merge('sort' => :last).map{|pair| pair.join('=')}.join(';')} Last Access
    
  - @projects.map do |project,attributes|
    %tr
      - #STDOUT.puts [project, attributes].inspect
      %th{:title => attributes[:name]}
        %a.project{:href => "/project/#{project}"}= project ? project.underscore.humanize : '<i>other</i>'
      %td
        - elapsed_time = attributes[:elapsed].seconds
        - if elapsed_time < 8.hours
          = elapsed_hours = elapsed_time / 1.hour
          = elapsed_hours == 1 ? 'hour' : 'hours'
        - else
          = elapsed_days  = elapsed_time / 8.hours
          man
          = elapsed_days  == 1 ? 'day'  : 'days'
          and
          = elapsed_hours = (elapsed_time % 8.hours) / 1.hour
          = elapsed_hours == 1 ? 'hour' : 'hours'
          
        
      %td
        %i #{time_ago_in_words Time.at(attributes[:last])} ago
      %td
        %a.tip{:href => "/mate?path=#{attributes[:path]}"} mate
      
.clear
%a.tip{:href => '/?'+params.merge('full' => nil).map{|pair| pair.compact.join('=')}.join(';')} full
%a.tip{:href => '/?'+params.dup.delete_if{|k,v| k == 'full'}.map{|pair| pair.join('=')}.join(';')} short



@@project
.back
  %a{:href => '/'} « Home
  .clear
%h2
  Project:
  %b= params[:name].underscore.humanize
.days
  - @project.days.to_a.sort_by(&:first).each do |(day, pinches)|
    - time = work_time(pinches)
    - next if time < 10.minutes
    .day
      %div
        = day.strftime("%a %d %b %y")
        %span.tip= time_ago_in_words Time.now - time
      .work{:style => "width:#{time / 15.minutes.to_f}em;background-color:green;color:#ccc;overflow:visible;height:1em"}
      %br




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





