# frozen_string_literal: true
require 'test_helper'

class Liquid::Tags::CdnAssetTest < ActiveSupport::TestCase
  test 'gets the correct file name' do
    Rails.configuration.three_scale.asset_host = nil
    {
      '/swagger-ui/2.2.10/swagger-ui.js' => '/dev-portal-assets/swagger-ui/2.2.10/swagger-ui.js',
      '/swagger-ui/2.2.10/swagger-ui.min.js' => '/dev-portal-assets/swagger-ui/2.2.10/swagger-ui.min.js',
    }.each do |params, expected|
      template = Liquid::Template.parse("{% cdn_asset #{params} %}")
      tag = template.root.nodelist.first

      assert_instance_of Liquid::Tags::CdnAsset, tag
      assert_equal expected, tag.file
    end
  end
end
