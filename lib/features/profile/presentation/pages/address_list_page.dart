import 'package:flutter/material.dart';
import 'package:app1/services/api_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:app1/l10n/app_localizations.dart';

class AddressListPage extends StatefulWidget {
  const AddressListPage({super.key});

  @override
  State<AddressListPage> createState() => _AddressListPageState();
}

class _AddressListPageState extends State<AddressListPage> {
  List<dynamic> _addresses = [];
  bool _isLoading = true;
  int? _userId;

  static const Color lazadaOrange = Color(0xFFFF6600);

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final prefs = await SharedPreferences.getInstance();
    final userIdStr = prefs.getString('userId') ?? prefs.getString('token');
    if (userIdStr != null) {
      _userId = int.tryParse(userIdStr);
      if (_userId != null) {
        try {
          final data = await ApiService.getAddresses(_userId!);
          if (mounted) {
            setState(() {
              _addresses = data;
              _isLoading = false;
            });
          }
        } catch (e) {
          if (mounted) setState(() => _isLoading = false);
        }
      }
    }
  }

  void _navigateToAddEdit({Map<String, dynamic>? address}) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => AddressFormPage(address: address, userId: _userId!),
      ),
    ).then((_) => _loadData());
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor:
          isDark ? const Color(0xFF121212) : const Color(0xFFF8F8FA),
      appBar: AppBar(
        title: Text(t.translate('shipping_address'),
            style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 18)),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: lazadaOrange))
          : _addresses.isEmpty
              ? _buildEmptyState(t)
              : ListView.builder(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  physics: const BouncingScrollPhysics(),
                  itemCount: _addresses.length,
                  itemBuilder: (context, index) {
                    final addr = _addresses[index];
                    return _buildAddressCard(addr, isDark, t)
                        .animate()
                        .fadeIn(delay: (index * 100).ms)
                        .slideX(begin: 0.1, end: 0);
                  },
                ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _navigateToAddEdit(),
        backgroundColor: Colors.black,
        elevation: 0,
        icon: const Icon(Icons.add_location_alt_rounded, color: Colors.white),
        label: Text(t.translate('add_new_address'),
            style: const TextStyle(
                color: Colors.white, fontWeight: FontWeight.w900)),
      ).animate().scale(delay: 400.ms, curve: Curves.easeOutBack),
    );
  }

  Widget _buildAddressCard(
      Map<String, dynamic> addr, bool isDark, AppLocalizations t) {
    bool isDefault = addr['isDefault'] == true;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.3 : 0.04),
            blurRadius: 20,
            offset: const Offset(0, 10),
          )
        ],
        border: isDefault
            ? Border.all(color: lazadaOrange.withOpacity(0.3), width: 1.5)
            : null,
      ),
      child: InkWell(
        onTap: () => _navigateToAddEdit(address: addr),
        borderRadius: BorderRadius.circular(24),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: isDefault
                      ? lazadaOrange.withOpacity(0.1)
                      : (isDark
                          ? Colors.white.withOpacity(0.05)
                          : Colors.grey[100]),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  isDefault ? Icons.home_rounded : Icons.location_on_rounded,
                  color: isDefault ? lazadaOrange : Colors.grey[400],
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(addr['fullName'],
                            style: const TextStyle(
                                fontWeight: FontWeight.w900, fontSize: 16)),
                        if (isDefault) ...[
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: lazadaOrange,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Text("DEFAULT",
                                style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 8,
                                    fontWeight: FontWeight.w900,
                                    letterSpacing: 0.5)),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      addr['phone'],
                      style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 13,
                          fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      "${addr['addressLine1']}, ${addr['city']}",
                      style: TextStyle(
                          color: Colors.grey[500], fontSize: 14, height: 1.4),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: Icon(Icons.edit_note_rounded, color: Colors.grey[400]),
                onPressed: () => _navigateToAddEdit(address: addr),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState(AppLocalizations t) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              color: lazadaOrange.withOpacity(0.05),
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.location_off_rounded,
                size: 80, color: lazadaOrange.withOpacity(0.2)),
          ).animate().scale(duration: 600.ms, curve: Curves.easeOutBack),
          const SizedBox(height: 24),
          Text(t.translate('no_address_found') ?? "No addresses found",
              style:
                  const TextStyle(fontSize: 18, fontWeight: FontWeight.w900)),
        ],
      ),
    );
  }
}

