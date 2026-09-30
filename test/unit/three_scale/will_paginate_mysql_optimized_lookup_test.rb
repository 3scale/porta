# frozen_string_literal: true

require 'test_helper'
require 'will_paginate/active_record'
require 'three_scale/will_paginate_mysql_optimized_lookup'

class ThreeScale::WillPaginateMysqlOptimizedLookupTest < ActiveSupport::TestCase
  test 'the optimized lookup is prepended only for MySQL' do
    relation_methods = WillPaginate::ActiveRecord::RelationMethods
    optimized_lookup_is_prepended = relation_methods.ancestors.include?(ThreeScale::WillPaginateMysqlOptimizedLookup)

    assert_equal System::Database.mysql?, optimized_lookup_is_prepended
  end

  test 'paginated relations stay lazy and load the requested page through a CTE' do
    skip_unless_mysql_with_cte

    prefix = "optimized-lookup-#{SecureRandom.hex(8)}"
    countries = (1..5).map do |number|
      FactoryBot.create(:country, name: "#{prefix}-#{number}")
    end
    relation = nil

    queries = capture_sql_queries do
      relation = Country.unscoped.where(id: countries.map(&:id)).order(name: :desc).paginate(page: 2, per_page: 2)
    end

    assert_empty queries
    assert_not relation.loaded?

    page = nil
    queries = capture_sql_queries { page = relation.to_a }
    optimized_lookup_query = queries.find { |sql| sql.include?('will_paginate_page_ids') }

    assert_not_nil optimized_lookup_query
    assert_match(/\bLIMIT\s+2\s+OFFSET\s+2\b/i, optimized_lookup_query)
    assert_equal 1, optimized_lookup_query.scan(/\bLIMIT\b/i).length
    assert_equal 1, optimized_lookup_query.scan(/\bOFFSET\b/i).length
    assert_equal countries.sort_by(&:name).reverse.drop(2).take(2).map(&:id), page.map(&:id)
    assert relation.loaded?

    assert_kind_of WillPaginate::Collection, page
    assert_equal 2, page.current_page
    assert_equal 2, page.per_page
    assert_equal 5, page.total_entries
    assert_equal 3, page.total_pages

    count_query = queries.find { |sql| sql.match?(/\bCOUNT\s*\(/i) }
    assert_not_nil count_query
    assert_not_includes count_query, 'will_paginate_page_ids'

    assert_empty(capture_sql_queries { relation.to_a })
  end

  test 'preloaded associations remain loaded after optimized lookup' do
    skip_unless_mysql_with_cte

    user = FactoryBot.create(:user_with_account)
    relation = User.where(id: user.id).includes(:account).paginate(page: 1, per_page: 1, total_entries: 1)
    page = nil

    queries = capture_sql_queries { page = relation.to_a }

    assert(queries.any? { |sql| sql.include?('will_paginate_page_ids') })
    assert relation.loaded?
    assert page.first.association(:account).loaded?
    assert_equal user.account_id, page.first.account.id
  end

  test 'unsafe query shapes use WillPaginate pagination SQL' do
    skip_unless_mysql

    user = FactoryBot.create(:user_with_account)
    unsafe_relations = {
      'custom select' => User.select(:id),
      'inner join' => User.joins(:account),
      'left outer join' => User.left_joins(:account),
      'eager load' => User.eager_load(:account),
      'grouping' => User.select(:state).group(:state),
      'having' => User.select(:state).group(:state).having('COUNT(*) > 0'),
      'distinct' => User.distinct,
      'custom from' => User.from('users'),
      'lock' => User.lock
    }
    unsafe_relations['existing CTE'] = User.with(other_users: User.select(:id)) if User.connection.supports_common_table_expressions?

    unsafe_relations.each do |description, base_relation|
      relation = base_relation.where(id: user.id).paginate(page: 1, per_page: 1, total_entries: 1)
      queries = capture_sql_queries { relation.to_a }
      select_query = queries.find { |sql| sql.match?(/\b(?:WITH|SELECT)\b/i) }

      assert_not_nil select_query, "#{description} should execute a query"
      assert_not_includes select_query, 'will_paginate_page_ids', description
      assert_match(/\bLIMIT\s+1\s+OFFSET\s+0\b/i, select_query, description)
    end
  end

  test 'adapters without CTE support use WillPaginate pagination SQL' do
    skip_unless_mysql

    user = FactoryBot.create(:user_with_account)
    relation = User.where(id: user.id).paginate(page: 1, per_page: 1, total_entries: 1)
    relation.connection.stubs(:supports_common_table_expressions?).returns(false)

    queries = capture_sql_queries { relation.to_a }
    select_query = queries.find { |sql| sql.match?(/\bSELECT\b/i) }

    assert_not_nil select_query
    assert_not_includes select_query, 'will_paginate_page_ids'
    assert_match(/\bLIMIT\s+1\s+OFFSET\s+0\b/i, select_query)
  end

  private

  def skip_unless_mysql
    skip 'requires MySQL' unless System::Database.mysql?
  end

  def skip_unless_mysql_with_cte
    skip_unless_mysql
    skip 'requires CTE support' unless ActiveRecord::Base.connection.supports_common_table_expressions?
  end

  def capture_sql_queries(&)
    queries = []
    callback = ->(_name, _start, _finish, _id, payload) do
      name, sql = payload.values_at(:name, :sql)
      queries << sql unless name == 'SCHEMA'
    end

    ActiveSupport::Notifications.subscribed(callback, 'sql.active_record', &)
    queries
  end
end
