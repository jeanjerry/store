import 'dart:convert';
import 'dart:io';
import 'dart:ui';
import 'package:csv/csv.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class Menu1Widget extends StatefulWidget {
  const Menu1Widget({
    super.key,
  });

  @override
  State<Menu1Widget> createState() => _Menu1WidgetState();
}

class _Menu1WidgetState extends State<Menu1Widget> {
  bool isLoading = false;
  late String menuPath;
  // 宣告csv檔
  List<List<dynamic>> csvData = [];
  List<List<List<dynamic>>> meal = [];
  List<List<List<dynamic>>> comboMeal = [];
  List<List<List<dynamic>>> option = [];
  Map<String, dynamic> mealClassification = {};
  Map<String, dynamic> comboMealClassification = {};
  Map<String, dynamic> optionClassification = {};
  @override
  void initState() {
    super.initState();
    initializeData(); // 呼叫自定義的初始化方法
  }

  Future<void> initializeData() async {
    setState(() {
      isLoading = true;
    });
    // 讀取csv檔
    menuPath = "/data/data/com.mycompany.store/temp_menu";
    Directory menuDirectory = Directory(menuPath);

    if (!menuDirectory.existsSync()) {
      menuDirectory.createSync(recursive: true);
    } else {
      menuDirectory.deleteSync(recursive: true);
      menuDirectory.createSync(recursive: true);
    }

    Directory menuDirectory2 = Directory("/data/data/com.mycompany.store/menu");
    menuDirectory2.listSync().forEach((element) {
      File(element.path).copySync("$menuPath/${element.path.split("/").last}");
    });
    try {
      csvData = await readCsv('$menuPath/new_data.csv');
    } catch (e) {
      if (kDebugMode) {
        print(e);
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
    return Scaffold(
        appBar: AppBar(
          title: const Text("編輯菜單"),
        ),
        body: Stack(
          children: [
            ListView(
              children: [
                Padding(
                  padding: const EdgeInsets.only(
                      left: 30, top: 30, right: 30, bottom: 150),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildMenuCategory("單點", mealClassification,
                          Colors.red[100]!, Colors.red),
                      _buildMenuCategory("套餐", comboMealClassification,
                          Colors.green[100]!, Colors.green),
                      _buildMenuCategory("選項", optionClassification,
                          Colors.blue[100]!, Colors.blue),
                    ],
                  ),
                )
              ],
            ),
            Container(
                alignment: Alignment.bottomCenter,
                child: SizedBox(
                    width: MediaQuery.of(context).size.width,
                    height: 90,
                    child: ClipRect(
                      child: BackdropFilter(
                          filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
                          child: InkWell(
                            onTap: () async {},
                            splashColor: Colors.black,
                            child: Container(
                                color: Colors.black.withOpacity(0.7),
                                child: const Center(
                                  child: Text(
                                    "確認更改",
                                    style: TextStyle(
                                        fontSize: 24,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.white),
                                  ),
                                )),
                          )),
                    ))),
          ],
        ));
  }

