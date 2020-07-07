import React, { useState } from 'react'
import { useAuth } from 'auth'
import {
  Button,
  PageHeaderTools,
  PageHeaderToolsGroup,
  PageHeaderToolsItem,
  ButtonVariant,
  Dropdown,
  DropdownToggle,
  Avatar,
  KebabToggle,
  DropdownItem,
  DropdownGroup
} from '@patternfly/react-core'
import { useTranslation } from 'i18n/useTranslation'
import { CogIcon, HelpIcon } from '@patternfly/react-icons'
import avatar from 'assets/img_avatar.svg'

const AppHeaderTools: React.FunctionComponent = () => {
  const { t } = useTranslation('shared')
  const { setAuthToken } = useAuth()

  const [isKebabDropdownOpen, setIsKebabDropdownOpen] = useState(false)
  const [isDropdownOpen, setIsDropDownOpen] = useState(false)

  const kebabDropdownItems = [
    <DropdownItem key="settings">
      <CogIcon />
      {' Settings'}
    </DropdownItem>,
    <DropdownItem key="help">
      <HelpIcon />
      {' Help'}
    </DropdownItem>
  ]

  const userDropdownItems = [
    <DropdownGroup key="group user">
      <DropdownItem key="group user logout" onClick={() => setAuthToken(null)}>
        {t('buttons.logout')}
      </DropdownItem>
    </DropdownGroup>
  ]

  return (
    <PageHeaderTools>
      <PageHeaderToolsGroup visibility={{ default: 'hidden', lg: 'visible' }}>
        <PageHeaderToolsItem>
          <Button aria-label="Settings actions" variant={ButtonVariant.plain}>
            <CogIcon />
          </Button>
        </PageHeaderToolsItem>
        <PageHeaderToolsItem>
          <Button aria-label="Help actions" variant={ButtonVariant.plain}>
            <HelpIcon />
          </Button>
        </PageHeaderToolsItem>
      </PageHeaderToolsGroup>
      <PageHeaderToolsGroup>
        <PageHeaderToolsItem visibility={{
          default: 'visible',
          sm: 'visible',
          md: 'visible',
          lg: 'hidden',
          xl: 'hidden',
          '2xl': 'hidden'
        }}
        >
          <Dropdown
            isPlain
            position="right"
            onSelect={() => setIsKebabDropdownOpen(!isKebabDropdownOpen)}
            toggle={<KebabToggle onToggle={() => setIsKebabDropdownOpen(!isKebabDropdownOpen)} />}
            isOpen={isKebabDropdownOpen}
            dropdownItems={kebabDropdownItems}
          />
        </PageHeaderToolsItem>
        <PageHeaderToolsItem visibility={{
          default: 'hidden',
          sm: 'hidden',
          md: 'hidden',
          lg: 'visible',
          xl: 'visible',
          '2xl': 'visible'
        }}
        >
          <Dropdown
            isPlain
            position="right"
            onSelect={() => setIsDropDownOpen(!isDropdownOpen)}
            isOpen={isDropdownOpen}
            toggle={(
              <DropdownToggle onToggle={() => setIsDropDownOpen(!isDropdownOpen)}>
                User Name
              </DropdownToggle>
              )}
            dropdownItems={userDropdownItems}
          />
        </PageHeaderToolsItem>
      </PageHeaderToolsGroup>
      <Avatar src={avatar} alt="Avatar image" />
    </PageHeaderTools>
  )
}

export { AppHeaderTools }
