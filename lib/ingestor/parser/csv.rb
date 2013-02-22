module Ingestor
  module Parser
    class Csv
    end
  end
end

Ingestor.register_parser :csv, Ingestor::Parser::Csv