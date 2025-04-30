import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ToggleButton extends StatefulWidget {
  const ToggleButton({super.key, required this.toggledIcon, required this.untoggledIcon, required this.onToggle, this.obs});

  final IconData toggledIcon;
  final IconData untoggledIcon;
  final void Function(bool) onToggle;
  final RxBool? obs;
  
  @override
  State<ToggleButton> createState() => _ToggleButtonState();
}

class _ToggleButtonState extends State<ToggleButton> {
  var _toggled = false.obs;

  @override
  void initState() {
    _toggled = widget.obs ?? false.obs;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() => Ink(
      decoration: ShapeDecoration(
        shape: const CircleBorder(), 
        color: _toggled.value ? Theme.of(context).colorScheme.primary : Theme.of(context).disabledColor
      ),
      child: IconButton(
        onPressed: () {
          _toggled.value = !_toggled.value;
          widget.onToggle(_toggled.value);
        }, 
        icon: Icon(_toggled.value ? widget.toggledIcon : widget.untoggledIcon,
          color: _toggled.value ? Theme.of(context).colorScheme.onPrimary : Theme.of(context).disabledColor,
        ),
        iconSize: 50,
      ),
    ));
  }
}