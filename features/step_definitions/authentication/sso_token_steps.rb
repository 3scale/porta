# frozen_string_literal: true

Given "the provider generated a sso token for the buyer" do
  create_token(account: @provider)
end

Given "the provider generated a sso token for the buyer, valid for {int} minutes" do |minutes|
  create_token(account: @provider, expires_in: minutes.minutes)
end

Given "another provider generated a sso token for another buyer" do
  buyer = FactoryBot.create(:buyer_account)
  create_token(account: buyer.provider_account, user_id: buyer.users.first.id)
end

def create_token(params)
  @sso_token = FactoryBot.build(:sso_token, params)
  @sso_token.save
end
