import 'package:bitsdojo_window/bitsdojo_window.dart';
import 'package:dakara_weighbridge/Menu/menu_items.dart';
import 'package:dakara_weighbridge/Themes/app_themes.dart';
import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';

Future main() async {
  // Inisialisasi database
  WidgetsFlutterBinding.ensureInitialized();

  // Inisialisasi ukuran layar
  appWindow.size = const Size(1280, 768);
  await initializeDateFormatting(
    'id_ID',
    null,
  ).then((_) => runApp(const MyApp()));
  appWindow.show();
  doWhenWindowReady(() {
    final win = appWindow;
    const initialSize = Size(1280, 768);
    win.minSize = initialSize;
    win.size = initialSize;
    win.alignment = Alignment.center;
    win.title = "Dakara Weighbridge";
    win.show();
  });
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final menu = MenuItems();
  final PageController pageController = PageController();
  int currentIndex = 0;
  bool selectedItem = false;
  Color bgGrey = const Color.fromARGB(255, 228, 230, 232);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Dakara Weighbridge',
      theme: AppThemes.lightTheme,
      home: Scaffold(
        body: WindowBorder(
          color: bgGrey,
          child: Container(
            color: bgGrey,
            child: Column(
              children: [
                Expanded(
                  child: Row(
                    children: [
                      // SIDE BAR
                      Container(
                        width: 220,
                        margin: const EdgeInsets.fromLTRB(0, 0, 25, 0),
                        padding: const EdgeInsets.symmetric(horizontal: 25),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          boxShadow: [
                            BoxShadow(
                              color: const Color.fromARGB(255, 230, 230, 230),
                              blurRadius: 5,
                              spreadRadius: 0.1,
                              offset: Offset(1, 0),
                            ),
                          ],
                        ),
                        child: Material(
                          type: MaterialType.transparency,
                          child: Column(
                            children: [
                              Padding(
                                padding: const EdgeInsets.only(
                                  top: 60,
                                  bottom: 20,
                                ),
                                child: Icon(Icons.logo_dev_rounded, size: 40),
                              ),
                              Expanded(
                                child: ListView.separated(
                                  separatorBuilder:
                                      (context, index) => SizedBox(height: 3),
                                  itemCount: menu.items.length,
                                  itemBuilder: (context, index) {
                                    selectedItem = currentIndex == index;
                                    return ListTile(
                                      leading: Icon(menu.items[index].icon),
                                      title: Text(
                                        menu.items[index].title,
                                        style: TextStyle(fontSize: 14),
                                      ),
                                      hoverColor: Colors.amber[100],
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.all(
                                          Radius.circular(10),
                                        ),
                                      ),
                                      splashColor: Colors.amberAccent,
                                      tileColor:
                                          selectedItem
                                              ? Colors.amber
                                              : Colors.transparent,
                                      onTap: () {
                                        setState(() {
                                          currentIndex = index;
                                          pageController.jumpToPage(index);
                                        });
                                      },
                                    );
                                  },
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 25,
                                ),
                                child: Text("Version 1.0"),
                              ),
                            ],
                          ),
                        ),
                      ),

                      // MAIN PAGE
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.fromLTRB(5, 15, 20, 20),
                          color: bgGrey,
                          child: PageView.builder(
                            controller: pageController,
                            itemCount: menu.items.length,
                            itemBuilder:
                                (context, index) => menu.items[index].page,
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
