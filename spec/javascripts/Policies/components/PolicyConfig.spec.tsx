import { mount } from 'enzyme'

import { PolicyConfig } from 'Policies/components/PolicyConfig'
import { HeaderButton } from 'Policies/components/HeaderButton'

import type { Props } from 'Policies/components/PolicyConfig'
import type { ChainPolicy } from 'Policies/types'

describe('PolicyConfig Component', () => {
  /**
   * DISABLING CONSOLE.WARN TO HIDE THIS MESSAGE FROM 'react-jsonschema-form' UNTIL WE UPGRADE to '@rjsf/core'. See https://react-jsonschema-form.readthedocs.io/en/latest/#installation
   *
   * console.warn
   * Warning: componentWillReceiveProps has been renamed, and is not recommended for use. See https://fb.me/react-unsafe-component-lifecycles for details.
   *
   * * Move data fetching code or side effects to componentDidUpdate.
   * * If you're updating state whenever props change, refactor your code to use memoization techniques or move it to static getDerivedStateFromProps. Learn more at: https://fb.me/react-derived-state
   * * Rename componentWillReceiveProps to UNSAFE_componentWillReceiveProps to suppress this warning in non-strict mode. In React 17.x, only the UNSAFE_ name will work. To rename all deprecated lifecycles to their new names, you can run `npx react-codemod rename-unsafe-lifecycles` in your project source folder.
   *
   * Please update the following components: Form
   *
   *   at printWarning (node_modules/react-dom/cjs/react-dom.development.js:88:30)
   *   at warn (node_modules/react-dom/cjs/react-dom.development.js:51:5)
   *   at Object.<anonymous>.ReactStrictModeWarnings.flushPendingUnsafeLifecycleWarnings (node_modules/react-dom/cjs/react-dom.development.js:11377:7)
   *   at flushRenderPhaseStrictModeWarningsInDEV (node_modules/react-dom/cjs/react-dom.development.js:23112:31)
   *   at commitRootImpl (node_modules/react-dom/cjs/react-dom.development.js:22396:3)
   *   at unstable_runWithPriority (node_modules/scheduler/cjs/scheduler.development.js:653:12)
   *   at runWithPriority$1 (node_modules/react-dom/cjs/react-dom.development.js:11039:10)
   */
  const consoleSpy: jest.SpyInstance = jest.spyOn(console, 'warn').mockImplementation(() => '')

  afterAll(() => {
    consoleSpy.mockRestore()
  })

  function setup () {
    const policyConfig: ChainPolicy = {
      uuid: '666',
      enabled: true,
      removable: true,
      name: 'caching',
      humanName: 'Caching policy',
      summary: 'Caching',
      description: ['Configures a cache for the authentication calls against the 3scale'],
      version: 'builtin',
      $schema: 'http://apicast.io/policy-v1/schema#manifest#',
      configuration: {
        properties: {
          caching_type: {
            oneOf: [
              {
                const: 'resilient',
                title: 'Authorize according to last request when backend is down.'
              },
              { const: 'strict',
                title: 'It only caches authorized calls.'
              },
              {
                const: 'allow',
                title: 'When backend is down, allow everything unless seen before and denied.'
              },
              {
                const: 'none',
                title: 'Disables caching.'
              }
            ],
            description: 'Caching mode',
            type: 'string'
          }
        },
        type: 'object'
      },
      data: {}
    }

    const props = {
      policy: policyConfig,
      actions: {
        submitPolicyConfig: jest.fn(),
        removePolicyFromChain: jest.fn(),
        closePolicyConfig: jest.fn(),
        updatePolicyConfig: jest.fn()
      }
    }

    const policyConfigWrapper = mount(<PolicyConfig {...props} />)

    return {
      policyConfig,
      props,
      policyConfigWrapper
    }
  }

  it('should render self', () => {
    const { policyConfigWrapper } = setup()
    expect(policyConfigWrapper.find('section').hasClass('PolicyConfiguration')).toEqual(true)
    expect(policyConfigWrapper.find('.PolicyConfiguration-name').text()).toBe('Caching policy')
    expect(policyConfigWrapper.find('.PolicyConfiguration-version-and-summary').text()).toBe('builtin - Caching')
    expect(policyConfigWrapper.find('.PolicyConfiguration-description').text())
      .toBe('Configures a cache for the authentication calls against the 3scale')
    expect(policyConfigWrapper.find('#policy-enabled').prop('checked')).toEqual(true)
  })

  it('should render correctly the form with the schema given', () => {
    const { policyConfigWrapper } = setup()
    const policyConfigForm = policyConfigWrapper.find('.PolicyConfiguration-form').first()
    expect(policyConfigForm.find('#root_caching_type__description.field-description').text()).toBe('Caching mode')
    expect(policyConfigForm.find('#root_caching_type option').length).toBe(5)
  })

  it('should have a close button', () => {
    const { policyConfigWrapper, props } = setup()
    const closeConfigButton = policyConfigWrapper.find(HeaderButton)
    expect(closeConfigButton.exists('.PolicyChain-addPolicy--cancel')).toEqual(true)
    expect(closeConfigButton.text()).toBe('Cancel')

    closeConfigButton.props().onClick()
    expect(props.actions.closePolicyConfig).toHaveBeenCalledTimes(1)
  })

  it('should have a remove button', () => {
    const { policyConfigWrapper, props } = setup()
    const removePolicyButton = policyConfigWrapper.find('.pf-c-button.pf-m-danger')
    expect(removePolicyButton.exists()).toEqual(true)

    removePolicyButton.simulate('click')
    expect(props.actions.removePolicyFromChain).toHaveBeenCalledTimes(1)
  })

  it('should have a submit button', () => {
    const { policyConfigWrapper } = setup()
    const submitPolicyButton = policyConfigWrapper.find('.PolicyConfiguration-form .pf-c-button[type="submit"]')
    expect(submitPolicyButton.text()).toBe('Update Policy')
  })

  it('should submit the form and call the submit action', () => {
    const { policyConfigWrapper, props } = setup()
    const policyConfigFormProps = policyConfigWrapper.find('.PolicyConfiguration-form').first().props()
    // eslint-disable-next-line @typescript-eslint/no-unsafe-argument
    policyConfigFormProps.onSubmit!({ formData: {}, schema: {} } as any)
    expect(props.actions.submitPolicyConfig).toHaveBeenCalledTimes(1)
  })
})

