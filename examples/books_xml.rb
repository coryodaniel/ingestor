#! /usr/bin/env ruby
require 'rubygems'
require 'bundler/setup'
require 'ingestor'
require 'ingestor/parser/xml'

# Set up a bogus active model
require 'active_model'
class Book
  include ActiveModel::Naming
  def persisted?
    true
  end
  # Make a fake active model
  attr_accessor :id, :title, :author, :price, :genre, :publish_date, :description
  def update_attributes(attributes = {})
    attributes.each do |name, value|
        send("#{name}=", value)
    end
    true    
  end
end
# end bogusness

ingest "./samples/books.xml" do
  parser :xml
  parser_options xpath: '//book'
  #sample true
  # compressed false

  # How to map out the columns from text to AR
  map_attributes do |values|
    values['book']
  end
  
  # before{|attrs| values}

  # Your strategy for finding or instantiating a new object to be handled by the processor block
  finder{|attrs|
    # Book.find( attrs['id'] ) || Book.new
    Book.new
  }

  processor{|attrs,record|
    # ... custom processor here ...
    record.update_attributes attrs
  }
  
  after{|record| 
    puts "Created: #{record.title}"
  }
end