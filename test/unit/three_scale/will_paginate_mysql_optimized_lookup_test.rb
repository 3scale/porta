# frozen_string_literal: true

require 'test_helper'
require 'will_paginate/active_record'
require 'three_scale/will_paginate_mysql_optimized_lookup'

# Runs on any database, to check that the optimized lookup is used only with MySQL.
class ThreeScale::WillPaginateMysqlOptimizedLookupPrependTest < ActiveSupport::TestCase
  test 'the optimized lookup is prepended only for MySQL' do
    relation_methods = WillPaginate::ActiveRecord::RelationMethods
    optimized_lookup_is_prepended = relation_methods.ancestors.include?(ThreeScale::WillPaginateMysqlOptimizedLookup)

    assert_equal System::Database.mysql?, optimized_lookup_is_prepended
  end
end

class ThreeScale::WillPaginateMysqlOptimizedLookupTest < ActiveSupport::TestCase
  setup do
    skip 'requires MySQL' unless System::Database.mysql?
  end

  # The code paths of the optimized lookup.
  PATHS = {
    cte: 'CTE',
    split_with_joins: 'split queries (relation with joins)',
    split_without_cte: 'split queries (no joins, CTE unsupported)'
  }.freeze

  # Names are assigned in id order so that filtering and ordering by name give a different page than plain id order.
  ACCOUNT_NAMES = %w[n-b n-d n-a n-c].freeze

  test 'paginated relations stay lazy and load the requested page through a CTE' do
    skip_unless_cte_support

    prefix = "optimized-lookup-#{SecureRandom.hex(8)}"
    countries = (1..5).map do |number|
      FactoryBot.create(:country, name: "#{prefix}-#{number}")
    end
    relation = nil

    # The default `matching` is SELECT only, which would miss the CTE (WITH ...), so any query is counted.
    assert_number_of_queries(0, matching: /./) do
      relation = Country.unscoped.where(id: countries.map(&:id)).order(name: :desc).paginate(page: 2, per_page: 2)
    end

    assert_not relation.loaded?

    page = nil
    queries = capture_sql_queries { page = relation.to_a }

    assert_equal 1, queries.grep(/\bWITH.+will_paginate_page_ids.+\sLIMIT\s+2\s+OFFSET\s+2.+\sSELECT\b/i).size
    # MySQL may read the tables of the join in either order, so the order of the page is guaranteed only by the
    # ORDER BY of the outer query, after the JOIN of the CTE.
    assert_equal 1, queries.grep(/\bJOIN `will_paginate_page_ids`.+\bORDER BY `countries`\.`name` DESC\z/m).size, queries.join("\n")
    assert_equal 1, queries.grep(/\A(?![\s\S]*will_paginate_page_ids)[\s\S]*?\bCOUNT\s*\(/i).size

    assert_equal countries.sort_by(&:name).reverse.drop(2).take(2).map(&:id), page.map(&:id)
    assert relation.loaded?

    assert_kind_of WillPaginate::Collection, page
    assert_equal 2, page.current_page
    assert_equal 2, page.per_page
    assert_equal 5, page.total_entries
    assert_equal 3, page.total_pages

    assert_number_of_queries(0, matching: /./) { relation.to_a }
  end

  test 'the optimized lookup is not used on page 1 (zero offset)' do
    user = FactoryBot.create(:user_with_account)
    relation = User.where(id: user.id).paginate(page: 1, per_page: 1, total_entries: 1)

    Rails.logger.expects(:warn).never
    queries = capture_sql_queries { relation.to_a }
    User.distinct.paginate(page: 1, per_page: 1).to_a # page 1 gains nothing, so it is not a miss

    assert_equal 0, queries.grep(/will_paginate_page_ids|\bFIELD\(/i).size, queries.join("\n")
  end

  test 'left outer join paginated relations use the two-query strategy and keep rows without a match' do
    users = create_users_with_accounts(ACCOUNT_NAMES)
    # A user without an account is only returned by the LEFT OUTER JOIN.
    orphan = FactoryBot.create(:simple_user)
    orphan.update_columns(account_id: nil)
    ids = users.map(&:id) + [orphan.id]
    # Descending order, so that the page is in the opposite order to the natural one, and the data query has to keep it.
    relation = User.left_outer_joins(:account).where(id: ids).order(id: :desc).paginate(page: 2, per_page: 2)
    page = nil

    Rails.logger.expects(:warn).never
    queries = capture_sql_queries { page = relation.to_a }

    assert_equal 1, queries.grep(/\bLEFT OUTER JOIN\b.*\bLIMIT 2 OFFSET 2\b/im).grep_v(/will_paginate_page_ids/i).size, queries.join("\n")
    assert_equal 1, queries.grep(/\bFIELD\(/i).size, queries.join("\n")
    assert_no_match(/\bJOIN\b/i, queries.grep(/\bFIELD\(/i).first)
    assert_equal ids.sort.reverse.drop(2).take(2), page.map(&:id)

    assert_kind_of WillPaginate::Collection, page
    assert_equal 2, page.current_page
    assert_equal 2, page.per_page
    assert_equal ids.size, page.total_entries
  end

  PATHS.each do |path, description|
    test "a page past the last one is empty with #{description}" do
      users = create_users_with_accounts(%w[n-a n-b n-c n-d])
      relation = base_relation_for(path, users).order(:id).paginate(page: 5, per_page: 2, total_entries: 4)
      page = nil

      queries = capture_sql_queries { page = relation.to_a }

      assert_empty page
      assert relation.loaded?
      assert_equal 0, queries.grep(/\bFIELD\(/i).size, queries.join("\n")
    end

    test "a relation without an order is paged by primary key with #{description}" do
      users = create_users_with_accounts(%w[n-a n-b n-c n-d])
      relation = base_relation_for(path, users).paginate(page: 2, per_page: 2)
      page = nil

      queries = capture_sql_queries { page = relation.to_a }

      assert_optimized_lookup_used(path, queries)
      assert_equal users.drop(2).map(&:id), page.map(&:id)
      assert_equal 1, queries.grep(/ORDER BY (?:`users`\.)?`?id`? LIMIT 2 OFFSET 2/i).size, queries.join("\n")
      # On the CTE path the outer query needs its own ORDER BY too, see the test of the CTE with a custom order.
      assert_equal 1, queries.grep(/\bJOIN `will_paginate_page_ids`.+\bORDER BY `users`\.`id`\z/m).size, queries.join("\n") if path == :cte
    end

    # Relations with joins and a custom select are not optimized, see `UNSUPPORTED_WITH_JOINS`.
    next if path == :split_with_joins

    test "a custom select is kept on the data query with #{description}" do
      users = create_users_with_accounts(%w[n-a n-b n-c n-d])
      relation = base_relation_for(path, users).select(:id, :username).order(:id).paginate(page: 2, per_page: 2)
      page = nil

      queries = capture_sql_queries { page = relation.to_a }

      assert_optimized_lookup_used(path, queries)
      assert_equal users.drop(2).map(&:id), page.map(&:id)
      assert_equal users.drop(2).map(&:username), page.map(&:username)
      assert_not page.first.has_attribute?(:email)
    end
  end

  test 'an existing CTE is kept on a relation with joins' do
    skip_unless_cte_support

    users = create_users_with_accounts(ACCOUNT_NAMES)
    relation = User.with(other_users: User.select(:id)).joins(:account)
                   .where(id: users.map(&:id)).order(:id).paginate(page: 2, per_page: 2)
    page = nil

    queries = nil
    messages = capture_log_messages { queries = capture_sql_queries { page = relation.to_a } }

    assert_empty messages.grep(/WillPaginateMysqlOptimizedLookup/), messages.join("\n")
    assert_equal 1, queries.grep(/\bFIELD\(/i).size, queries.join("\n")
    assert_equal 0, queries.grep(/will_paginate_page_ids/i).size, queries.join("\n")
    assert_equal users.drop(2).map(&:id), page.map(&:id)
  end

  test 'the optimized lookup is not used for unsafe query shapes' do
    users = FactoryBot.create_list(:user_with_account, 2)
    unsafe_relations = {
      'GROUP BY' => User.select(:state).group(:state),
      'HAVING' => User.having('1 = 1'),
      'DISTINCT' => User.distinct,
      'custom FROM' => User.from('users'),
      'lock' => User.lock,
      'custom SELECT with joins or references' => User.joins(:account).select('users.*, accounts.org_name AS joined_org_name')
    }
    unsafe_relations['existing CTE (WITH)'] = User.with(other_users: User.select(:id)) if User.connection.supports_common_table_expressions?

    unsafe_relations.each do |reason, base_relation|
      relation = base_relation.where(id: users.map(&:id)).paginate(page: 2, per_page: 1, total_entries: 2)

      Rails.logger.expects(:warn).with(regexp_matches(/is not optimized \(#{Regexp.escape(reason)}\)/)).once

      assert_number_of_queries(0, matching: /will_paginate_page_ids|\bFIELD\(/i) { relation.to_a }
    end
  end

  # `eager_loading?` is true when AR loads associations with a JOIN.  The ID query has no association
  # loading, so such a relation would lack that JOIN, and it uses the usual query instead.  See
  # `reason_not_optimizable`.  The check comes before the strategy is chosen, so it does not depend on
  # the code path.  Each relation returns the right page with its association loaded.
  EAGER_LOADING_RELATIONS = {
    'eager_load' => ->(rel) { rel.eager_load(:account).order(:id).paginate(page: 2, per_page: 1) },
    'eager_load added after paginate' => ->(rel) { rel.order(:id).paginate(page: 2, per_page: 1).eager_load(:account) },
    'eager_load with a condition on the eager loaded table' => ->(rel) { rel.eager_load(:account).where(accounts: { org_name: ACCOUNT_NAMES }).order(:id).paginate(page: 2, per_page: 1) },
    'includes with references' => ->(rel) { rel.includes(:account).references(:accounts).order(:id).paginate(page: 2, per_page: 1) },
    'includes with a hash condition on the included table (implicit references)' => ->(rel) { rel.includes(:account).where(accounts: { org_name: ACCOUNT_NAMES }).order(:id).paginate(page: 2, per_page: 1) },
    'includes with joins of the same association' => ->(rel) { rel.includes(:account).joins(:account).order(:id).paginate(page: 2, per_page: 1) }
  }.freeze

  # `includes(:x)` together with `joins(:x)` is not optimized, though the ID query could handle it, as the table
  # is joined.  The check is kept simple and public, it does not tell these apart.  This documents the current
  # behavior, not a requirement.  `joins(:x).preload(:x)` says the same and is optimized, see CONDITIONS_ON_ASSOCIATION.
  test 'relations that eager load use the usual query and log a warning' do
    users = create_users_with_accounts(%w[n-a n-b n-c n-d])

    EAGER_LOADING_RELATIONS.each do |name, build|
      relation = build.call(User.where(id: users.map(&:id)))
      page = nil

      Rails.logger.expects(:warn).with(regexp_matches(/User page 2 is not optimized \(eager loading .+\), called from no controller/)).once
      queries = capture_sql_queries { page = relation.to_a }

      assert_equal 0, queries.grep(/\bFIELD\(|will_paginate_page_ids/i).size, "#{name}: #{queries.join("\n")}"
      assert_equal [users.second.id], page.map(&:id), name
      assert page.first.association(:account).loaded?, name
    end
  end

  test 'a relation with a composite primary key is not optimized' do
    # `features_plans` has the composite primary key (plan_id, feature_id), no single column identifies a row.
    assert_equal %w[plan_id feature_id], FeaturesPlan.primary_key

    Rails.logger.expects(:warn).with(regexp_matches(/FeaturesPlan page 2 is not optimized \(no single-column primary key\)/)).once
    queries = capture_sql_queries { FeaturesPlan.paginate(page: 2, per_page: 1).to_a }

    assert_equal 0, queries.grep(/\bFIELD\(|will_paginate_page_ids/i).size, queries.join("\n")
    assert_equal 1, queries.grep(/\bFROM `features_plans`.+\bLIMIT 1 OFFSET 1\z/m).size, queries.join("\n")
  end

  test 'a select of the primary key only is not optimized and logs no warning' do
    users = FactoryBot.create_list(:user_with_account, 3).sort_by(&:id)
    relation = User.where(id: users.map(&:id)).select(:id).order(:id).paginate(page: 2, per_page: 1)
    page = nil

    Rails.logger.expects(:warn).never
    queries = capture_sql_queries { page = relation.to_a }

    assert_equal 0, queries.grep(/\bFIELD\(|will_paginate_page_ids/i).size, queries.join("\n")
    assert_equal 1, queries.grep(/\ASELECT `users`\.`id` FROM `users`.+\bLIMIT 1 OFFSET 1\z/m).size, queries.join("\n")
    assert_equal [users.second.id], page.map(&:id)
  end

  # WillPaginate's `first` clears `current_page`, so the relation is no longer paginated.
  test 'no warning is logged for a relation that is not paginated' do
    Rails.logger.expects(:warn).never
    User.distinct.paginate(page: 2, per_page: 1).first
  end

  # Association loading directives that AR runs as separate queries, on each code path.  Each combination
  # must use the optimized lookup (CTE or split queries), return the right page and leave the association
  # loaded for the page record.  The relation with joins joins `:account` itself, so it uses `preload`:
  # `includes(:account)` together with `joins(:account)` is eager loading, see EAGER_LOADING_RELATIONS.
  %i[includes preload].each do |loader|
    PATHS.each do |path, description|
      next if loader == :includes && path == :split_with_joins

      test "#{loader} loads the association of every record of the right page without N+1 queries with #{description}" do
        users = create_users_with_accounts(%w[n-a n-b n-c n-d])
        relation = base_relation_for(path, users).public_send(loader, :account).order(:id).paginate(page: 2, per_page: 2)

        page = nil
        queries = capture_sql_queries { page = relation.to_a }
        queries += capture_sql_queries { page.each { |user| user.account.org_name } }

        assert_optimized_lookup_used(path, queries)
        assert_equal users.drop(2).map(&:id), page.map(&:id)
        assert(page.all? { |user| user.association(:account).loaded? })
        assert_equal(users.drop(2).map(&:account_id), page.map { |user| user.account.id })
        assert_equal 0, queries.grep(/FROM `accounts` WHERE `accounts`\.`id` = \d+ LIMIT 1/).size, queries.join("\n")
      end
    end
  end

  # A condition or order on an association table needs that table to be joined for the ID query.  The
  # caller adds the `joins` and loads the association with `preload`.
  CONDITIONS_ON_ASSOCIATION = {
    'preload with explicit joins and a string where' => {
      relation: ->(rel) { rel.preload(:account).joins(:account).where("accounts.org_name IN ('n-d', 'n-a', 'n-c')").order(:id) },
      expected: ->(users) { [users[2].id] } # n-d, n-a, n-c => users 1, 2, 3 => second is user 2
    },
    'preload with explicit joins and a hash where' => {
      relation: ->(rel) { rel.preload(:account).joins(:account).where(accounts: { org_name: %w[n-d n-a n-c] }).order(:id) },
      expected: ->(users) { [users[2].id] }
    },
    'preload with a raw SQL join, a hash where and an order by the joined table' => {
      relation: ->(rel) { rel.preload(:account).joins('INNER JOIN accounts ON accounts.id = users.account_id').where(accounts: { org_name: %w[n-d n-a n-c] }).order(Arel.sql('accounts.org_name DESC')) },
      expected: ->(users) { [users[3].id] } # n-d(1), n-c(3), n-a(2) => second is user 3
    },
    'preload with explicit joins and an order by the association table' => {
      relation: ->(rel) { rel.preload(:account).joins(:account).order(Arel.sql('accounts.org_name DESC')) },
      expected: ->(users) { [users[3].id] } # n-d(1), n-c(3), n-b(0), n-a(2) => second is user 3
    }
  }.freeze

  CONDITIONS_ON_ASSOCIATION.each do |condition, definition|
    test "#{condition} returns the right page and keeps the association loaded" do
      users = create_users_with_accounts(ACCOUNT_NAMES)
      relation = definition[:relation].call(User.where(id: users.map(&:id))).paginate(page: 2, per_page: 1)
      page = nil

      Rails.logger.expects(:warn).never
      queries = capture_sql_queries { page = relation.to_a }

      assert_equal definition[:expected].call(users), page.map(&:id)
      assert page.first.association(:account).loaded?
      assert_equal 1, queries.grep(/\bFIELD\(/i).size, queries.join("\n")
    end
  end

  # `references` alone does nothing in AR: it only matters together with `includes`, where it makes the
  # relation eager load (see EAGER_LOADING_RELATIONS).  Without `includes` the relation does not eager
  # load, so none of these falls back and no warning is logged.  The condition on the joined table is a
  # string, which is where `references` is normally needed, and the caller provides the join.
  REFERENCES_WITHOUT_INCLUDES = {
    'references alone, without joins' => {
      relation: ->(rel) { rel.references(:accounts).order(:id) },
      expected: ->(users) { [users[1].id] },
      cte: true
    },
    'references with a raw SQL join of the referenced table' => {
      relation: ->(rel) { rel.joins('INNER JOIN accounts ON accounts.id = users.account_id').references(:accounts).where("accounts.org_name IN ('n-d', 'n-a', 'n-c')").order(:id) },
      expected: ->(users) { [users[2].id] }
    },
    'references with left_outer_joins and a string condition on the joined table' => {
      relation: ->(rel) { rel.left_outer_joins(:account).references(:accounts).where("accounts.org_name IN ('n-d', 'n-a', 'n-c')").order(:id) },
      expected: ->(users) { [users[2].id] }
    }
  }.freeze

  REFERENCES_WITHOUT_INCLUDES.each do |name, definition|
    test "#{name} is optimized without a warning and returns the right page" do
      skip_unless_cte_support if definition[:cte]

      users = create_users_with_accounts(ACCOUNT_NAMES)
      relation = definition[:relation].call(User.where(id: users.map(&:id))).paginate(page: 2, per_page: 1)
      page = nil

      Rails.logger.expects(:warn).never
      queries = capture_sql_queries { page = relation.to_a }

      assert_equal definition[:expected].call(users), page.map(&:id)
      assert_optimized_lookup_used(definition[:cte] ? :cte : :split_with_joins, queries)
    end
  end

  private

  def create_users_with_accounts(org_names)
    users = FactoryBot.create_list(:user_with_account, org_names.size).sort_by(&:id)
    users.zip(org_names) { |user, name| user.account.update_columns(org_name: name) }
    users
  end

  # :reek:ControlParameter
  def base_relation_for(path, users)
    relation = User.where(id: users.map(&:id))

    case path
    when :cte
      skip_unless_cte_support
    when :split_with_joins
      return relation.joins(:account)
    when :split_without_cte
      relation.connection.stubs(:supports_common_table_expressions?).returns(false)
    end

    relation
  end

  # :reek:ControlParameter :reek:FeatureEnvy
  def assert_optimized_lookup_used(path, queries)
    if path == :cte
      assert_equal 1, queries.grep(/\bWITH.+will_paginate_page_ids/i).size, queries.join("\n")
    else
      assert_equal 0, queries.grep(/will_paginate_page_ids/i).size, queries.join("\n")
      assert_equal 1, queries.grep(/\bFIELD\(/i).size, queries.join("\n")
    end
  end

  def skip_unless_cte_support
    skip 'requires CTE support' unless ActiveRecord::Base.connection.supports_common_table_expressions?
  end
end
