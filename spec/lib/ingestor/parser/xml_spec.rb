require 'spec_helper'
require 'ingestor/parser/xml'

describe Ingestor::Parser::Xml do
  describe '#process!' do
    before do
      @proxy = ingest("./samples/books.xml") do
        parser :xml
        parser_options({
          xpath: '//book'
        })
        finder{|attrs| Dummy.new}
        map_attributes{|values| 
          {:name => values['book']['title']} 
        }
      end
    end
    
    it 'should be able to process an XML file' do
      Dummy.first.name.should eq "XML Developer's Guide"
    end
  end
end