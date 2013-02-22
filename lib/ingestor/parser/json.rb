module Ingestor
  module Parser
    class Json
    end
  end
end

Ingestor.register_parser :json, Ingestor::Parser::Json