// @flow

import * as React from 'react'

import { NewMappingRule } from 'MappingRules'
import { createReactWrapper } from 'utilities'

import type { Props } from 'MappingRules/components/NewMappingRule'

const NewMappingRuleWrapper = (props: Props, containerId: string): void => createReactWrapper(<NewMappingRule {...props} />, containerId)

export { NewMappingRuleWrapper }
