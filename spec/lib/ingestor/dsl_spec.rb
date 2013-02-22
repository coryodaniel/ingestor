require 'spec_helper'
describe Ingestor::Dsl do
  before :each do
    @dsl = Ingestor::Dsl.new
  end
  it 'should be able to set the file path' do
    @dsl.file = "file.txt"
    @dsl.instance_variable_get("@file").should == "file.txt"
  end

  it 'should not expect a header by default' do
    @dsl.options[:includes_header].should be(false)
  end

  it 'should expect to disable AREL protection by default' do
    @dsl.options[:without_protection].should be(true)
  end  

  it 'should be able to set if a header line is included' do
    @dsl.includes_header(true)
    @dsl.options[:includes_header].should be(true)
    @dsl.includes_header(false)
    @dsl.options[:includes_header].should be(false)
  end

  it 'should be able to mark a file as compressed' do
    @dsl.compressed(true)
    @dsl.options[:compressed].should be(true)
    
    @dsl.compressed(false)
    @dsl.options[:compressed].should be(false)
  end

  it 'should be able to disable AREL attribute protection' do
    @dsl.without_protection(true)
    @dsl.options[:without_protection].should be(true)
    
    @dsl.without_protection(false)
    @dsl.options[:without_protection].should be(false)
  end

  it 'should be able to specify the parser' do
    @dsl.parser( :plain_text )
    @dsl.options[:parser].should == :plain_text
  end

  it 'should be able to pass a block that finds or initializes the AR object' do
    @dsl.finder {|values| }
    @dsl.options[:finder].should be_kind_of(Proc)
  end

  it 'should be able to override the record processor' do
    @dsl.processor {|values,record| }
    @dsl.options[:processor].should be_kind_of(Proc)
  end
  it 'should be able to set a before record processor block' do
    @dsl.before {|values| }
    @dsl.options[:before].should be_kind_of(Proc)
  end
  it 'should be able to set an after record processor block' do
    @dsl.after {|record| }
    @dsl.options[:after].should be_kind_of(Proc)
  end

  it 'should raise an exception if the arity is incorrect for finder' do
    lambda{
      @dsl.finder{}
    }.should raise_exception(Ingestor::Dsl::InvalidBlockSpecification)
  end

  it 'should raise an exception if the arity is incorrect for processor' do
    lambda{
      @dsl.processor{}
    }.should raise_exception(Ingestor::Dsl::InvalidBlockSpecification)
  end

  it 'should raise an exception if the arity is incorrect for before' do
    lambda{
      @dsl.before{}
    }.should raise_exception(Ingestor::Dsl::InvalidBlockSpecification)
  end

  it 'should raise an exception if the arity is incorrect for after' do
    lambda{
      @dsl.after{}
    }.should raise_exception(Ingestor::Dsl::InvalidBlockSpecification)
  end  

  it 'should raise an exception if the arity is incorrect for map_attributes' do
    lambda{
      @dsl.map_attributes{}
    }.should raise_exception(Ingestor::Dsl::InvalidBlockSpecification)
  end    

  it 'should be able to map out columns' do
    @dsl.map_attributes do |values|
      {
        :id => values[0],
        :name => values[1],
        :color => values[2]
      }
    end
    @dsl.options[:map_attributes].call([1,'Hat','Blue'])[:name].should eq('Hat')
  end

  it 'should be able to construct an Ingestor::Proxy' do
    @dsl.finder{|values| Country.new}
    @dsl.map_attributes do |values|
      {
        :name => values[0],
        :colors => values[1],
        :count  => values[2]
      }
    end
    @dsl.build.should be_kind_of(Ingestor::Proxy)
  end
end