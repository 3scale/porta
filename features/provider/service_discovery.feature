Feature: Service Discovery
  In order to integrate with 3scale
  Using a Kubernetes/Openshift cluster to deploy both 3scale onpremises and my APIs
  As I provider
  I want to be able to discover my services deployed to the cluster

  Background:
    Given a provider is logged in
    And service discovery is enabled
    And a discoverable API "fake-api" is deployed to the cluster
    And all the rolling updates features are off
    And I have proxy_private_base_path feature enabled

  @javascript
  Scenario: Create service
    When I go to the new service page
    And I create a service via Kubernetes discovery
    And all background jobs related to service discovery are finished
    And I go to the integration page for service "fake-api"
    Then I should see a service with private URL to the local cluster
