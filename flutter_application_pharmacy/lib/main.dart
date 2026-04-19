// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:firebase_core/firebase_core.dart';
// import 'package:flutter/foundation.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_application_pharmacy/models/user_model.dart';
// import 'package:flutter_application_pharmacy/pharmacy_registration.dart';
// import 'package:flutter_application_pharmacy/screens/welcome_screen.dart';
// import 'home_page.dart';
// import 'package:flutter_application_pharmacy/medicine_reminders.dart';
// import 'package:flutter_application_pharmacy/profile_page.dart';
// import 'package:flutter_application_pharmacy/reports.dart';
// import 'package:flutter_application_pharmacy/signin.dart';
// import 'package:flutter_application_pharmacy/signup.dart';
// import 'package:provider/provider.dart';
// // Removed import for custom_bottom_nav_bar.dart as it's not needed in MainScreen

// void main() async {
//   WidgetsFlutterBinding.ensureInitialized();

//   try {
//     if (kIsWeb) {
//       await Firebase.initializeApp(
//         options: const FirebaseOptions(
//           apiKey: "AIzaSyC3ZTxN5FbvDigGHIsu6mxmnUCpO6Fv1Wo",
//           authDomain: "final-fdbdf.firebaseapp.com",
//           projectId: "final-fdbdf",
//           storageBucket: "final-fdbdf.firebasestorage.app",
//           messagingSenderId: "303329458389",
//           appId: "1:303329458389:web:ddca75e80fa3b42d904a5c",
//           measurementId: "G-CFWM391TRV",
//         ),
//       );
//     } else {
//       await Firebase.initializeApp();
//     }
//     print("Firebase initialized successfully");
//   } catch (e) {
//     print("Firebase initialization error: $e");
//   }

//   runApp(const MyApp());
// }

// class MyApp extends StatelessWidget {
//   const MyApp({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return MultiProvider(
//       providers: [ChangeNotifierProvider(create: (context) => UserModel())],
//       child: MaterialApp(title: 'Pharmacy App', home: const WelcomeScreen()),
//     );
//   }
// }

// class MainScreen extends StatefulWidget {
//   final String userName;

//   const MainScreen({super.key, required this.userName});

//   @override
//   _MainScreenState createState() => _MainScreenState();
// }

// class _MainScreenState extends State<MainScreen> {
//   int _currentIndex = 0;

//   late List<Widget> _pages;

//   @override
//   void initState() {
//     super.initState();
//     _pages = [
//       HomePage(userName: widget.userName),
//       ReportsPage(userName: widget.userName),
//       MedicineReminder(userName: widget.userName),
//       ProfilePage(userName: widget.userName),
//     ];
//   }

//   void _onNavBarTap(int index) {
//     setState(() {
//       _currentIndex = index;
//     });
//   }

//   Future<bool> _onWillPop() async {
//     if (_currentIndex != 0) {
//       setState(() {
//         _currentIndex = 0; // Navigate to HomePage (index 0)
//       });
//       return false; // Prevent app exit
//     }
//     // Delegate to the current page's _onWillPop (e.g., HomePage's exit dialog)
//     return true;
//   }

