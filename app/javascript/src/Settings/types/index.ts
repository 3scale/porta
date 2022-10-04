import type { TextInputProps } from '@patternfly/react-core'

export type FieldGroupProps = {
  name: string,
  value: string,
  label: string,
  children?: React.ReactNode,
  legend?: string,
  checked?: boolean,
  hint?: string,
  placeholder?: string,
  defaultValue?: string,
  readOnly?: boolean,
  inputType?: TextInputProps['type'],
  isDefaultValue?: boolean,
  onChange?: (value: string, event: React.SyntheticEvent<HTMLButtonElement>) => void
}

export type FieldCatalogProps = {
  catalog: Record<string, string>
}

export type TypeItemProps = {
  type: FieldGroupProps & FieldCatalogProps,
  item: FieldGroupProps
}

export type LegendCollectionProps = {
  legend: string,
  collection: FieldGroupProps[]
}
