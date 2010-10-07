module TimeTap
  module Editors
    class EditorError < StandardError
    end
    
    class TextMate
      require 'appscript'
      include Appscript

      def is_running?
        `ps -ax -o comm|grep TextMate`.chomp.strip
      end

      def current_path
        if app('TextMate').is_running?
          mate = app('TextMate')
          document = mate.document.get
          raise(EditorError) if document.blank?
          path = document.first.path.get rescue nil
        end
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