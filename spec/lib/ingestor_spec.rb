require 'spec_helper'
require 'ingestor/parser/xml'

describe Ingestor do
  it "should have a version" do
    Ingestor::VERSION.should_not be_nil
  end

  it 'should have plain text as the default parser' do
    Ingestor.parser_for(:plain_text).should be(Ingestor::Parser::PlainText)
    Ingestor.parser_for(:xml).should be(Ingestor::Parser::Xml)
  end

  it 'should raise an exception for a bogus parser type' do
    lambda{
      Ingestor.parser_for(:bogus)
    }.should raise_exception
  end
end