require 'time_tap/project'

class TimeTap::Watcher
  attr_reader :editor, :backend
  def initialize editor, backend
    @editor, @backend = editor, backend
    logger.info "new watcher #{[editor, backend].inspect}"
  end
    
  def logger
    TimeTap.logger
  end
    
  def keep_watching
    last = nil

    loop do
      break if $stop
      logger.info "[TimeTap] checking current_path..."
      
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
    
    if path and File.exist? path
      logger.info "[TimeTap::Watcher] path: #{path.inspect}"
      mtime = File.mtime(path).to_i
      current = [mtime, path]
      logger.info "[TimeTap::Watcher] checking entry (#{current == last}): \n#{current.inspect} == \n#{last.inspect}"
      
      if current != last
        backend.register *current
        TimeTap::Project.register *current
        TimeTap.logger.info "[TimeTap::Watcher] registered: #{current.inspect}"
        last = current
      end
    end
  end
    
end
