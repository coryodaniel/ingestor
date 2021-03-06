module Ingestor
  Proxy = Struct.new(:file, :options) do
    def document
      @document
    end
    
    def header
      @header
    end

    def remote?
      file =~ /http(s)?|ftp/i
    end

    def local?
      !remote?
    end

    def working_directory
      options[:working_directory]
    end

    def compressed?; options[:compressed]; end;

    # for debugging, testing
    def continue_from(line_num)
      @document.rewind
      @document.drop( line_num -1 ).take(1)
    end

    def finder
      options[:finder]
    end

    def start!
      load
      Ingestor::LOG.warn("No #finder specified") if !finder
      @header = @document.gets.strip if options[:includes_header]

      parser = Ingestor.parser_for( options[:parser] ).new(self, @document)
      parser.options( options[:parser_options] )

      unless options[:sample]
        parser.process!
      else
        parser.sample!
      end
            
      self
    end

    # To be called from Parsers, send a attributes, get a record
    def process_entry( attrs )
      options[:before].call(attrs) if options[:before]
            
      record = finder ? finder.call(attrs) : nil

      process_record(attrs,record)
      options[:after].call(record) if options[:after]
      record
    end

    def process_record(attrs,record)
      options[:processor] ? options[:processor].call(attrs, record) : default_processor(attrs, record)
    end

    def default_processor(attrs,record)
      record.update_attributes( attrs )
    end

    def load_remote
      Ingestor::LOG.debug("Remote file detected #{file}...")
      @document = Tempfile.new("local", working_directory)
      @document.binmode if compressed?

      open( file, 'rb' ) do |remote_file|
        Ingestor::LOG.debug("Downloading #{file}...")
        @document.write remote_file.read
        @document.rewind
      end
    end

    # When loading compressed files the assumption is that if there is more than one
    # that the files are chunked, they will be put together and treated as one large file
    def load_compressed
      Ingestor::LOG.debug("Compressed file detected #{file}...")
      @tempfile     = @document
      @document = Tempfile.new("decompressed", working_directory)
      @document.binmode
      
      Zip::ZipFile.open(@tempfile.path) do |zipfile|
        zipfile.each do |entry|
          istream = entry.get_input_stream
          @document.write istream.read
        end
      end
      @document.rewind
    end

    def load
      Dir.mkdir(working_directory, 0777) unless Dir.exists?(working_directory)

      load_remote if remote?
      load_compressed if compressed?

      @document ||= File.new( file )
    end
  end
end
