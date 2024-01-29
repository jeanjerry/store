import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

// 獲得最新的菜單版本號
getMenuVersion(contractAddress, wallet) async {
  var url = Uri.parse('http://140.127.114.38:15000/contract/getMenuVersion');
  var body = {
    'contractAddress': contractAddress,
    'wallet': wallet,
  };

  var response = await http.post(
    url,
    body: body,
    headers: {
      'Content-Type': 'application/x-www-form-urlencoded',
    },
  );
  if (response.statusCode == 200) {
    var data = jsonDecode(response.body);
    var menuVersion = data['menuVersion'];
    return menuVersion;
  } else {
    if (kDebugMode) {
      print('Request failed with status: ${response.statusCode}.');
    }
    return null;
  }
}

// 獲得菜單
getMenu(contractAddress, wallet, menuVersion) async {
  var url = Uri.parse('http://140.127.114.38:15000/contract/getMenu');
  var body = {
    'contractAddress': contractAddress,
    'wallet': wallet,
    'menuVersion': menuVersion,
  };

  var response = await http.post(
    url,
    body: body,
    headers: {
      'Content-Type': 'application/x-www-form-urlencoded',
    },
  );

  if (response.statusCode == 200) {
    var data = jsonDecode(response.body);
    var menuLink = data['menuLink'];
    return menuLink;
  } else {
    if (kDebugMode) {
      print('Request failed with status: ${response.statusCode}.');
    }
    return null;
  }
}

// 更新菜單
menuUpdate(contractAddress, storeWallet, storePassword, updateMenuLink) async {
  var url = Uri.parse('http://140.127.114.38:15000/contract/menuUpdate');
  var body = {
    'contractAddress': contractAddress,
    'storeWallet': storeWallet,
    'storePassword': storePassword,
    'updateMenuLink': updateMenuLink,
  };

  var response = await http.post(
    url,
    body: body,
    headers: {
      'Content-Type': 'application/x-www-form-urlencoded',
    },
  );

  if (response.statusCode == 200) {
    var data = jsonDecode(response.body);
    var status = data['status'];
    return status;
  } else {
    if (kDebugMode) {
      print('Request failed with status: ${response.statusCode}.');
    }
    return null;
  }
}
