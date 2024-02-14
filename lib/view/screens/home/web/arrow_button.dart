import 'package:flutter/material.dart';
import 'package:flutter_grocery/view/base/on_hover.dart';

class ArrowIconButton extends StatelessWidget {
  final bool isRight;
  final void Function()? onTap;
  const ArrowIconButton({Key? key, this.isRight = true, this.onTap}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return OnHover(
      child: InkWell(
        onTap: onTap,
        child: Container(
          height: 40, width: 40,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Theme.of(context).cardColor,
            boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 10)],
          ),
          child: Icon(isRight ? Icons.arrow_forward : Icons.arrow_back, color: Theme.of(context).primaryColor, size: 25),
        ),
      ),
    );
  }
}
