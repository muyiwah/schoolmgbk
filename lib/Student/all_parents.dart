import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:schmgtsystem/color_pallete.dart';
import 'package:schmgtsystem/widgets/screen_header.dart';

class AllParents extends StatelessWidget {
  AllParents({super.key, required this.navigateTo});
  final Function navigateTo;
  final List<Map<String, dynamic>> peopleList = List.generate(30, (index) {
    return {
      "name": _randomName(),
      "role": _randomRole(),
      "email": "user$index@example.com",
      "phone": "(${_randomAreaCode()}) 555-${1000 + index}",
      "avatar":
          "https://randomuser.me/api/portraits/${index % 2 == 0 ? 'men' : 'women'}/$index.jpg",
    };
  });

  static String _randomName() {
    const firstNames = [
      "Linnie",
      "Miguel",
      "Jenna",
      "Chris",
      "Alex",
      "Taylor",
      "Jordan",
      "Morgan",
      "Jamie",
      "Pat",
    ];
    const lastNames = [
      "Richardson",
      "Daniels",
      "Smith",
      "Brown",
      "Johnson",
      "Lee",
      "Clark",
      "Hall",
      "Turner",
      "Evans",
    ];
    return "${firstNames[_randomIndex(firstNames.length)]} ${lastNames[_randomIndex(lastNames.length)]}";
  }

  static String _randomRole() {
    const roles = [
      "Account Manager",
      "Salon Owner",
      "Sales Lead",
      "Designer",
      "Developer",
      "Marketing Director",
    ];
    return roles[_randomIndex(roles.length)];
  }

  static int _randomAreaCode() {
    const codes = [302, 629, 415, 212, 646, 718, 305, 213];
    return codes[_randomIndex(codes.length)];
  }

  static int _randomIndex(int max) =>
      (DateTime.now().millisecondsSinceEpoch % max);

  List images = [
    'assets/images/1.jpeg',
    'assets/images/2.jpeg',
    'assets/images/3.jpeg',
    'assets/images/4.jpeg',
    'assets/images/5.jpeg',
    'assets/images/6.jpeg',
    'assets/images/7.jpeg',
    'assets/images/8.jpeg',
    'assets/images/9.jpeg',
    'assets/images/10.jpeg',
    'assets/images/1.jpeg',
    'assets/images/2.jpeg',
    'assets/images/3.jpeg',
    'assets/images/4.jpeg',
    'assets/images/5.jpeg',
    'assets/images/6.jpeg',
    'assets/images/7.jpeg',
    'assets/images/8.jpeg',
    'assets/images/9.jpeg',
    'assets/images/10.jpeg',
    'assets/images/1.jpeg',
    'assets/images/2.jpeg',
    'assets/images/3.jpeg',
    'assets/images/4.jpeg',
    'assets/images/5.jpeg',
    'assets/images/6.jpeg',
    'assets/images/7.jpeg',
    'assets/images/8.jpeg',
    'assets/images/9.jpeg',
    'assets/images/10.jpeg',
    'assets/images/1.jpeg',
    'assets/images/2.jpeg',
    'assets/images/3.jpeg',
    'assets/images/4.jpeg',
    'assets/images/5.jpeg',
    'assets/images/6.jpeg',
    'assets/images/7.jpeg',
    'assets/images/8.jpeg',
    'assets/images/9.jpeg',
    'assets/images/10.jpeg',
  ];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          color: screenBackground,
        ),
        child: Column(
          children: [
            ScreenHeader(
              group: 'Parents',
              subgroup: 'All Parents',
              showSearchBar: true,
            ),
            const SizedBox(height: 20),
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(20),
                width: double.infinity,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.grey.withOpacity(.3)),
                ),
                child: SingleChildScrollView(
                  child: Wrap(
                    alignment: WrapAlignment.spaceBetween,
                    runSpacing: 20,
                    children: List.generate(peopleList.length, (index) {
                      final person = peopleList[index];
                      return GestureDetector(
                        onTap: () {
                          navigateTo();
                        },
                        child: ConstrainedBox(
                          constraints: const BoxConstraints(
                            minWidth: 120,
                            maxWidth: 240,
                            minHeight: 160,
                            maxHeight: 240,
                          ),
                          child: Container(
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(14),
                                  color: Colors.white,
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.05),
                                      blurRadius: 10,
                                      offset: const Offset(0, 4),
                                    ),
                                  ],
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceAround,
                                  children: [
                                    Row(
                                      children: [
                                        CircleAvatar(
                                          backgroundImage: AssetImage(
                                            images[index],
                                          ),
                                          radius: 20,
                                        ),
                                        const SizedBox(width: 10),
                                        Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              person['name'],
                                              style: const TextStyle(
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                            Text(
                                              person['role'],
                                              style: const TextStyle(
                                                fontSize: 12,
                                                color: Colors.grey,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                    // SizedBox(height: 10,),
                                    Divider(
                                      color: Colors.grey.shade300,
                                      height: .2,
                                    ),
                                    // const SizedBox(height: 16),
                                    Row(
                                      children: [
                                        const Icon(
                                          Icons.email_outlined,
                                          size: 16,
                                        ),
                                        const SizedBox(width: 6),
                                        Expanded(
                                          child: Text(
                                            person['email'],
                                            style: const TextStyle(fontSize: 13),
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                      ],
                                    ),
                                    // const SizedBox(height: 8),
                                    Row(
                                      children: [
                                        const Icon(
                                          Icons.phone,
                                          size: 16,
                                          color: Colors.grey,
                                        ),
                                        const SizedBox(width: 6),
                                        Text(
                                          person['phone'],
                                          style: const TextStyle(
                                            fontSize: 13,
                                            color: Colors.grey,
                                          ),
                                        ),
                                      ],
                                    ),
                                    Row(
                                      children: [
                                        const Icon(
                                          Icons.phone,
                                          size: 16,
                                          color: Colors.grey,
                                        ),
                                        const SizedBox(width: 6),
                                        Text(
                                          person['phone'],
                                          style: const TextStyle(
                                            fontSize: 13,
                                            color: Colors.grey,
                                          ),
                                        ),
                                      ],
                                    ),
                                    Row(
                                      children: [
                                        const Icon(
                                          Icons.phone,
                                          size: 16,
                                          color: Colors.grey,
                                        ),
                                        const SizedBox(width: 6),
                                        Text(
                                          person['phone'],
                                          style: const TextStyle(
                                            fontSize: 13,
                                            color: Colors.grey,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              )
                              .animate()
                              .fadeIn(
                                delay: Duration(milliseconds: 100 * index),
                                duration: const Duration(milliseconds: 400),
                              )
                              .slideX(
                                begin: 1,
                                delay: Duration(milliseconds: 100 * index),
                                duration: const Duration(milliseconds: 400),
                              ),
                        ),
                      );
                    }),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
