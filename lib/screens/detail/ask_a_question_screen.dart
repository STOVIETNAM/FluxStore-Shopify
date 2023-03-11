import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../common/config.dart';
import '../../common/tools/flash.dart';
import '../../generated/l10n.dart';
import '../../models/entities/product.dart';
import '../../models/entities/user.dart';
import '../../models/request_callback_model.dart';
import '../../models/user_model.dart';
import '../../widgets/common/harold_text_field.dart';
import 'widgets/short_product_info.dart' show ShortProductInfo;

class AskAQuestionArgument {
  final Product product;

  const AskAQuestionArgument({required this.product});
}

class AskAQuestionScreen extends StatefulWidget {
  final Product product;
  const AskAQuestionScreen({required this.product, Key? key}) : super(key: key);

  @override
  State<AskAQuestionScreen> createState() => _AskAQuestionScreenState();
}

class _AskAQuestionScreenState extends State<AskAQuestionScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey();

  final TextEditingController _firstNameController = TextEditingController();

  final TextEditingController _lastNameController = TextEditingController();

  final TextEditingController _phoneNumberController = TextEditingController();

  final TextEditingController _typeOfQueryController = TextEditingController();

  User? get user => Provider.of<UserModel>(context, listen: false).user;

  @override
  Widget build(BuildContext context) {
    _firstNameController.text = user?.firstName ?? '';
    _lastNameController.text = user?.lastName ?? '';
    return ChangeNotifierProvider(
      create: (context) => RequestCallbackModel(),
      child: Scaffold(
        backgroundColor: Theme.of(context).backgroundColor,
        appBar: AppBar(
          backgroundColor: Theme.of(context).backgroundColor,
          elevation: 0.0,
          title: Text(
            S.of(context).askAQuestion,
            style: Theme.of(context)
                .textTheme
                .headline6!
                .copyWith(fontWeight: FontWeight.w600),
          ),
        ),
        body: GestureDetector(
          onTap: () {
            FocusScope.of(context).unfocus();
          },
          child: SingleChildScrollView(
              child: Stack(
            alignment: Alignment.center,
            children: [
              Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
                ShortProductInfo(
                  product: widget.product,
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16.0, vertical: 16),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                                child: CustomHaroldTextField(
                              label: S.of(context).firstName,
                              controller: _firstNameController,
                              validator: (val) {
                                if (val!.isEmpty) {
                                  return S.of(context).enterYourFirstName;
                                }
                                return null;
                              },
                              autoFillHints: const [
                                AutofillHints.name,
                                AutofillHints.givenName
                              ],
                            )),
                            const SizedBox(
                              width: 16,
                            ),
                            Expanded(
                                child: CustomHaroldTextField(
                              label: S.of(context).lastName,
                              controller: _lastNameController,
                              validator: (val) {
                                if (val!.isEmpty) {
                                  return S.of(context).enterYourLastNameHint;
                                }
                                return null;
                              },
                              autoFillHints: const [
                                AutofillHints.name,
                                AutofillHints.givenName
                              ],
                            )),
                          ],
                        ),
                        const SizedBox(
                          height: 12,
                        ),
                        CustomHaroldTextField(
                          label: S.of(context).contactNumber,
                          controller: _phoneNumberController,
                          inputType: TextInputType.phone,
                          validator: (val) {
                            if (val!.isEmpty) {
                              return S.of(context).enterYourContactNumberHint;
                            }
                            return null;
                          },
                          autoFillHints: const [AutofillHints.telephoneNumber],
                        ),
                        const SizedBox(
                          height: 12,
                        ),
                        CustomHaroldTextField(
                          label: S.of(context).typeOfQuery,
                          controller: _typeOfQueryController,
                          hintText: S.of(context).typeOfQueryHint,
                          validator: (val) {
                            if (val!.isEmpty) {
                              return S.of(context).typeOfQueryValidator;
                            }
                            return null;
                          },
                          maxLines: 5,
                        ),
                        const SizedBox(
                          height: 16,
                        ),
                        Consumer<RequestCallbackModel>(
                            builder: (context, snapshot, _) {
                          return TextButton(
                            onPressed: () {
                              if (_formKey.currentState!.validate()) {
                                snapshot.requestCallback(
                                    name: _firstNameController.text +
                                        ' ' +
                                        _lastNameController.text,
                                    phoneNumber: _phoneNumberController.text,
                                    inquiry: 'Enquiry for ' +
                                        widget.product.name.toString() +
                                        ' - ' +
                                        _typeOfQueryController.text,
                                    onError: (String error) {
                                      FlashHelper.errorBar(context,
                                          title: S.of(context).error(''),
                                          message: error);
                                    },
                                    onSuccess: () {
                                      Navigator.pop(context);
                                      FlashHelper.successBar(context,
                                          title: S
                                              .of(context)
                                              .submittedSuccessfully,
                                          message: S
                                              .of(context)
                                              .querySubmittedSuccessfully);
                                    });
                              }
                            },
                            style: TextButton.styleFrom(
                                backgroundColor:
                                    Theme.of(context).primaryColor),
                            child: Text(
                              S.of(context).submit,
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyText1!
                                  .copyWith(color: Colors.white, fontSize: 16),
                            ),
                          );
                        }),
                      ],
                    ),
                  ),
                )
              ]),
              Consumer<RequestCallbackModel>(builder: (context, snapshot, _) {
                return snapshot.isLoading
                    ? kLoadingWidget(context)
                    : Container();
              })
            ],
          )),
        ),
      ),
    );
  }

  @override
  void dispose() {
    super.dispose();
    _firstNameController.dispose();
    _lastNameController.dispose();
    _phoneNumberController.dispose();
  }
}
