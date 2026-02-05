/**
 * @jest-environment-options {"url": "http://www.example.com?tab=metrics"}
 */

import { isActiveTab } from 'utilities/isActiveTab'

it('should tell tab is metrics from current URL', () => {
  expect(isActiveTab('metrics')).toEqual(true)
  expect(isActiveTab('methods')).toEqual(false)
})
