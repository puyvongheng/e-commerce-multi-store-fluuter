// lib/widgets/notification_bell.dart

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';
import 'package:intl/intl.dart'; // Recommend adding this package for date formatting

// Realtime Packages
import 'package:pusher_channels_flutter/pusher_channels_flutter.dart';
import 'package:laravel_echo/laravel_echo.dart';

// Notification Model
class NotificationItem {
  final String id;
  final Map<String, dynamic> payload;
  final DateTime createdAt;
  bool read;

  NotificationItem({
    required this.id,
    required this.payload,
    required this.createdAt,
    this.read = false,
  });

  factory NotificationItem.fromJson(Map<String, dynamic> json) {
    return NotificationItem(
      id: json['id'].toString(),
      payload:
          json['data'] ?? json['payload'], // Laravel defaults to 'data' usually
      createdAt:
          DateTime.tryParse(json['created_at'].toString()) ?? DateTime.now(),
      read: json['read_at'] != null,
    );
  }
}

// Notification Bell Widget
class NotificationBell extends StatefulWidget {
  final int userId;

  const NotificationBell({super.key, required this.userId});

  @override
  State<NotificationBell> createState() => _NotificationBellState();
}

class _NotificationBellState extends State<NotificationBell> {
  List<NotificationItem> notifications = [];

  // Realtime vars
  late Echo echo;
  final pusher = PusherChannelsFlutter.getInstance();

  // Dropdown Overlay vars
  final LayerLink _layerLink = LayerLink();
  OverlayEntry? _overlayEntry;

  int get unreadCount => notifications.where((n) => !n.read).length;

  @override
  void initState() {
    super.initState();
    loadNotifications();
    initRealtime();
  }

  @override
  void dispose() {
    // 🔥 Cleanup to prevent memory leaks
    pusher.disconnect();
    _overlayEntry?.remove();
    _overlayEntry = null;
    super.dispose();
  }

  // 1. Load old notifications
  Future<void> loadNotifications() async {
    // Note: If using Android Emulator, use 10.0.2.2 instead of 127.0.0.1
    final url = Uri.parse("http://127.0.0.1:8000/api/notifications");

    try {
      final res = await http.get(url, headers: {
        "Accept": "application/json",
        // Add Authorization Bearer token here if needed
      });

      if (res.statusCode == 200 && mounted) {
        List data = jsonDecode(res.body);
        setState(() {
          notifications =
              data.map((e) => NotificationItem.fromJson(e)).toList();
        });
      }
    } catch (e) {
      debugPrint("Error loading notifications: $e");
    }
  }

  // 2. 🚀 REALTIME Laravel Echo Connection
  Future<void> initRealtime() async {
    try {
      await pusher.init(
        apiKey: "YOUR_APP_KEY",
        cluster: "mt1",
        onEvent: (event) {
          debugPrint("Pusher Event: ${event.data}");
        },
      );

      await pusher.connect();

      echo = Echo(
        broadcaster: EchoBroadcasterType.Pusher,
        client: pusher,
      );

      // Listen to private channel
      echo
          .private(
              "App.Models.User.${widget.userId}") // Standard Laravel naming
          .notification((data) {
        if (!mounted) return;

        setState(() {
          notifications.insert(
            0,
            NotificationItem(
              id: DateTime.now().millisecondsSinceEpoch.toString(),
              payload: data,
              createdAt: DateTime.now(),
              read: false,
            ),
          );
        });

        // Show Toast
        Fluttertoast.showToast(
          msg: data["title"] ?? "New Notification",
          gravity: ToastGravity.TOP,
          backgroundColor: Colors.black87,
          textColor: Colors.white,
        );
      });
    } catch (e) {
      debugPrint("Realtime Error: $e");
    }
  }

  // 3. Toggle Dropdown logic using Overlay
  void _toggleDropdown() {
    if (_overlayEntry == null) {
      _overlayEntry = _createOverlayEntry();
      Overlay.of(context).insert(_overlayEntry!);
    } else {
      _overlayEntry?.remove();
      _overlayEntry = null;
    }
  }

  // Create the floating dropdown
  OverlayEntry _createOverlayEntry() {
    RenderBox renderBox = context.findRenderObject() as RenderBox;
    var size = renderBox.size;

    return OverlayEntry(
      builder: (context) => Positioned(
        width: 350, // Width of dropdown
        child: CompositedTransformFollower(
          link: _layerLink,
          showWhenUnlinked: false,
          offset: Offset(-(350 - size.width), size.height + 5), // Align right
          child: Material(
            elevation: 8,
            borderRadius: BorderRadius.circular(12),
            color: Colors.white,
            child: Container(
              height: 400,
              padding: const EdgeInsets.symmetric(vertical: 10),
              child: Column(
                children: [
                  // Header
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text("Notifications",
                            style: TextStyle(
                                fontSize: 18, fontWeight: FontWeight.bold)),
                        TextButton(
                          onPressed: () {
                            markAllRead();
                            _overlayEntry
                                ?.remove(); // Close after action if you want
                            _overlayEntry = null;
                          },
                          child: const Text("Mark all read"),
                        ),
                      ],
                    ),
                  ),
                  const Divider(),

                  // List
                  Expanded(
                    child: notifications.isEmpty
                        ? const Center(
                            child: Text("No notifications",
                                style: TextStyle(color: Colors.grey)))
                        : ListView.builder(
                            padding: EdgeInsets.zero,
                            itemCount: notifications.length,
                            itemBuilder: (context, i) =>
                                _notificationItem(notifications[i]),
                          ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void markAllRead() {
    setState(() {
      for (var n in notifications) {
        n.read = true;
      }
    });
    // Call API to mark read on backend here
  }

  void openItem(NotificationItem item) async {
    setState(() => item.read = true);
    _overlayEntry?.remove(); // Close dropdown
    _overlayEntry = null;

    if (item.payload["url"] != null) {
      final uri = Uri.parse(item.payload["url"]);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Wrap with CompositedTransformTarget to link the overlay position
    return CompositedTransformTarget(
      link: _layerLink,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          IconButton(
            icon: const Icon(Icons.notifications),
            onPressed: _toggleDropdown,
          ),
          if (unreadCount > 0)
            Positioned(
              right: 8,
              top: 8,
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: const BoxDecoration(
                  color: Colors.red,
                  shape: BoxShape.circle,
                ),
                child: Text(
                  unreadCount > 9 ? "9+" : unreadCount.toString(),
                  style: const TextStyle(
                      fontSize: 10,
                      color: Colors.white,
                      fontWeight: FontWeight.bold),
                ),
              ),
            ),
        ],
      ),
    );
  }

  // Single Notification Item
  Widget _notificationItem(NotificationItem item) {
    final payload = item.payload;
    // Format date nicely
    String timeStr = DateFormat('MMM d, h:mm a').format(item.createdAt);

    return InkWell(
      onTap: () => openItem(item),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        color: item.read ? Colors.transparent : Colors.blue.withValues(alpha: 0.05),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              margin: const EdgeInsets.only(top: 2),
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                color: item.read ? Colors.transparent : Colors.blue,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    payload["title"] ?? "Notification",
                    style: TextStyle(
                        fontSize: 15,
                        fontWeight:
                            item.read ? FontWeight.normal : FontWeight.bold,
                        color: Colors.black87),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    payload["message"] ?? "",
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(fontSize: 13, color: Colors.grey[700]),
                  ),
                  const SizedBox(height: 6),
                  Text(timeStr,
                      style: TextStyle(fontSize: 11, color: Colors.grey[500])),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
