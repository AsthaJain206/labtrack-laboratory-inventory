CREATE DATABASE  IF NOT EXISTS `lab_inventory` /*!40100 DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci */ /*!80016 DEFAULT ENCRYPTION='N' */;
USE `lab_inventory`;
-- MySQL dump 10.13  Distrib 8.0.46, for Win64 (x86_64)
--
-- Host: localhost    Database: lab_inventory
-- ------------------------------------------------------
-- Server version	8.0.46

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!50503 SET NAMES utf8 */;
/*!40103 SET @OLD_TIME_ZONE=@@TIME_ZONE */;
/*!40103 SET TIME_ZONE='+00:00' */;
/*!40014 SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*!40111 SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0 */;

--
-- Table structure for table `equipment`
--

DROP TABLE IF EXISTS `equipment`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `equipment` (
  `equipment_id` int NOT NULL AUTO_INCREMENT,
  `name` varchar(100) NOT NULL,
  `category` varchar(100) DEFAULT NULL,
  `model` varchar(100) DEFAULT NULL,
  `brand` varchar(100) DEFAULT NULL,
  `serial_no` varchar(100) DEFAULT NULL,
  `condition` varchar(30) DEFAULT 'Good',
  `purchase_date` date DEFAULT NULL,
  `lab_id` int NOT NULL,
  `supplier_id` int DEFAULT NULL,
  PRIMARY KEY (`equipment_id`),
  UNIQUE KEY `serial_no` (`serial_no`),
  KEY `lab_id` (`lab_id`),
  KEY `supplier_id` (`supplier_id`),
  CONSTRAINT `equipment_ibfk_1` FOREIGN KEY (`lab_id`) REFERENCES `laboratory` (`lab_id`),
  CONSTRAINT `equipment_ibfk_2` FOREIGN KEY (`supplier_id`) REFERENCES `supplier` (`supplier_id`)
) ENGINE=InnoDB AUTO_INCREMENT=8 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `equipment`
--

