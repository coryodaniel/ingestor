require 'spec_helper'
describe Ingestor do
  it "should have a version" do
    Ingestor::VERSION.should_not be_nil
  end
end