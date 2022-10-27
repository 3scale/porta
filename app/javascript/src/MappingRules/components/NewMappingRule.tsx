import { useEffect, useState } from 'react'
import {
  ActionGroup,
  Button,
  Form,
  PageSection,
  PageSectionVariants
} from '@patternfly/react-core'

import { HttpMethodSelect } from 'MappingRules/components/HttpMethodSelect'
import { IncrementByInput } from 'MappingRules/components/IncrementByInput'
import { IsLastCheckbox } from 'MappingRules/components/IsLastCheckbox'
import { MetricInput } from 'MappingRules/components/MetricInput'
import { PatternInput } from 'MappingRules/components/PatternInput'
import { PositionInput } from 'MappingRules/components/PositionInput'
import { RedirectUrlInput } from 'MappingRules/components/RedirectUrlInput'
import { createReactWrapper } from 'utilities/createReactWrapper'
import { CSRFToken } from 'utilities/CSRFToken'

import type { Metric } from 'Types'
import type { FunctionComponent } from 'react'

import './NewMappingRule.scss'

interface Props {
  url: string;
  isProxyProEnabled?: boolean;
  topLevelMetrics: Metric[];
  methods: Metric[];
  httpMethods: string[];
  errors?: Record<string, string[]>;
}

type Validated = 'default' | 'error' | 'success' | undefined

const NewMappingRule: FunctionComponent<Props> = ({
  url,
  isProxyProEnabled = false,
  topLevelMetrics,
  methods,
  httpMethods,
  errors
}) => {
  const [httpMethod, setHttpMethod] = useState(httpMethods[0])
  const [pattern, setPattern] = useState('')
  const [patternValidated, setPatternValidated] = useState<Validated>('default')
  const [helperTextInvalid, setHelperTextInvalid] = useState('')
  const [metric, setMetric] = useState<Metric | null>(null)
  const [redirectUrl, setRedirectUrl] = useState('')
  const [increment, setIncrement] = useState(1)
  const [position, setPosition] = useState(0)
  const [loading, setLoading] = useState(false)

  useEffect(() => {
    if (errors?.pattern) {
      setPatternValidated('error')
      setHelperTextInvalid(errors.pattern.slice().join())
    }
  }, [])

  const validatePattern = (value: string) => {
    setPattern(value)
    setPatternValidated('default')
  }

  const isFormComplete = httpMethod &&
    pattern &&
    patternValidated !== 'error' &&
    metric !== null &&
    increment > 0 &&
    position >= 0

  return (
    <PageSection variant={PageSectionVariants.light}>
      <Form
        acceptCharset="UTF-8"
        action={url}
        id="new_mapping_rule"
        method="post"
        onSubmit={() => { setLoading(true) }}
        // isWidthLimited TODO: use when available instead of hardcoded css
      >
        <CSRFToken />
        <input name="utf8" type="hidden" value="✓" />

        <HttpMethodSelect httpMethod={httpMethod} httpMethods={httpMethods} setHttpMethod={setHttpMethod} />
        <PatternInput helperTextInvalid={helperTextInvalid} pattern={pattern} validatePattern={() => validatePattern} validated={patternValidated} />
        <MetricInput methods={methods} metric={metric} setMetric={setMetric} topLevelMetrics={topLevelMetrics} />
        {isProxyProEnabled && <RedirectUrlInput redirectUrl={redirectUrl} setRedirectUrl={setRedirectUrl} />}
        <IncrementByInput increment={increment} setIncrement={setIncrement} />
        <IsLastCheckbox isLast={false} /> {/* TODO: check what this component does and why isLas is always false */}
        <PositionInput position={position} setPosition={setPosition} />

        <ActionGroup>
          <Button
            data-testid="newMappingRule-buttonSubmit"
            isDisabled={!isFormComplete || loading}
            type="submit"
            variant="primary"
          >
            Create mapping rule
          </Button>
        </ActionGroup>
      </Form>
    </PageSection>
  )
}

// eslint-disable-next-line react/jsx-props-no-spreading
const NewMappingRuleWrapper = (props: Props, containerId: string): void => { createReactWrapper(<NewMappingRule {...props} />, containerId) }

export { NewMappingRule, NewMappingRuleWrapper, Props }
