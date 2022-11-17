import { isActiveTab } from 'utilities/isActiveTab'
import { mockLocation } from 'utilities/test-utils'

it('should work', () => {
  mockLocation('http://www.example.com?tab=metrics')
  expect(isActiveTab('metrics')).toEqual(true)

  expect(isActiveTab('methods')).toEqual(false)
})
