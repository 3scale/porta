class IntegrationErrorsService
  def list(service_id, page: 1, per_page: 100)
    pagination = { page: page, per_page: per_page }
    errors     = ThreeScale::Core::ServiceError.load_all(service_id, pagination)

    paginate(errors, page, per_page)
  end

  def delete_all(service_id)
    ThreeScale::Core::ServiceError.delete_all(service_id)
  end

  private

  def paginate(collection, page, per_page)
    WillPaginate::Collection.create(page, per_page, collection.total) do |pager|
      pager.replace(collection.instance_variable_get(:@resources))
    end
  end
end
