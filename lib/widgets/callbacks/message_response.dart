import 'package:cfms/utils/colors.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
class MessageResponse extends StatelessWidget {
  final IconData icon;
  final String msgTitle;
  final String msgDesc;
  final String refNo;
  final Color color;
  final Color backgroundColor;
  const MessageResponse({Key? key, required this.icon, required this.msgTitle, required this.msgDesc, required this.color, required this.backgroundColor, required this.refNo}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 20, horizontal: 30),
      width: MediaQuery.of(context).size.width,
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(6)
      ),
      child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Icon(icon, size: 30, color: color,),
          ),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(top:10,),
                child: Text(
                  msgTitle,
                  textAlign: TextAlign.left,
                  style: GoogleFonts.poppins(
                      color: color, fontWeight: FontWeight.w500, fontSize: 13),
                ),
              ),
              Visibility(
                visible: refNo.isNotEmpty,
                child: SizedBox(
                  width: 220,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 3),
                    child: Text(
                      "Ref No: $refNo",
                      textAlign: TextAlign.left,
                      style: GoogleFonts.poppins(
                          color: color, fontWeight: FontWeight.w500, fontSize: 13),
                    ),
                  ),
                ),
              ),
              SizedBox(
                width: 220,
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 3),
                  child: Text(
                    msgDesc,
                    textAlign: TextAlign.left,
                    style: GoogleFonts.poppins(
                        color: color, fontWeight: FontWeight.w300, fontSize: 12),
                  ),
                ),
              ),
              const SizedBox(
                height: 10,
              ),

            ],
          ),
        ],
      ),
    );
  }
}
