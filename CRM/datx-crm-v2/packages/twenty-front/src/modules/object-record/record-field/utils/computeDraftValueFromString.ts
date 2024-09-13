import { CurrencyCode } from '@/object-record/record-field/types/CurrencyCode';
import { FieldDefinition } from '@/object-record/record-field/types/FieldDefinition';
import { FieldInputDraftValue } from '@/object-record/record-field/types/FieldInputDraftValue';
import { FieldMetadata } from '@/object-record/record-field/types/FieldMetadata';
import { isFieldAddress } from '@/object-record/record-field/types/guards/isFieldAddress';
import { isFieldCurrency } from '@/object-record/record-field/types/guards/isFieldCurrency';
import { isFieldDateTime } from '@/object-record/record-field/types/guards/isFieldDateTime';
import { isFieldEmail } from '@/object-record/record-field/types/guards/isFieldEmail';
import { isFieldFullName } from '@/object-record/record-field/types/guards/isFieldFullName';
import { isFieldLink } from '@/object-record/record-field/types/guards/isFieldLink';
import { isFieldLinks } from '@/object-record/record-field/types/guards/isFieldLinks';
import { isFieldNumber } from '@/object-record/record-field/types/guards/isFieldNumber';
import { isFieldRelation } from '@/object-record/record-field/types/guards/isFieldRelation';
import { isFieldText } from '@/object-record/record-field/types/guards/isFieldText';
import { isFieldUuid } from '@/object-record/record-field/types/guards/isFieldUuid';

type computeDraftValueFromStringParams = {
  fieldDefinition: Pick<FieldDefinition<FieldMetadata>, 'type'>;
  value: string;
};

export const computeDraftValueFromString = <FieldValue>({
  fieldDefinition,
  value,
}: computeDraftValueFromStringParams):
  | FieldInputDraftValue<FieldValue>
  | undefined => {
  // Todo: improve typing
  if (
    isFieldUuid(fieldDefinition) ||
    isFieldText(fieldDefinition) ||
    isFieldDateTime(fieldDefinition) ||
    isFieldNumber(fieldDefinition) ||
    isFieldEmail(fieldDefinition) ||
    isFieldRelation(fieldDefinition)
  ) {
    return value as FieldInputDraftValue<FieldValue>;
  }
  if (isFieldLink(fieldDefinition)) {
    return { url: value, label: value } as FieldInputDraftValue<FieldValue>;
  }

  if (isFieldCurrency(fieldDefinition)) {
    return {
      amount: value,
      currenyCode: CurrencyCode.USD,
    } as unknown as FieldInputDraftValue<FieldValue>;
  }

  if (isFieldFullName(fieldDefinition)) {
    return {
      firstName: value,
      lastName: '',
    } as FieldInputDraftValue<FieldValue>;
  }

  if (isFieldAddress(fieldDefinition)) {
    return {
      addressStreet1: value,
    } as FieldInputDraftValue<FieldValue>;
  }

  if (isFieldLinks(fieldDefinition)) {
    return {
      primaryLinkUrl: value,
    } as FieldInputDraftValue<FieldValue>;
  }

  throw new Error(`Record field type not supported : ${fieldDefinition.type}}`);
};
