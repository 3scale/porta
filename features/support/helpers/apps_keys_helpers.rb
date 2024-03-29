# frozen_string_literal: true

module AppsKeysHelpers

  def fake_application_keys_count(application, number)
    fake_application_keys(application, generate_application_keys(number))
  end

  def fake_application_keys(application, keys)
    ApplicationKey.without_backend do
      application_keys = application.application_keys
      application_keys.delete_all
      keys.each { |key| application_keys.add(key) }
    end
  end

  def generate_application_keys(number)
    Array.new(number.to_i) { SecureRandom.hex(8) }
  end

  def backend_application_url(application, path)
    backend_url("/applications/#{application.application_id}#{path}")
  end

end

World(AppsKeysHelpers)
