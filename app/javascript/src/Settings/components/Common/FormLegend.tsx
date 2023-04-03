// TODO: Replace this component when patternfly-react implements it.

type Props = React.HTMLAttributes<HTMLLegendElement>

const FormLegend: React.FunctionComponent<React.HTMLAttributes<HTMLLegendElement>> = ({ children, className = '', ...props }) => (
  // eslint-disable-next-line react/jsx-props-no-spreading
  <legend {...props} className={`pf-c-form__legend ${className}`}>
    {children}
  </legend>
)

export type { Props }
export { FormLegend }
