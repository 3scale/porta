module TestHelpers
  module Account
    private

    # TODO: DRY - merge? with features/support/credit_card_helpers.rb
    def credit_card_attributes(overrides = {})
      { :first_name => 'Eric',
        :last_name => 'Cartman',
        :number => '1',
        :year => 1.year.from_now.year,
        :month => 4,
        :verification_value => '999'
      }.merge(overrides)
    end


    # Create a provider account with everything necessary* nicely stubbed out.
    #
    # * users, settings, profile, service, test plan and one real plan.
    #
    # TODO: since factorygirl now supports callbacks, this could be replaced with
    # a factory.
    #
    def stub_provider_account(attributes = {})
      Factory.stub(:provider_account, attributes)
    end

    # TODO: should be factory
    def stub_feature(service, attributes = {})
      attributes[:service] = service
      feature = Factory.stub(:feature, attributes)
      service.features.stubs(:find).with(feature.to_param).returns(feature)

      feature
    end

    # TODO: should be factory
    def stub_bought_cinstance(account, plan)
      cinstance = Factory.stub(:cinstance, :user_account => account, :plan => plan)
      cinstance.stubs(:user_key).returns(SecureRandom.hex(32))
      account.stubs(:bought_cinstance).returns(cinstance)

      cinstance
    end

    # TODO: should be factory
    def stub_invoice(cinstance, options = {})
      options[:period] ||= Month.new(::Time.zone.now)

      invoice = Factory.stub(:invoice, options.merge(:provider_account => cinstance.provider_account,
                                                     :buyer_account => cinstance.user_account))

      invoice.stubs(:cinstance).returns(cinstance)
      cinstance.user_account.invoices.stubs(:find_by_month!).with(invoice.to_param).returns(invoice)

      invoice
    end

    # TODO: should be factory
    def stub_usage_limit(plan, attributes = {})
      attributes[:plan] = plan
      usage_limit = Factory.stub(:usage_limit, attributes)

      stub_find(plan.usage_limits, usage_limit)
      usage_limit
    end

    # TODO: should be factory
    def stub_buyer_account(plan, attributes = {})
      buyer_account = Factory.stub(:buyer_account, attributes)

      cinstance = Factory.stub(:cinstance, :plan => plan, :user_account => buyer_account)
      buyer_account.stubs(:bought_cinstance).returns(cinstance)
      buyer_account.stubs(:provider_account).returns(plan.provider_account)

      buyer_account
    end

  end
end

require 'active_support/test_case'
ActiveSupport::TestCase.send(:include, TestHelpers::Account)
