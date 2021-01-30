// @flow

import React from 'react'

import { DefaultPlanSelectSection } from 'Applications'
import { createReactWrapper } from 'utilities/createReactWrapper'

import type { Props } from 'Applications/components/DefaultPlanSelectSection'

const DefaultPlanSelectWrapper = (props: Props, containerId: string) => createReactWrapper(<DefaultPlanSelectSection {...props} />, containerId)

export { DefaultPlanSelectWrapper }
