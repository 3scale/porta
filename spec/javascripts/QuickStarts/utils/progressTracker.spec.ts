import { getActiveQuickstart } from 'QuickStarts/utils/progressTracker'

it('should return null when there is no active quickstart', () => {
  localStorage.removeItem('quickstartId')
  expect(getActiveQuickstart()).toBe(null)

  localStorage.quickstartId = '""'
  expect(getActiveQuickstart()).toBe(null)

  localStorage.quickstartId = '"creating-a-method-quick-start"'
  expect(getActiveQuickstart()).not.toBe(null)
})
