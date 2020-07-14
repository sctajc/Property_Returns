import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:property_returns/shared/constants.dart';
import 'package:property_returns/shared/loading.dart';
import 'package:property_returns/services/auth.dart';

class SignIn extends StatefulWidget {
  final Function toggleView;
  SignIn({this.toggleView});

  @override
  _SignInState createState() => _SignInState();
}

class _SignInState extends State<SignIn> {
  final AuthService _auth = AuthService();
  final _formKey = GlobalKey<FormState>();
  final FocusNode _emailFocusNode = FocusNode();
  final FocusNode _passwordFocusNode = FocusNode();

  // text field state
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  String error = '';
  bool loading = false;
  bool signInButtonEnabled = false;
  bool _obscurePasswordText = true;

  @override
  Widget build(BuildContext context) {
    _emailController.text.isNotEmpty && _passwordController.text.length > 5
        ? signInButtonEnabled = true
        : signInButtonEnabled = false;
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
                    _displaySignInEmailField(),
                    SizedBox(
                      height: 20,
                    ),
                    _displaySignInPasswordField(),
                    SizedBox(
                      height: 20,
                    ),
                    RaisedButton(
                      child: Text(
                        'Sign in',
                      ),
                      onPressed: signInButtonEnabled ? _submit : null,
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
      title: Text('Sign in'),
      actions: <Widget>[
        FlatButton.icon(
            onPressed: () {
              widget.toggleView();
            },
            icon: Icon(Icons.person),
            label: Text('Register'))
      ],
    );
  }

  void _submit() async {
    if (_formKey.currentState.validate()) {
      setState(() => loading = true);
      dynamic result = await _auth.signInWithEmailAndPassword(
          _emailController.text, _passwordController.text);
      if (result == null) {
        loading = false;
        setState(() => error = 'Email and/or password not valid');
      }
    }
  }

  _displaySignInEmailField() {
    return TextFormField(
      controller: _emailController,
      inputFormatters: [
        // do not allow spaces
        BlacklistingTextInputFormatter(
          RegExp(r"\s"),
        ),
      ],
      autocorrect: false, // just above keyboard don't show suggestions
      keyboardType: TextInputType.emailAddress,
      textInputAction: TextInputAction.next,
      focusNode: _emailFocusNode,
      decoration: kTextInputDecoration.copyWith(hintText: 'Email'),
      validator: (val) => val.isEmpty ? 'Enter an email' : null,
      onChanged: (val) {
        setState(() {});
      },
      onEditingComplete: _emailEditingComplete,
    );
  }

  void _emailEditingComplete() {
    FocusScope.of(context).requestFocus(_passwordFocusNode);
  }

  _displaySignInPasswordField() {
    return TextFormField(
      controller: _passwordController,
      inputFormatters: [
        // do not allow spaces
        BlacklistingTextInputFormatter(
          RegExp(r"\s"),
        ),
      ],
      autocorrect: false, // just above keyboard don't show suggestions
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
        setState(() {});
      },
      onEditingComplete: _submit,
    );
  }
}
