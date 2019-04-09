// @flow

import type { Feature, AdminSection } from 'Users/types'

const FEATURE_NAMES: { [feature: Feature]: string } = {
  portal: 'Developer Portal',
  finance: 'Billing',
  settings: 'Settings',
  partners: 'Developer Accounts -- Applications',
  monitoring: 'Analytics',
  plans: 'Integration & Application Plans',
  policy_registry: 'Policy Registry'
}

const FEATURES_GRANTING_SERVICE_ACCESS = ['partners', 'monitoring', 'plans']

export function getFeatureName (feature: Feature): string {
  if (feature in FEATURE_NAMES) {
    return FEATURE_NAMES[feature]
  }

  throw new Error(`${feature} is not a known feature`)
}

export function canFeatureSetServicePermissions (features: AdminSection | Array<AdminSection>): boolean {
  if (typeof features === 'string') {
    return FEATURES_GRANTING_SERVICE_ACCESS.includes(features)
  } else {
    return !!features.find(canFeatureSetServicePermissions)
  }
}

export function toggleElementInCollection<T> (el: T, collection: T[]): T[] {
  const i = collection.indexOf(el)
  return (i > -1)
    ? collection.filter((_, j) => j !== i)
    : [...collection, el]
}
