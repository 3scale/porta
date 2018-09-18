#! rails runner
# -*- mode: Ruby;-*-
#

class InvalidDataDetector

  def initialize
    @invalid = {}
  end

  def search
    puts 'Searching for invalid data'


    Account.providers.find_each do |p|
      @current = p.id

      unless p.sections.find_by_system_name('root')
        error 'root section missing'
      end

      if p.billing_strategy && p.settings.finance.denied?
        error 'finance denied but billing strategy exists'
      end

      if p.billing_strategy.nil? && p.settings.finance.allowed?
        error 'missing billing strategy'
      end

      if p.provided_cinstances.find_each do |app|
        if app.user_account.nil?
          error "application #{app.id} has no buyer"
        end
      end

      if (count = p.forum.posts_count) < 0
        error "forum posts_count is #{count}"
      end
    end



      puts "Found errors in '#{p.name}': #{@invalid[p.id]}" if @invalid[p.id].present?
    end

    puts @invalid.inspect

    @invalid.empty? ? 0 : -1
  end

  private

  def error(msg)
    errors = @invalid[@current] ||= []
    errors << msg
  end
end

exit InvalidDataDetector.new.search
