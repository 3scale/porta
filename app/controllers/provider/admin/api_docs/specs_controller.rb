class Provider::Admin::ApiDocs::SpecsController < Provider::Admin::BaseController
  def show
    # TODO:
    # - add some kind of cache?
    availables = ['accounts', 'finance', 'analytics']
    if availables.include?(params[:id].to_s)
      json = File.read(Rails.root.join('doc', 'active_docs', "#{params[:id]}-s20.json"))

      hash = JSON.parse(json)
      hash["host"] = request_target_host
      hash["schemes"] = ['http'] if Rails.env.development?
      render json: hash
    else
      render json: {error: :not_found}, status: 404
    end
  end
end
