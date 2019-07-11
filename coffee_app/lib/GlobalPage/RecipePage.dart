import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:coffee_app/MyProfile/Recipe.dart';
import 'package:coffee_app/GlobalPage/search_bar.dart';
import 'package:coffee_app/GlobalPage/view-Entry.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';

class RecipePage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _RecipePageState();
}

class _RecipePageState extends State<RecipePage> {
  /*implement this using stream builder first. 
  to implement this via account version, we must find a way to access the 
  instance of the firebase user when i call this statelesswidget, prob 
  using future builder?
  Would be something like FutureBuilder( future: (where i await theuser id) 
  then we will pull the RecipePages based on this user uid. 
  */

  TextEditingController _controller;
  FocusNode _focusNode;
  String _terms = '';
  List<DocumentSnapshot> queryResults = [];
  List<DocumentSnapshot> tempSearchedResults = [];

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController()..addListener(_onTextChanged);
    _focusNode = FocusNode();
    _fetchQueryResults();
    // print('init state ran@@@@@@@@@@@@@@@');
  }

  void _fetchQueryResults() async {
    final QuerySnapshot docs = await Firestore.instance
        .collection('testRecipesv3')
        .where('isShared', isEqualTo: true)
        .getDocuments();

    for (int i = 0; i < docs.documents.length; ++i) {
      setState(() {
        queryResults.add(docs.documents[i]);
        tempSearchedResults.add(docs.documents[i]);
      });
    }
  }

  @override
  void dispose() {
    _focusNode.dispose();
    _controller.dispose();
    super.dispose();
  }

  void _onTextChanged() {
    setState(() {
      _terms = _controller.text;
    });

    if (_controller.text.length == 0) {
      // if search field is empty, all recipes should be displayed
      setState(() {
        tempSearchedResults = queryResults;
      });
    } else {
      setState(() {
        tempSearchedResults = [];
      });

      // change the test condition in the if block below
      // to change search functionality
      bool searchPredicate(DocumentSnapshot element) =>
          element['beanName'].toLowerCase().contains(_terms.toLowerCase()) ||
          element['brewer'].toLowerCase().contains(_terms.toLowerCase());

      // in brewer branch
      queryResults.forEach((element) {
        if (searchPredicate(element)) {
          setState(() {
            tempSearchedResults.add(element);
          });
        }
      });
    }
  }
  Widget _showLoading() {
    return Center(
      child: CircularProgressIndicator(
        backgroundColor: Colors.white,
        
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GestureDetector(
        onTap: () => FocusScope.of(context).requestFocus(new FocusNode()),
        child: Stack(
          fit: StackFit.expand,
          children: <Widget>[
             Image(
          image: new AssetImage("assets/globalPageBackground.jpg"),
          fit: BoxFit.fitHeight,
          color: Colors.black54,
          colorBlendMode: BlendMode.darken,
        ),
            Opacity(
              opacity: 0.95,
                          child: Column(
                children: <Widget>[
                  _buildSearchBox(),
                  Expanded(
                    child: tempSearchedResults.length == 0 ? _showLoading() : ListView.builder(
                      itemCount: tempSearchedResults.length,
                      itemBuilder: (context, index) => _buildEachItem(
                          context,
                          tempSearchedResults[index],
                          index,
                          tempSearchedResults.length),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchBox() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(0.0, 0.0, 0.0, 20.0),
      child: SearchBar(
        controller: _controller,
        focusNode: _focusNode,
      ),
    );
  }

  // // takes out the data from the stream
  // Widget _buildRecipePage(BuildContext context) {
  //   return StreamBuilder<QuerySnapshot>(
  //     stream: Firestore.instance
  //         .collection("testRecipes")
  //         .where('isShared', isEqualTo: true)
  //         .snapshots(),
  //     builder: (context, snapshot) {
  //       if (!snapshot.hasData) {
  //         return LinearProgressIndicator();
  //       }
  //       return _buildRecipePageList(context, snapshot.data.documents);
  //     },
  //   );
  // }

  //returns the list view
  // Widget _buildRecipePageList(
  //     BuildContext context, List<DocumentSnapshot> snapshot) {
  //   return ListView.builder(
  //     shrinkWrap: true,
  //     itemBuilder: (BuildContext context, int index) {
  //       return _buildEachItem(context, snapshot[index], index, snapshot.length);
  //     },
  //     itemCount: snapshot.length,
  //   );

  /*
    return ListView(
      padding: EdgeInsets.only(top: 10.0),
      children: snapshot.map((data) => _buildEachItem(context, data)).toList(),
    );*/
}

Widget _buildEachItem(BuildContext context, DocumentSnapshot currentEntry,
    int index, int length) {
  final last = index + 1 == length;
  // final currentEntry = Recipe.fromSnapshot(data);
  return Padding(
    key: ValueKey(currentEntry['id']),
    //add custom padding to last entry to accomdate floating action button
    padding: EdgeInsets.symmetric(horizontal: 10.0, vertical: 5.0),

    child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(width: 1.0, color: Colors.black),
          borderRadius: BorderRadius.circular(8.0),
        ),
        child: ListTile(
            contentPadding:
                EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
            leading: GestureDetector(
              onTap: () {
                _showLiked(context);
              },
              child: Container(
                padding: EdgeInsets.only(right: 12.0),
                decoration: new BoxDecoration(
                    border: new Border(
                        right:
                            new BorderSide(width: 1.0, color: Colors.black45))),
                child: Icon(Icons.star_border, color: Colors.black),
              ),
            ),
            title: Text("Bean: " + currentEntry['beanName']),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text("Brewer: " + currentEntry['brewer']),
                Text("Brewed by: " + currentEntry['displayName']),
                Text("Brewed on: " + currentEntry['date']),
              ],
            ),
            trailing: Container(
              decoration: BoxDecoration(
                //borderRadius: BorderRadius.circular(10.0),
                border:
                    Border(left: BorderSide(width: 1.0, color: Colors.black45)),
              ),
              //Border.all(width: 1.0, color: Colors.brown[300])),
              child: Theme(
                data: Theme.of(context).copyWith(
                  primaryColor: Colors.brown[300],
                ),
                child: MaterialButton(
                  child: Column(
                    children: <Widget>[
                      SizedBox(height: 5.0),
                      Icon(
                        Icons.keyboard_arrow_right,
                        color: Colors.brown[400],
                      ),
                      Text(
                        "view",
                        style: TextStyle(color: Colors.brown[400]),
                      ),
                    ],
                  ),
                  onPressed: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => ViewJournalEntry(
                                Recipe.fromSnapshot(currentEntry),
                                currentEntry)));
                  },
                ),
              ),
            ))),
  );
}

//function to change icon to starred
void _showLiked(BuildContext context) {
  showDialog(
      context: context,
      builder: (BuildContext context) {
        return CupertinoAlertDialog(
          content: Text("You have starred this recipe!"),
          actions: <Widget>[
            CupertinoButton(
              child: Text("Dismiss"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            )
          ],
        );
      });
}

/*
  //actually build the listtile
  Widget _buildEachItem(
      BuildContext context, DocumentSnapshot data, int index, int length) {
    final last = index + 1 == length;
    final currentEntry = Recipe.fromSnapshot(data);
    return Padding(
      key: ValueKey(currentEntry.id),
      //add custom padding to last entry to accomdate floating action button
      padding: !last
          ? EdgeInsets.symmetric(horizontal: 20.0, vertical: 15.0)
          : EdgeInsets.fromLTRB(20.0, 15.0, 20.0, 70),
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey),
          borderRadius: BorderRadius.circular(5.0),
        ),
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
            subtitle: Text(currentEntry.brewer),
            trailing: Container(
              child: IconButton(
                icon: Icon(Icons.library_books),
                onPressed: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) =>
                              ViewJournalEntry(currentEntry, data)));
                },
              ),
            )),
      ),
    );
  }
  */

/* 
// previous hard coded global repo recipe page.
import 'package:flutter/material.dart';
import '../styles.dart';
import './search_bar.dart';

class RecipePage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => RecipePageState();
}

class RecipePageState extends State<RecipePage> {
  
  TextEditingController _controller;
  FocusNode _focusNode;
  String _terms = '';

   @override
  void initState() {
    super.initState();
    _controller = TextEditingController()..addListener(_onTextChanged);
    _focusNode = FocusNode();
  }

  @override
  void dispose() {
    _focusNode.dispose();
    _controller.dispose();
    super.dispose();
  }

  void _onTextChanged() {
    setState(() {
      _terms = _controller.text;
    });
  }

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: 
        const BoxDecoration(
        color: Styles.scaffoldBackground,
      ),
      child: new Column(
        children: <Widget>[
      
          Expanded(
            child: _buildBody(),)
        ],
      ),
    );
  }

  Widget _buildBody() {
    return ListView.builder(
      padding: const EdgeInsets.all(5.0),
      itemBuilder: (context, i) {
        return _buildRow(i);
      },);
  }

   Widget _buildRow(int i) {
    return new ListTile(
      title: new Text("Coffee Recipe " + i.toString() ),
    );
  }

   Widget _buildSearchBox() {
    return Padding(
      padding: const EdgeInsets.all(8),
      child: SearchBar(
        controller: _controller,
        focusNode: _focusNode,
        
      ),
    );
  }     


}
*/