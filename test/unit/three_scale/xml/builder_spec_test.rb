require 'minitest_helper'

require 'test/test_helpers/xml_assertions'
require 'active_support/json/encoding'

describe ThreeScale::XML::Builder do
  include TestHelpers::XmlAssertions

  let(:builder) { ThreeScale::XML::Builder.new }

  it "works with hash" do
    object = { :key => 'value' }
    options = {:root => 'hash', :builder => builder }

    assert_equal_xml "<hash><key>value</key></hash>",
                     object.to_xml(options)
  end

  it "yields initial block" do
    builder = ThreeScale::XML::Builder.new do |xml|
      xml.root do
        xml.element
      end
    end

    assert_equal_xml "<root><element/></root>",
      builder.to_xml
  end

  it "builds element even is symbol is passed" do
    builder.root do |xml|
      xml.period :week
    end

    assert_equal_xml "<root><period>week</period></root>",
      builder.to_xml
  end

  it "builds xml" do
    builder.root do
      builder.element 'value'
    end

    assert_equal_xml "<root><element>value</element></root>",
                     builder.to_xml

  end

  it "has << method" do
    builder.root do |xml|
      xml << "<element/>"
    end

    assert_equal_xml "<root><element/></root>",
      builder.to_xml
  end

  it "has tag! method" do
    builder.root do
      builder.tag!('what-ever', attr: 'value') do
        builder.nested
      end
    end

    assert_equal_xml "<root><what-ever attr='value'><nested/></what-ever></root>",
      builder.to_xml
  end

  describe "xml object" do
    let(:xml) { builder.to_xml }
    let(:builder) do
      ThreeScale::XML::Builder.new do |xml|
        xml.root do |xml|
          xml.attribute "value"
        end
      end
    end

    it "delegates useful methods" do
      builder.to_s.must_equal(xml)
      builder.to_str.must_equal(xml)
      builder.as_json.must_equal(xml)
    end
  end
end