class AddressFormPage extends StatefulWidget {
  final Map<String, dynamic>? address;
  final int userId;

  const AddressFormPage({super.key, this.address, required this.userId});

  @override
  State<AddressFormPage> createState() => _AddressFormPageState();
}

class _AddressFormPageState extends State<AddressFormPage> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _phoneController;
  late TextEditingController _addr1Controller;
  late TextEditingController _cityController;
  bool _isDefault = false;
  bool _isSaving = false;

  static const Color lazadaOrange = Color(0xFFFF6600);

  @override
  void initState() {
    super.initState();
    _nameController =
        TextEditingController(text: widget.address?['fullName'] ?? "");
    _phoneController =
        TextEditingController(text: widget.address?['phone'] ?? "");
    _addr1Controller =
        TextEditingController(text: widget.address?['addressLine1'] ?? "");
    _cityController =
        TextEditingController(text: widget.address?['city'] ?? "");
    _isDefault = widget.address?['isDefault'] ?? false;
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isSaving = true);

    final data = {
      "userId": widget.userId,
      "fullName": _nameController.text,
      "phone": _phoneController.text,
      "addressLine1": _addr1Controller.text,
      "city": _cityController.text,
      "isDefault": _isDefault,
      "country": "Cambodia",
      "postalCode": "12000"
    };

    try {
      if (widget.address == null) {
        await ApiService.addAddress(data);
      } else {
        await ApiService.updateAddress(widget.address!['id'], data);
      }
      if (mounted) Navigator.pop(context);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text("Error: $e")));
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF121212) : Colors.white,
      appBar: AppBar(
        title: Text(widget.address == null ? "Add Address" : "Edit Address",
            style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 18)),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(24),
          children: [
            _buildTextField(
                _nameController, "Full Name", Icons.person_outline_rounded),
            const SizedBox(height: 20),
            _buildTextField(
                _phoneController, "Phone Number", Icons.phone_android_rounded,
                keyboardType: TextInputType.phone),
            const SizedBox(height: 20),
            _buildTextField(
                _addr1Controller, "Street Address", Icons.map_outlined),
            const SizedBox(height: 20),
            _buildTextField(_cityController, "City / District",
                Icons.location_city_rounded),
            const SizedBox(height: 32),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color:
                    isDark ? const Color(0xFF1E1E1E) : const Color(0xFFF8F8FA),
                borderRadius: BorderRadius.circular(20),
              ),
              child: SwitchListTile(
                title: const Text("Set as Default Address",
                    style:
                        TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                value: _isDefault,
                onChanged: (v) => setState(() => _isDefault = v),
                activeColor: lazadaOrange,
                contentPadding: EdgeInsets.zero,
              ),
            ),
            const SizedBox(height: 48),
            SizedBox(
              height: 56,
              child: ElevatedButton(
                onPressed: _isSaving ? null : _save,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16)),
                  elevation: 0,
                ),
                child: _isSaving
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text("Save Address",
                        style: TextStyle(
                            fontWeight: FontWeight.w900, fontSize: 16)),
              ),
            ),
            if (widget.address != null) ...[
              const SizedBox(height: 16),
              TextButton.icon(
                onPressed: () async {
                  await ApiService.deleteAddress(widget.address!['id']);
                  if (mounted) Navigator.pop(context);
                },
                icon:
                    const Icon(Icons.delete_outline_rounded, color: Colors.red),
                label: const Text("Remove this address",
                    style: TextStyle(
                        color: Colors.red, fontWeight: FontWeight.bold)),
              ),
            ]
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(
      TextEditingController controller, String label, IconData icon,
      {TextInputType? keyboardType}) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, size: 20),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: Colors.grey[200]!),
        ),
        filled: true,
        fillColor: Theme.of(context).brightness == Brightness.dark
            ? const Color(0xFF1E1E1E)
            : const Color(0xFFF8F8FA),
      ),
      validator: (v) => v!.isEmpty ? "Required field" : null,
    );
  }
}
