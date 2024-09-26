import 'dart:convert';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:darslik/main.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'DetailPage.dart';

class InstrumentDetailPage extends StatefulWidget {
  final String sectionName;
  final int sectionId;

  const InstrumentDetailPage(
      {super.key, required this.sectionName, required this.sectionId});

  @override
  State<InstrumentDetailPage> createState() => _InstrumentDetailPageState();
}

class _InstrumentDetailPageState extends State<InstrumentDetailPage> {
  List<dynamic> instruments = [];

  void initState() {
    super.initState();
    loadJsonData();
  }

  Future<void> loadJsonData() async {
    String response = '';

    if (widget.sectionId == 1) {
      response =
          await rootBundle.loadString('assets/json/ulchash_asboblari.json');
    } else if (widget.sectionId == 2) {
      response = await rootBundle
          .loadString('assets/json/metall_qirqish_asboblari.json');
    } else if (widget.sectionId == 3) {
      response = await rootBundle
          .loadString('assets/json/parchinlash_tunukasozlik_asboblari.json');
    } else if (widget.sectionId == 4) {
      response = await rootBundle
          .loadString('assets/json/kavsharlash_payvandlash_asboblari.json');
    } else if (widget.sectionId == 5) {
      response = await rootBundle
          .loadString('assets/json/metallga_ishlov_berish_stanoklari.json');
    } else if (widget.sectionId == 6) {
      response = await rootBundle.loadString('assets/json/pardozlash_asboblari.json');
    }

    if (response.isNotEmpty) {
      final List<dynamic> data = await json.decode(response);
      setState(() {
        instruments = data;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
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
        title: Hero(
          tag: widget.sectionId,
          child: Material(
            color: Colors.transparent,
            child: AutoSizeText(
              widget.sectionName,
              style: TextStyle(
                fontSize: 15.sp,
                fontWeight: FontWeight.w500,
                color: Colors.white
              ),
              maxLines: 2,
              minFontSize: 15,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
            ),
          ),
        ),
        iconTheme: IconThemeData(
          color: Colors.white,
        )
      ),
      body: instruments.isEmpty
          ? Center(child: CircularProgressIndicator())
          : AnimationLimiter(
              child: GridView.builder(
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                ),
                itemCount: instruments.length,
                itemBuilder: (context, index) {
                  final item = instruments[index];

                  final List<String> images = item["img"] is List
                      ? List<String>.from(item["img"])
                      : [item["img"]];

                  return InkWell(
                    onTap: () {
                      _onItemTap(context, instruments[index]);
                    },
                    child: AnimationConfiguration.staggeredGrid(
                      position: index,
                      columnCount: 2,
                      duration: Duration(milliseconds: 500),
                      child: ScaleAnimation(
                        child: FadeInAnimation(
                          delay: Duration(milliseconds: 275),
                          child: SafeArea(
                            child: Padding(
                              padding: EdgeInsets.symmetric(horizontal: 10.w),
                              child: Card(
                                elevation: 2,
                                color: Colors.white,
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Expanded(
                                      flex: 2,
                                      child: Image.asset(
                                        images[0],
                                        height: 100.h,
                                        width: double.infinity,
                                        fit: BoxFit.contain,
                                      ),
                                    ),
                                    Expanded(
                                      flex: 1,
                                      child: Padding(
                                        padding: EdgeInsets.fromLTRB(
                                            8.0.w, 2.0.w, 8.0.w, 2.0.w),
                                        child: Hero(
                                          tag: item['title'],
                                          child: Material(
                                            color: Colors.transparent,
                                            child: Text(
                                              item['title'],
                                              style: TextStyle(
                                                  fontWeight: FontWeight.bold),
                                              maxLines: 2,
                                              overflow: TextOverflow.ellipsis,
                                              textAlign: TextAlign.center,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
    );
  }

  void _onItemTap(BuildContext context, Map<String, dynamic> items) {
    Navigator.push(
        context,
        PageRouteBuilder(
            pageBuilder: (context, animation, secondaryAnimation) => DetailPage(
                  images: items['img'],
                  title: items['title'],
                  description: items['description'],
                  videos: items["videos"],
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
}
