import { mount, shallow } from 'enzyme'
import { act } from 'react-dom/test-utils'
import { TableBody, Tr } from '@patternfly/react-table'

import { CustomSupportEmails } from 'SiteEmails/components/CustomSupportEmails'
import { Exception } from 'SiteEmails/components/Exception'
import { TableModal } from 'Common/components/TableModal'
import { fetchPaginated as fetchMock, patch as patchMock } from 'utilities/ajax'
import { toast as toastMock } from 'utilities/toast'
import { waitForPromises } from 'utilities/test-utils'

import type { ReactWrapper } from 'enzyme'
import type { Product } from 'SiteEmails/types'
import type { Props } from 'SiteEmails/components/CustomSupportEmails'

import { exceptionFactory, productFactory } from '../../factories'

jest.mock('utilities/ajax')
jest.mock('utilities/toast')

const fetchPaginated = fetchMock as jest.Mock
const patch = patchMock as jest.Mock
const toast = toastMock as jest.Mock

const defaultProps = {
  buttonLabel: 'Add a custom support email',
  productsPath: '/products',
  products: [],
  exceptions: [],
  removeConfirmation: 'Are you sure?'
}

const findAddButton = (wrapper: ReactWrapper<unknown>) => wrapper.findWhere(n => n.type() === 'button' && n.text() === defaultProps.buttonLabel)

const props = (custom: Partial<Props> = {}) => ({
  ...defaultProps,
  productsCount: custom.products ? custom.products.length : 0,
  ...custom
})

it('renders itself', () => {
  const wrapper = shallow(<CustomSupportEmails {...props()} />)
  expect(wrapper.exists()).toEqual(true)
})

describe('when there are products without custom support email', () => {
  let products: Product[]

  beforeEach(() => {
    products = productFactory(5)
  })

  it('opens and closes the select product modal', () => {
    const wrapper = mount(<CustomSupportEmails {...props({ products })} />)
    expect(wrapper.find(TableModal).props().isOpen).toBe(false)

    findAddButton(wrapper).simulate('click')
    wrapper.update()

    expect(wrapper.find(TableModal).props().isOpen).toBe(true)
  })

  it('disables button when adding a new exception', () => {
    const product = products[0]
    const wrapper = mount(<CustomSupportEmails {...props({ products })} />)

    expect(findAddButton(wrapper).prop('disabled')).toBe(false)

    act(() => { wrapper.find(TableModal).props().onSelect(product) })
    wrapper.update()

    expect(findAddButton(wrapper).prop('disabled')).toBe(true)
  })

  it('adds new exception when product is selected from modal', () => {
    const product = products[0]
    const exception = exceptionFactory()
    const wrapper = mount(<CustomSupportEmails {...props({ products: [product], exceptions: [exception] })} />)

    const modal = wrapper.find(TableModal)

    let exceptionsList = wrapper.find(Exception)
    expect(exceptionsList).toHaveLength(1)
    expect(exceptionsList.last().props().product).toEqual(exception)
    expect(exceptionsList.last().props().isBeingEdited).toBe(false)

    act(() => { modal.props().onSelect(product) })
    wrapper.update()

    exceptionsList = wrapper.find(Exception)
    expect(exceptionsList).toHaveLength(2)
    expect(exceptionsList.last().props().product).toEqual(product)
    expect(exceptionsList.last().props().isBeingEdited).toBe(true)
  })

  it('can cancel adding a new exception', async () => {
    const product = products[0]

    const wrapper = mount(<CustomSupportEmails {...props({ products })} />)
    expect(wrapper.find(Exception)).toHaveLength(0)

    act(() => { wrapper.find(TableModal).props().onSelect(product) })
    wrapper.update()

    const { isBeingEdited: isBeingEditedAfter, onCancel } = wrapper.find(Exception).first().props()
    expect(isBeingEditedAfter).toEqual(true)

    // @ts-expect-error No need to pass input when cancelling, actually
    act(() => { onCancel({ current: undefined }) })
    await waitForPromises(wrapper)

    expect(patch).not.toHaveBeenCalled()
    expect(toast).not.toHaveBeenCalled()
    expect(wrapper.find(Exception)).toHaveLength(0)
  })

  it('should be able to search once per query', async () => {
    fetchPaginated.mockResolvedValue({ items: productFactory(1), newCount: 1 })
    const query = 'test'

    const wrapper = mount(<CustomSupportEmails {...props({ products })} />)
    findAddButton(wrapper).simulate('click')

    act(() => { wrapper.find(TableModal).props().onSearch(query) })
    await waitForPromises(wrapper)

    expect(fetchPaginated).toHaveBeenCalledTimes(1)
    expect(fetchPaginated).toHaveBeenLastCalledWith(defaultProps.productsPath, {
      compact: 'true',
      page: 1,
      perPage: 5,
      query,
      without_support_emails: ''
    })

    act(() => { wrapper.find(TableModal).props().onSearch(query) })
    await waitForPromises(wrapper)
    expect(fetchPaginated).toHaveBeenCalledTimes(1)

    act(() => { wrapper.find(TableModal).props().onSearch('') })
    await waitForPromises(wrapper)
    expect(fetchPaginated).toHaveBeenCalledTimes(2)
  })

  it('should fetch items to fill empty pages', async () => {
    const lastPageItems = productFactory(3)
    fetchPaginated.mockResolvedValue({ items: lastPageItems })

    const wrapper = mount(<CustomSupportEmails {...props({ products, productsCount: 20 })} />)
    findAddButton(wrapper).simulate('click')
    expect(wrapper.find(TableBody).find(Tr)).toHaveLength(5)

    act(() => { wrapper.find(TableModal).props().setPage(4) })
    await waitForPromises(wrapper)

    expect(fetchPaginated).toHaveBeenCalledTimes(1)
    expect(fetchPaginated).toHaveBeenLastCalledWith(defaultProps.productsPath, {
      compact: 'true',
      page: 4,
      perPage: 5,
      without_support_emails: ''
    })
    expect(wrapper.find(TableBody).find(Tr)).toHaveLength(lastPageItems.length)
  })
})

