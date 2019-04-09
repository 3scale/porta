// @flow

import React from 'react'

import { getFeatureName, canFeatureSetServicePermissions } from 'Users/utils'

import type { Feature, AdminSection } from 'Users/types'

type Props = {
  features: Feature[],
  selectedSections?: AdminSection[],
  areServicesVisible?: boolean,
  onAdminSectionSelected: AdminSection => void
}

/**
 * Contains a set of Features that can be checked by the user.
 * @param {Feature[]}       features                - An array containing all available Features in the fieldset.
 * @param {AdminSection[]}  selectedSections        - An array containing all checked elements. Besides Features it can be the checkbox for 'all services enabled'.
 * @param {boolean}         areServicesVisible      - Whether or not the fieldset with all services is visible.
 * @param {function}        onAdminSectionSelected  - A callback function triggered when a feature is checked or unchecked.
 */
const FeaturesFieldset = ({ features, selectedSections = [], areServicesVisible = false, onAdminSectionSelected }: Props) => {
  const featuresListClassName = `FeatureAccessList ${areServicesVisible ? '' : 'FeatureAccessList--noServicePermissionsGranted'}`
  const allServicesChecked = !selectedSections.includes('services')

  return (
    <fieldset>
      <legend className='label'>This user can access</legend>
      <ol className={featuresListClassName}>
        <input type='hidden' name='user[member_permission_ids][]' />
        {features.map(feature =>
          <FeatureCheckbox key={feature} value={feature} checked={selectedSections.includes(feature)} onChange={onAdminSectionSelected} />
        )}
        {areServicesVisible &&
          <AllServicesCheckbox checked={allServicesChecked} onChange={onAdminSectionSelected} />
        }
      </ol>
    </fieldset>
  )
}

/**
 * A checkbox representing a Feature the user will have access to.
 * @param {Feature}   value     - The feature this checkbox represents.
 * @param {boolean}   checked   - Whether or not this checkbox is selected.
 * @param {Function}  onChange  - A callback function triggered when its value changes.
 */
const FeatureCheckbox = ({ value, checked, onChange }: {
  value: Feature,
  checked?: boolean,
  onChange: Feature => void
}) => {
  const featuresListItemClassName = `FeatureAccessList-item FeatureAccessList-item--${value} ${checked ? 'is-checked' : 'is-unchecked'}`
  const featureCheckboxClassName = `user_member_permission_ids ${canFeatureSetServicePermissions(value) ? 'user_member_permission_ids--service' : ''}`

  return (
    <li className={featuresListItemClassName}>
      <label htmlFor={`user_member_permission_ids_${value}`}>
        <input
          className={featureCheckboxClassName}
          name='user[member_permission_ids][]'
          id={`user_member_permission_ids_${value}`}
          value={value}
          type='checkbox'
          checked={checked}
          onChange={() => onChange(value)}
        />
        {getFeatureName(value)}
      </label>
    </li>
  )
}

/**
 * A checkbox to select all services or to let them be selected one by one.
 * @param {boolean}   checked   - Whether the checkbox is selected.
 * @param {Function}  onChange  - A callback function triggered when the checkbox value changes.
 */
const AllServicesCheckbox = ({ checked, onChange }: {
  checked?: boolean,
  onChange: 'services' => void
}) => {
  // if service feature access checkbox is unchecked
  // at least blank service_ids array has to be sent
  const blankServiceIdsInput = checked ? null : <input type='hidden' name='user[member_permission_service_ids][]' />

  return (
    <li className='FeatureAccessList-item FeatureAccessList-item--services FeatureAccessList--services'>
      <label htmlFor='user_member_permission_ids_services'>
        <input
          className='user_member_permission_ids'
          name='user[member_permission_service_ids]'
          id='user_member_permission_ids_services'
          value=''
          type='checkbox'
          checked={checked}
          onChange={() => onChange('services')}
        />
        All current and future APIs
      </label>
      {blankServiceIdsInput}
    </li>
  )
}

export { FeaturesFieldset }
