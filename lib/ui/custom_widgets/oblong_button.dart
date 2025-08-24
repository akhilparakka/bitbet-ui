import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class OblongButton extends StatelessWidget {
  final VoidCallback? onTap;
  final double mWidth;
  final double mHeight;
  final Color bgColor;
  final String text;
  final Color textColor;
  final String? mIconPath;
  final double fontSize;
  final FontWeight fontWeight;
  final double iconSize;
  final Color? borderColor;
  final double borderWidth;
  final bool isLoading; // 👈 NEW

  const OblongButton({
    super.key,
    required this.onTap,
    required this.text,
    this.mIconPath,
    this.textColor = Colors.black,
    this.mWidth = 300,
    this.mHeight = 50,
    this.bgColor = Colors.white,
    this.fontSize = 16,
    this.fontWeight = FontWeight.w500,
    this.iconSize = 20,
    this.borderColor,
    this.borderWidth = 1,
    this.isLoading = false, // 👈 default false
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: isLoading ? null : onTap, // disable tap while loading
      borderRadius: BorderRadius.circular(25),
      child: Container(
        width: mWidth,
        height: mHeight,
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(25),
          border: borderColor != null
              ? Border.all(color: borderColor!, width: borderWidth)
              : null,
        ),
        child: Center(
          child: isLoading
              ? const SizedBox(
                  width: 22,
                  height: 22,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.5,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                )
              : Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (mIconPath != null && text.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(right: 12.0),
                        child: SvgPicture.asset(
                          mIconPath!,
                          width: iconSize,
                          height: iconSize,
                        ),
                      ),
                    Text(
                      text,
                      style: TextStyle(
                        color: textColor,
                        fontSize: fontSize,
                        fontWeight: fontWeight,
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }
}
