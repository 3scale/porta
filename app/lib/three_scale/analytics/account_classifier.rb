require 'ostruct'

module ThreeScale
  module Analytics
    class AccountClassifier
      EMPTY_ACCOUNT = OpenStruct.new(users: []).freeze

      def self.classify(account)
        new(account).account_type
      end

      def initialize(account)
        @account = account || EMPTY_ACCOUNT
      end

      def is_3scale?
        @account.users.all? { |user| classify_user(user).is_3scale? }
      end

      def account_type
        case
        when is_3scale? then 'Internal'.freeze
        else 'Customer'.freeze
        end
      end

      protected

      def classify_user(user)
        UserClassifier.new(user)
      end
    end
  end
end
