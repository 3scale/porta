// @flow

import React from 'react'

import { DefaultPlanSelectCard } from 'Plans'
import { createReactWrapper } from 'utilities/createReactWrapper'

import type { Props } from 'Plans/components/DefaultPlanSelectCard'

const DefaultPlanSelectWrapper = (props: Props, containerId: string) => createReactWrapper(<DefaultPlanSelectCard {...props} />, containerId)

export { DefaultPlanSelectWrapper }
