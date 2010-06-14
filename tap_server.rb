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
