import 'package:flutter/material.dart';
import 'package:aims/widgets/common/custom_button.dart';
import 'package:aims/widgets/common/custom_text_field.dart';

class StaffManagementScreen extends StatefulWidget {
  const StaffManagementScreen({super.key});

  @override
  State<StaffManagementScreen> createState() => _StaffManagementScreenState();
}

class _StaffManagementScreenState extends State<StaffManagementScreen> {
  final List<Map<String, dynamic>> staffList = [
    {
      'id': 'STF-001',
      'name': 'Juan Dela Cruz',
      'activity': 'Checked in',
      'status': 'On Duty',
      'hours': '8',
    },
    {
      'id': 'STF-002',
      'name': 'Maria Santos',
      'activity': 'Break',
      'status': 'Off Duty',
      'hours': '6',
    },
  ];

  String searchQuery = '';
  String? selectedFilter = 'All';
  final _searchController = TextEditingController();

  final _nameController = TextEditingController();
  final _statusController = TextEditingController();
  final _hoursController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final filteredStaff = staffList.where((staff) {
      final matchesSearch =
          staff['name'].toLowerCase().contains(searchQuery.toLowerCase());

      if (selectedFilter == null || selectedFilter == "All") {
        return matchesSearch;
      } else if (selectedFilter == "On Duty" || selectedFilter == "Off Duty") {
        return matchesSearch && staff['status'] == selectedFilter;
      } else if (selectedFilter == "Annual" || selectedFilter == "Monthly") {
        return matchesSearch && staff['membership'] == selectedFilter;
      }
      return matchesSearch;
    }).toList();

