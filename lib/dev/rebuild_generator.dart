// ignore_for_file: depend_on_referenced_packages

import 'dart:async';

import 'package:analyzer/dart/element/element.dart';
import 'package:build/build.dart';
import 'package:source_gen/source_gen.dart';

import 'package:cupcake/dev/generate_rebuild.dart';
import 'package:cupcake/utils/capitalize.dart';

class RebuildClassGenerator extends GeneratorForAnnotation<GenerateRebuild> {
  @override
  FutureOr<String> generateForAnnotatedElement(
    final Element element,
    final ConstantReader annotation,
    final BuildStep buildStep,
  ) async {
    if (element is! ClassElement) {
      throw InvalidGenerationSourceError(
        'Generator cannot target `${element.displayName}`. '
        '`@GenerateRebuild` can only be applied to classes.',
        element: element,
      );
    }
    final classElement = element;
    final className = classElement.displayName;

    final rebuildMethods = await _rebuildOnChangePart(classElement);
    final throwOnUiMethods = await _throwOnUiPart(classElement);
    final exposeRebuildableAccessorsMethods = await _exposeRebuildableAccessorsPart(classElement);
    final fileName = buildStep.inputId.uri.pathSegments.last;

    return '''
// GENERATED CODE - DO NOT MODIFY BY HAND

// ignore_for_file: unused_element

part of '$fileName';

extension ${className}RebuildExtension on $className {
  // Rebuild methods
${rebuildMethods.join()}
  // Throw on UI methods
${throwOnUiMethods.join()}
  // Expose Settings methods
${exposeRebuildableAccessorsMethods.join()}
}
''';
  }

  Future<List<String>> _rebuildOnChangePart(final ClassElement classElement) async {
    final rebuildMethods = <String>[];
    for (final field in classElement.fields) {
      final hasRebuildOnChange = field.metadata.any((final meta) {
        final constantValue = meta.computeConstantValue();
        return constantValue != null &&
            constantValue.type?.getDisplayString() == RebuildOnChange.name;
      });
      if (!hasRebuildOnChange) continue;
      final fieldName = field.displayName;
      final fieldType = field.type.getDisplayString();
      // Capitalize the field name for the method name.
      final methodSuffix = fieldName[0].toUpperCase() + fieldName.substring(1);
      final noPrefix = methodSuffix.substring(1);
      rebuildMethods.add('''
  $fieldType get $noPrefix => \$$noPrefix;
  set $noPrefix(final $fieldType new$noPrefix) { 
    \$$noPrefix = new$noPrefix;
    markNeedsBuild();
  }
''');
    }

    return rebuildMethods;
  }

  Future<List<String>> _throwOnUiPart(final ClassElement classElement) async {
    final throwOnUiMethods = <String>[];
    for (final field in classElement.methods) {
      final hasThrowOnUI = field.metadata.any((final meta) {
        final constantValue = meta.computeConstantValue();
        return constantValue != null && constantValue.type?.getDisplayString() == ThrowOnUI.name;
      });
      if (!hasThrowOnUI) continue;
      final throwOnUIMeta = field.metadata.firstWhere((final meta) {
        final constantValue = meta.computeConstantValue();
        return constantValue != null && constantValue.type?.getDisplayString() == ThrowOnUI.name;
      });
      final constantValue = throwOnUIMeta.computeConstantValue();

      final messageField = constantValue?.getField('message')?.toStringValue();
      final translationField = constantValue?.getField('L')?.toStringValue();

      if (messageField != null && translationField != null) {
        throw Exception("ThrowOnUI() cannot have message and L at the same time");
      }
      String? alertTitle;
      if (messageField != null) {
        alertTitle = "'''$messageField'''";
      } else if (translationField != null) {
        alertTitle = 'L.$translationField';
      } else {
        throw Exception("ThrowOnUI() requires either L or message");
      }

      final fieldName = field.displayName;
      final fieldType = field.type.getDisplayString().split(" ")[0];
      final fieldArgs = field.type.getDisplayString().split(" ")[1].replaceAll("Function", "");
      final methodSuffix = fieldName[0].toUpperCase() + fieldName.substring(1);
      final noPrefix = methodSuffix.substring(1);
      throwOnUiMethods.add('''
  $fieldType $noPrefix$fieldArgs async { 
    await callThrowable(
      () async => await \$$noPrefix$fieldArgs,
      $alertTitle,
    );
    markNeedsBuild();
  }
''');
    }

    return throwOnUiMethods;
  }

  Future<List<String>> _exposeRebuildableAccessorsPart(final ClassElement classElement) async {
    final rebuildMethods = <String>[];
    // classElement.methods
    for (final field in classElement.accessors) {
      final hasExposeRebuildableAccessors = field.metadata.any((final meta) {
        final constantValue = meta.computeConstantValue();
        return constantValue != null &&
            constantValue.type?.getDisplayString() == ExposeRebuildableAccessors.name;
      });
      if (!hasExposeRebuildableAccessors) continue;
      final exposeRebuildableAccessorsMeta = field.metadata.firstWhere((final meta) {
        final constantValue = meta.computeConstantValue();
        return constantValue != null &&
            constantValue.type?.getDisplayString() == ExposeRebuildableAccessors.name;
      });
      final fieldName = field.displayName;
      // Capitalize the field name for the method name.
      final methodSuffix = fieldName[0].toUpperCase() + fieldName.substring(1);
      final noPrefix = methodSuffix.substring(1);
      final constantValue = exposeRebuildableAccessorsMeta.computeConstantValue();

      String? extraCode = constantValue?.getField('extraCode')?.toStringValue();

      final elements = (field.returnType.element as ClassElement).accessors;
      for (final elm in elements) {
        if (elm.name.endsWith('=')) {
          continue; // something that dart generates I think?
        }
        if (elm.isStatic) continue;
        if (extraCode != null && !extraCode.endsWith(';')) {
          extraCode = "$extraCode;";
        }
        final capitalizedIfIfeelLikeIt = noPrefix.isEmpty ? elm.name : elm.name.capitalize();
        rebuildMethods.add('''
    ${elm.returnType} get $noPrefix$capitalizedIfIfeelLikeIt => \$$noPrefix.${elm.name};
    set $noPrefix$capitalizedIfIfeelLikeIt(final ${elm.returnType} new$capitalizedIfIfeelLikeIt) { 
      \$$noPrefix.${elm.name} = new$capitalizedIfIfeelLikeIt;
      ${(extraCode?.isNotEmpty ?? false) ? extraCode : '// no extraCode property'}
      markNeedsBuild();
    }
  ''');
      }
    }
    return rebuildMethods;
  }
}

Builder rebuildBuilder(final BuilderOptions options) =>
    LibraryBuilder(RebuildClassGenerator(), generatedExtension: '.g.dart');
