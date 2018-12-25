require 'test_helper'

class Liquid::Drops::PaginationDropTest < ActiveSupport::TestCase
  include Liquid

  def setup
    10.times { FactoryBot.create(:invoice) }
    @url_builder = Object.new

    @url_builder.stubs params: {}
    def @url_builder.url_for(params)
      params.to_param
    end
  end

  test 'in the middle' do
    drop = Drops::Pagination.new(Invoice.paginate(page: 2, per_page: 3), @url_builder)
    assert_equal 3, drop.page_size

    assert_equal 1, drop.previous
    assert_equal 2, drop.current_page
    assert_equal 3, drop.next

    assert_equal 3, drop.current_offset
    assert_equal 4, drop.pages
  end

  test 'head' do
    drop = Drops::Pagination.new(Invoice.paginate(page: 1, per_page: 3), @url_builder)
    assert_nil drop.previous
    assert_equal 1, drop.current_page
    assert_equal 2, drop.next
  end

  test 'tail' do
    drop = Drops::Pagination.new(Invoice.paginate(page: 4, per_page: 3), @url_builder)
    assert_equal 3, drop.previous
    assert_equal 4, drop.current_page
    assert_nil drop.next
  end


  test 'parts' do
    drop = Drops::Pagination.new(Invoice.paginate(page: 3, per_page: 1), @url_builder)

    assert_equal %w( Previous 1 2 3 … 10 Next ), drop.parts.map(&:title)

    current = drop.parts[3]
    assert_equal false, current.is_link
  end
end
