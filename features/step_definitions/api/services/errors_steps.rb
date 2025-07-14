# frozen_string_literal: true

Given "{product} has the following integration errors:" do |product, table|
  transform_integration_errors_table(table)
  errors = table.hashes.map { |error| ThreeScale::Core::ServiceError.new(error) }
  @purge = states('purge').starts_as('pending')

  ThreeScale::Core::ServiceError.stubs(:load_all)
                                .with(product.id, any_parameters)
                                .when(@purge.is('pending'))
                                .returns(ThreeScale::Core::APIClient::Collection.new(errors))
end

Given "they want to empty the integration errors table" do
  product_id = @product.id

  ThreeScale::Core::ServiceError.stubs(:delete_all)
                                .with(product_id)
                                .then(@purge.is('done'))
                                .returns(true)
                                .once

  ThreeScale::Core::ServiceError.stubs(:load_all)
                                .with(product_id, any_parameters)
                                .when(@purge.is('done'))
                                .returns(ThreeScale::Core::APIClient::Collection.new([]))
                                .once
end
