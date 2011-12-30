require 'spec_helper'
require 'time_tap/project'

describe TimeTap::Project do
  before do
    TimeTap::Project.reload!
  end
  
  it 'has a 30m puse limit' do
    TimeTap::Project.pause_limit.should eq(30.minutes)
  end
end
