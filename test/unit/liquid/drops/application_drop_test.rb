require 'test_helper'

class Liquid::Drops::ApplicationDropTest < ActiveSupport::TestCase
  include Liquid

  def setup
    @app = FactoryBot.create(:cinstance, :name => 'some instance')
    @buyer = @app.user_account
    @drop = Drops::Application.new(@app)
  end

  test 'returns id' do
    assert_equal @drop.id, @app.id
  end

  test 'returns state' do
    assert_equal @drop.state, @app.state
  end

  test 'admin_url' do
    assert_match System::UrlHelpers.system_url_helpers.admin_service_application_path(@app.service, @app), @drop.admin_url
  end

  test 'alerts' do
    _provider_alerts = FactoryBot.create_list(:limit_alert, 3, cinstance: @app, account: @app.provider_account)
    expected_alerts = FactoryBot.create_list(:limit_alert, 2, cinstance: @app, account: @app.buyer_account)
    _deleted_alert = FactoryBot.create(:limit_alert, cinstance: @app, account: @app.buyer_account, state: 'deleted')
    assert_same_elements Drops::Collection.for_drop(Drops::Alert).new(expected_alerts), @drop.alerts
  end

  context "field definitions" do
    setup do
      [{ :target => "Cinstance", :name => "visible_extra", :label => "visible_extra" },
       { :target => "Cinstance", :name => "hidden_extra",  :label => "hidden_extra", :hidden => true }]
       .each do |field|
         FactoryBot.create :fields_definition, field.merge({:account_id => @buyer.provider_account.id})
      end

      @app.reload
      @app.extra_fields = {"visible_extra" => "visible extra value", "hidden_extra" => "hidden extra value" }
      @app.save!

      @drop = Drops::Application.new(@app)
    end


    should 'builtin_fields should be Fields' do
      builtins = @drop.builtin_fields
      assert_instance_of Drops::Fields, builtins
      assert_instance_of Drops::Field, builtins.first
    end

    should 'bultin fields have visible fields' do
      assert_equal @app.name, @drop.builtin_fields["name"]
    end

    should 'builtin_fields does not include extra fields' do
      assert_nil @drop.builtin_fields["visible_extra"]
    end

    should '#extra_fields are Fields' do
      extras = @drop.extra_fields
      assert_instance_of Drops::Fields, extras
      assert_instance_of Drops::Field, extras.first
    end

    should '#extra_fields have both visible and hidden ones' do
      extras = @drop.extra_fields
      assert_equal "visible extra value", extras["visible_extra"]
      assert_not_nil extras["hidden_extra"]
    end

    should '#extra_fields does not return builtin fields' do
      extras = @drop.extra_fields
      assert_nil extras["name"]
    end
  end # field definitions
end
