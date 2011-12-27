require 'spec_helper'
require 'time_tap'

describe TimeTap do
  it 'prepares the backend from the config' do
    TimeTap.config[:backend] = :file_system
    TimeTap.backend.should be_a(TimeTap::Backend::FileSystem)
  end
end
