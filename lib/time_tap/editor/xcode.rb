require 'appscript'

class TimeTap::Editor::Xcode
  include Appscript

  def initialize options = {}
  end
  
  def is_running?
    # Cannot use app('Xcode') because it fails when multiple Xcode versions are installed
    !app('System Events').processes[its.name.eq('Xcode')].get.empty?
  end

  def current_path
    if is_running?
      # although multiple versions may be installed, tipically they will not be running simultaneously
      pid = app('System Events').processes[its.name.eq('Xcode')].first.unix_id.get
      xcode = app.by_pid(pid)
      document = xcode.document.get
      return nil if document.blank?
      path = document.last.path.get rescue nil
    end
  end
end
