require 'sinatra/base'
require 'haml'
require 'sass'
require 'action_view'

module TimeTap
  class Server < Sinatra::Application
  
    include ActionView::Helpers::DateHelper
    set :haml, { :format        => :html5,
                 :attr_wrapper  => '"' , 
                 :encoding => RUBY19 ? 'UTF-8' : nil}
    set :root, File.dirname(__FILE__)
    set :views, Proc.new { File.expand_path("../views", __FILE__) }
  
  
    before do
      content_type "text/html", :charset => "utf-8"
      Project.load_file('~/.tap_history')
    end
  
  
  
  
  
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
    
      haml :project
    end
  
  
    get "/project/:name/:day" do
      @project = Project.find(params[:name])
      redirect '/' if @project.nil?

      days = @project.days.to_a.sort_by(&:first).reverse
      @current_day = days[ params[:day].to_i ][0] #pick an arbitrary date in the pinches

      @pinches = @project.days[@current_day]
      haml :project_day
    end


    get "/stylesheet.css" do
      content_type "text/css", :charset => "utf-8"
      sass :stylesheet
    end
  
    get '/mate' do
      tm_project = File.expand_path("#{TimeTap.config[:textmate][:projects] || 'Development/Current Projects'}/#{File.basename(params[:path])}.tmproj")
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
end