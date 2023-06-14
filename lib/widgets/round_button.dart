import 'package:flutter/material.dart';
import 'package:single_radio/theme.dart';

class RoundButton extends StatelessWidget {
  const RoundButton({
    super.key,
    required this.icon,
    required this.onTap,
    required this.size,
    required this.iconSize,
  });

  final IconData icon;
  final Function() onTap;

  final Size size;
  final double iconSize;

  @override
  Widget build(BuildContext context) {
    return ClipOval(
      child: Material(
        color: AppTheme.controlButtonColor,
        child: InkWell(
          splashColor: AppTheme.controlButtonSplashColor,
          child: SizedBox(
            width: size.width,
            height: size.height,
            child: InkWell(
              splashColor: AppTheme.controlButtonSplashColor,
              onTap: onTap,
              child: Icon(
                icon,
                size: iconSize,
                color: AppTheme.controlButtonIconColor,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
