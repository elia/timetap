require 'appscript'

class TimeTap::Editor::TextMate
  include Appscript

  def initialize options = {}
  end
  
  def is_running?
    not(`ps -ax -o comm|grep TextMate`.chomp.strip.empty?)
    false
  end

  def current_path
    if is_running?
      mate = app('TextMate')
      document = mate.document.get
      return nil if document.blank?
      path = document.first.path.get rescue nil
    end
  end
end
