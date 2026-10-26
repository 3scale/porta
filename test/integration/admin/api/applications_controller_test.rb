# frozen_string_literal: true

require 'test_helper'

# :reek:TooManyInstanceVariables
class Admin::Api::ApplicationsControllerTest < ActionDispatch::IntegrationTest
  include NPlusOneControl::MinitestHelper

  # The ID query selects only IDs, and carries the JOIN and the OFFSET of page 2 (2 per page).
  ID_QUERY = /\ASELECT `cinstances`\.`id` FROM .*\bJOIN\b.*\bOFFSET 2\b/m
  # The data query loads whole records by those IDs, in their order.
  DATA_QUERY = /\ASELECT `cinstances`\.\*.* WHERE `cinstances`\.`id` IN \(.*\).*\bFIELD\(/m

  def setup
    @provider = FactoryBot.create(:provider_account)
    @service  = @provider.default_service
    @plan     = FactoryBot.create(:application_plan, issuer: @service)
    @buyer    = FactoryBot.create(:buyer_account, provider_account: @provider)
    @application = FactoryBot.create(:cinstance, user_account: @buyer, plan: @plan)
    @token    = FactoryBot.create(:access_token, owner: @provider.admin_users.first!, scopes: %w[account_management]).plaintext_value

    host! @provider.external_admin_domain
  end

  test 'find does not return applications from deleted services' do
    other_service = FactoryBot.create(:service, account: @provider, backend_version: '1')
    other_plan    = FactoryBot.create(:application_plan, issuer: other_service)
    other_app     = FactoryBot.create(:cinstance, user_account: @buyer, plan: other_plan)
    other_service.mark_as_deleted!

    get "/admin/api/applications/find.xml", params: { access_token: @token, user_key: other_app.user_key }

    assert_response :not_found
  end

  test 'find does not return applications from other providers' do
    other_provider = FactoryBot.create(:provider_account)
    other_service  = FactoryBot.create(:service, account: other_provider, backend_version: '1')
    other_plan     = FactoryBot.create(:application_plan, issuer: other_service)
    other_buyer    = FactoryBot.create(:buyer_account, provider_account: other_provider)
    other_app      = FactoryBot.create(:cinstance, user_account: other_buyer, plan: other_plan)

    get "/admin/api/applications/find.xml", params: { access_token: @token, id: other_app.id }

    assert_response :not_found
  end

  test 'find by user_key returns 404 when service is backend v2' do
    @service.update!(backend_version: '2')

    get "/admin/api/applications/find.xml", params: { access_token: @token, user_key: @application.user_key }

    assert_response :not_found
  end

  test 'find by app_id returns 404 when service is backend v1' do
    @service.update!(backend_version: '1')

    get "/admin/api/applications/find.xml", params: { access_token: @token, app_id: @application.application_id }

    assert_response :not_found
  end

  test 'find by id respects member service permissions' do
    member = FactoryBot.create(:member, account: @provider, member_permission_ids: [:partners], member_permission_service_ids: [])
    member_token = FactoryBot.create(:access_token, owner: member, scopes: %w[account_management]).plaintext_value

    get "/admin/api/applications/find.xml", params: { access_token: member_token, id: @application.id }

    assert_response :not_found

    member.update!(member_permission_service_ids: [@service.id])

    get "/admin/api/applications/find.xml", params: { access_token: member_token, id: @application.id }

    assert_response :success
  end

  test 'index does not return applications from deleted services' do
    other_service = FactoryBot.create(:service, account: @provider)
    other_plan    = FactoryBot.create(:application_plan, issuer: other_service)
    FactoryBot.create(:cinstance, user_account: @buyer, plan: other_plan)
    other_service.mark_as_deleted!

    get "/admin/api/applications.xml", params: { access_token: @token }

    assert_response :success
    assert_select 'applications application', 1
  end

  test 'index is forbidden for member without partners permission' do
    member = FactoryBot.create(:member, account: @provider, member_permission_ids: [])
    member_token = FactoryBot.create(:access_token, owner: member, scopes: %w[account_management]).plaintext_value

    get "/admin/api/applications.xml", params: { access_token: member_token }

    assert_response :forbidden
  end

  test 'index returns all applications for member with partners permission and no service ids restriction' do
    service2 = FactoryBot.create(:service, account: @provider)
    plan2    = FactoryBot.create(:application_plan, issuer: service2)
    app2     = FactoryBot.create(:cinstance, user_account: @buyer, plan: plan2)

    member = FactoryBot.create(:member, account: @provider, member_permission_ids: [:partners])
    member_token = FactoryBot.create(:access_token, owner: member, scopes: %w[account_management]).plaintext_value

    assert_nil member.member_permission_service_ids

    get "/admin/api/applications.xml", params: { access_token: member_token }

    assert_response :success
    returned_ids = css_select('applications application > id').map { |n| n.text.to_i }
    assert_includes returned_ids, @application.id
    assert_includes returned_ids, app2.id
  end

  test 'index pagination with member service permissions' do
    service2 = FactoryBot.create(:service, account: @provider)
    plan2    = FactoryBot.create(:application_plan, issuer: service2)

    4.times do
      FactoryBot.create(:cinstance, user_account: @buyer, plan: @plan)
      FactoryBot.create(:cinstance, user_account: @buyer, plan: plan2)
    end

    permitted_apps = Cinstance.where(service_id: @service.id).pluck(:id).sort
    non_permitted_apps = Cinstance.where(service_id: service2.id).pluck(:id).sort
    per_page = (permitted_apps.size / 2.0).ceil

    member = FactoryBot.create(:member, account: @provider, member_permission_ids: [:partners],
                                member_permission_service_ids: [@service.id])
    member_token = FactoryBot.create(:access_token, owner: member, scopes: %w[account_management]).plaintext_value

    get "/admin/api/applications.xml", params: { access_token: member_token, per_page: per_page, page: 1 }

    assert_response :success
    assert_select 'applications application', per_page
    assert_select('applications application > service_id') { |nodes| nodes.each { |n| assert_equal @service.id.to_s, n.text } }
    page1_ids = css_select('applications application > id').map { |n| n.text.to_i }

    get "/admin/api/applications.xml", params: { access_token: member_token, per_page: per_page, page: 2 }

    assert_response :success
    page2_ids = css_select('applications application > id').map { |n| n.text.to_i }
    assert_select('applications application > service_id') { |nodes| nodes.each { |n| assert_equal @service.id.to_s, n.text } }

    all_ids = (page1_ids + page2_ids).sort
    assert_empty page1_ids & page2_ids, 'pages should not overlap'
    assert_empty all_ids & non_permitted_apps, 'should not include apps from non-permitted services'
    assert_equal permitted_apps, all_ids
  end

  # The page is requested with an offset, so that the MySQL optimized lookup is in play.  The page holds
  # `current_scale` applications, each with its own account and plan, so any per-record query shows up.
  %w[xml json].each do |format|
    test "no n+1 queries on paginated index in #{format}" do
      populate = ->(scale) do
        (scale * 2).times do
          buyer = FactoryBot.create(:buyer_account, provider_account: @provider)
          FactoryBot.create(:cinstance, user_account: buyer, plan: FactoryBot.create(:application_plan, issuer: @service))
        end
      end

      assert_perform_constant_number_of_queries(populate: populate) do
        get "/admin/api/applications.#{format}", params: { access_token: @token, page: 2, per_page: current_scale }
        assert_response :success
      end
    end

    # THE EXPECTED QUERY SHAPE OF THE APPLICATIONS INDEX, SEE ThreeScale::WillPaginateMysqlOptimizedLookup.
    #
    # The index joins `services` (to filter by the accessible services), and page 2 and later would read
    # whole application rows through that JOIN just to skip them.  The optimized lookup splits it into:
    # 1. an ID query with the JOIN, ORDER BY and OFFSET, that selects only IDs;
    # 2. a data query by those IDs, without the JOIN and the OFFSET (the associations are loaded with
    #    separate preload queries, which this test does not look at);
    # 3. the COUNT for the pagination total.
    #
    # This only holds while the relation does not eager load, that is while `eager_loading?` is false:
    # no `eager_load`, and no `includes` combined with `references` (or a condition on the included table)
    # or with a `joins` of the same association.  AR then needs the JOIN of the association in the query
    # that selects the page, the optimized lookup refuses and the usual slow query runs instead, with a
    # warning in the log.  If this test fails, check what was added to the relation, prefer `preload` or
    # `includes`, and use an explicit `joins` for conditions on an association table.
    test "paginated index in #{format} runs an ID query with the joins and offset, then a data query by IDs without joins" do
      skip_unless_mysql

      4.times do
        buyer = FactoryBot.create(:buyer_account, provider_account: @provider)
        FactoryBot.create(:cinstance, user_account: buyer, plan: @plan)
      end

      queries = nil
      messages = capture_log_messages do
        queries = capture_sql_queries do
          get "/admin/api/applications.#{format}", params: { access_token: @token, page: 2, per_page: 2 }
          assert_response :success
        end
      end
      assert_empty messages.grep(/WillPaginateMysqlOptimizedLookup/), messages.join("\n")
      cinstance_queries = queries.grep(/FROM `cinstances`/)

      # 1. The ID query selects only IDs, and is the one that pays for the JOIN and the OFFSET.
      id_queries = cinstance_queries.grep(ID_QUERY)
      assert_equal 1, id_queries.size, queries.join("\n")

      # 2. The data query loads the whole records for exactly those IDs, in that order, without any JOIN or OFFSET.
      data_queries = cinstance_queries.grep(DATA_QUERY)
      assert_equal 1, data_queries.size, queries.join("\n")
      assert_no_match(/\bJOIN\b|\bOFFSET\b/i, data_queries.first)

      # 3. The pagination total, which needs no records.
      assert_equal 1, cinstance_queries.grep(/\ASELECT COUNT\(\*\) FROM `cinstances`/).size, queries.join("\n")

      # Nothing loads whole records together with the JOIN and OFFSET, that is what the split avoids.
      assert_empty cinstance_queries.grep(/\ASELECT `cinstances`\.\*.*\bJOIN\b.*\bOFFSET\b/m), queries.join("\n")
    end
  end

  # The conditional GET is decided on the records of the page that the ID query and the data query already
  # loaded, there is no query of its own to check freshness.  So a 304 on page 2 runs the same queries as
  # the 200, minus the preloads and the rendering.  The COUNT for the pagination total still runs, because
  # WillPaginate computes it together with the page, before the freshness check.
  test 'paginated index answers 304 from the loaded page without any query of its own, and 200 after a record of the page was modified' do
    skip_unless_mysql

    4.times do
      buyer = FactoryBot.create(:buyer_account, provider_account: @provider)
      FactoryBot.create(:cinstance, user_account: buyer, plan: @plan)
    end
    params = { access_token: @token, page: 2, per_page: 2 }

    get '/admin/api/applications.json', params: params
    assert_response :success
    etag = response.headers['ETag']
    last_modified = response.headers['Last-Modified']
    assert_not_nil etag
    assert_not_nil last_modified
    page_ids = response.parsed_body['applications'].map { _1['application']['id'] }
    assert_equal 2, page_ids.size
    conditional_headers = { 'HTTP_IF_NONE_MATCH' => etag, 'HTTP_IF_MODIFIED_SINCE' => last_modified }

    queries = capture_sql_queries do
      get '/admin/api/applications.json', params: params, headers: conditional_headers
      assert_response :not_modified
    end
    cinstance_queries = queries.grep(/FROM `cinstances`/)

    # The page is loaded once, by the ID query and the data query.
    assert_equal 1, cinstance_queries.grep(ID_QUERY).size, queries.join("\n")
    assert_equal 1, cinstance_queries.grep(DATA_QUERY).size, queries.join("\n")
    # No query was made for the freshness, such as MAX(updated_at) or a count of the modified records.
    assert_empty queries.grep(/\bMAX\(|\bupdated_at\b.*\bCOUNT\b|\bCOUNT\b.*\bupdated_at\b/i), queries.join("\n")
    # The associations are for the response body only, a 304 does not load them.
    assert_empty queries.grep(/FROM `(?:plans|services)` WHERE `(?:plans|services)`\.`id` IN/), queries.join("\n")

    # Bump updated_at manually, because otherwise it could be the same as the Last-Modified timestamp.
    modified = Cinstance.find(page_ids.first)
    modified.update_columns(updated_at: modified.updated_at + 1.minute)

    get '/admin/api/applications.json', params: params, headers: conditional_headers
    assert_response :success
    assert_not_equal etag, response.headers['ETag']
  end

  test 'paginated index of the first page does not use the split query' do
    skip_unless_mysql

    queries = capture_sql_queries do
      get '/admin/api/applications.json', params: { access_token: @token, page: 1, per_page: 2 }
      assert_response :success
    end

    assert_empty queries.grep(/FIELD\(/), queries.join("\n")
    assert_equal 1, queries.grep(/\ASELECT `cinstances`\.\*.*\bJOIN\b.*\bOFFSET 0\b/m).size, queries.join("\n")
  end

  private

  def skip_unless_mysql
    skip 'the split query is used only with MySQL' unless System::Database.mysql?
  end
end
