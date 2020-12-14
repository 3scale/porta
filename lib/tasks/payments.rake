# frozen_string_literal: true

namespace :payments do
  desc 'Save in a file the data of the providers having configured a specific payment gateway'
  task(:provider_data_payment_gateway_configured, %i[payment_gateway file_path] => [:environment]) do |_task, args|
    provider_data_attributes = %i[id admin_domain state]
    File.open(args[:file_path], File::WRONLY | File::APPEND | File::CREAT) do |f|
      f.puts provider_data_attributes.map(&:to_s).join(';')

      PaymentGatewaySetting.joins(:account).where(gateway_type: args[:payment_gateway]).order(id: :asc).find_each do |payment_setting|
        next unless payment_setting.configured?

        provider = payment_setting.account
        next if provider.scheduled_for_deletion?

        provider_values_line = provider_data_attributes.each_with_object(String.new) do |attr_name, values_line|
          values_line << ";#{provider.public_send(attr_name)}"
        end[1..-1]

        f.puts provider_values_line
      end
    end
  end
end
