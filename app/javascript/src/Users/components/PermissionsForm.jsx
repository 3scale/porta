// @flow

import 'raf/polyfill'
import 'core-js/es6/map'
import 'core-js/es6/set'

import React, { useState } from 'react'

import { RoleRadioGroup } from 'Users/components/RoleRadioGroup'
import { FeaturesFieldset } from 'Users/components/FeaturesFieldset'
import { ServicesFieldset } from 'Users/components/ServicesFieldset'

import { canFeatureSetServicePermissions, toggleElementInCollection } from 'Users/utils'

import type { Role, Feature, AdminSection } from 'Users/types'
import type { Service } from 'Types'

type Props = {
  initialState?: {
    role?: Role,
    admin_sections?: AdminSection[],
    member_permission_service_ids?: number[]
  },
  features: Feature[],
  services: Service[]
}

/**
 * Represents the user's permissions form, also known as Administrative. It handles the user's Role and their access to different Services.
 * @param {InitialState}  initialState  - The values of the user's current settings.
 * @param {Feature[]}     features      - The set of features or sections the user can have access to.
 * @param {Service[]}     services      - The list of services or APIs the user can have access to.
 */
const PermissionsForm = ({ initialState = {}, features, services }: Props) => {
  const [role, setRole] = useState(initialState.role || 'admin')
  const [selectedSections, setSelectedSections] = useState(initialState.admin_sections || [])
  const [selectedServicesIds, setSelectedServicesIds] = useState(initialState.member_permission_service_ids || [])

  const onAdminSectionSelected = (section: AdminSection) => {
    const newSections = toggleElementInCollection(section, selectedSections)
    setSelectedSections(newSections)
  }

  const onServiceSelected = (id: number) => {
    const newServices = toggleElementInCollection(id, selectedServicesIds)
    setSelectedServicesIds(newServices)
  }

  const areServicesVisible = canFeatureSetServicePermissions(selectedSections)

  return (
    <fieldset className='inputs' name='Administrative'>
      <legend>Administrative</legend>
      <ol>
        <RoleRadioGroup
          selectedRole={role}
          onRoleChanged={setRole}
        />

        {role === 'member' && (
          <li className='radio optional' id='user_member_permissions_input'>
            <FeaturesFieldset
              features={features}
              selectedSections={selectedSections}
              areServicesVisible={areServicesVisible}
              onAdminSectionSelected={onAdminSectionSelected}
            />

            {areServicesVisible && (
              <ServicesFieldset
                services={services}
                selectedSections={selectedSections}
                selectedServicesIds={selectedServicesIds}
                onServiceSelected={onServiceSelected}
              />)}
          </li>
        )}
      </ol>
    </fieldset>
  )
}

export { PermissionsForm }
