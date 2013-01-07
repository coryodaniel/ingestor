# Ingestor

A simple DSL for importing data from text and csv files to ActiveRecord. This was originally designed to 
continually import changing data from EAN and Geonames.

## Installation

Add this line to your application's Gemfile:

    gem 'ingestor'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install ingestor

Add the following to your Rakefile
    require 'ingestor/tasks'
    
## Usage

  Given a text file
    # id|name|skill_level
    # 1|George Washington|high
    # 2|Colonel Sanders|low
    # 3|Colonel Mustard|low
    # 4|Biz Markie|high
    # 5|Fat Blond Guy from TV|medium

  And an AR Class
    class ChickenCooker
      attr_accessible :name, :skill_level
    end

    ingest("path/to/my/chicken_skills.txt") do
      column_map 0 => :id,
        1 => :name,
        2 => :skill_level

      # current lines values
      finder{|values| ChickenCooker.where(id: values[0]).first || ChickenCooker.new}

    end

  It can handle remote files and zip files as well.

    ingest("http://example.com/alot_of_chicken_people.zip") do
      column_map 0 => :id,
        1 => :name,
        2 => :skill_level

      # current lines values
      finder{|values| ChickenCooker.where(id: values[0]).first || ChickenCooker.new}
    end

## Advanced Usage
DSL Options
  1. includes_header - Boolean (default: false)
  2. without_proctection - Boolean (default: true)
  3. delimiter - String|Symbol (default: '|', supports any character and :csv, :json)
  4. line_processor - Proc
  5. finder
  6. before
  7. processor
  8. after


    ingest("file.txt") do

    end

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request

## Running Tests
  
  1. Copy spec/orm/database.example.yml => spec/orm/database.yml
  2. Configure spec/orm/database.yml
  3. 
    export db=YOUR_ADAPTER_HERE; bundle exec guard
    export db=mysql; bundle exec guard


## TODO
* bin/ingestor sample PATH --no-header --delimiter="|" -> Display what a sample row from file
* Mongoid Support
* specify encoding(?)
* JSON, CSV parsing
* Disable validations option
* lambdas as values in hash for column_map
* consider blocks that receive values receiving a set of mapped and unmapped values...