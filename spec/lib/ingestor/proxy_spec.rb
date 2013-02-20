require 'spec_helper'

def default_test_ingestor
  ingest("./samples/flags.txt") do
    includes_header true
    finder{|values| Country.new}
    column_map 0 => :name, 1 => :colors, 2 => :count
  end
end

describe Ingestor::Proxy do
  describe 'loading local files' do
    before :each do
      @proxy = ingest("./samples/flags.txt") do
        finder{|values| Country.new}
        column_map 0 => :name, 1 => :colors, 2 => :count
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
        column_map 0 => :id, 1 => :name
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

  describe '#parser' do

    it 'should be able to set the parser type' do
      true.should be(false)
    end
    it 'should have plain text as the default parser' do
      true.should be(false)
    end

  end

  describe '#includes_header' do
    it 'should include a header' do
      ingest("./samples/flags.txt") do
        includes_header true
        finder{|values| Country.new}
        column_map 0 => :name, 1 => :colors, 2 => :count        
      end.header.should == "Country|Colors|Count|Secrets"
    end

    it 'should not include a header' do
      ingest("./samples/flags.txt") do
        includes_header false
        finder{|values| Country.new}
        column_map 0 => :name, 1 => :colors, 2 => :count
      end.header.should be_nil
    end    
  end

  describe '#column_map' do
    before do
      @proxy = ingest("./samples/flags.txt") do
        includes_header true
        column_map({
          0 => :name,
          1 => :colors,
          2 => :count
        })
      end
    end

    it 'should be able to output an attributes hash' do
      sample_values = ['Finland', 'blue,white', '2']
      @proxy.attribute_map(sample_values).should == {
        :name   => 'Finland',
        :colors => 'blue,white',
        :count  => '2'
      }
    end
  end

  describe '#delimiter' do
    before do
      @proxy = default_test_ingestor
    end

    it 'should allow the delimiter to be changed' do
      @proxy.delimiter = ','
      @proxy.process_line("Chicken,Cats,Dogs").should eq ['Chicken', 'Cats', 'Dogs']
    end
  end

  describe '#without_protection' do
    it "should not set the value when using protection" do
      ingest("./samples/flags.txt") do
        includes_header true
        finder{|values| Country.new}
        column_map 0 => :name, 1 => :colors, 2 => :count, 3 => :secrets
        without_protection false
      end
      Country.where(name: 'Germany').first.secrets.should be(nil)
    end

    it "should set the value when not using protection" do
      ingest("./samples/flags.txt") do
        includes_header true
        finder{|values| Country.new}
        column_map 0 => :name, 1 => :colors, 2 => :count, 3 => :secrets
        without_protection true
      end      
      Country.where(name: 'Germany').first.secrets.should == 'fat steamy wieners'
    end    
  end

  describe '#before' do
    before :each do
      ingest("./samples/flags.txt") do
        includes_header true
        finder{|values| Country.new}
        column_map 0 => :name, 1 => :colors, 2 => :count, 3 => :secrets
        before{|values|
          values[0].reverse!
          values
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
        column_map 0 => :name, 1 => :colors, 2 => :count, 3 => :secrets
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
        column_map 0 => :name, 1 => :colors, 2 => :count, 3 => :secrets
        processor{|attrs,record|
          record.update_attributes attrs, without_protection: true
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