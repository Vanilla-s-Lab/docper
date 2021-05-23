import 'package:flutter/material.dart';

class BorderedContainer extends StatelessWidget {
  final Widget child;

  const BorderedContainer({Key key, this.child}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        border: Border.all(
          color: Colors.blue,
          width: 2.0,
        ),
      ),
      child: child,
    );
  }
}
