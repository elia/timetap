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
        mate = app('TextMate')
        document = mate.document.get
        raise(EditorError) if document.blank?
        path = document.first.path.get rescue nil
      end
    end
    
  end
end