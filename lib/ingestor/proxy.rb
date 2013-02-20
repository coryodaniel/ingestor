# Note: http://stackoverflow.com/questions/5052512/fastest-way-to-skip-lines-while-parsing-files-in-ruby
#
module Ingestor
  Proxy = Struct.new(:file, :includes_header, :without_protection, :delimiter, :finder, :entry_processor, :processor, :before, :after, :column_map, :compressed) do
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

    def compressed?; compressed; end;

    def attribute_map(values)
      row_attributes = {}
      column_map.each do |k,v|
        [v].flatten.each do |attrib|
          row_attributes[attrib] = values[k]
        end
      end

      row_attributes
    end

    # for debugging, testing
    def continue_from(line_num)
      @document.rewind
      @document.drop( line_num -1 ).take(1)
    end

    def start!
      load
      Ingestor::LOG.warn("No #finder specified") if !finder
      @header = @document.gets.strip if includes_header

      #@file_parser = Ingestor::Config.parser_for( parser ).new(self, @document)
      
      while line = @document.gets do
        line.chomp!    
        values = process_line(line)
        
        values = before ? before.call(values) : values
        record = finder ? finder.call(values) : nil

        if record && record.class.ancestors.count{|r| r.to_s =~ /ActiveModel/} > 0
          record = process_record(values,record)
          after ? after.call(record) : record
        else
          Ingestor::LOG.warn("Processing skipped, ActiveModel type record not returned for #{values.join(',')}")
        end
      end
      
      self
    end

    def process_line(line)
      entry_processor ? entry_processor.call(line) : default_entry_processor(line)
    end

    def process_record(values,record)
      attrs = attribute_map(values)
      processor ? processor.call(attrs, record) : default_processor(attrs, record)
    end

    def default_entry_processor(line)
      line.split(delimiter)
    end

    def default_processor(attrs,record)
      record.update_attributes( attrs, :without_protection => without_protection)
      record
    end

    def load_remote
      Ingestor::LOG.debug("Remote file detected #{file}...")
      @document = Tempfile.new("local", Config.working_directory)
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
      @document = Tempfile.new("decompressed", Config.working_directory)
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
      load_remote if remote?
      load_compressed if compressed?

      @document ||= ::File.new( file )
    end
  end
end
