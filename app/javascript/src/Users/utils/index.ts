/* eslint-disable @typescript-eslint/naming-convention */
import type { AdminSection, Feature } from 'Users/types'

const FEATURE_NAMES: Partial<Record<Feature, string>> = {
  portal: 'Create, read, update, and delete content & code of the <strong>developer portal</strong>',
  finance: 'Setup and manage <strong>customer billing</strong>',
  settings: 'Update <strong>settings pages</strong>',
  partners: 'Create, read, update and delete:',
  monitoring: 'Access & query <strong>analytics</strong> of:',
  plans: 'Create, read, update and delete:',
  policy_registry: 'Create, read, update and delete:'
} as const

const FEATURE_NAMES_DESCRIPTION_ITEMS: Record<Feature, string[] | undefined> = {
  portal: undefined,
  finance: undefined,
  settings: undefined,
  partners: [
    'developer <strong>accounts</strong></span>',
    '<strong>applications</strong> of <em>selected API products</em>'
  ],
  monitoring: ['all API backends', '<em>selected API products</em>'],
  plans: [
    '<strong>attributes, metrics, methods, and mapping rules</strong><br/> of all existing API backends<br/>',
    '<strong>attributes, application plans, active docs, and integration</strong> of<br/> <em>selected API products</em>'
  ],
  policy_registry: ['the APIcast <strong>policy chain and its policies</strong>']
}

const FEATURES_GRANTING_SERVICE_ACCESS = ['partners', 'monitoring', 'plans']

export function getFeatureName (feature: Feature): string {
  if (feature in FEATURE_NAMES) {
    // eslint-disable-next-line @typescript-eslint/no-non-null-assertion -- FIXME: we assume feature is a Feature, either remove this check or type it as string instead
    return FEATURE_NAMES[feature]!
  }

  throw new Error(`${feature} is not a known feature`)
}

export function getFeatureNameDescription (feature: Feature): string[] | undefined {
  return FEATURE_NAMES_DESCRIPTION_ITEMS[feature]
}

export function canFeatureSetServicePermissions (features: AdminSection | AdminSection[]): boolean {
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
