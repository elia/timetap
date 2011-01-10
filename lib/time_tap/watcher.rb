module TimeTap
  module Watcher
    extend self
    
    def keep_watching editor
      last = nil

      # TODO: pick which application the user wants...
      editor = editor.new

      File.open(File.join(TimeTap.config[:root], ".tap_history"), 'a') do |history|
        history.sync = true
        loop do
          exit if $stop
          begin
            if editor.is_running? && !(path = editor.current_path).blank?
              mtime = File.stat(path).mtime
              current = [path, mtime]
              
              unless current == last
                # The following equals to this shell code:
                #   `echo \`date +%s\`: \`pwd\``
                history << "#{mtime.to_i}: #{path}\n"
                last = [path, mtime]
              end
            end
          rescue ::TimeTap::Editors::EditorError
            # do nothing
          rescue
            puts Time.now.to_s
            puts $!.to_s
            puts $!.backtrace.join("\n")

            File.open(File.join(TimeTap.config[:root], ".tap_errors"), "w") do |file|
              file.puts Time.now.to_s
              file.puts $!.to_s
              file.puts $!.backtrace.join("\n")
            end

            raise if $!.kind_of?(SignalException)
          end
          sleep 30
        end
      end
    end
    
    
  end
end