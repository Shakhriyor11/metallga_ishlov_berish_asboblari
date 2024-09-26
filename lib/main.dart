import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'InstrumentDetailPage.dart';
import 'dart:convert';

void main() {
  runApp(
    ScreenUtilInit(
      designSize: const Size(360, 690),
      builder: (context, child) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          home: HomePage(),
        );
      },
    ),
  );
}

class HomePage extends StatefulWidget {
  HomePage({Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  double width = 0;
  bool myAnimation = false;
  List<dynamic> sections = [];

  @override
  void initState() {
    super.initState();
    loadJsonData();
  }

  Future<void> loadJsonData() async {
    final String response =
        await rootBundle.loadString('assets/json/sections.json');
    final data = await json.decode(response);
    setState(() {
      sections = data;
      WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
        setState(() {
          myAnimation = true;
        });
      });
    });
  }

  void _onItemTap(BuildContext context, Map<String, dynamic> section) {
    Navigator.push(
        context,
        PageRouteBuilder(
            pageBuilder: (context, animation, secondaryAnimation) =>
                InstrumentDetailPage(
                  sectionName: section['title'],
                  sectionId: section['id'],
                ),
            transitionsBuilder:
                (context, animation, secondaryAnimation, child) {
              const begin = Offset(1.0, 0.0);
              const end = Offset.zero;
              const curve = Curves.easeInOut;

              var tween =
                  Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
              var offsetAnimation = animation.drive(tween);

              return SlideTransition(
                position: offsetAnimation,
                child: child,
              );
            }));
  }

  @override
  Widget build(BuildContext context) {
    width = MediaQuery.of(context).size.width;
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.purple[200],
        bottomOpacity: 0,
        elevation: 10,
        shadowColor: Colors.black.withOpacity(0.5),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
            bottomLeft: Radius.circular(30.r),
            bottomRight: Radius.circular(30.r),
          ),
        ),
        title: AutoSizeText(
          'Metallarga ishlov berishda foydalaniladigan asbob-uskuna, moslama va stanoklarning ishlatilish sohasiga ko‘ra turlar',
          style: TextStyle(
            fontSize: 20.sp,
            fontWeight: FontWeight.w500,
            color: Colors.white,
          ),
          maxLines: 2,
          minFontSize: 14,
          overflow: TextOverflow.ellipsis,
          textAlign: TextAlign.center,
        ),
      ),
      body: sections.isEmpty
          ? Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: sections.length,
              shrinkWrap: true,
              itemBuilder: (context, index) {
                final section = sections[index];

                return AnimatedContainer(
                  duration: Duration(milliseconds: 500 + (index * 250)),
                  curve: Curves.easeIn,
                  transform:
                      Matrix4.translationValues(myAnimation ? 0 : width, 0, 0),
                  child: Card(
                    color: Colors.white,
                    margin: EdgeInsets.all(8.0.w),
                    elevation: 4.0,
                    child: ListTile(
                      title: Hero(
                          tag: section["id"],
                          child: Material(
                              color: Colors.transparent,
                              child: Text(
                                  section['title'],
                                style: TextStyle(fontSize: 16.sp),
                              ),),),
                      onTap: () => _onItemTap(context, section),
                    ),
                  ),
                );
              },
            ),
    );
  }
}
