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
    id|name|skill_level
    1|George Washington|high
    2|Colonel Sanders|low
    3|Colonel Mustard|low
    4|Biz Markie|high
    5|Fat Blond Guy from TV|medium

  And an AR Class
    class ChickenCooker
      attr_accessible :name, :skill_level
    end

    ingest("path/to/my/chicken_skills.txt") do
      map_attributes do |values|
        {
          id:           values[0],
          name:         values[1],
          skill_level:  values[2]
        }
      end

      # current lines values
      finder{|attrs| ChickenCooker.where(id: attrs[:id]).first || ChickenCooker.new}

    end

  It can handle remote files and zip files as well.

    ingest("http://example.com/alot_of_chicken_people.zip") do
      compressed true
      map_attributes do |values|
        {
          id:           values[0],
          name:         values[1],
          skill_level:  values[2]
        }
      end

      # current lines values
      finder{|attrs| ChickenCooker.where(id: attrs[:id]).first || ChickenCooker.new}
    end


## Advanced Usage
DSL Options
  * sample - Boolean (defaults: false) will dump a single raw entry from the file to STDOUT and exit
  * includes_header - Boolean (default: false)
  * compressed - Boolean (default: false) Is the file compressed
  * without_proctection - Boolean (default: true)
  * finder - Proc, required: should return an ActiveModel object (ex: MyClass.new) to store the values in
  * before - receives attributes before call to #processor. Should return attributes hash
  * processor
  * after
  * parser Symbol [:plain_text, :xml, :json, :csv]
  * parser_options Hash (see specific parser)


## Parsers
There are 2 processors currently included. Plain Text and XML.

Support for JSON and CSV are under development.

## Plain Text Parser
  Parses a plain text document. The default delimiter is "|"

  Options
    * delimiter - String, optional
    * line_processor - Proc(string) -> Array, takes the raw line from the document and returns an array of values

## XML Parser
  Parses an XML document

  Options
    * selector (xpath selector to get the node collection)
    * encoding (See nokogiri encoding, default libmxl2 best guess)


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
* re-write this readme
* rdoc lib/ folder
* bin/ingestor sample PATH -> take a peak at an entry from the file
* Mongoid Support
* specify encoding(?)
* sort/limit options
* Disable validations option