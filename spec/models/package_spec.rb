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

  context "Twitter Bootstrap" do
    subject{ Package.new(MultiJson.load(File.read('spec/support/fixtures/bootstrap.json'))) }

    it 'should compile successfully' do
      expect{ subject.compile(:bootstrap) }.not_to raise_error
    end
  end
end