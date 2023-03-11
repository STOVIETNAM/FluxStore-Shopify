// ignore_for_file: always_declare_return_types, prefer_is_empty

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../app.dart';
import '../../common/constants.dart';
import '../../common/tools/tools.dart';
import '../../generated/l10n.dart';
import '../../models/newuser_model.dart';
import '../../widgets/common/harold_text_field.dart';

class RegistrationFinalScreen extends StatefulWidget {
  final String countryCode;
  final String phoneNumber;
  const RegistrationFinalScreen(
      {required this.countryCode, required this.phoneNumber, Key? key})
      : super(key: key);

  @override
  State<RegistrationFinalScreen> createState() =>
      _RegistrationFinalScreenState();
}

class _RegistrationFinalScreenState extends State<RegistrationFinalScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _pinCodeController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();

  @override
  void dispose() {
    super.dispose();
    _nameController.dispose();
    _emailController.dispose();
    _pinCodeController.dispose();
    _addressController.dispose();
  }

  _submitData() async {
    var nameSplit = _nameController.text.trim().split(' ');
    var firstname = nameSplit[0];
    var lastname = '';
    if (nameSplit.length >= 2) {
      lastname = nameSplit[1];
    }
    var phone = widget.countryCode + widget.phoneNumber;
    await Provider.of<NewUserModel>(context, listen: false)
        .createNewUser(
            phone.substring(1),
            'Mobile',
            firstname,
            lastname,
            _emailController.text,
            _pinCodeController.text,
            _addressController.text)
        .then((customers) async {
      if (customers.isEmpty) {
        if (kDebugMode) {
          print('Error Occured');
        }
      } else {
        await Navigator.of(
          App.fluxStoreNavigatorKey.currentContext!,
        ).pushNamedAndRemoveUntil(
          RouteList.dashboard,
          (route) => false,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: Theme.of(context).backgroundColor,
      appBar: AppBar(
        systemOverlayStyle: SystemUiOverlayStyle.light,
        backgroundColor: Theme.of(context).backgroundColor,
        leading: IconButton(
          icon: const Icon(CupertinoIcons.back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        elevation: 0.0,
      ),
      body: SafeArea(
        child: GestureDetector(
          onTap: () => Tools.hideKeyboard(context),
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 30.0),
              child: DefaultTextStyle(
                style: Theme.of(context).textTheme.bodyText1!,
                child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: <Widget>[
                      const SizedBox(
                        height: 10,
                      ),
                      Text(
                        S.of(context).yourInformation,
                        style: const TextStyle(fontSize: 24),
                      ),
                      const SizedBox(
                        height: 16,
                      ),
                      Card(
                        elevation: 8,
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                CustomHaroldTextField(
                                  label: S.of(context).name,
                                  controller: _nameController,
                                  autoFillHints: const [AutofillHints.name],
                                ),
                                _buildWidgetFormSeperator,
                                CustomHaroldTextField(
                                  label: S.of(context).email,
                                  controller: _emailController,
                                  autoFillHints: const [AutofillHints.email],
                                  inputType: TextInputType.emailAddress,
                                ),
                                _buildWidgetFormSeperator,
                                CustomHaroldTextField(
                                  label: S.of(context).pincode,
                                  inputType: TextInputType.number,
                                  inputFormatters: [
                                    FilteringTextInputFormatter.digitsOnly
                                  ],
                                  controller: _pinCodeController,
                                ),
                                _buildWidgetFormSeperator,
                                CustomHaroldTextField(
                                  label: S.of(context).address,
                                  maxLines: 4,
                                  autoFillHints: const [
                                    AutofillHints.postalAddress
                                  ],
                                  controller: _addressController,
                                )
                              ]),
                        ),
                      ),
                      const SizedBox(
                        height: 32,
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 32.0),
                        child: ElevatedButton(
                          style: ButtonStyle(
                            minimumSize:
                                MaterialStateProperty.all(const Size(0, 48)),
                            shape: MaterialStateProperty.all<
                                RoundedRectangleBorder>(
                              RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16.0),
                              ),
                            ),
                          ),
                          onPressed: () {
                            if (_nameController.text.isEmpty ||
                                _emailController.text.isEmpty ||
                                _pinCodeController.text.isEmpty ||
                                _addressController.text.isEmpty) {
                              final snackBar = SnackBar(
                                  content: Text(S.of(context).pleaseInput));
                              ScaffoldMessenger.of(context)
                                  .showSnackBar(snackBar);
                            } else {
                              _submitData();
                            }
                          },
                          child: Text(S.of(context).submit,
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyText1!
                                  .copyWith(color: Colors.white)),
                        ),
                      ),
                    ]),
              ),
            ),
          ),
        ),
      ),
    );
  }

  SizedBox get _buildWidgetFormSeperator => const SizedBox(
        height: 16,
      );
}
