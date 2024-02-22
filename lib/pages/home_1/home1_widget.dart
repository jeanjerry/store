import 'dart:convert';

import 'package:decimal/decimal.dart';

import '../../database/storeDB.dart';
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
import 'home1_model.dart';
export 'home1_model.dart';
import 'package:http/http.dart' as http;
import '/main.dart';

class Home1Widget extends StatefulWidget {
  const Home1Widget({Key? key, required this.A}) : super(key: key);
  final Map<String, dynamic> A;
  @override
  _Home1WidgetState createState() => _Home1WidgetState();
}

class _Home1WidgetState extends State<Home1Widget> {
  final GlobalKey<_Home1WidgetState> _key = GlobalKey<_Home1WidgetState>();  // 讓那個future一直跳出錯誤的消失
  final FocusNode _focusNode = FocusNode();
  late DBHelper dbHelper; // DBHelper 實例

  getOrderContent() async {   //獲取訂單內容
    var url = Uri.parse(ip+"contract/getOrderContent");

    final responce = await http.post(url,body: {

      "contractAddress": FFAppState().address,
      "wallet": FFAppState().account,
      "id": widget.A["id"],

    });
    if (responce.statusCode == 200) {
      var data = json.decode(responce.body);//將json解碼為陣列形式
      //print("訂單內容:${data["orderContent"].toString()}");
      return data["orderContent"];
    }
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

  storeAcceptOrder_true() async {   //接受訂單
    var url = Uri.parse(ip+"contract/storeAcceptOrder");

    final responce = await http.post(url,body: {

      "contractAddress": FFAppState().address,
      "storeWallet": FFAppState().account,
      "storePassword": FFAppState().password,
      "id": widget.A["id"],
      "storeAccept": "true",

    });
    if (responce.statusCode == 200) {
      var data = json.decode(responce.body);//將json解碼為陣列形式
      print("接受訂單");
    }
  }

  storeAcceptOrder_false() async {   //拒絕訂單
    var url = Uri.parse(ip+"contract/storeAcceptOrder");

    final responce = await http.post(url,body: {

      "contractAddress": FFAppState().address,
      "storeWallet": FFAppState().account,
      "storePassword": FFAppState().password,
      "id": widget.A["id"],
      "storeAccept": "false",
    });
    if (responce.statusCode == 200) {
      var data = json.decode(responce.body);//將json解碼為陣列形式
      await context.pushNamed('home');
      print("拒絕訂單");
    }
  }


  List<Map<String, dynamic>> checkorderList = []; // 訂單內容
  Future<List> checkorder() async {      //把單號和店家合約放入資料庫checkorder
    List<String> myList =widget.A['consumer'].split(','); //把string 變成 list
    Map<String, dynamic> A = {};  //重要{}
    A['id']=widget.A['id'];
    A['fee']=widget.A["fee"];
    A['consumer_address']=myList[1];
    await dbHelper.dbInsertcheckorder(A); // 將訂單內容插入資料庫
    checkorderList = await dbHelper.dbGetcheckorder();
    await context.pushNamed('order');
    print(checkorderList);
    return checkorderList;
  }

  setPreparationTime(preparationTime) async {   //設定準備時間
    var url = Uri.parse(ip+"contract/setPreparationTime");

    final responce = await http.post(url,body: {

      "contractAddress": FFAppState().address,
      "storeWallet": FFAppState().account,
      "storePassword": FFAppState().password,
      "id": widget.A["id"],
      "preparationTime": preparationTime,
    });
    if (responce.statusCode == 200) {
      var data = json.decode(responce.body);//將json解碼為陣列形式
      print("準備時間已設好");
    }
  }


  String userInput = "";
  late Home1Model _model;

  final scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => Home1Model());
    dbHelper = DBHelper(); // 初始化 DBHelper
  }

  @override
  void dispose() {
    _model.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    List<String> myList =widget.A['consumer'].split(',');//列表的構建器
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
                      Container(
                        width: MediaQuery.sizeOf(context).width * 1.0,
                        height: MediaQuery.sizeOf(context).height * 0.36,
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
                                '單號 : '+widget.A['id'],
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
                                    width: 100.0,
                                    height: MediaQuery.sizeOf(context).height *
                                        0.04,
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
                                              widget.A['fee']+' ETH',
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
                                      '消費者地址 : '+ myList[1],
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
                                        widget.A['note'],
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
                            B['id']=widget.A['id'];
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
                      Row(
                        mainAxisSize: MainAxisSize.max,
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          Padding(
                            padding: EdgeInsetsDirectional.fromSTEB(
                                0.0, 10.0, 0.0, 0.0),
                            child: FFButtonWidget(
                              onPressed: () async {
                                await storeAcceptOrder_false();
                              },
                              text: '拒絕',
                              options: FFButtonOptions(
                                width: MediaQuery.sizeOf(context).width * 0.4,
                                height:
                                    MediaQuery.sizeOf(context).height * 0.06,
                                padding: EdgeInsets.all(0.0),
                                iconPadding: EdgeInsetsDirectional.fromSTEB(
                                    0.0, 0.0, 0.0, 0.0),
                                color: Color(0xFFFF6D6F),
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
                                borderRadius: BorderRadius.circular(50.0),
                                hoverColor:
                                    FlutterFlowTheme.of(context).accent1,
                                hoverBorderSide: BorderSide(
                                  color: FlutterFlowTheme.of(context).primary,
                                  width: 1.0,
                                ),
                                hoverTextColor:
                                    FlutterFlowTheme.of(context).primary,
                              ),
                            ),
                          ),
                          Padding(
                            padding: EdgeInsetsDirectional.fromSTEB(0.0, 10.0, 0.0, 0.0),
                            child: FFButtonWidget(
                              onPressed: () async {
                                await showDialog(
                                  context: context,
                                  builder: (BuildContext context) {
                                    String inputValue = '';
                                    return AlertDialog(
                                      title: Text('請填寫準備時間(分鐘)'),
                                      content: TextFormField(
                                        onChanged: (value) {
                                          inputValue = value;
                                        },
                                      ),
                                      actions: [
                                        ElevatedButton(
                                          onPressed: () async {
                                            // 在这里处理输入的值，可以将其保存到状态中或执行其他操作
                                            print('輸入的值為: $inputValue');
                                            Navigator.of(context).pop();
                                            await setPreparationTime(inputValue);
                                          },
                                          child: Text('確定'),
                                        ),
                                      ],
                                    );
                                  },
                                );
                                await storeAcceptOrder_true();
                                await checkorder();
                              },
                              text: '接受',
                              options: FFButtonOptions(
                                width: MediaQuery.sizeOf(context).width * 0.4,
                                height: MediaQuery.sizeOf(context).height * 0.06,
                                padding: EdgeInsets.all(0.0),
                                iconPadding: EdgeInsetsDirectional.fromSTEB(0.0, 0.0, 0.0, 0.0),
                                color: Color(0xFF77FD86),
                                textStyle: FlutterFlowTheme.of(context).titleLarge.override(
                                  fontFamily: 'Outfit',
                                  fontWeight: FontWeight.w600,
                                ),
                                elevation: 2.0,
                                borderSide: BorderSide(
                                  color: Colors.transparent,
                                  width: 1.0,
                                ),
                                borderRadius: BorderRadius.circular(50.0),
                                hoverColor: FlutterFlowTheme.of(context).accent1,
                                hoverBorderSide: BorderSide(
                                  color: FlutterFlowTheme.of(context).primary,
                                  width: 1.0,
                                ),
                                hoverTextColor: FlutterFlowTheme.of(context).primary,
                              ),
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