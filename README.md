# Ingestor

A simple DSL for importing data from text and csv files to ActiveRecord. This was originally designed to 
continually import changing data from EAN and Geonames.

## Installation

Add this line to your application's Gemfile:

    gem 'ingestor'

And then execute:

    $ bundle install

Or install it yourself as:

    $ gem install ingestor

Add the following to your Rakefile
    require 'ingestor/tasks'
    
## Usage

  Given a text file:

    id|name|population
    1|China|1,354,040,000
    2|India|1,210,193,422
    3|United States|315,550,000

  And an AR Class:

    class Country
      attr_accessible :name, :population
    end

  Sync the file with AR:

    ingest("path/to/countries.txt") do
      map_attributes do |values|
        {
          id:           values[0],
          name:         values[1],
          population:  values[2]
        }
      end

      # current lines values
      finder{|attrs| 
        Country.where(id: attrs[:id]).first || Country.new
      }
    end

  It can handle remote files and zip files as well.

    ingest("http://example.com/a_lot_of_countries.zip") do
      compressed true
      map_attributes do |values|
        {
          id:           values[0],
          name:         values[1],
          population:  values[2]
        }
      end

      # current lines values
      finder{|attrs| 
        Country.where(id: attrs[:id]).first || Country.new
      }
    end

  It can handle XML, JSON, and more... 

    require 'ingestor/parser/xml'
    ingest("http://example.com/books.xml") do
      parser :xml
      parser_options xpath: '//book'
      map_attributes do |values|
        {
          id:           values['id'],
          title:        values['title'],
          author:       {
            name: values['author']
          }
        }
      end

      # current lines values
      finder{|attrs| 
        Book.where(id: attrs[:id]).first || Book.new
      }

      processor{|attrs,record|
        record.update_attributes(attrs)
        record.reviews.create({
          stars: 5,
          comment: "Every book they sell is so great!"
        })
      }
    end  

  JSON Example

    require 'ingestor/parser/json'
    ingest("http://example.com/people.json") do
      parser :json
      parser_options collection: lambda{|document|
        document['people']
      }
      map_attributes do |values|
        {
          name:         values["first_name"] + " " + values["last_name"]
          age:          values['age'],
          address:      values['address']
        }
      end

      # current lines values
      finder{|attrs| 
        Person.where(name: attrs[:name]).first || Person.new
      }

      processor{|attrs,record|
        record.update_attributes(attrs)
        record.send_junk_mail!
      }
    end    


## Advanced Usage
DSL Options
  * parser - the parser to use on the file
    * Symbol
    * Optional
    * Default: :plain_text
    * Available Values: :plain_text, :xml, :json, :csv, :html
    * See 'Included Parsers' below
  * parser_options - options for a specific parser
    * Hash
    * Optional
    * Default: set per parser
    * See 'Included Parsers' below
  * sample - dump a single raw entry from the file to STDOUT and exit
    * Boolean 
    * Optional
    * Default: false
    (defaults: false) will 
  * includes_header - Tells the parser that the first line is a header and should be ignored
    * Boolean
    * Optional
    * Default: false
  * compressed - Should the file be decompressed
    * Boolean
    * Optional
    * Default: false
  * working_directory - where to store remote or decompressed files for local processing
    * String
    * Optional
    * Default: /tmp/ingestor
  * before - callback that receives attributes for each record BEFORE call to [finder]
    * Proc(attributes)
    * Optional
    * Default: nil
  * finder - Arel finder for each object
    * Proc(attributes)
    * Returns: ~ActiveModel
    * Required
  * processor - What to do with the attributes and object
    * Proc(attributes,record)
    * Returns: ~ActiveModel
    * Optional
    * Default: Proc, calls #update_attributes on record without protection
  * after - callback that receives each record after [processor]
    * Proc(record)
    * Optional  


## Included Parsers

Writing parsers is simple ([see examples](https://github.com/coryodaniel/ingestor/tree/master/lib/ingestor/parser])).

### Plain Text Parser
  Parses a plain text document.

  Options
  * delimiter - how to split up each line
    * String
    * Default: '|'
    * Optional
  * line\_processor - override default\_line\_processor. The default\_line\_processor simply splits the string using the delimiter
    * Proc(string)
    * Returns Array
    * Default: nil
    * Optional

### XML Parser
  Parses an XML document

  Options
  * selector - xpath selector to get the node collection
    * String
    * Required
  * encoding - XML Encoding. See nokogiri encoding
    * String
    * Optional
    * Default libxml2 best guess

### JSON Parser
  Parses a JSON document

  Options
  * collection - receives the document and narrows it down to the collection you are interested in
    * Proc(Hash)
    * Returns Hash | Array
    * Required

### CSV Parser
Coming soon...

### HTML Parser
Coming soon...


## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request

## Running Tests
  
  1. Copy spec/orm/database.example.yml => spec/orm/database.yml
  2. Configure spec/orm/database.yml
  3. bundle exec guard


## Todos
* Deprecate plain_text 
* rdoc http://rdoc.rubyforge.org/RDoc/Markup.html
* Move includes_header to CSV, PlainText
* Mongoid Support
* sort/limit options
* configure travis
* A way to sample a file without building an ingestor first
  * bin/ingestor --sample --path=./my.xml --parser xml --parser_options_xpath '//book'