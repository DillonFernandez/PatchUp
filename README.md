<div align="center">
  <img src="patchup_website/images/Logo 1.webp" alt="PatchUp Logo" height="200"/>
  
  # PatchUp
  
  **Smart Pothole Reporting & Management Platform for Sri Lanka**
  
  [![Status](https://img.shields.io/badge/Status-Testing%20Phase-orange)](https://github.com)
  [![Location](https://img.shields.io/badge/Location-Sri%20Lanka-blue)](https://github.com)
  [![Platform](https://img.shields.io/badge/Platform-Mobile%20%7C%20Web-green)](https://github.com)
  
  *Making Sri Lankan roads safer, one pothole at a time* 🛣️✨
</div>

---

## About

PatchUp empowers Sri Lankan citizens to improve road infrastructure through seamless pothole reporting while providing local authorities with efficient management tools to prioritize and resolve issues.

> **Academic Project:** This project is developed as part of the Commercial Computing Second Year curriculum at APIIT Sri Lanka.

---

## Features

| **Citizen App**                                | **Authority Dashboard**                | **Smart Features**                      |
| ---------------------------------------------- | -------------------------------------- | --------------------------------------- |
| One-tap reporting with GPS auto-location       | Real-time report management            | Duplicate prevention system             |
| Photo capture with metadata                    | Priority assignment and status updates | Push notifications                      |
| Status tracking and progress monitoring        | Interactive heatmap analytics          | Community confirmation through upvoting |
| Multilingual support (Sinhala, Tamil, English) | Direct communication with citizens     | Real-time chat for each report          |
| Offline reporting with auto-sync               | Progress tracking tools                | Advanced filtering and analytics        |
| Community validation system                    | Validated reports dashboard            |                                         |
| Gamification with points and achievements      |                                        |                                         |

---

## Getting Started

### Prerequisites

- Mobile device (Android/iOS) for citizen app
- Web browser for authority dashboard
- Internet connection (offline sync available)
- **XAMPP** for local development environment

### Development Setup

<details>
<summary><strong>XAMPP Installation & Configuration</strong></summary>

#### Download & Install XAMPP

- Download XAMPP from [https://www.apachefriends.org/download.html](https://www.apachefriends.org/download.html)
- Install XAMPP on your local machine
- Start Apache and MySQL services from XAMPP Control Panel

#### Project Setup

1. Navigate to your XAMPP installation directory (usually `C:\xampp\htdocs\`)
2. Place both the **mobile app** and **website** folders inside the `htdocs` directory
3. Your folder structure should look like:
   ```
   C:\xampp\htdocs\
   ├── patchup-app/          (Mobile app files)
   ├── patchup-website/      (Website files)
   └── ...other projects
   ```

</details>

<details>
<summary><strong>Database Configuration</strong></summary>

#### Create Database

1. Open your web browser and go to `http://localhost/phpmyadmin`
2. Click "New" to create a new database
3. Name the database: `patchup`
4. Click "Create"

#### Import Database Structure

1. Select the newly created `patchup` database
2. Click on the "Import" tab
3. Click "Choose File" and select `Xampp Database.sql` from the project files
4. Click "Go" to import the database structure and initial data

</details>

<details>
<summary><strong>IP Address Configuration</strong></summary>

#### Find Your Local IP Address

**Windows:**

```cmd
ipconfig
```

Look for "IPv4 Address" under your active network connection

**Mac/Linux:**

```bash
ifconfig
```

Look for your network interface IP address

#### Configure Mobile App

- The mobile app requires your local IP address to communicate with the XAMPP server
- Replace `192.168.8.187` references in the mobile app configuration files with your actual IP address
- **Current IP Address**: `192.168.8.187`
- Example: Use `http://192.168.8.187/patchup-app/`
- This ensures the mobile app can communicate with the local server from different devices on the same network

> **Important:** When testing the mobile app on your device, make sure both your development machine (running XAMPP) and your mobile device are connected to the same WiFi network.

> **Note:** The website dashboard doesn't need Ip Address.

</details>

---

## Usage

| **For Citizens**                        | **For Authorities**                                  |
| --------------------------------------- | ---------------------------------------------------- |
| **Spot** a pothole during daily commute | **Receive** real-time report notifications           |
| **Open** PatchUp mobile app             | **Assess** reports on management dashboard           |
| **Capture** photo with auto GPS tagging | **Prioritize** using community validation & severity |
| **Submit** with severity & description  | **Assign** teams and update status                   |
| **Track** progress through dashboard    | **Communicate** directly with reporters              |
| **Engage** with community & earn points | **Monitor** progress through analytics               |

---

## Development Roadmap

<details>
<summary><strong>Phase 1: Foundation (Completed)</strong></summary>

#### Authentication System

- Secure user registration & login
- Session management & data sync

#### Location Services

- GPS integration for precise coordinates
- Location-based report mapping

#### Basic Reporting

- Photo capture with metadata
- Description and severity input
- Instant submission workflow

</details>

<details>
<summary><strong>Phase 2: Intelligence & Management (Completed)</strong></summary>

#### Visual Intelligence

- Interactive map with real-time updates
- Heatmap showing pothole density
- Advanced filtering by status & severity

#### Smart Operations

- Offline reporting with auto-sync
- Push notifications for updates
- Multilingual support (Sinhala, Tamil, English)

#### Authority Platform

- Dedicated municipal dashboard
- Report status management
- Progress tracking tools

</details>

<details>
<summary><strong>Phase 3: Community & Engagement (Completed)</strong></summary>

#### Community Confirmation

- Upvote system for report confirmation
- Community-driven prioritization
- Crowdsourced accuracy improvement

#### Gamification Engine

- Point system for active users
- Achievement badges & milestones
- Community leaderboards

#### Communication Hub

- Real-time chat for each report
- Direct citizen-authority communication
- Status update notifications

</details>

<details>
<summary><strong>Phase 4: Final Validation & Profile Management (Completed)</strong></summary>

#### Duplicate Prevention System

- Smart location-based duplicate detection
- Automatic validation when multiple users report same pothole
- Prevention of duplicate reports from same user
- Cross-user validation workflow

#### Profile Management

- User profile editing capabilities
- Personal dashboard with validated reports
- User contribution tracking

#### Enhanced Authority Features

- Validated reports dashboard for authorities
- Advanced report status management
- Community validation insights

</details>

---

## Testing

### Test Credentials

| Platform          | User Type   | Credentials                                                                               |
| ----------------- | ----------- | ----------------------------------------------------------------------------------------- |
| **Mobile App**    | Citizens    | **Email:** `dillon@gmail.com`<br>**Password:** `TestUser@1`                               |
| **Web Dashboard** | Authorities | **Name:** `Dillon Fernandez`<br>**Email:** `dillon@gmail.com`<br>**Password:** `Dillon@1` |

> **Note:** Testing credentials only - Not for production use

---

## Platform Overview

| Platform          | Target Users      | Availability     | Features                 |
| ----------------- | ----------------- | ---------------- | ------------------------ |
| **Mobile App**    | Citizens          | Sri Lanka Wide   | Report, Track, Engage    |
| **Web Dashboard** | Local Authorities | Internal Testing | Manage, Analyze, Respond |

---

## Contact

<div align="center">

**Email:** support@patchup.lk  
**Phone:** +94 77 123 4567

---

**© 2025 PatchUp. All rights reserved.**

</div>
