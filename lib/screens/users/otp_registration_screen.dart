// ignore_for_file: avoid_print

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pinput/pinput.dart';
import 'package:provider/provider.dart';
import '../../app.dart';
import '../../common/constants.dart';
import '../../common/tools/flash.dart';
import '../../common/tools/tools.dart';
import '../../generated/l10n.dart';
import '../../models/entities/newuser.dart';
import '../../models/newuser_model.dart';
import '../../modules/firebase/dynamic_link_service.dart';
import '../../modules/firebase/firebase_analytics_service.dart';
import 'registration_final_screen.dart';

class OTPRegistrationScreen extends StatefulWidget {
  final String countryCode;
  final String phoneNumber;
  const OTPRegistrationScreen(
      {required this.countryCode, required this.phoneNumber, Key? key})
      : super(key: key);

  @override
  State<OTPRegistrationScreen> createState() => _OTPRegistrationScreenState();
}

class _OTPRegistrationScreenState extends State<OTPRegistrationScreen> {
  final TextEditingController _pinController = TextEditingController();
  String currentVerificationId = '';
  FirebaseAuth auth = FirebaseAuth.instance;
  List<Customer> customer = [];

  @override
  void dispose() {
    super.dispose();
    _pinController.dispose();
  }

  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      _sendOTP(widget.countryCode, widget.phoneNumber);
    });
    super.initState();
  }

  // ignore: always_declare_return_types
  checkUserExists(String phone) async {
    customer = await Provider.of<NewUserModel>(context, listen: false)
        .searchNewUser(phone);
  }

  // ignore: always_declare_return_types
  _sendOTP(String countryCode, String phone) async {
    await FirebaseAuth.instance.verifyPhoneNumber(
      timeout: const Duration(seconds: 30),
      phoneNumber: countryCode + phone,
      verificationCompleted: (PhoneAuthCredential credential) {},
      verificationFailed: (FirebaseAuthException e) {
        if (e.code == 'invalid-phone-number') {
          FlashHelper.actionBar(
            context,
            title: 'Error',
            presistent: true,
            duration: const Duration(seconds: 3),
            message: 'The provided phone number is not valid',
            onPrimaryActionTap: ((controller) {}),
            primaryAction: const SizedBox(),
          );
        } else {
          FlashHelper.actionBar(
            context,
            title: 'Error',
            presistent: true,
            duration: const Duration(seconds: 3),
            message: e.message ?? '',
            onPrimaryActionTap: ((controller) {}),
            primaryAction: const SizedBox(),
          );
        }
      },
      codeSent: (String verificationId, int? resendToken) {
        currentVerificationId = verificationId;
      },
      codeAutoRetrievalTimeout: (String verificationId) {},
    );
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
                child: DefaultTextStyle(
                  style: Theme.of(context).textTheme.bodyText1!,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 30),
                    decoration: const BoxDecoration(
                        image: DecorationImage(
                            image: AssetImage('assets/images/login_bg.jpeg'),
                            fit: BoxFit.cover)),
                    child: Column(
                        mainAxisAlignment: MainAxisAlignment.end,
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: <Widget>[
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const SizedBox(height: 10.0),
                                Text(
                                  S.of(context).verification,
                                  style: const TextStyle(
                                      fontSize: 14,
                                      color: Colors.grey,
                                      fontWeight: FontWeight.w300),
                                ),
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                      vertical: 12.0),
                                  child: Text(
                                    S.of(context).weSentYouSmsCode,
                                    style: const TextStyle(fontSize: 24),
                                  ),
                                ),
                                RichText(
                                  textAlign: TextAlign.center,
                                  text: TextSpan(
                                      text: S.of(context).onNumber,
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodyText1!
                                          .copyWith(
                                              fontSize: 14, color: Colors.grey),
                                      children: [
                                        TextSpan(
                                            text: widget.phoneNumber,
                                            style: TextStyle(
                                              color: Theme.of(context)
                                                  .primaryColor,
                                            ))
                                      ]),
                                ),
                              ],
                            ),
                          ),
                          Expanded(
                            flex: 2,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Pinput(
                                    length: 6,
                                    autofocus: true,
                                    showCursor: true,
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceEvenly,
                                    controller: _pinController,
                                    closeKeyboardWhenCompleted: true,
                                    obscureText: false,
                                    inputFormatters: [
                                      FilteringTextInputFormatter.digitsOnly
                                    ],
                                    defaultPinTheme: _getPinTheme(context),
                                    // ignore: unnecessary_lambdas
                                    onCompleted: (val) async {
                                      try {
                                        print('Reg OTP Success');
                                        // ignore: omit_local_variable_types
                                        PhoneAuthCredential credential =
                                            PhoneAuthProvider.credential(
                                                verificationId:
                                                    currentVerificationId,
                                                smsCode: val);
                                        await auth
                                            .signInWithCredential(credential);
                                        await checkUserExists(
                                            widget.phoneNumber);

                                        if (customer.isEmpty) {
                                          FirebaseAnalyticsService.signUp();

                                          await Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) =>
                                                  RegistrationFinalScreen(
                                                      countryCode:
                                                          widget.countryCode,
                                                      phoneNumber:
                                                          widget.phoneNumber),
                                            ),
                                          );
                                        } else {
                                          FirebaseAnalyticsService.login();
                                          await Navigator.of(
                                            App.fluxStoreNavigatorKey
                                                .currentContext!,
                                          ).pushNamedAndRemoveUntil(
                                            RouteList.dashboard,
                                            (route) => false,
                                          );
                                        }
                                      } catch (e) {
                                        print('Incorrect OTP');
                                        // await FlashHelper.toast(
                                        //     'Incorrect OTP');
                                        await FlashHelper.actionBar(
                                          context,
                                          title: 'Invalid OTP',
                                          presistent: true,
                                          duration: const Duration(seconds: 3),
                                          message:
                                              'You need to enter a valid OTP.',
                                          onPrimaryActionTap: ((controller) {
                                            _pinController.clear();
                                            //Navigator.pop(context);
                                          }),
                                          primaryAction: const Text(
                                            'Clear OTP',
                                            style:
                                                TextStyle(color: Colors.white),
                                          ),
                                        );
                                      }
                                    }),
                                const SizedBox(
                                  height: 24,
                                ),
                                Text(
                                  S.of(context).codeNotReceived,
                                  style: const TextStyle(
                                      color: Color.fromARGB(255, 2, 1, 1)),
                                ),
                                GestureDetector(
                                  onTap: () {
                                    _sendOTP(
                                        widget.countryCode, widget.phoneNumber);
                                  },
                                  child: Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Text(
                                      S.of(context).sendAgain,
                                      style: const TextStyle(
                                        color: Color.fromARGB(255, 2, 1, 1),
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ]),
                  ),
                ))));
  }

  PinTheme _getPinTheme(BuildContext context) => PinTheme(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      textStyle: const TextStyle(fontSize: 24),
      constraints: const BoxConstraints(maxHeight: 64, maxWidth: 64),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey[300]!),
        borderRadius: BorderRadius.circular(5),
      ));
}
