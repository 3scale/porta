When "an admin is reviewing services index page" do
  FactoryBot.create(:service, name: 'First', account: @provider)
  FactoryBot.create(:service, name: 'Last', account: @provider)

  visit admin_services_path
end