LOCK TABLES `equipment` WRITE;
/*!40000 ALTER TABLE `equipment` DISABLE KEYS */;
INSERT INTO `equipment` VALUES (1,'Oscilloscope','Measurement','DS1054Z','Rigol','OSC001','Good','2025-01-15',1,1),(2,'Digital Multimeter','Measurement','DM100','Fluke','DMM001','Good','2025-02-10',1,2),(3,'PLC Trainer','Automation','LOGO8','Siemens','PLC001','Good','2025-03-20',3,3),(4,'DC Motor','Electrical Machines','DC200','ABB','MOT001','Good','2025-01-25',2,3),(5,'Function Generator','Electronics','FG100','Rigol','FG001','Good','2025-04-12',1,1),(6,'Power Supply','Electronics','PS300','Keysight','PS001','Good','2025-05-08',4,2),(7,'Tachometer',NULL,NULL,NULL,'07B6','Good','2026-10-12',2,NULL);
/*!40000 ALTER TABLE `equipment` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `faculty`
--

DROP TABLE IF EXISTS `faculty`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `faculty` (
  `faculty_id` int NOT NULL AUTO_INCREMENT,
  `name` varchar(100) NOT NULL,
  `department` varchar(100) DEFAULT NULL,
  `email` varchar(100) DEFAULT NULL,
  `phone` varchar(15) DEFAULT NULL,
  PRIMARY KEY (`faculty_id`),
  UNIQUE KEY `email` (`email`)
) ENGINE=InnoDB AUTO_INCREMENT=4 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `faculty`
--

LOCK TABLES `faculty` WRITE;
/*!40000 ALTER TABLE `faculty` DISABLE KEYS */;
INSERT INTO `faculty` VALUES (1,'Dr Amit Verma','ECE','amit@example.com','9123456780'),(2,'Dr Neha Joshi','Electrical','neha@example.com','9123456781'),(3,'Prof Rahul Desai','Mechanical','rahul@example.com','9123456782');
/*!40000 ALTER TABLE `faculty` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `issue_return`
--

DROP TABLE IF EXISTS `issue_return`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `issue_return` (
  `issue_id` int NOT NULL AUTO_INCREMENT,
  `student_id` int NOT NULL,
  `equipment_id` int NOT NULL,
  `approving_faculty_id` int NOT NULL,
  `issue_date` date NOT NULL,
  `return_date` date DEFAULT NULL,
  `status` varchar(30) DEFAULT 'Issued',
  `remarks` varchar(255) DEFAULT NULL,
  PRIMARY KEY (`issue_id`),
  KEY `student_id` (`student_id`),
  KEY `equipment_id` (`equipment_id`),
  KEY `approving_faculty_id` (`approving_faculty_id`),
  CONSTRAINT `issue_return_ibfk_1` FOREIGN KEY (`student_id`) REFERENCES `student` (`student_id`),
  CONSTRAINT `issue_return_ibfk_2` FOREIGN KEY (`equipment_id`) REFERENCES `equipment` (`equipment_id`),
  CONSTRAINT `issue_return_ibfk_3` FOREIGN KEY (`approving_faculty_id`) REFERENCES `faculty` (`faculty_id`)
) ENGINE=InnoDB AUTO_INCREMENT=6 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `issue_return`
--

LOCK TABLES `issue_return` WRITE;
/*!40000 ALTER TABLE `issue_return` DISABLE KEYS */;
INSERT INTO `issue_return` VALUES (1,1,1,1,'2026-10-01','2026-10-13','Returned','Electronics practical'),(2,2,2,2,'2026-10-02','2026-10-03','Returned','Measurement experiment'),(3,3,3,1,'2026-10-04','2026-10-13','Returned','PLC lab practice'),(4,1,2,3,'2026-10-13','2026-10-14','Returned',NULL),(5,5,3,2,'2026-10-13','2026-10-15','Returned',NULL);
/*!40000 ALTER TABLE `issue_return` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `laboratory`
--

DROP TABLE IF EXISTS `laboratory`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `laboratory` (
  `lab_id` int NOT NULL AUTO_INCREMENT,
  `lab_name` varchar(100) NOT NULL,
  `department` varchar(100) DEFAULT NULL,
  `location` varchar(100) DEFAULT NULL,
  `capacity` int DEFAULT NULL,
  PRIMARY KEY (`lab_id`)
) ENGINE=InnoDB AUTO_INCREMENT=5 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `laboratory`
--

LOCK TABLES `laboratory` WRITE;
/*!40000 ALTER TABLE `laboratory` DISABLE KEYS */;
INSERT INTO `laboratory` VALUES (1,'Electronics Lab','ECE','Block A, Room 101',30),(2,'Electrical Machines Lab','Electrical','Block B, Room 201',25),(3,'Automation Lab','ECE','Block A, Room 105',20),(4,'Measurement Lab','Electrical','Block B, Room 205',25);
/*!40000 ALTER TABLE `laboratory` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `maintenance`
--

DROP TABLE IF EXISTS `maintenance`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `maintenance` (
  `maintenance_id` int NOT NULL AUTO_INCREMENT,
  `equipment_id` int NOT NULL,
  `date` date NOT NULL,
  `type` varchar(100) DEFAULT NULL,
  `description` text,
  `cost` decimal(10,2) DEFAULT '0.00',
  `status` varchar(30) DEFAULT 'Pending',
  PRIMARY KEY (`maintenance_id`),
  KEY `equipment_id` (`equipment_id`),
  CONSTRAINT `maintenance_ibfk_1` FOREIGN KEY (`equipment_id`) REFERENCES `equipment` (`equipment_id`)
) ENGINE=InnoDB AUTO_INCREMENT=5 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `maintenance`
--

LOCK TABLES `maintenance` WRITE;
/*!40000 ALTER TABLE `maintenance` DISABLE KEYS */;
INSERT INTO `maintenance` VALUES (1,1,'2026-09-15','Inspection','Routine oscilloscope inspection',500.00,'Completed'),(2,4,'2026-10-05','Repair','Motor vibration inspection',1200.00,'Pending'),(3,5,'2026-09-20','Calibration','Function generator calibration',800.00,'Completed'),(4,4,'2026-10-12','Repair',NULL,1000.00,'Completed');
/*!40000 ALTER TABLE `maintenance` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `student`
--

DROP TABLE IF EXISTS `student`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `student` (
  `student_id` int NOT NULL AUTO_INCREMENT,
  `name` varchar(100) NOT NULL,
  `department` varchar(100) DEFAULT NULL,
  `year` int DEFAULT NULL,
  `email` varchar(100) DEFAULT NULL,
  `phone` varchar(15) DEFAULT NULL,
  PRIMARY KEY (`student_id`),
  UNIQUE KEY `email` (`email`)
) ENGINE=InnoDB AUTO_INCREMENT=6 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `student`
--

LOCK TABLES `student` WRITE;
/*!40000 ALTER TABLE `student` DISABLE KEYS */;
INSERT INTO `student` VALUES (1,'Aarav Sharma','ECE',3,'aarav@example.com','9876543210'),(2,'Priya Patel','Electrical',2,'priya@example.com','9876543211'),(3,'Rohan Mehta','ECE',3,'rohan@example.com','9876543212'),(4,'Sneha Kulkarni','Mechanical',2,'sneha@example.com','9876543213'),(5,'Kabir Shah','ECE',4,'kabir@example.com','9876543214');
/*!40000 ALTER TABLE `student` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `supplier`
--

DROP TABLE IF EXISTS `supplier`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `supplier` (
  `supplier_id` int NOT NULL AUTO_INCREMENT,
  `name` varchar(100) NOT NULL,
  `contact_person` varchar(100) DEFAULT NULL,
  `phone` varchar(15) DEFAULT NULL,
  `email` varchar(100) DEFAULT NULL,
  `address` varchar(255) DEFAULT NULL,
  PRIMARY KEY (`supplier_id`),
  UNIQUE KEY `email` (`email`)
) ENGINE=InnoDB AUTO_INCREMENT=4 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `supplier`
--

LOCK TABLES `supplier` WRITE;
/*!40000 ALTER TABLE `supplier` DISABLE KEYS */;
INSERT INTO `supplier` VALUES (1,'Tech Instruments','Raj Malhotra','9012345670','tech@example.com','Pune'),(2,'Electro Supplies','Meera Nair','9012345671','electro@example.com','Mumbai'),(3,'Industrial Systems','Vikram Rao','9012345672','industrial@example.com','Pune');
/*!40000 ALTER TABLE `supplier` ENABLE KEYS */;
UNLOCK TABLES;
/*!40103 SET TIME_ZONE=@OLD_TIME_ZONE */;

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;

-- Dump completed on 2026-10-15 14:16:21
