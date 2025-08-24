import 'package:flutter/material.dart';

class OblongLoader extends StatelessWidget {
  final double mWidth;
  final double mHeight;
  final Color bgColor;
  final Color loaderColor;
  final double loaderSize;
  final double borderRadius;
  final Color? borderColor;
  final double borderWidth;

  const OblongLoader({
    super.key,
    this.mWidth = 300,
    this.mHeight = 50,
    this.bgColor = Colors.white,
    this.loaderColor = Colors.white,
    this.loaderSize = 20,
    this.borderRadius = 25,
    this.borderColor,
    this.borderWidth = 1,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: mWidth,
      height: mHeight,
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(borderRadius),
        border: borderColor != null
            ? Border.all(color: borderColor!, width: borderWidth)
            : null,
      ),
      child: Center(
        child: SizedBox(
          width: loaderSize,
          height: loaderSize,
          child: CircularProgressIndicator(
            strokeWidth: 2.5,
            valueColor: AlwaysStoppedAnimation<Color>(loaderColor),
          ),
        ),
      ),
    );
  }
}
