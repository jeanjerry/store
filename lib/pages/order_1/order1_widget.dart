import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:decimal/decimal.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../google_api.dart';
import '../message/message_widget.dart';
import '/flutter_flow/flutter_flow_icon_button.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'order1_model.dart';
export 'order1_model.dart';
import 'package:http/http.dart' as http;
import '/main.dart';
import '/database/storeDB.dart'; // 引入自定義的 SQL 檔案
import 'package:permission_handler/permission_handler.dart';


class Order1Widget extends StatefulWidget {
  const Order1Widget({Key? key, required this.C}) : super(key: key);
  final Map<String, dynamic> C;
  @override
  _Order1WidgetState createState() => _Order1WidgetState();
}

class _Order1WidgetState extends State<Order1Widget> {



  Future<void> checkAndRequestPermissions() async {
    var status = await Permission.storage.status;
    if (status.isDenied) {
      await Permission.storage.request();
    }
  }

  getOrderContent() async {   //獲取訂單內容
    var url = Uri.parse(ip+"contract/getOrderContent");

    final responce = await http.post(url,body: {

      "contractAddress": FFAppState().address,
      "wallet": FFAppState().account,
      "id": widget.C["id"],

    });
    if (responce.statusCode == 200) {
      var data = json.decode(responce.body);//將json解碼為陣列形式
      //print("訂單內容:${data["orderContent"].toString()}");
      return data["orderContent"];
    }
  }

  getOrder() async {
    var url = Uri.parse(ip+"contract/getOrder");

    final responce = await http.post(url,body: {

      "contractAddress": FFAppState().address,
      "wallet": FFAppState().account,
      "id": widget.C["id"],

    });
    if (responce.statusCode == 200) {
      var data = json.decode(responce.body);//將json解碼為陣列形式
      return data;
    }
  }

  Future<bool> _checkImageFileExist_takemeal() async {
    File imageFile = File("/data/data/com.mycompany.store/confirm_picture/"+FFAppState().address+"-"+widget.C["id"]+"-"+"取餐照片-0");
    return await imageFile.exists();
  }

  Future<bool> _checkImageFileExist_service() async {
    File imageFile = File("/data/data/com.mycompany.store/confirm_picture/"+FFAppState().address+"-"+widget.C["id"]+"-"+"送達照片-0");
    return await imageFile.exists();
  }

  storePrepared() async {   //店家是否準備好餐點
    var url = Uri.parse(ip+"contract/storePrepared");

    final responce = await http.post(url,body: {

      "contractAddress": FFAppState().address,
      "storeWallet": FFAppState().account,
      "storePassword": FFAppState().password,
      "id": widget.C["id"],

    });
    if (responce.statusCode == 200) {
      var data = json.decode(responce.body);//將json解碼為陣列形式
      print("餐點已準備好");
      return data;
    }
  }



  getImage() async {   //店家是否準備好餐點
    File filePath1 = File("/data/data/com.mycompany.store/confirm_picture/"+FFAppState().address+"-"+widget.C["id"]+"-"+"取餐照片-0");
    File filePath2 = File("/data/data/com.mycompany.store/confirm_picture/"+FFAppState().address+"-"+widget.C["id"]+"-"+"送達照片-0");
    print("sadas");
     //Timer.periodic(Duration(seconds: 25), (Timer timer) async {

      if ( filePath1.existsSync() &&  filePath2.existsSync()) {
        print('文件路径有效，且文件存在。');
        //timer.cancel();
      } else if (  filePath1.existsSync() ){
          await checkAndRequestPermissions();  //確認權限
          await GoogleHelper.gmailGetMessage(FFAppState().address,widget.C["id"],"送達照片");
          print("送達照片完成");
          setState(() {});
      }
      else {
        await checkAndRequestPermissions();  //確認權限
        await GoogleHelper.gmailGetMessage(FFAppState().address,widget.C["id"],"取餐照片");
        print("取餐照片完成");
        setState(() {});
        await GoogleHelper.gmailGetMessage(FFAppState().address,widget.C["id"],"送達照片");
        print("送達照片完成");
        setState(() {});
        print('文件路径为空或文件不存在。');
      }
    //});
  }



