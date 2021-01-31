// @flow

import React from 'react'

import { DefaultPlanSelectCard } from 'Applications'
import { createReactWrapper } from 'utilities/createReactWrapper'

import type { Props } from 'Applications/components/DefaultPlanSelectCard'

const DefaultPlanSelectWrapper = (props: Props, containerId: string) => createReactWrapper(<DefaultPlanSelectCard {...props} />, containerId)

export { DefaultPlanSelectWrapper }
