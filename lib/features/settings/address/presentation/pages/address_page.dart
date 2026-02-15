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

  static const Color primaryColor = Color(0xFFFF6600);

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
    final backgroundColor =
        isDark ? const Color(0xFF121212) : const Color(0xFFF8F9FA);

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        title: Text(t.translate('shipping_address'),
            style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 18)),
        centerTitle: true,
        backgroundColor: backgroundColor,
        surfaceTintColor: backgroundColor,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new,
              size: 20, color: isDark ? Colors.white : Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: primaryColor))
          : _addresses.isEmpty
              ? _buildEmptyState(t)
              : ListView.separated(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                  separatorBuilder: (c, i) => const SizedBox(height: 16),
                  physics: const BouncingScrollPhysics(),
                  itemCount: _addresses.length,
                  itemBuilder: (context, index) {
                    final addr = _addresses[index];
                    return _buildAddressCard(addr, isDark, t)
                        .animate()
                        .fadeIn(delay: (index * 50).ms)
                        .slideY(begin: 0.1, end: 0);
                  },
                ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _navigateToAddEdit(),
        backgroundColor: isDark ? Colors.white : const Color(0xFF1A1A1A),
        foregroundColor: isDark ? Colors.black : Colors.white,
        elevation: 4,
        // shadowColor: Colors.black26, // not available in extended
        icon: const Icon(Icons.add_rounded),
        label: Text(t.translate('add_new_address'),
            style: const TextStyle(fontWeight: FontWeight.bold)),
      ).animate().scale(delay: 300.ms, curve: Curves.easeOutBack),
    );
  }

  Widget _buildAddressCard(
      Map<String, dynamic> addr, bool isDark, AppLocalizations t) {
    bool isDefault = addr['isDefault'] == true;
    final cardColor = isDark ? const Color(0xFF1E1E1E) : Colors.white;
    final borderColor = isDefault
        ? primaryColor
        : (isDark ? Colors.white10 : Colors.grey.shade200);

    return InkWell(
      onTap: () => _navigateToAddEdit(address: addr),
      borderRadius: BorderRadius.circular(20),
      child: Container(
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: borderColor, width: isDefault ? 1.5 : 1),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(isDark ? 0.3 : 0.05),
              blurRadius: 15,
              offset: const Offset(0, 5),
            )
          ],
        ),
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Flexible(
                            child: Text(
                              addr['fullName'],
                              style: const TextStyle(
                                fontWeight: FontWeight.w700,
                                fontSize: 16,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(width: 8),
                          if (isDefault)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(colors: [
                                  Color(0xFFFF6600),
                                  Color(0xFFFF9900)
                                ]),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: const Text("Default",
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold)),
                            )
                          else
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                color: isDark
                                    ? Colors.white.withOpacity(0.1)
                                    : Colors.grey[200],
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(addr['label'] ?? "Home",
                                  style: TextStyle(
                                      color: isDark
                                          ? Colors.white70
                                          : Colors.black54,
                                      fontSize: 10,
                                      fontWeight: FontWeight.w600)),
                            ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        addr['phone'],
                        style: TextStyle(
                            color: isDark ? Colors.grey[400] : Colors.grey[600],
                            fontSize: 14,
                            fontWeight: FontWeight.w500),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        "${addr['addressLine1']}, ${addr['city']}",
                        style: TextStyle(
                            color: isDark ? Colors.grey[500] : Colors.grey[500],
                            fontSize: 14,
                            height: 1.4),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isDark ? Colors.black26 : Colors.grey[100],
                  ),
                  child: IconButton(
                    icon: Icon(Icons.edit_outlined,
                        size: 20,
                        color: isDark ? Colors.white70 : Colors.black54),
                    onPressed: () => _navigateToAddEdit(address: addr),
                    tooltip: "Edit",
                  ),
                ),
              ],
            ),
          ],
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
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: primaryColor.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.markunread_mailbox_rounded,
                size: 64, color: primaryColor.withOpacity(0.8)),
          ).animate().scale(duration: 600.ms, curve: Curves.easeOutBack),
          const SizedBox(height: 16),
          Text(t.translate('no_address_found') ?? "No addresses yet",
              style:
                  const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Text(
            "Add a shipping address to checkout faster.",
            style: TextStyle(color: Colors.grey[500], fontSize: 14),
          ),
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

  static const Color primaryColor = Color(0xFFFF6600);

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
    // final t = AppLocalizations.of(context); // Not used currently
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final backgroundColor =
        isDark ? const Color(0xFF121212) : const Color(0xFFF8F9FA);

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        title: Text(widget.address == null ? "Add Address" : "Edit Address",
            style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 18)),
        centerTitle: true,
        backgroundColor: backgroundColor,
        surfaceTintColor: backgroundColor,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.close_rounded,
              color: isDark ? Colors.white : Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          if (widget.address != null)
            IconButton(
              onPressed: () async {
                final confirm = await showDialog<bool>(
                  context: context,
                  builder: (ctx) => AlertDialog(
                    title: const Text("Delete Address"),
                    content: const Text(
                        "Are you sure you want to delete this address?"),
                    actions: [
                      TextButton(
                          onPressed: () => Navigator.pop(ctx, false),
                          child: const Text("Cancel")),
                      TextButton(
                          onPressed: () => Navigator.pop(ctx, true),
                          child: const Text("Delete",
                              style: TextStyle(color: Colors.red))),
                    ],
                  ),
                );

                if (confirm == true) {
                  await ApiService.deleteAddress(widget.address!['id']);
                  if (mounted) Navigator.pop(context);
                }
              },
              icon: Icon(Icons.delete_outline_rounded,
                  color: Colors.red.withOpacity(0.8)),
            ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: Column(
          children: [
            Expanded(
              child: ListView(
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
                physics: const BouncingScrollPhysics(),
                children: [
                  _buildSectionTitle("Contact Info"),
                  const SizedBox(height: 16),
                  _buildTextField(_nameController, "Full Name",
                      Icons.person_outline_rounded),
                  const SizedBox(height: 16),
                  _buildTextField(_phoneController, "Phone Number",
                      Icons.phone_iphone_rounded,
                      keyboardType: TextInputType.phone),
                  const SizedBox(height: 32),
                  _buildSectionTitle("Address Details"),
                  const SizedBox(height: 16),
                  _buildTextField(
                      _addr1Controller, "Street Address", Icons.map_outlined,
                      maxLines: 2),
                  const SizedBox(height: 16),
                  _buildTextField(_cityController, "City / District",
                      Icons.location_city_rounded),
                  const SizedBox(height: 32),
                  Container(
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                          color:
                              isDark ? Colors.white10 : Colors.grey.shade200),
                    ),
                    child: SwitchListTile(
                      title: const Text("Set as Default Address",
                          style: TextStyle(
                              fontWeight: FontWeight.w600, fontSize: 14)),
                      value: _isDefault,
                      onChanged: (v) => setState(() => _isDefault = v),
                      activeColor: primaryColor,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16)),
                    ),
                  ),
                ],
              ),
            ),
            _buildBottomBar(isDark),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title.toUpperCase(),
      style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: Colors.grey[600],
          letterSpacing: 1),
    );
  }

  Widget _buildBottomBar(bool isDark) {
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, -5))
        ],
      ),
      child: SizedBox(
        width: double.infinity,
        height: 54,
        child: ElevatedButton(
          onPressed: _isSaving ? null : _save,
          style: ElevatedButton.styleFrom(
            backgroundColor: primaryColor,
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
          ),
          child: _isSaving
              ? const SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(
                      color: Colors.white, strokeWidth: 2))
              : const Text("Save Address",
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold)),
        ),
      ),
    );
  }

  Widget _buildTextField(
      TextEditingController controller, String label, IconData icon,
      {TextInputType? keyboardType, int maxLines = 1}) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final fillColor = isDark
        ? const Color(0xFF1E1E1E)
        : Colors.white; // Using white for cleaner look on grey bg

    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      maxLines: maxLines,
      style: const TextStyle(fontWeight: FontWeight.w500),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: Colors.grey[500]),
        prefixIcon: Icon(icon, size: 22, color: Colors.grey[400]),
        filled: true,
        fillColor: fillColor,
        contentPadding:
            const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(
              color:
                  isDark ? Colors.white10 : Colors.transparent), // Cleaner look
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: primaryColor, width: 1.5),
        ),
        floatingLabelBehavior: FloatingLabelBehavior.auto,
      ),
      validator: (v) => v!.isEmpty ? "Required field" : null,
    );
  }
}
