import 'package:auto_size_text/auto_size_text.dart';
import 'package:chewie/chewie.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class DetailPage extends StatefulWidget {
  final dynamic images;
  final String title;
  final String description;
  final dynamic videos;

  const DetailPage(
      {super.key,
      required this.images,
      required this.title,
      required this.description,
      required this.videos});

  @override
  State<DetailPage> createState() => _DetailPageState();
}

class _DetailPageState extends State<DetailPage> {
  final List<VideoPlayerController> _videoPlayerControllers = [];
  final List<ChewieController> _chewieControllers = [];
  bool _isVideoInitialized = false;

  @override
  void initState() {
    super.initState();
    if (widget.videos != null && widget.videos.isNotEmpty) {
      for (var video in widget.videos) {
        VideoPlayerController videoPlayerController =
            VideoPlayerController.asset(video);

        videoPlayerController.initialize().then((_) {
          setState(() {
            _isVideoInitialized = true;
            _chewieControllers.add(ChewieController(
              videoPlayerController: videoPlayerController,
              autoPlay: false,
              looping: true,
            ));
            _videoPlayerControllers.add(videoPlayerController);
          });
        });
      }
    }
  }

  @override
  void dispose() {
    for (var controller in _videoPlayerControllers) {
      controller.dispose();
    }
    for (var chewieController in _chewieControllers) {
      chewieController.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    List<String> imgList = widget.images is List
        ? List<String>.from(widget.images)
        : [widget.images];

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
          tag: widget.title,
          child: Material(
            color: Colors.transparent,
            child: AutoSizeText(
              widget.title,
              style: TextStyle(
                color: Colors.white,
                fontSize: 15.sp,
                fontWeight: FontWeight.w500,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
            ),
          ),
        ),
        iconTheme: IconThemeData(
          color: Colors.white,
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(16.0.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (imgList.length > 1)
                SizedBox(
                  child: GridView.builder(
                    shrinkWrap: true,
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 10,
                      mainAxisSpacing: 10,
                    ),
                    itemCount: imgList.length,
                    physics: NeverScrollableScrollPhysics(),
                    itemBuilder: (context, index) {
                      final imgUrl = imgList.elementAt(index);
                      return Image.asset(
                        height: 100.h,
                        imgUrl,
                        fit: BoxFit.contain,
                      );
                    },
                  ),
                )
              else
                SizedBox(
                    child: Image.asset(
                  imgList.elementAt(0),
                  height: 200.h,
                  width: double.infinity,
                  fit: BoxFit.contain,
                )),
              SizedBox(child: AutoSizeText(widget.description)),
              if(widget.videos.isNotEmpty) ...[
                Text(
                  "Video: ",
                  style: TextStyle(
                    fontSize: 20.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 15.h)
              ],

              widget.videos.isNotEmpty
                  ? _isVideoInitialized
                      ? Column(
                          children:
                              List.generate(_chewieControllers.length, (index) {
                            return Padding(
                              padding: EdgeInsets.symmetric(vertical: 10.h),
                              child: SizedBox(
                                  height: 200.h,
                                  child: Chewie(controller: _chewieControllers[index]),
                              )
                            );
                          }),
                        )
                      : Center(child: CircularProgressIndicator())
                  : Container(),
            ],
          ),
        ),
      ),
    );
  }
}
