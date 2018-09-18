class ThreeScale::EmailEngagementFooter

  def self.delivering_email message
    if should_add_engagement_footer? message
      message.body= String(message.body) + engagement_footer
    end
  end

  def self.should_add_engagement_footer? message
    message.header[::Message::APPLY_ENGAGEMENT_FOOTER].to_s.present?
  end

  def self.engagement_footer
    "\n--\nPowered by Red Hat 3scale API management\nhttp://www.3scale.net/poweredby\n"
  end
end
