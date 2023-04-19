require 'test_helper'

class ThreeScale::Api::ResponderTest < ActiveSupport::TestCase

  class FakeController < ApplicationController
    include Roar::Rails::ControllerAdditions
  end

  module Representer
    include ::Roar::Representer
  end

  setup do
    @controller = FakeController.new
    @controller.stubs(:default_render).raises(ActionView::MissingTemplate.allocate)
    @controller.response = ActionDispatch::Response.new
  end

  test '#to_format PATCH' do
    @controller.formats = [:json]
    @controller.request = ActionDispatch::Request.new('REQUEST_METHOD' => 'PATCH', 'rack.input' => StringIO.new)

    responder = ThreeScale::Api::Responder.new(@controller, ['foo'], representer: Representer, plain: 'foo')

    assert responder.to_format.presence
  end
end
