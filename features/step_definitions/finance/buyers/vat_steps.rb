Given /^VAT rate of ((?:buyer|provider) "[^"]*") is (\d+)%$/ do |account, rate|
  account.update_attribute( :vat_rate, rate.to_f)
end

Given /^VAT code of ((?:buyer|provider) "[^"]*") is (\w+)$/ do |account, rate|
  account.update_attribute( :vat_code, rate.to_f)
end
