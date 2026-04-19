Medway – Healthcare Monitoring System
Overview

Medway is a healthcare monitoring mobile application designed to support elderly individuals through real-time health tracking, medication management, and emergency assistance. The system integrates a Flutter-based mobile application with Firebase services and IoT-enabled wearable devices to provide a unified and efficient healthcare solution.

Problem Statement

Elderly individuals often struggle with managing their health due to memory issues, mobility challenges, and increased risk of emergencies. Caregivers face difficulties in providing continuous support due to the lack of integrated tools. Existing systems are fragmented and do not offer features tailored for elderly care such as real-time monitoring and medication management. Medway addresses these challenges by providing a comprehensive and user-friendly platform.

Solution

Medway offers a unified healthcare platform that combines mobile technology and wearable devices to enable:

Real-time heart rate monitoring
Emergency alert systems
Medication management
Doctor appointment booking
Pharmacy integration for medicine ordering

It allows caregivers to remotely monitor patients and manage healthcare activities efficiently.

Features
Patient Features
Wearable heart rate monitoring using sensor device
Real-time health dashboard
Book appointments with doctors
Order medicines from pharmacy
One-click ambulance request
Medication reminders
Caregiver Features
Link with patients using unique ID
Monitor patient’s health data in real time
Manage medication schedules and reminders
Track medicine intake through dashboard
Upload prescriptions
Access healthcare services on behalf of patient
Doctor Features
Doctor registration and profile creation
Appointment request handling
Manage and track appointments
Provide consultations
Pharmacy Features
Pharmacy registration and listing
Add and manage medicines
Receive and manage orders
Process and deliver medicines
Technology Stack
Frontend: Flutter (Dart)
Backend: Firebase (Authentication, Firestore, Storage)
IoT: Arduino Nano 33 BLE, Heart Rate Sensor
Tools: Visual Studio Code, Git, GitHub
System Architecture

The system consists of:

Mobile Application (Flutter)
Firebase Backend
IoT Device (Arduino + Sensor)

The wearable device captures heart rate data and transmits it via Bluetooth to the mobile application. The application processes and stores the data in Firebase, enabling access for patients and caregivers.

Installation
Clone Repository

git clone https://github.com/your-username/Final_Medway.git
cd Final_Medway

Run Application

flutter pub get
flutter run

How to Use
1. Launch Application

Run the application on an emulator or physical device.

2. Register and Login
Create an account or login
Authentication is handled via Firebase
3. Select Role

Choose your role:

Patient
Caregiver
Doctor
Pharmacy
4. Connect Health Device
Turn on the wearable device
Enable Bluetooth
Connect via app
Monitor real-time heart rate
5. Manage Medications
Add medicines and schedules
Receive reminders
6. Book Appointments
Select doctor
Choose slot
Confirm booking
7. Emergency Support
Use one-click emergency button
Request ambulance instantly
8. Medical Records
Upload prescriptions
View reports and history
9. Order Medicines
Browse pharmacy
Add to cart
Complete payment
Screenshots

Add your application screenshots here:

Login Screen
Dashboard
Heart Rate Monitoring
Medication Reminder
Appointment Booking
Pharmacy Module
Emergency Feature

(Replace this section with actual images from your presentation)

Security
Firebase Authentication ensures secure access
Role-based access control
Secure cloud storage
Limitations
Requires internet connectivity
Limited sensor accuracy
Dependency on Firebase services
Future Scope
Add sensors for blood pressure, oxygen levels, and temperature
Online doctor consultation (telemedicine)
Self-care mode for individuals
Enhanced security and verification
Doctor follow-up reminders
Integration with hospitals and pharmacies
Multi-language support
Conclusion

Medway is a user-friendly healthcare application that improves elderly care through real-time monitoring and smart healthcare services. It supports both patients and caregivers by providing tools for health tracking, medication management, and emergency handling, ensuring better healthcare accessibility and reliability.

Contributors
Bhavya Darji
Shubham Sheth
Komal Mehta
References
Flutter Documentation
Firebase Documentation
Arduino Documentation
Relevant research papers and online resources
