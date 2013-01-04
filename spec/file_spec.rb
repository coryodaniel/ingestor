require 'spec_helper'

def default_test_ingestor
  ingest("./samples/flags.txt") do
    includes_header true
    finder{|values| Country.new}
    column_map 0 => :name, 1 => :colors, 2 => :count
  end
end

describe Ingestor::File do
  describe 'loading local files' do
    before :each do
      @file = ingest("./samples/flags.txt") do
        finder{|values| Country.new}
        column_map 0 => :name, 1 => :colors, 2 => :count
      end
    end
    it 'should know if a file is local' do
      @file.should be_local
      @file.should_not be_remote
    end

    it 'should know if a file is compressed' do
      @file.should_not be_compressed
    end    
  end

  describe 'loading remote files' do
    use_vcr_cassette 'remote-zipped-files'

    before :each do
      @file  = ingest("https://www.ian.com/affiliatecenter/include/V2/ChainList.zip") do
        finder{|values| Dummy.new}
        column_map 0 => :id, 1 => :name
      end
    end
    it 'should know if a file is remote' do
      @file.should_not be_local
      @file.should be_remote
    end

    it 'should know if a file is compressed' do
      @file.should be_compressed
    end    

    it 'should create a tempfile for remote files' do
      File.exists?( @file.working_file.path ).should be true
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
      @file = ingest("./samples/flags.txt") do
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
      @file.attribute_map(sample_values).should == {
        :name   => 'Finland',
        :colors => 'blue,white',
        :count  => '2'
      }
    end
  end

  describe '#delimiter' do
    before do
      @file = default_test_ingestor
    end

    it 'should allow the delimiter to be changed' do
      @file.delimiter = ','
      @file.process_line("Chicken,Cats,Dogs").should eq ['Chicken', 'Cats', 'Dogs']
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

  pending 'finder'
  pending 'before'
  pending 'processor'
  pending 'after'


  # describe '#finder' do
  #   before do
  #     @file = ingest("./samples/flags.txt") do
  #       finder{|values|

  #       }
  #     end
  #   end
  #   it 'should be able to provide an active model compliant object' do

  #   end
  # end

  pending 'parsing csv'
end