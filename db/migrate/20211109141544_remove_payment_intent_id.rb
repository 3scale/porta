class RemovePaymentIntentId < ActiveRecord::Migration[5.0]
  def up
    safety_assured { remove_index(:payment_intents, :payment_intent_id) }
    safety_assured { remove_column(:payment_intents, :payment_intent_id)}
  end
end
