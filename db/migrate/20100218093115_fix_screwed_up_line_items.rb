class FixScrewedUpLineItems < ActiveRecord::Migration
  def self.up
    items = LineItem.by_type(:periodic_fee).select { |item| item.currency != 'EUR' }

    # Positives
    items.select { |item| item.cost > 0 }.each do |item|
      item.update_attribute(:cost, item.cost.amount.to_has_money('EUR').to_has_money('USD'))
    end

    # Negatives
    items.select { |item| item.cost < 0 }.each do |item|
      item.update_attribute(:cost, 0)
    end
  end

  def self.down
    # Don't bother...
  end
end
