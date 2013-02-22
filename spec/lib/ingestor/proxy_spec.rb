require 'spec_helper'

def default_test_ingestor
  ingest("./samples/flags.txt") do
    includes_header true
    finder{|values| Country.new}
    map_attributes{|values| {:name => values[0], :colors => values[1], :count => values[2]} }
  end
end

describe Ingestor::Proxy do
  describe 'loading local files' do
    before :each do
      @proxy = ingest("./samples/flags.txt") do
        finder{|values| Country.new}
        map_attributes{|values| {:name => values[0], :colors => values[1], :count => values[2]} }
      end
    end
    it 'should know if a file is local' do
      @proxy.should be_local
      @proxy.should_not be_remote
    end

    it 'should know if a file is compressed' do
      @proxy.should_not be_compressed
    end    
  end

  describe 'loading remote files' do
    use_vcr_cassette 'remote-zipped-files'

    before :each do
      @proxy  = ingest("https://www.ian.com/affiliatecenter/include/V2/ChainList.zip") do
        finder{|values| Dummy.new}
        map_attributes do |values|
          {:id => values[0], :name => values[1]}
        end
        compressed true
      end
    end
    it 'should know if a file is remote' do
      @proxy.should_not be_local
      @proxy.should be_remote
    end

    it 'should know if a file is compressed' do
      @proxy.should be_compressed
    end    

    it 'should create a tempfile for remote files' do
      File.exists?( @proxy.document.path ).should be true
    end    
  end

  pending '#sample'

  describe '#includes_header' do
    it 'should include a header' do
      ingest("./samples/flags.txt") do
        includes_header true
        finder{|values| Country.new}
        map_attributes{|values| {:name => values[0], :colors => values[1], :count => values[2]} }        
      end.header.should == "Country|Colors|Count|Secrets"
    end

    it 'should not include a header' do
      ingest("./samples/flags.txt") do
        includes_header false
        finder{|values| Country.new}
        map_attributes{|values| {:name => values[0], :colors => values[1], :count => values[2]} }
      end.header.should be_nil
    end    
  end

  describe '#before' do
    before :each do
      ingest("./samples/flags.txt") do
        includes_header true
        finder{|values| Country.new}
        map_attributes{|values| {:name => values[0], :colors => values[1], :count => values[2], :secrets => values[3]} }
        before{|attrs|
          attrs[:name].reverse!
          attrs
        }
      end
    end
    it 'should modify values in place when using a #before callback' do
      Country.first.name.should == 'rodavlaS lE'
    end
  end

  describe '#after' do
    before :each do
      @records = []
      ingest("./samples/flags.txt") do
        includes_header true
        finder{|values| Country.new}
        map_attributes{|values| {:name => values[0], :colors => values[1], :count => values[2], :secrets => values[3]} }
        after{|record|
          @records << record
        }
      end
    end

    it 'should pass the current record to an #after callback' do
      @records.length.should be(11)
    end
  end  

  describe '#processor' do
    before do
      ingest("./samples/flags.txt") do
        includes_header true
        finder{|values| Country.new}
        map_attributes{|values| {:name => values[0], :colors => values[1], :count => values[2], :secrets => values[3]} }
        processor{|attrs,record|
          record.update_attributes attrs
          record.secrets = "Squirrel Party"
          record.save
          record
        }
      end    
    end

    it 'should use the optional #processor when provided' do
      Country.where(secrets: 'Squirrel Party').count.should be(11)
    end
  end
end