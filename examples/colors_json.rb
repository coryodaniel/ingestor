#! /usr/bin/env ruby
require 'rubygems'
require 'bundler/setup'
require 'ingestor'
require 'ingestor/parser/json'

# Set up a bogus active model
require 'active_model'
class Color
  include ActiveModel::Naming
  def persisted?
    true
  end
  # Make a fake active model
  attr_accessor :name, :hex
  def update_attributes(attributes = {})
    attributes.each do |name, value|
        send("#{name}=", value)
    end
    true    
  end
end
# end bogusness

ingest "./samples/colors.json" do
  parser :json

  # Receives the full document and narrows it down to the collection to process.
  parser_options collection: lambda{|document|
    document
  }
  
  # How to map out the columns from text to AR
  map_attributes do |values|
    {
      name: values['color'],
      hex:  values['value']
    }
  end
  
  # before{|attrs| values}

  # Your strategy for finding or instantiating a new object to be handled by the processor block
  finder{|attrs|
    # Book.find( attrs['id'] ) || Book.new
    Color.new
  }

  processor{|attrs,record|
    # ... custom processor here ...
    record.update_attributes attrs
  }
  
  after{|record| 
    puts "Created: #{record.name}"
  }
end