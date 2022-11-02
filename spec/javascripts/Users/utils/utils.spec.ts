import { canFeatureSetServicePermissions, getFeatureName, toggleElementInCollection } from 'Users/utils'

import type { Feature } from 'Users/types'

// Features
const FEATURES: Feature[] = ['portal', 'finance', 'settings', 'partners', 'monitoring', 'plans', 'policy_registry']

describe('canFeatureSetServicePermissions', () => {
  it('should return whether or not service permissions are available', () => {
    expect(canFeatureSetServicePermissions('portal')).toEqual(false)
    expect(canFeatureSetServicePermissions('finance')).toEqual(false)
    expect(canFeatureSetServicePermissions('settings')).toEqual(false)
    expect(canFeatureSetServicePermissions('policy_registry')).toEqual(false)

    expect(canFeatureSetServicePermissions('partners')).toEqual(true)
    expect(canFeatureSetServicePermissions('monitoring')).toEqual(true)
    expect(canFeatureSetServicePermissions('plans')).toEqual(true)

    expect(canFeatureSetServicePermissions(['portal', 'finance', 'settings'])).toEqual(false)

    expect(canFeatureSetServicePermissions(['portal', 'partners'])).toEqual(true)
    expect(canFeatureSetServicePermissions(['plans', 'partners'])).toEqual(true)
  })
})

describe('toggleElementInCollection', () => {
  it('should add element if not present in collection', () => {
    const el = 'c'
    const collection = ['a', 'b']

    expect(toggleElementInCollection(el, collection)).toContain(el)
  })

  it('should remove element if present in collection', () => {
    const el = 'c'
    const collection = ['a', 'b', 'c']

    expect(toggleElementInCollection(el, collection)).not.toContain(el)
  })

  it('should return a copy of the original collection', () => {
    const el = 'c'
    const collection = ['a', 'b', 'c']

    expect(toggleElementInCollection(el, collection)).not.toBe(collection)
    expect(collection).toEqual(['a', 'b', 'c'])
  })
})

describe('getFeatureName', () => {
  it('should return a descriptive name for a provided Feature', () => {
    FEATURES.forEach(feature => { expect(typeof getFeatureName(feature)).toBe('string') })
  })
})
