require 'time_tap/editor_error'

module TimeTap
  module Watcher
    extend self

    # return all the active editors
    # put this in a function to make testing easier
    def editors
      editors = Array.new
      Editors::local_constants.each do |editor|
        editors.push eval "Editors::#{editor}.new"
      end
      editors
    end

    def keep_watching editor
      last = nil

      editors = TimeTap::Watcher.editors

      File.open(File.join(TimeTap.config[:root], ".tap_history"), 'a') do |history| 
        loop do
          exit if $stop
          begin
            editors.each do |editor|
              raise(EditorError) unless editor.is_running?

              path = editor.current_path
              raise(EditorError) if path.blank?

              mtime = File.stat(path).mtime
              current = [path, mtime]

              # The following equals to this shell code:
              #
              #   `echo \`date +%s\`: \`pwd\``
              #
              history << "#{mtime.to_i}: #{path}\n" unless current == last
              history.flush
              last = [path, mtime]
            end
          rescue EditorError
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