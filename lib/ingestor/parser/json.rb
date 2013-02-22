require 'multi_json'
require 'debugger'
module Ingestor
  module Parser
    class Json
      include Ingestor::Parser::Base      
      def options(opts={})
        @options = {
          collection: nil
        }.merge(opts)
      end

      def sample!
        puts @options[:collection].call(document).first
        #puts @options[:collection] ? @options[:collection].call(document).first : document.first
      end      

      def process!
        @options[:collection].call(document).each do |attrs|
          @proxy.process_entry @proxy.options[:map_attributes].call( attrs )
        end
      end      

      protected

      def document
        MultiJson.load(@document.read)
      end
    end
  end
end

Ingestor.register_parser :json, Ingestor::Parser::Json