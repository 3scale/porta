# frozen_string_literal: true

module Switches
  extend ActiveSupport::Concern

  SWITCHES = Settings::SWITCH_CLASSES.map { |k| k.setting_name.to_s.delete_suffix('_switch').to_sym }.freeze

  PROVIDER_VISIBLE_SWITCHES = Settings::SWITCH_CLASSES
    .select(&:provider_visible)
    .map { |k| k.setting_name.to_s.delete_suffix('_switch').to_sym }
    .freeze

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
      # Switch record getter (e.g., settings.finance returns the SwitchSetting record)
      define_method(name) do
        find_or_build_switch(name)
      end

      # State query delegations (e.g., settings.multiple_applications_visible?)
      %w[visible hidden denied allowed hideable].each do |state|
        define_method("#{name}_#{state}?") do
          send(name).send("#{state}?")
        end
      end

      # State transition delegations (e.g., settings.allow_finance!, settings.allow_finance)
      %w[allow show hide deny].each do |event|
        define_method("#{event}_#{name}!") do
          find_or_build_switch(name).send("#{event}!")
        end

        define_method("#{event}_#{name}") do
          find_or_build_switch(name).send("#{event}")
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
