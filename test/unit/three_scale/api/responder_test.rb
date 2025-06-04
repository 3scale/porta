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
  end

  test '#to_format PATCH' do
    @controller.formats = [:json]
    @controller.request = ActionDispatch::Request.new('REQUEST_METHOD' => 'PATCH', 'rack.input' => StringIO.new)
    @controller.set_response! ActionDispatch::Response.new

    responder = ThreeScale::Api::Responder.new(@controller, ['foo'], representer: Representer, plain: 'foo')

    assert responder.to_format.presence
  end

  test 'resources ordered by id if order is not set' do
    [3,1,2].each { |id| FactoryBot.create(:user, id: id) }
    resources = User.all
    responder = ThreeScale::Api::Responder.new(@controller, [resources])
    serializable = responder.send(:serializable)
    assert_equal [1,2,3], serializable.map(&:id)
  end

  test 'resources order is preserved when set explicitly' do
    [[1, "zzz"], [2, "aaa"], [3, "fff"]].each { |id, username| FactoryBot.create(:user, id: id, username: username) }
    resources = User.all.order(:username)
    responder = ThreeScale::Api::Responder.new(@controller, [resources])
    serializable = responder.send(:serializable)
    assert_equal [2,3,1], serializable.map(&:id)
  end
end
