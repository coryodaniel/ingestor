module Ingestor
  class Config
    class << self
      def working_directory
        @working_directory || "/tmp/ingestor"
      end

      def working_directory=(path)
        @working_directory = path
      end
    end    
  end
end
