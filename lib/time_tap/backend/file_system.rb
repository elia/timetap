class TimeTap::Backend::FileSystem
  def initialize options = {}
    raise 'missing :file_name option' unless options[:file_name]
    @file_name = options[:file_name]
  end
  
  def file_name
    File.expand_path(@file_name)
  end
  
  def append_to_file content
    File.open(file_name).tap do |f|
      f.sync = true
      f << content
    end
  end
  
  def ruby19?
    RUBY_VERSION < '1.9'
  end
  
  def each_entry
    File.open(file_name, 'r', ruby19? ? {:external_encoding => 'utf-8'} : nil) do |file|
      file.each_line do |line|
        time, path = line.split(": ")
        yield time.to_i, path
      end
    end
  end
  
  def register time, path
    append_to_file "#{time.to_i}: #{path}\n"
  end
  
  def load_data
    each_entry do |time, path|
      project = self[path]
      project << time if project
    end
  end
  
end
