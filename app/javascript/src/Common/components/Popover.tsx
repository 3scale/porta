import React from 'react'
import { Popover as PFPopover } from '@patternfly/react-core'

import { createReactWrapper } from 'utilities/createReactWrapper'

interface Props {
  body: string;
  footer?: string;
  header?: string;
}

export const Popover: React.FunctionComponent<Props> = ({
  body,
  footer,
  header
}) => (
  <PFPopover
    bodyContent={<div>{body}</div>}
    footerContent={footer && <div>{footer}</div>}
    headerContent={header && <div>{header}</div>}
    // eslint-disable-next-line @typescript-eslint/no-non-null-assertion
    reference={() => document.getElementById('popover-selector')!}
  />
)

// eslint-disable-next-line react/jsx-props-no-spreading
const PopoverWrapper = (props: Props, containerId: string): void => { createReactWrapper(<Popover {...props} />, containerId) }

export type { Props }
export { PopoverWrapper }
