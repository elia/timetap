require 'spec_helper'
require 'time_tap/watcher'

describe 'Watcher' do
  let(:file) { __FILE__ }
  let(:editor) { double('editor', :current_path => file) }
  let(:backend) { double('backend') }
  
  it 'asks the editor the name of the currently opened file' do
    backend.should_receive(:register).with(File.mtime(file).to_i, file)
    watcher = TimeTap::Watcher.new(editor, backend)
    watcher.watch!
  end
end
