-- MySQL dump 10.13  Distrib 5.5.37, for debian-linux-gnu (x86_64)
--
-- Host: localhost    Database: openmrs
-- ------------------------------------------------------
-- Server version	5.5.37-0ubuntu0.14.04.1

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8 */;
/*!40103 SET @OLD_TIME_ZONE=@@TIME_ZONE */;
/*!40103 SET TIME_ZONE='+00:00' */;
/*!40014 SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*!40111 SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0 */;

--
-- Table structure for table `patient_identifier_type`
--

DROP TABLE IF EXISTS `patient_identifier_type`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `patient_identifier_type` (
  `patient_identifier_type_id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(50) NOT NULL DEFAULT '',
  `description` text NOT NULL,
  `format` varchar(255) DEFAULT NULL,
  `check_digit` tinyint(1) NOT NULL DEFAULT '0',
  `creator` int(11) NOT NULL DEFAULT '0',
  `date_created` datetime NOT NULL DEFAULT '0000-00-00 00:00:00',
  `required` tinyint(1) NOT NULL DEFAULT '0',
  `format_description` varchar(255) DEFAULT NULL,
  `validator` varchar(200) DEFAULT NULL,
  `retired` tinyint(1) NOT NULL DEFAULT '0',
  `retired_by` int(11) DEFAULT NULL,
  `date_retired` datetime DEFAULT NULL,
  `retire_reason` varchar(255) DEFAULT NULL,
  `uuid` char(38) NOT NULL,
  `location_behavior` varchar(50) DEFAULT NULL,
  PRIMARY KEY (`patient_identifier_type_id`),
  UNIQUE KEY `patient_identifier_type_uuid_index` (`uuid`),
  KEY `type_creator` (`creator`),
  KEY `user_who_retired_patient_identifier_type` (`retired_by`),
  KEY `retired_status` (`retired`),
  CONSTRAINT `type_creator` FOREIGN KEY (`creator`) REFERENCES `users` (`user_id`),
  CONSTRAINT `user_who_retired_patient_identifier_type` FOREIGN KEY (`retired_by`) REFERENCES `users` (`user_id`)
) ENGINE=InnoDB AUTO_INCREMENT=25 DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `patient_identifier_type`
--

LOCK TABLES `patient_identifier_type` WRITE;
/*!40000 ALTER TABLE `patient_identifier_type` DISABLE KEYS */;
INSERT INTO `patient_identifier_type` VALUES (1,'OpenMRS Identification Number','Unique number used in OpenMRS','',1,1,'2005-09-22 00:00:00',0,NULL,'org.openmrs.patient.impl.LuhnIdentifierValidator',0,NULL,NULL,NULL,'8d793bee-c2cc-11de-8d13-0010c6dffd0f',NULL),(2,'Old Identification Number','Number given out prior to the OpenMRS system (No check digit)','',0,1,'2005-09-22 00:00:00',0,NULL,NULL,0,NULL,NULL,NULL,'8d79403a-c2cc-11de-8d13-0010c6dffd0f',NULL),(3,'National id','National ID number developed by Baobab','',0,1,'2007-11-29 22:12:34',0,'P-175-0000004-5',NULL,0,NULL,NULL,NULL,'7ae03a9a-da62-11d7-9243-0024217bb78e',NULL),(4,'ARV Number','Unique ID Number for Patients in ARV Treatment Program','',0,1,'2007-12-17 15:29:01',0,'',NULL,0,NULL,NULL,NULL,'7ae03bc6-da62-11d7-9243-0024217bb78e',NULL),(5,'z_deprecated Pre ART Number (Old format)','Sequential number given to patients enrolled in Pre-ART program','',0,1,'2009-07-22 12:55:25',0,'PART-0001','',0,NULL,NULL,NULL,'7ae03cfc-da62-11d7-9243-0024217bb78e',NULL),(6,'VHW ID','Village Health Worker ID#','',0,1,'2008-06-11 10:22:53',0,'',NULL,0,NULL,NULL,NULL,'7ae03e28-da62-11d7-9243-0024217bb78e',NULL),(7,'District TB Number','Ministry of Health identification number for TB patients','',0,1,'2008-07-09 15:39:46',0,'AA/DOT/####/YY','',0,NULL,NULL,NULL,'7ae03f5e-da62-11d7-9243-0024217bb78e',NULL),(8,'Dummy ID','Dummy ID for test patients','',0,1,'2008-08-16 15:41:21',0,'','',0,NULL,NULL,NULL,'7ae0408a-da62-11d7-9243-0024217bb78e',NULL),(9,'z_deprecated EID Number','Early Infant Diagnosis number.  Example: 3009-9009-1','',0,1,'2008-09-16 16:03:40',0,'','',0,NULL,NULL,NULL,'7ae041b6-da62-11d7-9243-0024217bb78e',NULL),(10,'Unknown ID','Unknown ID as scanned by mateme','',0,1,'2008-09-17 18:17:43',0,'','',0,NULL,NULL,NULL,'7ae042e2-da62-11d7-9243-0024217bb78e',NULL),(11,'MDR-TB Program Identifier','MDR-TB Program Identifier','',0,1,'2008-09-23 23:10:40',0,'','',0,NULL,NULL,NULL,'7ae04404-da62-11d7-9243-0024217bb78e',NULL),(12,'KS Number','Filing for KS Programme ','',0,1,'2009-04-08 10:51:11',0,'','',0,NULL,NULL,NULL,'7ae04530-da62-11d7-9243-0024217bb78e',NULL),(13,'z_deprecated PART Number','Sequential id number given to Pre-ART patients for filing purposes.  The first character \'P\' indicates the identifier type.  The next three characters (ie, NNO) indicate the facility.','',0,1,'2009-07-22 12:55:25',0,'P-NNO-0001','',0,NULL,NULL,NULL,'7ae04652-da62-11d7-9243-0024217bb78e',NULL),(14,'Diabetes Number','Unique identifier given to Diabetic patients','',0,1,'2009-12-01 09:17:25',0,'','',0,NULL,NULL,NULL,'7ae04788-da62-11d7-9243-0024217bb78e',NULL),(15,'LAB IDENTIFIER','Accession number for Lab Tests requested in OPD','/^LAB\\s\\d+$/',0,1,'2010-08-13 15:49:28',0,'Starts with string \"LAB\" a space and then a number','',0,NULL,NULL,NULL,'7ae048b4-da62-11d7-9243-0024217bb78e',NULL),(16,'DS Number','Diabetes Study Number','',0,1,'2010-11-15 13:18:58',0,'','',0,NULL,NULL,NULL,'7ae05a70-da62-11d7-9243-0024217bb78e',NULL),(17,'Filing number','Number attached to a patient\'s file at a clinic','',0,1,'2011-07-08 14:20:57',0,'','',0,NULL,NULL,NULL,'7ae05bba-da62-11d7-9243-0024217bb78e',NULL),(18,'Archived filing number','Number attached to a patient\'s file at a clinic','',0,1,'2011-07-08 14:21:32',0,'','',0,NULL,NULL,NULL,'7ae05ce6-da62-11d7-9243-0024217bb78e',NULL),(19,'HCC Number','HIV Care Clinic for Pre-ART patients and Exposed Children','',0,1,'2011-09-07 14:46:04',0,'','',0,NULL,NULL,NULL,'7ae05e12-da62-11d7-9243-0024217bb78e',NULL),(20,'Radiology Study Number','Radiology Study Number','',0,1,'2011-12-22 11:34:03',0,'','',0,NULL,NULL,NULL,'7ae05f3e-da62-11d7-9243-0024217bb78e',NULL),(21,'IVR Access Code','Used in mnch hotline to identify individual callers','',0,1,'2012-07-18 23:46:34',0,'','',0,NULL,NULL,NULL,'7ae0606a-da62-11d7-9243-0024217bb78e',NULL),(22,'Pre-ART Number','Pre-ART Number','',0,1,'2013-02-02 12:14:22',0,'','',0,NULL,NULL,NULL,'7ae0618c-da62-11d7-9243-0024217bb78e',NULL),(23,'Serial Number','Birth Registration Serial Number','',0,1,'2002-10-31 21:35:32',0,'','',0,NULL,NULL,NULL,'7ae062b8-da62-11d7-9243-0024217bb78e',NULL),(24,'HTC Identifier','Number used for identifying HTC clients',NULL,0,1,'2014-07-10 18:06:00',0,NULL,NULL,0,NULL,NULL,NULL,'2b0e7a9a-f252-4145-a46c-5b4e0d73b6bd',NULL);
/*!40000 ALTER TABLE `patient_identifier_type` ENABLE KEYS */;
UNLOCK TABLES;
/*!40103 SET TIME_ZONE=@OLD_TIME_ZONE */;

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;

-- Dump completed on 2014-07-10 18:14:30
