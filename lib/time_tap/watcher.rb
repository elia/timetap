require 'time_tap/project'

class TimeTap::Watcher
  attr_reader :editor, :backend
  def initialize editor, backend
    @editor, @backend = editor, backend
  end
    
  def logger
    TimeTap.logger
  end
    
  def keep_watching
    last = nil

    loop do
      break if $stop
        
      begin
        last = watch!(last)
      rescue
        logger.error "#{$!}\n#{$!.backtrace.join("\n")}"
        raise if $!.kind_of?(SignalException)
      end
      
      break if $stop
      sleep 30
    end
  end
  
  
  def watch! last = nil
    path = editor.current_path
    
    if path
      mtime = File.mtime(path)
      current = [mtime, path]
              
      unless current == last
        backend.register *current
        TimeTap::Project.register *current
        last = current
      end
    end
  end
    
end
