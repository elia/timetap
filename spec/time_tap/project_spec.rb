require 'spec_helper'
require 'time_tap/project'

describe TimeTap::Project do
  let(:backend) { double('backend') }
  it 'has a configuration' do
    TimeTap::Project.pause_limit.should eq(30.minutes)
  end
  it 'reads from the backend' do
    # backend.should_receive(:load_data).and_return([[Time.now, File.expand_path(__FILE__)]])
    # TimeTap::Project.all.size.should eq(1)
  end
end