  List<Map<String, dynamic>> orderContentList = []; // 訂單內容
  Future<List> getData() async {
    if(orderContentList.isEmpty){
      await dbHelper.dbResetOrder_content();
      orderContentList = List.from(orderContentList);//使list變成可更改的
      orderContentList.clear();
      var orderContent = await getOrderContent();
      for (var i =0; i< orderContent.length;i++){
        Map<String, dynamic> A = {};//重要{}
        A['orderID']=orderContent[i][0];
        A['num']=orderContent[i][1];
        A['money']=(Decimal.parse(orderContent[i][2]) / Decimal.parse('1e18')).toDouble().toString();
        await dbHelper.dbInsertOrder_content(A); // 將訂單內容插入資料庫
      }
      print("訂單內容是: $orderContent");
      orderContentList = await dbHelper.dbGetOrder_content(); // 更新訂單內
    }
    return orderContentList;
  }




  bool isButtonPressed = false; //控制按鈕狀態
  late DBHelper dbHelper; // DBHelper 實例
  late Order1Model _model;

  final scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => Order1Model());
    dbHelper = DBHelper(); // 初始化 DBHelper
    getImage();
    setState(() {

    });
  }



  @override
  void dispose() {
    _model.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (isiOS) {
      SystemChrome.setSystemUIOverlayStyle(
        SystemUiOverlayStyle(
          statusBarBrightness: Theme.of(context).brightness,
          systemStatusBarContrastEnforced: true,
        ),
      );
    }

    context.watch<FFAppState>();

    return Scaffold(
      key: scaffoldKey,
      backgroundColor: FlutterFlowTheme.of(context).primaryBackground,
      appBar: AppBar(
        backgroundColor: Color(0xFFF1F4F8),
        automaticallyImplyLeading: false,
        leading: FlutterFlowIconButton(
          borderColor: Colors.transparent,
          borderRadius: 30.0,
          borderWidth: 1.0,
          buttonSize: 60.0,
          icon: Icon(
            Icons.arrow_back_rounded,
            color: FlutterFlowTheme.of(context).primaryText,
            size: 30.0,
          ),
          onPressed: () async {
            context.pop();
          },
        ),
        title: Align(
          alignment: AlignmentDirectional(0.0, -1.0),
          child: Padding(
            padding: EdgeInsetsDirectional.fromSTEB(0.0, 0.0, 56.0, 30.0),
            child: Text(
              'Blofood',
              style: FlutterFlowTheme.of(context).displaySmall.override(
                    fontFamily: 'Outfit',
                    color: Color(0xFFF35E5E),
                  ),
            ),
          ),
        ),
        actions: [],
        centerTitle: true,
        elevation: 2.0,
      ),
      body: SafeArea(
        top: true,
        child: Align(
          alignment: AlignmentDirectional(0.0, -1.0),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.max,
              children: [
                Padding(
                  padding:
                      EdgeInsetsDirectional.fromSTEB(16.0, 16.0, 16.0, 24.0),
                  child: Wrap(
                    spacing: 16.0,
                    runSpacing: 16.0,
                    alignment: WrapAlignment.start,
                    crossAxisAlignment: WrapCrossAlignment.start,
                    direction: Axis.horizontal,
                    runAlignment: WrapAlignment.start,
                    verticalDirection: VerticalDirection.down,
                    clipBehavior: Clip.none,
                    children: [
                      Text(
                        '訂單詳細資料',
                        style: FlutterFlowTheme.of(context).bodyMedium.override(
                              fontFamily: 'Readex Pro',
                              fontSize: 25.0,
                              fontWeight: FontWeight.w500,
                            ),
                      ),
                      Container(
                        width: MediaQuery.sizeOf(context).width * 1.0,
                        height: MediaQuery.sizeOf(context).height * 0.08,
                        decoration: BoxDecoration(
                          boxShadow: [
                            BoxShadow(
                              blurRadius: 4.0,
                              color: Color(0x33000000),
                              offset: Offset(0.0, 5.0),
                            )
                          ],
                          borderRadius: BorderRadius.circular(0.0),
                          shape: BoxShape.rectangle,
                        ),
                        child: FFButtonWidget(
                          onPressed: isButtonPressed ? null : () async {
                            // 按鈕未被按下時執行的操作
                            await storePrepared();
                            //await getImage();

                            // 設置按鈕為已被按下
                            setState(() {
                              isButtonPressed = true;
                            });
                          },
                          text: '餐點準備完成',
                          options: FFButtonOptions(
                            width: MediaQuery.sizeOf(context).width * 0.1,
                            height: MediaQuery.sizeOf(context).height * 0.05,
                            padding: EdgeInsetsDirectional.fromSTEB(
                                24.0, 0.0, 24.0, 0.0),
                            iconPadding: EdgeInsetsDirectional.fromSTEB(
                                0.0, 0.0, 0.0, 0.0),
                            color: Color(0xFFFF8640),
                            textStyle: FlutterFlowTheme.of(context)
                                .titleLarge
                                .override(
                                  fontFamily: 'Outfit',
                                  fontSize: 24.0,
                                ),
                            elevation: 3.0,
                            borderSide: BorderSide(
                              color: Colors.transparent,
                              width: 1.0,
                            ),
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                        ),
                      ),
                      Container(
                        width: MediaQuery.sizeOf(context).width * 1.0,
                        height: MediaQuery.sizeOf(context).height * 0.42,
                        constraints: BoxConstraints(
                          maxWidth: 750.0,
                        ),
                        decoration: BoxDecoration(
                          color:
                              FlutterFlowTheme.of(context).secondaryBackground,
                          boxShadow: [
                            BoxShadow(
                              blurRadius: 4.0,
                              color: Color(0x33000000),
                              offset: Offset(0.0, 2.0),
                            )
                          ],
                          borderRadius: BorderRadius.circular(12.0),
                        ),
                        child: Padding(
                          padding: EdgeInsets.all(16.0),
                          child: Column(
                            mainAxisSize: MainAxisSize.max,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '單號 : '+widget.C['id'],
                                style: FlutterFlowTheme.of(context)
                                    .bodyMedium
                                    .override(
                                      fontFamily: 'Readex Pro',
                                      fontSize: 22.0,
                                      fontWeight: FontWeight.bold,
                                    ),
                              ),
                              Text(
                                '餐點內容 :',
                                style: FlutterFlowTheme.of(context)
                                    .titleLarge
                                    .override(
                                      fontFamily: 'Outfit',
                                      fontSize: 22.0,
                                      fontWeight: FontWeight.w500,
                                    ),
                              ),
                              ListView(
                                padding: EdgeInsets.zero,
                                shrinkWrap: true,
                                scrollDirection: Axis.vertical,
                                children: [
                                  Padding(
                                    padding: EdgeInsetsDirectional.fromSTEB(
                                        0.0, 0.0, 0.0, 12.0),
                                    child:Container(
                                      width: MediaQuery.sizeOf(context).width * 1.0,
                                      height: MediaQuery.sizeOf(context).height * 0.1,
                                      decoration: BoxDecoration(
                                        color: Color(0xFFF1F4F8),
                                        borderRadius: BorderRadius.circular(0.0),
                                      ),
                                      child:FutureBuilder<List>(
                                        future: getData(),
                                        builder: (ctx,ss) {
                                          if(ss.hasError){
                                            print("error");
                                          }
                                          if(ss.hasData){
                                            return Items(list:ss.data);
                                          }
                                          else{
                                            return CircularProgressIndicator();
                                          }
                                        },
                                      ),
                                    ),
                                  ),
                                  Container(
                                    width:
                                        MediaQuery.sizeOf(context).width * 1.0,
                                    height: MediaQuery.sizeOf(context).height *
                                        0.05,
                                    decoration: BoxDecoration(
                                      color: FlutterFlowTheme.of(context)
                                          .secondaryBackground,
                                    ),
                                    child: Column(
                                      mainAxisSize: MainAxisSize.max,
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          mainAxisSize: MainAxisSize.max,
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            AutoSizeText(
                                              '外送費 : ',
                                              style:
                                                  FlutterFlowTheme.of(context)
                                                      .titleLarge
                                                      .override(
                                                        fontFamily: 'Outfit',
                                                        fontSize: 20.0,
                                                      ),
                                            ),
                                            AutoSizeText(
                                              widget.C['fee']+' ETH',
                                              style:
                                                  FlutterFlowTheme.of(context)
                                                      .titleLarge
                                                      .override(
                                                        fontFamily: 'Outfit',
                                                        fontSize: 20.0,
                                                      ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                  Container(
                                    width:
                                        MediaQuery.sizeOf(context).width * 1.0,
                                    height: MediaQuery.sizeOf(context).height *
                                        0.08,
                                    decoration: BoxDecoration(
                                      color: FlutterFlowTheme.of(context)
                                          .secondaryBackground,
                                    ),
                                    child: AutoSizeText(
                                      '消費者地址 : '+widget.C['consumer'],
                                      style: FlutterFlowTheme.of(context)
                                          .titleLarge
                                          .override(
                                            fontFamily: 'Outfit',
                                            fontSize: 20.0,
                                          ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                      Container(
                        width: MediaQuery.sizeOf(context).width * 1.0,
                        height: MediaQuery.sizeOf(context).height * 0.15,
                        constraints: BoxConstraints(
                          maxWidth: 430.0,
                        ),
                        decoration: BoxDecoration(
                          color: Color(0xFFF1E9E9),
                          boxShadow: [
                            BoxShadow(
                              blurRadius: 4.0,
                              color: Color(0x33000000),
                              offset: Offset(0.0, 5.0),
                            )
                          ],
                          borderRadius: BorderRadius.circular(12.0),
                        ),
                        child: Padding(
                          padding: EdgeInsetsDirectional.fromSTEB(
                              16.0, 16.0, 16.0, 24.0),
                          child: Column(
                            mainAxisSize: MainAxisSize.max,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '備註',
                                style: FlutterFlowTheme.of(context).titleLarge,
                              ),
                              Padding(
                                padding: EdgeInsetsDirectional.fromSTEB(
                                    0.0, 0.0, 0.0, 22.0),
                                child: Column(
                                  mainAxisSize: MainAxisSize.max,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Align(
                                      alignment: AlignmentDirectional(0.0, 0.0),
                                      child: Text(
                                          widget.C['note'].toString(),
                                        style: FlutterFlowTheme.of(context).titleLarge,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      Padding(
                        padding:
                            EdgeInsetsDirectional.fromSTEB(0.0, 10.0, 0.0, 0.0),
                        child: FFButtonWidget(
                          onPressed: () async {
                            Map<String, dynamic> B = {};
                            B['id']=widget.C['id'];
                            await Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (context) => MessageWidget(B: B, ),
                              ),
                            );
                            //context.pushNamed('message');
                          },
                          text: '聊天室',
                          options: FFButtonOptions(
                            width: MediaQuery.sizeOf(context).width * 1.0,
                            height: MediaQuery.sizeOf(context).height * 0.06,
                            padding: EdgeInsets.all(0.0),
                            iconPadding: EdgeInsetsDirectional.fromSTEB(
                                0.0, 0.0, 0.0, 0.0),
                            color: Color(0xFF80D0E9),
                            textStyle: FlutterFlowTheme.of(context)
                                .titleLarge
                                .override(
                                  fontFamily: 'Outfit',
                                  fontWeight: FontWeight.w600,
                                ),
                            elevation: 2.0,
                            borderSide: BorderSide(
                              color: Colors.transparent,
                              width: 1.0,
                            ),
                            borderRadius: BorderRadius.circular(40.0),
                            hoverColor: FlutterFlowTheme.of(context).accent1,
                            hoverBorderSide: BorderSide(
                              color: FlutterFlowTheme.of(context).primary,
                              width: 1.0,
                            ),
                            hoverTextColor:
                                FlutterFlowTheme.of(context).primary,
                          ),
                        ),
                      ),
                      InkWell(
                        splashColor: Colors.transparent,
                        focusColor: Colors.transparent,
                        hoverColor: Colors.transparent,
                        highlightColor: Colors.transparent,
                        onTap: () async {
                          var _result =await getOrder();
                          var result = '' ;
                          setState(() {
                            result = _result["deliveryLocation"];
                            print(result);
                          });
                          Uri mapURL = Uri.parse('https://www.google.com/maps/search/?api=1&query=$result');
                          if (!await launchUrl(mapURL, mode: LaunchMode.externalApplication)) {
                            throw Exception('Could not launch $mapURL');
                          }
                        },
                        child: Container(
                          width: MediaQuery.sizeOf(context).width * 1.0,
                          height: MediaQuery.sizeOf(context).height * 0.2,
                          constraints: BoxConstraints(
                            maxWidth: 430.0,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            boxShadow: [
                              BoxShadow(
                                blurRadius: 4.0,
                                color: Color(0x33000000),
                                offset: Offset(0.0, 6.0),
                              )
                            ],
                            borderRadius: BorderRadius.circular(12.0),
                          ),
                          child: Padding(
                            padding: EdgeInsetsDirectional.fromSTEB(
                                16.0, 16.0, 16.0, 24.0),
                            child: Column(
                              mainAxisSize: MainAxisSize.max,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Padding(
                                  padding: EdgeInsetsDirectional.fromSTEB(
                                      0.0, 0.0, 0.0, 24.0),
                                  child: Column(
                                    mainAxisSize: MainAxisSize.max,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Align(
                                        alignment:
                                            AlignmentDirectional(0.0, 0.0),
                                        child: Text(
                                          '檢視外送員位置',
                                          style: FlutterFlowTheme.of(context)
                                              .titleLarge,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      InkWell(
                        splashColor: Colors.transparent,
                        focusColor: Colors.transparent,
                        hoverColor: Colors.transparent,
                        highlightColor: Colors.transparent,
                        onTap: () async {
                          context.safePop();
                        },
                        child: Container(
                          width: MediaQuery.sizeOf(context).width,
                          height: MediaQuery.sizeOf(context).height * 0.3,
                          constraints: BoxConstraints(
                            maxWidth: 430,
                          ),
                          decoration: BoxDecoration(
                            color: Color(0xFFD9BABA),
                            boxShadow: [
                              BoxShadow(
                                blurRadius: 4,
                                color: Color(0x33000000),
                                offset: Offset(0, 5),
                              )
                            ],
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Stack(
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  FutureBuilder<bool>(
                                    future: _checkImageFileExist_takemeal(),
                                    builder: (context, snapshot) {
                                      if (snapshot.connectionState == ConnectionState.done) {
                                        if (snapshot.data == true) {
                                          // If image file exists, display "外送員已取餐"
                                          return Padding(
                                            padding: EdgeInsets.all(8.0),
                                            child: Text(
                                              "外送員已取餐",
                                              style: TextStyle(
                                                fontSize: 24,
                                              ),
                                            ),
                                          );
                                        } else {
                                          // If image file doesn't exist, display "外送員未取餐"
                                          return Padding(
                                            padding: EdgeInsets.all(8.0),
                                            child: Text(
                                              "外送員未取餐",
                                              style: TextStyle(
                                                fontSize: 24,
                                              ),
                                            ),
                                          );
                                        }
                                      } else {
                                        // Loading indicator while checking file existence
                                        return Center(
                                          child: CircularProgressIndicator(),
                                        );
                                      }
                                    },
                                  ),
                                ],
                              ),
                              Align(
                                alignment: Alignment.center,
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(8),
                                  child: FutureBuilder<bool>(
                                    future: _checkImageFileExist_takemeal(),
                                    builder: (context, snapshot) {
                                      if (snapshot.connectionState == ConnectionState.done) {
                                        if (snapshot.data == true) {
                                          // If image file exists, display Image widget
                                          return Image.file(
                                            File("/data/data/com.mycompany.store/confirm_picture/"+FFAppState().address+"-"+widget.C["id"]+"-"+"取餐照片-0"),
                                            width: MediaQuery.sizeOf(context).width * 0.9,
                                            height: MediaQuery.sizeOf(context).height * 0.2,
                                            fit: BoxFit.cover,
                                          );
                                        } else {
                                          // If image file doesn't exist, display CircularProgressIndicator
                                          return CircularProgressIndicator();
                                        }
                                      } else {
                                        // Loading indicator while checking file existence
                                        return CircularProgressIndicator();
                                      }
                                    },
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      InkWell(
                        splashColor: Colors.transparent,
                        focusColor: Colors.transparent,
                        hoverColor: Colors.transparent,
                        highlightColor: Colors.transparent,
                        onTap: () async {
                          context.safePop();
                        },
                        child: Container(
                          width: MediaQuery.sizeOf(context).width,
                          height: MediaQuery.sizeOf(context).height * 0.3,
                          constraints: BoxConstraints(
                            maxWidth: 430,
                          ),
                          decoration: BoxDecoration(
                            color: Color(0xFFD9BABA),
                            boxShadow: [
                              BoxShadow(
                                blurRadius: 4,
                                color: Color(0x33000000),
                                offset: Offset(0, 5),
                              )
                            ],
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Stack(
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  FutureBuilder<bool>(
                                    future: _checkImageFileExist_service(),
                                    builder: (context, snapshot) {
                                      if (snapshot.connectionState == ConnectionState.done) {
                                        if (snapshot.data == true) {
                                          // If image file exists, display "外送員已取餐"
                                          return Padding(
                                            padding: EdgeInsets.all(8.0),
                                            child: Text(
                                              "外送員已送達",
                                              style: TextStyle(
                                                fontSize: 24,
                                              ),
                                            ),
                                          );
                                        } else {
                                          // If image file doesn't exist, display "外送員未取餐"
                                          return Padding(
                                            padding: EdgeInsets.all(8.0),
                                            child: Text(
                                              "外送員未送達",
                                              style: TextStyle(
                                                fontSize: 24,
                                              ),
                                            ),
                                          );
                                        }
                                      } else {
                                        // Loading indicator while checking file existence
                                        return Center(
                                          child: CircularProgressIndicator(),
                                        );
                                      }
                                    },
                                  ),
                                ],
                              ),
                              Align(
                                alignment: Alignment.center,
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(8),
                                  child: FutureBuilder<bool>(
                                    future: _checkImageFileExist_service(),
                                    builder: (context, snapshot) {
                                      if (snapshot.connectionState == ConnectionState.done) {
                                        if (snapshot.data == true) {
                                          // If image file exists, display Image widget
                                          return Image.file(
                                            File("/data/data/com.mycompany.store/confirm_picture/"+FFAppState().address+"-"+widget.C["id"]+"-"+"送達照片-0"),
                                            width: MediaQuery.sizeOf(context).width * 0.9,
                                            height: MediaQuery.sizeOf(context).height * 0.2,
                                            fit: BoxFit.cover,
                                          );
                                        } else {
                                          // If image file doesn't exist, display CircularProgressIndicator
                                          return CircularProgressIndicator();
                                        }
                                      } else {
                                        // Loading indicator while checking file existence
                                        return CircularProgressIndicator();
                                      }
                                    },
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
class Items extends StatelessWidget {

  List? list;

  Items({this.list});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: list!.length,  //列表的數量
      itemBuilder: (ctx,i){    //列表的構建器
        return Padding(
          padding: EdgeInsetsDirectional.fromSTEB(
              0.0, 0.0, 0.0, 2.0),
          child: Container(
            width: MediaQuery.sizeOf(context).width * 1.0,
            decoration: BoxDecoration(
              color: FlutterFlowTheme.of(context)
                  .secondaryBackground,
              borderRadius:
              BorderRadius.circular(0.0),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.max,
              crossAxisAlignment:
              CrossAxisAlignment.start,
              children: [
                Padding(
                  padding:
                  EdgeInsetsDirectional.fromSTEB(0.0, 4.0, 0.0, 12.0),
                  child: Row(
                    mainAxisSize: MainAxisSize.max,
                    mainAxisAlignment:
                    MainAxisAlignment.start,
                    children: [
                      Column(
                        mainAxisSize: MainAxisSize.max,
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          AutoSizeText(
                            list![i]["orderID"],
                            style: FlutterFlowTheme.of(context).titleLarge.override(
                              fontFamily:
                              'Outfit',
                              fontSize: 20.0,
                            ),
                          ),
                        ],
                      ),
                      Expanded(
                        child: Column(
                          mainAxisSize:
                          MainAxisSize.max,
                          children: [
                            AutoSizeText(
                              'x'+list![i]["num"],
                              style: FlutterFlowTheme
                                  .of(context)
                                  .titleLarge
                                  .override(
                                fontFamily:
                                'Outfit',
                                fontSize: 20.0,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Column(
                        mainAxisSize:
                        MainAxisSize.max,
                        children: [
                          AutoSizeText(
                            list![i]["money"]+' ETH',
                            style:
                            FlutterFlowTheme.of(
                                context)
                                .titleLarge
                                .override(
                              fontFamily:
                              'Outfit',
                              fontSize: 20.0,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}