describe('when there are products with custom support emails', () => {
  let exceptions: Product[]
  let products: Product[]

  beforeEach(() => {
    exceptions = exceptionFactory(3)
    products = productFactory(3)
  })

  it('renders a list of exceptions', () => {
    const wrapper = mount(<CustomSupportEmails {...props({ exceptions })} />)

    const exceptionElements = wrapper.find(Exception)
    expect(exceptionElements).toHaveLength(exceptions.length)
    expect(exceptions.every((product, i) => exceptionElements.at(i).props().product === product)).toEqual(true)
  })

  it('disables add button when editting one', () => {
    const exception = exceptions[0]
    const wrapper = mount(<CustomSupportEmails {...props({ exceptions, products })} />)

    expect(findAddButton(wrapper).prop('disabled')).toBe(false)

    const el = wrapper.find(Exception).first()
    act(() => { el.props().onEdit(exception, { current: null }) })
    wrapper.update()

    expect(findAddButton(wrapper).prop('disabled')).toBe(true)
  })

  it('validates email format before saving', () => {
    const exception = exceptions[0]
    const input = { checkValidity: jest.fn(() => false), reportValidity: jest.fn(), focus: jest.fn() } as unknown as HTMLInputElement

    const wrapper = mount(<CustomSupportEmails {...props({ exceptions })} />)

    act(() => { wrapper.find(Exception).first().props().onEdit(exception, { current: input }) })
    wrapper.update()

    act(() => { wrapper.find(Exception).first().props().onSave({ current: input }) })
    wrapper.update()

    expect(input.checkValidity).toHaveBeenCalled()
    expect(input.reportValidity).toHaveBeenCalled()
    expect(patch).not.toHaveBeenCalled()
  })

  it('can edit the email when it is valid', async () => {
    const message = 'Product was updated'
    patch.mockResolvedValueOnce({ success: true, message })

    const newEmail = 'new@email.com'
    const exception = exceptions[0]
    const input = { value: newEmail, checkValidity: () => true, focus: jest.fn() } as unknown as HTMLInputElement

    const wrapper = mount(<CustomSupportEmails {...props({ exceptions })} />)
    const { isBeingEdited: isBeingEditedBefore, onEdit } = wrapper.find(Exception).first().props()

    expect(isBeingEditedBefore).toEqual(false)
    act(() => { onEdit(exception, { current: input }) })
    wrapper.update()

    expect(input.focus).toHaveBeenCalledTimes(1)

    const { isBeingEdited: isBeingEditedAfter, onSave } = wrapper.find(Exception).first().props()
    expect(isBeingEditedAfter).toEqual(true)

    act(() => { onSave({ current: input }) })
    await waitForPromises(wrapper)

    expect(patch).toHaveBeenCalledWith(`/apiconfig/services/${exception.id}`, {
      service: { support_email: newEmail }
    })
    expect(toast).toHaveBeenCalledTimes(1)
    expect(toast).toHaveBeenCalledWith(message, 'success')
    expect(wrapper.find(Exception).first().props().isBeingEdited).toEqual(false)
  })

  it('can edit one email at a time', () => {
    const wrapper = mount(<CustomSupportEmails {...props({ exceptions })} />)

    expect(wrapper.find(Exception).everyWhere(n => n.props().isEditable)).toEqual(true)

    act(() => { wrapper.find(Exception).find('button[aria-label^="Edit"]').first().simulate('click') })
    wrapper.update()

    const exceptionsAfter = wrapper.find(Exception)
    expect(exceptionsAfter.filterWhere(n => n.props().isEditable)).toHaveLength(0)
    expect(exceptionsAfter.filterWhere(n => n.props().isBeingEdited)).toHaveLength(1)
  })

  it('shows an error when save fails', async () => {
    const message = 'Product could not be updated'
    patch.mockResolvedValueOnce({ success: false, message })

    const exception = exceptions[0]
    const input = { checkValidity: () => true, focus: jest.fn() } as unknown as HTMLInputElement

    const wrapper = mount(<CustomSupportEmails {...props({ exceptions })} />)
    const { isBeingEdited: isBeingEditedBefore, onEdit } = wrapper.find(Exception).first().props()
    expect(isBeingEditedBefore).toEqual(false)

    act(() => { onEdit(exception, { current: input }) })
    wrapper.update()

    const { isBeingEdited: isBeingEditedAfter, onSave } = wrapper.find(Exception).first().props()
    expect(isBeingEditedAfter).toEqual(true)

    act(() => { onSave({ current: input }) })
    await waitForPromises(wrapper)

    expect(patch).toHaveBeenCalledTimes(1)
    expect(toast).toHaveBeenCalledTimes(1)
    expect(toast).toHaveBeenCalledWith(message, 'danger')
    expect(wrapper.find(Exception).first().props().isBeingEdited).toEqual(true)
  })

  it('can remove a custom email after confirmation', async () => {
    const message = 'Product could not be removed'
    patch.mockResolvedValueOnce({ success: false, message })
    window.confirm = jest.fn().mockReturnValueOnce(true)
    const exception = exceptions[0]

    const wrapper = mount(<CustomSupportEmails {...props({ exceptions })} />)

    act(() => { wrapper.find(Exception).find('[aria-label^="Remove"]').first().simulate('click') })
    await waitForPromises(wrapper)

    expect(patch).toHaveBeenCalledWith(`/apiconfig/services/${exception.id}`, {
      service: { support_email: null }
    })
    expect(toast).toHaveBeenCalledWith(message, 'danger')
  })

  it('can cancel editting a custom email', async () => {
    const newEmail = 'something different'
    const exception = exceptions[0]
    const input = { value: newEmail, focus: jest.fn() } as unknown as HTMLInputElement

    const wrapper = mount(<CustomSupportEmails {...props({ exceptions })} />)
    const { isBeingEdited: isBeingEditedBefore, onEdit } = wrapper.find(Exception).first().props()

    expect(isBeingEditedBefore).toEqual(false)
    act(() => { onEdit(exception, { current: input }) })
    wrapper.update()

    const { isBeingEdited: isBeingEditedAfter, onCancel } = wrapper.find(Exception).first().props()
    expect(isBeingEditedAfter).toEqual(true)

    act(() => { onCancel({ current: input }) })
    await waitForPromises(wrapper)

    expect(patch).not.toHaveBeenCalled()
    expect(toast).not.toHaveBeenCalled()
    expect(input.value).not.toEqual(newEmail)
    expect(wrapper.find(Exception).first().props().isBeingEdited).toEqual(false)
  })

  it('does not remove the custom email before confirming', async () => {
    window.confirm = jest.fn()

    const wrapper = mount(<CustomSupportEmails {...props({ exceptions })} />)

    act(() => { wrapper.find(Exception).find('[aria-label^="Remove"]').first().simulate('click') })
    await waitForPromises(wrapper)

    expect(window.confirm).toHaveBeenCalledWith(defaultProps.removeConfirmation)
    expect(patch).not.toHaveBeenCalled()
  })

  it('does not remove the custom email if confirmation is cancelled', async () => {
    window.confirm = jest.fn().mockReturnValue(false)

    const wrapper = mount(<CustomSupportEmails {...props({ exceptions })} />)

    act(() => { wrapper.find(Exception).find('[aria-label^="Remove"]').first().simulate('click') })
    await waitForPromises(wrapper)

    expect(window.confirm).toHaveBeenCalledWith(defaultProps.removeConfirmation)
    expect(patch).not.toHaveBeenCalled()
  })
})
