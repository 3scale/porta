import { isActiveTab } from 'utilities/isActiveTab'

import { mockLocation } from 'utilities/test-utils'

it('should work', () => {
  mockLocation('http://www.example.com?tab=metrics')
  expect(isActiveTab('metrics')).toBe(true)

  expect(isActiveTab('metric')).toBe(false)
})
