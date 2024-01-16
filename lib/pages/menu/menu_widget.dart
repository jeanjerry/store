import 'package:flutter/material.dart';
import 'package:store/pages/menu_1/menu1_widget.dart';

class MenuWidget extends StatefulWidget {
  const MenuWidget({super.key});

  @override
  State<MenuWidget> createState() => _MenuWidgetState();
}

class _MenuWidgetState extends State<MenuWidget> {
  @override
  void initState() {
    super.initState();
    initializeData(); // 呼叫自定義的初始化方法
  }

  Future<void> initializeData() async {}

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
                      ],
                    ),
                    const SizedBox(height: 30),
                    FilledButton(
                      onPressed: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => const Menu1Widget(),
                          ),
                        );
                      },
                      child: const Text("進入頁面測試"),
                    ),
                  ],
                ),
              )
            ],
          ),
        ],
      ),
    );
  }
}
