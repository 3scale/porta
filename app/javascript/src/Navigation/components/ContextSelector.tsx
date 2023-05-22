import { useState } from 'react'
import {
  Dropdown,
  DropdownItem,
  DropdownToggle
} from '@patternfly/react-core'

import { InlineIcon } from 'Navigation/components/InlineIcon'
import { createReactWrapper } from 'utilities/createReactWrapper'

import type { FunctionComponent } from 'react'

import './ContextSelector.scss'

interface Props {
  menuItems: {
    title: string;
    href: string;
    icon: string;
    disabled: boolean;
  }[];
  toggle: {
    title: string;
    icon: string;
  };
}

const ContextSelector: FunctionComponent<Props> = ({
  toggle,
  menuItems
}) => {
  const [isOpen, setIsOpen] = useState(false)

  const dropdownItems = menuItems.map(({ title, href, icon, disabled }) => (
    <DropdownItem key={title} href={href} isDisabled={disabled}>
      <InlineIcon icon={icon} />{title}
    </DropdownItem>
  ))

  return (
    <Dropdown
      isPlain
      data-quickstart-id="context-selector"
      dropdownItems={dropdownItems}
      isOpen={isOpen}
      ouiaId="context-selector"
      toggle={(
        <DropdownToggle aria-label="Context selector toggle" onToggle={setIsOpen}>
          <span className="pf-c-context-selector__toggle-text">
            <InlineIcon toggle icon={toggle.icon} />{toggle.title}
          </span>
        </DropdownToggle>
      )}
    />
  )
}

// eslint-disable-next-line react/jsx-props-no-spreading
const ContextSelectorWrapper = (props: Props, containerId: string): void => { createReactWrapper(<ContextSelector {...props} />, containerId) }

export type { Props }
export { ContextSelector, ContextSelectorWrapper }
