# frozen_string_literal: true

class ReactPageGenerator < Rails::Generators::NamedBase
  desc 'TODO'

  class_option :module, type: :string, required: true

  def create_view_file
    create_file "app/views/#{file_name}.html.slim", <<~FILE
      ##{container_id}
        = javascript_pack_tag '#{module_name}/#{pack_file_name}'
    FILE
  end

  def create_pack_file
    create_file "app/javascript/packs/#{module_name}/#{pack_file_name}.js", <<~FILE
      // @flow

      import { #{component_name}Wrapper } from '#{module_name}/components/#{component_name}'
      import { safeFromJsonString } from 'utilities'

      document.addEventListener('DOMContentLoaded', () => {
        const containerId = '#{container_id}'
        const container = document.getElementById(containerId)

        if (!container) {
          throw new Error(`Container tag #${containerId} not found`)
        }

        // Get props from dataset here

        #{component_name}Wrapper({
          // Pass props
        }, containerId)
      })
    FILE
  end

  def create_react_component
    create_file "app/javascript/src/#{module_name}/components/#{component_name}.jsx", <<~FILE
      // @flow

      import * as React from 'react'

      import { createReactWrapper } from 'utilities'

      import './#{component_name}.scss'

      type Props = {
        // props here
      }

      const #{component_name} = (props: Props): React.Node => {
        // logic here

        return (
          <div>#{component_name}</div>
        )
      }

      const #{component_name}Wrapper = (props: Props, containerId: string): void => createReactWrapper(<#{component_name} {...props} />, containerId)

      export { #{component_name}, #{component_name}Wrapper }
    FILE
  end

  def create_stylesheet_file
    create_file "app/javascript/src/#{module_name}/components/#{component_name}.scss", <<~FILE
      ##{container_id} {
        // Your styles here
      }
    FILE
  end

  def create_test_file
    create_file "spec/javascripts/#{module_name}/components/#{component_name}.spec.jsx", <<~FILE
      // @flow

      import React from 'react'
      import { mount } from 'enzyme'

      import { #{component_name} } from '#{module_name}/components/#{component_name}'

      const defaultProps = {
        // props here
      }

      const mountWrapper = (props) => mount(<#{component_name} {...{ ...defaultProps, ...props }} />)

      afterEach(() => {
        jest.resetAllMocks()
      })

      it('should render itself', () => {
        const wrapper = mountWrapper()
        expect(wrapper.exists()).toBe(true)
      })
    FILE
  end

  def add_module_to_flow_config
    # TODO
  end

  private

  def pack_file_name
    name.downcase
  end

  def component_name
    "#{name}Page"
  end

  def module_name
    @module_name ||= options['module']
  end

  def container_id
    "#{component_name.underscore.dasherize}-container"
  end
end
