// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_application_pharmacy/home_page.dart';
// import 'package:flutter_application_pharmacy/models/user_model.dart';
// import 'package:flutter_application_pharmacy/screens/health_info_form.dart';
// import 'package:flutter_application_pharmacy/services/bluetooth_service.dart';
// import 'package:intl/intl.dart';
// import 'package:provider/provider.dart';
// import 'package:path_provider/path_provider.dart';
// import 'package:pdf/widgets.dart' as pw;
// import 'package:share_plus/share_plus.dart';
// import 'dart:io';

// class ReportsPage extends StatefulWidget {
//   final String userName;
//   const ReportsPage({super.key, required this.userName});

//   @override
//   _ReportsPageState createState() => _ReportsPageState();
// }

// class _ReportsPageState extends State<ReportsPage>
//     with SingleTickerProviderStateMixin {
//   String _heartRate = "97";
//   String _weight = "103";
//   String _bloodGroup = "A+";
//   bool _isFetching = false;
//   bool _isLoading = false;
//   bool _showLoadingIndicator = false;
//   String? _docId;
//   String? _targetDocId;
//   late BluetoothManager _bluetoothManager;

//   late AnimationController _animationController;
//   late Animation<double> _fadeAnimation;

//   @override
//   void initState() {
//     super.initState();
//     print("ReportsPage - Initializing...");
//     _bluetoothManager = BluetoothManager();
//     _animationController = AnimationController(
//       vsync: this,
//       duration: const Duration(milliseconds: 500),
//     );
//     _fadeAnimation = CurvedAnimation(
//       parent: _animationController,
//       curve: Curves.easeInOut,
//     );
//     _animationController.forward();
//     _showLoadingIndicator = true;
//     _loadHealthData();
//     _autoConnectToBluetooth();
//     _checkAndDownloadWeeklyReport();
//   }

//   @override
//   void dispose() {
//     _animationController.dispose();
//     _bluetoothManager.dispose();
//     super.dispose();
//   }

//   Future<void> _loadHealthData({bool showIndicator = true}) async {
//     print("ReportsPage - Loading health data...");
//     setState(() {
//       _isLoading = true;
//       _showLoadingIndicator = showIndicator;
//     });
//     final user = FirebaseAuth.instance.currentUser;
//     final userModel = Provider.of<UserModel>(context, listen: false);
//     if (user == null) {
//       print("No user logged in.");
//       setState(() {
//         _isLoading = false;
//         _showLoadingIndicator = false;
//       });
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(content: Text('Please sign in to view reports')),
//       );
//       return;
//     }

//     try {
//       QuerySnapshot userQuery =
//           await FirebaseFirestore.instance
//               .collection('users')
//               .where('email', isEqualTo: user.email)
//               .limit(1)
//               .get();

//       if (userQuery.docs.isNotEmpty) {
//         _docId = userQuery.docs.first.id;
//         _targetDocId = _docId;

//         if (userModel.role == 'Caretaker') {
//           final userDoc =
//               await FirebaseFirestore.instance
//                   .collection('users')
//                   .doc(_docId)
//                   .get();
//           _targetDocId = userDoc.data()?['linkedDocId'] as String?;
//           if (_targetDocId == null || _targetDocId!.isEmpty) {
//             print("No linked patient found for caretaker.");
//             setState(() {
//               _isLoading = false;
//               _showLoadingIndicator = false;
//             });
//             ScaffoldMessenger.of(context).showSnackBar(
//               const SnackBar(content: Text('No linked patient found')),
//             );
//             return;
//           }

//           final doc =
//               await FirebaseFirestore.instance
//                   .collection('users')
//                   .doc(_targetDocId)
//                   .collection('health_info')
//                   .doc('data')
//                   .get();

//           if (doc.exists) {
//             final data = doc.data();
//             setState(() {
//               _weight = data?['weight'] ?? "103";
//               _bloodGroup = data?['bloodGroup'] ?? "A+";
//               _heartRate = data?['heartRate'] ?? "97";
//               print(
//                 "Caretaker - Initial data loaded: Weight: $_weight, Blood Group: $_bloodGroup, Heart Rate: $_heartRate, TargetDocId: $_targetDocId",
//               );
//             });
//           } else {
//             print("No health data found for patient.");
//           }

//           FirebaseFirestore.instance
//               .collection('users')
//               .doc(_targetDocId)
//               .collection('health_info')
//               .doc('data')
//               .snapshots()
//               .listen(
//                 (docSnapshot) {
//                   if (docSnapshot.exists) {
//                     final data = docSnapshot.data();
//                     setState(() {
//                       _heartRate = data?['heartRate'] ?? "97";
//                       _weight = data?['weight'] ?? "103";
//                       _bloodGroup = data?['bloodGroup'] ?? "A+";
//                       print(
//                         "Caretaker - Real-time update: Heart Rate: $_heartRate, Weight: $_weight, Blood Group: $_bloodGroup",
//                       );
//                     });
//                   } else {
//                     print("No health data found for patient.");
//                     setState(() {
//                       _heartRate = "97";
//                       _weight = "103";
//                       _bloodGroup = "A+";
//                     });
//                   }
//                 },
//                 onError: (e) {
//                   print("Error listening to health data: $e");
//                   ScaffoldMessenger.of(context).showSnackBar(
//                     SnackBar(content: Text('Error loading health data: $e')),
//                   );
//                 },
//               );
//         } else {
//           final doc =
//               await FirebaseFirestore.instance
//                   .collection('users')
//                   .doc(_docId)
//                   .collection('health_info')
//                   .doc('data')
//                   .get();

//           print("Firestore response - Exists: ${doc.exists}");
//           if (doc.exists) {
//             final data = doc.data();
//             setState(() {
//               _weight = data?['weight'] ?? "103";
//               _bloodGroup = data?['bloodGroup'] ?? "A+";
//               _heartRate = data?['heartRate'] ?? "97";
//               print(
//                 "Patient - Data loaded: Weight: $_weight, Blood Group: $_bloodGroup, Heart Rate: $_heartRate, DocId: $_docId",
//               );
//             });
//           } else {
//             print("No data found at path. Using defaults.");
//           }
//         }
//       }
//     } catch (e) {
//       print("Error loading health data: $e");
//       ScaffoldMessenger.of(
//         context,
//       ).showSnackBar(SnackBar(content: Text('Error loading data: $e')));
//     } finally {
//       setState(() {
//         _isLoading = false;
//         _showLoadingIndicator = false;
//       });
//     }
//   }

//   Future<void> _autoConnectToBluetooth() async {
//     final userModel = Provider.of<UserModel>(context, listen: false);
//     if (userModel.role == 'Caretaker') {
//       print("Caretaker cannot connect to Bluetooth");
//       return;
//     }
//     if (_docId == null) {
//       print("No docId available, cannot connect to Bluetooth");
//       await _loadHealthData(showIndicator: false); // Ensure docId is loaded
//       if (_docId == null) return;
//     }
//     print("Attempting auto-connect to NanoHRM for docId: $_docId");
//     setState(() => _isFetching = true);
//     await _bluetoothManager.connectToBluetooth(
//       context: context,
//       docId: _docId!,
//       onHeartRateUpdate: (heartRate) {
//         if (mounted) {
//           setState(() {
//             _heartRate = heartRate;
//             _isFetching = false;
//             print("Heart rate updated in UI: $_heartRate");
//           });
//         }
//       },
//       onMessage: (message) {
//         if (mounted) {
//           ScaffoldMessenger.of(
//             context,
//           ).showSnackBar(SnackBar(content: Text(message)));
//           print("Bluetooth message: $message");
//         }
//       },
//       onFetchingStateChange: (isFetching) {
//         if (mounted) {
//           setState(() {
//             _isFetching = isFetching;
//             print("Fetching state changed: $_isFetching");
//           });
//         }
//       },
//       isRefresh: false,
//     );
//   }

//   Future<void> _checkAndDownloadWeeklyReport() async {
//     final user = FirebaseAuth.instance.currentUser;
//     if (user == null || _docId == null) return;

//     final now = DateTime.now();
//     final isSundayMidnight =
//         now.weekday == DateTime.sunday && now.hour == 0 && now.minute < 5;

//     if (!isSundayMidnight) return;

//     try {
//       final userDoc =
//           await FirebaseFirestore.instance
//               .collection('users')
//               .doc(_docId)
//               .get();
//       final linkedDocId = userDoc.data()?['linkedDocId'] as String?;

//       final timeFrame = DateTime.now().subtract(const Duration(days: 7));
//       final timestamp = Timestamp.fromDate(timeFrame);
//       final querySnapshot =
//           await FirebaseFirestore.instance
//               .collection('users')
//               .doc(_docId)
//               .collection('reminders')
//               .where('timestamp', isGreaterThan: timestamp)
//               .get();

//       final reminders =
//           querySnapshot.docs.map((doc) {
//             final data = doc.data();
//             return {
//               'medicine': data['medicine'] ?? 'Unknown',
//               'dosage': data['dosage'] ?? 'N/A',
//               'times': (data['times'] as List? ?? [])
//                   .map((t) => t.toString())
//                   .join(', '),
//               'isDaily': data['isDaily'] ?? true,
//               'timestamp': (data['timestamp'] as Timestamp?)?.toDate(),
//               'taken': data['taken'] ?? false,
//             };
//           }).toList();

//       String reportContent =
//           "Weekly Health Report (${DateFormat('MMM d, yyyy').format(timeFrame)} - ${DateFormat('MMM d, yyyy').format(now)})\n\n";
//       for (var reminder in reminders) {
//         reportContent += "Medicine: ${reminder['medicine']}\n";
//         reportContent += "Dosage: ${reminder['dosage']}\n";
//         reportContent += "Times: ${reminder['times']}\n";
//         reportContent +=
//             "Frequency: ${reminder['isDaily'] ? 'Daily' : 'Weekly'}\n";
//         reportContent +=
//             "Status: ${reminder['taken'] ? 'Taken' : 'Not Taken'}\n";
//         reportContent +=
//             "Added: ${reminder['timestamp'] != null ? DateFormat('MMM d, h:mm a').format(reminder['timestamp'] as DateTime) : 'N/A'}\n\n";
//       }

//       final directory = await getApplicationDocumentsDirectory();
//       final patientFile = File(
//         '${directory.path}/weekly_report_${_docId}_${now.millisecondsSinceEpoch}.txt',
//       );
//       await patientFile.writeAsString(reportContent);
//       print("Report saved for patient at: ${patientFile.path}");

//       if (mounted) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(
//             content: Text('Weekly report downloaded to ${patientFile.path}'),
//           ),
//         );
//       }

//       if (linkedDocId != null && linkedDocId.isNotEmpty) {
//         final caretakerFile = File(
//           '${directory.path}/weekly_report_${linkedDocId}_${now.millisecondsSinceEpoch}.txt',
//         );
//         await caretakerFile.writeAsString(reportContent);
//         print("Report saved for caretaker at: ${caretakerFile.path}");
//       }
//     } catch (e) {
//       print("Error downloading weekly report: $e");
//       if (mounted) {
//         ScaffoldMessenger.of(
//           context,
//         ).showSnackBar(SnackBar(content: Text('Error downloading report: $e')));
//       }
//     }
//   }

//   Future<void> _generateAndShareWeeklyReport() async {
//     if (_targetDocId == null) {
//       if (mounted) {
//         ScaffoldMessenger.of(
//           context,
//         ).showSnackBar(const SnackBar(content: Text('User data not loaded')));
//       }
//       return;
//     }

//     try {
//       // Load bundled font
//       final fontData = await DefaultAssetBundle.of(
//         context,
//       ).load('assets/fonts/Roboto-Regular.ttf');
//       final font = pw.Font.ttf(fontData);

//       final now = DateTime.now();
//       final timeFrame = now.subtract(const Duration(days: 7));
//       final timestamp = Timestamp.fromDate(timeFrame);
//       final querySnapshot =
//           await FirebaseFirestore.instance
//               .collection('users')
//               .doc(_targetDocId)
//               .collection('reminders')
//               .where('timestamp', isGreaterThan: timestamp)
//               .get();

//       final reminders =
//           querySnapshot.docs.map((doc) {
//             final data = doc.data();
//             return {
//               'medicine': data['medicine'] ?? 'Unknown',
//               'dosage': data['dosage'] ?? 'N/A',
//               'times': (data['times'] as List? ?? [])
//                   .map((t) => t.toString())
//                   .join(', '),
//               'isDaily': data['isDaily'] ?? true,
//               'timestamp': (data['timestamp'] as Timestamp?)?.toDate(),
//               'taken': data['taken'] ?? false,
//             };
//           }).toList();

//       final complianceRate =
//           reminders.isNotEmpty
//               ? (reminders.where((r) => r['taken'] as bool).length /
//                       reminders.length *
//                       100)
//                   .toStringAsFixed(1)
//               : '0';
//       final takenCount = reminders.where((r) => r['taken'] as bool).length;
//       final totalCount = reminders.length;

