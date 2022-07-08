# frozen_string_literal: true

require 'test_helper'

module Tasks
  class PaymentsTest < ActiveSupport::TestCase
    test 'provider_data_payment_gateway_configured saves the data in a file' do
      file_path = Rails.root.join('tmp', 'provider_data_payment_gateway_configured.csv')

      File.delete(file_path) if File.exist?(file_path)

      providers = FactoryBot.create_list(:simple_provider, 8)

      # Testing with stripe but it could be any other payment gateway setting

      _providers_without_payment,
      providers_with_stripe_configured,
      providers_with_braintree_configured,
      providers_with_stripe_unconfigured = providers.shuffle.each_slice(2).to_a

      providers_with_stripe_configured.each do |provider|
        provider.payment_gateway_type = :stripe
        provider.payment_gateway_options = { login: "sk_test_example#{provider.id}", publishable_key: "pk_test_example#{provider.id}", endpoint_secret: 'some-secret' }
        provider.save!
      end

      providers_with_braintree_configured.each do |provider|
        provider.payment_gateway_type = :braintree_blue
        provider.payment_gateway_options = {merchant_id: "#{provider.name}", public_key: "public_#{provider.name}", private_key: "private_#{provider.name}"}
        provider.save!
      end

      providers_with_stripe_unconfigured.each do |provider|
        provider.payment_gateway_type = :stripe
        provider.save!
      end

      execute_rake_task 'payments.rake', 'payments:provider_data_payment_gateway_configured', 'stripe', file_path

      assert File.exists?(file_path)

      expected_line_values_format = ->(pgs) { "#{pgs.account_id};#{pgs.account.external_admin_domain};#{pgs.account.state}\n" }
      expected_provider_ids = providers_with_stripe_configured.map(&:id)
      expected_all_values = PaymentGatewaySetting.where(account_id: expected_provider_ids).order(id: :asc).joins(:account).map(&expected_line_values_format)
      expected_file_data = ["id;admin_domain;state\n"] + expected_all_values
      assert_equal expected_file_data, File.readlines(file_path)

      File.delete(file_path)
    end

    test 'remove_adyen_from_db removes the payment details of all buyer accounts of providers with payment gateway adyen' do
      stripe_provider, adyen_provider = FactoryBot.create_list(:simple_provider, 2)
      stripe_provider.payment_gateway_setting.update_column(:gateway_type, :stripe)
      adyen_provider.payment_gateway_setting.update_column(:gateway_type, :adyen12)
      [stripe_provider, adyen_provider].each do |provider|
        buyer = FactoryBot.create(:simple_buyer, provider_account: provider)
        buyer.credit_card_partial_number ='1111'
        buyer.save!
      end

      execute_rake_task 'payments.rake', 'payments:remove_adyen_from_db'

      assert PaymentDetail.where(account_id: stripe_provider.buyer_accounts.first!.id).exists?
      refute PaymentDetail.where(account_id: adyen_provider.buyer_accounts.first!.id).exists?
    end

    test 'remove_adyen_from_db removes the form from the CMS templates' do
      provider, deleted_provider = FactoryBot.create_list(:simple_provider, 2)
      deleted_provider.schedule_for_deletion!

      published = <<-HTML
      <div class="row">
        <div class="col-md-9">
          {% include 'users_menu' %}
          <div class="panel panel-default">
            <div class="panel-heading important">
              <div class="pull-right">
                {% if current_account.has_billing_address? %}
                  {% case provider.payment_gateway.type %}
                  {% when "stripe" %}
                    <a href="{{ current_account.edit_stripe_billing_address_url }}">
                      <i class="fa fa-pencil"></i>
                      Edit billing address
                    </a>
                  {% when "adyen12" %}
                    <a href="{{ current_account.edit_adyen12_billing_address_url }}">
                      <i class="fa fa-pencil"></i>
                      Edit billing address
                    </a>
                  {% endcase %}
                {% endif %}
              </div>
              <div class="clearfix"></div>
            </div>
            <div class="panel-body">
              {% case provider.payment_gateway.type %}
              {% comment %} Braintree combines billing address + cc details in 1 form {% endcomment %}
              {% when "braintree_blue" %}
              <a href="{{ current_account.edit_braintree_blue_credit_card_details_url }}">
                {% unless current_account.has_billing_address? and current_account.credit_card_stored? %}
                  Add Credit Card Details and Billing Address
                {% endunless %}
              </a>
              {% comment %} Adyen renders a link to the external cc form once a billing address has been added {% endcomment %}
              {% when "adyen12" %}
                {% if current_account.has_billing_address? %}
                  {% if current_account.credit_card_stored? %}
                    {% adyen12_form "Edit Credit Card Details" %}
                  {% else %}
                    {% adyen12_form "Add Credit Card Details" %}
                  {% endif %}
                {% else %}
                  <p><a href="{{ current_account.edit_adyen12_billing_address_url }}">First add a billing address</a></p>
                {% endif %}
              {% endcase %}
            </div>
            <div class="panel-footer">
              <p>By <strong>Entering Credit Card details</strong> you agree to the <a href="{{ urls.credit_card_terms }}" id="terms-link">Terms of Service</a>, <a href="{{ urls.credit_card_privacy }}" id="privacy-link">Privacy</a> and <a href="{{ urls.credit_card_refunds }}" id="refunds-link">Refund</a>.</p>
            </div>
          </div>
        </div>
      </div>
      HTML

      cms_template, deleted_cms_template = [provider, deleted_provider].map { |account| FactoryBot.create(:cms_template, provider: account, published: published) }

      execute_rake_task 'payments.rake', 'payments:remove_adyen_from_db'

      refute_match /adyen12_form/, cms_template.reload.published
      assert cms_template.valid?

      assert_match /adyen12_form/, deleted_cms_template.reload.published
    end
  end
end
