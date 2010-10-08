require 'time_tap/editor_error'
require 'appscript'
include Appscript

module TimeTap
  module Editors
    
    class TextMate

      def is_running?
        app('TextMate').is_running?
      end

      def current_path
        mate = app('TextMate')
        document = mate.document.get
        raise(EditorError) if document.blank?
        path = document.first.path.get rescue nil
      end
    end
    
    class Xcode

      def is_running?
        # Cannot use app('Xcode') because it fails when multiple Xcode versions are installed
        !app('System Events').processes[its.name.eq('Xcode')].get.empty?
      end

      def current_path
        # although multiple versions may be installed, tipically they will not be running simultaneously
        pid = app('System Events').processes[its.name.eq('Xcode')].first.unix_id.get
        xcode = app.by_pid(pid)
        document = xcode.document.get
        raise(EditorError) if document.blank?
        path = document.last.path.get rescue nil

      end
    end

  end
end