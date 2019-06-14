import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:coffee_app/MyProfile/Main_profile_page_pastBrewTab_content_entry.dart';
import 'package:coffee_app/MyProfile/Recipe.dart';
import 'package:coffee_app/auth.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';


class PastBrews extends StatefulWidget {
  PastBrews({this.auth});
  final BaseAuth auth;

  @override
  State<StatefulWidget> createState() => _PastBrewsState();
  
}

class _PastBrewsState extends State<PastBrews> {
  String userId;
  /*implement this using stream builder first. 
  to implement this via account version, we must find a way to access the 
  instance of the firebase user when i call this statelesswidget, prob 
  using future builder?
  Would be something like FutureBuilder( future: (where i await theuser id) 
  then we will pull the PastBrewss based on this user uid. 
  */

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _buildPastBrews(context),
    );
  }

  //takes out the data from the stream
  Widget _buildPastBrews(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: Firestore.instance.collection("testRecipes").where('userId', isEqualTo: userId).snapshots(),
      // stream: Firestore.instance.collection("testRecipes").snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return LinearProgressIndicator();
        }
        return _buildPastBrewsList(context, snapshot.data.documents);
      },
    );
  }

  //returns the list view
  Widget _buildPastBrewsList(BuildContext context, List<DocumentSnapshot> snapshot) {
    
    return ListView.builder(
      itemBuilder: (BuildContext context , int index) {
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
  Widget _buildEachItem(BuildContext context, DocumentSnapshot data, int index, int length) {
    final last = index + 1 == length;
    final currentEntry = Recipe.fromSnapshot(data);
    return Padding(
      key: ValueKey(currentEntry.id),
      //add custom padding to last entry to accomdate floating action button
      padding: !last ? EdgeInsets.symmetric(horizontal: 20.0, vertical: 15.0) : EdgeInsets.fromLTRB(20.0, 15.0, 20.0, 70),
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey),
          borderRadius: BorderRadius.circular(5.0),
        ),
        child: ListTile(
            title: Text("Bean: " + currentEntry.beanName),
            //subtitle: Text(currentEntry.date),
            trailing: IconButton(
              icon: Icon(Icons.edit),
              onPressed: () {
                print("future edit button");
                Navigator.push(context,
                    MaterialPageRoute(builder: (context) => JournalEntry(currentEntry)));
              },
            )),
      ),
    );
  }
}
