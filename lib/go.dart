import "dart:convert";
import "dart:ffi";
import 'dart:io';
import 'package:ffi/ffi.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:system_info/system_info.dart';

typedef StringPtr = Pointer<GoString> Function(
    Pointer<GoString>, Pointer<GoString>);

// only tested windows and android
Future<String> getLibPath(String modName) async {
  final ext = Platform.isWindows
      ? 'dll'
      : Platform.isMacOS || Platform.isIOS ? 'dylib' : 'so';
  final filename = '$modName-${SysInfo.kernelArchitecture.toLowerCase()}.$ext';

  var libPath = 'assets/lib/$filename';

  if (Platform.isAndroid || Platform.isIOS) {
    print('mobbbbbbbbbbbbbbbbbbbbbbbbb');
    // copy lib file to mobile app data folder
    final savedPath =
        (await getApplicationSupportDirectory()).path + '/' + filename;
    final data = await rootBundle.load(libPath);
    File(savedPath).writeAsBytesSync(
        data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes));
    libPath = savedPath;
  }

  print(libPath);

  return libPath;
}

class Go {
  static DynamicLibrary dylib;

  static void load(String name) async {
    dylib = DynamicLibrary.open(await getLibPath(name));
  }

  static void hello(String msg) {
    final func = dylib.lookupFunction<Void Function(Pointer<GoString>),
        void Function(Pointer<GoString>)>('hello');

    final msgPtr = GoString.toGoString(msg);
    func(msgPtr);
    free(msgPtr.ref.valuePtr);
    free(msgPtr);
  }

  static String hi() {
    // hi func: first parameter is for return value.
    final func = dylib.lookupFunction<
        Pointer<GoString> Function(Pointer<GoString>),
        Pointer<GoString> Function(Pointer<GoString>)>('hi');

    final retArgPtr = allocate<GoString>();
    final retPtr = func(retArgPtr);
    final result = retPtr.ref.toString();
    free(retPtr);
    return result;
  }

  static String echo(String msg) {
    // echo func: first parameter is for return value.
    final func = dylib.lookupFunction<
        Pointer<GoString> Function(Pointer<GoString>, Pointer<GoString>),
        Pointer<GoString> Function(
            Pointer<GoString>, Pointer<GoString>)>('echo');

    final retArgPtr = allocate<GoString>();
    final msgPtr = GoString.toGoString(msg);
    final retPtr = func(retArgPtr, msgPtr);
    final result = retPtr.ref.toString();
    free(retPtr);
    free(msgPtr.ref.valuePtr);
    free(msgPtr);
    return result;
  }
}

class GoString extends Struct {
  Pointer<Uint8> valuePtr;

  @IntPtr()
  int length;

  @override
  String toString() => utf8.decode(valuePtr.asTypedList(length));

  static Pointer<GoString> toGoString(String string) {
    final units = utf8.encode(string);
    final Pointer<GoString> result = allocate<GoString>();
    result.ref
      ..length = units.length
      ..valuePtr = allocate<Uint8>(count: units.length);
    result.ref.valuePtr.asTypedList(units.length).setAll(0, units);
    return result;
  }
}
