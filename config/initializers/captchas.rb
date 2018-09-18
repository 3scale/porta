
CAPTCHA_QUESTIONS = [ {:question => "What letter comes next: A B C...?", :answer => "D"},
                      {:question => "What letter is missing A B ? D?", :answer => "C"},
                      {:question => "What is the number before 12 and after 10? (number)", :answer => "11"},
                      {:question => "Five times 2 is what? (number)", :answer => "10"},
                      {:question => "Insert the next number in this sequence: 14, 16, ??, 20", :answer => "18"},
                      {:question => "What is the number in our company's name (number)?", :answer => "3"},
                      {:question => "Ten divided by two is what? (number)", :answer => "5"},
                      {:question => "What day comes after Monday?", :answer => "tuesday"},
                      {:question => "What is the last month of the year?", :answer => "december"},
                      {:question => "How many minutes are there in two hours? (number)", :answer => "120"},
                      {:question => "What is the opposite of down?", :answer => "up"},
                      {:question => "What is the opposite of north?", :answer => "south"},
                      {:question => "What is the opposite of bad?", :answer => "good"},
                      {:question => "What is one times four? (number)", :answer => "4"},
                      {:question => "What number comes after 20? (number)", :answer => "21"},
                      {:question => "What month comes before July?", :answer => "june"},
                      {:question => "What is fifteen divided by three? (number)", :answer => "5"},
                      {:question => "What is equal to zero? (number)", :answer => "0"},
                      {:question => "What comes next? 'Monday Tuesday Wednesday ?????'", :answer => "thursday"},
                      {:question => "The grass is...?", :answer => "green"},
                      {:question => "The grass is green, violets are...?", :answer => "blue"},
                      {:question => "Write this text: '3scale'", :answer => "3scale"}]

Recaptcha.configure do |config|
  # Do not verify recaptcha keys if it is not correctly configured
  (config.skip_verify_env ||= []) << Rails.env if Rails.configuration.three_scale.recaptcha_private_key.blank?
  config.site_key = Rails.configuration.three_scale.recaptcha_public_key
  config.secret_key = Rails.configuration.three_scale.recaptcha_private_key
end
