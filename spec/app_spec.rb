require 'spec_helper'

describe Alloy::App do
  let(:app){ Alloy::App }

  describe "POST /compile" do
    it 'should compile SASS' do
      post "/compile", source: "body\n  color: red", type: "sass"
      last_response.status.should == 200
    end

    it 'should compile SCSS' do
      post "/compile", source: "body {\n  color: #fff;\n}", type: "scss"
      last_response.status.should == 200
    end

    it 'should compile Less' do
      post "/compile", source: "body{ color: red; }", type: "less"
      last_response.status.should == 200
    end

    it 'should compile Stylus' do
      post "/compile", source: "body\n  color red", type: "stylus"
      last_response.status.should == 200
    end

    %w(sass scss less stylus).each do |lang|
      it "should send through accurate error messages for #{lang}" do
        post "/compile", source: "a9w378094@(@) }}", type: lang
        last_response.status.should == 400
        last_response.body.should be_include("Compilation Error")
      end
    end
  end
end