import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../utils/colors.dart';

class LangItem extends StatelessWidget {
  final Function()? onTap;
  final int id,selectedId;
  final String icon;
  final String title;

  const LangItem(
      {super.key,
      required this.id,
      this.onTap,
      required this.icon,
      required this.title, required this.selectedId});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        height: 60,
        padding: const EdgeInsets.symmetric(horizontal: 10),
        margin: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: whiteColor,
          border:
              Border.all(width: 1, color: selectedId == id ? greenColor : whiteColor),
          borderRadius: BorderRadius.circular(10),
          boxShadow: const [
            BoxShadow(
              offset: Offset(0.0, 5.0),
              color: Color(0xffEDEDED),
              blurRadius: 5.0,
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Image.asset(
                  "assets/images/icons/$icon",
                  height: 25,
                  width: 25,
                ),
                const SizedBox(
                  width: 10,
                ),
                Text(
                  title,
                  style: GoogleFonts.poppins(
                      color: blackColor,
                      fontWeight: FontWeight.w400,
                      fontSize: 17),
                )
              ],
            ),
            id == selectedId
                ? Container(
                    height: 30,
                    margin: const EdgeInsets.symmetric(horizontal: 15),
                    padding: const EdgeInsets.all(2),
                    decoration: const BoxDecoration(
                        shape: BoxShape.circle, color: greenColor),
                    child: const Center(
                      child: Icon(
                        Icons.check,
                        size: 14,
                        color: whiteColor,
                      ),
                    ),
                  )
                : Radio(
                  value: id,
                  groupValue: selectedId,
                  activeColor: greenColor,
                  onChanged: (val)=>onTap!(),
                )
          ],
        ),
      ),
    );
  }
}
