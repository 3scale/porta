module Liquid::Tags
  class Email < Liquid::Block
    extend Liquid::Docs::DSL::Tags

    desc %{
     The `email` tag allows you to customize headers of your outgoing emails and is
     available only inside the email templates.

     There are several convenience subtags such as `cc` or `subject` (see the table below)
     that simplify the job but you can also use a `header` subtag to set an arbitrary
     SMTP header for the message.

     | Subtag        | Description        | Example                                           |
     |---------------|--------------------|---------------------------------------------------|
     | subject       | dynamic subject    | {% subject = 'Greetings from Example company!' %} |
     | cc            | carbon copy        | {% cc = 'boss@example.com' %}                     |
     | bcc           | blind carbon copy  | {% bcc = 'all@example.com' %}                     |
     | from          | the actual sender  | {% from = 'system@example.com' %}                 |
     | reply-to      |                    | {% reply-to = 'support@example.com' %}            |
     | header        | custom SMTP header | {% header 'X-SMTP-Group' = 'Important' %}         |
     | do_not_send   | discard the email  | {% do_not_send %}                                 |
    }

    example 'Conditional blind carbon copy', %{
       {% email %}
         {% if plan.system_name == 'enterprise' %}
            {% bcc 'marketing@world-domination.org' %}
         {% endif%}
       {% endemail %}
     }

    example 'Disabling emails at all', %{
       {% email %}
         {% do_not_send %}
       {% endemail %}
    }

    example 'Signup email filter', %{
        {% email %}
          {% if plan.system == 'enterprise' %}
            {% subject = 'Greetings from Example company!' %}
            {% reply-to = 'support@example.com' %}
          {% else %}
            {% do_not_send %}
          {% endif %}
        {% endemail %}
     }

    AssignSyntax = /(#{Liquid::QuotedFragment}+)?\s*=?\s*(#{Liquid::QuotedFragment}+)/
    QuotedFragmentContent = /^['"](.+?)['"]$/

    attr_accessor :headers

    def initialize(name, params, tokens)
      @headers = {}
      super
    end

    def render(context)
      mail    = context.registers[:mail]
      message = context.registers[:message]

      assign_to_mail(mail) if mail
      assign_to_message(message) if message

      "" # we dont want any output
    end

    private

    def unknown_tag(name, params, tokens)
      if name == 'do_not_send'
        @do_not_send = true
      else
        case params =~ AssignSyntax && name
          # when there are two arguments - $1 is first and $2 is second
          # when there is just one - it is $2
        when 'subject'
          @subject = unquote($2)
        when 'header'
          @headers[unquote($1)] = unquote($2)
        when 'bcc'
          @bcc = unquote_array( params.scan(AssignSyntax) )
        when 'cc'
          @cc = unquote_array( params.scan(AssignSyntax) )
        when 'reply_to', 'reply-to'
          @reply_to = unquote($2)
        when 'from'
          @from = unquote($2)
        else
          super
        end
      end
    end

    # removes leading and trailing ' or "
    def unquote(content)
      content =~ QuotedFragmentContent and $1
    end

    # returns flattened arrays of unquotened strings, filters only non empty strings
    def unquote_array(*values)
      values.flatten.map{|v| unquote(v) }.select{|v| v.respond_to?(:to_str)}
    end

    def assign_to_headers(hash)
      hash[:subject] = @subject if @subject

      hash[:bcc] = @bcc if @bcc
      hash[:bcc] = @cc if @cc

      hash[:from] = @from if @from
      hash[:reply_to] = @reply_to if @reply_to
    end

    # assigns existing variables to given message
    def assign_to_message(message)
      message.subject = @subject if @subject

      message.headers['bcc'] = @bcc if @bcc
      message.headers['cc'] = @cc if @cc

      message.headers['from'] = @from if @from
      message.headers['reply-to'] = @reply_to if @reply_to

      message.headers[::Message::DO_NOT_SEND_HEADER] = true if @do_not_send

      @headers.each_pair do |name, value|
        message.headers[name] = value
      end
    end

    # assigns existing variables to given mailer
    def assign_to_mail(mail)
      mail[:subject] = @subject if @subject
      mail[:bcc] = @bcc if @bcc
      mail[:cc] = @cc if @cc
      mail[:from] = @from if @from
      mail[:reply_to] = @reply_to if @reply_to

      @headers[::Message::DO_NOT_SEND_HEADER] = true if @do_not_send

      mail.headers @headers
    end

  end
end
