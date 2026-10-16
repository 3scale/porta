# frozen_string_literal: true

require 'test_helper'

class Admin::Api::ApplicationsControllerTest < ActionDispatch::IntegrationTest
  include NPlusOneControl::MinitestHelper

  def setup
    @provider = FactoryBot.create(:provider_account)
    @service  = @provider.default_service
    @plan     = FactoryBot.create(:application_plan, issuer: @service)
    @buyer    = FactoryBot.create(:buyer_account, provider_account: @provider)
    @application = FactoryBot.create(:cinstance, user_account: @buyer, plan: @plan)
    @token    = FactoryBot.create(:access_token, owner: @provider.admin_users.first!, scopes: %w[account_management]).plaintext_value

    host! @provider.external_admin_domain
  end

  test 'index returns applications' do
    get "/admin/api/applications.xml", params: { access_token: @token }

    assert_response :success
  end

  test 'find by id' do
    get "/admin/api/applications/find.xml", params: { access_token: @token, id: @application.id }

    assert_response :success
  end

  test 'find by user_key (backend v1)' do
    @service.update!(backend_version: '1')

    get "/admin/api/applications/find.xml", params: { access_token: @token, user_key: @application.user_key }

    assert_response :success
    assert_equal @application.id, assigns(:application).id
  end

  test 'find by app_id (backend v2)' do
    @service.update!(backend_version: '2')

    get "/admin/api/applications/find.xml", params: { access_token: @token, app_id: @application.application_id }

    assert_response :success
    assert_equal @application.id, assigns(:application).id
  end

  test 'find by user_key scoped to service_id' do
    @service.update!(backend_version: '1')
    other_service = FactoryBot.create(:service, account: @provider, backend_version: '1')
    other_plan    = FactoryBot.create(:application_plan, issuer: other_service)
    FactoryBot.create(:cinstance, user_account: @buyer, plan: other_plan, user_key: @application.user_key)

    get "/admin/api/applications/find.xml", params: { access_token: @token,
                                                       user_key: @application.user_key, service_id: @service.id }

    assert_response :success
    assert_equal @application.id, assigns(:application).id
  end

  test 'find by app_id scoped to service_id' do
    @service.update!(backend_version: '2')
    other_service = FactoryBot.create(:service, account: @provider, backend_version: '2')
    other_plan    = FactoryBot.create(:application_plan, issuer: other_service)
    FactoryBot.create(:cinstance, user_account: @buyer, plan: other_plan)

    get "/admin/api/applications/find.xml", params: { access_token: @token,
                                                       app_id: @application.application_id, service_id: @service.id }

    assert_response :success
    assert_equal @application.id, assigns(:application).id
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

  test 'index returns empty for member with partners permission but no services selected' do
    member = FactoryBot.create(:member, account: @provider, member_permission_ids: [:partners], member_permission_service_ids: [])
    member_token = FactoryBot.create(:access_token, owner: member, scopes: %w[account_management]).plaintext_value

    get "/admin/api/applications.xml", params: { access_token: member_token }

    assert_response :success
    assert_select 'applications application', 0
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

  test 'index respects member service permissions filtering' do
    service2 = FactoryBot.create(:service, account: @provider)
    plan2    = FactoryBot.create(:application_plan, issuer: service2)
    FactoryBot.create(:cinstance, user_account: @buyer, plan: plan2)

    member = FactoryBot.create(:member, account: @provider, member_permission_ids: [:partners],
                                member_permission_service_ids: [@service.id])
    member_token = FactoryBot.create(:access_token, owner: member, scopes: %w[account_management]).plaintext_value

    get "/admin/api/applications.xml", params: { access_token: member_token }

    assert_response :success
    assert_select 'applications application', 1
    assert_select 'applications application service_id', @service.id.to_s
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
  end

  test 'paginated index selects the page IDs with the joins and offset, then loads whole records by id without joins' do
    skip 'the split query is used only with MySQL' unless System::Database.mysql?

    4.times do
      buyer = FactoryBot.create(:buyer_account, provider_account: @provider)
      FactoryBot.create(:cinstance, user_account: buyer, plan: @plan)
    end

    queries = capture_sql_queries do
      get '/admin/api/applications.json', params: { access_token: @token, page: 2, per_page: 2 }
      assert_response :success
    end
    cinstance_queries = queries.grep(/FROM `cinstances`/)

    # 1. Only the IDs are selected, this is the one that pays for the JOIN and the OFFSET.
    id_scans = cinstance_queries.grep(/\ASELECT `cinstances`\.`id` FROM `cinstances`.*\bJOIN\b.*\bLIMIT 2 OFFSET 2\z/m)
    assert_equal 1, id_scans.size, queries.join("\n")

    # 2. The whole records are loaded for exactly those IDs, in that order, without any JOIN or OFFSET.
    page_loads = cinstance_queries.grep(/\ASELECT `cinstances`\.\* FROM `cinstances` WHERE `cinstances`\.`id` IN \(\d+, ?\d+\) ORDER BY FIELD\(/)
    assert_equal 1, page_loads.size, queries.join("\n")
    assert_no_match(/\bJOIN\b|\bOFFSET\b/i, page_loads.first)

    # 3. The pagination total, which needs no records.
    assert_equal 1, cinstance_queries.grep(/\ASELECT COUNT\(\*\) FROM `cinstances`/).size, queries.join("\n")

    # Nothing loads whole records together with the JOIN and OFFSET, that is what the split avoids.
    assert_empty cinstance_queries.grep(/\ASELECT `cinstances`\.\*.*\bJOIN\b.*\bOFFSET\b/m), queries.join("\n")
  end

  test 'paginated index of the first page does not use the split query' do
    skip 'the split query is used only with MySQL' unless System::Database.mysql?

    queries = capture_sql_queries do
      get '/admin/api/applications.json', params: { access_token: @token, page: 1, per_page: 2 }
      assert_response :success
    end

    assert_empty queries.grep(/FIELD\(/), queries.join("\n")
    assert_equal 1, queries.grep(/\ASELECT `cinstances`\.\* FROM `cinstances`.*\bJOIN\b.*\bLIMIT 2 OFFSET 0\z/m).size, queries.join("\n")
  end

end
