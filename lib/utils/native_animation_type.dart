import 'dart:io';

enum NativeAnimationType {
  material,
  cupertino,
}

final NativeAnimationType nativeAnimationType =
    Platform.isIOS ? NativeAnimationType.cupertino : NativeAnimationType.material;
