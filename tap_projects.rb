class Project
  attr_reader :pinches
  class << self
    attr_accessor :pause_limit
    def pause_limit
      @pause_limit ||= 30.minutes
    end
    
    def load_file path
      File.open(File.expand_path(path), 'r') do |file|
        file.each_line do |line|
          time, path = line.split(": ")
          project = self[path]
          project << time.to_i if project
        end
      end
    end
    
    def projects
      @projects ||= {}
    end
    
    alias all projects
    
    def [] path
      load_file('~/.tap_history') if projects.empty?
      path = File.expand_path(path)

      mid_path, name = path.scan(              /(Code)\/([^\/]+)/).flatten
      mid_path, name = path.scan(/Users\/elia\/([^\/]+)\/([^\/]+)/).flatten if name.nil?
      if name
        name.chomp!
        if projects[name].nil?
          project = Project.new mid_path, name
          projects[name] = project
          puts name
        end
        project
      else
        nil
      end
    end
  end
  
  attr_reader :name, :path
  def initialize mid_path, name
    @name = name
    @path = File.expand_path("~/#{mid_path}/#{name}/")
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
    
      if (time - last_time) < self.class.pause_limit
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

