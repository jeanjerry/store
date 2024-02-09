import 'dart:convert';
import 'dart:math';

import 'package:decimal/decimal.dart';

import '../home_1/home1_widget.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'home_model.dart';
export 'home_model.dart';
import 'package:http/http.dart' as http;
import '/main.dart';
import '/database/storeDB.dart'; // 引入自定義的 SQL 檔案

class HomeWidget extends StatefulWidget {
  const HomeWidget({Key? key}) : super(key: key);

  @override
  _HomeWidgetState createState() => _HomeWidgetState();
}

class _HomeWidgetState extends State<HomeWidget> {

  getStoreAvailableOrderID() async {   //獲取可接訂單
    var url = Uri.parse(ip+"contract/getStoreAvailableOrderID");

    final responce = await http.post(url,body: {

      "contractAddress": FFAppState().address,
      "storeWallet": FFAppState().account,

    });
    if (responce.statusCode == 200) {
      var data = json.decode(responce.body);//將json解碼為陣列形式
     // print("店家可接訂單:${data["availableOrderID"].toString()}");
      return data["availableOrderID"];
    }
  }

  getOrder(availableOrderID) async {
    var url = Uri.parse(ip+"contract/getOrder");

    final responce = await http.post(url,body: {

      "contractAddress": FFAppState().address,
      "wallet": FFAppState().account,
      "id": availableOrderID.toString(),

    });
    if (responce.statusCode == 200) {
      var data = json.decode(responce.body);//將json解碼為陣列形式
      return data;
    }
  }


  getOrderContent(id) async {
    var url = Uri.parse(ip+"contract/getOrderContent");

    final responce = await http.post(url,body: {

      "contractAddress": FFAppState().address,
      "wallet": FFAppState().account,
      "id": id,

    });
    if (responce.statusCode == 200) {
      var data = json.decode(responce.body);//將json解碼為陣列形式
      //print("訂單內容:${data["orderContent"].toString()}");
      return data["orderContent"];
    }
  }

/*orderList = await dbHelper.dbGetStores();
        List<String> myList =orderList[0]['consumer'].split(',');
        print(myList[1]);*///範例

  getStore() async {
    var url = Uri.parse(ip+"contract/getStore");

    final responce = await http.post(url,body: {

      "contractAddress": FFAppState().address,
      "wallet": FFAppState().account,

    });
    if (responce.statusCode == 200) {
      var data = json.decode(responce.body);//將json解碼為陣列形式
      return data;
    }
  }


  List<Map<String, dynamic>> orderList = []; // 訂單內容
  Future<List> getlist() async {
    await dbHelper.dbResetStores();// 重製訂單內容
    orderList.clear();
    List availableOrderID = await getStoreAvailableOrderID();
    if (availableOrderID != null) {
      print("店家的可接單號 ID 為: $availableOrderID");
      for(int i = 0; i < availableOrderID.length; i++){
        var ORDER = await getOrder(availableOrderID[i]);
        //var orderContent = await getOrderContent(availableOrderID[i]);  暫不需用
        Map<String, dynamic> A = {};//重要{}
        A['id']=availableOrderID[i];
        A['fee']=(Decimal.parse(ORDER["fee"]) / Decimal.parse('1e18')).toDouble().toString();
        A['consumer']=ORDER["consumer"].toString();
        A['consumer'] = A['consumer'].replaceAll(RegExp(r'^\[|\]$'), '');
        A['note'] = ORDER["note"];
        await dbHelper.dbInsertStore(A); // 將訂單內容插入資料庫
      }
    }
          var image = await getStore();  //設定那邊顯示資料庫的值
          FFAppState().storename = image["storeName"];
          FFAppState().storeaddress = image["storeAddress"];
          FFAppState().storephone = image["storePhone"];
          FFAppState().tag = image["storeTag"];
          FFAppState().email = image["storeEmail"];
          FFAppState().imagelink = image["storeImageLink"];

    orderList = await dbHelper.dbGetStores();
    //print(orderList);
    return orderList;
  }






