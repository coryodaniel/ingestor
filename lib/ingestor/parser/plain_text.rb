module Ingestor
  module Parser
    class PlainText
      include Ingestor::Parser::Base

      def options(opts={})
        @options = {
          :delimiter => '|',
          :line_processor => nil
        }.merge(opts)
      end

      def process!
        while line = @document.gets do
          line.chomp!    
          attrs   = @proxy.options[:map_attributes].call( process_line(line) )
          @proxy.process_entry attrs
        end
      end

      def sample!
        line = @document.gets
        line.chomp!

        puts line
      end

      protected
      # Runs the default line processor or line processor provided to options
      def process_line(line)
        if @options[:line_processor]
          @options[:line_processor].call(line)
        else
          default_line_processor(line)
        end
      end
      def default_line_processor(line)
        line.split(@options[:delimiter])
      end       
    end
  end
end

Ingestor.register_parser :plain_text, Ingestor::Parser::PlainText