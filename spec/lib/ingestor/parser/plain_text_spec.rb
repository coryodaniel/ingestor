require 'spec_helper'
describe Ingestor::Parser::PlainText do
  describe '#delimiter' do
    before do
      @parser = Ingestor::Parser::PlainText.new(nil,nil)
    end

    it 'should allow the delimiter to be changed' do
      @parser.options({
        delimiter: ','
      })      
      @parser.send(:process_line,"Chicken,Cats,Dogs").should eq ['Chicken', 'Cats', 'Dogs']
    end

    it 'should be able to change the line processor' do
      @parser.options({
        line_processor: lambda{|line|
          ['Something','Else']
        }
      })      
      @parser.send(:process_line,"Blue,3&4").should eq ['Something','Else']
    end
  end  
end