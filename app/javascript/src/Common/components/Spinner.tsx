import './Spinner.scss'

type Props = {
  size?: 'sm' | 'md' | 'lg' | 'xl',
  className?: string
}

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

export { Spinner, Props }
