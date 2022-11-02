import { moveState, recoverState, toggle, toggleState } from 'utilities/toggle'

let icon: HTMLElement
let article: HTMLElement

beforeEach(() => {
  localStorage.clear()
  icon = document.createElement('i')
  article = document.createElement('div')
  article.className = 'u-closed'
  article.setAttribute('id', 'article')
})

it('attaches the click event handler to the icon element', () => {
  expect(article.classList.contains('u-closed')).toEqual(true)
  toggle(article.id, article.classList, icon, 'u-closed')
  icon.click()
  expect(article.classList.contains('u-closed')).toEqual(false)
})

it('returns function which removes the click event handler', () => {
  expect(article.classList.contains('u-closed')).toEqual(true)
  const returnValue = toggle(article.id, article.classList, icon, 'u-closed')
  returnValue()
  icon.click()
  expect(article.classList.contains('u-closed')).toEqual(true)
})

it('toggles class for the element', () => {
  expect(article.classList.contains('u-closed')).toEqual(true)
  toggleState(article.id, article.classList, 'u-closed')
  expect(article.classList.contains('u-closed')).toEqual(false)
})

it('recovers class from the storage', () => {
  expect(article.classList.contains('u-closed')).toEqual(true)
  toggleState(article.id, article.classList, 'u-closed')
  expect(article.classList.contains('u-closed')).toEqual(false)
  article.className = 'u-closed'
  expect(article.classList.contains('u-closed')).toEqual(true)
  recoverState(article.id, article.classList, 'u-closed')
  expect(article.classList.contains('u-closed')).toEqual(false)
})

it('allows for renaming the class', () => {
  expect(article.classList.contains('u-closed')).toEqual(true)
  toggleState(article.id, article.classList, 'u-closed')
  expect(article.classList.contains('u-closed')).toEqual(false)
  article.className = 'is-closed'
  moveState(article.id, 'u-closed', 'is-closed')
  recoverState(article.id, article.classList, 'is-closed')
  expect(article.classList.contains('is-closed')).toEqual(false)
})

it('fires window resize event on click', () => {
  const onresize = jest.fn()
  global.onresize = onresize
  toggle(article.id, article.classList, icon, 'toggle')

  icon.click()

  expect(onresize).toHaveBeenCalled()
})
