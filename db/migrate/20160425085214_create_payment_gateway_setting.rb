class CreatePaymentGatewaySetting < ActiveRecord::Migration
  def change
    create_table :payment_gateway_settings  do |t|
      t.binary :gateway_settings
      t.string :gateway_type
      t.column :account_id, 'bigint(20)'

      t.timestamps
    end

    reversible do |direction|
      direction.up  do
        execute <<-SQL.strip_heredoc
          INSERT INTO `payment_gateway_settings` (`account_id`, `gateway_settings`, `gateway_type`)
          SELECT `accounts`.`id`, `accounts`.`payment_gateway_options`, `accounts`.`payment_gateway_type`
          FROM `accounts`  WHERE `accounts`.`payment_gateway_type` IS NOT NULL AND ((provider OR master))
        SQL
      end
    end
  end

end

__END__

# SQL COMMAND TO GENERATE THE TABLE
Account.providers_with_master.where.not(payment_gateway_type: nil).select([:id, :payment_gateway_options, :payment_gateway_type]).to_sql

#=> SELECT `accounts`.`id`, `accounts`.`payment_gateway_options`, `accounts`.`payment_gateway_type` FROM `accounts`  WHERE `accounts`.`payment_gateway_type` IS NOT NULL AND ((provider OR master))


