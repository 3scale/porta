# frozen_string_literal: true

# Copyright (c) 2005 Jamis Buck
#
# Permission is hereby granted, free of charge, to any person obtaining
# a copy of this software and associated documentation files (the
# "Software"), to deal in the Software without restriction, including
# without limitation the rights to use, copy, modify, merge, publish,
# distribute, sublicense, and/or sell copies of the Software, and to
# permit persons to whom the Software is furnished to do so, subject to
# the following conditions:
#
# The above copyright notice and this permission notice shall be
# included in all copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
# EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
# MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
# NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE
# LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION
# OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION
# WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
#
# Extracted from https://github.com/mperham/deadlock_retry/blob/874c80de92d9eb30405536916aff86f616649b01/lib/deadlock_retry.rb
require 'active_support/core_ext/module/attribute_accessors'

module DeadlockRetry
  def self.included(base)
    class << base
      prepend(ClassMethods)
    end
  end

  mattr_accessor :innodb_status_cmd

  module ClassMethods
    DEADLOCK_ERROR_MESSAGES = [
      "Deadlock found when trying to get lock",
      "Lock wait timeout exceeded",
      "deadlock detected"
    ]

    MAXIMUM_RETRIES_ON_DEADLOCK = 3


    def transaction(...)
      retry_count = 0

      check_innodb_status_available

      begin
        super
      rescue ActiveRecord::StatementInvalid => error
        raise if in_nested_transaction?
        if DEADLOCK_ERROR_MESSAGES.any? { |msg| error.message =~ /#{Regexp.escape(msg)}/ }
          raise if retry_count >= MAXIMUM_RETRIES_ON_DEADLOCK
          retry_count += 1
          logger.info "Deadlock detected on retry #{retry_count}, restarting transaction"
          log_innodb_status if DeadlockRetry.innodb_status_cmd
          exponential_pause(retry_count)
          retry
        else
          raise
        end
      end
    end

    private

    WAIT_TIMES = [0, 1, 2, 4, 8, 16, 32]

    def exponential_pause(count)
      sec = WAIT_TIMES[count-1] || 32
      # sleep 0, 1, 2, 4, ... seconds up to the MAXIMUM_RETRIES.
      # Cap the pause time at 32 seconds.
      sleep(sec) if sec != 0
    end

    def in_nested_transaction?
      # open_transactions was added in 2.2's connection pooling changes.
      connection.open_transactions != 0
    end

    def show_innodb_status
      self.connection.select_value(DeadlockRetry.innodb_status_cmd)
    end

    # Should we try to log innodb status -- if we don't have permission to,
    # we actually break in-flight transactions, silently (!)
    def check_innodb_status_available
      return unless DeadlockRetry.innodb_status_cmd == nil

      if self.connection.adapter_name == "MySQL"
        begin
          mysql_version = self.connection.select_rows('show variables like \'version\'')[0][1]
          cmd = if mysql_version < '5.5'
            'show innodb status'
          else
            'show engine innodb status'
          end
          self.connection.select_value(cmd)
          DeadlockRetry.innodb_status_cmd = cmd
        rescue
          logger.info "Cannot log innodb status: #{$!.message}"
          DeadlockRetry.innodb_status_cmd = false
        end
      else
        DeadlockRetry.innodb_status_cmd = false
      end
    end

    def log_innodb_status
      # show innodb status is the only way to get visiblity into why
      # the transaction deadlocked.  log it.
      lines = show_innodb_status
      logger.warn "INNODB Status follows:"
      lines.each_line do |line|
        logger.warn line
      end
    rescue => e
      # Access denied, ignore
      logger.info "Cannot log innodb status: #{e.message}"
    end

  end
end

ActiveRecord::Base.send(:include, DeadlockRetry) if defined?(ActiveRecord)
