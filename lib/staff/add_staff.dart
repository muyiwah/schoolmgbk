import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'package:schmgtsystem/color_pallete.dart';
import 'package:schmgtsystem/widgets/custom_datepicker.dart';
import 'package:schmgtsystem/widgets/custom_doc_pick.dart';
import 'package:schmgtsystem/widgets/custom_dropdown_select.dart';
import 'package:schmgtsystem/widgets/custom_textfield.dart';
import 'package:schmgtsystem/widgets/fancy_image_pick.dart'; // Uncomment if used
import 'package:schmgtsystem/widgets/image_pick.dart'; // Uncomment if used
import 'package:schmgtsystem/widgets/screen_header.dart';

class AddStaff extends StatefulWidget {
  const AddStaff({super.key});

  @override
  State<AddStaff> createState() => _AddStaffState();
}

class _AddStaffState extends State<AddStaff>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    _tabController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
       
          borderRadius: BorderRadius.circular(14),
        ),
        child: Column(
          children: [
            const ScreenHeader(group: 'Staff',subgroup: 'Add Staff',),
            const SizedBox(height: 10),
            Expanded(
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.transparent,
                  border: Border.all(color: Colors.white),
                  borderRadius: BorderRadius.circular(14),
                ),
                padding: const EdgeInsets.all(10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Padding(
                          padding: EdgeInsets.only(bottom: 20.0),
                          child: Text('Staff Information', style: TextStyle()),
                        ),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: homeColor,
                            // minimumSize: const Size(1, 50),
                            shape: BeveledRectangleBorder(
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ),
                          onPressed: () {
                            clear();
                            setState(() {});
                          },
                          child: const Text(
                            'Clear All',
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                      ],
                    ),
                    TabBar(
                      controller: _tabController,
                      labelColor: Colors.black,
                      unselectedLabelColor: Colors.grey,
                      indicatorColor: Colors.blueAccent,

                      tabs: const [
                        Tab(text: "Basic Info"),
                        Tab(text: "Pay Info"),
                        Tab(text: "Bank Info"),
                        Tab(text: "Documents"),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Expanded(
                      child: TabBarView(
                        controller: _tabController,
                        children: [
                          BasicInfo(controller: _tabController),
                          PayInfo(),
                          BankInfo(),
                          Document(),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

bool validatePressed = false;

class Document extends StatefulWidget {
  const Document({super.key});

  @override
  State<Document> createState() => _DocumentState();
}

PlatformFile? myDoc;

class _DocumentState extends State<Document> {
  @override
  Widget build(BuildContext context) {
    return Wrap(
      children: [
        // DocumentPicker(
        //     onFilePicked: (file) {
        //       print('Picked file: ${file.name}');
        //     },
        //   ),
        Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              DocumentPickerWithValidator(
                clearFile: () {},
                initialFile: myDoc,
                validateTrigger: validatePressed,
                onFilePicked: (file) {
                  myDoc = file;
                  print('Picked file: ${file.name}');
                },
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    validatePressed = true;
                  });
                },
                child: Text('Submit'),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

final _bankController = TextEditingController();
final _accountController = TextEditingController();
final _accountNpController = TextEditingController();

final _totalController = TextEditingController();

class BankInfo extends StatelessWidget {
  const BankInfo({super.key});

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 20,
      runSpacing: 20,
      children: [
        CustomInput(title: 'bank Name', controller: _bankController),
        CustomInput(title: 'Account Name', controller: _accountController),
        CustomInput(title: 'Account Number', controller: _accountNpController),

        CustomDropdown(
          allValues: ['Permanent', 'Contract', 'Others'],
          title: 'Contract Type',
          onChanged: (p0) {},
        ),
      ],
    );
  }
}

final _basicSalaryController = TextEditingController();

final _insuranceController = TextEditingController();
final _othersController = TextEditingController();

class PayInfo extends StatelessWidget {
  const PayInfo({super.key});

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 20,
      runSpacing: 20,
      children: [
        CustomInput(title: 'Basic Salary', controller: _basicSalaryController),
        CustomInput(title: 'Insurance', controller: _insuranceController),
        CustomInput(title: 'Others', controller: _othersController),

        CustomInput(title: 'Total', controller: _totalController),
      ],
    );
  }
}

final _nameController = TextEditingController();
final _lastnameController = TextEditingController();
final _maidenNameController = TextEditingController();
final _emailController = TextEditingController();
final _phoneController = TextEditingController();
final _nokController = TextEditingController();
final _nokNoController = TextEditingController();
final _dobController = TextEditingController();
final _dateOfJoiningController = TextEditingController();
final _currentAddressController = TextEditingController();
final _permanentAddressController = TextEditingController();
final _qualificationController = TextEditingController();
final _experienceController = TextEditingController();
bool _fristnameRequired = false;
bool _lasstnameRequired = false;
bool _emailRequired = false;
bool _genderRequired = false;
clear() {
  _nameController.text =
      _lastnameController.text =
          _emailController.text =
              _maidenNameController.text =
                  _phoneController.text =
                      _nokController.text =
                          _nokNoController.text =
                              _dobController.text =
                                  _dateOfJoiningController.text =
                                      _currentAddressController.text =
                                          _permanentAddressController.text =
                                              _qualificationController.text =
                                                  _experienceController.text =
                                                      _basicSalaryController
                                                              .text =
                                                          _insuranceController
                                                                  .text =
                                                              _othersController.text =
                                                                  _bankController.text = _accountController.text = _accountNpController.text = '';
  _fristnameRequired =
      _lasstnameRequired = _emailRequired = _genderRequired = false;
  myDoc = null;
}

class BasicInfo extends StatefulWidget {
  BasicInfo({super.key, required this.controller});
  final TabController controller;
  @override
  State<BasicInfo> createState() => _BasicInfoState();
}

class _BasicInfoState extends State<BasicInfo> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SingleChildScrollView(
        child: Wrap(
          spacing: 20,
          runSpacing: 20,
          children: [
            CustomInput(
              title: 'First Name',
              controller: _nameController,
              showError: _fristnameRequired,
            ),
            CustomInput(
              title: 'Last Name',
              controller: _lastnameController,
              showError: _lasstnameRequired,
            ),
            CustomInput(
              title: 'Maiden Name',
              controller: _maidenNameController,
            ),
            CustomInput(
              title: 'Email',
              controller: _emailController,
              showError: _emailRequired,
            ),
            CustomInput(title: 'Mobile No', controller: _phoneController),
            CustomInput(title: 'NOK', controller: _nokController),
            CustomInput(title: 'NOK No', controller: _nokNoController),
            CustomDropdown(
              allValues: ['Male', 'Female'],
              title: 'Select Gender',
              showError: _genderRequired,
              onChanged: (value) => print('Selected gender: $value'),
            ),
            CustomDropdown(
              allValues: ['Single', 'Married', 'Other'],
              title: 'Marital Status',
              onChanged: (value) => print('Selected status: $value'),
            ),
            CustomDatePicker(type: 'Date of Birth', controller: _dobController),
            CustomDatePicker(
              type: 'Date of Joining',
              controller: _dateOfJoiningController,
            ),
            CustomDropdown(
              allValues: const [
                'Admin',
                'Accountant',
                'Cleaner',
                'Teacher',
                'Secretary',
                'Principal',
                'Head Teacher',
                'Others',
              ],
              title: 'Select Role',
              onChanged: (value) => print('Selected role: $value'),
            ),
            CustomDropdown(
              allValues: const [
                'Admin',
                'Accountant',
                'Cleaner',
                'Teacher',
                'Secretary',
                'Principal',
                'Head Teacher',
                'Others',
              ],
              title: 'Select Role',
              onChanged: (value) => print('Selected role: $value'),
            ),
            CustomDropdown(
              allValues: const [
                'Admin',
                'Accountant',
                'Cleaner',
                'Teacher',
                'Secretary',
                'Principal',
                'Head Teacher',
                'Others',
              ],
              title: 'Select Role',
              onChanged: (value) => print('Selected role: $value'),
            ),
            _customField(
              context,
              title: 'CURRENT ADDRESS',
              controller: _currentAddressController,
            ),
            _customField(
              context,
              title: 'PERMANENT ADDRESS',
              controller: _permanentAddressController,
            ),
            _customField(
              context,
              title: 'QUALIFICATIONS',
              controller: _qualificationController,
            ),
            _customField(
              context,
              title: 'EXPERIENCE',
              controller: _experienceController,
            ),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  _fristnameRequired =
                      _lasstnameRequired =
                          _emailRequired = _genderRequired = true;
                });
                if (_nameController.text.isNotEmpty) {
                  // Proceed with form submission
                  print("Form submitted with: ${_nameController.text}");
                } else {
                  // Show error
                  print("Please fill all fields");
                }
              },
              child: const Text('Submit'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: homeColor,
                minimumSize: const Size(150, 50),
                shape: BeveledRectangleBorder(
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              onPressed: () {
                widget.controller.animateTo(1);
              },
              child: const Text('Next', style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }

  SizedBox _customField(
    BuildContext context, {
    required String title,
    required TextEditingController controller,
  }) {
    return SizedBox(
      width: MediaQuery.sizeOf(context).width * 0.3,
      height: 200,
      child: TextField(
        controller: controller,
        maxLines: 20,
        decoration: InputDecoration(
          labelText: title,
          labelStyle: const TextStyle(fontSize: 12),
          filled: true,
          fillColor: Colors.white,
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Colors.grey),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.blue.withOpacity(.4)),
          ),
        ),
      ),
    );
  }
}
