#! /usr/bin/env ruby
require 'rubygems'
require 'bundler/setup'
require 'ingestor'
require 'ingestor/parser/csv'

# Set up a bogus active model
require 'active_model'
class Contract
  include ActiveModel::Naming
  def persisted?
    true
  end
  # Make a fake active model
  attr_accessor :id, :seller_name, :customer_name, :commencement_date, :termination_date
  def summary
    [:seller_name, :customer_name, :commencement_date, :termination_date].map{|key|
      send(key)
    }.join(' ')
  end
  def update_attributes(attributes = {})
    attributes.each do |name, value|
        send("#{name}=", value)
    end
    true    
  end
end
# end bogusness

ingest "./samples/contracts.csv" do
  parser :csv
  #sample true
  parser_options :headers => true
  #   :col_sep            => ",",
  #   :row_sep            => :auto,
  #   :quote_char         => '"',
  #   :field_size_limit   => nil,
  #   :converters         => nil,
  #   :unconverted_fields => nil,
  #   :return_headers     => false,
  #   :header_converters  => nil,
  #   :skip_blanks        => false,
  #   :force_quotes       => false    

  # How to map out the columns from text to AR
  map_attributes do |row|
    {
      id:                 row[0],
      seller_name:        row[1],
      customer_name:      row[2],
      commencement_date:  row[7],
      termination_date:   row[8]
    }
  end
  
  # before{|attrs| attrs}
  
  # Your strategy for finding or instantiating a new object to be handled by the processor block
  finder{|attrs|
    Contract.new
  }

  processor{|attrs,record|
    # ... custom processor here ...
    record.update_attributes attrs
  }
  
  after{|record| 
    puts "Created: #{record.summary}"
  }
end