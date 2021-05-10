// @flow

import React from 'react'

import { ApplicationPlansTableCard } from 'Plans'
import { createReactWrapper } from 'utilities'
import type { Props } from 'Plans/components/ApplicationPlansTableCard'

const ApplicationPlansTableCardWrapper = (props: Props, containerId: string): void => (
  createReactWrapper(<ApplicationPlansTableCard {...props} />, containerId)
)

export { ApplicationPlansTableCardWrapper }
