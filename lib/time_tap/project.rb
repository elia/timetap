require 'active_support/core_ext/hash/indifferent_access'
require 'active_support/core_ext/numeric/time'

class TimeTap::Project
    
  # CONFIG
    
  @pause_limit = 30.minutes
  @projects = HashWithIndifferentAccess.new
  @backend = TimeTap.backend
    
  class << self
    attr_accessor :pause_limit
    attr_reader :projects
    attr_reader :backend
  end

  def logger
    TimeTap.logger
  end




  class << self
    def logger
      TimeTap.logger
    end
    
    def all
      backend.each_entry do |time, path|
        register time, path
      end unless @loaded
      @loaded = true
      projects.values
    end
    
    def register time, path
      project = self[path]
      if project
        project << time
        logger.info "[TimeTap::Project] added #{time} to project #{project.name} (#{project})"
      else
        logger.info "[TimeTap::Project] skipping #{time}, no project"
      end
    end
    
    def find name
      projects[name.underscore.downcase]
    end

    def [] path
      return if path.nil? or path.empty?
      path = File.expand_path(path)
      how_nested = 1

      regex_suffix = "([^/]+)"
      
      folders = TimeTap.config[:code_folders].map do |folder|
        folder = File.expand_path(folder)
        folder = Dir[folder]
      end.flatten
      
      folders_regex = folders.map{|f| Regexp.escape f}.join('|')
      res = path.scan(%r{(#{folders_regex})/#{regex_suffix}}).flatten
      
      # res = path.scan(%r{(#{TimeTap.config[:code] || "Code"})/#{regex_suffix}}).flatten
      mid_path = res[0] # not in a MatchObj group any more, so it's 0 based
      name = res[how_nested]
      mid_path, name = path.scan(%r{#{File.expand_path("~")}/([^/]+)/([^/]+)}).flatten if name.nil?
      
      if name
        name.chomp!
        key = name.underscore.downcase
        if projects[key].nil?
          project = new mid_path, name
          projects[key] = project
        end
        projects[key]
      else
        nil
      end
    end
  end





  def initialize mid_path, name
    @name = name
    @path = File.expand_path("~/#{mid_path}/#{name}/")
    @pinches = []
  end
  
  
  
  
  # ATTRIBUTES
  
  attr_reader :name, :path, :pinches
    
  def work_time
    pinches.map(&:duration).inject(0.seconds, &:+)
  end

  def days
    pinches.group_by do |pinch|
      pinch.start_time.to_date
    end
  end



  class Pinch
    attr_accessor :start_time, :end_time
    def initialize start_time
      @end_time = @start_time = start_time
    end

    def duration
      end_time ? end_time - start_time : 30.seconds
    end

    def humanized_duration
      seconds = duration

      hours = mins = 0
      if seconds >=  60 then
        mins = (seconds / 60).to_i 
        seconds = (seconds % 60 ).to_i

        if mins >= 60 then
          hours = (mins / 60).to_i 
          mins = (mins % 60).to_i
        end
      end
      "#{hours}h #{mins}m #{seconds}s"
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

end
