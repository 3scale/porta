require File.expand_path(File.dirname(__FILE__) + '/../test_helper')

class ArrayTest < ActiveSupport::TestCase
  context '#to_xml method' do
    should 'not add the attr params as default' do
      xml = Nokogiri::XML::Document.parse([1,2].to_xml)

      assert xml.xpath("//integers[@type]").empty?
    end

    should 'not add the attr params if skip_types => true is passed' do
      xml = Nokogiri::XML::Document.parse([1,2].to_xml(:skip_types => true))

      assert xml.xpath("//integers[@type]").empty?
    end

    should 'add the attr params if skip_types => false is passed' do
      xml = Nokogiri::XML::Document.parse([1,2].to_xml(:skip_types => false))
      assert !xml.xpath("//integers[@type]").empty?
    end
  end
end
