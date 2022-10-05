/* eslint-disable react/no-multi-comp */
import ReactHtmlParser from 'react-html-parser'
import {
  canFeatureSetServicePermissions,
  getFeatureName,
  getFeatureNameDescription
} from 'Users/utils'

import type { FunctionComponent } from 'react'
import type { AdminSection, Feature } from 'Users/types'

/**
 * Contains a set of Features that can be checked by the user.
 * @param {Feature[]}       features                - An array containing all available Features in the fieldset.
 * @param {AdminSection[]}  selectedSections        - An array containing all checked elements. Besides Features it can be the checkbox for 'all services enabled'.
 * @param {boolean}         areServicesVisible      - Whether or not the fieldset with all services is visible.
 * @param {function}        onAdminSectionSelected  - A callback function triggered when a feature is checked or unchecked.
 */
type Props = {
  features: Feature[],
  selectedSections?: AdminSection[],
  areServicesVisible?: boolean,
  onAdminSectionSelected: (arg1: AdminSection) => void
}

const FeaturesFieldset: React.FunctionComponent<Props> = ({
  features,
  selectedSections = [],
  areServicesVisible = false,
  onAdminSectionSelected
}) => {
  const featuresListClassName = `FeatureAccessList ${areServicesVisible ? '' : 'FeatureAccessList--noServicePermissionsGranted'}`
  const allServicesChecked = !selectedSections.includes('services')

  return (
    <fieldset>
      <legend className="label">This member user can:</legend>
      <ol className={featuresListClassName}>
        <input name="user[member_permission_ids][]" type="hidden" />
        {features.map(feature => (
          <FeatureCheckbox key={feature} checked={selectedSections.includes(feature)} value={feature} onChange={onAdminSectionSelected} />
        ))}
        {areServicesVisible && (
          <AllServicesCheckbox checked={allServicesChecked} onChange={onAdminSectionSelected} />
        )}
      </ol>
    </fieldset>
  )
}

/**
 * A list describing member permissions for each label.
 * @param {Array} descriptionItems - An array of strings containing the description of the label.
 */
const LabelDescriptionItems: FunctionComponent<{ descriptionItems: Array<string> }> = ({ descriptionItems }) => (
  <ul className="FeatureAccessList-item--labelDescription">
    {descriptionItems.map(item => <li key={item}>{ReactHtmlParser(item)}</li>)}
  </ul>
)

/**
 * A checkbox representing a Feature the user will have access to.
 * @param {Feature}   value     - The feature this checkbox represents.
 * @param {boolean}   checked   - Whether or not this checkbox is selected.
 * @param {Function}  onChange  - A callback function triggered when its value changes.
 */
type FeatureCheckboxProps = {
  value: Feature,
  checked?: boolean,
  onChange: (arg1: Feature) => void
}

const FeatureCheckbox: React.FunctionComponent<FeatureCheckboxProps> = ({
  value,
  checked,
  onChange
}) => {
  const featuresListItemClassName = `FeatureAccessList-item FeatureAccessList-item--${value} ${checked ? 'is-checked' : 'is-unchecked'}`
  const featureCheckboxClassName = `user_member_permission_ids ${canFeatureSetServicePermissions(value) ? 'user_member_permission_ids--service' : ''}`
  const descriptionItems = getFeatureNameDescription(value)

  return (
    <li className={featuresListItemClassName}>
      <label htmlFor={`user_member_permission_ids_${value}`}>
        <input
          checked={checked}
          className={featureCheckboxClassName}
          id={`user_member_permission_ids_${value}`}
          name="user[member_permission_ids][]"
          type="checkbox"
          value={value}
          onChange={() => onChange(value)}
        />
        { ReactHtmlParser(getFeatureName(value)) }
        { descriptionItems && <LabelDescriptionItems descriptionItems={descriptionItems} /> }
      </label>
    </li>
  )
}

/**
 * A checkbox to select all services or to let them be selected one by one.
 * @param {boolean}   checked   - Whether the checkbox is selected.
 * @param {Function}  onChange  - A callback function triggered when the checkbox value changes.
 */
type AllServicesCheckboxProps = {
  checked?: boolean,
  onChange: (arg1: 'services') => void
}

const AllServicesCheckbox: React.FunctionComponent<AllServicesCheckboxProps> = ({
  checked,
  onChange
}) => {
  // if service feature access checkbox is unchecked
  // at least blank service_ids array has to be sent
  const blankServiceIdsInput = checked ? null : <input name="user[member_permission_service_ids][]" type="hidden" />

  return (
    <li className="FeatureAccessList-item FeatureAccessList-item--services FeatureAccessList--services">
      <label htmlFor="user_member_permission_ids_services">
        <input
          checked={checked}
          className="user_member_permission_ids"
          id="user_member_permission_ids_services"
          name="user[member_permission_service_ids]"
          type="checkbox"
          value=""
          onChange={() => onChange('services')}
        />
        All current and future existing API products
      </label>
      {blankServiceIdsInput}
    </li>
  )
}

export { FeaturesFieldset, Props }
