# frozen_string_literal: true
require 'test_helper'

class Liquid::Tags::CdnAssetTest < ActiveSupport::TestCase

  test 'gets the correct file name' do
    Rails.configuration.three_scale.assets_cdn_host = 'https://cdn.3scale.net'
    {
      '/swagger-ui/2.2.10/swagger-ui.js' => 'https://cdn.3scale.net/swagger-ui/2.2.10/swagger-ui.js',
      '/swagger-ui/2.2.10/swagger-ui.min.js' => 'https://cdn.3scale.net/swagger-ui/2.2.10/swagger-ui.min.js',
      '/swagger-ui/2.2.10/swagger-ui.css' => 'https://cdn.3scale.net/swagger-ui/2.2.10/swagger-ui.css',
    }.each do |params, expected|
      assert_equal expected, Liquid::Tags::CdnAsset.parse('cdn_asset', params, [], {}).file
    end
  end

  test 'gets the assets files from local cdn when no config' do
    Rails.configuration.three_scale.assets_cdn_host = nil
    {
      '/swagger-ui/2.2.10/swagger-ui.js' => '/_cdn_assets_/swagger-ui/2.2.10/swagger-ui.js',
      '/swagger-ui/2.2.10/swagger-ui.min.js' => '/_cdn_assets_/swagger-ui/2.2.10/swagger-ui.min.js',
      '/bootstrap/3.0.0/bootstrap.css' => '/_cdn_assets_/bootstrap/3.0.0/bootstrap.css',
      '/bootstrap/3.0.0/bootstrap.min.js' => '/_cdn_assets_/bootstrap/3.0.0/bootstrap.min.js',
      '/jquery/jquery.colorbox-patched.js' => '/_cdn_assets_/jquery/jquery.colorbox-patched.js',
      '/3scale_v2.js' => '/_cdn_assets_/3scale_v2.js',
      '/excanvas.compiled.js' => '/_cdn_assets_/excanvas.compiled.js',
      '/default.css' => '/_cdn_assets_/default.css'
    }.each do |params, expected|
      assert_equal expected, Liquid::Tags::CdnAsset.parse('cdn_asset', params, [], {}).file
    end
  end
end
