require 'time_tap/editor_error'

module TimeTap
  module Editors
    
    class TextMate
      require 'appscript'
      include Appscript

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
      require 'appscript'
      include Appscript

      def is_running?
        app('Xcode').is_running?
      end

      def current_path
        xcode = app('Xcode')
        document = xcode.document.get
        raise(EditorError) if document.blank?
        path = document.last.path.get rescue nil

      end
    end

  end
end