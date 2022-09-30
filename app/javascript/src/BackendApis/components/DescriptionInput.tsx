
import { FormGroup, TextArea } from '@patternfly/react-core'

type Props = {
  description: string,
  setDescription: (arg1: string) => void
};

const DescriptionInput = (
  {
    description,
    setDescription
  }: Props
): React.ReactElement => <FormGroup
  label="Description"
  validated="default"
  fieldId="backend_api_description"
>
  <TextArea
    id="backend_api_description"
    name="backend_api[description]"
    value={description}
    onChange={setDescription}
  />
</FormGroup>

export { DescriptionInput, Props }
