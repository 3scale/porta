import { canFeatureSetServicePermissions, toggleElementInCollection, getFeatureName } from 'Users/utils'

// Features
const FEATURES = ['portal', 'finance', 'settings', 'partners', 'monitoring', 'plans', 'policy_registry']

describe('canFeatureSetServicePermissions', () => {
  it('should return whether or not service permissions are available', () => {
    expect(canFeatureSetServicePermissions('portal')).toBe(false)
    expect(canFeatureSetServicePermissions('finance')).toBe(false)
    expect(canFeatureSetServicePermissions('settings')).toBe(false)
    expect(canFeatureSetServicePermissions('policy_registry')).toBe(false)

    expect(canFeatureSetServicePermissions('partners')).toBe(true)
    expect(canFeatureSetServicePermissions('monitoring')).toBe(true)
    expect(canFeatureSetServicePermissions('plans')).toBe(true)

    expect(canFeatureSetServicePermissions(['portal', 'finance', 'settings'])).toBe(false)

    expect(canFeatureSetServicePermissions(['portal', 'partners'])).toBe(true)
    expect(canFeatureSetServicePermissions(['plans', 'partners'])).toBe(true)
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
    FEATURES.forEach(feature => expect(typeof getFeatureName(feature)).toBe('string'))
  })
})
