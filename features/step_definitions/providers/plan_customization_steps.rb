Given /^(buyer "[^\"]*") has customized plan$/ do |buyer_account|
  buyer_account.bought_cinstance.customize_plan!
end

