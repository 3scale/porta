# frozen_string_literal: true

Given "VAT rate of buyer/provider {account} is {int}%" do |account, rate|
  account.update!(vat_rate: rate.to_f)
end

Given "VAT code of buyer/provider {account} is {int}" do |account, rate|
  account.update!(vat_code: rate.to_f)
end
