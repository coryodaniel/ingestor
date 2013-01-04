module Ingestor
  class Dsl
    class InvalidBlockSpecification < Exception;end;
    def initialize(*args)
      includes_header(false)
      without_protection(true)
      delimiter '|'
    end

    def file=(v);                     @file = v;end;

    # skip first line?
    def includes_header(v);           @includes_header = v;end;
    def without_protection(v);        @without_protection = v;end;
    def delimiter(v);                 @delimiter = v;end;
    
    # Takes an array of values (a line) and should return an
    # ActiveModel type object
    #
    # You do not need to set the attributes here, than is handled by #processor
    # 
    # update or create:
    # finder{|values| User.where(id: values[0]).first || User.new}
    #
    # create:
    # finder{|values| User.new}
    def finder(&block)
      if !block_given? || block.arity != 1
        raise InvalidBlockSpecification, "finder proc should have an arity of 1 (Array: values)"
      end      
      @finder = block
    end

    # receives line, returns array
    # Optional, only used if using a text delimiter
    # ie, wont be used for :json,or :csv
    def line_processor(&block)
      if !block_given? || block.arity != 1
        raise InvalidBlockSpecification, "line_processor proc should have an arity of 1 (String: line)"
      end
      @line_processor = block
    end

    def processor(&block)
      if !block_given? || block.arity != 2
        raise InvalidBlockSpecification, "processor proc should have an arity of 2 (Array: values, ~ActiveRecord: record)"
      end      
      @processor = block
    end

    def before(&block)
      if !block_given? || block.arity != 1
        raise InvalidBlockSpecification, "before proc should have an arity of 1 (Array: values)"
      end      
      @before = block
    end

    def after(&block)
      if !block_given? || block.arity != 1
        raise InvalidBlockSpecification, "after proc should have an arity of 1 (~ActiveRecord: record)"
      end      
      @after = block
    end

    # text file index => AR's attribute name or array of names
    # id|date
    # 3030|2012-12-12
    # 0 => :id
    # 1 => [:created_at, :updated_at]    
    def column_map(v)
      @column_map = v
    end

    def build
      Ingestor::File.new(@file, @includes_header, @without_protection, @delimiter, @finder, @line_processor, @processor, @before, @after, @column_map)
    end    
  end
end
