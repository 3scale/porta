// @flow

import type { Feature, AdminSection } from 'Users/types'

const FEATURE_NAMES: { [feature: Feature]: string } = {
  portal: 'Create, read, update, and delete content & code of the <strong>developer portal</strong>',
  finance: 'Setup and manage <strong>customer billing</strong>',
  settings: 'Update <strong>feature settings</strong>',
  partners: 'Create, read, update and delete:',
  monitoring: 'Access & query <strong>analytics</strong> of:',
  plans: 'Create, read, update and delete:',
  policy_registry: 'Create, read, update and delete:'
}

const FEATURE_NAMES_DESCRIPTION_ITEMS: { [string]: Array<string> } = {
  partners: [
    'developer <strong>accounts</strong></span>',
    '<strong>applications</strong> of selected API Products'
  ],
  monitoring: ['all API BAckends', 'selected API Products'],
  plans: [
    '<strong>attribues, metrics, methods, and mapping rules of all existing API Backends</strong><br/>',
    '<strong>attribues, application plans, active docs, and integration</strong> of selected existing API Products'
  ],
  policy_registry: ['the APIcast <strong>policy chain and its policies</strong>']
}

const FEATURES_GRANTING_SERVICE_ACCESS = ['partners', 'monitoring', 'plans']

export function getFeatureName (feature: Feature): string {
  if (feature in FEATURE_NAMES) {
    return FEATURE_NAMES[feature]
  }

  throw new Error(`${feature} is not a known feature`)
}

export function getFeatureNameDescription (feature: Feature) {
  return FEATURE_NAMES_DESCRIPTION_ITEMS[feature]
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
