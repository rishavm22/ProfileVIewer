import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

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
                              : AssetImage('assets/images/profile.png') as ImageProvider,
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