describe('PolicyConfig APIcast policy', () => {
  function setup () {
    const policyConfig = {
      uuid: '007',
      enabled: true,
      removable: false,
      name: 'apicast',
      humanName: 'APIcast',
      summary: 'Main function...',
      description: ['Main function...'],
      version: 'builtin',
      $schema: 'http://apicast.io/policy-v1/schema#manifest#',
      data: {},
      configuration: {}
    }

    const props: Props = {
      policy: policyConfig,
      actions: {
        submitPolicyConfig: jest.fn(),
        removePolicyFromChain: jest.fn(),
        closePolicyConfig: jest.fn(),
        updatePolicyConfig: jest.fn()
      }
    }

    const policyConfigWrapper = mount(<PolicyConfig {...props} />)

    return {
      policyConfig,
      props,
      policyConfigWrapper
    }
  }

  it('should display the APIcast policy name and summary', () => {
    const { policyConfigWrapper } = setup()
    expect(policyConfigWrapper.find('section').hasClass('PolicyConfiguration')).toEqual(true)
    expect(policyConfigWrapper.find('.PolicyConfiguration-name').text()).toBe('APIcast')
    expect(policyConfigWrapper.find('.PolicyConfiguration-version-and-summary').text()).toBe('builtin - Main function...')
  })

  it('should hide the APIcast policy form', () => {
    const { policyConfigWrapper } = setup()

    expect(policyConfigWrapper.exists('Form')).toEqual(false)
  })
})
