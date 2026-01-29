// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'action_input_field.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ActionInputField _$ActionInputFieldFromJson(Map<String, dynamic> json) =>
    ActionInputField(
      key: json['key'] as String,
      label: json['label'] as String,
      type: ActionInputType.fromJson(json['type'] as String),
    );

Map<String, dynamic> _$ActionInputFieldToJson(ActionInputField instance) =>
    <String, dynamic>{
      'key': instance.key,
      'label': instance.label,
      'type': _$ActionInputTypeEnumMap[instance.type]!,
    };

const _$ActionInputTypeEnumMap = {
  ActionInputType.number: 'number',
  ActionInputType.text: 'text',
  ActionInputType.image: 'image',
  ActionInputType.$unknown: r'$unknown',
};
