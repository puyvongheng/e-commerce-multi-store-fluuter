import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:app1/models/store.dart';
import 'package:app1/services/store_service.dart';
import 'package:geolocator/geolocator.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

class MapStoreController extends GetxController {
  var isLoading = true.obs;
  var stores = <Store>[].obs;
  var selectedStore = Rxn<Store>();

  // Location States
  var userLocation = Rxn<Position>();
  var mapController = MapController();
  var pageController = PageController(viewportFraction: 0.85); // Added this
  var isLocating = false.obs;

  @override
  void onInit() {
    super.onInit();
    fetchStores();
    determinePosition();
  }

  Future<void> fetchStores() async {
    try {
      isLoading(true);
      final fetchedStores = await StoreService.fetchStores();

      // For demonstration, if lat/lng are null, we can provide some mock coordinates around Phnom Penh
      // so the user can see markers on the map.
      final processedStores = fetchedStores.map((store) {
        if (store.lat == null || store.lng == null) {
          // Provide some spread out coordinates around Phnom Penh
          double mockLat = 11.5564 + (store.id * 0.005);
          double mockLng = 104.9282 + (store.id * 0.005);
          return Store(
            id: store.id,
            name: store.name,
            logo: store.logo,
            coverImage: store.coverImage,
            description: store.description,
            telegram: store.telegram,
            address: store.address,
            businessType: store.businessType,
            lat: mockLat,
            lng: mockLng,
            isVerified: store.isVerified,
          );
        }
        return store;
      }).toList();

      stores.assignAll(processedStores);
    } finally {
      isLoading(false);
    }
  }

  Future<void> determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) return;

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) return;
    }

    if (permission == LocationPermission.deniedForever) return;

    isLocating(true);
    try {
      Position position = await Geolocator.getCurrentPosition();
      userLocation.value = position;
    } finally {
      isLocating(false);
    }
  }

  void moveToUserLocation() async {
    if (userLocation.value != null) {
      mapController.move(
        LatLng(userLocation.value!.latitude, userLocation.value!.longitude),
        15,
      );
    } else {
      await determinePosition();
      if (userLocation.value != null) {
        mapController.move(
          LatLng(userLocation.value!.latitude, userLocation.value!.longitude),
          15,
        );
      }
    }
  }

  void selectStore(Store store) {
    selectedStore.value = store;
    if (store.lat != null && store.lng != null) {
      mapController.move(LatLng(store.lat!, store.lng!), 16);
    }

    // Sync PageController
    int index = stores.indexWhere((s) => s.id == store.id);
    if (index != -1 && pageController.hasClients) {
      pageController.animateToPage(
        index,
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOut,
      );
    }
  }

  double calculateDistance(double endLat, double endLng) {
    if (userLocation.value == null) return 0.0;
    return Geolocator.distanceBetween(
      userLocation.value!.latitude,
      userLocation.value!.longitude,
      endLat,
      endLng,
    );
  }

  void findNearbyStores() {
    if (userLocation.value == null) return;

    // Sort stores by distance
    var sorted = List<Store>.from(stores);
    sorted.sort((a, b) {
      double distA = calculateDistance(a.lat ?? 0, a.lng ?? 0);
      double distB = calculateDistance(b.lat ?? 0, b.lng ?? 0);
      return distA.compareTo(distB);
    });

    if (sorted.isNotEmpty) {
      selectStore(sorted.first);
    }
  }
}
