class CurrencyDefault < ActiveRecord::Migration
  def up
    change_column_default :billing_strategies, :currency, 'USD'
  end

  def down
    change_column_default :billing_strategies, :currency, nil
  end
end
