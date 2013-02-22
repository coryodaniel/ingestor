require 'spec_helper'
require 'ingestor/parser/csv'

describe Ingestor::Parser::Csv do
  describe '#process!' do
    before do
      @proxy = ingest("./samples/contracts.csv") do
        parser :csv
        parser_options headers: true
          
        finder{|attrs| Dummy.new}
        map_attributes{|row| 
          {
            :name => row[1]
          } 
        }
      end
    end
    
    it 'should be able to process a JSON file' do
      Dummy.first.name.should eq "The Electric Company"
    end
  end
end