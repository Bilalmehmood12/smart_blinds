import 'package:flutter/material.dart';

class CustomMenuIconButton extends StatelessWidget {
  final double size;
  final Color color;
  final Function onTap;
  const CustomMenuIconButton({
    Key key, this.size = 25, this.color = Colors.grey, this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap == null ? (){}: onTap,
      child: Container(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  height: 3 * (size/25),
                  width: 25 * (size/25),
                  color: color,
                ),
                SizedBox(height: 5 * (size/25),),
                Container(
                  height: 3 * (size/25),
                  width: 20 * (size/25),
                  color: color,
                ),
                SizedBox(height: 5 * (size/25),),
                Container(
                  height: 3 * (size/25),
                  width: 30 * (size/25),
                  color: color,
                ),
                SizedBox(height: 5 * (size/25),),
                Container(
                  height: 3 * (size/25),
                  width: 25 * (size/25),
                  color: color,
                )
              ],
            ),
          ],
        ),
      ),
    );
  }
}
