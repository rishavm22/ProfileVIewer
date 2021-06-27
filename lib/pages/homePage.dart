import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:lazy_load_scrollview/lazy_load_scrollview.dart';
import 'package:profile_viewer/provider/listFilterProvider.dart';
import 'package:profile_viewer/provider/profileFilterProvider.dart';
import 'package:progress_indicators/progress_indicators.dart';
import 'package:provider/provider.dart';

class HomePage extends StatefulWidget {
  static String id = 'home';
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final _categoryFormKey = GlobalKey<FormBuilderState>();
  List<String> items = new List.generate(100, (index) => 'Hello $index');
  final CollectionReference ref = FirebaseFirestore.instance.collection('users');
  bool isLoading=false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Profile Viewer'),
      ),
      body: Center(
        child: SingleChildScrollView(
          child: Container(
            color: Color(0xffc9e1ff),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Container(
                  child: Consumer<ProfileFilterProvider>(
                    builder: (context, data, child) {
                      return filterForm(data);
                    },
                  ),
                ),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 50),
                  child: Consumer<ListFilterProvider>(
                      builder: (context, data, child) {
                    return listData(data);
                  }),
                ),
                isLoading?JumpingDotsProgressIndicator():Container(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget filterForm(ProfileFilterProvider data) {
    return FormBuilder(
      key: _categoryFormKey,
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        child: Column(
          children: [
            FormBuilderFilterChip(
              name: 'filter',
              disabledColor: Colors.white,
              selectedColor: Colors.blue.shade200,
              selectedShadowColor: Colors.blueGrey,
              spacing: MediaQuery.of(context).size.width / 1.8,
              onChanged: (v) {
                if (_categoryFormKey.currentState != null &&
                    _categoryFormKey.currentState!.fields['filter'] != null) {
                  context.read<ProfileFilterProvider>().setFilterStatus(true);
                  List<String> type =
                      _categoryFormKey.currentState!.fields['filter']!.value;
                  context.read<ProfileFilterProvider>().setFilterBy(type);
                  if (!type.contains('Age'))
                    context
                        .read<ListFilterProvider>()
                        .setAgeLimit(RangeValues(18, 60));
                  if (!type.contains('Interest'))
                    context.read<ListFilterProvider>().setInterest('');
                }
              },
              decoration: InputDecoration(
                labelText: 'Filter By',
                labelStyle: TextStyle(
                  color: Color(0xFF020663),
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                ),
              ),
              options: [
                FormBuilderFieldOption(
                  value: 'Age',
                  child: Text('Age'),
                ),
                FormBuilderFieldOption(
                  value: 'Interest',
                  child: Text('Interest'),
                ),
              ],
            ),
            if (data.getFilterStatus)
              if (data.getFilterBy.contains('Interest'))
                FormBuilderChoiceChip(
                  name: 'interests',
                  disabledColor: Colors.white,
                  selectedColor: Colors.blue.shade200,
                  selectedShadowColor: Colors.blueGrey,
                  labelStyle: TextStyle(color: Colors.black),
                  onChanged: (v) {
                    String value;
                    (v != null) ? value = v.toString() : value = '';
                    context.read<ListFilterProvider>().setInterest(value);
                  },
                  spacing: MediaQuery.of(context).size.width / 5,
                  decoration: InputDecoration(
                    labelText: 'Interests By',
                    labelStyle: TextStyle(
                      color: Color(0xFF020663),
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  options: [
                    FormBuilderFieldOption(
                      value: 'one',
                      child: Text('Type A'),
                    ),
                    FormBuilderFieldOption(
                      value: 'two',
                      child: Text('Type B'),
                    ),
                    FormBuilderFieldOption(
                      value: 'three',
                      child: Text('Type C'),
                    ),
                  ],
                ),
            if (data.getFilterStatus)
              if (data.getFilterBy.contains('Age'))
                FormBuilderRangeSlider(
                  name: 'age',
                  onChanged: (v) {
                    context.read<ListFilterProvider>().setAgeLimit(v!);
                  },
                  min: 18,
                  max: 60,
                  initialValue: RangeValues(18, 60),
                  divisions: 21,
                  activeColor: Colors.red,
                  inactiveColor: Colors.pink[100],
                  decoration: const InputDecoration(
                    labelText: 'Age Limit',
                    labelStyle: TextStyle(
                      color: Color(0xFF020663),
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
          ],
        ),
      ),
    );
  }

  Widget listData(ListFilterProvider data) {
    Stream<QuerySnapshot> queryStream = ref.limit(data.getListLimit).snapshots();
    if ((data.getAgeLimit.start != 18 ||
        data.getAgeLimit.end != 60) &&
        data.getInterest.isNotEmpty) {
      queryStream =
          ref.limit(data.getListLimit).where('interest', arrayContains: data.getInterest).snapshots();
      return getListWithAgeLimit(queryStream, data);
    }
    if (data.getAgeLimit.start != 18.0 || data.getAgeLimit.end != 60.0) {
      queryStream = ref.snapshots();
      return getListWithAgeLimit(queryStream, data);
    }
    if (data.getInterest.isNotEmpty)
      queryStream =
          ref.limit(data.getListLimit).where('interest', arrayContains: data.getInterest).snapshots();
    List<Widget> profileList;
    return Container(
      height: MediaQuery.of(context).size.height - 200,
      child: StreamBuilder<QuerySnapshot>(
        stream: queryStream,
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return CircularProgressIndicator();
          }
          profileList = snapshot.data!.docs
              .map(
                (doc) => profileCard(
                  doc['name'],
                  doc['imageUrl'],
                  doc['age'],
                  doc['interest'],
                ),
              )
              .toList();
          return Container(
            color: Colors.white,
            child: LazyLoadScrollView(
              onEndOfPage: () {
                Future.delayed(Duration(milliseconds: 800), () {
                  data.increaseListLimit(2);
                });
              },
              child: ListView(
                children: profileList,
              ),
            ),
          );
        },
      ),
    );
  }

  Widget profileCard(
    String userName,
    String imageUrl,
    int age,
    List<dynamic> interest,
  ) {
    return Card(
      clipBehavior: Clip.antiAlias,
      shadowColor: Colors.grey.shade900,
      elevation: 6.0,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 5.0, vertical: 5.0),
        child: Column(
          children: <Widget>[
            Container(
              color: Color(0xFF020663),
              child: Column(
                children: [
                  SizedBox(
                    height: 10,
                  ),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Center(
                          child: CircleAvatar(
                            backgroundImage: imageUrl.isNotEmpty
                                ? NetworkImage(imageUrl)
                                : NetworkImage(
                                    "https://st3.depositphotos.com/15648834/17930/v/600/"
                                    "depositphotos_179308454-stock-illustration-"
                                    "unknown-person-silhouette-glasses-profile.jpg",
                                  ),
                            radius: 30.0,
                          ),
                        ),
                      ),
                      Expanded(
                        child: Column(
                          children: [
                            Text(
                              'Name ' + userName,
                              style: TextStyle(
                                fontSize: 16.0,
                                color: Colors.white,
                              ),
                            ),
                            Text(
                              'Age ' + age.toString(),
                              style: TextStyle(
                                fontSize: 16.0,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  SizedBox(
                    height: 10,
                  ),
                ],
              ),
            ),
            SizedBox(
              height: 4.0,
            ),
            Center(
              child: Text(
                'Interest',
                style: TextStyle(
                  fontSize: 20,
                  color: Color(0xFF020663),
                ),
              ),
            ),
            SizedBox(
              height: 4.0,
            ),
            (interest.length > 0)
                ? Center(
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        for (var i = 0; i < interest.length; i++)
                          Expanded(
                            child: Column(
                              children: [
                                Text(
                                  interest[i],
                                  style: TextStyle(
                                    color: Color(0xff195de5),
                                    fontSize: 16.0,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                SizedBox(
                                  height: 5.0,
                                ),
                              ],
                            ),
                          ),
                      ],
                    ),
                  )
                : Row()
          ],
        ),
      ),
    );
  }

  Widget getListWithAgeLimit(Stream<QuerySnapshot<Object?>> queryStream, ListFilterProvider data) {
    return Container(
      height: MediaQuery.of(context).size.height - 200,
      child: Scrollbar(
        child: StreamBuilder<QuerySnapshot>(
          stream: queryStream,
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return CircularProgressIndicator();
            }
            final List<Widget> profileList = snapshot.data!.docs.map((doc) {
              return (doc['age'] >= data.getAgeLimit.start.toInt() &&
                  doc['age'] <= data.getAgeLimit.end.toInt())
                  ? profileCard(
                doc['name'],
                doc['imageUrl'],
                doc['age'],
                doc['interest'],
              )
                  : Container();
            }).toList();
            return Container(
              color: Colors.white,
              child: ListView(
                children: profileList,
              ),
            );
          },
        ),
      ),
    );
  }
}