  late HomeModel _model;
  late DBHelper dbHelper; // DBHelper 實例
  final scaffoldKey = GlobalKey<ScaffoldState>();
  @override
  void initState() {
    super.initState();
    dbHelper = DBHelper(); // 初始化 DBHelper
    _model = createModel(context, () => HomeModel());
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

    return GestureDetector(
      onTap: () => _model.unfocusNode.canRequestFocus
          ? FocusScope.of(context).requestFocus(_model.unfocusNode)
          : FocusScope.of(context).unfocus(),
      child: Scaffold(
        key: scaffoldKey,
        backgroundColor: FlutterFlowTheme.of(context).primaryBackground,
        appBar: AppBar(
          backgroundColor: FlutterFlowTheme.of(context).primaryBackground,
          automaticallyImplyLeading: false,
          title: Align(
            alignment: AlignmentDirectional(0.0, -1.0),
            child: Padding(
              padding: EdgeInsetsDirectional.fromSTEB(0.0, 0.0, 0.0, 30.0),
              child: AutoSizeText(
                'Blofood',
                textAlign: TextAlign.start,
                style: FlutterFlowTheme.of(context).displaySmall.override(
                      fontFamily: 'Outfit',
                      color: Color(0xFFF35E5E),
                    ),
              ),
            ),
          ),
          actions: [],
          centerTitle: false,
          elevation: 0.0,
        ),
        body: SafeArea(
          top: true,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.max,
              children: [
                Padding(
                  padding:
                      EdgeInsetsDirectional.fromSTEB(16.0, 10.0, 16.0, 0.0),
                  child: Row(
                    mainAxisSize: MainAxisSize.max,
                    children: [
                      Padding(
                        padding:
                            EdgeInsetsDirectional.fromSTEB(0.0, 0.0, 0.0, 10.0),
                        child: Text(
                          '可接受的餐點訂單',
                          style:
                              FlutterFlowTheme.of(context).labelMedium.override(
                                    fontFamily: 'Readex Pro',
                                    fontSize: 25.0,
                                    fontWeight: FontWeight.w600,
                                  ),
                        ),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: EdgeInsetsDirectional.fromSTEB(0.0, 10.0, 0.0, 0.0),
                  child: ListView(
                    padding: EdgeInsets.zero,
                    shrinkWrap: true,
                    scrollDirection: Axis.vertical,
                    children: [
                      Padding(
                        padding: EdgeInsetsDirectional.fromSTEB(
                            0.0, 0.0, 0.0, 12.0),
                        child:Container(
                          width: MediaQuery.sizeOf(context).width * 1.0,
                          height: MediaQuery.sizeOf(context).height * 1.0 ,
                          decoration: BoxDecoration(
                            color: Color(0xFFF1F4F8),
                            borderRadius: BorderRadius.circular(0.0),
                          ),
                          child:FutureBuilder<List>(
                            future: getlist(),
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
    //Widget divider1=Divider(color: Colors.blue, thickness: 3.0,);
    //Widget divider2=Divider(color: Colors.green,thickness: 3.0,);
    Widget divider0 = const Divider(
      color: Colors.red,
      thickness: 3,
    );
    Widget divider1 = const Divider(
      color: Colors.orange,
      thickness: 3,
    );
    Widget divider2 = Divider(
      color: Colors.yellow.shade600,
      thickness: 3,
    );
    Widget divider3 = const Divider(
      color: Colors.green,
      thickness: 3,
    );
    Widget divider4 = const Divider(
      color: Colors.blue,
      thickness: 3,
    );
    Widget divider5 = Divider(
      color: Colors.blue.shade900,
      thickness: 3,
    );
    Widget divider6 = const Divider(
      color: Colors.purple,
      thickness: 3,
    );
    Widget ChooseDivider(int index) {
      return index % 7 == 0
          ? divider0
          : index % 7 == 1
          ? divider1
          : index % 7 == 2
          ? divider2
          : index % 7 == 3
          ? divider3
          : index % 7 == 4
          ? divider4
          : index % 7 == 5
          ? divider5
          : divider6;
    }
    return ListView.separated(
      itemCount: list!.length,  //列表的數量
      itemBuilder: (ctx,i){//列表的構建器
        List<String> myList =list![i]['consumer'].split(',');
        return Container(
          width: MediaQuery.sizeOf(context).width * 1.0,
          child: InkWell(
            splashColor: Colors.transparent,
            focusColor: Colors.transparent,
            hoverColor: Colors.transparent,
            highlightColor: Colors.transparent,
            onTap: () async {
              Map<String, dynamic> A = await list![i];
              //print("a$A");  //測試用
              await Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => Home1Widget(A: A, ),
                ),
              );
              //context.pushNamed('home-1');
            },
            child: Column(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  width: MediaQuery.sizeOf(context).width * 1.0,
                  decoration: BoxDecoration(
                    color: Color(0xFFD6D4F9),
                    boxShadow: [
                      BoxShadow(
                        blurRadius: 4.0,
                        color: Color(0x33000000),
                        offset: Offset(2.0, 6.0),
                      ),
                    ],
                    borderRadius: BorderRadius.circular(14.0),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.max,
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Padding(
                        padding: EdgeInsetsDirectional.fromSTEB(10.0, 0.0, 10.0, 0.0),
                        child: Row(
                          mainAxisSize: MainAxisSize.max,
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Padding(
                              padding: EdgeInsetsDirectional.fromSTEB(0.0, 5.0, 0.0, 0.0),
                              child: AutoSizeText(
                                '單號 : ' + list![i]["id"],
                                style: FlutterFlowTheme.of(context).bodyMedium.override(
                                  fontFamily: 'Readex Pro',
                                  fontSize: 24.0,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                            Padding(
                              padding: EdgeInsetsDirectional.fromSTEB(160.0, 5.0, 0.0, 0.0),
                              child: AutoSizeText(
                                '查看更多',
                                style: FlutterFlowTheme.of(context).bodyMedium.override(
                                  fontFamily: 'Readex Pro',
                                  fontSize: 24.0,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                            Padding(
                              padding: EdgeInsetsDirectional.fromSTEB(0.0, 5.0, 0.0, 0.0),
                              child: Icon(
                                Icons.arrow_forward_ios,
                                color: FlutterFlowTheme.of(context).primaryText,
                                size: 24.0,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Padding(
                        padding: EdgeInsetsDirectional.fromSTEB(10.0, 10.0, 10.0, 0.0),
                        child: Row(
                          mainAxisSize: MainAxisSize.max,
                          children: [
                            AutoSizeText(
                              '外送費 : '+ list![i]["fee"]+' ETH',
                              style: FlutterFlowTheme.of(context).bodyMedium.override(
                                fontFamily: 'Readex Pro',
                                fontSize: 24.0,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Padding(
                        padding: EdgeInsetsDirectional.fromSTEB(10, 10, 10, 0),
                        child: Row(
                          mainAxisSize: MainAxisSize.max,
                          children: [
                            Container(
                              width: MediaQuery.sizeOf(context).width * 0.94,
                              height: MediaQuery.sizeOf(context).height * 0.09,
                              decoration: BoxDecoration(
                                color: Color(0xFFD6D4F9),
                              ),
                              child: AutoSizeText(
                                '地址 : ' + myList[1],
                                style: FlutterFlowTheme.of(context).bodyMedium.override(
                                  fontFamily: 'Readex Pro',
                                  fontSize: 24,
                                  fontWeight: FontWeight.w500,
                                ),
                                minFontSize: 1,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Padding(
                        padding: EdgeInsetsDirectional.fromSTEB(10.0, 10.0, 10.0, 0.0),
                        child: Row(
                          mainAxisSize: MainAxisSize.max,
                          children: [
                            AutoSizeText(
                              '備註 : ' + list![i]["note"],
                              style: FlutterFlowTheme.of(context).bodyMedium.override(
                                fontFamily: 'Readex Pro',
                                fontSize: 24.0,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
      separatorBuilder: (BuildContext context, int index) {
        return ChooseDivider(index);
      },
    );
  }
}

