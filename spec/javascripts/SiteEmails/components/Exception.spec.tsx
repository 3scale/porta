import { mount } from 'enzyme'
import { Button, TextInput, InputGroupText, Spinner } from '@patternfly/react-core'

import { Exception } from 'SiteEmails/components/Exception'

import type { Props } from 'SiteEmails/components/Exception'
import type { Product } from 'SiteEmails/types'

const mockProduct: Product = {
  id: 1,
  name: 'Test Product',
  systemName: 'test_product',
  updatedAt: '2023-01-01',
  supportEmail: 'support@test.com'
}

const defaultProps: Props = {
  product: mockProduct,
  isBeingEdited: false,
  isEditLoading: false,
  isEditable: true,
  onEdit: jest.fn(),
  onSave: jest.fn(),
  onCancel: jest.fn(),
  onRemove: jest.fn()
}

const mountWrapper = (props: Partial<Props> = {}) => mount(<Exception {...{ ...defaultProps, ...props }} />)

it('renders itself', () =>{
  const wrapper = mountWrapper()
  expect(wrapper.exists(Exception)).toEqual(true)
})

describe('when not being edited', () => {
  const props = { isBeingEdited: false }

  it('renders in readonly mode', () => {
    const wrapper = mountWrapper(props)

    expect(wrapper.find(InputGroupText).children().text()).toEqual(mockProduct.name)
    expect(wrapper.find(TextInput).props().readOnly).toEqual(true)
  })

  it('can be edited', () => {
    const wrapper = mountWrapper(props)
    expect(defaultProps.onEdit).not.toHaveBeenCalled()

    const editButton = wrapper.find('button[aria-label^="Edit"]')
    expect(editButton.props().disabled).toEqual(false)

    editButton.simulate('click')
    expect(defaultProps.onEdit).toHaveBeenCalledWith(mockProduct, expect.any(Object))
  })

  it('can be removed', () => {
    const wrapper = mountWrapper(props)
    expect(defaultProps.onRemove).not.toHaveBeenCalled()

    const removeButton = wrapper.find('button[aria-label^="Remove"]')
    expect(removeButton.props().disabled).toEqual(false)

    removeButton.simulate('click')
    expect(defaultProps.onRemove).toHaveBeenCalledTimes(1)
  })

  it('can neither be saved nor cancelled', () => {
    const wrapper = mountWrapper(props)

    expect(wrapper.exists('button[aria-label^="Save"]')).toEqual(false)
    expect(wrapper.exists('button[aria-label^="Cancel"]')).toEqual(false)
  })
})

it('shows validation', () => {
  const wrapper = mountWrapper({ validated: 'error' })

  expect(wrapper.find(TextInput).prop('validated')).toEqual('error')
})

describe('when not editable', () => {
  const props = { isEditable: false }

  it('disables buttons', () => {
    const wrapper = mountWrapper(props)

    expect(wrapper.find(Button).everyWhere(b => b.props().isDisabled === true)).toEqual(true)
  })
})

describe('when being edited', () => {
  const props = { isBeingEdited: true }

  it('renders editable text input', () => {
    const wrapper = mountWrapper(props)

    expect(wrapper.find(InputGroupText).children().text()).toEqual(mockProduct.name)
    expect(wrapper.find(TextInput).props().readOnly).toEqual(false)
  })

  it('can be saved', () => {
    const wrapper = mountWrapper(props)
    expect(defaultProps.onSave).not.toHaveBeenCalled()

    const saveButton = wrapper.find('button[aria-label^="Save"]')
    expect(saveButton.props().disabled).toEqual(false)

    saveButton.simulate('click')
    expect(defaultProps.onSave).toHaveBeenCalledWith(expect.any(Object))
  })

  it('can be cancelled', () => {
    const wrapper = mountWrapper(props)
    expect(defaultProps.onCancel).not.toHaveBeenCalled()

    const cancelButton = wrapper.find('button[aria-label^="Cancel"]')
    expect(cancelButton.props().disabled).toEqual(false)

    cancelButton.simulate('click')
    expect(defaultProps.onCancel).toHaveBeenCalledTimes(1)
  })

  it('can neither be edited nor removed', () => {
    const wrapper = mountWrapper(props)

    expect(wrapper.exists('button[aria-label^="Edit"]')).toEqual(false)
    expect(wrapper.exists('button[aria-label^="Remove"]')).toEqual(false)
  })

  it('shows a spinner when being saved', () => {
    const wrapper = mountWrapper(props)
    expect(wrapper.find('button[aria-label^="Save"]').exists(Spinner)).toEqual(false)

    wrapper.setProps({ isEditLoading: true })
    expect(wrapper.find('button[aria-label^="Save"]').exists(Spinner)).toEqual(true)
  })
})
