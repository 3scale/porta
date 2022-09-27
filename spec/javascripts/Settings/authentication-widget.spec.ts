import { element } from 'prop-types'
import * as AuthenticationWidget from 'Settings/authentication-widget'

it('#toggle should call a function with an element', () => {
  const fn = jest.fn((el: HTMLInputElement) => el)
  const fnFactory = jest.fn(() => fn)

  const element = document.createElement('input')

  AuthenticationWidget.toggle(fnFactory)(true)(element)
  AuthenticationWidget.toggle(fnFactory)(false)(element)

  expect(fnFactory).nthCalledWith(1, true)
  expect(fnFactory).nthCalledWith(2, false)
  expect(fn).toHaveBeenCalledWith(element)
})

it('#toggleAttrInSetting should set an element\'s attribute on and off', () => {
  const element = document.createElement('input')

  AuthenticationWidget.toggleAttrInSetting('checked')(true)(element)
  expect(element.getAttribute('checked')).toEqual('checked')

  AuthenticationWidget.toggleAttrInSetting('checked')(false)(element)
  expect(element.getAttribute('checked')).toEqual(null)
})

it('#toggleHiddenClass should add and remove css class .hidden from an element', () => {
  const element = document.createElement('input')

  AuthenticationWidget.toggleHiddenClass(true)(element)
  expect(element.classList.contains('hidden')).toEqual(true)

  AuthenticationWidget.toggleHiddenClass(false)(element)
  expect(element.classList.contains('hidden')).toEqual(false)
})

it('#toggleDisabled should set an element\'s "disabled" attribute on and off', () => {
  const element = document.createElement('input')

  AuthenticationWidget.toggleDisabled(true)(element)
  expect(element.getAttribute('disabled')).toEqual('disabled')

  AuthenticationWidget.toggleDisabled(false)(element)
  expect(element.getAttribute('disabled')).toEqual(null)
})

it('#toggleReadOnly should set an element\'s "readonly" attribute on and off', () => {
  const element = document.createElement('input')

  AuthenticationWidget.toggleReadOnly(true)(element)
  expect(element.getAttribute('readonly')).toEqual('readonly')

  AuthenticationWidget.toggleReadOnly(false)(element)
  expect(element.getAttribute('readonly')).toEqual(null)
})

it('#setValue should set an element\'s value', () => {
  const element = document.createElement('input')
  const value = 'foo'

  AuthenticationWidget.setValue(element, value)
  expect(element.value).toEqual(value)
})

it('#setInputValue should set an input\'s value unless readonly', () => {
  const element = document.createElement('input')

  let editable = true
  AuthenticationWidget.setInputValue('bar')(editable)(element)
  expect(element.value).toEqual('bar')

  editable = false
  AuthenticationWidget.setInputValue('foo')(editable)(element)
  expect(element.value).toEqual('bar')
})

it.todo('#initialize should toggle hidden, disabled and readonly the appropriate elements')
