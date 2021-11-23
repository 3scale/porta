class Provider::Admin::ApiDocs::SpecsController < Provider::Admin::BaseController
  def show
    # TODO:
    # - add some kind of cache?
    availables = ['accounts', 'finance', 'analytics']
    if availables.include?(show_params[:id].to_s)
      json = File.read(Rails.root.join('doc', 'active_docs', "#{show_params[:id]}-s20.json"))

      hash = JSON.parse(json)
      hash["host"] = request.host_with_port
      hash["schemes"] = ['http'] if Rails.env.development?
      render json: hash
    else
      render json: {error: :not_found}, status: 404
    end
  end

  private

  def show_params
    params.permit(:id).to_h
  end
end
