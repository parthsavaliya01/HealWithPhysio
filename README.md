# 💪 HealWithPhysio – Full Stack Project
This project is a complete physiotherapy management system, including:

🧑‍⚕️ Flutter Mobile Application (Patient Interface)

🛠️ Django Admin Panel (Admin Control & Backend)

🔗 PHP + MySQL API (Capstone API)

🗃️ MySQL Database Setup

# ⚙️ Project Setup Guide
## 🔒 Admin Panel – Django (Python)
Navigate to settings.py and update your credentials:

python
Copy
Edit
# settings.py
USERNAME = 'your_username'
PASSWORD = 'your_password'
When you run the Django server, the required tables will be automatically created using Django's ORM.

## 🌐 Capstone API – PHP (Backend)
Extract the folder capstone Api to the following location:

rust

XAMPP -> htdocs -> capstone
Edit the following PHP files to match your XAMPP database credentials:

db_config.php

db_connect.php

Replace:

php

$username = "your_username";
$password = "your_password";

# 📱 Flutter Application – Mobile App
Open the main.dart file.

Update the IP address to your system's IP for local API calls.

🔍 To find your IP address:

bash

Open terminal → type: ipconfig (on Windows)
Replace all API endpoint IPs in your Flutter files to match the one found above.

# 🧾 Database Structure
## 🗃️ Table: ratings_feedback

sql

CREATE TABLE ratings_feedback (
  id INT AUTO_INCREMENT PRIMARY KEY,
  appointment_id INT NOT NULL,
  physio_name VARCHAR(255) NOT NULL,
  patient_name VARCHAR(255) NOT NULL,
  rating INT NOT NULL CHECK (rating >= 1 AND rating <= 5),
  feedback TEXT,
  created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (appointment_id) REFERENCES appointments(id) ON DELETE CASCADE
);

## ➕ Alter Table: physio_physiotherapist
sql

ALTER TABLE physio_physiotherapist
ADD average_rating FLOAT DEFAULT 0;

# 🚀 Summary
This project combines Flutter, Django, and PHP with MySQL for a complete full-stack healthcare application. Follow the steps above to configure each part and ensure the system works seamlessly across platforms.

