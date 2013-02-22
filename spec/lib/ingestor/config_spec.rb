require 'spec_helper'
require 'ingestor/parser/xml'
describe Ingestor::Config do
  it 'should have plain text as the default parser' do
    Ingestor::Config.parser_for(:plain_text).should be(Ingestor::Parser::PlainText)
    Ingestor::Config.parser_for(:xml).should be(Ingestor::Parser::Xml)
  end

  it 'should raise an exception for a bogus parser type' do
    lambda{
      Ingestor::Config.parser_for(:bogus)
    }.should raise_exception
  end
end