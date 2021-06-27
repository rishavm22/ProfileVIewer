import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:lazy_load_scrollview/lazy_load_scrollview.dart';
import 'package:profile_viewer/utilities/profileCard.dart';
import 'package:profile_viewer/provider/listFilterProvider.dart';
import 'package:profile_viewer/provider/profileFilterProvider.dart';
import 'package:provider/provider.dart';

import '../utilities/filter.dart';

class HomePage extends StatefulWidget {
  static String id = 'home';
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final _categoryFormKey = GlobalKey<FormBuilderState>();
  List<String> items = new List.generate(100, (index) => 'Hello $index');
  final CollectionReference ref =
      FirebaseFirestore.instance.collection('users');

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
                      return filterForm(data, _categoryFormKey, context);
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
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget listData(ListFilterProvider data) {
    Stream<QuerySnapshot> queryStream =
        ref.limit(data.getListLimit).snapshots();
    if ((data.getAgeLimit.start != 18 || data.getAgeLimit.end != 60) &&
        data.getInterest.isNotEmpty) {
      queryStream = ref
          .limit(data.getListLimit)
          .where('interest', arrayContains: data.getInterest)
          .snapshots();
      return getListWithAgeLimit(queryStream, data);
    }
    if (data.getAgeLimit.start != 18.0 || data.getAgeLimit.end != 60.0) {
      queryStream = ref.snapshots();
      return getListWithAgeLimit(queryStream, data);
    }
    if (data.getInterest.isNotEmpty)
      queryStream = ref
          .limit(data.getListLimit)
          .where('interest', arrayContains: data.getInterest)
          .snapshots();
    List<Widget> profileList;
    return Container(
      height: MediaQuery.of(context).size.height - 200,
      child: StreamBuilder<QuerySnapshot>(
        stream: queryStream,
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return Center(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 80),
                child: Container(
                  child: CircularProgressIndicator(),
                ),
              ),
            );
          }
          profileList = snapshot.data!.docs
              .map(
                (doc) {
                  return  profileCard(
                    doc['name'],
                    doc['imageUrl'],
                    doc['age'],
                    doc['interest'],
                  );
                }
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

  Widget getListWithAgeLimit(
      Stream<QuerySnapshot<Object?>> queryStream, ListFilterProvider data) {
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
