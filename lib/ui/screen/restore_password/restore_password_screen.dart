import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:masterstudy_app/ui/bloc/restore_password/bloc.dart';

import '../../../main.dart';

class RestorePasswordScreen extends StatelessWidget {
  static const routeName = "restorePasswordScreen";
  final RestorePasswordBloc bloc;

  const RestorePasswordScreen(this.bloc) : super();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: BlocProvider<RestorePasswordBloc>(
          create: (context) => bloc, child: _RestorePasswordWidget()),
    );
  }
}

class _RestorePasswordWidget extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _RestorePasswordWidgetState();
  }
}

class _RestorePasswordWidgetState extends State<_RestorePasswordWidget> {
  RestorePasswordBloc _bloc;

  @override
  void initState() {
    _bloc = BlocProvider.of<RestorePasswordBloc>(context);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener(
      bloc: _bloc,
      listener: (context,state){
        if(state is SuccessRestorePasswordState)
          Scaffold.of(context).showSnackBar(SnackBar(content: Text(localizations.getLocalization("restore_password_sent_text")),backgroundColor: Colors.green,));
      },
      child: BlocBuilder<RestorePasswordBloc, RestorePasswordState>(
        bloc: _bloc,
        builder: (context, state) {
          return _buildForm(state);
        },
      ),
    );
  }

  TextEditingController _emailController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  _buildForm(state) {
    var enableInputs = !(state is LoadingRestorePasswordState);
    return Form(
      key: _formKey,
      child: Column(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.only(left: 18.0, right: 18.0, top: 18.0),
            child: TextFormField(
              controller: _emailController,
              enabled: enableInputs,
              decoration: InputDecoration(
                  labelText: localizations.getLocalization("email_label_text"),
                  helperText:
                      localizations.getLocalization("email_helper_text"),
                  filled: true),
              validator: _validateEmail,
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(left: 18.0, right: 18.0, top: 18.0),
            child: new MaterialButton(
              minWidth: double.infinity,
              color: mainColor,
              onPressed: register,
              child: setUpButtonChild(enableInputs),
              textColor: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  void register() {
    if (_formKey.currentState.validate()) {
      _bloc.add(SendRestorePasswordEvent(_emailController.text));
    }
  }

  Widget setUpButtonChild(enable) {
    if (enable == true) {
      return new Text(
        localizations.getLocalization("restore_password_button"),
        textScaleFactor: 1.0,
      );
    } else {
      return SizedBox(
        width: 30,
        height: 30,
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
        ),
      );
    }
  }

  String _validateEmail(String value) {
    if (value.isEmpty) {
      // The form is empty
      return localizations.getLocalization("email_empty_error_text");
    }
    // This is just a regular expression for email addresses
    String p = "[a-zA-Z0-9\+\.\_\%\-\+]{1,256}" +
        "\\@" +
        "[a-zA-Z0-9][a-zA-Z0-9\\-]{0,64}" +
        "(" +
        "\\." +
        "[a-zA-Z0-9][a-zA-Z0-9\\-]{0,25}" +
        ")+";
    RegExp regExp = new RegExp(p);

    if (regExp.hasMatch(value)) {
      // So, the email is valid
      return null;
    }

    // The pattern of the email didn't match the regex above.
    return localizations.getLocalization("email_invalid_error_text");
  }
}
