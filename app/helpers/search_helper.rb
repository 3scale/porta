module SearchHelper

  def search_query_value
     (params[:search].is_a?(Hash) && params[:search][:query] ? params[:search][:query] : nil)
  end

  def search_form(data = @search)
    form_for(data, as: :search, url: search_path, builder: ThreeScale::Search::FormBuilder,
             html: {method: :get, class: :search}) do |search|

      [:per_page, :direction, :sort].each do |key|
        next unless params[key]
        concat hidden_field_tag(key, params[key])
      end

      yield(search)
    end
  end

  def search_path
    url_for(:per_page => params[:per_page])
  end
end
