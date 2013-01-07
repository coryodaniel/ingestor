# Note: http://stackoverflow.com/questions/5052512/fastest-way-to-skip-lines-while-parsing-files-in-ruby
#
module Ingestor
  File = Struct.new(:file, :includes_header, :without_protection, :delimiter, :finder, :line_processor, :processor, :before, :after, :column_map) do
    def working_file
      @working_file
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

    def compressed?
      @_compressed ||= begin
        ['.zip'].include? ::File.extname( file )
      end
    end

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
      @working_file.rewind
      @working_file.drop( line_num -1 ).take(1)
    end

    def start!
      load

      Ingestor::LOG.warn("No #finder specified") if !finder
    
      if delimiter == :csv
        # TODO, noop
      elsif delimiter == :json
        # TODO, noop
      else
        @header = @working_file.gets.strip if includes_header
        
        while line = @working_file.gets do
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
      end

      self
    end

    def process_line(line)
      line_processor ? line_processor.call(line) : default_line_processor(line)
    end

    def process_record(values,record)
      attrs = attribute_map(values)
      processor ? processor.call(attrs, record) : default_processor(attrs, record)
    end

    def default_line_processor(line)
      line.split(delimiter)
    end

    def default_processor(attrs,record)
      record.update_attributes( attrs, :without_protection => without_protection)
      record
    end

    def load_remote
      Ingestor::LOG.debug("Remote file detected #{file}...")
      @working_file = Tempfile.new("local", Config.working_directory)
      @working_file.binmode if compressed?

      open( file, 'rb' ) do |remote_file|
        Ingestor::LOG.debug("Downloading #{file}...")
        @working_file.write remote_file.read
        @working_file.rewind
      end
    end

    # When loading compressed files the assumption is that if there is more than one
    # that the files are chunked, they will be put together and treated as one large file
    def load_compressed
      Ingestor::LOG.debug("Compressed file detected #{file}...")
      @tempfile     = @working_file
      @working_file = Tempfile.new("decompressed", Config.working_directory)
      @working_file.binmode
      
      Zip::ZipFile.open(@tempfile.path) do |zipfile|
        zipfile.each do |entry|
          istream = entry.get_input_stream
          @working_file.write istream.read
        end
      end
      @working_file.rewind
    end

    def load
      load_remote if remote?
      load_compressed if compressed?

      @working_file ||= ::File.new( file )
    end
  end
end
