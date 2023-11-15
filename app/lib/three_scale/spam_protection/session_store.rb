module ThreeScale::SpamProtection
  class SessionStore

    delegate :[], :[]=, to: :@session

    def initialize(session)
      @session = session
    end

    def marked_as_possible_spam?
      @session[:marked_as_possible_spam_until].to_i > Time.now.utc.to_i
    end

    def mark_possible_spam
      @session[:marked_as_possible_spam_until] = (Time.now.utc + 5.minutes).to_i
    end
  end
end
