module AppsKeysHelpers

  def fake_application_keys_count(application, number)
    fake_application_keys(application, generate_application_keys(number))
  end

  def fake_application_keys(application, keys)
    ApplicationKey.without_backend do
      keys.each do |key|
        application.application_keys.add(key)
      end
    end
  end

  def generate_application_keys(number)
    Array.new(number.to_i) { SecureRandom.hex(8) }
  end

  def backend_application_url(application, path)
    backend_url("/applications/#{application.application_id}#{path}")
  end

end
