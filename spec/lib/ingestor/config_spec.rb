require 'spec_helper'
describe Ingestor::Config do
  it 'should have plain text as the default parser' do
    Ingestor::Config.parser_for(:plain_text).should be(Ingestor::Parser::PlainText)
    Ingestor::Config.parser_for(:bogus).should be(Ingestor::Parser::PlainText)
  end
end