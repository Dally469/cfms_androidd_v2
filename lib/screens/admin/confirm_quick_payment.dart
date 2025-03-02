import 'package:cfms/screens/admin/admin.dashboard.screen.dart';
import 'package:cfms/services/db/db_helper.dart';
import 'package:cfms/services/provider/donation_provider.dart';
import 'package:cfms/widgets/buttons/button.dart';
import 'package:cfms/widgets/texts/heading.dart';
import 'package:cfms/utils/colors.dart';
import 'package:cfms/utils/routes.dart';
import 'package:flutter/material.dart';
import 'package:flutter_translate/flutter_translate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class ConfirmQuickPayment extends StatefulWidget {
  final double totalAmount;
  final String countryCurrency;
  final String memberName;
  final String memberPhone;
  const ConfirmQuickPayment(
      {Key? key,
      required this.totalAmount,
      required this.countryCurrency,
      required this.memberName,
      required this.memberPhone})
      : super(key: key);

  @override
  State<ConfirmQuickPayment> createState() => _ConfirmQuickPaymentState();
}

class _ConfirmQuickPaymentState extends State<ConfirmQuickPayment> {
  String title = '';
  final DbHelper _dbHelper = DbHelper();
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
        create: (_) => DonationProvider(),
        child: Builder(builder: (BuildContext context) {
          return MaterialApp(
            debugShowCheckedModeBanner: false,
            home: Scaffold(
              backgroundColor: whiteColor,
              appBar: AppBar(
                backgroundColor: whiteColor,
                elevation: 0,
                leading: InkWell(
                    onTap: () {
                        Navigator.push(
                          context, MyPageRoute(widget: AdminDashboard()));
                    },
                    child: const Icon(
                      Icons.arrow_back,
                      color: primaryColor,
                    )),
              ),
              body: Center(
                child: SingleChildScrollView(
                  child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Image.asset(
                          "assets/images/logo/success_two.gif",
                          scale: 2,
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(
                              vertical: 0, horizontal: 30),
                          child: Text(
                            widget.memberName,
                            textAlign: TextAlign.center,
                            style: GoogleFonts.poppins(
                                color: blackColor,
                                fontWeight: FontWeight.w400,
                                fontSize: 20),
                          ),
                        ),
                        Heading(
                            title: translate("app_txt_thanks"),
                            subtitle: translate("app_txt_success_payment")),
                        Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 30, vertical: 10),
                          child: Text(
                            "${widget.countryCurrency} ${widget.totalAmount.toStringAsFixed(1)}",
                            style: GoogleFonts.poppins(
                                fontWeight: FontWeight.w600,
                                fontSize: 45,
                                color: greenColor),
                          ),
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            InkWell(
                                onTap: () {
                                  Navigator.pop(context);
                                },
                                child: const ActiveButton(
                                    icon: Icons.arrow_back,
                                    backgroundColor: primaryColor,
                                    width: 130,
                                    title: "Continue")),
                          ],
                        )
                      ]),
                ),
              ),
              bottomNavigationBar: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset(
                    "assets/images/logo/logo.png",
                    scale: 2,
                    height: 50,
                    color: primaryOverlayColor,
                    width: 50,
                  ),
                ],
              ),
            ),
          );
        }));
  }
}
