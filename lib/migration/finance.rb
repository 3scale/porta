# frozen_string_literal: true

module Migration
  module Finance

    def self.freeze_closed_invoices_raw
      vat_rate_cmd = "UPDATE invoices i LEFT JOIN accounts buyer ON i.buyer_account_id = buyer.id SET i.vat_rate = buyer.vat_rate;"

      address_cmd = """
  UPDATE invoices i

  LEFT JOIN accounts provider ON i.provider_account_id = provider.id
  LEFT JOIN accounts buyer ON i.buyer_account_id = buyer.id

  LEFT JOIN countries provider_country ON provider.country_id = provider_country.id
  LEFT JOIN countries buyer_country ON buyer.country_id = buyer_country.id

  LEFT JOIN billing_strategies bs ON bs.account_id = provider.id

  SET
    i.fiscal_code = buyer.fiscal_code,
    i.vat_code = buyer.vat_code,
    i.currency = bs.currency,

    i.from_address_name = provider.org_name,
    i.from_address_line1 = provider.org_legaladdress,
    i.from_address_line2 = provider.org_legaladdress_cont,
    i.from_address_city = provider.city,
    i.from_address_region = provider.state_region,
    i.from_address_state = provider.state_region,
    i.from_address_country = provider_country.name,
    i.from_address_zip = provider.zip,
    i.from_address_phone = provider.telephone_number,

    i.to_address_name = buyer.org_name,
    i.to_address_line1 = buyer.org_legaladdress,
    i.to_address_line2 = buyer.org_legaladdress_cont,
    i.to_address_city = buyer.city,
    i.to_address_region = buyer.state_region,
    i.to_address_state = provider.state_region,
    i.to_address_country = buyer_country.name,
    i.to_address_zip = buyer.zip,
    i.to_address_phone = buyer.telephone_number

  WHERE i.state IN ('pending', 'unpaid', 'cancelled', 'failed', 'paid');
  """

      puts 'Caching vat_rates'
      Invoice.connection.execute(vat_rate_cmd)

      puts 'Freezing addresses'
      Invoice.connection.execute(address_cmd)
    end



    # TODO: remove this file when Rails3 are successfully deployed.
    #
    def self.freeze_closed_invoices
      Invoice.reset_column_information
      all = Invoice.count
      count = 0

      Invoice.includes(:buyer_account, :provider_account).find_each(:batch_size => 100) do |invoice|

        begin
          buyer = invoice.buyer
          provider = invoice.provider

          count += 1
          puts "Migrating #{invoice.id} (#{count}/#{all})"

          # just to skip master locally [if you have just one provider in the db
          next if (Rails.env.development? && provider.master?)

          if [ :pending, :unpaid, :cancelled, :failed, :paid ].include?(invoice.state.to_sym)
            invoice.vat_rate = buyer.vat_rate
            invoice.vat_code = buyer.vat_code || ''
            invoice.fiscal_code = invoice.fiscal_code || ''
            invoice.currency = invoice.provider.currency

            invoice.from_address_name = provider.org_name
            invoice.from_address_line1 = provider.org_legaladdress
            invoice.from_address_line2 = provider.org_legaladdress_cont
            invoice.from_address_city = provider.city
            invoice.from_address_state = provider.state
            invoice.from_address_region = provider.state_region
            invoice.from_address_country = provider.country.try!(:name)
            invoice.from_address_zip = provider.zip
            invoice.from_address_phone = provider.telephone_number

            invoice.to_address_name = buyer.org_name
            invoice.to_address_line1 = buyer.org_legaladdress
            invoice.to_address_line2 = buyer.org_legaladdress_cont
            invoice.to_address_city = buyer.city
            invoice.to_address_state = buyer.state
            invoice.to_address_region = buyer.state_region
            invoice.to_address_country = buyer.country.try!(:name)
            invoice.to_address_zip = buyer.zip
            invoice.to_address_phone = buyer.telephone_number
          end

          invoice.vat_rate = buyer.vat_rate
          invoice.save(false)
        rescue => e
          puts "Failed to migrate #{invoice.id}"
          puts e.message
          raise e
        end
      end

      def self.find_invoice_zombies
        ids = Invoice.connection.execute("select invoices.id from invoices join accounts on invoices.buyer_account_id = accounts.id where invoices.state in ('finalized', 'pending', 'open', 'unpaid') and accounts.state = 'scheduled_for_deletion'").map(&:first)

        puts "There are #{ids.count} zombies."
      end

    end
  end
end
