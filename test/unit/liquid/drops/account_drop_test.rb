require 'test_helper'

class Liquid::Drops::AccountDropTest < ActiveSupport::TestCase
  include Liquid

  def setup
    @app = FactoryGirl.create(:cinstance)
    @buyer = @app.user_account
    @drop = Drops::Account.new(@buyer)
  end

  def test_url_helpers
    routes      = Rails.application.routes.url_helpers
    account_url = routes.admin_buyers_account_url(@drop, host: 'foo.example.com')

    assert account_url
    assert account_url.include?("/#{@buyer.id}")
  end

  test 'returns id' do
    assert_equal @drop.id, @buyer.id
  end

  test 'returns vat_rate' do
    assert_equal(@drop.vat_rate, @buyer.vat_rate)
  end

  test "returns buyer's applications" do
    assert @drop.applications.is_a?(Array)
    assert @drop.applications.is_a?(Drops::Collection)
    assert @drop.applications.first.is_a?(Drops::Application)
  end

  test '#bought_account_contract' do
    contract = FactoryGirl.build_stubbed(:contract)
    @buyer.stubs bought_account_contract: contract
    assert_equal Drops::Contract.new(contract), @drop.bought_account_contract
  end

  test '#latest_messages' do
    assert @drop.latest_messages.is_a?(Drops::Collection)
    # TODO: assert @drop.latest_messages.first.kind_of?(Drops::Message)
  end

  test '#unread_messages' do
    assert @drop.unread_messages.is_a?(Drops::Collection)
  end

  test 'return plans' do
    assert @drop.bought_account_plan.is_a?(Drops::AccountPlan)
    assert @drop.bought_plan.is_a?(Drops::Plan)
  end

  test 'returns signup date' do
    assert_equal @buyer.created_at.utc.to_i, @drop.created_at
  end

  test 'returns whether an account is paid' do
    @buyer.stubs(:paid?).returns(true)
    assert @drop.paid?

    @buyer.stubs(:paid?).returns(false)
    assert !@drop.paid?
  end

  test 'returns whether an account is on_trial' do
    @buyer.stubs(:on_trial?).returns(true)
    assert @drop.on_trial?

    @buyer.stubs(:on_trial?).returns(false)
    assert !@drop.on_trial?
  end

  ## begin Fields tests
  class AccountDropFieldsTest < ActiveSupport::TestCase
    include Liquid

    def setup
      @app = FactoryGirl.create(:cinstance)
      @buyer = @app.user_account
      [{ target: "Account", name: "telephone_number", label: "telephone_number", hidden: true },
       { target: "Account", name: "visible_extra", label: "visible_extra" },
       { target: "Account", name: "hidden_extra",  label: "hidden_extra", hidden: true }]
        .each do |field|
        FactoryGirl.create :fields_definition, field.merge({account_id: @buyer.provider_account.id})
      end

      @buyer.reload
      @buyer.extra_fields = {"visible_extra" => "visible extra value", "hidden_extra" => "hidden extra value" }
      @buyer.save!

      @drop = Drops::Account.new(@buyer)
    end

    test 'be fields' do
      assert_instance_of Drops::Fields, @drop.fields
      assert_instance_of Drops::Field, @drop.fields.first
    end

    test 'return visible fields' do
      assert @drop.fields["org_name"].visible?
    end

    test 'return hidden fields' do
      assert_not_nil @drop.fields["telephone_number"]
    end

    test 'return extra fields' do
      assert_not_nil @drop.fields["visible_extra"]
    end

    test 'extra fields are fields' do
      assert_instance_of Drops::Fields, @drop.extra_fields
      assert_instance_of Drops::Field, @drop.extra_fields.first
    end

    test 'return extra visible extra fields' do
      assert_equal "visible extra value", @drop.extra_fields["visible_extra"].value
    end

    test 'return hidden extra fields' do
      assert_not_nil @drop.extra_fields["hidden_extra"]
    end

    test 'not return fields' do
      assert_nil @drop.extra_fields["org_name"]
    end
  end
  # End fields tests
end
