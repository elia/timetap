require 'spec_helper'
require 'time_tap/backend'

describe 'Backend' do
  let(:file_name) { './test-file_system-backend' }
  
  it 'loads a backend' do
    backend = TimeTap::Backend.load :file_system, :file_name => file_name
    backend.file_name.should eq(File.expand_path(file_name))
    backend.should be_a(TimeTap::Backend::FileSystem)
  end
end
