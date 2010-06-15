class TapServer < Sinatra::Application
  
  get '/' do
    sort = (params[:sort] || :last).to_sym
    
    @projects = Project.all.sort_by do |project|
      case sort
      when :name;     project.name
      when :last;     -project.pinches.last.end_time.to_i
      when :elapsed;  -project.work_time
      end
    end.select{|p| p.work_time > 30.minutes}
    
    haml :index
  end
  
  get '/project/:name' do
    @project = Project.find(params[:name])
    redirect '/' if @project.nil?
    
    def @project.days
      pinches.group_by do |pinch|
        pinch.start_time.to_date
      end
    end
    
    haml :project
  end
  
  
  
  #################
  
  
  
  
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
  
  include ActionView::Helpers::DateHelper
  set :haml, { :format        => :html5,
               :attr_wrapper  => '"'     }
  use_in_file_templates!
  
  before do
    content_type "text/html", :charset => "utf-8"
    Project.load_file('~/.tap_history')
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
  
end
