import 'package:coffee_app/auth_provider.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_facebook_login/flutter_facebook_login.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

import 'dart:io' show Platform;
import 'styles.dart';
import 'package:flutter_signin_button/flutter_signin_button.dart';

class LoginPage extends StatefulWidget {
  //need to pass in an instance of this abstract class BaseAuth
  LoginPage({this.onSignedIn});

  final VoidCallback onSignedIn;

  @override
  State<StatefulWidget> createState() {
    return _LoginPageState();
  }
}

enum FormType {
  login,
  register,
}

class _LoginPageState extends State<LoginPage> {
  FacebookLogin facebookLogin = new FacebookLogin();

  String _displayName;
  String _email;
  final _formKey = new GlobalKey<FormState>();
  FormType _formType = FormType.login;
  String _password;

  // storing user locally so we can delete facebook's user cache
 
  // FirebaseUser firebaseUser;

  bool validateAndSave() {
    final form = _formKey.currentState;
    form.save();
    if (form.validate()) {
      print("$_email, $_password");
      return true;
    } else {
      print("invalid form");
      return false;
    }
  }

  void validateAndSubmit() async {
    if (validateAndSave()) {
      try {
        var auth = AuthProvider.of(context).auth;
        if (_formType == FormType.login) {
          String userId =
              await auth.signInWithEmailAndPassword(_email, _password);
          print("signed in $userId");
        } else {
          String userId = await auth.createUserWithEmailAndPassword(
              _email, _password, _displayName);
          print("registered $userId");
        }
        widget.onSignedIn();
      } catch (e) {
        print(e);
        _signInErrorDialog(e);
        print("error signing in");
      }
    }
  }

  //facebook login
  void _initiateFacebookLogin() async {
    var auth = AuthProvider.of(context).auth;

    final facebookLoginResult = await facebookLogin
        .logInWithReadPermissions(['email', 'public_profile']);

    switch (facebookLoginResult.status) {
      case FacebookLoginStatus.loggedIn:
        // login was successful
        FacebookAccessToken myToken = facebookLoginResult.accessToken;

        // we use FacebookAuthProvider class to get a credential from accessToken
        // this will return an AuthCredential object that we will use to auth in firebase
        AuthCredential credential =
            FacebookAuthProvider.getCredential(accessToken: myToken.token);

        // this line does auth in firebase with your facebook credential
        FirebaseUser firebaseUser =
            await auth.instance.signInWithCredential(credential);

        print('fb login status : ${facebookLoginResult.status}');
        print('logged in as ${firebaseUser.displayName}');
        print('signing in');

        widget.onSignedIn();
        break;
      case FacebookLoginStatus.cancelledByUser:
        print('from facebook login switch case: login cancelled by user');
        break;
      case FacebookLoginStatus.error:
        print('from facebook login switch case: login error');
        break;
    }
    /* uses deprecated facebook login API
    For reference only
    () {
      fbLogin
          .logInWithReadPermissions(['email', 'public_profile'])
          .then((result) {
            var auth = AuthProvider.of(context).auth;
            switch (result.status) {
              case FacebookLoginStatus.loggedIn:
                auth.instance.signInWithFacebook(
                  accessToken: result.accessToken.token
                ).then((signedInUser) {
                  print('Signed in as facebook ${signedInUser.displayName}');
                  print('Do the navigator change to homepage here');
                });
                break;
              case FacebookLoginStatus.cancelledByUser:
                print('Facebook login cancelled by user');
                break;
              case FacebookLoginStatus.error:
                print('Facebook login switch case error');
                break;
            }
          })
          .catchError((e) {
            print(e);
          })
    },
    */
  }

  Future<Null> _signInErrorDialog(PlatformException e) async {
    return showDialog(
        context: context,
        builder: (BuildContext context) {
          if (Platform.isAndroid) {
            return AlertDialog(
              title: Text("Error signing in"),
              content: Text(e.code),
              actions: <Widget>[
                FlatButton(
                  child: Text("try again"),
                  onPressed: () => Navigator.of(context).pop(),
                )
              ],
            );
          } else {
            return CupertinoAlertDialog(
              title: Text("Error signing in"),
              content: Text(e.code),
              actions: <Widget>[
                FlatButton(
                  child: Text("try again"),
                  onPressed: () => Navigator.of(context).pop(),
                )
              ],
            );
          } 
        });
  }

  //register user by switching form type
  void moveToRegister() {
    _formKey.currentState.reset();
    setState(() {
      _formType = FormType.register;
    });
  }

