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

<p align="center">
  <img src="https://github.com/user-attachments/assets/212086dc-2371-4a50-a0ef-cf6fd69e4ebf" width="250"/>
  <img src="https://github.com/user-attachments/assets/f08f9e1b-c55b-44ad-af71-3c7b852385a1" width="250"/>
</p>

<p align="center">
  <img src="https://github.com/user-attachments/assets/7c6871db-0fb2-44a4-955a-db5e7eefcf67" width="250"/>
  <img src="https://github.com/user-attachments/assets/47b0c7ac-913a-4242-b256-aa899bce4b15" width="250"/>
</p>

<p align="center">
  <img src="https://github.com/user-attachments/assets/0e01c98a-7458-419e-b8c2-e131a0ad595a" width="250"/>
  <img src="https://github.com/user-attachments/assets/0191c221-a7bf-4ae8-a1b0-f41455d12714" width="250"/>
</p>

<p align="center">
  <img src="https://github.com/user-attachments/assets/41c6f783-f2ee-4b3a-bf49-0ffc35081153" width="250"/>
  <img src="https://github.com/user-attachments/assets/08aa6a03-0005-4474-a532-57d62500d8a5" width="250"/>
</p>

<p align="center">
  <img src="https://github.com/user-attachments/assets/f8e34bc0-f0c8-4353-9185-8168cdd175cf" width="250"/>
  <img src="https://github.com/user-attachments/assets/6545ebb4-076c-4393-8d9b-4d7fad7041d6" width="250"/>
</p>

<p align="center">
  <img src="https://github.com/user-attachments/assets/cadb3e7b-f88b-4380-bc09-917dde5ac43f" width="250"/>
</p>

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

---

## LICENSE

This Project is under Apache 2.0 LICENSE
See the LICENSE file for details.
