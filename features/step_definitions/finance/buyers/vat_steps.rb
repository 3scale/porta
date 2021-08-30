# frozen_string_literal: true

Given "VAT rate of {provider_or_buyer} is {int}%" do |account, rate|
  account.update_attribute( :vat_rate, rate.to_f)
end

Given "VAT code of {provider_or_buyer} is {int}" do |account, rate|
  account.update_attribute( :vat_code, rate.to_f)
end
