class TimeTap::Editor::SublimeText2
  def initialize options = {}
  end
  
  def current_path
    container_file = File.expand_path('~/.timetap.sbl2.current_file')
    file = File.read(container_file).strip if File.exist? container_file
    
    if File.exist? file
      file
    else
      nil
    end
  end
end
