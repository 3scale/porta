# This class tries to mimic ActiveMailer interface, but sends internal messages
# insteads of emails.
#
# TODO: make this as close to ActiveMailer as possible. Support templates,
# helpers, and so on.
class Messenger
  include ActionView::Helpers::NumberHelper
  include Rails.application.routes.url_helpers

  class << self
    def method_missing(name, *args)
      if match =  /^deliver_([_a-z]\w*)/.match(name.to_s)
        message = new.send(match[1], *args)
        message.save!
        message.deliver!
      else
        super
      end
    end
  end

  protected

  def set_content(template, options = {})
    file_path = Rails.root.join("app", "views", self.class.to_s.underscore, "#{template}.liquid")
    return Liquid::Template.parse(File.read(file_path)).render(options)
  end

end