//       final pdf = pw.Document();
//       pdf.addPage(
//         pw.Page(
//           build:
//               (pw.Context context) => pw.Column(
//                 crossAxisAlignment: pw.CrossAxisAlignment.start,
//                 children: [
//                   pw.Text(
//                     'Weekly Health Report',
//                     style: pw.TextStyle(
//                       fontSize: 24,
//                       fontWeight: pw.FontWeight.bold,
//                       font: font,
//                     ),
//                   ),
//                   pw.SizedBox(height: 10),
//                   pw.Text(
//                     '${DateFormat('MMM d, yyyy').format(timeFrame)} - ${DateFormat('MMM d, yyyy').format(now)}',
//                     style: pw.TextStyle(fontSize: 16, font: font),
//                   ),
//                   pw.SizedBox(height: 20),
//                   pw.Text(
//                     'Compliance Overview',
//                     style: pw.TextStyle(
//                       fontSize: 18,
//                       fontWeight: pw.FontWeight.bold,
//                       font: font,
//                     ),
//                   ),
//                   pw.SizedBox(height: 10),
//                   pw.Text(
//                     'Compliance Rate: $complianceRate%',
//                     style: pw.TextStyle(font: font),
//                   ),
//                   pw.Text(
//                     'Taken/Total: $takenCount/$totalCount',
//                     style: pw.TextStyle(font: font),
//                   ),
//                   pw.SizedBox(height: 20),
//                   pw.Text(
//                     'Reminders',
//                     style: pw.TextStyle(
//                       fontSize: 18,
//                       fontWeight: pw.FontWeight.bold,
//                       font: font,
//                     ),
//                   ),
//                   pw.SizedBox(height: 10),
//                   if (reminders.isEmpty)
//                     pw.Text(
//                       'No reminders found for this period.',
//                       style: pw.TextStyle(font: font),
//                     )
//                   else
//                     ...reminders.map(
//                       (reminder) => pw.Column(
//                         crossAxisAlignment: pw.CrossAxisAlignment.start,
//                         children: [
//                           pw.Text(
//                             'Medicine: ${reminder['medicine']}',
//                             style: pw.TextStyle(fontSize: 14, font: font),
//                           ),
//                           pw.Text(
//                             'Dosage: ${reminder['dosage']}',
//                             style: pw.TextStyle(font: font),
//                           ),
//                           pw.Text(
//                             'Times: ${reminder['times']}',
//                             style: pw.TextStyle(font: font),
//                           ),
//                           pw.Text(
//                             'Frequency: ${reminder['isDaily'] ? 'Daily' : 'Weekly'}',
//                             style: pw.TextStyle(font: font),
//                           ),
//                           pw.Text(
//                             'Status: ${reminder['taken'] ? 'Taken' : 'Not Taken'}',
//                             style: pw.TextStyle(font: font),
//                           ),
//                           pw.Text(
//                             'Added: ${reminder['timestamp'] != null ? DateFormat('MMM d, h:mm a').format(reminder['timestamp'] as DateTime) : 'N/A'}',
//                             style: pw.TextStyle(font: font),
//                           ),
//                           pw.SizedBox(height: 10),
//                         ],
//                       ),
//                     ),
//                 ],
//               ),
//         ),
//       );

//       final directory = await getApplicationDocumentsDirectory();
//       final file = File(
//         '${directory.path}/weekly_report_${_targetDocId}_${now.millisecondsSinceEpoch}.pdf',
//       );
//       await file.writeAsBytes(await pdf.save());
//       print("PDF report saved at: ${file.path}");

//       if (mounted) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(content: Text('Report downloaded to ${file.path}')),
//         );

//         await Share.shareXFiles(
//           [XFile(file.path)],
//           text: 'Weekly Health Report',
//           subject: 'Weekly Health Report',
//         );
//       }
//     } catch (e, stackTrace) {
//       print("Error generating PDF report: $e");
//       print("Stack trace: $stackTrace");
//       if (mounted) {
//         ScaffoldMessenger.of(
//           context,
//         ).showSnackBar(SnackBar(content: Text('Error generating report: $e')));
//       }
//     }
//   }

//   Future<bool> _onWillPop() async {
//     Navigator.pushReplacement(
//       context,
//       MaterialPageRoute(
//         builder: (context) => HomePage(userName: widget.userName),
//       ),
//     );
//     return false;
//   }

//   @override
//   Widget build(BuildContext context) {
//     print("ReportsPage - Building UI...");
//     final user = FirebaseAuth.instance.currentUser;
//     final userModel = Provider.of<UserModel>(context);
//     final isPatient = userModel.role == 'Patient';
//     final screenWidth = MediaQuery.of(context).size.width; // For responsiveness

//     if (user == null) {
//       return const Center(child: Text('Please log in to view reports.'));
//     }

