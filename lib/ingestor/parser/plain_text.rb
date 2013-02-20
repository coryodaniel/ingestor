module Ingestor
  module Parser
    class PlainText
      # process document
      # process entry
      # take options
      # default options
      def initialize(file,document)
        @file     = file
        @document = document
      end


    end
  end
end

Ingestor::Config.register_parser :plain_text, Ingestor::Parser::PlainText