# frozen_string_literal: true

require 'test_helper'

class DeleteObjectHierarchyWorkerTest < ActiveSupport::TestCase
  include ActiveJob::TestHelper

  DoNotRetryError = DeleteObjectHierarchyWorker.const_get(:DoNotRetryError)

  setup do
    @object = FactoryBot.create(:metric)
  end

  def test_perform
    perform_enqueued_jobs do
      perform_expectations

      DeleteObjectHierarchyWorker.delete_later(object)
    end
  end

  private

  attr_reader :object

  def perform_expectations; end

  class DeletingOrderCheck < ActiveSupport::TestCase
    include ActiveJob::TestHelper

    class TracingDeleteObjectHierarchyWorker < DeleteObjectHierarchyWorker
      def self.trace
        @trace ||= []
      end

      private def handle_one_hierarchy_entry!(hierarchy)
        self.class.trace << hierarchy.last
        super
      end
    end

    test "basic order test" do
      metric = FactoryBot.create(:metric)
      pricing_rule = FactoryBot.create(:pricing_rule, metric: metric)

      perform_enqueued_jobs do
        TracingDeleteObjectHierarchyWorker.delete_later(metric)
      end

      exp = %W[
        Association-Metric-#{metric.id}:proxy_rules
        Association-Metric-#{metric.id}:plan_metrics
        Association-Metric-#{metric.id}:usage_limits
        Association-Metric-#{metric.id}:pricing_rules
        Plain-PricingRule-#{pricing_rule.id}
        Association-Metric-#{metric.id}:pricing_rules
        Plain-Metric-#{metric.id}
        ]

      assert_equal exp, TracingDeleteObjectHierarchyWorker.trace
    end
  end

  class ReschedulingTest < ActiveSupport::TestCase
    include ActiveJob::TestHelper


    test "will reschedule if timeout is reached" do
      now = DeleteObjectHierarchyWorker.new.send :now
      DeleteObjectHierarchyWorker.any_instance.expects(:now).times(5).returns(now, now, now + DeleteObjectHierarchyWorker::WORK_TIME_LIMIT_SECONDS)

      perform_enqueued_jobs(queue: "deletion") do
        DeleteObjectHierarchyWorker.perform_later("Plain-Alert-123456", "Plain-Alert-654321")
      end

      assert_equal ["Plain-Alert-123456", "Plain-Alert-654321"], performed_jobs[0]["arguments"]
      assert_equal ["Plain-Alert-123456"], performed_jobs[1]["arguments"]
    end
  end

  class AssociationUnknownPrimaryKeyTest < ActiveSupport::TestCase
    include ActiveJob::TestHelper

    test 'the error is not raised and the object is removed' do
      plan = FactoryBot.create(:application_plan)
      feature = FactoryBot.create(:feature)
      plan.features_plans.create!(feature: feature)

      assert_difference(plan.features_plans.method(:count), -1) do
        perform_enqueued_jobs { DeleteObjectHierarchyWorker.delete_later(feature) }
      end

      assert_raises(ActiveRecord::RecordNotFound) { feature.reload }
    end
  end

  class BadHierarchyEntryTest < ActiveSupport::TestCase
    include ActiveJob::TestHelper

    test "call with bad hierarchy entry" do
      System::ErrorReporting.expects(:report_error).with do |exception|
        exception.is_a? DoNotRetryError
      end

      DeleteObjectHierarchyWorker.perform_now("Plain-BadClass-1234")
    end
  end

  class DeleteObjectHierarchyWorkerWhenObjectDoesNotExistAnymoreTest < ActiveSupport::TestCase
    include ActiveJob::TestHelper

    setup do
      @object = FactoryBot.create(:simple_account)
      System::ErrorReporting.stubs(:report_error)
    end

    attr_reader :object

    test "compatibility perform deserialization error" do
      object.destroy!
      System::ErrorReporting.expects(:report_error).with { _1.is_a? ActiveJob::DeserializationError }
      perform_enqueued_jobs { DeleteObjectHierarchyWorker.perform_later(object) }
    end

    test "compatibility perform error with hierarchy" do
      fake_object = {}
      object.destroy!
      Rails.logger.stubs(:warn)
      Rails.logger.expects(:warn).with { |msg| msg.start_with? "DeleteObjectHierarchyWorker skipping object, maybe something else already deleted it: " }
      perform_enqueued_jobs { DeleteObjectHierarchyWorker.perform_later(fake_object, ["Hierarchy-Account-#{object.id}"]) }
    end

    test "success when record not found" do
      object.destroy!
      Rails.logger.stubs(:warn)
      Rails.logger.expects(:warn).with { |msg| msg.start_with? "DeleteObjectHierarchyWorker skipping object, maybe something else already deleted it: " }
      perform_enqueued_jobs { DeleteObjectHierarchyWorker.perform_later("Plain-#{object.class}-#{object.id}") }
    end

    test "deleting records that mixed do not exist" do
      account = object
      service, other_service = FactoryBot.create_list(:simple_service, 2, account:)
      service.destroy!
      Rails.logger.stubs(:warn)
      Rails.logger.expects(:warn).with { |msg| msg.start_with? "DeleteObjectHierarchyWorker skipping object, maybe something else already deleted it: " }.twice
      perform_enqueued_jobs {
        DeleteObjectHierarchyWorker.perform_later(
          "Plain-#{object.class}-#{object.id}",
          "Plain-Service-#{service.id}",
          "Association-Service-#{service.id}:metrics",
          "Plain-Service-#{other_service.id}",
        )
      }

      assert_raises(ActiveRecord::RecordNotFound) { other_service.reload }
      assert_raises(ActiveRecord::RecordNotFound) { account.reload }
    end
  end

  class DeletePlanTest < ActiveSupport::TestCase
    include ActiveJob::TestHelper

    setup do
      # ApplicationPlan setup
      @plan = FactoryBot.create(:application_plan)
      @contract = FactoryBot.create(:application_contract, plan: @plan)
      @customized_plan = FactoryBot.create(:application_plan, original_id: @plan.id)
    end

    test "delete plan" do
      perform_enqueued_jobs(queue: "deletion") do
        DeleteObjectHierarchyWorker.delete_later(plan)
      end

      [plan, contract, customized_plan].each do |object|
        assert_raise(ActiveRecord::RecordNotFound) { object.reload }
      end
    end

    private

    attr_reader :plan, :contract, :customized_plan

    def perform_expectations
      DeleteObjectHierarchyWorker.stubs(:perform_later)
      DeleteObjectHierarchyWorker.expects(:perform_later).with(Contract.new({ id: contract.id }, without_protection: true), anything, 'destroy')
      DeleteObjectHierarchyWorker.expects(:perform_later).with(Plan.new({ id: customized_plan.id }, without_protection: true), anything, 'destroy')
    end

    class AccountPlanTest < DeletePlanTest
      def setup
        @plan = FactoryBot.create(:account_plan)
        @contract = FactoryBot.create(:account_contract, plan: @plan)
        @customized_plan = FactoryBot.create(:account_plan, original_id: @plan.id)
      end
    end

    class ServicePlanTest < DeletePlanTest
      def setup
        @plan = FactoryBot.create(:service_plan)
        @contract = FactoryBot.create(:service_contract, plan: @plan)
        @customized_plan = FactoryBot.create(:service_plan, original_id: @plan.id)
      end
    end
  end

  class DeleteServiceTest < ActiveSupport::TestCase
    include ActiveJob::TestHelper

    setup do
      @object = @service = FactoryBot.create(:simple_service)

      @service_plan = service.service_plans.first
      @application_plan = FactoryBot.create(:application_plan, issuer: service)
      @metrics = service.metrics
      service.update_attribute :default_service_plan, service_plan
      service.update_attribute :default_application_plan, application_plan
      @api_docs_service = FactoryBot.create(:api_docs_service, service: service, account: service.account)

      @backend_api = FactoryBot.create(:backend_api, account: service.account)
      @backend_api_config = FactoryBot.create(:backend_api_config, service: service, backend_api: backend_api)
    end

    test "delete when destroyable" do
      FactoryBot.create(:service, account: service.account) # just a second service to make first destroyable
      cinstance = FactoryBot.create(:cinstance, plan: application_plan)
      limit_alerts = FactoryBot.create_list(:limit_alert, 4, cinstance:, account: cinstance.user_account)
      perform_enqueued_jobs(queue: "deletion") do
        service.mark_as_deleted!
      end

      [service, service_plan, application_plan, *metrics.to_a, api_docs_service, service.proxy, backend_api_config, *limit_alerts].each do |object|
        assert_raise(ActiveRecord::RecordNotFound) { object.reload }
      end

      assert backend_api.reload
    end

    test "delete plain non-destroyable fails" do
      assert_raise(ActiveRecord::RecordNotDestroyed) do
        perform_enqueued_jobs(queue: "deletion") do
          DeleteObjectHierarchyWorker.perform_later("Plain-Service-#{service.id}")
        end
      end

      assert service.reload
    end

    test "deleting last service should not delete anything" do
      before_objects = all_objects

      assert_raise(DoNotRetryError) do
        perform_enqueued_jobs(queue: "deletion") do
          DeleteObjectHierarchyWorker.delete_later(service)
        end
      end

      after_objects = all_objects

      # splitting the assertions to more easily see what was deleted from logs in case of an issue
      assert_empty before_objects - after_objects
      assert_empty after_objects - before_objects
    end

    test "delete default service as association" do
      perform_enqueued_jobs(queue: "deletion") do
        DeleteObjectHierarchyWorker.perform_later("Association-Account-#{service.account_id}:services", "Plain-Service-#{service.id}")
      end

      assert_raise(ActiveRecord::RecordNotFound) { service.reload }
    end

    private

    attr_reader :service, :service_plan, :application_plan, :metrics, :api_docs_service, :backend_api, :backend_api_config
  end

  class DeleteAccountTest < ActiveSupport::TestCase
    include ActiveJob::TestHelper

    attr_reader :provider

    setup do
      @provider = FactoryBot.create(:provider_account, :with_a_buyer)
    end

    test "delete succeeds" do
      provider2 = FactoryBot.create(:provider_account, :with_a_buyer)

      buyer1 = provider.buyers.first
      buyer2 = FactoryBot.create(:buyer_account, provider_account: provider)
      provider.schedule_for_deletion!
      perform_enqueued_jobs(queue: "deletion") do
        DeleteObjectHierarchyWorker.delete_later buyer1
      end
      assert_raise(ActiveRecord::RecordNotFound) { buyer1.reload }
      buyer2.reload

      perform_enqueued_jobs(queue: "deletion") do
        DeleteObjectHierarchyWorker.delete_later provider
      end

      assert_raise(ActiveRecord::RecordNotFound) { provider.reload }
      assert_raise(ActiveRecord::RecordNotFound) { buyer2.reload }

      provider2.reload
      assert_equal 1, provider2.buyers.count
    end

    test "delete with a payment_gateway_setting" do
      pgs = FactoryBot.create(:payment_gateway_setting, account: provider)
      provider.schedule_for_deletion!
      perform_enqueued_jobs(queue: "deletion") do
        DeleteObjectHierarchyWorker.delete_later provider
      end

      assert_raise(ActiveRecord::RecordNotFound) { provider.reload }
      assert_raise(ActiveRecord::RecordNotFound) { pgs.reload }
    end

    test "account is not deleted when not scheduled" do
      buyer = provider.buyers.first
      perform_enqueued_jobs(queue: "deletion") do
        assert_raises { DeleteObjectHierarchyWorker.delete_later provider }
      end
      assert provider.reload
      assert buyer.reload
    end

    test "buyer account can be deleted if provider is not destroyable" do
      buyer = provider.buyers.first

      perform_enqueued_jobs(queue: "deletion") do
        DeleteObjectHierarchyWorker.delete_later buyer
        assert_raises { DeleteObjectHierarchyWorker.delete_later provider }
      end
      assert provider.reload
      assert_raise(ActiveRecord::RecordNotFound) { buyer.reload }
    end

    test "deleting buyer with unresolved invoices will not delete anything" do
      buyer = FactoryBot.create(:buyer_account, provider_account: provider)
      FactoryBot.create(:invoice, provider_account: provider, buyer_account: buyer)
      assert buyer.payment_detail.save
      assert buyer.reload.profile

      before_objects = all_objects
      perform_enqueued_jobs(queue: "deletion") do
        assert_raise(DoNotRetryError) do
          DeleteObjectHierarchyWorker.delete_later buyer
        end
      end

      assert_equal before_objects, all_objects
    end

    class DeleteCompleteAccountTest < ActiveSupport::TestCase
      include ActiveJob::TestHelper
      include TestHelpers::Provider

      # DeletedObject might be needed for updating backend, JanitorWorker handles stale ones
      # the rest are not specific to a provider or should not be deleted with the provider
      NON_PROVIDER_MODELS = [BackendEvent, CMS::LegalTerm, Country, DeletedObject, Partner, LogEntry, SystemOperation]

      test 'perform big account destroy in background' do
        provider = create_a_complete_provider
        assert_equal 1, Account.where(provider: true).count
        assert_equal 1, Account.where(buyer: true).count

        provider.schedule_for_deletion!
        assert_empty models_without_objects.map(&:to_s)

        perform_enqueued_jobs { DeleteObjectHierarchyWorker.delete_later(provider) }

        assert_empty non_master_objects.map { "#{_1.class} #{_1.id}" }
      end

      test "background destroy does not delete anything from another provider" do
        provider = create_a_complete_provider
        provider.schedule_for_deletion!
        before_objects = all_objects

        another_complete_provider = create_a_complete_provider
        another_complete_provider.schedule_for_deletion!

        perform_enqueued_jobs { DeleteObjectHierarchyWorker.delete_later(another_complete_provider) }

        assert_raise(ActiveRecord::RecordNotFound) { another_complete_provider.reload }
        assert_empty before_objects - all_objects # all original objects are still here
      end

      test "deleting a buyer account does not affect other buyers" do
        provider = create_a_complete_provider
        before_objects = all_objects

        buyer = FactoryBot.create(:buyer_account, provider_account: provider)
        before_objects << FactoryBot.create(:invoice, provider_account: provider, buyer_account: buyer, state: "paid")
        permission = buyer.permissions.create(:group => provider.provided_groups.take)
        buyer.save!
        topic = FactoryBot.create(:topic, user: buyer.admin_user, forum: provider.forum)
        before_objects << topic
        topic_subscription = UserTopic.create({user: buyer.admin_user, topic:}, {without_protection: true})

        perform_enqueued_jobs(queue: "deletion") do
          DeleteObjectHierarchyWorker.delete_later buyer
        end

        assert_empty before_objects - all_objects # basically all original objects are still here
        assert_raise(ActiveRecord::RecordNotFound) { buyer.reload }
        assert_raise(ActiveRecord::RecordNotFound) { permission.reload }
        assert_raise(ActiveRecord::RecordNotFound) { topic_subscription.reload }
      end

      test "deleting service should not delete unrelated objects" do
        provider = create_a_complete_provider
        before_objects = all_objects

        service = FactoryBot.create(:simple_service, account: provider)
        FactoryBot.create(:application_plan, issuer: service)
        FactoryBot.create(:api_docs_service, service: service, account: service.account)
        FactoryBot.create(:backend_api_config, service: service, backend_api: provider.backend_apis.take)

        perform_enqueued_jobs(queue: "deletion") do
          service.mark_as_deleted!
        end

        assert_raise(ActiveRecord::RecordNotFound) { service.reload }
        assert_empty before_objects - all_objects # basically all original objects are still here
      end

      private

      def models_without_objects
        (leaf_models - NON_PROVIDER_MODELS).select { _1.all.empty? }
      end

      def non_master_objects
        (leaf_models - NON_PROVIDER_MODELS).inject([]) do |objects, model|
          objects.concat model.all.reject { object_of_master?(_1) }
        end
      end

      def object_of_master?(object)
        tenant_id = object.try(:tenant_id)
        return tenant_id == master_account.id if tenant_id.present?

        case object
        when Account, InvoiceCounter, Invoice
          object.provider_account_id == master_account.id
        when Service, User, Invitation, Finance::BillingStrategy, CMS::Permission, PaymentTransaction, MailDispatchRule, GoLiveState, Settings, PaymentGatewaySetting
          object_of_master?(Account.find(object.account_id))
        when Feature
          object_of_master?(object.featurable_type.constantize.find(object.featurable_id))
        when Cinstance, FeaturesPlan
          object_of_master?(object.plan) if object.plan
        when CMS::Section
          object_of_master?(object.provider) if object.provider
        when Configuration::Value
          object_of_master?(object.configurable_type.constantize.find(object.configurable_id))
        when UserTopic, Notification, UserSession
          object_of_master?(User.find(object.user_id))
        when Metric
          owner = object.owner
          object_of_master?(owner) if owner
        when Message
          object_of_master?(Account.find(object.sender_id))
        when MessageRecipient
          object_of_master?(object.message) if object.message
        when Plan
          object_of_master?(object.issuer) if object.issuer
        when ProxyConfigAffectingChange, ProxyRule
          object_of_master?(Proxy.find(object.proxy_id))
        when ServiceToken, Proxy
          object_of_master?(Service.find(object.service_id))
        when SystemOperation
          objects = [object.messages.take, object.mail_dispatch_rules.take].compact
          object_of_master?(objects.first)
        when Partner, Onboarding, CMS::GroupSection, CMS::LegalTerm, CMS::Template::Version, DeletedObject, PaymentIntent, ProviderConstraints, TopicCategory
          false # assume the test master has none of these
        else
          raise "Object of type #{object}"
        end
      rescue ActiveRecord::RecordNotFound
        # if relation is not found, we consider it part of a deleted provider
        return false
      end
    end
  end

  class WorkerCompatibilityTest < ActiveSupport::TestCase
    include ActiveJob::TestHelper

    setup do
      @service = FactoryBot.create(:service)
    end

    test "perform with hierarchy" do
      fake_ar_object = {}
      @service = FactoryBot.create(:service)
      DeleteObjectHierarchyWorker.perform_later(fake_ar_object, ["Hierarchy-Service-#{@service.id}", "Hierarchy-Proxy-392685", "Hierarchy-ProxyRule-124893"], "fake_method")

      DeleteObjectHierarchyWorker.expects(:perform_later).with(*DeleteObjectHierarchyWorker.send(:hierarchy_entries_for, @service))

      perform_enqueued_jobs queue: "deletion"
    end

    test "perform without hierarchy" do
      @service = FactoryBot.create(:service)
      DeleteObjectHierarchyWorker.perform_later(@service)

      DeleteObjectHierarchyWorker.expects(:perform_later).with(*DeleteObjectHierarchyWorker.send(:hierarchy_entries_for, @service))

      perform_enqueued_jobs queue: "deletion"
    end

    test "perform with bad hierarchy" do
      fake_object = {}
      System::ErrorReporting.expects(:report_error).with do |exception|
        exception.is_a? DeleteObjectHierarchyWorker.const_get(:DoNotRetryError)
      end
      DeleteObjectHierarchyWorker.perform_now(fake_object, ["Some-crap-1324"])
    end
  end

  class DeleteMemberPermissionThroughUserTest < ActiveSupport::TestCase
    include ActiveJob::TestHelper

    def setup
      tenant = FactoryBot.create(:simple_provider)
      @member = FactoryBot.create(:member, account: tenant)
      @member_permission = FactoryBot.create(:member_permission, user: member)
    end

    attr_reader :member, :member_permission

    def test_perform
      perform_enqueued_jobs { DeleteObjectHierarchyWorker.perform_now(member) }

      assert_raises(ActiveRecord::RecordNotFound) { member_permission.reload }
      assert_raises(ActiveRecord::RecordNotFound) { member.reload }
    end
  end

  class DeletePlanUpdatePosition < ActiveSupport::TestCase
    include ActiveJob::TestHelper

    test 'destroy account plan updates position when it is not destroyed by account association' do
      account = FactoryBot.create(:simple_account)
      FactoryBot.create_list(:simple_account_plan, 2, issuer: account)
      plans = account.account_plans.order(position: :asc).to_a
      # note that we don't expect such a hierarchy in the real world ever
      DeletePlainObjectWorker.perform_later(*%W[Association-Service-42:cinstances Plain-AccountPlan-#{plans.first.id}])

      assert_change of: -> { plans.last.reload.position }, by: -1 do
        perform_enqueued_jobs(queue: "deletion")
      end
    end

    test 'destroy account plan does not update position when it is destroyed by account association' do
      account = FactoryBot.create(:simple_account)
      FactoryBot.create_list(:simple_account_plan, 2, issuer: account)
      plans = account.account_plans.order(position: :asc).to_a
      DeletePlainObjectWorker.any_instance.expects(:now).times(3).returns(5,5,20) # limit iterations to 1

      assert_no_change of: -> { plans.last.reload.position } do
        DeletePlainObjectWorker.perform_now(*%W[Plain-Account-#{account.id} Association-Account-#{account.id}:account_plans Plain-AccountPlan-#{plans.first.id}])
      end

      assert_raise(ActiveRecord::RecordNotFound) { plans.first.reload }
    end

    test 'destroy application plan updates position when it is not destroyed by service association' do
      service = FactoryBot.create(:simple_service)
      FactoryBot.create_list(:simple_application_plan, 2, issuer: service)
      plans = service.application_plans.order(position: :asc).to_a
      # note that we don't expect such a hierarchy in the real world ever
      DeletePlainObjectWorker.any_instance.expects(:now).times(3).returns(5,5,20) # limit iterations to 1

      assert_change of: -> { plans.last.reload.position }, by: -1 do
        DeletePlainObjectWorker.perform_now(*%W[Plain-Service-#{service.id} Association-Account-#{Random.random_number(1000000)}:servies Plain-ApplicationPlan-#{plans.first.id}])
      end

      assert_raise(ActiveRecord::RecordNotFound) { plans.first.reload }
    end

    test 'destroy application plan does not update position when it is destroyed by service association' do
      service = FactoryBot.create(:simple_service)
      FactoryBot.create_list(:simple_application_plan, 2, issuer: service)
      plans = service.application_plans.order(position: :asc).to_a
      DeletePlainObjectWorker.any_instance.expects(:now).times(3).returns(5,5,20) # limit iterations to 1

      assert_no_change of: -> { plans.last.reload.position } do
        DeletePlainObjectWorker.perform_now(*%W[Plain-Service-#{service.id} Association-Service-#{service.id}:service_plans Plain-ApplicationPlan-#{plans.first.id}])
      end

      assert_raise(ActiveRecord::RecordNotFound) { plans.first.reload }
    end

    test 'destroy service plan updates position when it is not destroyed by service association' do
      service = FactoryBot.create(:simple_service)
      FactoryBot.create_list(:simple_service_plan, 2, issuer: service)
      plans = service.service_plans.order(position: :asc).to_a
      # note that we don't expect such a hierarchy in the real world ever
      DeletePlainObjectWorker.any_instance.expects(:now).times(3).returns(5,5,20) # limit iterations to 1

      assert_change of: -> { plans.last.reload.position }, by: -1 do
        DeletePlainObjectWorker.perform_now(*%W[Plain-Service-#{service.id} Association-Service-#{Random.random_number(1000000)}:account_plans Plain-ServicePlan-#{plans.first.id}])
      end

      assert_raise(ActiveRecord::RecordNotFound) { plans.first.reload }
    end

    test 'destroy service plan does not update position when it is destroyed by service association' do
      service = FactoryBot.create(:simple_service)
      FactoryBot.create_list(:simple_service_plan, 2, issuer: service)
      plans = service.service_plans.order(position: :asc).to_a
      DeletePlainObjectWorker.any_instance.expects(:now).times(3).returns(5,5,20) # limit iterations to 1

      assert_no_change of: -> { plans.last.reload.position } do
        DeletePlainObjectWorker.perform_now(*%W[Plain-Service-#{service.id} Association-Service-#{service.id}:service_plans Plain-ServicePlan-#{plans.first.id}])
      end

      assert_raise(ActiveRecord::RecordNotFound) { plans.first.reload }
    end
  end

  class DeleteCMSObjects < ActiveSupport::TestCase
    include ActiveJob::TestHelper

    test "deleting CMS::Permissions through User" do
      provider = FactoryBot.create(:provider_account, :with_a_buyer)
      buyer = provider.buyers.first
      cms_group = FactoryBot.create(:cms_group, provider:)
      permission = buyer.permissions.create(:group => cms_group)

      perform_enqueued_jobs(queue: :deletion) do
        DeleteObjectHierarchyWorker.delete_later(buyer)
      end

      assert_raise(ActiveRecord::RecordNotFound) { permission.reload }
    end

    test "deleting CMS::Permissions and CMS::GroupSections through group" do
      provider = FactoryBot.create(:provider_account, :with_a_buyer)
      buyer = provider.buyers.first
      cms_group = FactoryBot.create(:cms_group, provider:)
      group_section = cms_group.group_sections.create(section: provider.provided_sections.first)
      permission = buyer.permissions.create(:group => cms_group)

      perform_enqueued_jobs(queue: :deletion) do
        DeleteObjectHierarchyWorker.delete_later(cms_group)
      end

      assert_raise(ActiveRecord::RecordNotFound) { group_section.reload }
      assert_raise(ActiveRecord::RecordNotFound) { permission.reload }
    end

    test "deleting CMS::GroupSections through sections" do
      cms_group = FactoryBot.create(:cms_group)
      section = cms_group.provider.provided_sections.first
      group_section = cms_group.group_sections.create(section:)

      perform_enqueued_jobs(queue: :deletion) do
        DeleteObjectHierarchyWorker.delete_later(section)
      end

      assert_raise(ActiveRecord::RecordNotFound) { group_section.reload }
    end
  end
end
