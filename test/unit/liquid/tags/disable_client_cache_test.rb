# frozen_string_literal: true

require 'test_helper'

class Liquid::Tags::DisableClientCacheTest < ActiveSupport::TestCase
  def setup
    @context = Liquid::Context.new
    @context.registers[:controller] = ApplicationController.new
    @context.registers[:controller].response = ActionDispatch::Response.new
    @disable_client_cache = Liquid::Tags::DisableClientCache.parse 'disable_client_cache', '', [], {}
  end

  test "page should not cache" do
    @disable_client_cache.render(@context)
    response = @context.registers[:controller].response

    assert_equal 'no-store', response.headers['Cache-Control']
    assert_equal 'no-cache', response.headers['Pragma']
    assert_equal 'Mon, 01 Jan 1990 00:00:00 GMT', response.headers['Expires']
  end
end
