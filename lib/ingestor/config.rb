module Ingestor
  class Config
    class << self
      def working_directory
        @working_directory || "/tmp/ingestor"
      end

      def working_directory=(path)
        raise Exception, "Ingestor::Config.working_directory already set" if @working_directory
        @working_directory ||= path
      end

      def ensure_path!
        unless Dir.exists?(working_directory)
          Dir.mkdir(working_directory, 0777)
        end
      end
    end    
  end
end