import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:get/get.dart';
import '../controllers/map_store_controller.dart';
import 'package:app1/services/api_constants.dart';

// Import refactored components
import '../widgets/map/store_marker_widget.dart';
import '../widgets/map/selected_store_card_widget.dart';
import '../widgets/map/map_control_buttons.dart';

class MapStorePage extends StatelessWidget {
  const MapStorePage({super.key});

  String _getImageUrl(String? imagePath) {
    if (imagePath == null || imagePath.isEmpty) return '';
    if (imagePath.startsWith('http')) return imagePath;
    final baseUrl = ApiConstants.baseUrl.replaceAll('/api', '');
    return "$baseUrl/uploads/$imagePath";
  }

  @override
  Widget build(BuildContext context) {
    // Initialize controller if not already
    final controller = Get.put(MapStoreController());

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: _buildAppBar(),
      body: Stack(
        children: [
          // 1. Map Layer
          Obx(() => FlutterMap(
                mapController: controller.mapController,
                options: MapOptions(
                  initialCenter: const LatLng(11.5564, 104.9282),
                  initialZoom: 13,
                  onTap: (_, __) => controller.selectedStore.value = null,
                ),
                children: [
                  TileLayer(
                    urlTemplate:
                        'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                    userAgentPackageName: 'com.example.app1',
                  ),

                  // User Location Marker
                  if (controller.userLocation.value != null)
                    MarkerLayer(
                      markers: [
                        Marker(
                          point: LatLng(
                            controller.userLocation.value!.latitude,
                            controller.userLocation.value!.longitude,
                          ),
                          width: 40,
                          height: 40,
                          child: _buildUserLocationMarker(),
                        ),
                      ],
                    ),

                  // Store Markers
                  MarkerLayer(
                    markers: controller.stores
                        .map((store) {
                          if (store.lat == null || store.lng == null)
                            return null;
                          return Marker(
                            point: LatLng(store.lat!, store.lng!),
                            width: 65,
                            height: 65,
                            child: StoreMarkerWidget(
                              store: store,
                              imageUrl: _getImageUrl(store.logo),
                              onTap: () => controller.selectStore(store),
                            ),
                          );
                        })
                        .whereType<Marker>()
                        .toList(),
                  ),
                ],
              )),

          // 2. Control Buttons (Location, Nearby)
          const MapControlButtons(),

          // 3. Loading Indicator
          Obx(() => controller.isLoading.value
              ? const Center(child: CircularProgressIndicator())
              : const SizedBox.shrink()),

          // 4. Modern Horizontal Store List
          _buildHorizontalStoreList(controller),
        ],
      ),
    );
  }

  Widget _buildHorizontalStoreList(MapStoreController controller) {
    return Positioned(
      left: 0,
      right: 0,
      bottom: 20,
      child: Obx(() {
        if (controller.stores.isEmpty || controller.isLoading.value) {
          return const SizedBox.shrink();
        }

        return Container(
          height: 120, // Modern compact height
          child: PageView.builder(
            controller: controller.pageController,
            itemCount: controller.stores.length,
            onPageChanged: (index) {
              final store = controller.stores[index];
              controller.selectedStore.value = store;
              controller.mapController.move(
                LatLng(store.lat!, store.lng!),
                15,
              );
            },
            itemBuilder: (context, index) {
              final store = controller.stores[index];
              final distance = store.lat != null && store.lng != null
                  ? controller.calculateDistance(store.lat!, store.lng!)
                  : null;

              return AnimatedBuilder(
                animation: controller.pageController,
                builder: (context, child) {
                  double value = 1.0;
                  if (controller.pageController.position.haveDimensions) {
                    value = controller.pageController.page! - index;
                    value = (1 - (value.abs() * 0.1)).clamp(0.0, 1.0);
                  }
                  return Transform.scale(
                    scale: value,
                    child: SelectedStoreCardWidget(
                      store: store,
                      imageUrl: _getImageUrl(store.logo),
                      distance: distance,
                    ),
                  );
                },
              );
            },
          ),
        );
      }),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      title: const Text(
        'Store Locality',
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w900,
          color: Colors.black,
          letterSpacing: -0.5,
        ),
      ),
      backgroundColor: Colors.white.withOpacity(0.85),
      elevation: 0,
      scrolledUnderElevation: 0,
      centerTitle: true,
      leading: Padding(
        padding: const EdgeInsets.all(8.0),
        child: CircleAvatar(
          backgroundColor: Colors.black,
          child: IconButton(
            icon: const Icon(Icons.arrow_back_rounded,
                color: Colors.white, size: 20),
            onPressed: () => Get.back(),
          ),
        ),
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.tune_rounded, color: Colors.black54),
          onPressed: () {},
        ),
      ],
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          bottom: Radius.circular(30),
        ),
      ),
    );
  }

  Widget _buildUserLocationMarker() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.blue.withOpacity(0.2),
        shape: BoxShape.circle,
      ),
      child: Center(
        child: Container(
          width: 14,
          height: 14,
          decoration: BoxDecoration(
            color: Colors.blue,
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white, width: 2),
            boxShadow: [
              BoxShadow(
                color: Colors.blue.withOpacity(0.5),
                blurRadius: 8,
                spreadRadius: 2,
              )
            ],
          ),
        ),
      ),
    );
  }
}
