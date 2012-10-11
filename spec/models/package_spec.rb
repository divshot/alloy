require 'spec_helper'

describe Package do
  subject{ build(:package) }
  
  describe '#style' do
    it 'should retrieve a style by name' do
      subject.style(subject.styles.first.name).should == subject.styles.first
    end

    it 'should be nil if it cannot find the named style' do
      subject.style(:poppycock).should be_nil
    end
  end

  context "Twitter Bootstrap Integration" do
    subject{ Package.new(MultiJson.load(File.read('spec/support/fixtures/bootstrap.json'))) }

    it 'should compile successfully' do
      expect{ subject.compile(:bootstrap) }.not_to raise_error
    end

    it 'should include variables' do
      output = subject.compile(:bootstrap, "variables" => {"linkColor" => "#123456"})
      output.should be_include("#123456")
    end

    it 'should compress if that option is passed' do
      subject.compile(:bootstrap, compress: true).size.should < subject.compile(:bootstrap).size
    end
  end

  describe '#version_string' do
    it 'should join version segments with periods' do
      subject.version = [2,1,1]
      subject.version_string.should == "2.1.1"
    end

    it 'should just return a string' do
      subject.version = "1.0"
      subject.version_string.should == "1.0"
    end
  end
end