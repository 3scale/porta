module Admin::FieldsDefinitionsHelper

  def retrieve_properties_of field
    %w[hidden read_only required].select{ |property| field.send(property)}.to_sentence.humanize
  end

end
