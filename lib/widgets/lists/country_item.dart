import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../utils/colors.dart';

class CountryItem extends StatelessWidget {
  final Function()? onTap;
  final String id,selectedId;
  final String title,code;
  final Image image;

  const CountryItem(
      {super.key,
      required this.id,
      this.onTap,
      required this.title, required this.selectedId, required this.code, required this.image});

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
                image,
                const SizedBox(
                  width: 10,
                ),
                SizedBox(
                  width: MediaQuery.of(context).size.width - 172,
                  child: Text(
                    title,
                    maxLines: 1,
                    softWrap: false,
                    overflow: TextOverflow.fade,
                    style: GoogleFonts.poppins(
                        color: blackColor,
                        fontWeight: FontWeight.w400,
                        fontSize: 17),
                  ),
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
