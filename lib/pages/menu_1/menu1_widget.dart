import 'dart:convert';
import 'dart:io';
import 'dart:ui';
import 'package:csv/csv.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:store/google_api.dart';
import 'package:store/api.dart';

class Menu1Widget extends StatefulWidget {
  const Menu1Widget({
    super.key,
    required this.contractAddress,
    required this.account,
    required this.password,
  });

  final String contractAddress;
  final String account;
  final String password;

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

    if (kDebugMode) {
      print("mealClassification: $mealClassification");
      print("comboMealClassification: $comboMealClassification");
      print("optionClassification: $optionClassification");
    }

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
                      _buildMenuCategory("Single Point", mealClassification,
                          Colors.red[100]!, Colors.red),
                      _buildMenuCategory("combo", comboMealClassification,
                          Colors.green[100]!, Colors.green),
                      _buildMenuCategory("Options", optionClassification,
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
                            onTap: () async {
                              setState(() {
                                isLoading = true;
                              });
                              if (kDebugMode) {
                                print(
                                    "mealClassification: $mealClassification");
                                print(
                                    "comboMealClassification: $comboMealClassification");
                                print(
                                    "optionClassification: $optionClassification");
                              }
                              List<List<dynamic>> csvData = [];
                              for (int i = 0;
                                  i < mealClassification.length;
                                  i++) {
                                for (int j = 0;
                                    j <
                                        mealClassification.values
                                            .toList()[i]
                                            .length;
                                    j++) {
                                  for (int k = 0;
                                      k <
                                          mealClassification.values
                                              .toList()[i][j]
                                              .length;
                                      k++) {
                                    csvData.add(mealClassification.values
                                        .toList()[i][j][k]);
                                  }
                                }
                              }
                              for (int i = 0;
                                  i < comboMealClassification.length;
                                  i++) {
                                for (int j = 0;
                                    j <
                                        comboMealClassification.values
                                            .toList()[i]
                                            .length;
                                    j++) {
                                  for (int k = 0;
                                      k <
                                          comboMealClassification.values
                                              .toList()[i][j]
                                              .length;
                                      k++) {
                                    csvData.add(comboMealClassification.values
                                        .toList()[i][j][k]);
                                  }
                                }
                              }
                              for (int i = 0;
                                  i < optionClassification.length;
                                  i++) {
                                for (int j = 0;
                                    j <
                                        optionClassification.values
                                            .toList()[i]
                                            .length;
                                    j++) {
                                  for (int k = 0;
                                      k <
                                          optionClassification.values
                                              .toList()[i][j]
                                              .length;
                                      k++) {
                                    csvData.add(optionClassification.values
                                        .toList()[i][j][k]);
                                  }
                                }
                              }

                              // 填入id
                              for (int i = 0; i < csvData.length; i++) {
                                csvData[i][2] = i.toString();
                              }

                              if (kDebugMode) {
                                print("csvData: $csvData");
                              }

                              // 將csvData寫入csv檔
                              final csvFile = File('$menuPath/new_data.csv');
                              String csv =
                                  const ListToCsvConverter().convert(csvData);
                              await csvFile.writeAsString(csv);

                              // 獲得當前菜單版本
                              String version = await getMenuVersion(
                                  widget.contractAddress, widget.account);

                              String parentID = await getMenu(
                                  widget.contractAddress, widget.account, "0");

                              // 將菜單上傳到google drive
                              var folderID = await GoogleHelper.driveUploadFolder(
                                  menuPath,
                                  parentID,
                                  "version ${(int.parse(version) + 1).toString()}");

                              if (kDebugMode) {
                                print("folderID: $folderID");
                              }

                              var status = await menuUpdate(
                                  widget.contractAddress,
                                  widget.account,
                                  widget.password,
                                  folderID);

                              if (kDebugMode) {
                                print("status: $status");
                              }

                              if (status == true) {
                                updateSuccessDialog();
                              } else {
                                updateFailDialog();
                              }
                              setState(() {
                                isLoading = false;
                              });
                            },
                            splashColor: Colors.black,
                            child: Container(
                                color: Colors.black.withOpacity(0.7),
                                child: const Center(
                                  child: Text(
                                    "Confirm changes",
                                    style: TextStyle(
                                        fontSize: 24,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.white),
                                  ),
                                )),
                          )),
                    ))),
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
            onPressed: () async {
              await addClassification(categoryName);
              setState(() {});
            },
            child: const Text("Add category", style: TextStyle(color: Colors.blue))),
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
                        removeClassification(categoryName, key);
                        setState(() {});
                      },
                      child: const Text("Delete category",
                          style: TextStyle(color: Colors.red)))
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
            onPressed: () async {
              await addFirstItem(categoryName, key);
              setState(() {});
            },
            icon: const Icon(Icons.add_circle),
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
    if (kDebugMode) {
      print("categoryClassification[key]: ${categoryClassification[key]}");
    }
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
                                itemCount: categoryClassification[key].length >
                                        index2
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
                                            onPressed: () {
                                              removeItem(
                                                  categoryName,
                                                  key,
                                                  index,
                                                  categoryClassification,
                                                  index2);
                                              setStateBottomSheet(() {});
                                            },
                                            icon:
                                                const Icon(Icons.remove_circle),
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
                                  onPressed: () async {
                                    await addItem(
                                        categoryName,
                                        key,
                                        index2,
                                        categoryClassification,
                                        setStateBottomSheet);
                                    setStateBottomSheet(() {});
                                  },
                                  icon: const Icon(Icons.add_circle),
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
      for (int j = 0; j < data[i].length; j++) {
        data[i][j][2] = "";
      }
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

  removeClassification(String categoryName, String key) {
    if (categoryName == "Single Point") {
      // 如果有照片，刪除照片
      for (int i = 0; i < mealClassification[key].length; i++) {
        for (int j = 0; j < mealClassification[key][i].length; j++) {
          if (mealClassification[key][i][j][6] != "") {
            File("$menuPath/${mealClassification[key][i][j][6]}").deleteSync();
          }
        }
      }
      mealClassification.remove(key);
    } else if (categoryName == "combo") {
      for (int i = 0; i < comboMealClassification[key].length; i++) {
        for (int j = 0; j < comboMealClassification[key][i].length; j++) {
          if (comboMealClassification[key][i][j][6] != "") {
            File("$menuPath/${comboMealClassification[key][i][j][6]}")
                .deleteSync();
          }
        }
      }
      comboMealClassification.remove(key);
    } else if (categoryName == "Options") {
      for (int i = 0; i < optionClassification[key].length; i++) {
        for (int j = 0; j < optionClassification[key][i].length; j++) {
          if (optionClassification[key][i][j][6] != "") {
            File("$menuPath/${optionClassification[key][i][j][6]}")
                .deleteSync();
          }
        }
      }
      optionClassification.remove(key);
    }
  }

  addClassification(String categoryName) {
    TextEditingController classificationName = TextEditingController();
    showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: const Text("Add category"),
            content: TextField(
              controller: classificationName,
              decoration:
                  const InputDecoration(hintText: "Please enter a category name", labelText: "classification name"),
            ),
            actions: [
              TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: const Text("Cancel")),
              TextButton(
                  onPressed: () {
                    if (categoryName == "Single Point") {
                      mealClassification[classificationName.text] = [];
                    } else if (categoryName == "combo") {
                      comboMealClassification[classificationName.text] = [];
                    } else if (categoryName == "Options") {
                      optionClassification[classificationName.text] = [];
                    }
                    Navigator.pop(context);
                  },
                  child: const Text("confirm"))
            ],
          );
        });
    setState(() {});
  }

  addFirstItem(String categoryName, String key) async {
    TextEditingController itemName = TextEditingController();
    TextEditingController itemOption = TextEditingController();
    TextEditingController itemPrice = TextEditingController();
    String imagePath = "";
    showDialog(
        context: context,
        builder: (context) {
          return StatefulBuilder(
              builder: (BuildContext context, StateSetter setDialogState) {
            return AlertDialog(
              title: const Text("Add new items"),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const SizedBox(
                      height: 15,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        if (imagePath != "")
                          SizedBox(
                              // 顯示圖片
                              width: 90,
                              height: 90,
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(6.0),
                                child: Image.file(
                                  File(imagePath),
                                  fit: BoxFit.cover,
                                ),
                              )),
                        if (imagePath != "")
                          const SizedBox(
                            width: 15,
                          ),
                        // 選取照片
                        ElevatedButton(
                            onPressed: () async {
                              imagePath = await pickImage();
                              setDialogState(() {});
                            },
                            child: const Text("Select photo")),
                      ],
                    ),
                    const SizedBox(height: 15),
                    // 輸入項目名稱
                    TextField(
                      controller: itemName,
                      decoration: const InputDecoration(
                          hintText: "Please enter project name", labelText: "project name"),
                    ),
                    // 輸入項目選項
                    TextField(
                      controller: itemOption,
                      decoration: const InputDecoration(
                          hintText: "Please enter project options", labelText: "Project options"),
                    ),
                    const SizedBox(height: 15),
                    // 輸入項目價格
                    TextField(
                      keyboardType:
                          const TextInputType.numberWithOptions(decimal: true),
                      onChanged: (value) {
                        if (value.startsWith("0") &&
                            value.length > 1 &&
                            value[1] != ".") {
                          // 如果輸入以0開頭且長度大於1，去掉開頭的0
                          value = value.substring(1);
                        }
                        if (!isValidDouble(value)) {
                          setDialogState(() {
                            itemPrice.text = "";
                          });
                        } else {
                          setDialogState(() {
                            itemPrice.text = value;
                          });
                        }
                      },
                      controller: itemPrice,
                      decoration: const InputDecoration(
                          hintText: "Please enter the item price", labelText: "Project price"),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: const Text("Cancel")),
                TextButton(
                    onPressed: () {
                      if (checkSameItemName(categoryName, key, itemName.text) ==
                          true) {
                        showDialog(
                            context: context,
                            builder: (context) {
                              return AlertDialog(
                                title: const Text("mistake"),
                                content: const Text("An existing project name cannot be entered"),
                                actions: [
                                  TextButton(
                                      onPressed: () {
                                        Navigator.pop(context);
                                      },
                                      child: const Text("confirm"))
                                ],
                              );
                            });
                      } else if (itemName.text == "") {
                        showDialog(
                            context: context,
                            builder: (context) {
                              return AlertDialog(
                                title: const Text("mistake"),
                                content: const Text("Please enter project name"),
                                actions: [
                                  TextButton(
                                      onPressed: () {
                                        Navigator.pop(context);
                                      },
                                      child: const Text("confirm"))
                                ],
                              );
                            });
                      } else if (itemPrice.text == "") {
                        showDialog(
                            context: context,
                            builder: (context) {
                              return AlertDialog(
                                title: const Text("mistake"),
                                content: const Text("Please enter the item price"),
                                actions: [
                                  TextButton(
                                      onPressed: () {
                                        Navigator.pop(context);
                                      },
                                      child: const Text("confirm"))
                                ],
                              );
                            });
                      } else {
                        // 如果有圖片，複製到指定位置並重新命名
                        String pictureName = "";
                        if (imagePath != "") {
                          String name = "";
                          if (itemOption.text == "") {
                            name = itemName.text;
                          } else {
                            name = "${itemName.text} ${itemOption.text}";
                          }
                          pictureName = name;
                          File(imagePath).copySync("$menuPath/$name");
                        }
                        // 將項目加入到對應的類別中
                        if (categoryName == "Single Point") {
                          setState(() {
                            mealClassification[key].add([
                              [
                                1, // 類別
                                key, // 單點類別
                                "",
                                itemName.text, // 單點名稱
                                itemOption.text, // 單點選項
                                itemPrice.text, // 單點價格
                                pictureName // 圖片名稱
                              ]
                            ]);
                          });
                        } else if (categoryName == "combo") {
                          setState(() {
                            comboMealClassification[key].add([
                              [
                                2, // 類別
                                key, // 套餐類別
                                "",
                                itemName.text, // 套餐名稱
                                itemOption.text, // 套餐選項
                                itemPrice.text, // 套餐價格
                                pictureName // 圖片名稱
                              ]
                            ]);
                          });
                        } else if (categoryName == "Options") {
                          setState(() {
                            optionClassification[key].add([
                              [
                                3, // 類別
                                key, // 選項類別
                                "",
                                itemName.text, // 選項名稱
                                itemOption.text, // 選項的選項
                                itemPrice.text, // 選項價格
                                pictureName // 圖片名稱
                              ]
                            ]);
                          });
                        }
                        Navigator.pop(context);
                      }
                    },
                    child: const Text("confirm"))
              ],
            );
          });
        });
  }

  addItem(
      String categoryName,
      String key,
      int index2,
      Map<String, dynamic> categoryClassification,
      StateSetter setStateBottomSheet) async {
    TextEditingController itemOption = TextEditingController();
    TextEditingController itemPrice = TextEditingController();
    String imagePath = "";
    showDialog(
        context: context,
        builder: (context) {
          return StatefulBuilder(
              builder: (BuildContext context, StateSetter setDialogState) {
            return AlertDialog(
              title: const Text("Add new items"),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const SizedBox(
                      height: 15,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        if (imagePath != "")
                          SizedBox(
                              // 顯示圖片
                              width: 90,
                              height: 90,
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(6.0),
                                child: Image.file(
                                  File(imagePath),
                                  fit: BoxFit.cover,
                                ),
                              )),
                        if (imagePath != "")
                          const SizedBox(
                            width: 15,
                          ),
                        // 選取照片
                        ElevatedButton(
                            onPressed: () async {
                              imagePath = await pickImage();
                              setDialogState(() {});
                            },
                            child: const Text("Select photo")),
                      ],
                    ),
                    const SizedBox(height: 15),
                    //顯示項目名稱
                    TextField(
                      controller: TextEditingController(
                          text: categoryClassification[key][index2][0][3]),
                      enabled: false,
                      decoration: const InputDecoration(
                          hintText: "Please enter project name", labelText: "project name"),
                    ),
                    // 輸入項目選項
                    TextField(
                      controller: itemOption,
                      decoration: const InputDecoration(
                          hintText: "Please enter project options", labelText: "Project options"),
                    ),
                    const SizedBox(height: 15),
                    // 輸入項目價格
                    TextField(
                      keyboardType:
                          const TextInputType.numberWithOptions(decimal: true),
                      onChanged: (text) {
                        if (text.startsWith("0") &&
                            text.length > 1 &&
                            text[1] != ".") {
                          // 如果輸入以0開頭且長度大於1，去掉開頭的0
                          text = text.substring(1);
                        }
                        if (!isValidDouble(text)) {
                          setDialogState(() {
                            itemPrice.text = "";
                          });
                        } else {
                          setDialogState(() {
                            itemPrice.text = text;
                          });
                        }
                      },
                      controller: itemPrice,
                      decoration: const InputDecoration(
                          hintText: "Please enter the item price", labelText: "Project price"),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: const Text("Cancel")),
                TextButton(
                    onPressed: () {
                      if (checkSameOptionName(
                              categoryName, key, index2, itemOption.text) ==
                          true) {
                        showDialog(
                            context: context,
                            builder: (context) {
                              return AlertDialog(
                                title: const Text("mistake"),
                                content: const Text("An existing project name cannot be entered"),
                                actions: [
                                  TextButton(
                                      onPressed: () {
                                        Navigator.pop(context);
                                      },
                                      child: const Text("confirm"))
                                ],
                              );
                            });
                      } else if (itemOption.text == "") {
                        showDialog(
                            context: context,
                            builder: (context) {
                              return AlertDialog(
                                title: const Text("mistake"),
                                content: const Text("Please enter project options"),
                                actions: [
                                  TextButton(
                                      onPressed: () {
                                        Navigator.pop(context);
                                      },
                                      child: const Text("confirm"))
                                ],
                              );
                            });
                      } else if (itemPrice.text == "") {
                        showDialog(
                            context: context,
                            builder: (context) {
                              return AlertDialog(
                                title: const Text("mistake"),
                                content: const Text("Please enter the item price"),
                                actions: [
                                  TextButton(
                                      onPressed: () {
                                        Navigator.pop(context);
                                      },
                                      child: const Text("confirm"))
                                ],
                              );
                            });
                      } else {
                        // 如果有圖片，複製到指定位置並重新命名
                        var pictureName = "";
                        if (imagePath != "") {
                          pictureName =
                              "${categoryClassification[key][index2][0][3]} ${itemOption.text}";
                          File(imagePath).copySync(
                              "$menuPath/${categoryClassification[key][index2][0][3]} ${itemOption.text}");
                        }
                        // 將項目加入到對應的類別中
                        if (categoryName == "Single Point") {
                          setStateBottomSheet(
                            () {
                              mealClassification[key][index2].add([
                                1.toString(), // 類別
                                key.toString(), // 單點類別
                                "",
                                mealClassification[key][index2][0][3]
                                    .toString(), // 單點名稱
                                itemOption.text, // 單點選項
                                itemPrice.text, // 單點價格
                                pictureName.toString() // 圖片名稱
                              ]);
                            },
                          );
                        } else if (categoryName == "combo") {
                          setStateBottomSheet(() {
                            comboMealClassification[key][index2].add([
                              2.toString(), // 類別
                              key.toString(), // 套餐類別
                              "",
                              comboMealClassification[key][index2][0][3]
                                  .toString(), // 套餐名稱
                              itemOption.text, // 套餐選項
                              itemPrice.text, // 套餐價格
                              pictureName.toString() // 圖片名稱
                            ]);
                          });
                        } else if (categoryName == "Options") {
                          setStateBottomSheet(() {
                            optionClassification[key][index2].add([
                              3.toString(), // 類別
                              key.toString(), // 選項類別
                              "",
                              optionClassification[key][index2][0][3]
                                  .toString(), // 選項名稱
                              itemOption.text, // 選項的選項
                              itemPrice.text, // 選項價格
                              pictureName.toString() // 圖片名稱
                            ]);
                          });
                        }
                        Navigator.pop(context);
                      }
                    },
                    child: const Text("confirm"))
              ],
            );
          });
        });
  }

  removeItem(String categoryName, String key, int index,
      Map<String, dynamic> categoryClassification, int index2) {
    if (categoryClassification[key][index2][index][6] != "") {
      File("$menuPath/${categoryClassification[key][index2][index][6]}")
          .deleteSync();
    }
    if (categoryName == "Single Point") {
      if (categoryClassification[key][index2].length == 1) {
        mealClassification[key].removeAt(index2);

        Navigator.pop(context);
      } else {
        mealClassification[key][index2].removeAt(index);
      }
      if (kDebugMode) {
        print("mealClassification: $mealClassification");
      }
    } else if (categoryName == "combo") {
      if (categoryClassification[key][index2].length == 1) {
        comboMealClassification[key].removeAt(index2);

        Navigator.pop(context);
      } else {
        comboMealClassification[key][index2].removeAt(index);
      }
      if (kDebugMode) {
        print("comboMealClassification: $comboMealClassification");
      }
    } else if (categoryName == "Options") {
      if (categoryClassification[key][index2].length == 1) {
        optionClassification[key].removeAt(index2);

        Navigator.pop(context);
      } else {
        optionClassification[key][index2].removeAt(index);
      }
      if (kDebugMode) {
        print("optionClassification: $optionClassification");
      }
    }
    setState(() {});
  }

  checkSameItemName(String categoryName, String key, String value) {
    // 不得輸入已有的項目名稱
    if (categoryName == "Single Point") {
      for (int i = 0; i < mealClassification[key].length; i++) {
        if (value == mealClassification[key][i][0][3]) {
          return true;
        }
      }
    } else if (categoryName == "combo") {
      for (int i = 0; i < comboMealClassification[key].length; i++) {
        if (value == comboMealClassification[key][i][0][3]) {
          return true;
        }
      }
    } else if (categoryName == "Options") {
      for (int i = 0; i < optionClassification[key].length; i++) {
        if (value == optionClassification[key][i][0][3]) {
          return true;
        }
      }
    }
    return false;
  }

  checkSameOptionName(
      String categoryName, String key, int index2, String value) {
    // 不得輸入已有的項目名稱
    if (categoryName == "Single Point") {
      for (int i = 0; i < mealClassification[key][index2].length; i++) {
        if (value == mealClassification[key][index2][i][4]) {
          return true;
        }
      }
    } else if (categoryName == "combo") {
      for (int i = 0; i < comboMealClassification[key][index2].length; i++) {
        if (value == comboMealClassification[key][index2][i][4]) {
          return true;
        }
      }
    } else if (categoryName == "Options") {
      for (int i = 0; i < optionClassification[key][index2].length; i++) {
        if (value == optionClassification[key][index2][i][4]) {
          return true;
        }
      }
    }
    return false;
  }

  bool isValidDouble(String value) {
    try {
      double.parse(value);
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<String> pickImage() async {
    final pickedFile =
        await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      return pickedFile.path;
    } else {
      return "";
    }
  }

  updateSuccessDialog() {
    showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: const Text("update completed"),
            content: const Text("Menu updated successfully"),
            actions: [
              TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                    Navigator.pop(context, "true");
                  },
                  child: const Text("confirm"))
            ],
          );
        });
  }

  updateFailDialog() {
    showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: const Text("Update failed"),
            content: const Text("Menu update failed"),
            actions: [
              TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: const Text("confirm"))
            ],
          );
        });
  }
}
