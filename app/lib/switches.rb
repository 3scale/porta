# frozen_string_literal: true

module Switches
  extend ActiveSupport::Concern

  SWITCHES = %i[account_plans service_plans finance require_cc_on_signup
                multiple_services multiple_applications multiple_users skip_email_engagement_footer
                groups branding web_hooks iam_tools].freeze

  THREESCALE_VISIBLE_SWITCHES = %i[
    finance branding groups skip_email_engagement_footer web_hooks require_cc_on_signup
  ].freeze

  class Switch
    delegate :hidden?, :visible?, :denied?, to: :status

    attr_reader :name, :settings

    def initialize(settings, name)
      @settings = settings
      @name = name
    end

    def status
      record = @settings.send(:setting_record_for, :"#{@name}_switch")
      ActiveSupport::StringInquirer.new(record&.value || 'denied')
    end

    def hideable?
      !globally_denied? && Settings.basic_hidden_switches.exclude?(name.to_sym)
    end

    def allowed?
      not denied?
    end

    def hide!
      record = @settings.send(:find_or_build_switch, @name)
      record.hide! if visible?
    end

    def show!
      record = @settings.send(:find_or_build_switch, @name)
      record.show! if hidden?
    end

    def allow
      record = @settings.send(:find_or_build_switch, @name)
      record.allow && record.save!
    end

    def deny
      record = @settings.send(:find_or_build_switch, @name)
      record.deny && record.save!
    end

    def reload
      self
    end

    def globally_denied?
      false
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
    delegate *%i[[] each keys values fetch partition map include? any? all? empty? first with_indifferent_access delete stringify_keys], to: :switches

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
      settings.reload
      assign_switches(*keys)
      self
    end

    private

    def assign_switches(*switch_names)
      @switches = Hash[switch_names.map { |switch_name| [switch_name, settings.send(switch_name)] }]
    end
  end

  included do
    SWITCHES.each do |name|
      # Switch object getter (e.g., settings.finance returns Switch object)
      define_method(name) do
        if globally_denied_switches.include?(name.to_sym)
          SwitchDenied.new(self, name)
        else
          Switch.new(self, name)
        end
      end

      # State query delegations (e.g., settings.multiple_applications_visible?)
      %w[visible hidden denied allowed].each do |state|
        define_method("#{name}_#{state}?") do
          send(name).send("#{state}?")
        end
      end

      # State transition delegations (e.g., settings.allow_finance!)
      %w[allow show hide deny].each do |event|
        define_method("#{event}_#{name}!") do
          find_or_build_switch(name).send("#{event}!")
        end

        define_method("can_#{event}_#{name}?") do
          find_or_build_switch(name).send("can_#{event}?")
        end
      end
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
    Collection.new(self)
  end

  # Using a constant here seems weird as it depends on some parameters
  def globally_denied_switches
    [
      account.master_on_premises? ? :finance : nil
    ].compact
  end

  def visible_ui?(switch)
    setting_name = "#{switch}_ui_visible"
    if respond_to?(setting_name)
      send(setting_name)
    elsif switch == :require_cc_on_signup # visible only for existing providers as of 2016-07-05
      account.provider_can_use?(switch)
    else
      true
    end
  end
end
