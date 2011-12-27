class TimeTap::Editor::TextMate
  def initialize options = {}
  end
  
  def current_path
    file = File.expand_path("~/.timetap.tm2.current_file")
    File.exist? file ? File.read(file) : nil
  end
end
