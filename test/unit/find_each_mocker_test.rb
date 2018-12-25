require 'test_helper'

class FindEachMockerTest < ActiveSupport::TestCase
  def setup
    @items = FactoryBot.create_list(:line_item, 31)
    @items.sort_by(&:id)
    @batch = FindEachMocker.new(LineItem.all.order(id: :asc), per_page: 5, page: 1)
  end

  test '#find_in_batches' do
    assert_equal 7, @batch.total_pages
    assert_equal 31, @batch.total_entries

    results = []

    find_in_batches = @batch.find_in_batches
    assert_equal 7, find_in_batches.size

    6.times do
      records = find_in_batches.next
      records.load
      assert_equal 5, records.size
      results.concat(records)
    end

    records = find_in_batches.next
    records.load
    assert_equal 1, records.size
    results.concat(records)

    assert_raise(StopIteration) { find_in_batches.next }
    assert_equal @items, results
  end

  test '#find_each' do
    find_each = @batch.find_each
    assert_equal 31, find_each.size

    31.times do |i|
      assert_equal @items[i], find_each.next
    end

    assert_raise(StopIteration) { find_each.next }
  end
end
