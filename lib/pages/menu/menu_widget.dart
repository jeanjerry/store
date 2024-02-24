import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:store/google_api.dart';
import 'package:store/pages/menu_1/menu1_widget.dart';
import 'dart:convert';
import 'package:csv/csv.dart';
import 'dart:io';
import 'dart:ui';
import '/flutter_flow/flutter_flow_util.dart';

import '../../api.dart';

class MenuWidget extends StatefulWidget {
  const MenuWidget({super.key});

  @override
  State<MenuWidget> createState() => _MenuWidgetState();
}

class _MenuWidgetState extends State<MenuWidget> {
  String contractAddress = "";
  String account = "";
  String password = "";

  // 宣告csv檔
  List<List<dynamic>> csvData = [];
  List<List<List<dynamic>>> meal = [];
  List<List<List<dynamic>>> comboMeal = [];
  List<List<List<dynamic>>> option = [];
  Map<String, dynamic> mealClassification = {};
  Map<String, dynamic> comboMealClassification = {};
  Map<String, dynamic> optionClassification = {};

  bool isLoading = false;
  late String menuPath;

  @override
  void initState() {
    super.initState();
    initializeData(); // 呼叫自定義的初始化方法
  }

  Future<void> initializeData() async {
    setState(() {
      isLoading = true;
    });

    contractAddress = FFAppState().address;
    account = FFAppState().account;
    password = FFAppState().password;

    // 讀取csv檔
    menuPath = "/data/data/com.mycompany.store/menu";
    Directory menuDirectory = Directory(menuPath);

    if (!menuDirectory.existsSync()) {
      menuDirectory.createSync(recursive: true);
    } else {
      try {
        csvData = await readCsv('$menuPath/new_data.csv');
      } catch (e) {
        if (kDebugMode) {
          print(e);
        }
      }
    }

    csvProcess(csvData);
    mealClassification = csvClassification(meal);
    comboMealClassification = csvClassification(comboMeal);
    optionClassification = csvClassification(option);

    setState(() {
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    const titleStyle = TextStyle(
      fontSize: 40,
      fontWeight: FontWeight.w600,
    );

    return Scaffold(
      body: Stack(
        children: [
          ListView(
            children: [
              Padding(
                padding: const EdgeInsets.only(
                    left: 30, top: 30, right: 30, bottom: 120),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Stack(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Row(
                              children: [
                                Text("Blo",
                                    style: titleStyle.copyWith(
                                        color: Colors.red[900])),
                                Text("food",
                                    style: titleStyle.copyWith(
                                        color: Colors.black87)),
                              ],
                            ),
                          ],
                        ),
                        Container(
                          padding: const EdgeInsets.only(top: 6, right: 30),
                          alignment: Alignment.centerRight,
                          child: IconButton(
                            icon: const Icon(Icons.refresh),
                            onPressed: () async {
                              await refreshMenu();
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 30),
                    FilledButton(
                      onPressed: () async {
                        final result = await Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => Menu1Widget(
                                contractAddress: contractAddress,
                                account: account,
                                password: password),
                          ),
                        );
                        if (result == "true") {
                          await refreshMenu();
                        }
                      },
                      style: ButtonStyle(
                        minimumSize: MaterialStateProperty.all(
                            const Size(double.infinity, 60)), // 設定最小尺寸
                        maximumSize: MaterialStateProperty.all(
                            const Size(double.infinity, 60)), // 設定最大尺寸
                      ),
                      child: const Text('Edit menu', style: TextStyle(fontSize: 18)),
                    ),
                    const SizedBox(height: 30),
                    const Text(
                      "Current menu",
                      style: TextStyle(fontSize: 32),
                    ),
                    const SizedBox(height: 15),
                    if (csvData.isNotEmpty)
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildMenuCategory("Single", mealClassification,
                              Colors.red[100]!, Colors.red),
                          _buildMenuCategory("combo", comboMealClassification,
                              Colors.green[100]!, Colors.green),
                          _buildMenuCategory("Options", optionClassification,
                              Colors.blue[100]!, Colors.blue),
                        ],
                      ),
                    if (csvData.isEmpty && !isLoading)
                      const Center(
                        child: Text("Unable to read store menu",
                            style: TextStyle(fontSize: 24, color: Colors.grey)),
                      ),
                  ],
                ),
              )
            ],
          ),
          if (isLoading)
            Stack(
              children: [
                SizedBox(
                  // 背景模糊
                  width: MediaQuery.of(context).size.width,
                  height: MediaQuery.of(context).size.height,
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 7, sigmaY: 7),
                    child: Container(
                      color: Colors.black.withOpacity(0),
                    ),
                  ),
                ),
                const Center(child: CircularProgressIndicator()),
                // 中央的旋轉 loading 圖示
              ],
            ),
        ],
      ),
    );
  }

  Widget _buildMenuCategory(
      String categoryName,
      Map<String, dynamic> categoryClassification,
      Color cardColor,
      Color splashColor) {
    if (kDebugMode) {
      print("categoryName: $categoryName");
      print("categoryClassification: $categoryClassification");
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          categoryName,
          style: const TextStyle(fontSize: 24),
        ),
        const SizedBox(height: 15),
        Padding(
          padding: const EdgeInsets.only(left: 6),
          child: ListView.builder(
            itemCount: categoryClassification.length,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemBuilder: (context, index) {
              return _buildCategoryItem(categoryClassification, index,
                  cardColor, splashColor, categoryName);
            },
          ),
        ),
        const SizedBox(height: 15),
      ],
    );
  }

  Widget _buildCategoryItem(Map<String, dynamic> categoryClassification,
      int index, Color cardColor, Color splashColor, String categoryName) {
    String key = categoryClassification.keys.toList()[index];
    List<dynamic> categoryItems = categoryClassification[key];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (key != "")
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const SizedBox(width: 6),
                  Text(
                    key,
                    style: const TextStyle(fontSize: 20),
                  ),
                ],
              ),
              const SizedBox(height: 15),
            ],
          ),
        ListView.builder(
          itemCount: categoryItems.length,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemBuilder: (context, index2) {
            return _buildMenuCard(
                categoryItems[index2], cardColor, splashColor);
          },
        ),
      ],
    );
  }

  Widget _buildMenuCard(
      List<List<dynamic>> menu, Color cardColor, Color splashColor) {
    return Card(
      color: cardColor,
      clipBehavior: Clip.hardEdge,
      child: InkWell(
        splashColor: splashColor,
        onTap: () {
          //   彈出bottom-sheet
          showModalBottomSheet(
            context: context,
            builder: (context) {
              return StatefulBuilder(
                builder:
                    (BuildContext context, StateSetter setStateBottomSheet) {
                  return ListView(
                    children: [
                      Column(
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(
                                left: 30, top: 60, right: 30, bottom: 60),
                            child: ListView.builder(
                              itemCount: menu.length,
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemBuilder: (context, index) {
                                return Column(children: [
                                  Row(
                                    children: [
                                      if (menu[index][6] != "")
                                        SizedBox(
                                            // 顯示圖片
                                            width: 60,
                                            height: 60,
                                            child: ClipRRect(
                                              borderRadius:
                                                  BorderRadius.circular(6.0),
                                              child: Image.file(
                                                File(
                                                    "$menuPath/${menu[index][6]}"),
                                                fit: BoxFit.cover,
                                              ),
                                            )),
                                      if (menu[index][6] != "")
                                        const SizedBox(
                                          width: 12,
                                        ),
                                      if (menu[index][6] != "")
                                        Expanded(
                                          child: Column(
                                            children: [
                                              if (menu[index][4] == "")
                                                AutoSizeText(
                                                  menu[index][3],
                                                  textAlign: TextAlign.left,
                                                  style: const TextStyle(
                                                      fontSize: 16),
                                                ),
                                              if (menu[index][4] != "")
                                                AutoSizeText(
                                                  "${menu[index][3]}　${menu[index][4]}",
                                                  textAlign: TextAlign.left,
                                                  style: const TextStyle(
                                                      fontSize: 16),
                                                ),
                                              AutoSizeText(
                                                "${menu[index][5].toString()} ETH",
                                                textAlign: TextAlign.center,
                                                style: const TextStyle(
                                                    fontSize: 16),
                                              ),
                                            ],
                                          ),
                                        ),
                                      if (menu[index][6] == "")
                                        Expanded(
                                          child: AutoSizeText(
                                            "${menu[index][3]}　${menu[index][4]}",
                                            textAlign: TextAlign.center,
                                            style:
                                                const TextStyle(fontSize: 16),
                                          ),
                                        ),
                                      if (menu[index][6] == "")
                                        Expanded(
                                          child: AutoSizeText(
                                            "${menu[index][5].toString()} ETH",
                                            textAlign: TextAlign.center,
                                            style:
                                                const TextStyle(fontSize: 16),
                                          ),
                                        ),
                                    ],
                                  ),
                                  const SizedBox(height: 15),
                                ]);
                              },
                            ),
                          ),
                        ],
                      )
                    ],
                  );
                },
              );
            },
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Row(
            children: [
              if (menu[0][6] != "")
                Row(
                  children: [
                    SizedBox(
                        // 顯示圖片
                        width: 60,
                        height: 60,
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(6.0),
                          child: Image.file(
                            File("$menuPath/${menu[0][6]}"),
                            fit: BoxFit.cover,
                          ),
                        )),
                    const SizedBox(
                      width: 12,
                    )
                  ],
                ),
              Expanded(
                child: AutoSizeText(
                  menu[0][3],
                  textAlign: TextAlign.left,
                  style: const TextStyle(fontSize: 16),
                ),
              ),
              Expanded(
                child: AutoSizeText(
                  "${menu[0][5].toString()} ETH",
                  textAlign: TextAlign.right,
                  style: const TextStyle(fontSize: 16),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  readCsv(csv) {
    final input = File(csv).openRead();
    return input
        .transform(utf8.decoder)
        .transform(const CsvToListConverter())
        .toList();
  }

  csvProcess(csvData) {
    for (int i = 0; i < csvData.length; i++) {
      if (csvData[i][0] == 1) {
        bool isExist = false;
        for (int j = 0; j < meal.length; j++) {
          if (csvData[i][3] == meal[j][0][3]) {
            setState(() {
              meal[j].add(csvData[i]);
            });
            isExist = true;
            break;
          }
        }
        if (!isExist) {
          setState(() {
            meal.add([csvData[i]]);
          });
        }
      } else if (csvData[i][0] == 2) {
        bool isExist = false;
        for (int j = 0; j < comboMeal.length; j++) {
          if (csvData[i][3] == comboMeal[j][0][3]) {
            setState(() {
              comboMeal[j].add(csvData[i]);
            });
            isExist = true;
            break;
          }
        }
        if (!isExist) {
          setState(() {
            comboMeal.add([csvData[i]]);
          });
        }
      } else if (csvData[i][0] == 3) {
        bool isExist = false;
        for (int j = 0; j < option.length; j++) {
          if (csvData[i][3] == option[j][0][3]) {
            setState(() {
              option[j].add(csvData[i]);
            });
            isExist = true;
            break;
          }
        }
        if (!isExist) {
          setState(() {
            option.add([csvData[i]]);
          });
        }
      }
    }
  }

  csvClassification(List<List<List<dynamic>>> data) {
    Map<String, dynamic> classification = {};
    classification[""] = [];
    for (int i = 0; i < data.length; i++) {
      if (classification.containsKey(data[i][0][1])) {
        classification[data[i][0][1]].add(data[i]);
      } else {
        classification[data[i][0][1]] = [data[i]];
      }
    }
    return classification;
  }

  refreshMenu() async {
    setState(() {
      isLoading = true;
    });

    var menuVersion = await getMenuVersion(contractAddress, account);

    Directory menuDirectory = Directory(menuPath);
    if (menuDirectory.existsSync()) {
      menuDirectory.deleteSync(recursive: true);
    }
    menuDirectory.createSync(recursive: true);

    var menuLink = await getMenu(contractAddress, account, menuVersion);
    if (kDebugMode) {
      print("menuLink: $menuLink");
    }

    try {
      await GoogleHelper.driveDownloadMenu(menuLink, menuPath);
    } catch (e) {
      if (kDebugMode) {
        print(e);
      }
    }
    // 清空資料
    csvData.clear();
    meal.clear();
    comboMeal.clear();
    option.clear();
    await initializeData();
    setState(() {
      isLoading = false;
    });
  }
}
