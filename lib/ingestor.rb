require 'docile'
require 'open-uri'
require 'csv'
require 'logger'
require 'zip/zipfilesystem'
require 'ingestor/version'
require 'ingestor/proxy'
require 'ingestor/dsl'

#require 'debugger'

module Ingestor
  LOG = Logger.new(STDOUT)
  LOG.level = Logger::WARN
  class << self
    def parsers
      @parsers ||= {}
    end
    def register_parser(kind, klass)
      parsers[kind] = klass
    end

    def parser_for(kind)
      raise Exception, "No parser for type #{kind}" if parsers[kind].nil?
      parsers[kind]
    end  
  end
end

def ingest(filename, &block)
  options = Ingestor::Dsl.new
  options.file = filename
  proxy = Docile.dsl_eval(options, &block).build.start!
end

require 'ingestor/parser/base'
require 'ingestor/parser/plain_text'