  void moveToLogin() {
    _formKey.currentState.reset();
    setState(() {
      _formType = FormType.login;
    });
  }

//build login form fields
  List<Widget> buildInputs() {
    if (_formType == FormType.login) {
      return [
        TextFormField(
          autofocus: true,
          style: Styles.loginText,
          decoration: new InputDecoration(
              hintText: "Enter Email/Username", hintStyle: Styles.loginText),
          keyboardType: TextInputType.text,
          validator: (value) => value.isEmpty ? "email cant be empty" : null,
          onSaved: (value) => _email = value,
        ),
        Divider(),
        TextFormField(
          style: Styles.loginText,
          decoration: new InputDecoration(
              hintText: "Enter password", hintStyle: Styles.loginText),
          keyboardType: TextInputType.text,
          obscureText: true,
          validator: (value) => value.isEmpty ? "password cant be empty" : null,
          onSaved: (value) => _password = value,
        ),
        Divider(),
      ];
    } else if (_formType == FormType.register) {
      return [
        TextFormField(
          autofocus: true,
          style: Styles.loginText,
          decoration: new InputDecoration(
              hintText: "Enter DisplayName", hintStyle: Styles.loginText),
          keyboardType: TextInputType.text,
          validator: (value) => value.isEmpty ? "email cant be empty" : null,
          onSaved: (value) => _displayName = value,
        ),
        Divider(),
        TextFormField(
          autofocus: true,
          style: Styles.loginText,
          decoration: new InputDecoration(
              hintText: "Enter Email", hintStyle: Styles.loginText),
          keyboardType: TextInputType.text,
          validator: (value) => value.isEmpty ? "email cant be empty" : null,
          onSaved: (value) => _email = value,
        ),
        Divider(),
        TextFormField(
          autofocus: true,
          style: Styles.loginText,
          decoration: new InputDecoration(
              hintText: "Enter password", hintStyle: Styles.loginText),
          keyboardType: TextInputType.text,
          obscureText: true,
          validator: (value) => value.isEmpty ? "password cant be empty" : null,
          onSaved: (value) => _password = value,
        ),
        Divider(),
      ];
    } else {
      return [];
    }
  }

//build buttons
  List<Widget> buildSubmitButtons() {
    if (_formType == FormType.login) {
      return [
        ClipRRect(
          borderRadius: BorderRadius.circular(10.0),
          child: MaterialButton(
            color: Colors.brown[400],
            child: Text("Login"),
            onPressed: () => validateAndSubmit(),
          ),
        ),
        ClipRRect(
          borderRadius: BorderRadius.circular(10.0),
          child: new MaterialButton(
            color: Colors.brown[400],
            child: Text("Create account"),
            onPressed: () => moveToRegister(),
          ),
        ),
        ClipRRect(
          borderRadius: BorderRadius.circular(10.0),
          child: SignInButton(
            Buttons.Facebook,
            text: "Sign in with Facebook",
            onPressed: () => _initiateFacebookLogin(),
          )

          /*new MaterialButton(
            color: Colors.brown[400],
            child: Text("Login with Facebook"),
            onPressed: () => _initiateFacebookLogin(),
          )*/
          ,
        ),
        ClipRRect(
          borderRadius: BorderRadius.circular(10.0),
          child: SignInButton(
            Buttons.Facebook,
            text: "Clear Facebook account",
            onPressed: () async {
              await facebookLogin.logOut();
              var auth = AuthProvider.of(context).auth;
              await auth.signOut();
            },
          ),
          /*MaterialButton(
            color: Colors.brown[400],
            child: Text("clear facebook account"),
            onPressed: () async {
              await facebookLogin.logOut();
              var auth = AuthProvider.of(context).auth;
              await auth.signOut();
              // firebaseUser = null;
            },
          )*/
        ),
        ClipRRect(
          borderRadius: BorderRadius.circular(10.0),
          child: SignInButton(
            Buttons.Google,
            text: "Sign In With Google",
            onPressed: () {
              signInWithGoogle();   
            },
          ),
        ),
        Divider(),
      ];
    } else {
      return [
        ClipRRect(
          borderRadius: BorderRadius.circular(10.0),
          child: MaterialButton(
            color: Colors.brown[400],
            child: Text("create an account"),
            onPressed: () => validateAndSubmit(),
          ),
        ),
        ClipRRect(
          borderRadius: BorderRadius.circular(10.0),
          child: new MaterialButton(
            color: Colors.brown[400],
            child: Text("Already registered?"),
            onPressed: () => moveToLogin(),
          ),
        ),
        Divider(),
      ];
    }
  }

  Future<Null> signInWithGoogle() async {
    GoogleSignInAccount googleAccount;
    final GoogleSignIn googleSignIn = new GoogleSignIn();

    if (googleAccount == null) {
      // Start the sign-in process:
      googleAccount = await googleSignIn.signIn();
    }
    var _auth = AuthProvider.of(context).auth;

    FirebaseUser googleFirebaseUser =
        await _auth.googleSignIntoFirebase(googleAccount);

    widget.onSignedIn();
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      resizeToAvoidBottomInset: false,
      body: GestureDetector(
        onTap: () => FocusScope.of(context).requestFocus(new FocusNode()),
        child: Stack(
          fit: StackFit.expand,
          children: <Widget>[
            Image(
              image: new AssetImage("assets/login_background.jpg"),
              fit: BoxFit.fitHeight,
              color: Colors.black87,
              colorBlendMode: BlendMode.darken,
            ),
            Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: <Widget>[
                new Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: <Widget>[
                    Container(
                        alignment: Alignment.center,
                        child: Text(
                          "BrewCompass",
                          style: TextStyle(
                              fontFamily: "Montesarro",
                              fontSize: 25.0,
                              color: Colors.white,
                              fontStyle: FontStyle.italic),
                        ))
                  ],
                ),
                Container(
                  padding: EdgeInsets.all(40.0),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: buildInputs() + buildSubmitButtons(),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
