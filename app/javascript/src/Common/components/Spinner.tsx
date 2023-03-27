import type { SpinnerProps as Props } from '@patternfly/react-core'

import './Spinner.scss'

const Spinner: React.FunctionComponent<Props> = ({ size = 'md', className = '' }) => {
  const classParameters = `pf-c-spinner pf-m-${size} ${className}`

  return (
    <span aria-valuetext="Loading projects" className={classParameters} role="progressbar">
      <span className="pf-c-spinner__clipper" />
      <span className="pf-c-spinner__lead-ball" />
      <span className="pf-c-spinner__tail-ball" />
    </span>
  )
}

export type { Props }
export { Spinner }
