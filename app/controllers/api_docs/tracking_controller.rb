class ApiDocs::TrackingController < FrontendController
  skip_before_action :set_x_content_type_options_header
  skip_before_action :login_required

  skip_before_action :verify_authenticity_token

  def update
    set_cookie! unless cookie == domain

    respond_to do |format|
      json = {:domain => cookie}.to_json
      format.text { render :plain => json }
      format.json { render :json => json, :callback => params[:callback] }
      format.js { render :json => json }
    end
  end

  private
  def domain
    @domain ||= if domain = params[:domain]
                  domain
                elsif url = request.headers['HTTP_REFERER']
                  URI.parse(url).host
                end
  end

  def cookie
    cookies['3scale_domain']
  end

  def set_cookie!
    cookies['3scale_domain'] = { :value => domain, :expires => 1.year.from_now }
  end
end
