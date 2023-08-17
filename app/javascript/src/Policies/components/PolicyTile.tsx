import type { RegistryPolicy, ThunkAction } from 'Policies/types'

interface Props {
  isDisabled?: boolean;
  policy: RegistryPolicy;
  title?: string;
  onClick: () => ThunkAction;
}

const PolicyTile: React.FunctionComponent<Props> = ({
  isDisabled,
  policy,
  onClick,
  title = 'Edit this Policy'
}) => {
  return (
    <article
      className={`Policy-article ${isDisabled ? 'Policy--disabled' : ''}`}
      title={title}
      onClick={onClick}
    >
      <h3 className="Policy-name">{policy.humanName}</h3>
      <p className="Policy-version-and-summary">
        <span>
          {`${policy.version} - ${policy.summary || ''}`}
        </span>
      </p>
    </article>
  )
}

export type { Props }
export { PolicyTile }
