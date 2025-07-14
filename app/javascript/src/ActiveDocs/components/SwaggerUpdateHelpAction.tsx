import { Popover } from '@patternfly/react-core'
import OutlinedQuestionCircleIcon from '@patternfly/react-icons/dist/js/icons/outlined-question-circle-icon'

import type { FunctionComponent } from 'react'

interface Props {
  href: string;
  title: string;
}

const SwaggerUpdateHelpAction: FunctionComponent<Props> = ({ href, title }) => (
  <span className="pf-c-table__column-help-action">
    <Popover
      bodyContent={(
        <a href={href} rel="noreferrer" target="_blank">{title}</a>
      )}
    >
      <a className="pf-c-button pf-m-plain">
        <OutlinedQuestionCircleIcon />
      </a>
    </Popover>
  </span>
)

export { SwaggerUpdateHelpAction }
