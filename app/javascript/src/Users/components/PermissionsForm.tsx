import { useState } from 'react'

import { RoleRadioGroup } from 'Users/components/RoleRadioGroup'
import { FeaturesFieldset } from 'Users/components/FeaturesFieldset'
import { ServicesFieldset } from 'Users/components/ServicesFieldset'
import { canFeatureSetServicePermissions, toggleElementInCollection } from 'Users/utils'
import { createReactWrapper } from 'utilities/createReactWrapper'

import type { FunctionComponent } from 'react'
import type { AdminSection, Feature, Role } from 'Users/types'
import type { Api } from 'Types'

interface State {
  role?: Role;
  // eslint-disable-next-line @typescript-eslint/naming-convention -- Comes from rails like that
  admin_sections?: AdminSection[];
  // eslint-disable-next-line @typescript-eslint/naming-convention -- Comes from rails like that
  member_permission_service_ids?: number[];
}

interface Props {
  initialState?: State;
  features: Feature[];
  services: Api[];
}

const emptyObject = {} as never

/**
 * Represents the user's permissions form, also known as Administrative. It handles the user's Role and their access to different Services.
 * @param {State}  initialState  - The values of the user's current settings.
 * @param {Feature[]}     features      - The set of features or sections the user can have access to.
 * @param {Api[]}         services      - The list of services or APIs the user can have access to.
 */
const PermissionsForm: FunctionComponent<Props> = ({
  initialState = emptyObject,
  features,
  services
}) => {
  const [role, setRole] = useState(initialState.role ?? 'admin')
  const [selectedSections, setSelectedSections] = useState(initialState.admin_sections ?? [])
  const [selectedServicesIds, setSelectedServicesIds] = useState(initialState.member_permission_service_ids ?? [])

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
    <fieldset className="inputs" name="Administrative">
      <legend>Administrative</legend>
      <ol>
        <RoleRadioGroup
          selectedRole={role}
          onRoleChanged={setRole}
        />

        {role === 'member' && (
          <li className="radio optional" id="user_member_permissions_input">
            <FeaturesFieldset
              areServicesVisible={areServicesVisible}
              features={features}
              selectedSections={selectedSections}
              onAdminSectionSelected={onAdminSectionSelected}
            />

            {areServicesVisible && (
              <ServicesFieldset
                selectedSections={selectedSections}
                selectedServicesIds={selectedServicesIds}
                services={services}
                onServiceSelected={onServiceSelected}
              />
            )}
          </li>
        )}
      </ol>
    </fieldset>
  )
}

// eslint-disable-next-line react/jsx-props-no-spreading
const PermissionsFormWrapper = (props: Props, containerId: string): void => { createReactWrapper(<PermissionsForm {...props} />, containerId) }

export type { Props }
export { PermissionsForm, PermissionsFormWrapper }
