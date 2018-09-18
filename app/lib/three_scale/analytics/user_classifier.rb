# frozen_string_literal: true

require 'ostruct'

module ThreeScale
  module Analytics
    class UserClassifier
      internal_domains_config = (Rails.application.simple_try_config_for(:internal_domains) || []).freeze
      domains = Regexp.union(internal_domains_config).source
      THREESCALE_EMAIL_REGEX = /@(#{domains})$/xi

      EMPTY_USER = OpenStruct.new(email: nil, username: nil).freeze

      def self.classify(user)
        new(user).user_type
      end

      def initialize(user)
        @user = user || EMPTY_USER
      end

      def internal_email_regex
        THREESCALE_EMAIL_REGEX
      end

      def has_3scale_email?
        internal_email_regex.match(@user.email.to_s)
      end

      def is_impersonation_admin?
        @user.impersonation_admin?
      end

      def is_3scale?
        has_3scale_email? || is_impersonation_admin?
      end

      def is_guest?
        @user.username.nil? || @user.email.nil?
      end

      def user_type
        case
        when is_guest? then 'guest'
        when is_impersonation_admin? then 'impersonation_admin'
        when is_3scale? then '3scale'
        else 'customer'
        end
      end
    end
  end
end
