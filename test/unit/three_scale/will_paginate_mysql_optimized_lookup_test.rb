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

    assert_number_of_queries(0) do
      relation = Country.unscoped.where(id: countries.map(&:id)).order(name: :desc).paginate(page: 2, per_page: 2)
    end

    assert_not relation.loaded?

    page = nil

    assert_number_of_queries([
                               [1, /\bWITH.+will_paginate_page_ids.+\sLIMIT\s+2\s+OFFSET\s+2.+\sSELECT\b/i],
                               [1, /\A(?![\s\S]*will_paginate_page_ids)[\s\S]*?\bCOUNT\s*\(/i]
                             ]) { page = relation.to_a }

    assert_equal countries.sort_by(&:name).reverse.drop(2).take(2).map(&:id), page.map(&:id)
    assert relation.loaded?

    assert_kind_of WillPaginate::Collection, page
    assert_equal 2, page.current_page
    assert_equal 2, page.per_page
    assert_equal 5, page.total_entries
    assert_equal 3, page.total_pages

    assert_number_of_queries(0) { relation.to_a }
  end

  test 'preloaded associations remain loaded after optimized lookup' do
    skip_unless_mysql_with_cte

    user = FactoryBot.create(:user_with_account)
    relation = User.where(id: user.id).includes(:account).paginate(page: 1, per_page: 1, total_entries: 1)
    page = nil

    assert_number_of_queries(1, matching: /will_paginate_page_ids/) { page = relation.to_a }

    assert relation.loaded?
    assert page.first.association(:account).loaded?
    assert_equal user.account_id, page.first.account.id
  end

  test 'the optimized lookup is not used for unsafe query shapes' do
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

    unsafe_relations.each_value do |base_relation|
      relation = base_relation.where(id: user.id).paginate(page: 1, per_page: 1, total_entries: 1)

      assert_number_of_queries(
        1,
        matching: /\A(?![\s\S]*will_paginate_page_ids)[\s\S]*\b(?:WITH|SELECT)\b[\s\S]*\bLIMIT\s+1\s+OFFSET\s+0\b/i
      ) { relation.to_a }
    end
  end

  test 'the optimized lookup is not used without CTE support' do
    skip_unless_mysql

    user = FactoryBot.create(:user_with_account)
    relation = User.where(id: user.id).paginate(page: 1, per_page: 1, total_entries: 1)
    relation.connection.stubs(:supports_common_table_expressions?).returns(false)

    assert_number_of_queries(
      1,
      matching: /\A(?![\s\S]*will_paginate_page_ids)[\s\S]*\bSELECT\b[\s\S]*\bLIMIT\s+1\s+OFFSET\s+0\b/i
    ) { relation.to_a }
  end

  private

  def skip_unless_mysql
    skip 'requires MySQL' unless System::Database.mysql?
  end

  def skip_unless_mysql_with_cte
    skip_unless_mysql
    skip 'requires CTE support' unless ActiveRecord::Base.connection.supports_common_table_expressions?
  end
end