//   @override
//   Widget build(BuildContext context) {
//     return WillPopScope(
//       onWillPop: _onWillPop,
//       child: IndexedStack(index: _currentIndex, children: _pages),
//     );
//   }
// }
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_pharmacy/doctor_profile.dart';
import 'package:flutter_application_pharmacy/models/user_model.dart';
import 'package:flutter_application_pharmacy/pharmacy_profile.dart';
import 'package:flutter_application_pharmacy/pharmacy_registration.dart';
import 'package:flutter_application_pharmacy/screens/welcome_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_application_pharmacy/main_screen.dart';
import 'package:provider/provider.dart';
import 'doctor_regestration.dart';
import 'home_page.dart';
import 'medicine_reminders.dart';
import 'profile_page.dart';
import 'reports.dart';
import 'signin.dart';
import 'signup.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    if (kIsWeb) {
      await Firebase.initializeApp(
        options: const FirebaseOptions(
          apiKey: "AIzaSyC3ZTxN5FbvDigGHIsu6mxmnUCpO6Fv1Wo",
          authDomain: "final-fdbdf.firebaseapp.com",
          projectId: "final-fdbdf",
          storageBucket: "final-fdbdf.firebasestorage.app",
          messagingSenderId: "303329458389",
          appId: "1:303329458389:web:ddca75e80fa3b42d904a5c",
          measurementId: "G-CFWM391TRV",
        ),
      );
    } else {
      await Firebase.initializeApp();
    }
    print("Firebase initialized successfully");
  } catch (e) {
    print("Firebase initialization error: $e");
  }

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [ChangeNotifierProvider(create: (context) => UserModel())],
      child: MaterialApp(
        title: 'Pharmacy App',
        debugShowCheckedModeBanner: false, // Disable debug banner
        home: const AuthWrapper(),
      ),
    );
  }
}

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  Future<Widget> _getInitialScreen(User user, BuildContext context) async {
    try {
      final firestore = FirebaseFirestore.instance;
      QuerySnapshot userQuery =
          await firestore
              .collection('users')
              .where('email', isEqualTo: user.email)
              .limit(1)
              .get();

      if (userQuery.docs.isNotEmpty) {
        DocumentSnapshot userDoc = userQuery.docs.first;
        String docId = userDoc.id;
        String userName = userDoc['name'] ?? "Unknown";
        String? userRole = userDoc['role'];
        String? phone = userDoc['phone'] ?? "";
        DateTime? createdAt = (userDoc['createdAt'] as Timestamp?)?.toDate();

        // Update UserModel
        Provider.of<UserModel>(context, listen: false).setUser(
          docId: docId,
          name: userName,
          email: user.email ?? "unknown@example.com",
          role: userRole,
          phone: phone,
          createdAt: createdAt,
        );

        // Navigate based on role
        switch (userRole) {
          case "Doctor":
            QuerySnapshot doctorQuery =
                await firestore
                    .collection('doctors')
                    .where('email', isEqualTo: user.email)
                    .limit(1)
                    .get();

            if (doctorQuery.docs.isNotEmpty) {
              String doctorId = doctorQuery.docs.first.id;
              DocumentSnapshot doctorDoc = doctorQuery.docs.first;
              Map<String, dynamic> data =
                  doctorDoc.data() as Map<String, dynamic>;
              bool isComplete =
                  data.containsKey('fullName') &&
                  data['fullName'] != null &&
                  data['fullName'].toString().isNotEmpty &&
                  data.containsKey('specialty') &&
                  data['specialty'] != null &&
                  data['specialty'].toString().isNotEmpty &&
                  data.containsKey('location') &&
                  data['location'] != null &&
                  data['location'].toString().isNotEmpty &&
                  data.containsKey('age') &&
                  data['age'] != null &&
                  data.containsKey('mobile') &&
                  data['mobile'] != null &&
                  data['mobile'].toString().isNotEmpty;

              if (isComplete) {
                return DoctorProfilePage(doctorId: doctorId);
              } else {
                await firestore.collection('doctors').doc(doctorId).delete();
                return DoctorRegistrationPage(
                  userName: userName,
                  email: user.email ?? "unknown@example.com",
                );
              }
            } else {
              return DoctorRegistrationPage(
                userName: userName,
                email: user.email ?? "unknown@example.com",
              );
            }
          case "Pharmacist":
            QuerySnapshot pharmacyQuery =
                await firestore
                    .collection('pharmacies')
                    .where('email', isEqualTo: user.email)
                    .limit(1)
                    .get();

            if (pharmacyQuery.docs.isNotEmpty) {
              String pharmacyId = pharmacyQuery.docs.first.id;
              DocumentSnapshot pharmacyDoc = pharmacyQuery.docs.first;
              Map<String, dynamic> data =
                  pharmacyDoc.data() as Map<String, dynamic>;
              bool isComplete =
                  data.containsKey('pharmacyName') &&
                  data['pharmacyName'] != null &&
                  data['pharmacyName'].toString().isNotEmpty &&
                  data.containsKey('location') &&
                  data['location'] != null &&
                  data['location'].toString().isNotEmpty;

              if (isComplete) {
                return PharmacyProfilePage(pharmacyId: pharmacyId);
              } else {
                await firestore
                    .collection('pharmacies')
                    .doc(pharmacyId)
                    .delete();
                return PharmacyRegistrationPage(
                  userName: userName,
                  email: user.email ?? "unknown@example.com",
                );
              }
            } else {
              return PharmacyRegistrationPage(
                userName: userName,
                email: user.email ?? "unknown@example.com",
              );
            }
          case "Patient":
          case "Caretaker":
          default:
            return MainScreen(userName: userName);
        }
      } else {
        // User not found in Firestore, sign out and show WelcomeScreen
        await FirebaseAuth.instance.signOut();
        return const WelcomeScreen();
      }
    } catch (e) {
      print("Error determining initial screen: $e");
      return const WelcomeScreen();
    }
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
        if (snapshot.hasData && snapshot.data != null) {
          // User is signed in, determine the appropriate screen
          return FutureBuilder<Widget>(
            future: _getInitialScreen(snapshot.data!, context),
            builder: (context, screenSnapshot) {
              if (screenSnapshot.connectionState == ConnectionState.waiting) {
                return const Scaffold(
                  body: Center(child: CircularProgressIndicator()),
                );
              }
              return screenSnapshot.data ?? const WelcomeScreen();
            },
          );
        }
        // User is not signed in, show WelcomeScreen
        return const WelcomeScreen();
      },
    );
  }
}
