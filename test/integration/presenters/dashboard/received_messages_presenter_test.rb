# frozen_string_literal: true

require 'test_helper'

module Dashboard
  class ReceivedMessagesPresenterTest < ActionDispatch::IntegrationTest
    def setup
      provider = FactoryBot.create(:simple_provider)
      buyer = FactoryBot.create(:simple_buyer, provider_account: provider)
      messages = FactoryBot.create_list(:message,5, sender: buyer, state: 'sent')
      messages.each { FactoryBot.create_list(:received_message, 5, receiver: provider, message: _1, state: 'unread') }
      @visible_messages = provider.reload.received_messages.not_system
    end

    def test_unread_exist_sql_queries
      skip 'Not available for Oracle' if System::Database.oracle?

      presenter = ReceivedMessagesPresenter.new(@visible_messages)

      # Assert no unexpected SELECT queries (except the ones we expect)
      assert_number_of_queries(0, matching: /SELECT(?!.*LIMIT)/) do
        # Assert we get exactly the queries we expect
        assert_number_of_queries(1, matching: /SELECT.+LIMIT/) do
          presenter.unread_exist?
        end
      end
    end
  end
end
