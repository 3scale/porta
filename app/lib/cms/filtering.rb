module CMS::Filtering

  extend ActiveSupport::Concern

  included do
    class_attribute :search_origin, :search_type
    self.search_type = name.split("::").last.parameterize
    self.search_origin = 'own'
  end

  def model
    self.class.model_name.human
  end

  def search
    {
        origin: search_origin,
        type: search_type
    }
  end
end
