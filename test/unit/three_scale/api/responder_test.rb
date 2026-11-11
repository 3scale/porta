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

  test 'paginated records skip counting for freshness and count once for serialization without reloading' do
    countries = FactoryBot.create_list(:country, 3)
    scope = Country.where(id: countries.map(&:id)).reorder(:id)

    [1, 2, 4].each do |page|
      relation = scope.paginate(page: page, per_page: 1)
      responder = ThreeScale::Api::Responder.new(@controller, [relation])
      records = nil
      queries = capture_sql_queries { records = responder.send(:primary_records) }
      assert_empty queries.grep(/\bCOUNT\s*\(/i)
      assert_equal countries.drop(page - 1).take(1).map(&:id), records.map(&:id)

      queries = capture_sql_queries do
        collection = responder.send(:serializable)
        assert_kind_of WillPaginate::Collection, collection
        assert_equal records.map(&:id), collection.map(&:id)
        assert_equal page, collection.current_page
        assert_equal 1, collection.per_page
        assert_equal 3, collection.total_entries
        assert_equal 3, collection.total_pages
        responder.send(:serializable)
      end
      assert_equal 1, queries.size, queries.join("\n")
      assert_match(/\bCOUNT\s*\(/i, queries.first)
    end
  end

  test 'partial and empty first pages infer totals without counting' do
    countries = FactoryBot.create_list(:country, 3)
    scope = Country.where(id: countries.map(&:id)).reorder(:id)
    [scope.paginate(page: 1, per_page: 4),
     scope.paginate(page: 2, per_page: 2),
     scope.none.paginate(page: 1, per_page: 2)].each do |relation|
      responder = ThreeScale::Api::Responder.new(@controller, [relation])
      queries = capture_sql_queries do
        records = responder.send(:primary_records)
        assert_equal relation.offset_value + records.size, responder.send(:serializable).total_entries
      end
      assert_empty queries.grep(/\bCOUNT\s*\(/i)
    end
  end

  test 'explicit pagination totals are preserved without counting' do
    country = FactoryBot.create(:country)
    relation = Country.where(id: country.id).paginate(page: 1, per_page: 1, total_entries: 10)
    responder = ThreeScale::Api::Responder.new(@controller, [relation])
    queries = capture_sql_queries do
      responder.send(:primary_records)
      assert_equal 10, responder.send(:serializable).total_entries
    end
    assert_empty queries.grep(/\bCOUNT\s*\(/i)
  end

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
