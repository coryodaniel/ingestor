# require this file to load the tasks
require 'rake'

namespace :ingestor do
  desc "New"
  task :new do
    puts "Make a file"
  end

  task :run do
    puts "run a file"
  end
end