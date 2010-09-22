require File.join(File.dirname(__FILE__), 'spec_helper')

describe Bitcache::Encoder do
  it "should not be instantiable" do
    lambda { Bitcache::Encoder.new }.should raise_error(NoMethodError)
  end

  context "base-16" do
    before(:each) { @encoder = Bitcache::Encoder::Base16 }

    it "should be supported" do
      Bitcache::Encoder.for(:base16).should be_a_kind_of(Class)
      Bitcache::Encoder.for(:base16).should == @encoder
    end

    it "should have a base of 16" do
      @encoder.base.should == 16
    end

    it "should have 16 digits" do
      @encoder.digits.should be_instance_of(Array)
      @encoder.digits.size.should == 16
    end

    it "should encode identifiers" do
      @encoder.encode(  0).should be_a(String)
      @encoder.encode(  0).should == '0'
      @encoder.encode( 15).should == 'f'
      @encoder.encode(255).should == 'ff'
    end

    it "should decode identifiers" do
      @encoder.decode('0' ).should be_an(Integer)
      @encoder.decode('0' ).should == 0
      @encoder.decode('f' ).should == 15
      @encoder.decode('ff').should == 255
    end
  end

  context "base-62" do
    before(:each) { @encoder = Bitcache::Encoder::Base62 }

    it "should be supported" do
      Bitcache::Encoder.for(:base62).should be_a_kind_of(Class)
      Bitcache::Encoder.for(:base62).should == @encoder
    end

    it "should have a base of 62" do
      @encoder.base.should == 62
    end

    it "should have 62 digits" do
      @encoder.digits.should be_instance_of(Array)
      @encoder.digits.size.should == 62
    end

    it "should encode identifiers"
    it "should decode identifiers"
  end

  context "base-94" do
    before(:each) { @encoder = Bitcache::Encoder::Base94 }

    it "should be supported" do
      Bitcache::Encoder.for(:base94).should be_a_kind_of(Class)
      Bitcache::Encoder.for(:base94).should == @encoder
    end

    it "should have a base of 94" do
      @encoder.base.should == 94
    end

    it "should have 94 digits" do
      @encoder.digits.should be_instance_of(Array)
      @encoder.digits.size.should == 94
    end

    it "should encode identifiers"
    it "should decode identifiers"
  end

  context "others" do
    it "should not be supported" do
      Bitcache::Encoder.for(:none).should be_nil
    end
  end
end
