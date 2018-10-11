require 'equivalent-xml'

module TestHelpers
  module XmlAssertions

    def xml_document
      Nokogiri::XML::Document.parse(response.body)
    end

    def refute_xml(*args)
      match, nodes = xml_match_and_nodes(args)


      if block_given?
        yield(nodes)
      else
        case match
          when String
            refute_equal match, nodes.text

          when Regexp
            refute_match match, nodes.text
          when NilClass
            assert nodes.blank?
          else
            raise 'Not Implemented'
        end
      end
    end
    alias refute_xpath refute_xml

    def assert_xml(*args)
      match, nodes, msg = xml_match_and_nodes(args)

      if block_given?
        yield(nodes)
      else
        case match
        when String
          assert_equal match, nodes.text

        when Regexp
          assert_match match, nodes.text

        when Numeric
          assert_equal match, nodes.count

        when NilClass
          assert nodes.present?, msg

        when Nokogiri::XML::Document
          assert_equal_xml match, nodes

        else
          raise "Not Implemented"
        end
      end
    end
    alias assert_xpath assert_xml

    def xml_match_and_nodes(args)
      arg = args.shift
      root, selector = arg.respond_to?(:xpath) ? [arg, args.shift] : [xml_document, arg]
      xml_failed_test_message(root, selector)
      [args.shift, root.xpath(selector), xml_failed_test_message(root, selector)]
    end

    def xml_failed_test_message(root, selector)
      if @response && (exception = @controller.instance_variable_get(:@exception))
        exception && exception.message
      else
        "Failed to assert/refute #{selector} in #{root}"
      end
    end

    def assert_xml_404
      assert_response :not_found
      assert_equal '', response.body # the exception detail should not reach the clients
    end

    def assert_xml_403
      assert_response :forbidden
      assert_equal '', response.body # the exception detail should not reach the clients
    end

    def assert_xml_error(doc, error)
      xml = Nokogiri::XML::Document.parse(doc)
      assert xml.xpath('.//errors/error').any? { |e| e.text =~ /#{error}/ }, "Expected #{doc} to include #{error}"
    end

    def assert_xml_single_error(doc, error)
      xml = Nokogiri::XML::Document.parse(doc)
      assert xml.xpath('.//error').any? { |e| e.text =~ /#{error}/ }
    end

    def assert_empty_xml(doc)
      xml = Nokogiri::XML::Document.parse(doc)
      assert xml.root.nil?
    end

    def assert_pagination(doc, tag, attrs = { })
      xml = Nokogiri::XML::Document.parse(doc)
      elem = xml.xpath(".//#{tag}")

      assert elem.attr('per_page').present?
      assert elem.attr('total_entries').present?
      assert elem.attr('total_pages').present?
      assert elem.attr('current_page').present?
      attrs.each_pair do |k, v|
        assert elem.attr(k.to_s).to_s == v.to_s
      end
    end

    def assert_not_pagination(doc, tag, attrs = { })
      xml = Nokogiri::XML::Document.parse(doc)
      elem = xml.xpath(".//#{tag}")

      assert elem.attr('per_page').nil?
      assert elem.attr('total_entries').nil?
      assert elem.attr('total_pages').nil?
      assert elem.attr('current_page').nil?
    end

    def assert_only_account_plans(xml)
      assert  xml.xpath('.//plans/plan/type').all? { |t| t.text == "account_plan" }

      assert !xml.xpath('.//plans/plan/type').any? { |t| t.text == "application_plan" }
      assert !xml.xpath('.//plans/plan/type').any? { |t| t.text == "service_plan" }
    end

    def assert_an_account_plan(xml, account)
      assert xml.xpath('.//plan/type').children.first.to_s == "account_plan"

      assert xml.xpath('.//plan/id').presence
      assert xml.xpath('.//plan/name').presence
      assert xml.xpath('.//plan/type').presence
      assert xml.xpath('.//plan/state').presence
      assert xml.xpath('.//plan/setup_fee').presence
      assert xml.xpath('.//plan/cost_per_month').presence
      assert xml.xpath('.//plan/trial_period_days').presence
      assert xml.xpath('.//plan/cancellation_period').presence
    end

    def assert_only_service_plans(xml)
      assert  xml.xpath('.//plans/plan/type').all? { |t| t.text == "service_plan" }

      assert !xml.xpath('.//plans/plan/type').any? { |t| t.text == "account_plan" }
      assert !xml.xpath('.//plans/plan/type').any? { |t| t.text == "application_plan" }
    end

    def assert_a_service_plan(xml, service)
      assert xml.xpath('.//plan/type').children.first.to_s == "service_plan"
      assert xml.xpath('.//plan/service_id').children.first.to_s == service.id.to_s

      assert xml.xpath('.//plan/id').presence
      assert xml.xpath('.//plan/name').presence
      assert xml.xpath('.//plan/type').presence
      assert xml.xpath('.//plan/state').presence
      assert xml.xpath('.//plan/setup_fee').presence
      assert xml.xpath('.//plan/cost_per_month').presence
      assert xml.xpath('.//plan/trial_period_days').presence
      assert xml.xpath('.//plan/cancellation_period').presence
    end

    def assert_only_application_plans(xml)
      assert  xml.xpath('.//plans/plan/type').all? { |t| t.text == "application_plan" }

      assert !xml.xpath('.//plans/plan/type').any? { |t| t.text == "account_plan" }
      assert !xml.xpath('.//plans/plan/type').any? { |t| t.text == "service_plan" }
    end

    def assert_an_application_plan(xml, service)
      assert xml.xpath('.//plan/type').children.first.to_s == "application_plan"
      assert xml.xpath('.//plan/service_id').children.first.to_s == service.id.to_s

      assert xml.xpath('.//plan/id').presence
      assert xml.xpath('.//plan/name').presence
      assert xml.xpath('.//plan/type').presence
      assert xml.xpath('.//plan/state').presence
      assert xml.xpath('.//plan/setup_fee').presence
      assert xml.xpath('.//plan/cost_per_month').presence
      assert xml.xpath('.//plan/trial_period_days').presence
      assert xml.xpath('.//plan/cancellation_period').presence

      assert_xpath(xml, '//plan/end_user_required')
    end

    def assert_all_features_of_service(xml, service)
      assert xml.xpath('.//features/feature/service_id').presence
      assert xml.xpath('.//features/feature/service_id')
        .all? { |service_id| service_id.text == service.id.to_s }

      assert xml.xpath('.//features/feature/scope').presence
      assert xml.xpath('.//features/feature/scope').all? { |scope|
        ["application_plan", "service_plan"].include?(scope.text)
      }
    end

    def assert_all_account_features(xml, account)
      assert xml.xpath('.//features/feature/account_id').presence
      assert xml.xpath('.//features/feature/account_id')
        .all? { |account_id| account_id.text == account.id.to_s }

      assert xml.xpath('.//features/feature/scope').presence
      assert xml.xpath('.//features/feature/scope')
        .all? { |scope| scope.text == "account_plan" }
    end

    def assert_an_account_feature(xml)
      assert xml.xpath('.//feature/id').presence
      assert xml.xpath('.//feature/name').presence
      assert xml.xpath('.//feature/system_name').presence
      assert xml.xpath('.//feature/account_id').presence
      assert xml.xpath('.//feature/scope').presence
    end

    def assert_a_service_feature(xml)
      assert xml.xpath('.//feature/id').presence
      assert xml.xpath('.//feature/name').presence
      assert xml.xpath('.//feature/system_name').presence
      assert xml.xpath('.//feature/service_id').presence
      assert xml.xpath('.//feature/scope').presence
    end

    def assert_all_features_of_plan(xml, app_plan)
      assert_equal app_plan.feature_ids,
                   xml.xpath('.//features/feature/id').map{|id| id.text.to_i}
    end

    def assert_account(doc, attrs = {})
      xml = Nokogiri::XML::Document.parse(doc)

      assert xml.xpath('.//account').presence
      assert xml.xpath('.//account/id').presence
      assert xml.xpath('.//account/created_at').presence
      assert xml.xpath('.//account/updated_at').presence
      assert xml.xpath('.//account/state').presence
      assert xml.xpath('.//account/plans').presence
      assert xml.xpath('.//account/users').presence

      assert_extra_fields_xml xml, ".//account", attrs
      assert_xml_nodes xml,        ".//account", attrs
    end

    def assert_accounts(doc, attrs = {})
      xml = Nokogiri::XML::Document.parse(doc)

      assert xml.xpath('.//accounts').presence
      assert xml.xpath('.//accounts/account').presence
      assert xml.xpath('.//accounts/account/id').presence
      assert xml.xpath('.//accounts/account/created_at').presence
      assert xml.xpath('.//accounts/account/updated_at').presence
      assert xml.xpath('.//accounts/account/state').presence
      assert xml.xpath('.//accounts/account/plans').presence
      assert xml.xpath('.//accounts/account/users').presence

      assert_extra_fields_xml xml, ".//accounts/account", attrs
      assert_xml_nodes        xml, ".//accounts/account", attrs
    end

    def assert_users(doc, attrs = { })
      xml = Nokogiri::XML::Document.parse(doc)

      assert xml.xpath('.//users').presence
      assert xml.xpath('.//users/user').presence
      assert xml.xpath('.//users/user/id').presence
      assert xml.xpath('.//users/user/created_at').presence
      assert xml.xpath('.//users/user/updated_at').presence
      assert xml.xpath('.//users/user/account_id').presence
      assert xml.xpath('.//users/user/state').presence
      assert xml.xpath('.//users/user/username').presence
      assert xml.xpath('.//users/user/email').presence
      assert xml.xpath('.//users/user/role').presence

      assert_extra_fields_xml xml, ".//users/user", attrs
      assert_xml_nodes xml,        ".//users/user", attrs
    end

    def assert_user(doc, attrs = { })
      xml = Nokogiri::XML::Document.parse(doc)

      assert xml.xpath('.//user').presence
      assert xml.xpath('.//user/id').presence
      assert xml.xpath('.//user/account_id').presence
      assert xml.xpath('.//user/created_at').presence
      assert xml.xpath('.//user/updated_at').presence
      assert xml.xpath('.//user/state').presence
      assert xml.xpath('.//user/username').presence
      assert xml.xpath('.//user/email').presence
      assert xml.xpath('.//user/role').presence

      assert_extra_fields_xml xml, ".//user", attrs
      assert_xml_nodes        xml, ".//user", attrs
    end

    def assert_empty_users(doc)
      xml = Nokogiri::XML::Document.parse(doc)
      assert xml.xpath('.//users').presence
      assert xml.xpath('.//users/*').empty?
    end

    def assert_metric_methods(doc, attrs = { })
      xml = Nokogiri::XML::Document.parse(doc)

      assert xml.xpath('.//methods').presence
      assert xml.xpath('.//methods/method').presence
      assert xml.xpath('.//methods/method/service_id').presence
      assert xml.xpath('.//methods/method/metric_id').presence

      assert_xml_nodes xml, ".//methods/method", attrs
    end

    def assert_metric_method(doc, attrs = { })
      xml = Nokogiri::XML::Document.parse(doc)

      assert xml.xpath('.//method').presence
      assert xml.xpath('.//method/service_id').presence
      assert xml.xpath('.//method/metric_id').presence

      assert_xml_nodes xml, ".//method", attrs
    end

    def assert_usage_limits(doc, attrs = { })
      xml = Nokogiri::XML::Document.parse(doc)

      assert xml.xpath('.//limits').presence
      assert xml.xpath('.//limits/limit').presence
      assert xml.xpath('.//limits/limit/metric_id').presence
      assert xml.xpath('.//limits/limit/plan_id').presence

      assert_xml_nodes xml, ".//limits/limit", attrs
    end

    def assert_usage_limit(doc, attrs = { })
      xml = Nokogiri::XML::Document.parse(doc)

      assert xml.xpath('.//limit').presence
      assert xml.xpath('.//limit/metric_id').presence
      assert xml.xpath('.//limit/plan_id').presence

      assert_xml_nodes xml, ".//limit", attrs
    end

    def assert_pricing_rules(doc, attrs = { })
      xml = Nokogiri::XML::Document.parse(doc)

      assert xml.xpath('.//pricing_rules').presence
      assert xml.xpath('.//pricing_rules/pricing_rule').presence
      assert xml.xpath('.//pricing_rules/pricing_rule/metric_id').presence
      assert xml.xpath('.//pricing_rules/pricing_rule/plan_id').presence
      assert xml.xpath('.//pricing_rules/pricing_rule/cost_per_unit').presence
      assert xml.xpath('.//pricing_rules/pricing_rule/min').presence
      assert xml.xpath('.//pricing_rules/pricing_rule/max').presence

      assert_xml_nodes xml, ".//pricing_rules/pricing_rule", attrs
    end

    def assert_services(doc, attrs = {})
      xml = Nokogiri::XML::Document.parse(@response.body)

      assert xml.xpath('.//services/service').presence
      assert xml.xpath('.//services/service/id').presence
      assert xml.xpath('.//services/service/account_id').presence
      assert xml.xpath('.//services/service/name').presence
      assert xml.xpath('.//services/service/state').presence
      assert xml.xpath('.//services/service/metrics').presence

      assert_xml_nodes xml, ".//services/service", attrs
    end

    def assert_service(doc, attrs = {})
      xml = Nokogiri::XML::Document.parse(@response.body)

      assert xml.xpath('.//service').presence
      assert xml.xpath('.//service/id').presence
      assert xml.xpath('.//service/account_id').presence
      assert xml.xpath('.//service/name').presence
      assert xml.xpath('.//service/state').presence
      assert xml.xpath('.//service/metrics').presence

      assert_xml_nodes xml, ".//service", attrs
    end

    def assert_applications(doc, attrs = {})
      xml = Nokogiri::XML::Document.parse(doc)

      assert xml.xpath('.//applications/application').presence
      assert xml.xpath('.//applications/application/id').presence
      assert xml.xpath('.//applications/application/created_at').presence
      assert xml.xpath('.//applications/application/updated_at').presence
      assert xml.xpath('.//applications/application/state').presence
      assert xml.xpath('.//applications/application/user_account_id').presence

      assert xml.xpath('.//applications/application/plan').presence

      backend = attrs.delete(:backend)
      if backend == "1"
        assert xml.xpath('.//applications/application/user_key').presence
        assert xml.xpath('.//applications/application/provider_verification_key').presence
      end

      if backend == "2" || backend == :oauth
        assert xml.xpath('.//applications/application/application_id').presence
        assert xml.xpath('.//applications/application/keys').presence
      end

      if backend == :oauth
        assert xml.xpath('.//applications/application/redirect_url').presence
      end

      assert_xml_nodes xml, ".//applications/application", attrs
    end

    def assert_payment_transactions(doc, attrs = {})
      xml = Nokogiri::XML::Document.parse(doc)

      assert xml.xpath('.//payment_transactions/payment_transaction').presence
      assert xml.xpath('.//payment_transactions/payment_transaction/id').presence
      assert xml.xpath('.//payment_transactions/payment_transaction/created_at').presence
      assert xml.xpath('.//payment_transactions/payment_transaction/updated_at').presence

      assert xml.xpath('.//payment_transactions/payment_transaction/invoice_id').presence
      assert xml.xpath('.//payment_transactions/payment_transaction/account_id').presence
      assert xml.xpath('.//payment_transactions/payment_transaction/reference').presence
      assert xml.xpath('.//payment_transactions/payment_transaction/success').presence
      assert xml.xpath('.//payment_transactions/payment_transaction/amount').presence
      assert xml.xpath('.//payment_transactions/payment_transaction/currency').presence
      assert xml.xpath('.//payment_transactions/payment_transaction/action').presence
      assert xml.xpath('.//payment_transactions/payment_transaction/message').presence
      assert xml.xpath('.//payment_transactions/payment_transaction/gateway_response').presence
      assert xml.xpath('.//payment_transactions/payment_transaction/test').presence

      assert_xml_nodes xml, ".//payment_transactions/payment_transaction", attrs
    end

    def assert_equal_xml(expected, actual)
      expected = Nokogiri::XML.parse(expected.respond_to?(:to_xml) ? expected.to_xml : expected.to_s)
      actual = Nokogiri::XML.parse(actual.respond_to?(:to_xml) ? actual.to_xml : actual.to_s)

      EquivalentXml.equivalent?(actual, expected) do |expected, actual, result|
        assert result, "#{expected} expected to be #{actual}"
      end
    end

    def assert_application(doc, attrs = {})
      xml = Nokogiri::XML::Document.parse(doc)

      assert xml.xpath('.//application').presence
      assert xml.xpath('.//application/id').presence
      assert xml.xpath('.//application/created_at').presence
      assert xml.xpath('.//application/updated_at').presence
      assert xml.xpath('.//application/state').presence
      assert xml.xpath('.//application/user_account_id').presence
      assert_xpath xml, './/application/end_user_required'

      assert xml.xpath('.//application/plan').presence

      if attrs.delete(:v1)
        assert xml.xpath('.//application/user_key').presence
        assert xml.xpath('.//application/provider_verification_key').presence
      end

      backend_v2    = attrs.delete(:v2)
      backend_oauth = attrs.delete(:oauth)
      if backend_v2 || backend_oauth
        assert xml.xpath('.//application/application_id').presence
        assert xml.xpath('.//application/keys').presence
      end

      if backend_oauth
        assert xml.xpath('.//application/redirect_url').presence
      end

      assert_extra_fields_xml xml, ".//application", attrs
      assert_xml_nodes        xml, ".//application", attrs
    end

    def assert_extra_fields_xml(xml, node, attrs)
      assert xml.xpath("#{node}/extra_fields").presence
      extra_fields = attrs.delete(:extra_fields)

      if extra_fields
        assert_xml_nodes xml, "#{node}/extra_fields", extra_fields
      end
    end

    def assert_xml_nodes(xml, node, attrs)
      attrs.each_pair do |attr, expected_value|
        nodes = xml.xpath("#{node}/#{attr}")

        assert false == nodes.empty?
        assert nodes.map(&:to_s).all? { |node_value|
          node_value =~ />#{expected_value.to_s}</
        }
      end
    end

  end
end