    return Scaffold(
      backgroundColor: const Color(0xFFF4F8FA),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    "List of Staff",
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                  ),
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    icon: const Icon(Icons.add),
                    label: const Text('Add Staff'),
                    onPressed: _showAddForm,
                  ),
                ],
              ),
              
              const SizedBox(height: 16),

              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _searchController,
                      onChanged: (value) {
                        setState(() {
                          searchQuery = value;
                        });
                      },
                      decoration: InputDecoration(
                        hintText: 'Search staff by name',
                        prefixIcon: const Icon(Icons.search, color: Colors.grey),
                        filled: true,
                        fillColor: Colors.white,
                        contentPadding: const EdgeInsets.symmetric(
                            vertical: 0, horizontal: 16),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(25),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),

                  Container(
                    height: 48,
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF5E6CC), // beige background
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey.shade400),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: selectedFilter,
                        isExpanded: false,
                        icon: const Icon(Icons.arrow_drop_down, color: Colors.black),
                        style: const TextStyle(color: Colors.black, fontSize: 16),
              
                        selectedItemBuilder: (context) {
                          return [
                            "All",
                            "On Duty",
                            "Off Duty",
                            "Annual",
                            "Monthly"
                          ].map((_) {
                            return Row(
                              children: const [
                                Icon(Icons.filter_alt, color: Colors.black),
                                SizedBox(width: 4),
                                Text("Filter by"),
                              ],
                            );
                          }).toList();
                        },

                        items: [
                          const DropdownMenuItem(
                              value: "All", child: Text("All")),
                          const DropdownMenuItem(
                              value: "On Duty", child: Text("On Duty")),
                          const DropdownMenuItem(
                              value: "Off Duty", child: Text("Off Duty")),
                          const DropdownMenuItem(
                              value: "Annual",
                              child: Text("Membership: Annual")),
                          const DropdownMenuItem(
                              value: "Monthly",
                              child: Text("Membership: Monthly")),
                        ],
                        onChanged: (value) {
                          setState(() {
                            selectedFilter = value;
                        });
                      },
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            Expanded(
              child: ListView.builder(
                itemCount: filteredStaff.length,
                itemBuilder: (context, index) {
                  final staff = filteredStaff[index];
                  return Card(
                    margin: const EdgeInsets.symmetric(vertical: 8),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 3,
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            staff['name'],
                            style: const TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                          Text(
                            '${staff['id']} • ${staff['email'] ?? 'no-email@example.com'}',
                            style: const TextStyle(color: Colors.grey),
                          ),
                          const SizedBox(height: 12),

                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: [
                              _buildInfoTag('User Type: ${staff['userType'] ?? 'N/A'}'),
                              _buildInfoTag('Membership: ${staff['membership'] ?? 'N/A'}'),
                              _buildInfoTag('Phone: ${staff['phone'] ?? 'N/A'}'),
                              _buildInfoTag('Status: ${staff['status']}'),
                              _buildInfoTag('Hours: ${staff['hours']}'),
                            ],
                          ),
                            
                          const SizedBox(height: 12),

                          Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              _buildActionButton(
                                label: 'User History',
                                icon: Icons.history,
                                onPressed: () => _showStaffDetails(staff),
                              ),
                              const SizedBox(width: 8),
                              _buildActionButton(
                                label: 'Edit User',
                                icon: Icons.edit,
                                onPressed: () => _showEditForm(staff),
                              ),
                              const SizedBox(width: 8),
                              _buildActionButton(
                                label: 'Delete User',
                                icon: Icons.delete,
                                textColor: Colors.red, // only text/icon red
                                onPressed: () =>
                                    setState(() => staffList.remove(staff)),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );      
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActionButton({
    required String label,
    required IconData icon,
    Color? backgroundColor,
    Color? textColor,
    Color? borderColor,
    required VoidCallback onPressed,
  }) {
    return ElevatedButton.icon(
      style: ElevatedButton.styleFrom(
        foregroundColor: textColor ?? Colors.purple,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(
          color: borderColor ?? Colors.grey, // <-- border color
          width: 1.5,                                // <-- border thickness
          ),
        ),
      ),
      icon: Icon(icon, size: 18, color: textColor ?? Colors.purple),
      label: Text(label, style: TextStyle(color: textColor ?? Colors.purple)),
      onPressed: onPressed,
    );
  }

  Widget _buildInfoTag(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFFF0F0F0), // light gray background
        borderRadius: BorderRadius.circular(20), // pill shape
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Text(
        text,
        style: const TextStyle(fontSize: 14, color: Colors.black87),
      ),
    );
  }

  void _showAddForm() {
    _nameController.clear();
    _statusController.clear();
    _hoursController.clear();

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Add Staff'),
        content: SizedBox(
          width: 400,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CustomTextField(hint: 'Enter full name', controller: _nameController),
              const SizedBox(height: 12),
              CustomTextField(hint: 'On Duty / Off Duty', controller: _statusController),
              const SizedBox(height: 12),
              CustomTextField(hint: 'Enter working hours', controller: _hoursController),
            ],
          ),
        ),
        actions: [
          CustomButton(
            label: 'Cancel',
            backgroundColor: Colors.white,
            textColor: Colors.black,
            borderColor: Colors.black,
            width: 100,
            height: 40,
            onPressed: () async {
              Navigator.pop(context);
            },
          ),
          CustomButton(
            label: 'Save',
            backgroundColor: Colors.black,
            textColor: Colors.white,
            borderColor: Colors.black,
            width: 100,
            height: 40,
            onPressed: () async {
              setState(() {
                staffList.add({
                  'id': 'STF-${staffList.length + 1}',
                  'name': _nameController.text,
                  'activity': 'New',
                  'status': _statusController.text,
                  'hours': _hoursController.text,
                });
              });
              Navigator.pop(context);
            },
          ),
        ],
      ),
    );
  }

  void _showEditForm(Map<String, dynamic> staff) {
    _nameController.text = staff['name'];
    _statusController.text = staff['status'];
    _hoursController.text = staff['hours'];

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Edit Staff'),
        content: SizedBox(
          width: 400,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CustomTextField(hint: 'Enter full name', controller: _nameController),
              const SizedBox(height: 12),
              CustomTextField(hint: 'On Duty / Off Duty', controller: _statusController),
              const SizedBox(height: 12),
              CustomTextField(hint: 'Enter working hours', controller: _hoursController),
            ],
          ),
        ),
        actions: [
          CustomButton(
            label: 'Cancel',
            backgroundColor: Colors.white,
            textColor: Colors.black,
            borderColor: Colors.black,
            width: 100,
            height: 40,
            onPressed: () async {
              Navigator.pop(context);
            },
          ),
          CustomButton(
            label: 'Update',
            backgroundColor: Colors.black,
            textColor: Colors.white,
            borderColor: Colors.black,
            width: 100,
            height: 40,
            onPressed: () async {
              setState(() {
                staff['name'] = _nameController.text;
                staff['status'] = _statusController.text;
                staff['hours'] = _hoursController.text;
              });
              Navigator.pop(context);
            },
          ),
        ],
      ),
    );
  }

  void _showStaffDetails(Map<String, dynamic> staff) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text('Staff Details - ${staff['name']}'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('ID: ${staff['id']}'),
            Text('Activity: ${staff['activity']}'),
            Text('Status: ${staff['status']}'),
            Text('Hours: ${staff['hours']}'),
          ],
        ),
        actions: [
          CustomButton(
            label: 'Close',
            backgroundColor: Colors.black,
            textColor: Colors.white,
            borderColor: Colors.black,
            width: 100,
            height: 40,
            onPressed: () async {
              Navigator.pop(context);
            },
          ),
        ],
      ),
    );
  }
}

