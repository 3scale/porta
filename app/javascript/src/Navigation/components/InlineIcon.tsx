import { Icon } from '@patternfly/react-core'
import BookIcon from '@patternfly/react-icons/dist/js/icons/book-icon'
import BullseyeIcon from '@patternfly/react-icons/dist/js/icons/bullseye-icon'
import CodeIcon from '@patternfly/react-icons/dist/js/icons/code-icon'
import CogIcon from '@patternfly/react-icons/dist/js/icons/cog-icon'
import CubeIcon from '@patternfly/react-icons/dist/js/icons/cube-icon'
import CubesIcon from '@patternfly/react-icons/dist/js/icons/cubes-icon'
import ExternalLinkAltIcon from '@patternfly/react-icons/dist/js/icons/external-link-alt-icon'
import HomeIcon from '@patternfly/react-icons/dist/js/icons/home-icon'
import LeafIcon from '@patternfly/react-icons/dist/js/icons/leaf-icon'
import PuzzlePieceIcon from '@patternfly/react-icons/dist/js/icons/puzzle-piece-icon'
import TimesIcon from '@patternfly/react-icons/dist/js/icons/times-icon'

import type { FunctionComponent, ReactNode } from 'react'

import './InlineIcon.scss'

interface Props {
  icon: string;
  toggle?: boolean;
}

/**
 * HACK: FIXME: Instead of importing and rendering components in a hacky switch block, ideally it could
 * return the HTML version of Patternfly's Icon:
 *   (icon) => (
 *     <span class="pf-c-icon">
 *       <span class="pf-c-icon__content">
 *         <i class={`fas fa-${icon}`} aria-hidden="true"></i>
 *       </span>
 *     </span>
 *   )
 */

const InlineIcon: FunctionComponent<Props> = ({ icon, toggle }) => {
  let iconComponent: ReactNode = null

  switch (icon) {

    case 'book':
      iconComponent = <BookIcon />
      break

    case 'bullseye':
      iconComponent = <BullseyeIcon />
      break

    case 'code':
      iconComponent = <CodeIcon />
      break

    case 'cog':
      iconComponent = <CogIcon />
      break

    case 'cube':
      iconComponent = <CubeIcon />
      break

    case 'cubes':
      iconComponent = <CubesIcon />
      break

    case 'external-link':
      iconComponent = <ExternalLinkAltIcon />
      break

    case 'home':
      iconComponent = <HomeIcon />
      break

    case 'leaf':
      iconComponent = <LeafIcon />
      break

    case 'puzzle-piece':
      iconComponent = <PuzzlePieceIcon />
      break

    case 'times':
      iconComponent = <TimesIcon />
      break
  }

  const className = `header-context-selector__item-icon${toggle ? ' header-context-selector__toggle-text-icon' : ''}`

  return (
    <Icon isInline className={className}>
      {iconComponent}
    </Icon>
  )
}

export type { Props }
export { InlineIcon }
