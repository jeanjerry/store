import '/flutter_flow/flutter_flow_animations.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import 'login_widget.dart' show LoginWidget;
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class LoginModel extends FlutterFlowModel<LoginWidget> {
  ///  State fields for stateful widgets in this page.

  final unfocusNode = FocusNode();
  // State field(s) for TabBar widget.
  TabController? tabBarController;
  int get tabBarCurrentIndex =>
      tabBarController != null ? tabBarController!.index : 0;

  // State field(s) for store_name widget.
  FocusNode? storeNameFocusNode;
  TextEditingController? storeNameController;
  String? Function(BuildContext, String?)? storeNameControllerValidator;
  // State field(s) for store_address widget.
  FocusNode? storeAddressFocusNode;
  TextEditingController? storeAddressController;
  String? Function(BuildContext, String?)? storeAddressControllerValidator;
  // State field(s) for store_phone widget.
  FocusNode? storePhoneFocusNode;
  TextEditingController? storePhoneController;
  String? Function(BuildContext, String?)? storePhoneControllerValidator;
  // State field(s) for store_email widget.
  FocusNode? storeEmailFocusNode;
  TextEditingController? storeEmailController;
  String? Function(BuildContext, String?)? storeEmailControllerValidator;
  // State field(s) for store_tag widget.
  FocusNode? storeTagFocusNode;
  TextEditingController? storeTagController;
  String? Function(BuildContext, String?)? storeTagControllerValidator;
  // State field(s) for password widget.
  FocusNode? passwordFocusNode1;
  TextEditingController? passwordController1;
  String? Function(BuildContext, String?)? passwordController1Validator;
  // State field(s) for Address widget.
  FocusNode? addressFocusNode;
  TextEditingController? addressController;
  String? Function(BuildContext, String?)? addressControllerValidator;
  // State field(s) for emailAddress widget.
  FocusNode? emailAddressFocusNode;
  TextEditingController? emailAddressController;
  String? Function(BuildContext, String?)? emailAddressControllerValidator;
  // State field(s) for password widget.
  FocusNode? passwordFocusNode2;
  TextEditingController? passwordController2;
  late bool passwordVisibility;
  String? Function(BuildContext, String?)? passwordController2Validator;

  /// Initialization and disposal methods.

  void initState(BuildContext context) {
    passwordVisibility = false;
  }

  void dispose() {
    unfocusNode.dispose();
    tabBarController?.dispose();
    storeNameFocusNode?.dispose();
    storeNameController?.dispose();

    storeAddressFocusNode?.dispose();
    storeAddressController?.dispose();

    storePhoneFocusNode?.dispose();
    storePhoneController?.dispose();

    storeEmailFocusNode?.dispose();
    storeEmailController?.dispose();

    storeTagFocusNode?.dispose();
    storeTagController?.dispose();

    passwordFocusNode1?.dispose();
    passwordController1?.dispose();

    addressFocusNode?.dispose();
    addressController?.dispose();

    emailAddressFocusNode?.dispose();
    emailAddressController?.dispose();

    passwordFocusNode2?.dispose();
    passwordController2?.dispose();
  }

  /// Action blocks are added here.

  /// Additional helper methods are added here.
}