//     return WillPopScope(
//       onWillPop: _onWillPop,
//       child: Scaffold(
//         backgroundColor: Colors.grey[100],
//         appBar: AppBar(
//           toolbarHeight: 56,
//           title: Text(
//             isPatient ? 'Health Reports' : 'Patient Reports',
//             style: TextStyle(
//               fontSize: screenWidth * 0.055, // Responsive font size
//               fontWeight: FontWeight.w600,
//               color: Colors.white,
//             ),
//             overflow: TextOverflow.ellipsis, // Prevent text overflow
//             maxLines: 1,
//           ),
//           centerTitle: true,
//           backgroundColor: Colors.blueAccent,
//           elevation: 0,
//           flexibleSpace: Container(
//             decoration: const BoxDecoration(
//               gradient: LinearGradient(
//                 colors: [Colors.blueAccent, Colors.lightBlueAccent],
//                 begin: Alignment.topLeft,
//                 end: Alignment.bottomRight,
//               ),
//             ),
//           ),
//         ),
//         body:
//             _isLoading && _showLoadingIndicator
//                 ? const Center(child: CircularProgressIndicator())
//                 : Padding(
//                   padding: EdgeInsets.all(
//                     screenWidth * 0.04,
//                   ), // Responsive padding
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       SizedBox(
//                         height: screenWidth * 0.06,
//                       ), // Responsive spacing
//                       Stack(
//                         children: [
//                           InfoCard(
//                             title:
//                                 isPatient ? "Heart Rate" : "Patient Heart Rate",
//                             value:
//                                 _isFetching && isPatient
//                                     ? "Fetching..."
//                                     : "$_heartRate bpm",
//                             unit: "",
//                             icon: Icons.monitor_heart,
//                             color: Colors.blue.shade100,
//                           ),
//                           if (isPatient)
//                             Positioned(
//                               right: 8,
//                               top: 8,
//                               child: IconButton(
//                                 icon: Icon(
//                                   Icons.refresh,
//                                   color: Colors.blueAccent,
//                                   size:
//                                       screenWidth *
//                                       0.06, // Responsive icon size
//                                 ),
//                                 onPressed: () async {
//                                   if (_docId == null) {
//                                     ScaffoldMessenger.of(context).showSnackBar(
//                                       const SnackBar(
//                                         content: Text(
//                                           'User data not loaded, please try again',
//                                         ),
//                                       ),
//                                     );
//                                     return;
//                                   }
//                                   print(
//                                     "Refresh button pressed, reconnecting...",
//                                   );
//                                   setState(() => _isFetching = true);
//                                   await _bluetoothManager.connectToBluetooth(
//                                     context: context,
//                                     docId: _docId!,
//                                     onHeartRateUpdate: (heartRate) {
//                                       if (mounted) {
//                                         setState(() {
//                                           _heartRate = heartRate;
//                                           _isFetching = false;
//                                           print(
//                                             "Heart rate updated via refresh: $_heartRate",
//                                           );
//                                         });
//                                       }
//                                     },
//                                     onMessage: (message) {
//                                       if (mounted) {
//                                         ScaffoldMessenger.of(
//                                           context,
//                                         ).showSnackBar(
//                                           SnackBar(content: Text(message)),
//                                         );
//                                         print("Bluetooth message: $message");
//                                       }
//                                     },
//                                     onFetchingStateChange: (isFetching) {
//                                       if (mounted) {
//                                         setState(() {
//                                           _isFetching = isFetching;
//                                           print(
//                                             "Fetching state changed: $_isFetching",
//                                           );
//                                         });
//                                       }
//                                     },
//                                     isRefresh: true,
//                                   );
//                                 },
//                               ),
//                             ),
//                         ],
//                       ),
//                       SizedBox(
//                         height: screenWidth * 0.05,
//                       ), // Responsive spacing
//                       Row(
//                         children: [
//                           Expanded(
//                             child: GestureDetector(
//                               onLongPress: () {
//                                 if (_targetDocId != null) {
//                                   showDialog(
//                                     context: context,
//                                     builder:
//                                         (context) => WeightForm(
//                                           initialWeight: _weight,
//                                           docId: _targetDocId!,
//                                         ),
//                                   ).then(
//                                     (_) =>
//                                         _loadHealthData(showIndicator: false),
//                                   );
//                                 }
//                               },
//                               child: InfoCard(
//                                 title: "Weight",
//                                 value: _weight,
//                                 unit: "lbs",
//                                 icon: Icons.scale,
//                                 color: Colors.grey.shade300,
//                               ),
//                             ),
//                           ),
//                           SizedBox(
//                             width: screenWidth * 0.05,
//                           ), // Responsive spacing
//                           Expanded(
//                             child: GestureDetector(
//                               onLongPress: () {
//                                 if (_targetDocId != null) {
//                                   showDialog(
//                                     context: context,
//                                     builder:
//                                         (context) => BloodGroupForm(
//                                           initialBloodGroup: _bloodGroup,
//                                           docId: _targetDocId!,
//                                         ),
//                                   ).then(
//                                     (_) =>
//                                         _loadHealthData(showIndicator: false),
//                                   );
//                                 }
//                               },
//                               child: InfoCard(
//                                 title: "Blood Group",
//                                 value: _bloodGroup,
//                                 unit: "",
//                                 icon: Icons.water_drop,
//                                 color: Colors.red.shade200,
//                               ),
//                             ),
//                           ),
//                         ],
//                       ),
//                       SizedBox(
//                         height: screenWidth * 0.075,
//                       ), // Responsive spacing
//                       Row(
//                         mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                         children: [
//                           Text(
//                             "Latest Reports",
//                             style: TextStyle(
//                               fontSize:
//                                   screenWidth * 0.05, // Responsive font size
//                               fontWeight: FontWeight.w700,
//                               color: Colors.blueGrey,
//                             ),
//                             overflow:
//                                 TextOverflow.ellipsis, // Prevent text overflow
//                             maxLines: 1,
//                           ),
//                           IconButton(
//                             icon: Icon(
//                               Icons.download,
//                               color: Colors.blueAccent,
//                               size: screenWidth * 0.06, // Responsive icon size
//                             ),
//                             onPressed: _generateAndShareWeeklyReport,
//                           ),
//                         ],
//                       ),
//                       const SizedBox(height: 12),
//                       Expanded(
//                         child: _LatestReportsSection(
//                           userName: widget.userName,
//                           docId: _targetDocId,
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//       ),
//     );
//   }
// }

// class InfoCard extends StatelessWidget {
//   final String title;
//   final String value;
//   final String unit;
//   final IconData icon;
//   final Color color;

//   const InfoCard({
//     super.key,
//     required this.title,
//     required this.value,
//     required this.unit,
//     required this.icon,
//     required this.color,
//   });

//   @override
//   Widget build(BuildContext context) {
//     final screenWidth = MediaQuery.of(context).size.width; // For responsiveness
//     return Card(
//       elevation: 2,
//       color: color,
//       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
//       child: ConstrainedBox(
//         constraints: BoxConstraints(
//           maxWidth: screenWidth * 0.9, // Limit card width
//         ),
//         child: Padding(
//           padding: EdgeInsets.all(screenWidth * 0.04), // Responsive padding
//           child: Row(
//             children: [
//               Icon(
//                 icon,
//                 size: screenWidth * 0.1, // Responsive icon size
//                 color: Colors.blueAccent,
//               ),
//               SizedBox(width: screenWidth * 0.04), // Responsive spacing
//               Expanded(
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     Text(
//                       title,
//                       style: TextStyle(
//                         fontSize: screenWidth * 0.04, // Responsive font size
//                         color: Colors.grey,
//                         overflow:
//                             TextOverflow.ellipsis, // Prevent text overflow
//                       ),
//                       maxLines: 1,
//                     ),
//                     SizedBox(height: screenWidth * 0.01), // Responsive spacing
//                     FittedBox(
//                       fit: BoxFit.scaleDown,
//                       child: Text(
//                         "$value $unit",
//                         style: TextStyle(
//                           fontSize: screenWidth * 0.06, // Responsive font size
//                           fontWeight: FontWeight.bold,
//                           color: Colors.black87,
//                         ),
//                         maxLines: 1,
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }

// class _LatestReportsSection extends StatefulWidget {
//   final String userName;
//   final String? docId;

//   const _LatestReportsSection({required this.userName, required this.docId});

//   @override
//   __LatestReportsSectionState createState() => __LatestReportsSectionState();
// }

// class __LatestReportsSectionState extends State<_LatestReportsSection>
//     with SingleTickerProviderStateMixin {
//   String _filter = 'All';
//   bool _showDaily = true;
//   late AnimationController _animationController;
//   late Animation<double> _fadeAnimation;
//   List<Map<String, dynamic>> _reminders = [];
//   late ScrollController _scrollController;

//   @override
//   void initState() {
//     super.initState();
//     _animationController = AnimationController(
//       vsync: this,
//       duration: const Duration(milliseconds: 500),
//     );
//     _fadeAnimation = CurvedAnimation(
//       parent: _animationController,
//       curve: Curves.easeInOut,
//     );
//     _animationController.forward();
//     _scrollController = ScrollController();
//     _subscribeToReminders();
//   }

//   @override
//   void dispose() {
//     _animationController.dispose();
//     _scrollController.dispose();
//     super.dispose();
//   }

//   void _subscribeToReminders() {
//     if (widget.docId == null) return;

//     final timeFrame =
//         _showDaily
//             ? DateTime.now().subtract(const Duration(days: 1))
//             : DateTime.now().subtract(const Duration(days: 7));
//     final timestamp = Timestamp.fromDate(timeFrame);

//     FirebaseFirestore.instance
//         .collection('users')
//         .doc(widget.docId)
//         .collection('reminders')
//         .where('timestamp', isGreaterThan: timestamp)
//         .snapshots()
//         .listen(
//           (snapshot) {
//             final reminders =
//                 snapshot.docs.map((doc) {
//                   final data = doc.data();
//                   return {
//                     'id': doc.id,
//                     'medicine': data['medicine'] ?? 'Unknown',
//                     'dosage': data['dosage'] ?? 'N/A',
//                     'times': (data['times'] as List? ?? [])
//                         .map((t) => t.toString())
//                         .join(', '),
//                     'isDaily': data['isDaily'] ?? true,
//                     'timestamp': data['timestamp'] as Timestamp?,
//                     'taken': data['taken'] ?? false,
//                   };
//                 }).toList();

//             setState(() {
//               _reminders = reminders;
//               print("Reminders updated silently: ${_reminders.length}");
//             });
//           },
//           onError: (e) {
//             print("Error subscribing to reminders: $e");
//             ScaffoldMessenger.of(context).showSnackBar(
//               SnackBar(content: Text('Error fetching reminders: $e')),
//             );
//           },
//         );
//   }

//   Widget _buildFilterButton(String label) {
//     return GestureDetector(
//       onTap: () => setState(() => _filter = label),
//       child: AnimatedContainer(
//         duration: const Duration(milliseconds: 300),
//         width: 90,
//         padding: const EdgeInsets.symmetric(vertical: 10),
//         decoration: BoxDecoration(
//           color: _filter == label ? Colors.blueAccent : Colors.grey.shade100,
//           borderRadius: BorderRadius.circular(10),
//           boxShadow:
//               _filter == label
//                   ? [
//                     BoxShadow(
//                       color: Colors.blueAccent.withOpacity(0.3),
//                       blurRadius: 4,
//                     ),
//                   ]
//                   : [],
//         ),
//         child: Center(
//           child: Text(
//             label,
//             style: TextStyle(
//               fontSize: 14,
//               color: _filter == label ? Colors.white : Colors.black87,
//               fontWeight: FontWeight.w600,
//             ),
//           ),
//         ),
//       ),
//     );
//   }

//   Widget _buildToggleSwitch() {
//     return Container(
//       decoration: BoxDecoration(
//         borderRadius: BorderRadius.circular(10),
//         color: Colors.grey.shade100,
//       ),
//       child: Row(
//         mainAxisSize: MainAxisSize.min,
//         children: [
//           GestureDetector(
//             onTap: () {
//               if (!_showDaily) {
//                 setState(() {
//                   _showDaily = true;
//                 });
//                 _subscribeToReminders();
//               }
//             },
//             child: Container(
//               width: 90,
//               padding: const EdgeInsets.symmetric(vertical: 10),
//               decoration: BoxDecoration(
//                 color: _showDaily ? Colors.blueAccent : Colors.grey.shade100,
//                 borderRadius: const BorderRadius.horizontal(
//                   left: Radius.circular(10),
//                 ),
//               ),
//               child: Center(
//                 child: Text(
//                   'Daily',
//                   style: TextStyle(
//                     fontSize: 14,
//                     color: _showDaily ? Colors.white : Colors.black87,
//                     fontWeight: FontWeight.w600,
//                   ),
//                 ),
//               ),
//             ),
//           ),
//           GestureDetector(
//             onTap: () {
//               if (_showDaily) {
//                 setState(() {
//                   _showDaily = false;
//                 });
//                 _subscribeToReminders();
//               }
//             },
//             child: Container(
//               width: 90,
//               padding: const EdgeInsets.symmetric(vertical: 10),
//               decoration: BoxDecoration(
//                 color: !_showDaily ? Colors.blueAccent : Colors.grey.shade100,
//                 borderRadius: const BorderRadius.horizontal(
//                   right: Radius.circular(10),
//                 ),
//               ),
//               child: Center(
//                 child: Text(
//                   'Weekly',
//                   style: TextStyle(
//                     fontSize: 14,
//                     color: !_showDaily ? Colors.white : Colors.black87,
//                     fontWeight: FontWeight.w600,
//                   ),
//                 ),
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   void _showReminderDetails(
//     BuildContext context,
//     Map<String, dynamic> reminder,
//   ) {
//     final isTaken = reminder['taken'] as bool;
//     final timestamp = (reminder['timestamp'] as Timestamp?)?.toDate();
//     final dateString =
//         timestamp != null
//             ? DateFormat('MMM d, h:mm a').format(timestamp)
//             : 'N/A';

//     showModalBottomSheet(
//       context: context,
//       shape: const RoundedRectangleBorder(
//         borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
//       ),
//       builder: (context) {
//         return Padding(
//           padding: const EdgeInsets.all(12),
//           child: Column(
//             mainAxisSize: MainAxisSize.min,
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               Row(
//                 children: [
//                   CircleAvatar(
//                     radius: 26,
//                     backgroundColor:
//                         isTaken
//                             ? Colors.green.withOpacity(0.1)
//                             : Colors.red.withOpacity(0.1),
//                     child: Icon(
//                       isTaken ? Icons.check_circle : Icons.warning,
//                       color: isTaken ? Colors.green : Colors.red,
//                       size: 32,
//                     ),
//                   ),
//                   const SizedBox(width: 12),
//                   Expanded(
//                     child: Text(
//                       reminder['medicine'],
//                       style: const TextStyle(
//                         fontSize: 22,
//                         fontWeight: FontWeight.bold,
//                         color: Colors.black87,
//                       ),
//                       overflow: TextOverflow.ellipsis,
//                       maxLines: 1,
//                     ),
//                   ),
//                 ],
//               ),
//               const SizedBox(height: 12),
//               Text(
//                 'Dosage: ${reminder['dosage']}',
//                 style: const TextStyle(fontSize: 14, color: Colors.grey),
//               ),
//               const SizedBox(height: 6),
//               Text(
//                 'Times: ${reminder['times']}',
//                 style: const TextStyle(fontSize: 14, color: Colors.grey),
//               ),
//               const SizedBox(height: 6),
//               Text(
//                 'Frequency: ${reminder['isDaily'] ? 'Daily' : 'Weekly'}',
//                 style: const TextStyle(fontSize: 14, color: Colors.grey),
//               ),
//               const SizedBox(height: 6),
//               Text(
//                 'Added: $dateString',
//                 style: const TextStyle(fontSize: 14, color: Colors.grey),
//               ),
//               const SizedBox(height: 6),
//               Text(
//                 'Status: ${isTaken ? 'Taken' : 'Not Taken'}',
//                 style: TextStyle(
//                   fontSize: 14,
//                   color: isTaken ? Colors.green : Colors.red,
//                   fontWeight: FontWeight.w600,
//                 ),
//               ),
//               const SizedBox(height: 20),
//               SizedBox(
//                 width: double.infinity,
//                 child: ElevatedButton(
//                   onPressed: () => Navigator.pop(context),
//                   style: ElevatedButton.styleFrom(
//                     backgroundColor: Colors.blueAccent,
//                     padding: const EdgeInsets.symmetric(vertical: 14),
//                     shape: RoundedRectangleBorder(
//                       borderRadius: BorderRadius.circular(10),
//                     ),
//                     elevation: 2,
//                   ),
//                   child: const Text(
//                     'Close',
//                     style: TextStyle(fontSize: 14, color: Colors.white),
//                   ),
//                 ),
//               ),
//             ],
//           ),
//         );
//       },
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     final filteredReminders =
//         _filter == 'All'
//             ? _reminders
//             : _filter == 'Taken'
//             ? _reminders.where((r) => r['taken'] as bool).toList()
//             : _reminders.where((r) => !(r['taken'] as bool)).toList();

//     final sortedReminders =
//         filteredReminders..sort(
//           (a, b) => (b['timestamp'] as Timestamp).compareTo(
//             a['timestamp'] as Timestamp,
//           ),
//         );

//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Center(child: _buildToggleSwitch()),
//         const SizedBox(height: 12),
//         Center(
//           child: Row(
//             mainAxisSize: MainAxisSize.min,
//             children: [
//               _buildFilterButton('All'),
//               const SizedBox(width: 10),
//               _buildFilterButton('Taken'),
//               const SizedBox(width: 10),
//               _buildFilterButton('Not Taken'),
//             ],
//           ),
//         ),
//         const SizedBox(height: 20),
//         FadeTransition(
//           opacity: _fadeAnimation,
//           child: Card(
//             elevation: 2,
//             shape: RoundedRectangleBorder(
//               borderRadius: BorderRadius.circular(10),
//             ),
//             color: Colors.grey.shade50,
//             child: Padding(
//               padding: const EdgeInsets.all(12),
//               child: ConstrainedBox(
//                 constraints: const BoxConstraints(
//                   maxHeight: 110, // Limit height to prevent overflow
//                 ),
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   mainAxisSize: MainAxisSize.min,
//                   children: [
//                     const Text(
//                       'Compliance Overview',
//                       style: TextStyle(
//                         fontSize: 16, // Slightly smaller font
//                         fontWeight: FontWeight.bold,
//                         color: Colors.black87,
//                       ),
//                     ),
//                     const SizedBox(height: 6),
//                     if (_reminders.isEmpty)
//                       const SizedBox.shrink()
//                     else
//                       Row(
//                         mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                         children: [
//                           Column(
//                             crossAxisAlignment: CrossAxisAlignment.start,
//                             children: [
//                               Text(
//                                 '${_reminders.isNotEmpty ? (_reminders.where((r) => r['taken'] as bool).length / _reminders.length * 100).toStringAsFixed(1) : '0'}%',
//                                 style: const TextStyle(
//                                   fontSize: 24, // Slightly smaller font
//                                   fontWeight: FontWeight.bold,
//                                   color: Colors.blueAccent,
//                                 ),
//                               ),
//                               const Text(
//                                 'Compliance Rate',
//                                 style: TextStyle(
//                                   fontSize: 11, // Slightly smaller font
//                                   color: Colors.grey,
//                                 ),
//                               ),
//                             ],
//                           ),
//                           Column(
//                             crossAxisAlignment: CrossAxisAlignment.start,
//                             children: [
//                               Text(
//                                 '${_reminders.where((r) => r['taken'] as bool).length}/${_reminders.length}',
//                                 style: const TextStyle(
//                                   fontSize: 20, // Slightly smaller font
//                                   fontWeight: FontWeight.bold,
//                                   color: Colors.green,
//                                 ),
//                               ),
//                               const Text(
//                                 'Taken/Total',
//                                 style: TextStyle(
//                                   fontSize: 11, // Slightly smaller font
//                                   color: Colors.grey,
//                                 ),
//                               ),
//                             ],
//                           ),
//                         ],
//                       ),
//                   ],
//                 ),
//               ),
//             ),
//           ),
//         ),
//         const SizedBox(height: 20),
//         Expanded(
//           child:
//               sortedReminders.isEmpty
//                   ? Center(
//                     child: Column(
//                       mainAxisAlignment: MainAxisAlignment.center,
//                       children: [
//                         Icon(
//                           Icons.info_outline,
//                           size: 60,
//                           color: Colors.grey[400],
//                         ),
//                         const SizedBox(height: 12),
//                         Text(
//                           _showDaily
//                               ? 'No reminders added today.'
//                               : 'No reminders added in the past week.',
//                           style: const TextStyle(
//                             fontSize: 14,
//                             color: Colors.grey,
//                           ),
//                         ),
//                       ],
//                     ),
//                   )
//                   : SingleChildScrollView(
//                     controller: _scrollController,
//                     child: Column(
//                       children:
//                           sortedReminders.map((reminder) {
//                             final isTaken = reminder['taken'] as bool;
//                             final timestamp =
//                                 (reminder['timestamp'] as Timestamp?)?.toDate();
//                             final dateString =
//                                 timestamp != null
//                                     ? DateFormat(
//                                       'MMM d, h:mm a',
//                                     ).format(timestamp)
//                                     : 'N/A';

//                             return FadeTransition(
//                               opacity: _fadeAnimation,
//                               child: GestureDetector(
//                                 onTap:
//                                     () =>
//                                         _showReminderDetails(context, reminder),
//                                 child: Card(
//                                   elevation: 2,
//                                   margin: const EdgeInsets.symmetric(
//                                     vertical: 6,
//                                   ),
//                                   shape: RoundedRectangleBorder(
//                                     borderRadius: BorderRadius.circular(10),
//                                   ),
//                                   color: Colors.grey.shade50,
//                                   child: Padding(
//                                     padding: const EdgeInsets.all(12),
//                                     child: Row(
//                                       children: [
//                                         CircleAvatar(
//                                           radius: 20,
//                                           backgroundColor:
//                                               isTaken
//                                                   ? Colors.green.withOpacity(
//                                                     0.1,
//                                                   )
//                                                   : Colors.red.withOpacity(0.1),
//                                           child: Icon(
//                                             isTaken
//                                                 ? Icons.check_circle
//                                                 : Icons.warning,
//                                             color:
//                                                 isTaken
//                                                     ? Colors.green
//                                                     : Colors.red,
//                                             size: 24,
//                                           ),
//                                         ),
//                                         const SizedBox(width: 12),
//                                         Expanded(
//                                           child: Column(
//                                             crossAxisAlignment:
//                                                 CrossAxisAlignment.start,
//                                             children: [
//                                               Text(
//                                                 reminder['medicine'],
//                                                 style: const TextStyle(
//                                                   fontSize: 18,
//                                                   fontWeight: FontWeight.bold,
//                                                   color: Colors.black87,
//                                                 ),
//                                               ),
//                                               const SizedBox(height: 2),
//                                               Text(
//                                                 '${reminder['dosage']} • ${reminder['times']}',
//                                                 style: const TextStyle(
//                                                   fontSize: 14,
//                                                   color: Colors.grey,
//                                                 ),
//                                               ),
//                                               const SizedBox(height: 2),
//                                               Text(
//                                                 'Added: $dateString',
//                                                 style: const TextStyle(
//                                                   fontSize: 12,
//                                                   color: Colors.grey,
//                                                 ),
//                                               ),
//                                               const SizedBox(height: 6),
//                                               Container(
//                                                 padding:
//                                                     const EdgeInsets.symmetric(
//                                                       horizontal: 10,
//                                                       vertical: 4,
//                                                     ),
//                                                 decoration: BoxDecoration(
//                                                   color:
//                                                       isTaken
//                                                           ? Colors.green
//                                                               .withOpacity(0.1)
//                                                           : Colors.red
//                                                               .withOpacity(0.1),
//                                                   borderRadius:
//                                                       BorderRadius.circular(6),
//                                                 ),
//                                                 child: Text(
//                                                   isTaken
//                                                       ? 'Taken'
//                                                       : 'Not Taken',
//                                                   style: TextStyle(
//                                                     fontSize: 12,
//                                                     color:
//                                                         isTaken
//                                                             ? Colors.green
//                                                             : Colors.red,
//                                                     fontWeight: FontWeight.w600,
//                                                   ),
//                                                 ),
//                                               ),
//                                             ],
//                                           ),
//                                         ),
//                                       ],
//                                     ),
//                                   ),
//                                 ),
//                               ),
//                             );
//                           }).toList(),
//                     ),
//                   ),
//         ),
//       ],
//     );
//   }
// }

// class RemindersScreen extends StatelessWidget {
//   const RemindersScreen({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: const Text('Reminders')),
//       body: const Center(child: Text('Reminders Page')),
//     );
//   }
// }

//yeh wala hai
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_application_pharmacy/home_page.dart';
// import 'package:flutter_application_pharmacy/models/user_model.dart';
// import 'package:flutter_application_pharmacy/screens/health_info_form.dart';
// import 'package:flutter_application_pharmacy/services/bluetooth_service.dart';
// import 'package:intl/intl.dart';
// import 'package:provider/provider.dart';
// import 'package:path_provider/path_provider.dart';
// import 'package:pdf/widgets.dart' as pw;
// import 'package:share_plus/share_plus.dart';
// import 'dart:io';

// class ReportsPage extends StatefulWidget {
//   final String userName;
//   const ReportsPage({super.key, required this.userName});

//   @override
//   _ReportsPageState createState() => _ReportsPageState();
// }

// class _ReportsPageState extends State<ReportsPage>
//     with SingleTickerProviderStateMixin {
//   String _heartRate = "97";
//   String _weight = "103";
//   String _bloodGroup = "A+";
//   bool _isFetching = false;
//   bool _isLoading = false;
//   bool _showLoadingIndicator = false;
//   String? _docId;
//   String? _targetDocId;
//   late BluetoothManager _bluetoothManager;

//   late AnimationController _animationController;
//   late Animation<double> _fadeAnimation;

//   @override
//   void initState() {
//     super.initState();
//     print("ReportsPage - Initializing...");
//     _bluetoothManager = BluetoothManager();
//     _animationController = AnimationController(
//       vsync: this,
//       duration: const Duration(milliseconds: 500),
//     );
//     _fadeAnimation = CurvedAnimation(
//       parent: _animationController,
//       curve: Curves.easeInOut,
//     );
//     _animationController.forward();
//     _showLoadingIndicator = true;
//     _loadHealthData();
//     _autoConnectToBluetooth();
//     _checkAndDownloadWeeklyReport();
//   }

//   @override
//   void dispose() {
//     _animationController.dispose();
//     _bluetoothManager.dispose();
//     super.dispose();
//   }

//   Future<void> _loadHealthData({bool showIndicator = true}) async {
//     print("ReportsPage - Loading health data...");
//     setState(() {
//       _isLoading = true;
//       _showLoadingIndicator = showIndicator;
//     });
//     final user = FirebaseAuth.instance.currentUser;
//     final userModel = Provider.of<UserModel>(context, listen: false);
//     if (user == null) {
//       print("No user logged in.");
//       setState(() {
//         _isLoading = false;
//         _showLoadingIndicator = false;
//       });
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(content: Text('Please sign in to view reports')),
//       );
//       return;
//     }

//     try {
//       QuerySnapshot userQuery =
//           await FirebaseFirestore.instance
//               .collection('users')
//               .where('email', isEqualTo: user.email)
//               .limit(1)
//               .get();

//       if (userQuery.docs.isNotEmpty) {
//         _docId = userQuery.docs.first.id;
//         _targetDocId = _docId;

//         if (userModel.role == 'Caretaker') {
//           final userDoc =
//               await FirebaseFirestore.instance
//                   .collection('users')
//                   .doc(_docId)
//                   .get();
//           _targetDocId = userDoc.data()?['linkedDocId'] as String?;
//           if (_targetDocId == null || _targetDocId!.isEmpty) {
//             print("No linked patient found for caretaker.");
//             setState(() {
//               _isLoading = false;
//               _showLoadingIndicator = false;
//             });
//             ScaffoldMessenger.of(context).showSnackBar(
//               const SnackBar(content: Text('No linked patient found')),
//             );
//             return;
//           }

//           final doc =
//               await FirebaseFirestore.instance
//                   .collection('users')
//                   .doc(_targetDocId)
//                   .collection('health_info')
//                   .doc('data')
//                   .get();

//           if (doc.exists) {
//             final data = doc.data();
//             setState(() {
//               _weight = data?['weight'] ?? "103";
//               _bloodGroup = data?['bloodGroup'] ?? "A+";
//               _heartRate = data?['heartRate'] ?? "97";
//               print(
//                 "Caretaker - Initial data loaded: Weight: $_weight, Blood Group: $_bloodGroup, Heart Rate: $_heartRate, TargetDocId: $_targetDocId",
//               );
//             });
//           } else {
//             print("No health data found for patient.");
//           }

//           FirebaseFirestore.instance
//               .collection('users')
//               .doc(_targetDocId)
//               .collection('health_info')
//               .doc('data')
//               .snapshots()
//               .listen(
//                 (docSnapshot) {
//                   if (docSnapshot.exists) {
//                     final data = docSnapshot.data();
//                     setState(() {
//                       _heartRate = data?['heartRate'] ?? "97";
//                       _weight = data?['weight'] ?? "103";
//                       _bloodGroup = data?['bloodGroup'] ?? "A+";
//                       print(
//                         "Caretaker - Real-time update: Heart Rate: $_heartRate, Weight: $_weight, Blood Group: $_bloodGroup",
//                       );
//                     });
//                   } else {
//                     print("No health data found for patient.");
//                     setState(() {
//                       _heartRate = "97";
//                       _weight = "103";
//                       _bloodGroup = "A+";
//                     });
//                   }
//                 },
//                 onError: (e) {
//                   print("Error listening to health data: $e");
//                   ScaffoldMessenger.of(context).showSnackBar(
//                     SnackBar(content: Text('Error loading health data: $e')),
//                   );
//                 },
//               );
//         } else {
//           final doc =
//               await FirebaseFirestore.instance
//                   .collection('users')
//                   .doc(_docId)
//                   .collection('health_info')
//                   .doc('data')
//                   .get();

//           print("Firestore response - Exists: ${doc.exists}");
//           if (doc.exists) {
//             final data = doc.data();
//             setState(() {
//               _weight = data?['weight'] ?? "103";
//               _bloodGroup = data?['bloodGroup'] ?? "A+";
//               _heartRate = data?['heartRate'] ?? "97";
//               print(
//                 "Patient - Data loaded: Weight: $_weight, Blood Group: $_bloodGroup, Heart Rate: $_heartRate, DocId: $_docId",
//               );
//             });
//           } else {
//             print("No data found at path. Using defaults.");
//           }
//         }
//       }
//     } catch (e) {
//       print("Error loading health data: $e");
//       ScaffoldMessenger.of(
//         context,
//       ).showSnackBar(SnackBar(content: Text('Error loading data: $e')));
//     } finally {
//       setState(() {
//         _isLoading = false;
//         _showLoadingIndicator = false;
//       });
//     }
//   }

//   Future<void> _autoConnectToBluetooth() async {
//     final userModel = Provider.of<UserModel>(context, listen: false);
//     if (userModel.role == 'Caretaker') {
//       print("Caretaker cannot connect to Bluetooth");
//       return;
//     }
//     if (_docId == null) {
//       print("No docId available, cannot connect to Bluetooth");
//       await _loadHealthData(showIndicator: false); // Ensure docId is loaded
//       if (_docId == null) return;
//     }
//     print("Attempting auto-connect to NanoHRM for docId: $_docId");
//     setState(() => _isFetching = true);
//     await _bluetoothManager.connectToBluetooth(
//       context: context,
//       docId: _docId!,
//       onHeartRateUpdate: (heartRate) {
//         if (mounted) {
//           setState(() {
//             _heartRate = heartRate;
//             _isFetching = false;
//             print("Heart rate updated in UI: $_heartRate");
//           });
//         }
//       },
//       onMessage: (message) {
//         if (mounted) {
//           ScaffoldMessenger.of(
//             context,
//           ).showSnackBar(SnackBar(content: Text(message)));
//           print("Bluetooth message: $message");
//         }
//       },
//       onFetchingStateChange: (isFetching) {
//         if (mounted) {
//           setState(() {
//             _isFetching = isFetching;
//             print("Fetching state changed: $_isFetching");
//           });
//         }
//       },
//       isRefresh: false,
//     );
//   }

//   Future<void> _checkAndDownloadWeeklyReport() async {
//     final user = FirebaseAuth.instance.currentUser;
//     if (user == null || _docId == null) return;

//     final now = DateTime.now();
//     final isSundayMidnight =
//         now.weekday == DateTime.sunday && now.hour == 0 && now.minute < 5;

//     if (!isSundayMidnight) return;

//     try {
//       final userDoc =
//           await FirebaseFirestore.instance
//               .collection('users')
//               .doc(_docId)
//               .get();
//       final linkedDocId = userDoc.data()?['linkedDocId'] as String?;

//       final timeFrame = DateTime.now().subtract(const Duration(days: 7));
//       final timestamp = Timestamp.fromDate(timeFrame);
//       final querySnapshot =
//           await FirebaseFirestore.instance
//               .collection('users')
//               .doc(_docId)
//               .collection('reminders')
//               .where('timestamp', isGreaterThan: timestamp)
//               .get();

//       final reminders =
//           querySnapshot.docs.map((doc) {
//             final data = doc.data();
//             return {
//               'medicine': data['medicine'] ?? 'Unknown',
//               'dosage': data['dosage'] ?? 'N/A',
//               'times': (data['times'] as List? ?? [])
//                   .map((t) => t.toString())
//                   .join(', '),
//               'isDaily': data['isDaily'] ?? true,
//               'timestamp': (data['timestamp'] as Timestamp?)?.toDate(),
//               'taken': data['taken'] ?? false,
//             };
//           }).toList();

//       String reportContent =
//           "Weekly Health Report (${DateFormat('MMM d, yyyy').format(timeFrame)} - ${DateFormat('MMM d, yyyy').format(now)})\n\n";
//       for (var reminder in reminders) {
//         reportContent += "Medicine: ${reminder['medicine']}\n";
//         reportContent += "Dosage: ${reminder['dosage']}\n";
//         reportContent += "Times: ${reminder['times']}\n";
//         reportContent +=
//             "Frequency: ${reminder['isDaily'] ? 'Daily' : 'Weekly'}\n";
//         reportContent +=
//             "Status: ${reminder['taken'] ? 'Taken' : 'Not Taken'}\n";
//         reportContent +=
//             "Added: ${reminder['timestamp'] != null ? DateFormat('MMM d, h:mm a').format(reminder['timestamp'] as DateTime) : 'N/A'}\n\n";
//       }

//       final directory = await getApplicationDocumentsDirectory();
//       final patientFile = File(
//         '${directory.path}/weekly_report_${_docId}_${now.millisecondsSinceEpoch}.txt',
//       );
//       await patientFile.writeAsString(reportContent);
//       print("Report saved for patient at: ${patientFile.path}");

//       if (mounted) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(
//             content: Text('Weekly report downloaded to ${patientFile.path}'),
//           ),
//         );
//       }

//       if (linkedDocId != null && linkedDocId.isNotEmpty) {
//         final caretakerFile = File(
//           '${directory.path}/weekly_report_${linkedDocId}_${now.millisecondsSinceEpoch}.txt',
//         );
//         await caretakerFile.writeAsString(reportContent);
//         print("Report saved for caretaker at: ${caretakerFile.path}");
//       }
//     } catch (e) {
//       print("Error downloading weekly report: $e");
//       if (mounted) {
//         ScaffoldMessenger.of(
//           context,
//         ).showSnackBar(SnackBar(content: Text('Error downloading report: $e')));
//       }
//     }
//   }

//   Future<void> _generateAndShareWeeklyReport() async {
//     if (_targetDocId == null) {
//       if (mounted) {
//         ScaffoldMessenger.of(
//           context,
//         ).showSnackBar(const SnackBar(content: Text('User data not loaded')));
//       }
//       return;
//     }

//     try {
//       // Load bundled font
//       final fontData = await DefaultAssetBundle.of(
//         context,
//       ).load('assets/fonts/Roboto-Regular.ttf');
//       final font = pw.Font.ttf(fontData);

//       final now = DateTime.now();
//       final timeFrame = now.subtract(const Duration(days: 7));
//       final timestamp = Timestamp.fromDate(timeFrame);
//       final querySnapshot =
//           await FirebaseFirestore.instance
//               .collection('users')
//               .doc(_targetDocId)
//               .collection('reminders')
//               .where('timestamp', isGreaterThan: timestamp)
//               .get();

//       final reminders =
//           querySnapshot.docs.map((doc) {
//             final data = doc.data();
//             return {
//               'medicine': data['medicine'] ?? 'Unknown',
//               'dosage': data['dosage'] ?? 'N/A',
//               'times': (data['times'] as List? ?? [])
//                   .map((t) => t.toString())
//                   .join(', '),
//               'isDaily': data['isDaily'] ?? true,
//               'timestamp': (data['timestamp'] as Timestamp?)?.toDate(),
//               'taken': data['taken'] ?? false,
//             };
//           }).toList();

//       final complianceRate =
//           reminders.isNotEmpty
//               ? (reminders.where((r) => r['taken'] as bool).length /
//                       reminders.length *
//                       100)
//                   .toStringAsFixed(1)
//               : '0';
//       final takenCount = reminders.where((r) => r['taken'] as bool).length;
//       final totalCount = reminders.length;

//       final pdf = pw.Document();
//       pdf.addPage(
//         pw.Page(
//           build:
//               (pw.Context context) => pw.Column(
//                 crossAxisAlignment: pw.CrossAxisAlignment.start,
//                 children: [
//                   pw.Text(
//                     'Weekly Health Report',
//                     style: pw.TextStyle(
//                       fontSize: 24,
//                       fontWeight: pw.FontWeight.bold,
//                       font: font,
//                     ),
//                   ),
//                   pw.SizedBox(height: 10),
//                   pw.Text(
//                     '${DateFormat('MMM d, yyyy').format(timeFrame)} - ${DateFormat('MMM d, yyyy').format(now)}',
//                     style: pw.TextStyle(fontSize: 16, font: font),
//                   ),
//                   pw.SizedBox(height: 20),
//                   pw.Text(
//                     'Compliance Overview',
//                     style: pw.TextStyle(
//                       fontSize: 18,
//                       fontWeight: pw.FontWeight.bold,
//                       font: font,
//                     ),
//                   ),
//                   pw.SizedBox(height: 10),
//                   pw.Text(
//                     'Compliance Rate: $complianceRate%',
//                     style: pw.TextStyle(font: font),
//                   ),
//                   pw.Text(
//                     'Taken/Total: $takenCount/$totalCount',
//                     style: pw.TextStyle(font: font),
//                   ),
//                   pw.SizedBox(height: 20),
//                   pw.Text(
//                     'Reminders',
//                     style: pw.TextStyle(
//                       fontSize: 18,
//                       fontWeight: pw.FontWeight.bold,
//                       font: font,
//                     ),
//                   ),
//                   pw.SizedBox(height: 10),
//                   if (reminders.isEmpty)
//                     pw.Text(
//                       'No reminders found for this period.',
//                       style: pw.TextStyle(font: font),
//                     )
//                   else
//                     ...reminders.map(
//                       (reminder) => pw.Column(
//                         crossAxisAlignment: pw.CrossAxisAlignment.start,
//                         children: [
//                           pw.Text(
//                             'Medicine: ${reminder['medicine']}',
//                             style: pw.TextStyle(fontSize: 14, font: font),
//                           ),
//                           pw.Text(
//                             'Dosage: ${reminder['dosage']}',
//                             style: pw.TextStyle(font: font),
//                           ),
//                           pw.Text(
//                             'Times: ${reminder['times']}',
//                             style: pw.TextStyle(font: font),
//                           ),
//                           pw.Text(
//                             'Frequency: ${reminder['isDaily'] ? 'Daily' : 'Weekly'}',
//                             style: pw.TextStyle(font: font),
//                           ),
//                           pw.Text(
//                             'Status: ${reminder['taken'] ? 'Taken' : 'Not Taken'}',
//                             style: pw.TextStyle(font: font),
//                           ),
//                           pw.Text(
//                             'Added: ${reminder['timestamp'] != null ? DateFormat('MMM d, h:mm a').format(reminder['timestamp'] as DateTime) : 'N/A'}',
//                             style: pw.TextStyle(font: font),
//                           ),
//                           pw.SizedBox(height: 10),
//                         ],
//                       ),
//                     ),
//                 ],
//               ),
//         ),
//       );

//       final directory = await getApplicationDocumentsDirectory();
//       final file = File(
//         '${directory.path}/weekly_report_${_targetDocId}_${now.millisecondsSinceEpoch}.pdf',
//       );
//       await file.writeAsBytes(await pdf.save());
//       print("PDF report saved at: ${file.path}");

//       if (mounted) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(content: Text('Report downloaded to ${file.path}')),
//         );

//         await Share.shareXFiles(
//           [XFile(file.path)],
//           text: 'Weekly Health Report',
//           subject: 'Weekly Health Report',
//         );
//       }
//     } catch (e, stackTrace) {
//       print("Error generating PDF report: $e");
//       print("Stack trace: $stackTrace");
//       if (mounted) {
//         ScaffoldMessenger.of(
//           context,
//         ).showSnackBar(SnackBar(content: Text('Error generating report: $e')));
//       }
//     }
//   }

//   Future<bool> _onWillPop() async {
//     Navigator.pushReplacement(
//       context,
//       MaterialPageRoute(
//         builder: (context) => HomePage(userName: widget.userName),
//       ),
//     );
//     return false;
//   }

//   @override
//   Widget build(BuildContext context) {
//     print("ReportsPage - Building UI...");
//     final user = FirebaseAuth.instance.currentUser;
//     final userModel = Provider.of<UserModel>(context);
//     final isPatient = userModel.role == 'Patient';

//     if (user == null) {
//       return const Center(child: Text('Please log in to view reports.'));
//     }

//     return WillPopScope(
//       onWillPop: _onWillPop,
//       child: Scaffold(
//         backgroundColor: Colors.grey[100],
//         appBar: AppBar(
//           toolbarHeight: 56,
//           title: Text(
//             isPatient ? 'Health Reports' : 'Patient Reports',
//             style: const TextStyle(
//               fontSize: 22,
//               fontWeight: FontWeight.w600,
//               color: Colors.white,
//             ),
//           ),
//           centerTitle: true,
//           backgroundColor: Colors.blueAccent,
//           elevation: 0,
//           flexibleSpace: Container(
//             decoration: const BoxDecoration(
//               gradient: LinearGradient(
//                 colors: [Colors.blueAccent, Colors.lightBlueAccent],
//                 begin: Alignment.topLeft,
//                 end: Alignment.bottomRight,
//               ),
//             ),
//           ),
//         ),
//         body:
//             _isLoading && _showLoadingIndicator
//                 ? const Center(child: CircularProgressIndicator())
//                 : Padding(
//                   padding: const EdgeInsets.all(16.0),
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       const SizedBox(height: 24),
//                       Stack(
//                         children: [
//                           InfoCard(
//                             title:
//                                 isPatient ? "Heart Rate" : "Patient Heart Rate",
//                             value:
//                                 _isFetching && isPatient
//                                     ? "Fetching..."
//                                     : "$_heartRate bpm",
//                             unit: "",
//                             icon: Icons.monitor_heart,
//                             color: Colors.blue.shade100,
//                           ),
//                           if (isPatient)
//                             Positioned(
//                               right: 8,
//                               top: 8,
//                               child: IconButton(
//                                 icon: const Icon(
//                                   Icons.refresh,
//                                   color: Colors.blueAccent,
//                                 ),
//                                 onPressed: () async {
//                                   if (_docId == null) {
//                                     ScaffoldMessenger.of(context).showSnackBar(
//                                       const SnackBar(
//                                         content: Text(
//                                           'User data not loaded, please try again',
//                                         ),
//                                       ),
//                                     );
//                                     return;
//                                   }
//                                   print(
//                                     "Refresh button pressed, reconnecting...",
//                                   );
//                                   setState(() => _isFetching = true);
//                                   await _bluetoothManager.connectToBluetooth(
//                                     context: context,
//                                     docId: _docId!,
//                                     onHeartRateUpdate: (heartRate) {
//                                       if (mounted) {
//                                         setState(() {
//                                           _heartRate = heartRate;
//                                           _isFetching = false;
//                                           print(
//                                             "Heart rate updated via refresh: $_heartRate",
//                                           );
//                                         });
//                                       }
//                                     },
//                                     onMessage: (message) {
//                                       if (mounted) {
//                                         ScaffoldMessenger.of(
//                                           context,
//                                         ).showSnackBar(
//                                           SnackBar(content: Text(message)),
//                                         );
//                                         print("Bluetooth message: $message");
//                                       }
//                                     },
//                                     onFetchingStateChange: (isFetching) {
//                                       if (mounted) {
//                                         setState(() {
//                                           _isFetching = isFetching;
//                                           print(
//                                             "Fetching state changed: $_isFetching",
//                                           );
//                                         });
//                                       }
//                                     },
//                                     isRefresh: true,
//                                   );
//                                 },
//                               ),
//                             ),
//                         ],
//                       ),
//                       const SizedBox(height: 20),
//                       Row(
//                         children: [
//                           Expanded(
//                             child: GestureDetector(
//                               onLongPress: () {
//                                 if (_targetDocId != null) {
//                                   showDialog(
//                                     context: context,
//                                     builder:
//                                         (context) => WeightForm(
//                                           initialWeight: _weight,
//                                           docId: _targetDocId!,
//                                         ),
//                                   ).then(
//                                     (_) =>
//                                         _loadHealthData(showIndicator: false),
//                                   );
//                                 }
//                               },
//                               child: InfoCard(
//                                 title: "Weight",
//                                 value: _weight,
//                                 unit: "lbs",
//                                 icon: Icons.scale,
//                                 color: Colors.grey.shade300,
//                               ),
//                             ),
//                           ),
//                           const SizedBox(width: 20),
//                           Expanded(
//                             child: GestureDetector(
//                               onLongPress: () {
//                                 if (_targetDocId != null) {
//                                   showDialog(
//                                     context: context,
//                                     builder:
//                                         (context) => BloodGroupForm(
//                                           initialBloodGroup: _bloodGroup,
//                                           docId: _targetDocId!,
//                                         ),
//                                   ).then(
//                                     (_) =>
//                                         _loadHealthData(showIndicator: false),
//                                   );
//                                 }
//                               },
//                               child: InfoCard(
//                                 title: "Blood Group",
//                                 value: _bloodGroup,
//                                 unit: "",
//                                 icon: Icons.water_drop,
//                                 color: Colors.red.shade200,
//                               ),
//                             ),
//                           ),
//                         ],
//                       ),
//                       const SizedBox(height: 30),
//                       Row(
//                         mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                         children: [
//                           const Text(
//                             "Latest Reports",
//                             style: TextStyle(
//                               fontSize: 20,
//                               fontWeight: FontWeight.w700,
//                               color: Colors.blueGrey,
//                             ),
//                           ),
//                           IconButton(
//                             icon: const Icon(
//                               Icons.download,
//                               color: Colors.blueAccent,
//                               size: 24,
//                             ),
//                             onPressed: _generateAndShareWeeklyReport,
//                           ),
//                         ],
//                       ),
//                       const SizedBox(height: 12),
//                       Expanded(
//                         child: _LatestReportsSection(
//                           userName: widget.userName,
//                           docId: _targetDocId,
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//       ),
//     );
//   }
// }

// class InfoCard extends StatelessWidget {
//   final String title;
//   final String value;
//   final String unit;
//   final IconData icon;
//   final Color color;

//   const InfoCard({
//     super.key,
//     required this.title,
//     required this.value,
//     required this.unit,
//     required this.icon,
//     required this.color,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return Card(
//       elevation: 2,
//       color: color,
//       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
//       child: Padding(
//         padding: const EdgeInsets.all(16.0),
//         child: Row(
//           children: [
//             Icon(icon, size: 40, color: Colors.blueAccent),
//             const SizedBox(width: 16),
//             Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Text(
//                   title,
//                   style: const TextStyle(fontSize: 16, color: Colors.grey),
//                 ),
//                 const SizedBox(height: 4),
//                 Text(
//                   "$value $unit",
//                   style: const TextStyle(
//                     fontSize: 24,
//                     fontWeight: FontWeight.bold,
//                     color: Colors.black87,
//                   ),
//                 ),
//               ],
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }

// class _LatestReportsSection extends StatefulWidget {
//   final String userName;
//   final String? docId;

//   const _LatestReportsSection({required this.userName, required this.docId});

//   @override
//   __LatestReportsSectionState createState() => __LatestReportsSectionState();
// }

// class __LatestReportsSectionState extends State<_LatestReportsSection>
//     with SingleTickerProviderStateMixin {
//   String _filter = 'All';
//   bool _showDaily = true;
//   late AnimationController _animationController;
//   late Animation<double> _fadeAnimation;
//   List<Map<String, dynamic>> _reminders = [];
//   late ScrollController _scrollController;

//   @override
//   void initState() {
//     super.initState();
//     _animationController = AnimationController(
//       vsync: this,
//       duration: const Duration(milliseconds: 500),
//     );
//     _fadeAnimation = CurvedAnimation(
//       parent: _animationController,
//       curve: Curves.easeInOut,
//     );
//     _animationController.forward();
//     _scrollController = ScrollController();
//     _subscribeToReminders();
//   }

//   @override
//   void dispose() {
//     _animationController.dispose();
//     _scrollController.dispose();
//     super.dispose();
//   }

//   void _subscribeToReminders() {
//     if (widget.docId == null) return;

//     final timeFrame =
//         _showDaily
//             ? DateTime.now().subtract(const Duration(days: 1))
//             : DateTime.now().subtract(const Duration(days: 7));
//     final timestamp = Timestamp.fromDate(timeFrame);

//     FirebaseFirestore.instance
//         .collection('users')
//         .doc(widget.docId)
//         .collection('reminders')
//         .where('timestamp', isGreaterThan: timestamp)
//         .snapshots()
//         .listen(
//           (snapshot) {
//             final reminders =
//                 snapshot.docs.map((doc) {
//                   final data = doc.data();
//                   return {
//                     'id': doc.id,
//                     'medicine': data['medicine'] ?? 'Unknown',
//                     'dosage': data['dosage'] ?? 'N/A',
//                     'times': (data['times'] as List? ?? [])
//                         .map((t) => t.toString())
//                         .join(', '),
//                     'isDaily': data['isDaily'] ?? true,
//                     'timestamp': data['timestamp'] as Timestamp?,
//                     'taken': data['taken'] ?? false,
//                   };
//                 }).toList();

//             setState(() {
//               _reminders = reminders;
//               print("Reminders updated silently: ${_reminders.length}");
//             });
//           },
//           onError: (e) {
//             print("Error subscribing to reminders: $e");
//             ScaffoldMessenger.of(context).showSnackBar(
//               SnackBar(content: Text('Error fetching reminders: $e')),
//             );
//           },
//         );
//   }

//   Widget _buildFilterButton(String label) {
//     return GestureDetector(
//       onTap: () => setState(() => _filter = label),
//       child: AnimatedContainer(
//         duration: const Duration(milliseconds: 300),
//         width: 90,
//         padding: const EdgeInsets.symmetric(vertical: 10),
//         decoration: BoxDecoration(
//           color: _filter == label ? Colors.blueAccent : Colors.grey.shade100,
//           borderRadius: BorderRadius.circular(10),
//           boxShadow:
//               _filter == label
//                   ? [
//                     BoxShadow(
//                       color: Colors.blueAccent.withOpacity(0.3),
//                       blurRadius: 4,
//                     ),
//                   ]
//                   : [],
//         ),
//         child: Center(
//           child: Text(
//             label,
//             style: TextStyle(
//               fontSize: 14,
//               color: _filter == label ? Colors.white : Colors.black87,
//               fontWeight: FontWeight.w600,
//             ),
//           ),
//         ),
//       ),
//     );
//   }

//   Widget _buildToggleSwitch() {
//     return Container(
//       decoration: BoxDecoration(
//         borderRadius: BorderRadius.circular(10),
//         color: Colors.grey.shade100,
//       ),
//       child: Row(
//         mainAxisSize: MainAxisSize.min,
//         children: [
//           GestureDetector(
//             onTap: () {
//               if (!_showDaily) {
//                 setState(() {
//                   _showDaily = true;
//                 });
//                 _subscribeToReminders();
//               }
//             },
//             child: Container(
//               width: 90,
//               padding: const EdgeInsets.symmetric(vertical: 10),
//               decoration: BoxDecoration(
//                 color: _showDaily ? Colors.blueAccent : Colors.grey.shade100,
//                 borderRadius: const BorderRadius.horizontal(
//                   left: Radius.circular(10),
//                 ),
//               ),
//               child: Center(
//                 child: Text(
//                   'Daily',
//                   style: TextStyle(
//                     fontSize: 14,
//                     color: _showDaily ? Colors.white : Colors.black87,
//                     fontWeight: FontWeight.w600,
//                   ),
//                 ),
//               ),
//             ),
//           ),
//           GestureDetector(
//             onTap: () {
//               if (_showDaily) {
//                 setState(() {
//                   _showDaily = false;
//                 });
//                 _subscribeToReminders();
//               }
//             },
//             child: Container(
//               width: 90,
//               padding: const EdgeInsets.symmetric(vertical: 10),
//               decoration: BoxDecoration(
//                 color: !_showDaily ? Colors.blueAccent : Colors.grey.shade100,
//                 borderRadius: const BorderRadius.horizontal(
//                   right: Radius.circular(10),
//                 ),
//               ),
//               child: Center(
//                 child: Text(
//                   'Weekly',
//                   style: TextStyle(
//                     fontSize: 14,
//                     color: !_showDaily ? Colors.white : Colors.black87,
//                     fontWeight: FontWeight.w600,
//                   ),
//                 ),
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   void _showReminderDetails(
//     BuildContext context,
//     Map<String, dynamic> reminder,
//   ) {
//     final isTaken = reminder['taken'] as bool;
//     final timestamp = (reminder['timestamp'] as Timestamp?)?.toDate();
//     final dateString =
//         timestamp != null
//             ? DateFormat('MMM d, h:mm a').format(timestamp)
//             : 'N/A';

//     showModalBottomSheet(
//       context: context,
//       shape: const RoundedRectangleBorder(
//         borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
//       ),
//       builder: (context) {
//         return Padding(
//           padding: const EdgeInsets.all(12),
//           child: Column(
//             mainAxisSize: MainAxisSize.min,
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               Row(
//                 children: [
//                   CircleAvatar(
//                     radius: 26,
//                     backgroundColor:
//                         isTaken
//                             ? Colors.green.withOpacity(0.1)
//                             : Colors.red.withOpacity(0.1),
//                     child: Icon(
//                       isTaken ? Icons.check_circle : Icons.warning,
//                       color: isTaken ? Colors.green : Colors.red,
//                       size: 32,
//                     ),
//                   ),
//                   const SizedBox(width: 12),
//                   Expanded(
//                     child: Text(
//                       reminder['medicine'],
//                       style: const TextStyle(
//                         fontSize: 22,
//                         fontWeight: FontWeight.bold,
//                         color: Colors.black87,
//                       ),
//                     ),
//                   ),
//                 ],
//               ),
//               const SizedBox(height: 12),
//               Text(
//                 'Dosage: ${reminder['dosage']}',
//                 style: const TextStyle(fontSize: 14, color: Colors.grey),
//               ),
//               const SizedBox(height: 6),
//               Text(
//                 'Times: ${reminder['times']}',
//                 style: const TextStyle(fontSize: 14, color: Colors.grey),
//               ),
//               const SizedBox(height: 6),
//               Text(
//                 'Frequency: ${reminder['isDaily'] ? 'Daily' : 'Weekly'}',
//                 style: const TextStyle(fontSize: 14, color: Colors.grey),
//               ),
//               const SizedBox(height: 6),
//               Text(
//                 'Added: $dateString',
//                 style: const TextStyle(fontSize: 14, color: Colors.grey),
//               ),
//               const SizedBox(height: 6),
//               Text(
//                 'Status: ${isTaken ? 'Taken' : 'Not Taken'}',
//                 style: TextStyle(
//                   fontSize: 14,
//                   color: isTaken ? Colors.green : Colors.red,
//                   fontWeight: FontWeight.w600,
//                 ),
//               ),
//               const SizedBox(height: 20),
//               SizedBox(
//                 width: double.infinity,
//                 child: ElevatedButton(
//                   onPressed: () => Navigator.pop(context),
//                   style: ElevatedButton.styleFrom(
//                     backgroundColor: Colors.blueAccent,
//                     padding: const EdgeInsets.symmetric(vertical: 14),
//                     shape: RoundedRectangleBorder(
//                       borderRadius: BorderRadius.circular(10),
//                     ),
//                     elevation: 2,
//                   ),
//                   child: const Text(
//                     'Close',
//                     style: TextStyle(fontSize: 14, color: Colors.white),
//                   ),
//                 ),
//               ),
//             ],
//           ),
//         );
//       },
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     final filteredReminders =
//         _filter == 'All'
//             ? _reminders
//             : _filter == 'Taken'
//             ? _reminders.where((r) => r['taken'] as bool).toList()
//             : _reminders.where((r) => !(r['taken'] as bool)).toList();

//     final sortedReminders =
//         filteredReminders..sort(
//           (a, b) => (b['timestamp'] as Timestamp).compareTo(
//             a['timestamp'] as Timestamp,
//           ),
//         );

//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Center(child: _buildToggleSwitch()),
//         const SizedBox(height: 12),
//         Center(
//           child: Row(
//             mainAxisSize: MainAxisSize.min,
//             children: [
//               _buildFilterButton('All'),
//               const SizedBox(width: 10),
//               _buildFilterButton('Taken'),
//               const SizedBox(width: 10),
//               _buildFilterButton('Not Taken'),
//             ],
//           ),
//         ),
//         const SizedBox(height: 20),
//         FadeTransition(
//           opacity: _fadeAnimation,
//           child: Card(
//             elevation: 2,
//             shape: RoundedRectangleBorder(
//               borderRadius: BorderRadius.circular(10),
//             ),
//             color: Colors.grey.shade50,
//             child: Padding(
//               padding: const EdgeInsets.all(12),
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   const Text(
//                     'Compliance Overview',
//                     style: TextStyle(
//                       fontSize: 18,
//                       fontWeight: FontWeight.bold,
//                       color: Colors.black87,
//                     ),
//                   ),
//                   const SizedBox(height: 8),
//                   if (_reminders.isEmpty)
//                     const SizedBox.shrink()
//                   else
//                     Row(
//                       mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                       children: [
//                         Column(
//                           crossAxisAlignment: CrossAxisAlignment.start,
//                           children: [
//                             Text(
//                               '${_reminders.isNotEmpty ? (_reminders.where((r) => r['taken'] as bool).length / _reminders.length * 100).toStringAsFixed(1) : '0'}%',
//                               style: const TextStyle(
//                                 fontSize: 28,
//                                 fontWeight: FontWeight.bold,
//                                 color: Colors.blueAccent,
//                               ),
//                             ),
//                             const Text(
//                               'Compliance Rate',
//                               style: TextStyle(
//                                 fontSize: 12,
//                                 color: Colors.grey,
//                               ),
//                             ),
//                           ],
//                         ),
//                         Column(
//                           crossAxisAlignment: CrossAxisAlignment.start,
//                           children: [
//                             Text(
//                               '${_reminders.where((r) => r['taken'] as bool).length}/${_reminders.length}',
//                               style: const TextStyle(
//                                 fontSize: 22,
//                                 fontWeight: FontWeight.bold,
//                                 color: Colors.green,
//                               ),
//                             ),
//                             const Text(
//                               'Taken/Total',
//                               style: TextStyle(
//                                 fontSize: 12,
//                                 color: Colors.grey,
//                               ),
//                             ),
//                           ],
//                         ),
//                       ],
//                     ),
//                 ],
//               ),
//             ),
//           ),
//         ),
//         const SizedBox(height: 20),
//         Expanded(
//           child:
//               sortedReminders.isEmpty
//                   ? Center(
//                     child: Column(
//                       mainAxisAlignment: MainAxisAlignment.center,
//                       children: [
//                         Icon(
//                           Icons.info_outline,
//                           size: 60,
//                           color: Colors.grey[400],
//                         ),
//                         const SizedBox(height: 12),
//                         Text(
//                           _showDaily
//                               ? 'No reminders added today.'
//                               : 'No reminders added in the past week.',
//                           style: const TextStyle(
//                             fontSize: 14,
//                             color: Colors.grey,
//                           ),
//                         ),
//                       ],
//                     ),
//                   )
//                   : SingleChildScrollView(
//                     controller: _scrollController,
//                     child: Column(
//                       children:
//                           sortedReminders.map((reminder) {
//                             final isTaken = reminder['taken'] as bool;
//                             final timestamp =
//                                 (reminder['timestamp'] as Timestamp?)?.toDate();
//                             final dateString =
//                                 timestamp != null
//                                     ? DateFormat(
//                                       'MMM d, h:mm a',
//                                     ).format(timestamp)
//                                     : 'N/A';

//                             return FadeTransition(
//                               opacity: _fadeAnimation,
//                               child: GestureDetector(
//                                 onTap:
//                                     () =>
//                                         _showReminderDetails(context, reminder),
//                                 child: Card(
//                                   elevation: 2,
//                                   margin: const EdgeInsets.symmetric(
//                                     vertical: 6,
//                                   ),
//                                   shape: RoundedRectangleBorder(
//                                     borderRadius: BorderRadius.circular(10),
//                                   ),
//                                   color: Colors.grey.shade50,
//                                   child: Padding(
//                                     padding: const EdgeInsets.all(12),
//                                     child: Row(
//                                       children: [
//                                         CircleAvatar(
//                                           radius: 20,
//                                           backgroundColor:
//                                               isTaken
//                                                   ? Colors.green.withOpacity(
//                                                     0.1,
//                                                   )
//                                                   : Colors.red.withOpacity(0.1),
//                                           child: Icon(
//                                             isTaken
//                                                 ? Icons.check_circle
//                                                 : Icons.warning,
//                                             color:
//                                                 isTaken
//                                                     ? Colors.green
//                                                     : Colors.red,
//                                             size: 24,
//                                           ),
//                                         ),
//                                         const SizedBox(width: 12),
//                                         Expanded(
//                                           child: Column(
//                                             crossAxisAlignment:
//                                                 CrossAxisAlignment.start,
//                                             children: [
//                                               Text(
//                                                 reminder['medicine'],
//                                                 style: const TextStyle(
//                                                   fontSize: 18,
//                                                   fontWeight: FontWeight.bold,
//                                                   color: Colors.black87,
//                                                 ),
//                                               ),
//                                               const SizedBox(height: 2),
//                                               Text(
//                                                 '${reminder['dosage']} • ${reminder['times']}',
//                                                 style: const TextStyle(
//                                                   fontSize: 14,
//                                                   color: Colors.grey,
//                                                 ),
//                                               ),
//                                               const SizedBox(height: 2),
//                                               Text(
//                                                 'Added: $dateString',
//                                                 style: const TextStyle(
//                                                   fontSize: 12,
//                                                   color: Colors.grey,
//                                                 ),
//                                               ),
//                                               const SizedBox(height: 6),
//                                               Container(
//                                                 padding:
//                                                     const EdgeInsets.symmetric(
//                                                       horizontal: 10,
//                                                       vertical: 4,
//                                                     ),
//                                                 decoration: BoxDecoration(
//                                                   color:
//                                                       isTaken
//                                                           ? Colors.green
//                                                               .withOpacity(0.1)
//                                                           : Colors.red
//                                                               .withOpacity(0.1),
//                                                   borderRadius:
//                                                       BorderRadius.circular(6),
//                                                 ),
//                                                 child: Text(
//                                                   isTaken
//                                                       ? 'Taken'
//                                                       : 'Not Taken',
//                                                   style: TextStyle(
//                                                     fontSize: 12,
//                                                     color:
//                                                         isTaken
//                                                             ? Colors.green
//                                                             : Colors.red,
//                                                     fontWeight: FontWeight.w600,
//                                                   ),
//                                                 ),
//                                               ),
//                                             ],
//                                           ),
//                                         ),
//                                       ],
//                                     ),
//                                   ),
//                                 ),
//                               ),
//                             );
//                           }).toList(),
//                     ),
//                   ),
//         ),
//       ],
//     );
//   }
// }

// class RemindersScreen extends StatelessWidget {
//   const RemindersScreen({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: const Text('Reminders')),
//       body: const Center(child: Text('Reminders Page')),
//     );
//   }
// }
//yeh wala hai

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_pharmacy/home_page.dart';
import 'package:flutter_application_pharmacy/models/user_model.dart';
import 'package:flutter_application_pharmacy/screens/health_info_form.dart';
import 'package:flutter_application_pharmacy/services/bluetooth_service.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:share_plus/share_plus.dart';
import 'dart:io';
import 'package:audioplayers/audioplayers.dart';

class ReportsPage extends StatefulWidget {
  final String userName;
  const ReportsPage({super.key, required this.userName});

  @override
  _ReportsPageState createState() => _ReportsPageState();
}

class _ReportsPageState extends State<ReportsPage>
    with SingleTickerProviderStateMixin {
  String _heartRate = "97";
  String _weight = "103";
  String _bloodGroup = "A+";
  bool _isFetching = false;
  bool _isLoading = false;
  bool _showLoadingIndicator = false;
  String? _docId;
  String? _targetDocId;
  late BluetoothManager _bluetoothManager;
  late AudioPlayer _audioPlayer;

  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    print("ReportsPage - Initializing...");
    _bluetoothManager = BluetoothManager();
    _audioPlayer = AudioPlayer();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _fadeAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );
    _animationController.forward();
    _showLoadingIndicator = true;
    _loadHealthData();
    _autoConnectToBluetooth();
    _checkAndDownloadWeeklyReport();
    _listenForAlerts();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _bluetoothManager.dispose();
    _audioPlayer.dispose();
    super.dispose();
  }

  Future<void> _playAlertSound() async {
    try {
      await _audioPlayer.play(AssetSource('alert.mp3'));
      print("Alert sound played");
    } catch (e) {
      print("Error playing alert sound: $e");
    }
  }

  void _checkHeartRateAndAlert(String heartRate) {
    try {
      final hr = int.parse(heartRate);
      if (hr < 60 || hr > 100) {
        _playAlertSound();
        if (_docId != null) {
          FirebaseFirestore.instance
              .collection('users')
              .doc(_docId)
              .collection('health_info')
              .doc('alerts')
              .set({
                'heartRate': heartRate,
                'timestamp': Timestamp.now(),
                'alert': true,
              }, SetOptions(merge: true));
          print("Alert triggered for heart rate: $heartRate");
        }
      }
    } catch (e) {
      print("Error parsing heart rate: $e");
    }
  }

  void _listenForAlerts() {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null || _docId == null) return;

    FirebaseFirestore.instance
        .collection('users')
        .doc(_targetDocId ?? _docId)
        .collection('health_info')
        .doc('alerts')
        .snapshots()
        .listen(
          (snapshot) {
            if (snapshot.exists && snapshot.data()?['alert'] == true) {
              final heartRate = snapshot.data()?['heartRate']?.toString();
              if (heartRate != null) {
                try {
                  final hr = int.parse(heartRate);
                  if (hr < 60 || hr > 100) {
                    _playAlertSound();
                    print(
                      "Caretaker received alert for heart rate: $heartRate",
                    );
                  }
                } catch (e) {
                  print("Error processing alert heart rate: $e");
                }
              }
            }
          },
          onError: (e) {
            print("Error listening for alerts: $e");
          },
        );
  }

  Future<void> _loadHealthData({bool showIndicator = true}) async {
    print("ReportsPage - Loading health data...");
    setState(() {
      _isLoading = true;
      _showLoadingIndicator = showIndicator;
    });
    final user = FirebaseAuth.instance.currentUser;
    final userModel = Provider.of<UserModel>(context, listen: false);
    if (user == null) {
      print("No user logged in.");
      setState(() {
        _isLoading = false;
        _showLoadingIndicator = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please sign in to view reports')),
      );
      return;
    }

    try {
      QuerySnapshot userQuery =
          await FirebaseFirestore.instance
              .collection('users')
              .where('email', isEqualTo: user.email)
              .limit(1)
              .get();

      if (userQuery.docs.isNotEmpty) {
        _docId = userQuery.docs.first.id;
        _targetDocId = _docId;

        if (userModel.role == 'Caretaker') {
          final userDoc =
              await FirebaseFirestore.instance
                  .collection('users')
                  .doc(_docId)
                  .get();
          _targetDocId = userDoc.data()?['linkedDocId'] as String?;
          if (_targetDocId == null || _targetDocId!.isEmpty) {
            print("No linked patient found for caretaker.");
            setState(() {
              _isLoading = false;
              _showLoadingIndicator = false;
            });
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('No linked patient found')),
            );
            return;
          }

          final doc =
              await FirebaseFirestore.instance
                  .collection('users')
                  .doc(_targetDocId)
                  .collection('health_info')
                  .doc('data')
                  .get();

          if (doc.exists) {
            final data = doc.data();
            setState(() {
              _weight = data?['weight'] ?? "103";
              _bloodGroup = data?['bloodGroup'] ?? "A+";
              _heartRate = data?['heartRate'] ?? "97";
              print(
                "Caretaker - Initial data loaded: Weight: $_weight, Blood Group: $_bloodGroup, Heart Rate: $_heartRate, TargetDocId: $_targetDocId",
              );
            });
          } else {
            print("No health data found for patient.");
          }

          FirebaseFirestore.instance
              .collection('users')
              .doc(_targetDocId)
              .collection('health_info')
              .doc('data')
              .snapshots()
              .listen(
                (docSnapshot) {
                  if (docSnapshot.exists) {
                    final data = docSnapshot.data();
                    setState(() {
                      _heartRate = data?['heartRate'] ?? "97";
                      _weight = data?['weight'] ?? "103";
                      _bloodGroup = data?['bloodGroup'] ?? "A+";
                      print(
                        "Caretaker - Real-time update: Heart Rate: $_heartRate, Weight: $_weight, Blood Group: $_bloodGroup",
                      );
                    });
                  } else {
                    print("No health data found for patient.");
                    setState(() {
                      _heartRate = "97";
                      _weight = "103";
                      _bloodGroup = "A+";
                    });
                  }
                },
                onError: (e) {
                  print("Error listening to health data: $e");
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Error loading health data: $e')),
                  );
                },
              );
        } else {
          final doc =
              await FirebaseFirestore.instance
                  .collection('users')
                  .doc(_docId)
                  .collection('health_info')
                  .doc('data')
                  .get();

          print("Firestore response - Exists: ${doc.exists}");
          if (doc.exists) {
            final data = doc.data();
            setState(() {
              _weight = data?['weight'] ?? "103";
              _bloodGroup = data?['bloodGroup'] ?? "A+";
              _heartRate = data?['heartRate'] ?? "97";
              print(
                "Patient - Data loaded: Weight: $_weight, Blood Group: $_bloodGroup, Heart Rate: $_heartRate, DocId: $_docId",
              );
            });
          } else {
            print("No data found at path. Using defaults.");
          }
        }
      }
    } catch (e) {
      print("Error loading health data: $e");
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error loading data: $e')));
    } finally {
      setState(() {
        _isLoading = false;
        _showLoadingIndicator = false;
      });
    }
  }

  Future<void> _autoConnectToBluetooth() async {
    final UserModel userModel = Provider.of<UserModel>(context, listen: false);
    if (userModel.role == 'Caretaker') {
      print("Caretaker cannot connect to Bluetooth");
      return;
    }
    if (_docId == null) {
      print("No docId available, cannot connect to Bluetooth");
      await _loadHealthData(showIndicator: false);
      if (_docId == null) return;
    }
    print("Attempting auto-connect to NanoHRM for docId: $_docId");
    setState(() => _isFetching = true);
    await _bluetoothManager.connectToBluetooth(
      context: context,
      docId: _docId!,
      onHeartRateUpdate: (heartRate) {
        if (mounted) {
          setState(() {
            _heartRate = heartRate;
            _isFetching = false;
            print("Heart rate updated in UI: $_heartRate");
          });
          _checkHeartRateAndAlert(heartRate);
        }
      },
      onMessage: (message) {
        if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(message)));
          print("Bluetooth message: $message");
        }
      },
      onFetchingStateChange: (isFetching) {
        if (mounted) {
          setState(() {
            _isFetching = isFetching;
            print("Fetching state changed: $_isFetching");
          });
        }
      },
      isRefresh: false,
    );
  }

  Future<void> _checkAndDownloadWeeklyReport() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null || _docId == null) return;

    final now = DateTime.now();
    final isSundayMidnight =
        now.weekday == DateTime.sunday && now.hour == 0 && now.minute < 5;

    if (!isSundayMidnight) return;

    try {
      final userDoc =
          await FirebaseFirestore.instance
              .collection('users')
              .doc(_docId)
              .get();
      final linkedDocId = userDoc.data()?['linkedDocId'] as String?;

      final timeFrame = DateTime.now().subtract(const Duration(days: 7));
      final timestamp = Timestamp.fromDate(timeFrame);
      final querySnapshot =
          await FirebaseFirestore.instance
              .collection('users')
              .doc(_docId)
              .collection('reminders')
              .where('timestamp', isGreaterThan: timestamp)
              .get();

      final reminders =
          querySnapshot.docs.map((doc) {
            final data = doc.data();
            return {
              'medicine': data['medicine'] ?? 'Unknown',
              'dosage': data['dosage'] ?? 'N/A',
              'times': (data['times'] as List? ?? [])
                  .map((t) => t.toString())
                  .join(', '),
              'isDaily': data['isDaily'] ?? true,
              'timestamp': (data['timestamp'] as Timestamp?)?.toDate(),
              'taken': data['taken'] ?? false,
            };
          }).toList();

      String reportContent =
          "Weekly Health Report (${DateFormat('MMM d, yyyy').format(timeFrame)} - ${DateFormat('MMM d, yyyy').format(now)})\n\n";
      for (var reminder in reminders) {
        reportContent += "Medicine: ${reminder['medicine']}\n";
        reportContent += "Dosage: ${reminder['dosage']}\n";
        reportContent += "Times: ${reminder['times']}\n";
        reportContent +=
            "Frequency: ${reminder['isDaily'] ? 'Daily' : 'Weekly'}\n";
        reportContent +=
            "Status: ${reminder['taken'] ? 'Taken' : 'Not Taken'}\n";
        reportContent +=
            "Added: ${reminder['timestamp'] != null ? DateFormat('MMM d, h:mm a').format(reminder['timestamp'] as DateTime) : 'N/A'}\n\n";
      }

      final directory = await getApplicationDocumentsDirectory();
      final patientFile = File(
        '${directory.path}/weekly_report_${_docId}_${now.millisecondsSinceEpoch}.txt',
      );
      await patientFile.writeAsString(reportContent);
      print("Report saved for patient at: ${patientFile.path}");

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Weekly report downloaded to ${patientFile.path}'),
          ),
        );
      }

      if (linkedDocId != null && linkedDocId.isNotEmpty) {
        final caretakerFile = File(
          '${directory.path}/weekly_report_${linkedDocId}_${now.millisecondsSinceEpoch}.txt',
        );
        await caretakerFile.writeAsString(reportContent);
        print("Report saved for caretaker at: ${caretakerFile.path}");
      }
    } catch (e) {
      print("Error downloading weekly report: $e");
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error downloading report: $e')));
      }
    }
  }

  Future<void> _generateAndShareWeeklyReport() async {
    if (_targetDocId == null) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('User data not loaded')));
      }
      return;
    }

    try {
      final fontData = await DefaultAssetBundle.of(
        context,
      ).load('assets/fonts/Roboto-Regular.ttf');
      final font = pw.Font.ttf(fontData);

      final now = DateTime.now();
      final timeFrame = now.subtract(const Duration(days: 7));
      final timestamp = Timestamp.fromDate(timeFrame);
      final querySnapshot =
          await FirebaseFirestore.instance
              .collection('users')
              .doc(_targetDocId)
              .collection('reminders')
              .where('timestamp', isGreaterThan: timestamp)
              .get();

      final reminders =
          querySnapshot.docs.map((doc) {
            final Map<String, dynamic> data = doc.data(); // Fixed: Correct type
            return {
              'medicine': data['medicine'] ?? 'Unknown',
              'dosage': data['dosage'] ?? 'N/A',
              'times': (data['times'] as List? ?? [])
                  .map((t) => t.toString())
                  .join(', '),
              'isDaily': data['isDaily'] ?? true,
              'timestamp': (data['timestamp'] as Timestamp?)?.toDate(),
              'taken': data['taken'] ?? false,
            };
          }).toList();

      final complianceRate =
          reminders.isNotEmpty
              ? (reminders.where((r) => r['taken'] as bool).length /
                      reminders.length *
                      100)
                  .toStringAsFixed(1)
              : '0';
      final takenCount = reminders.where((r) => r['taken'] as bool).length;
      final totalCount = reminders.length;

      final pdf = pw.Document();
      pdf.addPage(
        pw.Page(
          build:
              (pw.Context context) => pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text(
                    'Weekly Health Report',
                    style: pw.TextStyle(
                      fontSize: 24,
                      fontWeight: pw.FontWeight.bold,
                      font: font,
                    ),
                  ),
                  pw.SizedBox(height: 10),
                  pw.Text(
                    '${DateFormat('MMM d, yyyy').format(timeFrame)} - ${DateFormat('MMM d, yyyy').format(now)}',
                    style: pw.TextStyle(fontSize: 16, font: font),
                  ),
                  pw.SizedBox(height: 20),
                  pw.Text(
                    'Compliance Overview',
                    style: pw.TextStyle(
                      fontSize: 18,
                      fontWeight: pw.FontWeight.bold,
                      font: font,
                    ),
                  ),
                  pw.SizedBox(height: 10),
                  pw.Text(
                    'Compliance Rate: $complianceRate%',
                    style: pw.TextStyle(font: font),
                  ),
                  pw.Text(
                    'Taken/Total: $takenCount/$totalCount',
                    style: pw.TextStyle(font: font),
                  ),
                  pw.SizedBox(height: 20),
                  pw.Text(
                    'Reminders',
                    style: pw.TextStyle(
                      fontSize: 18,
                      fontWeight: pw.FontWeight.bold,
                      font: font,
                    ),
                  ),
                  pw.SizedBox(height: 10),
                  if (reminders.isEmpty)
                    pw.Text(
                      'No reminders found for this period.',
                      style: pw.TextStyle(font: font),
                    )
                  else
                    ...reminders.map(
                      (reminder) => pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.start,
                        children: [
                          pw.Text(
                            'Medicine: ${reminder['medicine']}',
                            style: pw.TextStyle(fontSize: 14, font: font),
                          ),
                          pw.Text(
                            'Dosage: ${reminder['dosage']}',
                            style: pw.TextStyle(font: font),
                          ),
                          pw.Text(
                            'Times: ${reminder['times']}',
                            style: pw.TextStyle(font: font),
                          ),
                          pw.Text(
                            'Frequency: ${reminder['isDaily'] ? 'Daily' : 'Weekly'}',
                            style: pw.TextStyle(font: font),
                          ),
                          pw.Text(
                            'Status: ${reminder['taken'] ? 'Taken' : 'Not Taken'}',
                            style: pw.TextStyle(font: font),
                          ),
                          pw.Text(
                            'Added: ${reminder['timestamp'] != null ? DateFormat('MMM d, h:mm a').format(reminder['timestamp'] as DateTime) : 'N/A'}',
                            style: pw.TextStyle(font: font),
                          ),
                          pw.SizedBox(height: 10),
                        ],
                      ),
                    ),
                ],
              ),
        ),
      );

      final directory = await getApplicationDocumentsDirectory();
      final file = File(
        '${directory.path}/weekly_report_${_targetDocId}_${now.millisecondsSinceEpoch}.pdf',
      );
      await file.writeAsBytes(await pdf.save());
      print("PDF report saved at: ${file.path}");

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Report downloaded to ${file.path}')),
        );

        await Share.shareXFiles(
          [XFile(file.path)],
          text: 'Weekly Health Report',
          subject: 'Weekly Health Report',
        );
      }
    } catch (e, stackTrace) {
      print("Error generating PDF report: $e");
      print("Stack trace: $stackTrace");
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error generating report: $e')));
      }
    }
  }

  Future<bool> _onWillPop() async {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => HomePage(userName: widget.userName),
      ),
    );
    return false;
  }

  @override
  Widget build(BuildContext context) {
    print("ReportsPage - Building UI...");
    final user = FirebaseAuth.instance.currentUser;
    final userModel = Provider.of<UserModel>(context);
    final isPatient = userModel.role == 'Patient';

    if (user == null) {
      return const Center(child: Text('Please log in to view reports.'));
    }

    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        backgroundColor: Colors.grey[100],
        appBar: AppBar(
          toolbarHeight: 56,
          title: Text(
            isPatient ? 'Health Reports' : 'Patient Reports',
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
          centerTitle: true,
          backgroundColor: Colors.blueAccent,
          elevation: 0,
          flexibleSpace: Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.blueAccent, Colors.lightBlueAccent],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),
        ),
        body:
            _isLoading && _showLoadingIndicator
                ? const Center(child: CircularProgressIndicator())
                : Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 24),
                      Stack(
                        children: [
                          InfoCard(
                            title:
                                isPatient ? "Heart Rate" : "Patient Heart Rate",
                            value:
                                _isFetching && isPatient
                                    ? "Fetching..."
                                    : "$_heartRate bpm",
                            unit: "",
                            icon: Icons.monitor_heart,
                            color: Colors.blue.shade100,
                          ),
                          if (isPatient)
                            Positioned(
                              right: 8,
                              top: 8,
                              child: IconButton(
                                icon: const Icon(
                                  Icons.refresh,
                                  color: Colors.blueAccent,
                                ),
                                onPressed: () async {
                                  if (_docId == null) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text(
                                          'User data not loaded, please try again',
                                        ),
                                      ),
                                    );
                                    return;
                                  }
                                  print(
                                    "Refresh button pressed, reconnecting...",
                                  );
                                  setState(() => _isFetching = true);
                                  await _bluetoothManager.connectToBluetooth(
                                    context: context,
                                    docId: _docId!,
                                    onHeartRateUpdate: (heartRate) {
                                      if (mounted) {
                                        setState(() {
                                          _heartRate = heartRate;
                                          _isFetching = false;
                                          print(
                                            "Heart rate updated via refresh: $_heartRate",
                                          );
                                        });
                                        _checkHeartRateAndAlert(heartRate);
                                      }
                                    },
                                    onMessage: (message) {
                                      if (mounted) {
                                        ScaffoldMessenger.of(
                                          context,
                                        ).showSnackBar(
                                          SnackBar(content: Text(message)),
                                        );
                                        print("Bluetooth message: $message");
                                      }
                                    },
                                    onFetchingStateChange: (isFetching) {
                                      if (mounted) {
                                        setState(() {
                                          _isFetching = isFetching;
                                          print(
                                            "Fetching state changed: $_isFetching",
                                          );
                                        });
                                      }
                                    },
                                    isRefresh: true,
                                  );
                                },
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      Row(
                        children: [
                          Expanded(
                            child: GestureDetector(
                              onLongPress: () {
                                if (_targetDocId != null) {
                                  showDialog(
                                    context: context,
                                    builder:
                                        (context) => WeightForm(
                                          initialWeight: _weight,
                                          docId: _targetDocId!,
                                        ),
                                  ).then(
                                    (_) =>
                                        _loadHealthData(showIndicator: false),
                                  );
                                }
                              },
                              child: InfoCard(
                                title: "Weight",
                                value: _weight,
                                unit: "lbs",
                                icon: Icons.scale,
                                color: Colors.grey.shade300,
                              ),
                            ),
                          ),
                          const SizedBox(width: 20),
                          Expanded(
                            child: GestureDetector(
                              onLongPress: () {
                                if (_targetDocId != null) {
                                  showDialog(
                                    context: context,
                                    builder:
                                        (context) => BloodGroupForm(
                                          initialBloodGroup: _bloodGroup,
                                          docId: _targetDocId!,
                                        ),
                                  ).then(
                                    (_) =>
                                        _loadHealthData(showIndicator: false),
                                  );
                                }
                              },
                              child: InfoCard(
                                title: "Blood Group",
                                value: _bloodGroup,
                                unit: "",
                                icon: Icons.water_drop,
                                color: Colors.red.shade200,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 30),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            "Latest Reports",
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w700,
                              color: Colors.blueGrey,
                            ),
                          ),
                          IconButton(
                            icon: const Icon(
                              Icons.download,
                              color: Colors.blueAccent,
                              size: 24,
                            ),
                            onPressed: _generateAndShareWeeklyReport,
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Expanded(
                        child: _LatestReportsSection(
                          userName: widget.userName,
                          docId: _targetDocId,
                        ),
                      ),
                    ],
                  ),
                ),
      ),
    );
  }
}

