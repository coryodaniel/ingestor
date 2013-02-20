module Ingestor
  module Parser
    class Json
    end
  end
end

Ingestor::Config.register_parser :json, Ingestor::Parser::Json