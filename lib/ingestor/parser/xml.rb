#   #require 'open-uri'
#   #http://nokogiri.org/tutorials/parsing_an_html_xml_document.html
#   #doc = Nokogiri::HTML(open("http://www.threescompany.com/"))

require 'nokogiri'
require 'active_support/core_ext/hash/conversions'

module Ingestor
  module Parser
    class Xml
      include Ingestor::Parser::Base      
      def options(opts={})
        @options = {
          encoding: nil,
          xpath: nil
        }.merge(opts)
      end

      def sample!
        puts Hash.from_xml( document.xpath(@options[:xpath]).first.to_s )
      end      

      def process!
        document.xpath(@options[:xpath]).each do |node|
          node_attrs = Hash.from_xml(node.to_s)
          attrs   = @proxy.options[:map_attributes].call( node_attrs )
          @proxy.process_entry attrs
        end
      end

      protected
      def document
        Nokogiri::XML(@document, nil, @options[:encoding])
      end
    end
  end
end

Ingestor.register_parser :xml, Ingestor::Parser::Xml