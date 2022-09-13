import * as React from 'react'
import './Spinner.scss'

type Props = {
  size?: 'sm' | 'md' | 'lg' | 'xl',
  className?: string
};

const Spinner = (
  {
    size = 'md',
    className = ''
  }: Props
): React.ReactElement => {
  const classParameters = `pf-c-spinner pf-m-${size} ${className}`

  return (
    <span className={classParameters} role="progressbar" aria-valuetext="Loading projects">
      <span className="pf-c-spinner__clipper"></span>
      <span className="pf-c-spinner__lead-ball"></span>
      <span className="pf-c-spinner__tail-ball"></span>
    </span>
  )
}

export { Spinner }
