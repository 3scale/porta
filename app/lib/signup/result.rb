# frozen_string_literal: true

module Signup
  class Result
    extend ActiveModel::Naming
    extend ActiveModel::Translation
    class AccountMismatchError < ActiveRecord::ActiveRecordError
    end

    def initialize(user:, account:)
      raise AccountMismatchError unless user.account == account
      @user = user
      @account = account
      @errors = ActiveModel::Errors.new(self)
      local_initialize
    end

    def local_initialize; end

    attr_reader :user, :account

    delegate :approve, :approve!, :approved?, :approval_required?, :make_pending!,   to: :account, prefix: true
    delegate :activate, :activate!, :active?, :activate_on_minimal_or_sample_data?,  to: :user, prefix: true
    delegate :id, to: :account

    def valid?
      # It's done this way to get all the errors even if it is already known that is invalid
      [account.valid?, user.valid?, @errors.empty?].all?
    end

    def persisted?
      account.persisted? && user.persisted?
    end

    def save!
      raise ActiveRecord::RecordInvalid if errors.present?

      ActiveRecord::Base.transaction do
        account.save! && user.save!
      end
    end

    def save
      save! # To rollback the transaction and not save any of them if didn't work
    rescue ActiveRecord::RecordInvalid
      false
    end

    def errors
      errors = @errors.dup
      user.errors.full_messages.each    { |user_error|    errors.add(:user, user_error) }
      account.errors.full_messages.each { |account_error| errors.add(:account, account_error) }
      errors
    end

    def add_error(message:, attribute: :base)
      @errors.add(attribute, message)
    end

    def self.name
      'SignupResult'
    end

    private

    # ActiveModel::Errors needs this method to read the errors correctly
    def read_attribute_for_validation(attr)
      public_send(attr)
    end
  end
end
