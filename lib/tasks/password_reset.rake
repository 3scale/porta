# frozen_string_literal: true

require 'io/console'

namespace :password do
  namespace :master do
    desc 'Reset password for a master user'
    task(:reset, %i[email_or_username password] => [:environment]) do |_task, args|
      def say(message, icon = :info)
        puts "[#{emoji(icon)}] " + message.to_s
      end

      def emoji(icon)
        case icon
        when :question
          "\e[34m?\e[0m"
        when :info
          "\e[36m\xE2\x84\xB9\e[0m"
        when :ok
          "\e[32m\xE2\x9C\x94\e[0m"
        when :fail
          "\e[32m\xE2\x9C\x96	\e[0m"
        else
          "....."
        end
      end

      say "You are about to change the password of a user of Master tenant"
      email = args.email_or_username
      password = args.password
      password_confirmation = args.password

      if email.blank?
        say "Please give the email or username of the user", :question
        email = STDIN.gets
        email.chomp!
      end
      user = Account.master.users.where.has { |t| (t.email == email) | (t.username == email) }.first
      unless user
        say "Can't find User `#{email}`", :fail
        exit 1
      end
      if password.blank?
        loop do
          say "Please enter the NEW password", :question
          password = STDIN.noecho(&:gets).chomp
          break if password.present?
        end
        loop do
          say "Please confirm the password", :question
          password_confirmation = STDIN.noecho(&:gets).chomp
          break if password_confirmation.present?
        end

        if password != password_confirmation
          say "Password and confirmation does not match", :fail
          exit 1
        end
      end

      user.password = user.password_confirmation = password

      if user.save
        say "`#{email}` password has been changed successfully", :ok
      else
        say "Error in saving #{email} password"
        say user.errors.full_messages.join("\n"), :info
        exit 1
      end

    end
  end
end
