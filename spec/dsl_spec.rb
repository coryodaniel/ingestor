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
    @dsl.instance_variable_get("@includes_header").should be(false)
  end

  it 'should expect to disable AREL protection by default' do
    @dsl.instance_variable_get("@without_protection").should be(true)
  end  

  it 'should be able to set if a header line is included' do
    @dsl.includes_header(true)
    @dsl.instance_variable_get("@includes_header").should be(true)
    @dsl.includes_header(false)
    @dsl.instance_variable_get("@includes_header").should be(false)
  end

  it 'should be able to disable AREL attribute protection' do
    @dsl.without_protection(true)
    @dsl.instance_variable_get("@without_protection").should be(true)
    @dsl.without_protection(false)
    @dsl.instance_variable_get("@without_protection").should be(false)
  end

  it 'should have a default delimiter' do
    @dsl.instance_variable_get("@delimiter").should == '|'
  end  

  it 'should be able to set a delimiter' do
    @dsl.delimiter('-')
    @dsl.instance_variable_get("@delimiter").should == '-'
  end

  it 'should be able to set the delimiter type as CSV' do
    @dsl.delimiter( :csv )
    @dsl.instance_variable_get("@delimiter").should == :csv
  end

  it 'should be able to pass a block that finds or initializes the AR object' do
    @dsl.finder {|values| }
    @dsl.instance_variable_get("@finder").should be_kind_of(Proc)
  end

  it 'should be able to override the line processor' do
    @dsl.line_processor {|line|}
    @dsl.instance_variable_get("@line_processor").should be_kind_of(Proc)
  end
  it 'should be able to override the record processor' do
    @dsl.processor {|values,record| }
    @dsl.instance_variable_get("@processor").should be_kind_of(Proc)
  end
  it 'should be able to set a before record processor block' do
    @dsl.before {|values| }
    @dsl.instance_variable_get("@before").should be_kind_of(Proc)
  end
  it 'should be able to set an after record processor block' do
    @dsl.after {|record| }
    @dsl.instance_variable_get("@after").should be_kind_of(Proc)
  end

  it 'should raise an exception if the arity is incorrect for finder' do
    lambda{
      @dsl.finder{}
    }.should raise_exception(Ingestor::Dsl::InvalidBlockSpecification)
  end

  it 'should raise an exception if the arity is incorrect for line_processor' do
    lambda{
      @dsl.line_processor{}
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

  it 'should be able to map out columns' do
    @dsl.column_map({
      0 => :id,
      1 => [:title, :description],
      2 => :created_at,
      3 => :updated_at
    })

    @dsl.instance_variable_get("@column_map").should be_kind_of(Hash)
  end

  it 'should be able to construct an Ingestor::File' do
    @dsl.finder{|values| Country.new}
    @dsl.column_map 0 => :name, 1 => :colors, 2 => :count
    @dsl.build.should be_kind_of(Ingestor::File)
  end
end