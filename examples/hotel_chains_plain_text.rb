#! /usr/bin/env ruby
require 'rubygems'
require 'bundler/setup'
require 'ingestor'

# Set up a bogus active model
require 'active_model'
class HotelChain
  include ActiveModel::Naming
  def persisted?
    true
  end
  # Make a fake active model
  attr_accessor :id, :name
  def update_attributes(attributes = {})
    attributes.each do |name, value|
        send("#{name}=", value)
    end
    true    
  end
end
# end bogusness

ingest "./samples/ChainList.zip" do
  parser :plain_text
  compressed true
  includes_header true
  # sample true

  parser_options delimiter: '|'

  # How to map out the columns from text to AR
  map_attributes do |values|
    {
      id:   values[0],
      name: values[1]
    }
  end
  
  # before{|attrs| attrs}
  
  # Your strategy for finding or instantiating a new object to be handled by the processor block
  finder{|attrs|
    # Book.find( attrs['id'] ) || Book.new
    HotelChain.new
  }

  processor{|attrs,record|
    # ... custom processor here ...
    record.update_attributes attrs
  }
  
  after{|record| 
    puts "Created: #{record.name}"
  }
end