import 'package:country_code_picker/country_code_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../common/config.dart';
import '../../common/tools/tools.dart';
import '../../generated/l10n.dart';
import '../../models/newuser_model.dart';
import '../../models/user_model.dart';
import 'otp_registration_screen.dart';

class RegistrationScreenNew extends StatefulWidget {
  const RegistrationScreenNew({Key? key}) : super(key: key);

  @override
  State<RegistrationScreenNew> createState() => _RegistrationScreenNewState();
}

class _RegistrationScreenNewState extends State<RegistrationScreenNew> {
  CountryCode? countryCode;
  final TextEditingController _numberController = TextEditingController();

  @override
  void initState() {
    super.initState();
    countryCode = CountryCode(
      code: LoginSMSConstants.countryCodeDefault.isNotEmpty
          ? LoginSMSConstants.countryCodeDefault
          : null,
      dialCode: LoginSMSConstants.dialCodeDefault.isNotEmpty
          ? LoginSMSConstants.dialCodeDefault
          : null,
      name: LoginSMSConstants.nameDefault.isNotEmpty
          ? LoginSMSConstants.nameDefault
          : null,
    );
  }

  @override
  void dispose() {
    super.dispose();
    _numberController.dispose();
  }

  // ignore: always_declare_return_types
  checkUserExists(String phone) async {
    await Provider.of<NewUserModel>(context, listen: false)
        .searchNewUser(phone);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
                child: ListenableProvider.value(
                    value: Provider.of<UserModel>(context),
                    child:
                        Consumer<UserModel>(builder: (context, value, child) {
                      return Container(
                        decoration: const BoxDecoration(
                            image: DecorationImage(
                                image:
                                    AssetImage('assets/images/login_bg.jpeg'),
                                fit: BoxFit.cover)),
                        height: MediaQuery.of(context).size.height,
                        child: Padding(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 30.0),
                            child: DefaultTextStyle(
                              style: Theme.of(context).textTheme.bodyText1!,
                              child: Column(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  crossAxisAlignment:
                                      CrossAxisAlignment.stretch,
                                  children: <Widget>[
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        const SizedBox(height: 10.0),
                                        Text(
                                          S.of(context).welcome,
                                          style: const TextStyle(
                                              fontSize: 14,
                                              fontWeight: FontWeight.w300),
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.symmetric(
                                              vertical: 12.0),
                                          child: Text(
                                            S.of(context).continueWithPhone,
                                            style:
                                                const TextStyle(fontSize: 24),
                                          ),
                                        ),
                                        Text(
                                          S
                                              .of(context)
                                              .weWillSendOTPToPhoneNumber,
                                          style: const TextStyle(
                                              fontSize: 14, color: Colors.grey),
                                        ),
                                      ],
                                    ),
                                    const Spacer(),
                                    Card(
                                      elevation: 5,
                                      child: Row(
                                        children: [
                                          CountryCodePicker(
                                            onChanged: (country) {
                                              setState(() {
                                                countryCode = country;
                                              });
                                            },
                                            initialSelection: countryCode!.code,
                                            onInit: (code) {
                                              countryCode = code;
                                            },
                                            backgroundColor: Theme.of(context)
                                                .backgroundColor,
                                            dialogBackgroundColor:
                                                Theme.of(context)
                                                    .dialogBackgroundColor,
                                            textStyle: Theme.of(context)
                                                .textTheme
                                                .bodyLarge!
                                                .copyWith(fontSize: 16),
                                          ),
                                          Container(
                                            height: 32,
                                            margin:
                                                const EdgeInsets.only(right: 8),
                                            width: 1,
                                            color: Colors.grey,
                                          ),
                                          Expanded(
                                              child: TextField(
                                            keyboardType: TextInputType.phone,
                                            controller: _numberController,
                                            inputFormatters: [
                                              FilteringTextInputFormatter
                                                  .digitsOnly
                                            ],
                                            decoration: const InputDecoration(
                                                border: InputBorder.none),
                                          ))
                                        ],
                                      ),
                                    ),
                                    ValueListenableBuilder(
                                      valueListenable: _numberController,
                                      builder:
                                          (context, TextEditingValue value, _) {
                                        if (!_phoneValidator(value.text)) {
                                          return Padding(
                                            padding: const EdgeInsets.symmetric(
                                                vertical: 8.0),
                                            child: Text(
                                              S.of(context).errorPhoneFormat,
                                              style: const TextStyle(
                                                  color: Colors.red,
                                                  fontSize: 12),
                                            ),
                                          );
                                        } else {
                                          return Container();
                                        }
                                      },
                                    ),
                                    const Spacer(),
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      children: [
                                        ElevatedButton(
                                          onPressed: () {
                                            if (_phoneValidator(
                                                    _numberController.text) &&
                                                _numberController
                                                    .text.isNotEmpty &&
                                                countryCode?.dialCode != null) {
                                              //printLog(countryCode?.dialCode);
                                              //printLog(_numberController.text);
                                              // checkUserExists(
                                              //     _numberController.text);
                                              Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                  builder: (context) =>
                                                      OTPRegistrationScreen(
                                                    countryCode:
                                                        countryCode!.dialCode ??
                                                            '+00',
                                                    phoneNumber:
                                                        _numberController.text,
                                                  ),
                                                ),
                                              );
                                            }
                                          },
                                          style: ElevatedButton.styleFrom(
                                            fixedSize: const Size(48, 48),
                                            shape: const CircleBorder(),
                                          ),
                                          child: const Icon(
                                            Icons.chevron_right,
                                            size: 32,
                                            color: Colors.white,
                                          ),
                                        ),
                                        const SizedBox(
                                          height: 8,
                                        ),
                                        Text(S.of(context).next)
                                      ],
                                    ),
                                    const Spacer(),
                                    // Padding(
                                    //   padding:
                                    //       const EdgeInsets.only(bottom: 36.0),
                                    //   child: Row(
                                    //     mainAxisAlignment:
                                    //         MainAxisAlignment.center,
                                    //     children: <Widget>[
                                    //       Text(
                                    //         S.of(context).alreadyHaveAnAccount,
                                    //         style: const TextStyle(
                                    //             color: Colors.grey),
                                    //       ),
                                    //       GestureDetector(
                                    //         onTap: () {
                                    //           Navigator.pop(context);
                                    //         },
                                    //         child: Text(
                                    //           ' ${S.of(context).signIn}',
                                    //           style: TextStyle(
                                    //             fontWeight: FontWeight.bold,
                                    //             color: Theme.of(context)
                                    //                 .primaryColor,
                                    //           ),
                                    //         ),
                                    //       ),
                                    //     ],
                                    //   ),
                                    // ),
                                  ]),
                            )),
                      );
                    })))));
  }

  bool _phoneValidator(value) => !(value.length > 0 && value.length < 8);
}
