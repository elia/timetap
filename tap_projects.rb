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

