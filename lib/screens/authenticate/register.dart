import 'package:flutter/material.dart';
import 'package:property_returns/shared/constants.dart';
import 'package:property_returns/shared/loading.dart';
import 'package:property_returns/services/auth.dart';

class Register extends StatefulWidget {
  final Function toggleView;
  Register({this.toggleView});

  @override
  _RegisterState createState() => _RegisterState();
}

class _RegisterState extends State<Register> {
  final AuthService _auth = AuthService();
  final _formKey = GlobalKey<FormState>();
  String email = '';
  String password = '';
  String error = '';
  bool loading = false;

  @override
  Widget build(BuildContext context) {
    return loading
        ? Loading()
        : Scaffold(
            backgroundColor: Colors.brown[100],
            appBar: AppBar(
              backgroundColor: Colors.brown[400],
              elevation: 0,
              title: Text('Register with Property Returns'),
              actions: <Widget>[
                FlatButton.icon(
                    onPressed: () {
                      widget.toggleView();
                    },
                    icon: Icon(Icons.person),
                    label: Text('Sign In'))
              ],
            ),
            body: Container(
              padding: EdgeInsets.symmetric(vertical: 20, horizontal: 50),
              child: Form(
                key: _formKey,
                child: Column(
                  children: <Widget>[
                    SizedBox(
                      height: 20,
                    ),
                    _displayRegisterEmailField(),
                    SizedBox(
                      height: 20,
                    ),
                    _displayRegisterPasswordField(),
                    SizedBox(
                      height: 20,
                    ),
                    // Register
                    RaisedButton(
                      child: Text(
                        'Register',
                      ),
                      onPressed: () async {
                        if (_formKey.currentState.validate()) {
                          setState(() => loading = true);
                          dynamic result = await _auth
                              .registerWithEmailAndPassword(email, password);
                          if (result == null) {
                            loading = false;
                            setState(
                                () => error = 'Please supply a valid email');
                          }
                          print('Register: $email');
                          print('Register: $password');
                        }
                      },
                    ),
                    SizedBox(
                      height: 12,
                    ),
                    Text(
                      error,
                      style: TextStyle(color: Colors.red, fontSize: 14),
                    )
                  ],
                ),
              ),
            ),
          );
  }

  TextFormField _displayRegisterEmailField() {
    return TextFormField(
      keyboardType: TextInputType.emailAddress,
      decoration: kTextInputDecoration.copyWith(hintText: 'Email'),
      validator: (val) => val.isEmpty ? 'Enter an email' : null,
      onChanged: (val) {
        // in course the Net Ninja used Set State here
        email = val;
      },
    );
  }

  TextFormField _displayRegisterPasswordField() {
    return TextFormField(
      decoration: kTextInputDecoration.copyWith(hintText: 'Password'),
      obscureText: true,
      validator: (val) =>
          val.length < 6 ? 'Must have six or more characters' : null,
      onChanged: (val) {
        // in course the Net Ninja used Set State here
        password = val;
      },
    );
  }
}