class InfoCard extends StatelessWidget {
  final String title;
  final String value;
  final String unit;
  final IconData icon;
  final Color color;

  const InfoCard({
    super.key,
    required this.title,
    required this.value,
    required this.unit,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      color: color,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            Icon(icon, size: 40, color: Colors.blueAccent),
            const SizedBox(width: 16),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(fontSize: 16, color: Colors.grey),
                ),
                const SizedBox(height: 4),
                Text(
                  "$value $unit",
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _LatestReportsSection extends StatefulWidget {
  final String userName;
  final String? docId;

  const _LatestReportsSection({required this.userName, required this.docId});

  @override
  __LatestReportsSectionState createState() => __LatestReportsSectionState();
}

class __LatestReportsSectionState extends State<_LatestReportsSection>
    with SingleTickerProviderStateMixin {
  String _filter = 'All';
  bool _showDaily = true;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  List<Map<String, dynamic>> _reminders = [];
  late ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _fadeAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );
    _animationController.forward();
    _scrollController = ScrollController();
    _subscribeToReminders();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _subscribeToReminders() {
    if (widget.docId == null) return;

    final timeFrame =
        _showDaily
            ? DateTime.now().subtract(const Duration(days: 1))
            : DateTime.now().subtract(const Duration(days: 7));
    final timestamp = Timestamp.fromDate(timeFrame);

    FirebaseFirestore.instance
        .collection('users')
        .doc(widget.docId)
        .collection('reminders')
        .where('timestamp', isGreaterThan: timestamp)
        .snapshots()
        .listen(
          (snapshot) {
            final reminders =
                snapshot.docs.map((doc) {
                  final data = doc.data();
                  return {
                    'id': doc.id,
                    'medicine': data['medicine'] ?? 'Unknown',
                    'dosage': data['dosage'] ?? 'N/A',
                    'times': (data['times'] as List? ?? [])
                        .map((t) => t.toString())
                        .join(', '),
                    'isDaily': data['isDaily'] ?? true,
                    'timestamp': data['timestamp'] as Timestamp?,
                    'taken': data['taken'] ?? false,
                  };
                }).toList();

            setState(() {
              _reminders = reminders;
              print("Reminders updated silently: ${_reminders.length}");
            });
          },
          onError: (e) {
            print("Error subscribing to reminders: $e");
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Error fetching reminders: $e')),
            );
          },
        );
  }

  Widget _buildFilterButton(String label) {
    return GestureDetector(
      onTap: () => setState(() => _filter = label),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        width: 90,
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: _filter == label ? Colors.blueAccent : Colors.grey.shade100,
          borderRadius: BorderRadius.circular(10),
          boxShadow:
              _filter == label
                  ? [
                    BoxShadow(
                      color: Colors.blueAccent.withOpacity(0.3),
                      blurRadius: 4,
                    ),
                  ]
                  : [],
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              fontSize: 14,
              color: _filter == label ? Colors.white : Colors.black87,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildToggleSwitch() {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        color: Colors.grey.shade100,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          GestureDetector(
            onTap: () {
              if (!_showDaily) {
                setState(() {
                  _showDaily = true;
                });
                _subscribeToReminders();
              }
            },
            child: Container(
              width: 90,
              padding: const EdgeInsets.symmetric(vertical: 10),
              decoration: BoxDecoration(
                color: _showDaily ? Colors.blueAccent : Colors.grey.shade100,
                borderRadius: const BorderRadius.horizontal(
                  left: Radius.circular(10),
                ),
              ),
              child: Center(
                child: Text(
                  'Daily',
                  style: TextStyle(
                    fontSize: 14,
                    color: _showDaily ? Colors.white : Colors.black87,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ),
          GestureDetector(
            onTap: () {
              if (_showDaily) {
                setState(() {
                  _showDaily = false;
                });
                _subscribeToReminders();
              }
            },
            child: Container(
              width: 90,
              padding: const EdgeInsets.symmetric(vertical: 10),
              decoration: BoxDecoration(
                color: !_showDaily ? Colors.blueAccent : Colors.grey.shade100,
                borderRadius: const BorderRadius.horizontal(
                  right: Radius.circular(10),
                ),
              ),
              child: Center(
                child: Text(
                  'Weekly',
                  style: TextStyle(
                    fontSize: 14,
                    color: !_showDaily ? Colors.white : Colors.black87,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showReminderDetails(
    BuildContext context,
    Map<String, dynamic> reminder,
  ) {
    final isTaken = reminder['taken'] as bool;
    final timestamp = (reminder['timestamp'] as Timestamp?)?.toDate();
    final dateString =
        timestamp != null
            ? DateFormat('MMM d, h:mm a').format(timestamp)
            : 'N/A';

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    radius: 26,
                    backgroundColor:
                        isTaken
                            ? Colors.green.withOpacity(0.1)
                            : Colors.red.withOpacity(0.1),
                    child: Icon(
                      isTaken ? Icons.check_circle : Icons.warning,
                      color: isTaken ? Colors.green : Colors.red,
                      size: 32,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      reminder['medicine'],
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                'Dosage: ${reminder['dosage']}',
                style: const TextStyle(fontSize: 14, color: Colors.grey),
              ),
              const SizedBox(height: 6),
              Text(
                'Times: ${reminder['times']}',
                style: const TextStyle(fontSize: 14, color: Colors.grey),
              ),
              const SizedBox(height: 6),
              Text(
                'Frequency: ${reminder['isDaily'] ? 'Daily' : 'Weekly'}',
                style: const TextStyle(fontSize: 14, color: Colors.grey),
              ),
              const SizedBox(height: 6),
              Text(
                'Added: $dateString',
                style: const TextStyle(fontSize: 14, color: Colors.grey),
              ),
              const SizedBox(height: 6),
              Text(
                'Status: ${isTaken ? 'Taken' : 'Not Taken'}',
                style: TextStyle(
                  fontSize: 14,
                  color: isTaken ? Colors.green : Colors.red,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blueAccent,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    elevation: 2,
                  ),
                  child: const Text(
                    'Close',
                    style: TextStyle(fontSize: 14, color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final filteredReminders =
        _filter == 'All'
            ? _reminders
            : _filter == 'Taken'
            ? _reminders.where((r) => r['taken'] as bool).toList()
            : _reminders.where((r) => !(r['taken'] as bool)).toList();

    final sortedReminders =
        filteredReminders..sort(
          (a, b) => (b['timestamp'] as Timestamp).compareTo(
            a['timestamp'] as Timestamp,
          ),
        );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Center(child: _buildToggleSwitch()),
        const SizedBox(height: 12),
        Center(
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildFilterButton('All'),
              const SizedBox(width: 10),
              _buildFilterButton('Taken'),
              const SizedBox(width: 10),
              _buildFilterButton('Not Taken'),
            ],
          ),
        ),
        const SizedBox(height: 20),
        FadeTransition(
          opacity: _fadeAnimation,
          child: Card(
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            color: Colors.grey.shade50,
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Compliance Overview',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 8),
                  if (_reminders.isEmpty)
                    const SizedBox.shrink()
                  else
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '${_reminders.isNotEmpty ? (_reminders.where((r) => r['taken'] as bool).length / _reminders.length * 100).toStringAsFixed(1) : '0'}%',
                              style: const TextStyle(
                                fontSize: 28,
                                fontWeight: FontWeight.bold,
                                color: Colors.blueAccent,
                              ),
                            ),
                            const Text(
                              'Compliance Rate',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey,
                              ),
                            ),
                          ],
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '${_reminders.where((r) => r['taken'] as bool).length}/${_reminders.length}',
                              style: const TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                color: Colors.green,
                              ),
                            ),
                            const Text(
                              'Taken/Total',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(height: 20),
        Expanded(
          child:
              sortedReminders.isEmpty
                  ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.info_outline,
                          size: 60,
                          color: Colors.grey[400],
                        ),
                        const SizedBox(height: 12),
                        Text(
                          _showDaily
                              ? 'No reminders added today.'
                              : 'No reminders added in the past week.',
                          style: const TextStyle(
                            fontSize: 14,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  )
                  : SingleChildScrollView(
                    controller: _scrollController,
                    child: Column(
                      children:
                          sortedReminders.map((reminder) {
                            final isTaken = reminder['taken'] as bool;
                            final timestamp =
                                (reminder['timestamp'] as Timestamp?)?.toDate();
                            final dateString =
                                timestamp != null
                                    ? DateFormat(
                                      'MMM d, h:mm a',
                                    ).format(timestamp)
                                    : 'N/A';

                            return FadeTransition(
                              opacity: _fadeAnimation,
                              child: GestureDetector(
                                onTap:
                                    () =>
                                        _showReminderDetails(context, reminder),
                                child: Card(
                                  elevation: 2,
                                  margin: const EdgeInsets.symmetric(
                                    vertical: 6,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  color: Colors.grey.shade50,
                                  child: Padding(
                                    padding: const EdgeInsets.all(12),
                                    child: Row(
                                      children: [
                                        CircleAvatar(
                                          radius: 20,
                                          backgroundColor:
                                              isTaken
                                                  ? Colors.green.withOpacity(
                                                    0.1,
                                                  )
                                                  : Colors.red.withOpacity(0.1),
                                          child: Icon(
                                            isTaken
                                                ? Icons.check_circle
                                                : Icons.warning,
                                            color:
                                                isTaken
                                                    ? Colors.green
                                                    : Colors.red,
                                            size: 24,
                                          ),
                                        ),
                                        const SizedBox(width: 12),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                reminder['medicine'],
                                                style: const TextStyle(
                                                  fontSize: 18,
                                                  fontWeight: FontWeight.bold,
                                                  color: Colors.black87,
                                                ),
                                              ),
                                              const SizedBox(height: 2),
                                              Text(
                                                '${reminder['dosage']} • ${reminder['times']}',
                                                style: const TextStyle(
                                                  fontSize: 14,
                                                  color: Colors.grey,
                                                ),
                                              ),
                                              const SizedBox(height: 2),
                                              Text(
                                                'Added: $dateString',
                                                style: const TextStyle(
                                                  fontSize: 12,
                                                  color: Colors.grey,
                                                ),
                                              ),
                                              const SizedBox(height: 6),
                                              Container(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                      horizontal: 10,
                                                      vertical: 4,
                                                    ),
                                                decoration: BoxDecoration(
                                                  color:
                                                      isTaken
                                                          ? Colors.green
                                                              .withOpacity(0.1)
                                                          : Colors.red
                                                              .withOpacity(0.1),
                                                  borderRadius:
                                                      BorderRadius.circular(6),
                                                ),
                                                child: Text(
                                                  isTaken
                                                      ? 'Taken'
                                                      : 'Not Taken',
                                                  style: TextStyle(
                                                    fontSize: 12,
                                                    color:
                                                        isTaken
                                                            ? Colors.green
                                                            : Colors.red,
                                                    fontWeight: FontWeight.w600,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            );
                          }).toList(),
                    ),
                  ),
        ),
      ],
    );
  }
}

class RemindersScreen extends StatelessWidget {
  const RemindersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Reminders')),
      body: const Center(child: Text('Reminders Page')),
    );
  }
}
