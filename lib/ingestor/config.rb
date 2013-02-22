module Ingestor
  class Config
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

      def output_directory
        'script/ingestors'
      end
      def working_directory
        @working_directory || "/tmp/ingestor"
      end

      def working_directory=(path)
        raise Exception, "Ingestor::Config.working_directory already set" if @working_directory
        @working_directory ||= path
      end

      def ensure_output_directory!
        unless Dir.exists?(output_directory)
          FileUtils.mkdir_p(output_directory, mode: 0755)
        end
      end

      def ensure_working_directory!
        unless Dir.exists?(working_directory)
          Dir.mkdir(working_directory, 0777)
        end
      end
    end    
  end
end