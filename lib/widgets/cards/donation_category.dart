import 'package:cfms/widgets/buttons/state_button_outlined.dart';
import 'package:cfms/utils/colors.dart';
import 'package:cfms/utils/routes.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class DonationCategoryCard extends StatelessWidget {
  final Color backgroundColor;
  final String title;
  final String amount;
  final String lastDate;
  const DonationCategoryCard({
    Key? key,
    required this.title,
    required this.amount,
    required this.lastDate,
    this.backgroundColor = whiteColor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Expanded(
      flex: 1,
      child: InkWell(
        onTap: (){
          // Navigator.push( context, MyPageRoute(widget:  DonationHistoryDetails(categoryId: 1)));
        },
        child: Container(
          width: MediaQuery.of(context).size.width,
          padding: const EdgeInsets.all(6),
          margin: const EdgeInsets.symmetric(horizontal: 5, vertical: 5),
          decoration: BoxDecoration(
            color: backgroundColor,
            borderRadius: BorderRadius.circular(10),
            boxShadow: [
              new BoxShadow(
                offset: const Offset(0.0, 5.0),
                color: const Color(0xffEDEDED),
                blurRadius: 5.0,
              ),
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
                child: Text(
                  title,
                  style: GoogleFonts.poppins(
                      color: blackColor, fontWeight: FontWeight.w500, fontSize: 16),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                child: Text(
                  amount,
                  style: GoogleFonts.poppins(
                      color: blackColor, fontWeight: FontWeight.bold, fontSize: 25),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 0),
                child: Text(
                  "Last date: "+lastDate,
                  style: GoogleFonts.poppins(
                      color: blackColor, fontWeight: FontWeight.w400, fontSize: 12),
                ),
              ),
              const SizedBox(height: 3,),
              StateOutlinedButton(backgroundColor: whiteColor, title: "View", clicked: false,)
            ],
          ),
        ),
      ),
    );
  }
}
