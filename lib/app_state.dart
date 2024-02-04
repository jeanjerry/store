import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'flutter_flow/flutter_flow_util.dart';

class FFAppState extends ChangeNotifier {
  static FFAppState _instance = FFAppState._internal();

  factory FFAppState() {
    return _instance;
  }

  FFAppState._internal();

  static void reset() {
    _instance = FFAppState._internal();
  }

  Future initializePersistedState() async {
    prefs = await SharedPreferences.getInstance();
    _safeInit(() {
      _account = prefs.getString('ff_account') ?? _account;
    });
    _safeInit(() {
      _password = prefs.getString('ff_password') ?? _password;
    });
    _safeInit(() {
      _name = prefs.getString('ff_name') ?? _name;
    });
    _safeInit(() {
      _Telephone = prefs.getString('ff_Telephone') ?? _Telephone;
    });
    _safeInit(() {
      _email = prefs.getString('ff_email') ?? _email;
    });
    _safeInit(() {
      _people = prefs.getString('ff_people') ?? _people;
    });
    _safeInit(() {
      _storename = prefs.getString('ff_storename') ?? _storename;
    });
    _safeInit(() {
      _storeaddress = prefs.getString('ff_storeaddress') ?? _storeaddress;
    });
    _safeInit(() {
      _storephone = prefs.getString('ff_storephone') ?? _storephone;
    });
    _safeInit(() {
      _tag = prefs.getString('ff_tag') ?? _tag;
    });
    _safeInit(() {
      _address = prefs.getString('ff_address') ?? _address;
    });
    _safeInit(() {
      _imagelink = prefs.getString('ff_imagelink') ?? _imagelink;
    });
  }

  void update(VoidCallback callback) {
    callback();
    notifyListeners();
  }

  late SharedPreferences prefs;

  String _account = '';
  String get account => _account;
  set account(String _value) {
    _account = _value;
    prefs.setString('ff_account', _value);
  }

  String _password = '';
  String get password => _password;
  set password(String _value) {
    _password = _value;
    prefs.setString('ff_password', _value);
  }

  String _name = '';
  String get name => _name;
  set name(String _value) {
    _name = _value;
    prefs.setString('ff_name', _value);
  }

  String _Telephone = '';
  String get Telephone => _Telephone;
  set Telephone(String _value) {
    _Telephone = _value;
    prefs.setString('ff_Telephone', _value);
  }

  String _email = '';
  String get email => _email;
  set email(String _value) {
    _email = _value;
    prefs.setString('ff_email', _value);
  }

  String _people = '';
  String get people => _people;
  set people(String _value) {
    _people = _value;
    prefs.setString('ff_people', _value);
  }

  String _storename = '';
  String get storename => _storename;
  set storename(String _value) {
    _storename = _value;
    prefs.setString('ff_storename', _value);
  }

  String _storeaddress = '';
  String get storeaddress => _storeaddress;
  set storeaddress(String _value) {
    _storeaddress = _value;
    prefs.setString('ff_storeaddress', _value);
  }

  String _storephone = '';
  String get storephone => _storephone;
  set storephone(String _value) {
    _storephone = _value;
    prefs.setString('ff_storephone', _value);
  }

  String _tag = '';
  String get tag => _tag;
  set tag(String _value) {
    _tag = _value;
    prefs.setString('ff_tag', _value);
  }

  String _address = '';
  String get address => _address;
  set address(String _value) {
    _address = _value;
    prefs.setString('ff_address', _value);
  }

  String _imagelink = '';
  String get imagelink => _imagelink;
  set imagelink(String _value) {
    _imagelink = _value;
    prefs.setString('ff_imagelink', _value);
  }
}

LatLng? _latLngFromString(String? val) {
  if (val == null) {
    return null;
  }
  final split = val.split(',');
  final lat = double.parse(split.first);
  final lng = double.parse(split.last);
  return LatLng(lat, lng);
}

void _safeInit(Function() initializeField) {
  try {
    initializeField();
  } catch (_) {}
}

Future _safeInitAsync(Function() initializeField) async {
  try {
    await initializeField();
  } catch (_) {}
}
