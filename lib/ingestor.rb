require 'docile'
require 'open-uri'
require 'csv'
require 'logger'
require 'zip/zipfilesystem'
require "ingestor/version"
require 'ingestor/config'
require 'ingestor/file'
require 'ingestor/dsl'
require 'debugger'

module Ingestor
  LOG = Logger.new(STDOUT)
  LOG.level = Logger::WARN
end

def ingest(filename, &block)
  parser = Ingestor::Dsl.new
  parser.file = filename
  file = Docile.dsl_eval(parser, &block).build

  file.start!
end
