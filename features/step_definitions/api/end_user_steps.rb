Given /^(provider "[^\"]*") has end user "([^\"]*)" on service "([^\"]*)"$/ do |provider, name, service_name|
  service = provider.services.find_by_name!(service_name)
  EndUser.create(service, username: name)
  ThreeScale::Core::User.stubs(:load).with(service.backend_id, name)
    .returns(stub(username: name, plan_id: nil))
end
