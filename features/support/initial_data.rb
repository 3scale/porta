#TODO: join all these into one single Before for speed
Before do
  countries = {'ES' => 'Spain',
               'US' => 'United States of America'}

  countries.each do |code, name|
    Factory(:country, :name => name, :code => code) unless Country.exists?(:code => code)
  end
end

Before do
  ThreeScale.config.stubs(superdomain: 'example.com')
  FieldsDefinition.create_defaults FactoryGirl.create(:master_account)
  ThreeScale.config.stubs(onpremises: false)
  ThreeScale.config.sandbox_proxy.stubs(apicast_registry_url: 'http://apicast.alaska/policies')
end
