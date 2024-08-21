Rails.application.config.to_prepare do
  ActiveModel::Errors.prepend ActiveModel::ErrorsToXml
end
