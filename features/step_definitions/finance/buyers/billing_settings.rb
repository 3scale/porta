Given /^(buyer "[^\"]*") is not charged monthly$/ do |buyer|
  buyer.not_paying_monthly!
end

Given /^(buyer "[^\"]*") is not billed monthly$/ do |buyer|
  buyer.not_billing_monthly!
end

# Given /^(buyer "[^\"]*") has VAT rate of [0-9]+$/ do |buyer|
# end
