import 'package:cfms/utils/colors.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';


class ItemSetting extends StatelessWidget {
  final String title;
  final String subtitle;
  final String image;
  final Color backgroundColor;
  final IconData icon;
  final Color iconColor;
  final double size;
  final bool isLang;
  const ItemSetting(
      {Key? key,
        required this.title,
        required this.subtitle,
        this.backgroundColor = primaryOverlayColor,
        required this.icon,
        required this.iconColor,
        required this. isLang,
        required this.image,
        this.size = 40})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(top: 5, left: 8, right: 8, bottom: 5),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(size / 2),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,

              children: [
                Container(
                  width: size,
                  height: size,
                  margin: EdgeInsets.all(10),
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(size / 2),
                      color: backgroundColor),
                  child: Icon(
                    icon,
                    color: iconColor,
                    size: size / 2,
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      title,
                      style: GoogleFonts.rubik(
                          color: primaryColor,
                          fontSize: 15,
                          fontWeight: FontWeight.w400),
                    ),
                    SizedBox(height: 5,),
                    Container(
                      width: 200,
                      child: Text(
                        subtitle,
                        style:
                        GoogleFonts.poppins(fontSize: 11, fontWeight: FontWeight.w300),
                      ),
                    ),
                  ],
                )
              ],
            ),
          ),
          isLang ?
          Container( width: 30, height: 30,
            decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: primaryOverlayColor, width: 2),
                image: DecorationImage(
                    image: ExactAssetImage(image),
                    fit: BoxFit.cover)
            ),
          )
              :
          Padding(
            padding: const EdgeInsets.all(10.0),
            child: Icon(Icons.arrow_forward_ios, size: size/3, color: blackColor,),
          )
        ],
      ),
    );
  }
}
