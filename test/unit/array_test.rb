# frozen_string_literal: true

require 'test_helper'

class ArrayTest < ActiveSupport::TestCase
  test '#to_xml not add the attr params as default' do
    xml = Nokogiri::XML::Document.parse([1,2].to_xml)
    assert xml.xpath("//integers[@type]").empty?
  end

  test '#to_xml not add the attr params if skip_types => true is passed' do
    xml = Nokogiri::XML::Document.parse([1,2].to_xml(skip_types: true))
    assert xml.xpath("//integers[@type]").empty?
  end

  test '#to_xml add the attr params if skip_types => false is passed' do
    xml = Nokogiri::XML::Document.parse([1,2].to_xml(skip_types: false))
    assert_not xml.xpath("//integers[@type]").empty?
  end
end
