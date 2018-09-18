# frozen_string_literal: true

module TestHelpers
  module Master
    def master_account
      ::Account.exists?(master: true) ? ::Account.master : FactoryGirl.create(:master_account)
    end
  end
end

ActiveSupport::TestCase.class_eval do
  include TestHelpers::Master
  extend TestHelpers::Master
end
