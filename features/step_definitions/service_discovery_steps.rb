Given(/^service discovery is (not )?enabled$/) do |disabled|
  ThreeScale.config.service_discovery.stubs(enabled: disabled.blank?)
end

include TestHelpers::ServiceDiscovery

Given(/^a discoverable API "([^\"]*)" is deployed to the cluster$/) do |api_name|
  cluster_service_metadata = {
    name: api_name || 'fake-api',
    namespace: 'fake-project',
    labels: { :'discovery.3scale.net' => 'true' },
    annotations: {
      :'discovery.3scale.net/scheme' => 'http',
      :'discovery.3scale.net/port' => '8081',
      :'discovery.3scale.net/path' => 'api',
      :'discovery.3scale.net/description-path' => 'api/doc'
    }
  }
  @cluster_service = ServiceDiscovery::ClusterService.new(cluster_service(metadata: cluster_service_metadata))
end

Given(/^I create a service via Kubernetes discovery$/) do
  Sidekiq::Testing.fake!
  ServiceCreationService.call(@provider, name: @cluster_service.name,
                                         namespace: @cluster_service.namespace,
                                         source: 'discover')
end

Given(/^all background jobs related to service discovery are finished$/) do
  ServiceDiscovery::ClusterClient.any_instance.stubs(:find_discoverable_service_by).with(name: @cluster_service.name, namespace: @cluster_service.namespace).returns(@cluster_service)
  @cluster_service.stubs(fetch_specification: false)
  ServiceDiscovery::ImportClusterServiceDefinitionsWorker.drain
end

Then(/^I should see a service with private URL to the local cluster$/) do
  assert_match @cluster_service.endpoint, page.body
end
