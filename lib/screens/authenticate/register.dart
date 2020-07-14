import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
  final FocusNode _emailFocusNode = FocusNode();
  final FocusNode _passwordFocusNode = FocusNode();

  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  String email = '';
  String password = '';
  String error = '';
  bool loading = false;
  bool _registerButtonEnabled = false;
  bool _obscurePasswordText = true;

  @override
  Widget build(BuildContext context) {
    _emailController.text.isNotEmpty && _passwordController.text.length > 5
        ? _registerButtonEnabled = true
        : _registerButtonEnabled = false;
    return loading
        ? Loading()
        : Scaffold(
            backgroundColor: Colors.brown[100],
            appBar: _buildAppBar(),
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
                      onPressed: _registerButtonEnabled ? _submit : null,
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

  AppBar _buildAppBar() {
    return AppBar(
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
    );
  }

  void _submit() async {
    if (_formKey.currentState.validate()) {
      setState(() => loading = true);
      dynamic result = await _auth.registerWithEmailAndPassword(
          _emailController.text, _passwordController.text);
      if (result == null) {
        loading = false;
        setState(() => error = 'Please supply a valid email');
      }
    }
  }

  TextFormField _displayRegisterEmailField() {
    return TextFormField(
      controller: _emailController,
      inputFormatters: [
        // do not allow spaces
        BlacklistingTextInputFormatter(RegExp(r"\s")),
      ],
      // don't show corrections on keyboard
      autocorrect: false,
      keyboardType: TextInputType.emailAddress,
      textInputAction: TextInputAction.next,
      focusNode: _emailFocusNode,
      decoration: kTextInputDecoration.copyWith(hintText: 'Email'),
      validator: (val) => val.isEmpty ? 'Enter an email' : null,
      onChanged: (val) {
        setState(() {});
//        email = val;
      },
      onEditingComplete: _emailEditingComplete,
    );
  }

  void _emailEditingComplete() {
    FocusScope.of(context).requestFocus(_passwordFocusNode);
  }

  TextFormField _displayRegisterPasswordField() {
    return TextFormField(
      controller: _passwordController,
      inputFormatters: [
        // do not allow spaces
        BlacklistingTextInputFormatter(RegExp(r"\s")),
      ],
      // Don't show corrections on keyboard
      autocorrect: false,
      keyboardType: TextInputType.visiblePassword,
      textInputAction: TextInputAction.done,
      focusNode: _passwordFocusNode,
      decoration: kTextInputDecoration.copyWith(
          hintText: 'Password',
          suffixIcon: IconButton(
              icon: Icon(
                _obscurePasswordText ? Icons.visibility : Icons.visibility_off,
                color: Theme.of(context).primaryColorDark,
              ),
              onPressed: () {
                setState(() {
                  _obscurePasswordText = !_obscurePasswordText;
                });
              })),
      obscureText: _obscurePasswordText,
      validator: (val) =>
          val.length < 6 ? 'Must have six or more characters' : null,
      onChanged: (val) {
        setState(() {}); //        password = val;
      },
      onEditingComplete: _submit,
    );
  }
}
