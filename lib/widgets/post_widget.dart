import 'package:date_format/date_format.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../data/firebase_services/firestore.dart';
import '../util/image_cached.dart';
import 'comment.dart';
import 'like_animation.dart';

class PostWidget extends StatefulWidget {
  final snapshot;
  PostWidget(this.snapshot, {super.key});

  @override
  State<PostWidget> createState() => _PostWidgetState();
}

class _PostWidgetState extends State<PostWidget> {
  bool isAnimating = false;
  String user = '';
  final FirebaseAuth _auth = FirebaseAuth.instance;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    user = _auth.currentUser!.uid;
  }

  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 375.w,
          height: 54.h,
          color: Colors.white,
          child: Center(
            child: ListTile(
              leading: ClipOval(
                child: SizedBox(
                  width: 35.w,
                  height: 35.h,
                  child: CachedImage(widget.snapshot['profileImage']),
                ),
              ),
              title: Text(
                widget.snapshot['username'],
                style: TextStyle(fontSize: 13.sp),
              ),
              subtitle: Text(
                widget.snapshot['location'],
                style: TextStyle(fontSize: 11.sp),
              ),
              trailing: Icon(Icons.more_horiz),
            ),
          ),
        ),
        SizedBox(
          height: 5.h,
        ),
        GestureDetector(
          onDoubleTap: () {
            Firebase_Firestor().like(
                like: widget.snapshot['like'],
                type: 'posts',
                uid: user,
                postId: widget.snapshot['postId']);
            setState(() {
              isAnimating = true;
            });
          },
          child: Stack(alignment: Alignment.center, children: [
            Container(
              height: 375.h,
              width: 375.w,
              child: CachedImage(
                widget.snapshot['postImage'],
              ),
            ),
            AnimatedOpacity(
              duration: const Duration(milliseconds: 200),
              opacity: isAnimating ? 1 : 0,
              child: LikeAnimation(
                isAnimating: isAnimating,
                duration: const Duration(milliseconds: 400),
                iconlike: false,
                End: () {
                  setState(() {
                    isAnimating = false;
                  });
                },
                child: Icon(
                  Icons.favorite,
                  size: 100.w,
                  color: Colors.red,
                ),
              ),
            ),
          ]),
        ),
        Container(
          width: 375.w,
          color: Colors.white,
          child: Column(
            children: [
              SizedBox(height: 14.h),
              Row(
                children: [
                  SizedBox(width: 14.w),
                  LikeAnimation(
                    isAnimating: widget.snapshot['like'].contains(user),
                    child: IconButton(
                      onPressed: () {
                        Firebase_Firestor().like(
                            like: widget.snapshot['like'],
                            type: 'posts',
                            uid: user,
                            postId: widget.snapshot['postId']);
                      },
                      icon: Icon(
                        widget.snapshot['like'].contains(user)
                            ? Icons.favorite
                            : Icons.favorite_border,
                        color: widget.snapshot['like'].contains(user)
                            ? Colors.red
                            : Colors.black,
                        size: 24.w,
                      ),
                    ),
                  ),
                  SizedBox(width: 17.w),
                  GestureDetector(
                    onTap: () {
                      showModalBottomSheet(
                        context: context,
                        isScrollControlled: true, // To ensure the modal adjusts to the keyboard
                        backgroundColor: Colors.transparent,
                        builder: (context) {
                          return Padding(
                            padding: EdgeInsets.only(
                              bottom: MediaQuery.of(context).viewInsets.bottom, // Adjust for keyboard
                            ),
                            child: DraggableScrollableSheet(
                              maxChildSize: 0.9, // Adjust this based on the size you need
                              initialChildSize: 0.6, // Adjust starting size
                              minChildSize: 0.4, // Minimum size of the scrollable sheet
                              builder: (context, scrollController) {
                                return Comment(
                                  'posts',
                                  widget.snapshot['postId'],
                                );
                              },
                            ),
                          );
                        },
                      );
                    },
                    child: Image.asset(
                      'assets/images/comment.webp',
                      height: 28.h,
                    ),
                  ),

                  SizedBox(width: 17.w),
                  Image.asset(
                    'assets/images/send.jpg',
                    height: 28.h,
                  ),
                  const Spacer(),
                  Padding(
                    padding: EdgeInsets.only(right: 15.w),
                    child: Image.asset(
                      'assets/images/save.png',
                      height: 28.h,
                    ),
                  ),
                ],
              ),
              Align(
                alignment: Alignment.centerLeft,
                child: Padding(
                  padding:
                      EdgeInsets.only(left: 19.w, bottom: 5.h),
                  child: Text(
                    widget.snapshot['like'].length.toString(),
                    style: TextStyle(
                      fontSize: 13.sp,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 15.w),
                child: Row(
                  children: [
                    Text(
                widget.snapshot['username'] + ":  ",
                      style: TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 13.sp),
                    ),
                    Text(
                      widget.snapshot['caption'],
                      style: TextStyle(fontSize: 13.sp),
                    )
                  ],
                ),
              ),
              Align(
                alignment: Alignment.centerLeft,
                child: Padding(
                  padding: EdgeInsets.only(
                    left: 15.w,
                    top: 20.h,
                    bottom: 8.h,
                  ),
                  child: Text(
                    formatDate(widget.snapshot['time'].toDate(),
                        [yyyy, '-', mm, '-', dd]),
                    style: TextStyle(color: Colors.grey, fontSize: 11.sp),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
