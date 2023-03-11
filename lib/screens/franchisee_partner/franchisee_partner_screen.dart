import 'package:flutter/material.dart';
import '../../generated/l10n.dart';
import '../../widgets/common/index.dart';

class FranchiseePartnerScreen extends StatefulWidget {
  const FranchiseePartnerScreen({Key? key}) : super(key: key);

  @override
  State<FranchiseePartnerScreen> createState() =>
      _FranchiseePartnerScreenState();
}

class _FranchiseePartnerScreenState extends State<FranchiseePartnerScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).backgroundColor,
      body: WebView(
        url: 'https://haroldelectricals.com/pages/partner',
        title: S.of(context).franchiseePartner,
      ),
    );
  }
}
