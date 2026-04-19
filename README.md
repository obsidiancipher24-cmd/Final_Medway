# Medway – Healthcare Monitoring System

## Overview

Medway is a healthcare monitoring mobile application designed to support elderly individuals through real-time health tracking, medication management, and emergency assistance. It integrates a Flutter-based mobile application with Firebase services and IoT-enabled wearable devices to provide a unified healthcare solution.

---

## Problem Statement

Elderly individuals often struggle with managing their health due to memory issues, mobility challenges, and increased risk of emergencies. Caregivers face difficulties in providing continuous support due to the lack of integrated tools. Existing systems are fragmented and lack features tailored for elderly care such as medication reminders and real-time monitoring.

---

## Solution

Medway provides a unified platform that integrates wearable devices with a mobile application to enable:

* Real-time heart rate monitoring
* Emergency alerts
* Medication management
* Doctor appointment booking
* Pharmacy-based medicine ordering

---

## Features

### Patient Features

* Wearable heart rate monitoring
* Real-time health dashboard
* Book doctor appointments
* Order medicines
* One-click ambulance request
* Medication reminders

### Caregiver Features

* Link with patients using unique ID
* Monitor real-time health data
* Manage medication schedules
* Track medicine intake
* Upload prescriptions
* Access healthcare services

### Doctor Features

* Doctor registration and profile creation
* Receive and manage appointment requests
* Provide consultations

### Pharmacy Features

* Pharmacy registration and listing
* Add and manage medicines
* Handle and process orders

---

## Technology Stack

* **Frontend:** Flutter (Dart)
* **Backend:** Firebase (Authentication, Firestore, Storage)
* **IoT:** Arduino Nano 33 BLE, Heart Rate Sensor
* **Tools:** VS Code, Git, GitHub

---

## System Architecture

The system consists of:

1. Flutter Mobile Application
2. Firebase Backend
3. Arduino-based IoT Device

The IoT device collects heart rate data and transmits it via Bluetooth to the mobile application. The data is processed and stored in Firebase for real-time access.

---

## Installation

### Clone Repository

```bash
git clone https://github.com/your-username/Final_Medway.git
cd Final_Medway
```

### Run Application

```bash
flutter pub get
flutter run
```

---

## How to Use

### 1. Launch Application

Run the application on an emulator or physical device.

### 2. Register and Login

* Create a new account or login
* Authentication is handled using Firebase

### 3. Select Role

Choose your role:

* Patient
* Caregiver
* Doctor
* Pharmacy

### 4. Connect Health Device

* Turn on the wearable device
* Enable Bluetooth on your mobile
* Connect the device through the app
* View real-time heart rate

### 5. Manage Medications

* Add medicines and schedules
* Receive timely reminders

### 6. Book Appointments

* Select doctor
* Choose time slot
* Confirm booking

### 7. Emergency Support

* Use one-click emergency button
* Request ambulance instantly

### 8. Medical Records

* Upload prescriptions
* View reports and history

### 9. Order Medicines

* Browse pharmacy
* Add to cart
* Complete payment

---

## Screenshots

Add your screenshots inside a folder named `screenshots` and use:

```md
![Dashboard](screenshots/dashboard.png)
![Heart Rate](screenshots/heartrate.png)
![Appointment](screenshots/appointment.png)
![Pharmacy](screenshots/pharmacy.png)
```

---

## Security

* Firebase Authentication
* Role-based access control
* Secure cloud storage

---

## Limitations

* Requires internet connectivity
* Limited sensor accuracy
* Dependency on Firebase services

---

## Future Scope

* Additional sensors (BP, oxygen, temperature)
* Online doctor consultations
* Self-care mode
* Enhanced security
* Doctor follow-up reminders
* Multi-language support

---

## Conclusion

Medway is a scalable healthcare solution that enhances elderly care through real-time monitoring, automation, and efficient communication between patients, caregivers, and healthcare providers.
