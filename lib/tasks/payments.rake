# frozen_string_literal: true

namespace :payments do
  desc 'Save in a file the data of the providers having configured a specific payment gateway'
  task(:provider_data_payment_gateway_configured, %i[payment_gateway file_path] => [:environment]) do |_task, args|
    File.open(args[:file_path], File::WRONLY | File::APPEND | File::CREAT) do |f|
      f.puts 'id;admin_domain;state'

      PaymentGatewaySetting.joins(:account).where(gateway_type: args[:payment_gateway]).order(id: :asc).find_each do |payment_setting|
        next unless payment_setting.configured?

        provider = payment_setting.account

        provider_values_line = %i[id internal_admin_domain state].each_with_object(String.new) do |attr_name, values_line|
          values_line << ";#{provider.public_send(attr_name)}"
        end[1..-1]

        f.puts provider_values_line
      end
    end
  end

  desc 'remove all traces of "adyen" from the DB'
  task(:remove_adyen_from_db => [:environment]) do
    PaymentGatewaySetting.where(gateway_type: :adyen12).joins(:account).find_each do |payment_setting|
      payment_setting.account.buyer_accounts.joins(:payment_detail).find_each do |buyer|
        buyer.payment_detail.destroy!
      end
      payment_setting.destroy!
    end

    adyen_form_regex = /{%\s?adyen12_form[^(%})]*%}/
    CMS::Template.where.not(provider_id: Account.scheduled_for_deletion.select(:id)).where('published LIKE \'%adyen12_form%\'').find_each do |cms_template|
      cms_template.update_column(:published, cms_template.published.gsub(adyen_form_regex, ''))
    end
  end
end
