require 'spec_helper'
require 'ingestor/parser/json'

describe Ingestor::Parser::Json do
  describe '#process!' do
    before do
      @proxy = ingest("./samples/people.json") do
        parser :json
        parser_options collection: lambda{|document|
          document['people']
        }
        finder{|attrs| Dummy.new}
        map_attributes{|values| 
          {
            :name => [ values['first_name'], values["last_name"] ].join(' ')
          } 
        }
      end
    end
    
    it 'should be able to process a JSON file' do
      Dummy.first.name.should eq "John Smith"
    end
  end
end