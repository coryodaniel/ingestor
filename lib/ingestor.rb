require 'docile'
require 'open-uri'
require 'csv'
require 'logger'
require 'zip/zipfilesystem'
require "ingestor/version"
require 'ingestor/config'
require 'ingestor/proxy'
require 'ingestor/dsl'
require 'ingestor/parser/plain_text'
require 'debugger'

module Ingestor
  LOG = Logger.new(STDOUT)
  LOG.level = Logger::WARN
end

def ingest(filename, &block)
  options = Ingestor::Dsl.new
  options.file = filename
  proxy = Docile.dsl_eval(options, &block).build.start!
end
