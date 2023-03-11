import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:harold/modules/firebase/firebase_analytics_service.dart';
import 'package:provider/provider.dart';

import '../../common/config.dart';
import '../../common/tools/flash.dart';
import '../../common/tools/tools.dart';
import '../../generated/l10n.dart';
import '../../models/request_callback_model.dart';
import '../../models/user_model.dart';

class RequestCallbackScreen extends StatefulWidget {
  const RequestCallbackScreen({Key? key}) : super(key: key);

  @override
  _RequestCallbackScreenState createState() => _RequestCallbackScreenState();
}

class _RequestCallbackScreenState extends State<RequestCallbackScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _mobileNumberController = TextEditingController();
  final TextEditingController _typeOfQueries = TextEditingController();

  @override
  void initState() {
    super.initState();
    SchedulerBinding.instance.addPostFrameCallback((timeStamp) {
      final user = Provider.of<UserModel>(context, listen: false).user;
      if (user != null) {
        _nameController.text = user.fullName;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => RequestCallbackModel(),
      child: Stack(
        children: [
          _BaseRequestCallbackScreen(
              topAreaChild: Image.asset('assets/images/support.png'),
              bottomChild: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Center(
                      child: Text(S.of(context).requestForCallback,
                          textAlign: TextAlign.center,
                          style: Theme.of(context)
                              .textTheme
                              .headlineSmall
                              ?.copyWith(fontWeight: FontWeight.w900)),
                    ),
                    const SizedBox(
                      height: 50,
                    ),
                    _RequestCallBackTextField(
                      controller: _nameController,
                      autoFillHints: const [AutofillHints.name],
                      inputType: TextInputType.name,
                      autoValidateMode: AutovalidateMode.onUserInteraction,
                      validator: (String? name) {
                        if (name!.isEmpty) {
                          return 'Please enter your name';
                        }
                        return null;
                      },
                      hint: S.of(context).enterYourName,
                    ),
                    const SizedBox(
                      height: 28,
                    ),
                    Consumer<RequestCallbackModel>(
                        builder: (context, snapshot, _) {
                      return _RequestCallBackTextField(
                        controller: _mobileNumberController,
                        autoFillHints: const [AutofillHints.telephoneNumber],
                        inputType: TextInputType.phone,
                        autoValidateMode: AutovalidateMode.onUserInteraction,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly
                        ],
                        validator: (String? phoneNumber) {
                          return snapshot.validateMobile(phoneNumber!);
                        },
                        hint: S.of(context).enterYourMobile,
                      );
                    }),
                    const SizedBox(
                      height: 28,
                    ),
                    Consumer<RequestCallbackModel>(
                        builder: (context, snapshot, _) {
                      return Container(
                        color: Colors.grey[200],
                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                        child: DropdownButtonHideUnderline(
                            child: DropdownButton<String>(
                                value: snapshot.selectedInquiry,
                                dropdownColor: Colors.grey[200],
                                hint: Text(
                                    S.of(context).typeOfQueries.toUpperCase(),
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodyText1!
                                        .copyWith(color: Colors.grey[500])),
                                onChanged: (String? val) {
                                  snapshot.setSelectedInquiry(val!);
                                },
                                items: snapshot.enquiryDropdownData
                                    .map((String val) {
                                  return DropdownMenuItem<String>(
                                    value: val,
                                    child: Text(val,
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodyText1!),
                                  );
                                }).toList())),
                      );
                    }),
                    const SizedBox(
                      height: 48,
                    ),
                    Consumer<RequestCallbackModel>(
                        builder: (context, snapshot, _) {
                      return TextButton(
                        onPressed: () {
                          if (_formKey.currentState!.validate()) {
                            snapshot.requestCallback(
                                name: _nameController.text,
                                phoneNumber: _mobileNumberController.text,
                                onError: (String error) {
                                  FlashHelper.errorBar(context,
                                      title: 'Error', message: error);
                                },
                                onSuccess: () {
                                  FirebaseAnalyticsService.requestCallBack();

                                  Navigator.pushReplacement(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) =>
                                              const _RequestCallbackSuccessfulScreen()));
                                });
                          }
                        },
                        style: TextButton.styleFrom(
                            backgroundColor: Theme.of(context).primaryColor),
                        child: Text(
                          S.of(context).submit.toUpperCase(),
                          style: const TextStyle(
                              color: Colors.white, fontWeight: FontWeight.bold),
                        ),
                      );
                    }),
                  ],
                ),
              )),
          Consumer<RequestCallbackModel>(builder: (context, snapshot, _) {
            return snapshot.isLoading ? kLoadingWidget(context) : Container();
          })
        ],
      ),
    );
  }

  @override
  void dispose() {
    super.dispose();
    _nameController.dispose();
    _mobileNumberController.dispose();
    _typeOfQueries.dispose();
  }
}

