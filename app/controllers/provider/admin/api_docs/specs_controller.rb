class Provider::Admin::ApiDocs::SpecsController < Provider::Admin::BaseController
  def show
    # TODO:
    # - add some kind of cache?
    availables = ['accounts', 'finance', 'analytics']
    id = params.permit(:id)[:id]
    if availables.include?(id.to_s)
      json = File.read(Rails.root.join('doc', 'active_docs', "#{id}-s20.json"))

      hash = JSON.parse(json)
      hash["host"] = request.host_with_port
      hash["schemes"] = ['http'] if Rails.env.development?
      render json: hash
    else
      render json: {error: :not_found}, status: 404
    end
  end
end
