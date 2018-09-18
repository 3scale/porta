class DeveloperPortal::SearchController < DeveloperPortal::BaseController
  self.builtin_template_scope = 'search'

  liquify prefix: 'search'

  skip_before_action :verify_authenticity_token, if: -> { request.format.json? }

  def index
    presenter = SearchPresenters::IndexPresenter.new params, request, site_account.id

    respond_to do |format|
      format.html do
        search = Liquid::Drops::Search.new(presenter)
        pagination = Liquid::Drops::Pagination.new(presenter.search, self)
        assign_drops search: search, pagination: pagination
      end

      format.json do
        render :json => presenter.search_results.as_json, callback: callback = params[:callback].presence, content_type: callback ? Mime[:js] : Mime[:json]
      end
    end
  end

  def forum
    @presenter = SearchPresenters::ForumPresenter.new params, request, site_account.id
    render :action => 'index'
  end

  protected

  def login_required
    site_account.settings.public_search? or super
  end
end