class _BaseRequestCallbackScreen extends StatelessWidget {
  final Widget topAreaChild;
  final Widget bottomChild;
  const _BaseRequestCallbackScreen(
      {required this.topAreaChild, required this.bottomChild, Key? key})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: SingleChildScrollView(
            child: Stack(clipBehavior: Clip.none, children: [
      topAreaChild,
      Align(
          alignment: Alignment.bottomCenter,
          child: Container(
              height: MediaQuery.of(context).size.height * 0.7,
              margin: EdgeInsets.only(
                  top: MediaQuery.of(context).size.height * 0.3),
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 32),
              decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(32),
                      topRight: Radius.circular(32))),
              child: bottomChild))
    ])));
  }
}

class _RequestCallBackTextField extends StatelessWidget {
  final TextEditingController controller;
  final List<String>? autoFillHints;
  final List<TextInputFormatter>? inputFormatters;
  final TextInputType inputType;
  final String? hint;
  final AutovalidateMode? autoValidateMode;
  final String? Function(String? value)? validator;

  const _RequestCallBackTextField(
      {required this.controller,
      this.autoFillHints,
      this.inputType = TextInputType.text,
      this.hint,
      this.inputFormatters,
      this.autoValidateMode,
      this.validator,
      Key? key})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      autofillHints: autoFillHints,
      validator: validator,
      textInputAction: TextInputAction.next,
      inputFormatters: inputFormatters,
      keyboardType: inputType,
      autovalidateMode: autoValidateMode,
      style: Theme.of(context).textTheme.bodyText1!.copyWith(),
      decoration: InputDecoration(
        hintText: hint?.toUpperCase(),
        filled: true,
        border: InputBorder.none,
        hintStyle: TextStyle(color: Colors.grey[500]),
        fillColor: Colors.grey[200],
      ),
    );
  }
}

class _RequestCallbackSuccessfulScreen extends StatefulWidget {
  const _RequestCallbackSuccessfulScreen({Key? key}) : super(key: key);

  @override
  __RequestCallbackSuccessfulScreenState createState() =>
      __RequestCallbackSuccessfulScreenState();
}

class __RequestCallbackSuccessfulScreenState
    extends State<_RequestCallbackSuccessfulScreen> {
  @override
  Widget build(BuildContext context) {
    return _BaseRequestCallbackScreen(
        topAreaChild: Container(
          color: Colors.grey[400],
          height: MediaQuery.of(context).size.height,
          width: double.infinity,
          child: Padding(
            padding: EdgeInsets.symmetric(
                vertical: MediaQuery.of(context).size.height * 0.1),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  S.of(context).thankYou.toUpperCase(),
                  style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w900,
                      fontSize:
                          Theme.of(context).textTheme.headlineLarge!.fontSize),
                ),
                const SizedBox(
                  height: 8,
                ),
                Text(
                  'Our team will get in touch with you shortly',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      color: Colors.white,
                      fontSize:
                          Theme.of(context).textTheme.bodyText1!.fontSize),
                ),
              ],
            ),
          ),
        ),
        bottomChild: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(
              child: Text(
                  'We are excited to hear from you and will connect with you shortly. Please feel free to get in touch with us in case you have any urgent requirement which needs to be addressed.',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyText1?.copyWith(
                        color: Colors.grey,
                      )),
            ),
            const SizedBox(
              height: 50,
            ),
            TextButton(
              onPressed: () {
                Tools.launchURL('tel:+919971772611');
              },
              style: TextButton.styleFrom(
                  backgroundColor: Theme.of(context).primaryColor),
              child: Text(
                S.of(context).callUs.toUpperCase(),
                style: const TextStyle(
                    color: Colors.white, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ));
  }
}
