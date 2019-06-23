import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:coffee_app/MyProfile/Main_profile_page_pastBrewTab_content_entry.dart';
import 'package:coffee_app/MyProfile/Recipe.dart';
import 'package:coffee_app/auth.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:uuid/uuid.dart';

class PastBrews extends StatefulWidget {
  PastBrews({this.auth});
  final BaseAuth auth;

  @override
  State<StatefulWidget> createState() => _PastBrewsState();
}

class _PastBrewsState extends State<PastBrews> {
  String userId;
  Uuid uuid = new Uuid();

  Future<FirebaseUser> _fetchUser() async {
    FirebaseUser user = await widget.auth.getUser();
    return user;
  }

  void _user() async {
    // final user = await _fetchUser();
    final user = await _fetchUser();
    setState(() {
      if (user.uid != null) {
        //name = uid.displayName;
        userId = user.uid;
      } else {}
    });
  }

  @override
  void initState() {
    super.initState();
    _user();
  }

  Stream<QuerySnapshot> newStream() {
    return Firestore.instance
        .collection("testRecipesv3")
        .where('userId', isEqualTo: userId)
        .snapshots();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _buildPastBrews(context),
    );
  }

  //takes out the data from the stream
  Widget _buildPastBrews(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: Firestore.instance
          .collection("testRecipesv3")
          .where('userId', isEqualTo: userId)
          .snapshots(),
      // stream: Firestore.instance.collection("testRecipes").snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return Column(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: <Widget>[
              Center(child: CircularProgressIndicator()),
            ],
          );
        }
        return _buildPastBrewsList(context, snapshot.data.documents);
      },
    );
  }

  //returns the list view
  Widget _buildPastBrewsList(
      BuildContext context, List<DocumentSnapshot> snapshot) {
    return ListView.builder(
      itemBuilder: (BuildContext context, int index) {
        return _buildEachItem(context, snapshot[index], index, snapshot.length);
      },
      itemCount: snapshot.length,
    );

    /*
    return ListView(
      padding: EdgeInsets.only(top: 10.0),
      children: snapshot.map((data) => _buildEachItem(context, data)).toList(),
    );*/
  }

  //actually build the listtile
  Widget _buildEachItem(
      BuildContext context, DocumentSnapshot data, int index, int length) {
    final last = index + 1 == length;
    final currentEntry = Recipe.fromSnapshot(data);
    return Padding(
      //add custom padding to last entry to accomdate floating action button
      padding: !last
          ? EdgeInsets.symmetric(horizontal: 20.0, vertical: 15.0)
          : EdgeInsets.fromLTRB(20.0, 15.0, 20.0, 120),
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey),
          borderRadius: BorderRadius.circular(5.0),
        ),
        child: Dismissible(
          background: Container(
            color: Colors.red,
          ),
          //unique key
          key: Key(uuid.v4()),
          onDismissed: (direction) {
            try {
              setState(() {
                Firestore.instance
                    .collection("testRecipesv3")
                    .document(data.documentID)
                    .delete()
                    .catchError((e) {
                  print(e);
                });
              });
            } catch (e) {
              print("danggity");
            }
          },
          child: ListTile(
              contentPadding:
                  EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
              leading: Container(
                padding: EdgeInsets.only(right: 12.0),
                decoration: new BoxDecoration(
                    border: new Border(
                        right:
                            new BorderSide(width: 1.0, color: Colors.black45))),
                child: Icon(Icons.book, color: Colors.black),
              ),
              title: Text("Bean: " + currentEntry.beanName),
              subtitle: Text(currentEntry.date),
              trailing: Container(
                decoration: BoxDecoration(
                    border: Border(
                  left: BorderSide(width: 1.0, color: Colors.black45),
                )),
                child: IconButton(
                  icon: Icon(Icons.chevron_right),
                  onPressed: () {
                    print("future edit button");
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) =>
                                JournalEntry(currentEntry, data)));
                  },
                ),
              )),
        ),
      ),
    );
  }
}
