# frozen_string_literal: true

require 'test_helper'

module Tasks
  class FinanceTest < ActiveSupport::TestCase
    test 'payment_intents:backfill_reference' do
      payment_intent_ids = FactoryBot.create_list(:payment_intent, 5).map(&:id)
      relation = PaymentIntent.where(id: payment_intent_ids)

      # creates the state to be fixed with the rake task
      relation.update_all('payment_intent_id=reference, reference=NULL')

      execute_rake_task 'finance.rake', 'finance:payment_intents:backfill_reference'

      relation.reload.each do |payment_intent|
        assert_equal payment_intent.attributes['payment_intent_id'], payment_intent.reference, "It looks like reference of payment intent ID #{payment_intent.id} wasn't back filled"
      end
    end
  end
end
