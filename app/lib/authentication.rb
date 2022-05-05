require 'digest/sha1'

module Authentication
  # Uncomment to suit
  RE_LOGIN_OK     = /\A\w[\w\.\-_@\+]+\z/                   # ASCII, strict
  # RE_LOGIN_OK   = /\A[[:alnum:]][[:alnum:]\.\-_@]+\z/     # Unicode, strict
  # RE_LOGIN_OK   = /\A[^[:cntrl:]\\<>\/&]*\z/              # Unicode, permissive
  MSG_LOGIN_BAD   = "use only letters, numbers, and .-_@+ please.".freeze

  RE_NAME_OK      = /\A[^[:cntrl:]\\<>\/&]*\z/              # Unicode, permissive
  MSG_NAME_BAD    = "avoid non-printing characters and \\&gt;&lt;&amp;/ please.".freeze

  # This is purposefully imperfect -- it's just a check for bogus input. See
  # http://www.regular-expressions.info/email.html
  RE_EMAIL_NAME   = '[\'\w\.%\+\-]+'.freeze                 # what you actually see in practice
  #RE_EMAIL_NAME   = '0-9A-Z!#\$%\&\'\*\+_/=\?^\-`\{|\}~\.' # technically allowed by RFC-2822
  RE_DOMAIN_HEAD  = '(?:[A-Z0-9\-]+\.)+'.freeze
  RE_DOMAIN_TLD   = '(?:[A-Za-z]{2,63})'.freeze
  RE_DOMAIN_OK    = /\A#{RE_DOMAIN_HEAD}#{RE_DOMAIN_TLD}\z/i
  RE_EMAIL_OK     = /\A#{RE_EMAIL_NAME}@#{RE_DOMAIN_HEAD}#{RE_DOMAIN_TLD}\z/i
  MSG_EMAIL_BAD   = 'should look like an email address'.freeze

  def self.included( recipient )
    recipient.extend( ModelClassMethods )
    recipient.class_eval do
      include ModelInstanceMethods
    end
  end

  module ModelClassMethods
    def secure_digest(*args)
      Digest::SHA1.hexdigest(args.flatten.join('--'))
    end

    def make_token
      secure_digest(Time.now, (1..10).map{ rand.to_s })
    end
  end # class methods

  module ModelInstanceMethods
  end # instance methods

end
