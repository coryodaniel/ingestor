#   #require 'open-uri'
#   #http://nokogiri.org/tutorials/parsing_an_html_xml_document.html
#   #doc = Nokogiri::HTML(open("http://www.threescompany.com/"))
module Ingestor
  module Parser
    class Xml
    end
  end
end

Ingestor::Config.register_parser :xml, Ingestor::Parser::Xml