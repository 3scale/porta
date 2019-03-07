# frozen_string_literal: true

module Switches
  extend ActiveSupport::Concern

  SWITCHES = %i[end_users account_plans service_plans finance require_cc_on_signup
                multiple_services multiple_applications multiple_users skip_email_engagement_footer
                groups branding web_hooks iam_tools].freeze

  THREESCALE_VISIBLE_SWITCHES = %i[
    finance branding end_users groups skip_email_engagement_footer web_hooks require_cc_on_signup
  ].freeze

  class Switch
    delegate :hidden?, :visible?, :denied?, to: :status

    attr_reader :name, :settings

    def initialize(settings, name)
      @settings = settings
      @name = name
    end

    def status
      # it has to be read_attribute - calling the method would cause
      # return a Switch object
      ActiveSupport::StringInquirer.new(@status || update_status)
    end

    def hideable?
      !globally_denied? && Settings.basic_hidden_switches.exclude?(name.to_sym)
    end

    def allowed?
      not denied?
    end

    def hide!
      if visible?
        @settings.send("hide_#{@name}!")
      end
    ensure
      update_status
    end

    def show!
      if hidden?
        @settings.send("show_#{@name}!")
      end
    ensure
      update_status
    end

    def allow
      @settings.send("allow_#{@name}")
    ensure
      update_status
    end

    def deny
      @settings.send("deny_#{@name}")
    ensure
      update_status
    end

    def reload
      @settings = @settings.clone.reload
      update_status
      self
    end

    def globally_denied?
      false
    end

    private

    def update_status
      @status = @settings.read_attribute("#{@name}_switch").to_s
    end
  end

  class SwitchDenied < Switch
    def allowed?
      false
    end

    def hidden?
      false
    end

    def visible?
      false
    end

    def denied?
      true
    end

    def hide!
      false
    end

    def show!
      false
    end

    def allow
      false
    end

    def deny
      true
    end

    def globally_denied?
      true
    end
  end

  class Collection
    def initialize(settings, switch_names = SWITCHES)
      @settings = settings
      assign_switches(*switch_names)
    end

    attr_reader :settings, :switches
    delegate *%i[[] each keys values fetch partition map include? any? all? empty? first with_indifferent_access delete], to: :switches

    def slice(*switch_names)
      self.class.new(settings, switch_names)
    end

    def except(*switch_names)
      slice(*(keys - switch_names))
    end

    def select(&block)
      slice(*(switches.select(&block).keys))
    end

    %i[allowed denied visible hidden hideable].each do |method_sym|
      define_method(method_sym) do
        switch_names = switches.select { |_, switch| switch.send("#{method_sym}?") }.keys
        slice(*switch_names)
      end
    end

    def reload
      @settings = settings.clone.reload
      assign_switches(*keys)
      self
    end

    private

    def assign_switches(*switch_names)
      @switches = Hash[switch_names.map { |switch_name| [switch_name, settings.send(switch_name)] }]
    end
  end

  MULTISERVICES_MAX_SERVICES = 3

  included do
    SWITCHES.each do |name|
      attr_name = "#{name}_switch"
      attr_protected attr_name

      # Switches State Machine
      #
      #
      #    +--------------+	                         +--------------+
      #    |              +                          |              |
      #    | Visible      |                          |   DENIED     |
      #    |              |       deny               |              |
      #    |              o------------------------->+              |
      #    +---+-----+----+			                     +-----+--------+
      # 	   |	 |				                               ^  |
      # 	   |	 | hide/show		                         |  |
      # 	   |	 |			                                 |  |
      # 	+--+-----+----+	         deny          	       |  |
      # 	|             |-------------------------------    |
      # 	|  Hidden     |          allow                    |
      # 	|             |<-----------------------------------
      # 	|             |
      # 	+-------------+
      #
      state_machine attr_name, initial: :denied, namespace: name do
        before_transition do |settings|
          unless settings.account.provider?
            raise Account::ProviderOnlyMethodCalledError, "cannot change state of #{name} of #{settings.inspect}"
          end
        end

        state :denied, :hidden, :visible

        event :hide do
          transition visible: :hidden
        end

        event :show do
          transition hidden: :visible
        end

        event :deny do
          transition [:hidden, :visible] => :denied
        end

        event :allow do
          transition denied: :hidden
        end
      end

      # Overrides the model's attribute reader
      define_method(name) do
        if globally_denied_switches.include?(name.to_sym)
          SwitchDenied.new(self, name)
        else
          Switch.new(self, name)
        end
      end
    end

    finance_state_machine = state_machines['finance_switch']

    finance_state_machine.after_transition to: :denied, from: %i[hidden visible] do |settings|
      settings.account.billing_strategy.destroy if settings.account.billing_strategy
    end

    finance_state_machine.after_transition to: %i[visible hidden], from: [:denied] do |settings|
      unless settings.account.billing_strategy
        account = settings.account
        account.billing_strategy = Finance::PostpaidBillingStrategy.create(account: account, currency: 'USD')
        account.save!
      end
    end

    state_machines['multiple_applications_switch'].after_transition to: %i[visible hidden], from: [:denied] do |settings|
      SimpleLayout.new(settings.account).create_multiapp_builtin_pages!
    end

    state_machines['multiple_services_switch'].after_transition to: %i[visible hidden], from: [:denied] do |settings|
      SimpleLayout.new(settings.account).create_multiservice_builtin_pages!

      settings.account.update_provider_constraints_to(
        { max_services: MULTISERVICES_MAX_SERVICES },
        'Upgrading max_services because of switch is enabled.'
      )
    end

    state_machines['service_plans_switch'].after_transition to: %i[visible hidden], from: [:denied] do |settings|
      SimpleLayout.new(settings.account).create_service_plans_builtin_pages!
    end
  end

  module ClassMethods
    def hide_basic_switches?
      Rails.configuration.three_scale.hide_basic_switches
    end

    def basic_enabled_switches
      if hide_basic_switches?
        %i(multiple_services multiple_applications multiple_users).freeze
      else
        [].freeze
      end
    end

    def basic_disabled_switches
      if hide_basic_switches?
        %i(skip_email_engagement_footer).freeze
      else
        [].freeze
      end
    end

    def basic_hidden_switches
      basic_disabled_switches
    end
  end

  def switches
    # Hash[SWITCHES.map{ |switch_name| [ switch_name, send(switch_name) ] }]
    Collection.new(self)
  end

  # Using a constant here seems weird as it depends on some parameters
  def globally_denied_switches
    [
      account.master_on_premises? ? :finance : nil,
      ThreeScale.config.onpremises ? :end_users : nil
    ].compact
  end

  def visible_ui?(switch)
    attribute = "#{switch}_ui_visible"
    if has_attribute?(attribute)
      self[attribute]
    elsif switch == :require_cc_on_signup # visible only for existing providers as of 2016-07-05
      account.provider_can_use?(switch)
    else
      true
    end
  end
end
