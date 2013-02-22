module Ingestor
  class Dsl
    class InvalidBlockSpecification < Exception;end;
    def initialize(*args)
      @options = {}
      
      includes_header(false)
      compressed(false)
      parser :plain_text
      parser_options({})
      working_directory '/tmp/ingestor'
    end

    def options
      @options
    end

    # the file to retrieve
    def file=(v);                     @file = v;end;    

    # When set to true sample will get the file and print out the first
    # set of raw values
    def sample(v)
      @options[:sample] = v
    end

    # where the file will be moved locally for processing when it is compressed or a remote file.
    # local files will not use working directory
    def working_directory(v)
      @options[:working_directory] = v
    end

    # set parser, default :plain_text
    def parser(v)
      @options[:parser] = v
    end

    # set options
    def parser_options(v)
      @options[:parser_options] = v
    end

    # skip first line?
    def includes_header(v);           @options[:includes_header] = v;end;
        
    # if the remote file is compressed, this will decompress it.
    def compressed(v);                @options[:compressed] = v;end;

    # Takes an array of values (a line/entry/node) and should return an
    # ActiveModel type object
    #
    # You do not need to set the attributes here, than is handled by #processor
    # 
    # update or create:
    # finder{|attrs| User.where(id: attrs[:id]).first || User.new}
    #
    # create:
    # finder{|attrs| User.new}
    # @required
    def finder(&block)
      if !block_given? || block.arity != 1
        raise InvalidBlockSpecification, "finder proc should have an arity of 1 (Array: values)"
      end      
      @options[:finder] = block
    end

    # How to process an entry in a file. The default takes the values and passes them to the record returned
    #  by your finder and calls update attributes
    # Proc should receive two parameters
    #   attrs - Hash, mapped attributs for this record
    #   record - ~ActiveRecord:Base, record found by #finder
    def processor(&block)
      if !block_given? || block.arity != 2
        raise InvalidBlockSpecification, "processor proc should have an arity of 2 (Array: values, ~ActiveRecord: record)"
      end      
      @options[:processor] = block
    end

    # Processing performed on the attributes before being passed to [+finder+]
    def before(&block)
      if !block_given? || block.arity != 1
        raise InvalidBlockSpecification, "before proc should have an arity of 1 (Array: values)"
      end      
      @options[:before] = block
    end

    # Processing performed on the record AFTER being passing to [+processor+]
    def after(&block)
      if !block_given? || block.arity != 1
        raise InvalidBlockSpecification, "after proc should have an arity of 1 (~ActiveRecord: record)"
      end      
      @options[:after] = block
    end

    # This method is called for each entry in the document
    # Block should receive 'values' (array for plain text, hash for all others) and return a hash
    #   of ActiveModel attribute name to value
    #
    def map_attributes(&block)
      if !block_given? || block.arity != 1
        raise InvalidBlockSpecification, "after proc should have an arity of 1 (Hash|Array: values)"
      end      
      @options[:map_attributes] = block
    end

    def build
      Ingestor::Proxy.new(@file, @options)
    end    
  end
end
