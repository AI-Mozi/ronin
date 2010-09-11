require 'spec_helper'
require 'ronin/engine'
require 'engine/classes/engine_class'

describe Engine do
  subject { EngineClass }

  it "should be a Model" do
    subject.included_modules.should include(Model)
  end

  it "should have a name" do
    subject.included_modules.should include(Model::HasName)
  end

  it "should have a description" do
    subject.included_modules.should include(Model::HasDescription)
  end

  it "should have a version" do
    subject.included_modules.should include(Model::HasVersion)
  end

  it "should include Platform::Cacheable" do
    subject.included_modules.should include(Platform::Cacheable)
  end

  it "should include Parameters" do
    subject.included_modules.should include(Parameters)
  end

  it "should initialize attributes" do
    resource = subject.new(:name => 'test')

    resource.name.should == 'test'
  end

  it "should initialize parameters" do
    resource = subject.new(:x => 5)

    resource.x.should == 5
  end

  it "should allow custom initialize methods" do
    resource = subject.new

    resource.y.should == 2
  end
end
