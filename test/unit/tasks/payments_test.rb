# frozen_string_literal: true

require 'test_helper'

module Tasks
  class PaymentsTest < ActiveSupport::TestCase
    test 'provider_data_payment_gateway_configured saves the data in a file' do
      file_path = Rails.root.join('tmp', 'provider_data_payment_gateway_configured.csv')

      File.delete(file_path) if File.exist?(file_path)

      providers = FactoryBot.create_list(:simple_provider, 10)

      # Testing with stripe but it could be any other payment gateway setting

      _providers_without_payment,
      providers_with_stripe_configured,
      providers_with_braintree_configured,
      providers_with_stripe_unconfigured,
      deleted_provider_with_stripe_configured = providers.shuffle.each_slice(2).to_a

      providers_with_stripe_configured.each do |provider|
        provider.payment_gateway_type = :stripe
        provider.payment_gateway_options = {login: "sk_test_example#{provider.id}", publishable_key: "pk_test_example#{provider.id}"}
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

      deleted_provider_with_stripe_configured.each do |provider|
        provider.payment_gateway_type = :stripe
        provider.payment_gateway_options = {login: "sk_test_example#{provider.id}", publishable_key: "pk_test_example#{provider.id}"}
        provider.save!
        provider.schedule_for_deletion!
      end

      execute_rake_task 'payments.rake', 'payments:provider_data_payment_gateway_configured', 'stripe', file_path

      assert File.exists?(file_path)

      expected_line_values_format = ->(pgs) { "#{pgs.account_id};#{pgs.account.admin_domain};#{pgs.account.state}\n" }
      expected_provider_ids = providers_with_stripe_configured.map(&:id)
      expected_all_values = PaymentGatewaySetting.where(account_id: expected_provider_ids).order(id: :asc).joins(:account).map(&expected_line_values_format)
      expected_file_data = ["id;admin_domain;state\n"] + expected_all_values
      assert_equal expected_file_data, File.readlines(file_path)

      File.delete(file_path)
    end
  end
end
