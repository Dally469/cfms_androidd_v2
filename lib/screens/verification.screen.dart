import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:flutter_translate/flutter_translate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pinput/pinput.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../utils/colors.dart';
import '../../utils/routes.dart';
import '../widgets/texts/heading.dart';
import 'member/dashboard.screen.dart';

class Verification extends StatefulWidget {
  final String memberId;
  final String memberName;
  final String sysMember;
  final String sysChurch;
  final String sysGroup;
  final String otp;
  final String phone;
  const Verification(
      {Key? key,
      required this.memberId,
      required this.sysMember,
      required this.sysChurch,
      required this.sysGroup,
      required this.otp,
      required this.phone,
      required this.memberName})
      : super(key: key);

  @override
  State<Verification> createState() => _VerificationState();
}

class _VerificationState extends State<Verification> {
  final pinController = TextEditingController();
  final focusNode = FocusNode();
  final formKey = GlobalKey<FormState>();
  bool _isSettingDashboard = false;
  bool _isLoading = false;
  String? userId;

  @override
  void initState() {
    super.initState();
    userId = widget.memberId.toString();
  }

  settingUpDashboard() async {
    if (formKey.currentState!.validate()) {
      setState(() {
        _isLoading = false;
        _isSettingDashboard = true;
      });
      // Member isRegister
      final prefs = await SharedPreferences.getInstance();
      prefs.setString('current_member', widget.sysMember);
      prefs.setString('current_church', widget.sysChurch);
      prefs.setString('current_group', widget.sysGroup);
      prefs.setBool('showHome', true);

      Future.delayed(const Duration(seconds: 3), () {
        setState(() {
          _isSettingDashboard = false;
        });
        Navigator.pushAndRemoveUntil(
            context, MyPageRoute(widget: const Dashboard()), (Route) => false);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    const focusedBorderColor = Color.fromRGBO(23, 171, 144, 1);
    const fillColor = Color.fromRGBO(243, 246, 249, 0);
    const borderColor = Color.fromRGBO(23, 171, 144, 0.4);

    final defaultPinTheme = PinTheme(
      width: 56,
      height: 56,
      textStyle: const TextStyle(
        fontSize: 22,
        color: Color.fromRGBO(30, 60, 87, 1),
      ),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(19),
        border: Border.all(color: borderColor),
      ),
    );
    return MaterialApp(
        debugShowCheckedModeBanner: false,
        home: Material(
            child: Stack(
          children: [
            Scaffold(
              backgroundColor: Colors.white,
              appBar: AppBar(
                backgroundColor: Colors.white,
                elevation: 0,
                toolbarHeight: 70,
                leading: InkWell(
                    onTap: () {
                      Navigator.of(context).pop(true);
                    },
                    child: const Icon(
                      Icons.arrow_back,
                      color: primaryColor,
                    )),
              ),
              body: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const SizedBox(
                        height: 50,
                      ),
                      Image.asset(
                        "assets/images/logo/otp.png",
                        scale: 9,
                      ),
                      const SizedBox(
                        height: 20,
                      ),
                      Heading(
                          title: translate('app_txt_verification'),
                          subtitle:
                              translate('app_txt_choose_church_for_donate')),
                      Padding(
                        padding: const EdgeInsets.symmetric(
                            vertical: 0, horizontal: 30),
                        child: Text(
                          "+${widget.phone}",
                          textAlign: TextAlign.center,
                          style: GoogleFonts.poppins(
                              color: primaryColor,
                              fontWeight: FontWeight.w500,
                              fontSize: 20),
                        ),
                      ),
                      const SizedBox(
                        height: 30,
                      ),
                      Form(
                        key: formKey,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Pinput(
                              controller: pinController,
                              focusNode: focusNode,
                           
                              defaultPinTheme: defaultPinTheme,
                              validator: (value) {
                                return value == widget.otp
                                    ? null
                                    : translate('app_txt_incorrect_otp_sms');
                              },
                              hapticFeedbackType:
                                  HapticFeedbackType.lightImpact,
                              onCompleted: (pin) {
                                debugPrint('onCompleted: $pin');
                                settingUpDashboard();
                              },
                              onChanged: (value) {
                                debugPrint('onChanged: $value');
                              },
                              cursor: Column(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  Container(
                                    margin: const EdgeInsets.only(bottom: 9),
                                    width: 22,
                                    height: 1,
                                    color: focusedBorderColor,
                                  ),
                                ],
                              ),
                              focusedPinTheme: defaultPinTheme.copyWith(
                                decoration:
                                    defaultPinTheme.decoration!.copyWith(
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(color: focusedBorderColor),
                                ),
                              ),
                              submittedPinTheme: defaultPinTheme.copyWith(
                                decoration:
                                    defaultPinTheme.decoration!.copyWith(
                                  color: fillColor,
                                  borderRadius: BorderRadius.circular(19),
                                  border: Border.all(color: focusedBorderColor),
                                ),
                              ),
                              errorPinTheme: defaultPinTheme.copyBorderWith(
                                border: Border.all(color: Colors.redAccent),
                              ),
                            ),
                            const SizedBox(
                              height: 70,
                            ),
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 10),
                              child: Text(
                                translate('app_txt_resend_code_not'),
                                textAlign: TextAlign.center,
                                style: GoogleFonts.poppins(
                                    color: blackColor,
                                    fontWeight: FontWeight.w200,
                                    fontSize: 13),
                              ),
                            ),
                            TextButton(
                                onPressed: () {},
                                child: Text(
                                  translate('app_txt_resend_code'),
                                  textAlign: TextAlign.center,
                                  style: GoogleFonts.poppins(
                                      color: primaryColor,
                                      fontWeight: FontWeight.w300,
                                      fontSize: 15),
                                )),
                          ],
                        ),
                      )
                    ],
                  ),
                ),
              ),
            ),
            Visibility(
              visible: _isSettingDashboard,
              child: Positioned(
                  child: Column(
                children: [
                  Container(
                    width: MediaQuery.of(context).size.width,
                    height: MediaQuery.of(context).size.height,
                    color: transparentColor2,
                    child: const Center(
                      child: SpinKitFadingCube(
                        color: whiteColor,
                        size: 50,
                      ),
                    ),
                  )
                ],
              )),
            ),
          ],
        )));
  }
}
