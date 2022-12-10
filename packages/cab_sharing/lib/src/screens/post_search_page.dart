import 'package:cab_sharing/cab_sharing.dart';
import 'package:cab_sharing/src/functions/snackbar.dart';
import 'package:cab_sharing/src/screens/search_screen.dart';
import 'package:cab_sharing/src/services/api.dart';
import 'package:cab_sharing/src/services/user_store.dart';
import 'package:cab_sharing/src/widgets/create_post_and_search/date_field.dart';
import 'package:cab_sharing/src/widgets/create_post_and_search/post_input_fields.dart';
import 'package:cab_sharing/src/widgets/create_post_and_search/time_field.dart';
import 'package:cab_sharing/src/widgets/create_post_and_search/to_from_fields.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../decorations/post_and_search_style.dart';
import '../functions/helpers.dart';
import '../widgets/create_post_and_search/align_button.dart';

class PostSearchPage extends StatefulWidget {
  final String category;
  const PostSearchPage({Key? key, required this.category}) : super(key: key);

  @override
  State<PostSearchPage> createState() => _PostSearchPageState();
}

class _PostSearchPageState extends State<PostSearchPage> {
  final TextEditingController phone = TextEditingController();
  final TextEditingController note = TextEditingController();
  final TextEditingController to = TextEditingController(text: "Airport");
  final TextEditingController from = TextEditingController(text: "Campus");
  final FixedExtentScrollController date = FixedExtentScrollController();
  final FixedExtentScrollController month = FixedExtentScrollController();
  final FixedExtentScrollController year = FixedExtentScrollController();
  final FixedExtentScrollController hours = FixedExtentScrollController();
  final FixedExtentScrollController min = FixedExtentScrollController();
  final  noteFieldKey = GlobalKey<FormState>();
  String? marginValue;

  @override
  Widget build(BuildContext context) {
    Map<String, String> userData = context.read<CommonStore>().userData;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromRGBO(27, 27, 29, 1),
        elevation: 0,
        leading: IconButton(
          onPressed: Navigator.of(context).pop,
          icon: const Icon(
            Icons.arrow_back_ios_outlined,
            color: Colors.white,
          ),
        ),
      ),
      backgroundColor: const Color.fromRGBO(27, 27, 29, 1),
      body: LayoutBuilder(
          builder: (BuildContext context, BoxConstraints viewportConstraints) {
        return SingleChildScrollView(
          child: ConstrainedBox(
            constraints:
                BoxConstraints(minHeight: viewportConstraints.maxHeight),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                DateField(
                  year: year,
                  date: date,
                  month: month,
                ),
                (widget.category == "post")
                    ? TimeField(hour: hours, min: min)
                    : Container(),
                ToFromField(to: to, from: from),
                (widget.category == 'post')
                    ? PostFields(
                        phoneController: phone,
                        noteController: note,
                        formKey: noteFieldKey,
                      )
                    : Container(),
                const SizedBox(
                  height: 20,
                ),
                GestureDetector(
                  onTap: () async {
                    noteFieldKey.currentState!.validate();
                    return;
                    var res = {};
                    Map<String, dynamic> data = {
                      'to': to.text,
                      'from': from.text,
                      'name': userData['name'],
                      'email': userData['email'],
                      'security-key': userData['security-key'],
                      'travelDateTime': timeHelper({
                        'date': date.selectedItem,
                        'month': month.selectedItem,
                        'year': year.selectedItem,
                        'hour': hours.selectedItem,
                        'min': min.selectedItem,
                      })
                    };
                    try {
                      if (widget.category == 'post') {
                        Map<String, dynamic> moreData = {
                          'note': note.text,
                          'margin': marginHelper(marginValue),
                        };
                        if (phone.text.isNotEmpty) {
                          moreData['phonenumber'] = phone.text;
                        }
                        res = await APIService.postTripData(
                            {...data, ...moreData});
                      } else {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => SearchScreen(
                                    userData: data,
                                  )),
                        );
                      }
                    } catch (e) {
                      print(e);
                      ScaffoldMessenger.of(context)
                          .showSnackBar(getSnackbar("An error occurred."));
                    }

                    if (widget.category == 'post') {
                      if (res['success']) {
                        if (!mounted) return;
                        ScaffoldMessenger.of(context)
                            .showSnackBar(getSnackbar("Post Uploaded"));
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => CabSharingScreen(
                                    userData: userData,
                                  )),
                        );
                      } else {
                        if (!mounted) return;
                        ScaffoldMessenger.of(context).showSnackBar(getSnackbar(
                            "An error occurred. Check your connection and try again"));
                      }
                    }
                  },
                  child: AlignButton(
                      text: (widget.category == "post")
                          ? "Create Post"
                          : "Search"),
                )
              ],
            ),
          ),
        );
      }),
    );
  }
}
