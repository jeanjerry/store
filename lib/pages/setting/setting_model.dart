import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import 'setting_widget.dart' show SettingWidget;
import 'package:easy_debounce/easy_debounce.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class SettingModel extends FlutterFlowModel<SettingWidget> {
  ///  State fields for stateful widgets in this page.

  // State field(s) for storename widget.
  FocusNode? storenameFocusNode;
  TextEditingController? storenameController;
  String? Function(BuildContext, String?)? storenameControllerValidator;
  // State field(s) for storeaddress widget.
  FocusNode? storeaddressFocusNode;
  TextEditingController? storeaddressController;
  String? Function(BuildContext, String?)? storeaddressControllerValidator;
  // State field(s) for storephone widget.
  FocusNode? storephoneFocusNode;
  TextEditingController? storephoneController;
  String? Function(BuildContext, String?)? storephoneControllerValidator;
  // State field(s) for tag widget.
  FocusNode? tagFocusNode;
  TextEditingController? tagController;
  String? Function(BuildContext, String?)? tagControllerValidator;
  // State field(s) for email widget.
  FocusNode? emailFocusNode;
  TextEditingController? emailController;
  String? Function(BuildContext, String?)? emailControllerValidator;
  // State field(s) for imagelink widget.
  FocusNode? imagelinkFocusNode;
  TextEditingController? imagelinkController;
  String? Function(BuildContext, String?)? imagelinkControllerValidator;

  /// Initialization and disposal methods.

  void initState(BuildContext context) {}

  void dispose() {
    storenameFocusNode?.dispose();
    storenameController?.dispose();

    storeaddressFocusNode?.dispose();
    storeaddressController?.dispose();

    storephoneFocusNode?.dispose();
    storephoneController?.dispose();

    tagFocusNode?.dispose();
    tagController?.dispose();

    emailFocusNode?.dispose();
    emailController?.dispose();

    imagelinkFocusNode?.dispose();
    imagelinkController?.dispose();
  }

  /// Action blocks are added here.

  /// Additional helper methods are added here.
}
