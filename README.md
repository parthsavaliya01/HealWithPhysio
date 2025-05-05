# HealWithPhysio

***********Admin panel **************

setting.py - in this file change your username password
username - password


when you run admin panel which uses Django framework tables are automatically created

**********capston Api - folder*************
Extract this folder to    -> Xampp -> htdocs -> capstone

db_config.php - - in this file change your username password
username - password

db_connect.php - in this file change your username password
username - password


*************flutter application*************

main.dart -> in this file Change your ip address


for ip address type this command on terminal

-> open terminal -> ipconfig



->  Change your all api file locations


************** capstone - databse **************

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


ALTER TABLE physio_physiotherapist ADD average_rating FLOAT DEFAULT 0;
