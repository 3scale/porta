require File.expand_path(File.dirname(__FILE__) + '/../test_helper')

class ArrayTest < ActiveSupport::TestCase
  context '#to_xml method' do
    setup do
      @version = Gem::Version.new(RUBY_VERSION)
      @ruby_24 = Gem::Version.new('2.4.0')
    end

    should 'not add the attr params as default' do
      xml = Nokogiri::XML::Document.parse([1,2].to_xml)

      if @version < @ruby_24
        assert xml.xpath("//fixnums[@type]").empty?
      else
        assert xml.xpath("//integers[@type]").empty?
      end
    end

    should 'not add the attr params if skip_types => true is passed' do
      xml = Nokogiri::XML::Document.parse([1,2].to_xml(:skip_types => true))
      if @version < @ruby_24
        assert xml.xpath("//fixnums[@type]").empty?
      else
        assert xml.xpath("//integers[@type]").empty?
      end
    end

    should 'add the attr params if skip_types => false is passed' do
      xml = Nokogiri::XML::Document.parse([1,2].to_xml(:skip_types => false))
      if @version < @ruby_24
        assert !xml.xpath("//fixnums[@type]").empty?
      else
        assert !xml.xpath("//integers[@type]").empty?
      end
    end
  end
end
