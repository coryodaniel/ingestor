module Ingestor
  module Parser
    class Csv
    end
  end
end

Ingestor::Config.register_parser :csv, Ingestor::Parser::Csv