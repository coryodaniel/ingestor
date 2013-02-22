module Ingestor
  module Parser
    module Base
      def self.included(base)
        base.extend(ClassMethods)
      end
      
      module ClassMethods;end;
  
      def initialize(proxy,document)
        @proxy    = proxy
        @document = document
      end
      
      def options(opts)
        @options = opts
      end

      def sample!
        raise Exception, "#sample! not implemented"
      end

      def process!
        raise Exception, "#process! not implemented"
      end
    end
  end
end