#! /usr/bin/env ruby
require 'rubygems'
require 'bundler/setup'
require 'ingestor'
require 'ingestor/parser/json'

# Set up a bogus active model
require 'active_model'
class Person
  include ActiveModel::Naming
  def persisted?
    true
  end
  # Make a fake active model
  attr_accessor :id, :first_name, :last_name, :age, :address
  def update_attributes(attributes = {})
    attributes.each do |name, value|
        send("#{name}=", value)
    end
    true    
  end
end
# end bogusness

ingest "./samples/people.json" do
  parser :json

  # Receives the full document and narrows it down to the collection to process.
  parser_options collection: lambda{|document|
    document['people']
  }
  #sample true
  
  # How to map out the columns from text to AR
  map_attributes do |values|
    values
  end
  
  # before{|attrs| values}

  # Your strategy for finding or instantiating a new object to be handled by the processor block
  finder{|attrs|
    # Book.find( attrs['id'] ) || Book.new
    Person.new
  }

  processor{|attrs,record|
    # ... custom processor here ...
    record.update_attributes attrs
  }
  
  after{|record| 
    puts "Created: #{record.first_name} @ #{record.address}"
  }
end