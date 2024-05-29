desc "Credit card related tasks"
namespace :credit_cards do

  desc "get all authorize.net payment profiles and store them"
  task :store_authorize_net_payment_profiles => :environment do
    providers = Account.providers.find_all_by_payment_gateway_type(:authorize_net)
    providers.each do |provider|
      provider.buyers.find(:all,
                            :conditions =>  ["credit_card_auth_code IS NOT NULL AND credit_card_authorize_net_payment_profile_token IS NULL"]).each do |account|
        response = provider.payment_gateway.cim_gateway.get_customer_profile(:customer_profile_id => account.credit_card_auth_code)
        account.credit_card_authorize_net_payment_profile_token =
          response.params['profile']['payment_profiles']['customer_payment_profile_id']
        Rails.logger.info "saving #{account.id}, response: #{response.inspect}"
        puts "saving #{account.id}, response: #{response.inspect}"
        # account.save!
      end
    end
  end
end