  Widget _buildMenuCategory(
      String categoryName,
      Map<String, dynamic> categoryClassification,
      Color cardColor,
      Color splashColor) {
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
        ElevatedButton(
            onPressed: () {},
            child: Text("新增類別", style: TextStyle(color: Colors.blue))),
        const SizedBox(height: 15),
      ],
    );
  }

  Widget _buildCategoryItem(Map<String, dynamic> categoryClassification,
      int index, Color cardColor, Color splashColor, String categoryName) {
    String key = categoryClassification.keys.toList()[index];

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
                  const SizedBox(width: 18),
                  ElevatedButton(
                      onPressed: () {
                        if (categoryName == "單點") {
                          mealClassification.remove(key);
                        } else if (categoryName == "套餐") {
                          comboMealClassification.remove(key);
                        } else if (categoryName == "選項") {
                          optionClassification.remove(key);
                        }
                        setState(() {});
                      },
                      child: Text("刪除類別", style: TextStyle(color: Colors.red)))
                ],
              ),
              const SizedBox(height: 15),
            ],
          ),
        ListView.builder(
          itemCount: categoryClassification[key].length,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemBuilder: (context, index2) {
            return _buildMenuCard(categoryClassification, cardColor,
                splashColor, categoryName, key, index2);
          },
        ),
        Center(
          child: IconButton(
            onPressed: () {},
            icon: Icon(Icons.add_circle),
            color: Colors.blue,
          ),
        ),
      ],
    );
  }

  Widget _buildMenuCard(
      Map<String, dynamic> categoryClassification,
      Color cardColor,
      Color splashColor,
      String categoryName,
      String key,
      int index2) {
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
                      Padding(
                          padding: const EdgeInsets.only(
                              left: 30, top: 60, right: 30, bottom: 60),
                          child: Column(
                            children: [
                              ListView.builder(
                                itemCount: categoryClassification[key].length !=
                                        0
                                    ? categoryClassification[key][index2].length
                                    : 0,
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                itemBuilder: (context, index) {
                                  return Column(children: [
                                    Row(
                                      children: [
                                        if (categoryClassification[key][index2]
                                                [index][6] !=
                                            "")
                                          SizedBox(
                                              // 顯示圖片
                                              width: 60,
                                              height: 60,
                                              child: ClipRRect(
                                                borderRadius:
                                                    BorderRadius.circular(6.0),
                                                child: Image.file(
                                                  File(
                                                      "$menuPath/${categoryClassification[key][index2][index][6]}"),
                                                  fit: BoxFit.cover,
                                                ),
                                              )),
                                        if (categoryClassification[key][index2]
                                                [index][6] !=
                                            "")
                                          const SizedBox(
                                            width: 12,
                                          ),
                                        if (categoryClassification[key][index2]
                                                [index][6] !=
                                            "")
                                          Expanded(
                                            child: Column(
                                              children: [
                                                AutoSizeText(
                                                  "${categoryClassification[key][index2][index][3]}　${categoryClassification[key][index2][index][4]}",
                                                  textAlign: TextAlign.left,
                                                  style: const TextStyle(
                                                      fontSize: 16),
                                                ),
                                                AutoSizeText(
                                                  "${categoryClassification[key][index2][index][5].toString()} ETH",
                                                  textAlign: TextAlign.center,
                                                  style: const TextStyle(
                                                      fontSize: 16),
                                                ),
                                              ],
                                            ),
                                          ),
                                        if (categoryClassification[key][index2]
                                                [index][6] ==
                                            "")
                                          Expanded(
                                            child: AutoSizeText(
                                              "${categoryClassification[key][index2][index][3]}　${categoryClassification[key][index2][index][4]}",
                                              textAlign: TextAlign.center,
                                              style:
                                                  const TextStyle(fontSize: 16),
                                            ),
                                          ),
                                        if (categoryClassification[key][index2]
                                                [index][6] ==
                                            "")
                                          Expanded(
                                            child: AutoSizeText(
                                              "${categoryClassification[key][index2][index][5].toString()} ETH",
                                              textAlign: TextAlign.center,
                                              style:
                                                  const TextStyle(fontSize: 16),
                                            ),
                                          ),
                                        Center(
                                            child: IconButton(
                                                onPressed: () {},
                                                icon: Icon(Icons.edit_rounded),
                                                color: Colors.green)),
                                        Center(
                                          child: IconButton(
                                            onPressed: () {
                                              if (categoryName == "單點") {
                                                if (categoryClassification[key]
                                                            [index2]
                                                        .length ==
                                                    1) {
                                                  mealClassification[key]
                                                      .removeAt(index2);
                                                  Navigator.pop(context);
                                                } else {
                                                  mealClassification[key]
                                                          [index2]
                                                      .removeAt(index);
                                                }
                                                setStateBottomSheet(() {});
                                                setState(() {});
                                                if (kDebugMode) {
                                                  print(
                                                      "mealClassification: ${mealClassification}");
                                                }
                                              } else if (categoryName == "套餐") {
                                                if (categoryClassification[key]
                                                            [index2]
                                                        .length ==
                                                    1) {
                                                  comboMealClassification[key]
                                                      .removeAt(index2);
                                                  Navigator.pop(context);
                                                } else {
                                                  comboMealClassification[key]
                                                          [index2]
                                                      .removeAt(index);
                                                }
                                                setStateBottomSheet(() {});
                                                setState(() {});
                                                if (kDebugMode) {
                                                  print(
                                                      "comboMealClassification: ${comboMealClassification}");
                                                }
                                              } else if (categoryName == "選項") {
                                                if (categoryClassification[key]
                                                            [index2]
                                                        .length ==
                                                    1) {
                                                  optionClassification[key]
                                                      .removeAt(index2);
                                                  Navigator.pop(context);
                                                } else {
                                                  optionClassification[key]
                                                          [index2]
                                                      .removeAt(index);
                                                }
                                                setStateBottomSheet(() {});
                                                setState(() {});
                                                if (kDebugMode) {
                                                  print(
                                                      "optionClassification: ${optionClassification}");
                                                }
                                              }
                                              setState(() {});
                                              setStateBottomSheet(() {});
                                            },
                                            icon: Icon(Icons.remove_circle),
                                            color: Colors.red,
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 15),
                                  ]);
                                },
                              ),
                              IconButton(
                                  onPressed: () {},
                                  icon: Icon(Icons.add_circle),
                                  color: Colors.blue),
                            ],
                          )),
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
              if (categoryClassification[key][index2][0][6] != "")
                Row(
                  children: [
                    SizedBox(
                        // 顯示圖片
                        width: 60,
                        height: 60,
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(6.0),
                          child: Image.file(
                            File(
                                "$menuPath/${categoryClassification[key][index2][0][6]}"),
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
                  categoryClassification[key][index2][0][3],
                  textAlign: TextAlign.left,
                  style: const TextStyle(fontSize: 16),
                ),
              ),
              Expanded(
                child: AutoSizeText(
                  "${categoryClassification[key][index2][0][5].toString()} ETH",
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

  readCsv(csv) {
    final input = File(csv).openRead();
    return input
        .transform(utf8.decoder)
        .transform(const CsvToListConverter())
        .toList();
  }
}
