require 'csv'
module Ingestor
  module Parser
    class Csv
      include Ingestor::Parser::Base      
      def options(opts={})
        @options = {
          :col_sep            => ",",
          :row_sep            => :auto,
          :quote_char         => '"',
          :field_size_limit   => nil,
          :converters         => nil,
          :unconverted_fields => nil,
          :headers            => false,
          :return_headers     => false,
          :header_converters  => nil,
          :skip_blanks        => false,
          :force_quotes       => false          
        }.merge(opts)
      end

      def sample!
        puts CSV.parse( @document.read, @options ).first
      end      

      def process!
        CSV.parse( @document.read, @options ).each do |row|
          @proxy.process_entry @proxy.options[:map_attributes].call( row )
        end
      end      

    end
  end
end

Ingestor.register_parser :csv, Ingestor::Parser::Csv