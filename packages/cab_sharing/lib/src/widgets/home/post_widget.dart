import 'package:cab_sharing/src/services/api.dart';
import 'package:cab_sharing/src/functions/snackbar.dart';
import 'package:cab_sharing/src/services/user_store.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cab_sharing/src/decorations/post_widget_style.dart';
import 'package:cab_sharing/src/models/post_model.dart';
import 'package:cab_sharing/src/screens/post_detail_page.dart';

class PostWidget extends StatefulWidget {
  final String colorCategory;
  final PostModel post;
  final Function deleteCallback;
  Map<String, dynamic>? userData;
  PostWidget(
      {Key? key,
      required this.post,
      required this.colorCategory,
      required this.deleteCallback,
      this.userData})
      : super(key: key);

  @override
  State<PostWidget> createState() => _PostWidgetState();
}

class _PostWidgetState extends State<PostWidget> {
  bool allowDelete = true;
  @override
  Widget build(BuildContext context) {
    bool myPost = (widget.colorCategory == "mypost");
    var commonStore = context.read<CommonStore>();
    print("YO COMMON=${commonStore.userData}");
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) {
            // print("Route mein ${context.read<CommonStore>()}");
            return Provider.value(
              value: commonStore,
              child: PostDetailPage(post: widget.post),
            );
          }),
        );
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: 16.0,
          vertical: 4.0,
        ),
        child: Container(
          height: 96.0,
          width: double.infinity,
          decoration:
              myPost ? kRowContainerDecorationMyPost : kRowContainerDecoration,
          child: Row(
            children: [
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(left: 16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(top: 16.0),
                        child: Text(
                          myPost ? widget.post.getDate() : widget.post.name,
                          style: myPost
                              ? kPostNameTextStyleMyPost
                              : kPostNameTextStyle,
                        ),
                      ),
                      Text(
                        widget.post.email,
                        style: myPost
                            ? kPostEmailTextStyleMyPost
                            : kPostEmailTextStyle,
                      ),
                      Padding(
                        padding: const EdgeInsets.only(top: 8.0),
                        child: Text(
                          widget.post.note.replaceAll("\n", " "),
                          style: myPost
                              ? kPostGetNoteTextStyleMyPost
                              : kPostGetNoteTextStyle,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(
                width: 105.0,
                child: Padding(
                  padding: const EdgeInsets.only(right: 16.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      myPost
                          ? GestureDetector(
                              onTap: allowDelete
                                  ? () async {
                                      Map<String, String> data = {};
                                      data['postId'] = widget.post.id;
                                      data['email'] = widget.userData!['email'];
                                      data['security-key'] =
                                          widget.userData!['security-key'];
                                      setState(() {
                                        allowDelete = false;
                                      });
                                      bool deleteSuccess =
                                          await APIService.deletePost(data);
                                      print("deleteSuccess = $deleteSuccess");
                                      if (deleteSuccess) {
                                        widget.deleteCallback();
                                      } else {
                                        if (!mounted) {
                                          return;
                                        }
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(getSnackbar(
                                                "An error occurred. Your post could not be deleted at this moment."));
                                        setState(() {
                                          allowDelete = true;
                                        });
                                      }
                                    }
                                  : () => {},
                              child: const Icon(Icons.delete_outline,
                                  color: Colors.black),
                            )
                          : const SizedBox(
                              height: 1,
                            ),
                      Padding(
                        padding: const EdgeInsets.only(
                          top: 4.0,
                          bottom: 4.0,
                        ),
                        child: Text(
                          widget.post.getTime(),
                          style: myPost
                              ? kPostTimeTextStyleMyPost
                              : kPostTimeTextStyle,
                        ),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Icon(
                            widget.post.from == 'Airport'
                                ? Icons.airplanemode_active_outlined
                                : widget.post.from == 'Railway Station'
                                    ? Icons.directions_railway
                                    : Icons.school,
                            size: 20,
                            color: myPost ? Colors.black : Colors.white,
                          ),
                          Icon(
                            Icons.arrow_right_alt,
                            size: 20,
                            color: myPost ? Colors.black : Colors.white,
                          ),
                          Icon(
                            widget.post.to == 'Airport'
                                ? Icons.airplanemode_active_outlined
                                : widget.post.to == 'Railway Station'
                                    ? Icons.directions_railway
                                    : Icons.school,
                            size: 20,
                            color: myPost ? Colors.black : Colors.white,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
