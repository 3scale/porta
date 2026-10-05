require 'test_helper'

class ThreeScale::Api::ResponderTest < ActiveSupport::TestCase
  include NPlusOneControl::MinitestHelper

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

  # --- Query count tests for the includes/preload split ---

  test 'primary_records on a relation with includes does not fire association queries' do
    service = FactoryBot.create(:simple_service)
    relation = Service.where(id: service.id).includes(:proxy, :annotations)
    responder = ThreeScale::Api::Responder.new(@controller, [relation])

    # primary_records strips includes — only the main SELECT fires, not the association SELECTs
    assert_number_of_queries(1) do
      records = responder.send(:primary_records)
      assert_equal [service.id], records.map(&:id)
    end
  end

  test 'serializable on a relation with includes fires the main query plus association preload queries' do
    service = FactoryBot.create(:simple_service)
    relation = Service.where(id: service.id).includes(:proxy, :annotations)
    responder = ThreeScale::Api::Responder.new(@controller, [relation])

    # serializable fires: 1 main query + 1 proxy preload + 1 annotations preload = 3
    assert_number_of_queries(3) do
      records = responder.send(:serializable)
      assert_equal [service.id], records.map(&:id)
    end
  end

  test 'primary_records on a pre-materialized array does not fire any queries' do
    service = FactoryBot.create(:simple_service)
    # Caller already ran the query with includes and has an Array
    materialized = Service.where(id: service.id).includes(:proxy, :annotations).to_a
    responder = ThreeScale::Api::Responder.new(@controller, [materialized])

    assert_number_of_queries(0) do
      records = responder.send(:primary_records)
      assert_equal [service.id], records.map(&:id)
    end
  end

  test 'serializable on a pre-materialized array does not fire any queries' do
    service = FactoryBot.create(:simple_service)
    materialized = Service.where(id: service.id).includes(:proxy, :annotations).to_a
    responder = ThreeScale::Api::Responder.new(@controller, [materialized])

    assert_number_of_queries(0) do
      records = responder.send(:serializable)
      assert_equal [service.id], records.map(&:id)
    end
  end

  test 'primary_records on a plain non-AR collection does not fire any queries' do
    plain = ['a', 'b', 'c']
    responder = ThreeScale::Api::Responder.new(@controller, [plain])

    assert_number_of_queries(0) do
      result = responder.send(:primary_records)
      assert_equal plain, result
    end
  end

  test 'serializable on a plain non-AR collection does not fire any queries' do
    plain = ['a', 'b', 'c']
    responder = ThreeScale::Api::Responder.new(@controller, [plain])

    assert_number_of_queries(0) do
      result = responder.send(:serializable)
      assert_equal plain, result
    end
  end
end
