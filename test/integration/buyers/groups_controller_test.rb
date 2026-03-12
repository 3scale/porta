# frozen_string_literal: true

require 'test_helper'

class Buyers::GroupsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @provider = FactoryBot.create(:provider_account)
    @buyer = FactoryBot.create(:buyer_account, provider_account: @provider)
    @group1 = FactoryBot.create(:cms_group, provider: @provider, name: "group1")
    @group2 = FactoryBot.create(:cms_group, provider: @provider, name: "group2")

    @provider.settings.allow_groups!
    login! @provider
  end

  test 'show displays groups for buyer account' do
    get admin_buyers_account_groups_path(@buyer)

    assert_response :success

    page = Nokogiri::HTML4::Document.parse(response.body)
    checkboxes = page.xpath("//input[@name='account[group_ids][]'][@type='checkbox'][not(@hidden)]")
    labels = checkboxes.map { |cb| cb.xpath("following-sibling::label").text }

    assert_same_elements %w(group1 group2), labels
    assert checkboxes.all? { |cb| cb['checked'].nil? }, "Expected all checkboxes to be unchecked"
  end

  test 'update sets correctly the groups' do
    put admin_buyers_account_groups_path(@buyer), params: {
      account: {
        group_ids: [@group2.id]
      }
    }

    assert_redirected_to admin_buyers_account_groups_path(@buyer, id: @buyer.id)
    assert_equal 'Account updated', flash[:success]
    assert_equal [@group2.id], @buyer.reload.group_ids

    put admin_buyers_account_groups_path(@buyer), params: {
      account: {
        group_ids: [@group1.id, @group2.id]
      }
    }
    assert_response :redirect
    assert_same_elements [@group1.id, @group2.id], @buyer.reload.group_ids

    put admin_buyers_account_groups_path(@buyer), params: {
      account: {
        group_ids: [""]
      }
    }
    assert_response :redirect
    assert_empty @buyer.reload.group_ids
  end

  test 'update removes all groups when empty array provided' do
    buyer.groups << group
    assert_equal [group.id], buyer.group_ids

    put admin_buyers_account_groups_path(@buyer), params: {
      account: {
        group_ids: []
      }
    }

    assert_redirected_to admin_buyers_account_groups_path(@buyer)
    assert_empty buyer.reload.groups
  end

  test 'update shows success flash message' do
    put admin_buyers_account_groups_path(@buyer), params: {
      account: {
        group_ids: [group.id]
      }
    }

    assert_redirected_to admin_buyers_account_groups_path(@buyer)
    assert_equal 'Groups were successfully updated.', flash[:success]
  end

  test 'update requires groups authorization' do
    member = FactoryBot.create(:member, account: provider, member_permission_ids: [:partners])
    member.activate!
    login! provider, user: member

    put admin_buyers_account_groups_path(@buyer), params: {
      account: {
        group_ids: [group.id]
      }
    }

    assert_response :forbidden
  end

  test 'cannot access groups of another provider buyer account' do
    other_provider = FactoryBot.create(:provider_account)
    other_buyer = FactoryBot.create(:buyer_account, provider_account: other_provider)

    get admin_buyers_account_groups_path(other_buyer)
    assert_response :not_found

    put admin_buyers_account_groups_path(other_buyer), params: {
      account: {
        group_ids: [group.id]
      }
    }
    assert_response :not_found
  end
end