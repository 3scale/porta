module Liquid
  module Tags
    class Form < Liquid::Block

      extend Liquid::Docs::DSL::Tags

      include Rails.application.routes.url_helpers

      # list of allowed html attributes
      HTML_FORM_ATTRIBUTES = ["class", "id"]

      Syntax = /(#{Liquid::QuotedFragment}+)\s*(?:,\s*(#{Liquid::QuotedFragment}*))?(.+)?/o

      info %{
       Renders a form tag with an action and class attribute specified, depending on the name
       of the form. The supported forms are:

        <table>
          <tr>
            <th>Form</th>
            <th>Allowed Field Names</th>
            <th>Spam Protection</th>
            <th>Notes</th>
          </tr>
          <tr>
            <th>application.create</th>
            <td>
              <ul>
                <li>application[name]</li>
                <li>application[description]</li>
                <li>application[&lt;any-extra-field&gt;]</li>
              </ul>
            </td>
            <td>No</td>
            <td></td>
          </tr>
          <tr>
            <th>application.update</th>
            <td>
              <ul>
                <li>application[name]</li>
                <li>application[description]</li>
                <li>application[&lt;any-extra-field&gt;]</li>
              </ul>
            </td>
            <td>No</td>
            <td></td>
          </tr>
          <tr>
            <th>signup</th>
            <td>
              <ul>
                <li>account[org_name]</li>
                <li>account[org_legaladdress]</li>
                <li>account[org_legaladdress_cont]</li>
                <li>account[city]</li>
                <li>account[state]</li>
                <li>account[zip]</li>
                <li>account[telephone_number]</li>
                <li>account[country_id]</li>
                <li>account[&lt;any-extra-field&gt;]</li>
                <li>account[user][username]</li>
                <li>account[user][email]</li>
                <li>account[user][first_name]</li>
                <li>account[user][last_name]</li>
                <li>account[user][password]</li>
                <li>account[user][password_confirmation]</li>
                <li>account[user][title]</li>
                <li>account[user][&lt;any-extra-field&gt;]</li>
              </ul>
            </td>
            <td>Yes</td>
            <td>Sign Up directly to plans of your choice by adding one
                or more hidden fields with a name <code>plan_ids[]</code>.
                If a parameter of such name is found in the current URL,
                the input field is added automagically.
            </td>
          </tr>
        </table>
      }

      example "A form to create an application", %{
        {% form 'application.create', application %}
           <input type='text' name='application[name]'
                  value='{{ application.name }}'
                  class='{{ application.errors.name | error_class }}'/>

           {{ application.errors.name | inline_errors }}

           <input name='commit'  value='Create!'>
        {% endform %}
      }

      def initialize(tag_name, params, tokens)
        super

        @html_attributes = {}

        if params =~ Syntax
          @form_name = $1[1..-2]
          @object_name = $2
          html_options = $3

          if html_options
            html_options.scan(TagAttributes) do | key, value |
              next unless HTML_FORM_ATTRIBUTES.include?(key)
              @html_attributes[key] = Variable.new(value)
            end
          end

        else
          raise "Wrong parameters '#{params}' for a form tag"
        end
      end

      def form_class
        Liquid::Forms.find_class_by_name(@form_name)
      end

      def render(context)

        form = form_class.new(context, @object_name,  @html_attributes.inject({}){|result, (k,v)| result[k] = v.render(context); result} )

        context.stack do
          context.registers[:form] = form
          content = render_all(@nodelist, context).html_safe
          form.render(content)
        end
      rescue Liquid::Forms::Error
        render_error $!.message
      end

      private

      def render_error(msg)
        # TODO: maybe escape the messsage?
        "<!-- form_tag error: #{msg} -->".html_safe
      end

    end
  end

end
