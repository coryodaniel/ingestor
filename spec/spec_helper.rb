require 'rubygems'
require 'bundler/setup'

require 'ingestor'
require 'vcr'
require 'orm/active_record'

VCR.configure do |c|
  c.cassette_library_dir     = 'spec/cassettes'
  c.stub_with                :fakeweb
end

RSpec.configure do |config|
  config.extend VCR::RSpec::Macros
  config.before(:all) { TestMigration.up }
  config.after(:all) { TestMigration.down }
  config.after(:each){ 
    Country.delete_all
    Dummy.delete_all
  }
end