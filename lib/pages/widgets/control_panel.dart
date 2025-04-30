import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hci/controllers/smartkitcontroller.dart';
import 'package:hci/pages/widgets/toggle_button.dart';

final _controller = Get.find<SmartKitController>();

class ControlPanel extends StatelessWidget {
  const ControlPanel({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      spacing: 5,
      children: [
        Column(
          spacing: 5,
          children: [
            ToggleButton(
              obs: SmartKitState.whiteLed,
              toggledIcon: Icons.lightbulb, 
              untoggledIcon: Icons.lightbulb_outline, 
              onToggle: (value) => 
                value ? 
                  _controller.write(SmartKitCommand.whiteLedOn.valueAndSetState) 
                : 
                  _controller.write(SmartKitCommand.whiteLedOff.valueAndSetState)
            ),

            ToggleButton(
              obs: SmartKitState.door,
              toggledIcon: Icons.sensor_door,
              untoggledIcon: Icons.sensor_door_outlined,
              onToggle: (value) => 
              value ? 
                _controller.write(SmartKitCommand.doorOpen.valueAndSetState) 
              : 
                _controller.write(SmartKitCommand.doorClose.valueAndSetState),
            ),

            ToggleButton(
              obs: SmartKitState.window,
              toggledIcon: Icons.sensor_window,
              untoggledIcon: Icons.sensor_window_outlined,
              onToggle: (value) => 
              value ? 
                _controller.write(SmartKitCommand.windowOpen.valueAndSetState) 
              : 
                _controller.write(SmartKitCommand.windowClose.valueAndSetState),
            )
          ]
        ),
        Column(
          spacing: 5,
          children: [
            ToggleButton(
              obs: SmartKitState.fan,
              toggledIcon: Icons.wind_power, 
              untoggledIcon: Icons.wind_power_outlined, 
              onToggle: (value) =>
              value ?
                _controller.write(SmartKitCommand.fanStart.valueAndSetState)
              :
                _controller.write(SmartKitCommand.fanStop.valueAndSetState)
            ),

            ToggleButton(
              obs: SmartKitState.yellowLed,
              toggledIcon: Icons.wb_incandescent, 
              untoggledIcon: Icons.wb_incandescent_outlined, 
              onToggle: (value) =>
              value ?
                _controller.write(SmartKitCommand.yellowLedOn.valueAndSetState)
              :
                _controller.write(SmartKitCommand.yellowLedOff.valueAndSetState)
            ),

            IconButton.filled(
              onPressed: () => _controller.write(SmartKitCommand.routine([
                SmartKitCommand.whiteLedOn,
                SmartKitCommand.doorOpen,
                SmartKitCommand.windowOpen,
                SmartKitCommand.fanStart,
                SmartKitCommand.yellowLedOn
              ])), 
              icon: Icon(Icons.play_arrow),
              iconSize: 50,
            )
          ],
        )
      ],
    );
  }
}