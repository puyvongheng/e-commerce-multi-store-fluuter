import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/map_store_controller.dart';

class MapControlButtons extends StatelessWidget {
  const MapControlButtons({super.key});

  @override
  Widget build(BuildContext context) {
    final MapStoreController controller = Get.find();

    return Positioned(
      right: 20,
      top: 120,
      child: Column(
        children: [
          _ControlButton(
            icon: Icons.my_location,
            onPressed: controller.moveToUserLocation,
            heroTag: 'location_btn',
          ),
          const SizedBox(height: 12),
          _ControlButton(
            icon: Icons.near_me,
            onPressed: controller.findNearbyStores,
            heroTag: 'nearby_btn',
            color: Colors.blue,
          ),
        ],
      ),
    );
  }
}

class _ControlButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onPressed;
  final String heroTag;
  final Color? color;

  const _ControlButton({
    required this.icon,
    required this.onPressed,
    required this.heroTag,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(
      heroTag: heroTag,
      onPressed: onPressed,
      backgroundColor: Colors.white,
      mini: true,
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Icon(icon, color: color ?? Colors.black87),
    );
  }
}
