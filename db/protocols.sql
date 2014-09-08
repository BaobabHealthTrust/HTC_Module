-- MySQL dump 10.13  Distrib 5.5.38, for debian-linux-gnu (x86_64)
--
-- Host: localhost    Database: htc_db
-- ------------------------------------------------------
-- Server version	5.5.38-0ubuntu0.14.04.1

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
-- Table structure for table `counseling_question`
--

DROP TABLE IF EXISTS `counseling_question`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `counseling_question` (
  `question_id` int(11) NOT NULL AUTO_INCREMENT,
  `name` text,
  `description` text,
  `child` int(11) NOT NULL DEFAULT '0',
  `data_type` varchar(25) DEFAULT NULL,
  `list_type` text,
  `date_created` datetime DEFAULT NULL,
  `date_updated` datetime DEFAULT NULL,
  `retired` int(11) NOT NULL DEFAULT '0',
  `creator` int(11) NOT NULL,
  PRIMARY KEY (`question_id`)
) ENGINE=InnoDB AUTO_INCREMENT=12 DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `counseling_question`
--

LOCK TABLES `counseling_question` WRITE;
/*!40000 ALTER TABLE `counseling_question` DISABLE KEYS */;
INSERT INTO `counseling_question` VALUES (9,'Have you ever tested for HIV?','HTC Protocols',0,'Number','Residence',NULL,NULL,0,3),(10,'Have you ever tested for STIs?','Risk determination',0,'Boolean',NULL,NULL,NULL,0,3),(11,'Have you ever had foot rush?','HTC screening',0,'Boolean',NULL,NULL,NULL,0,3);
/*!40000 ALTER TABLE `counseling_question` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `counseling_answer`
--

DROP TABLE IF EXISTS `counseling_answer`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `counseling_answer` (
  `answer_id` int(11) NOT NULL AUTO_INCREMENT,
  `question_id` int(11) DEFAULT NULL,
  `patient_id` int(11) DEFAULT NULL,
  `encounter_id` int(11) DEFAULT NULL,
  `value_coded` int(11) DEFAULT NULL,
  `value_numeric` int(11) DEFAULT NULL,
  `value_text` text,
  `value_datetime` datetime DEFAULT NULL,
  `date_created` datetime DEFAULT NULL,
  `date_updated` datetime DEFAULT NULL,
  `creator` int(11) DEFAULT NULL,
  `voided` tinyint(1) NOT NULL DEFAULT '0',
  `voided_by` int(11) DEFAULT NULL,
  PRIMARY KEY (`answer_id`)
) ENGINE=InnoDB AUTO_INCREMENT=30 DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `counseling_answer`
--

LOCK TABLES `counseling_answer` WRITE;
/*!40000 ALTER TABLE `counseling_answer` DISABLE KEYS */;
INSERT INTO `counseling_answer` VALUES (28,7,49,71,1065,NULL,NULL,NULL,'2014-08-06 08:07:52',NULL,5,3,NULL),(29,8,49,71,NULL,NULL,NULL,'2013-08-06 00:00:00','2014-08-06 08:07:52',NULL,5,3,NULL);
/*!40000 ALTER TABLE `counseling_answer` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `child_protocol`
--

DROP TABLE IF EXISTS `child_protocol`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `child_protocol` (
  `child_id` int(11) NOT NULL AUTO_INCREMENT,
  `protocol_id` int(11) DEFAULT NULL,
  `parent_id` int(11) DEFAULT NULL,
  PRIMARY KEY (`child_id`)
) ENGINE=InnoDB AUTO_INCREMENT=9 DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `child_protocol`
--

LOCK TABLES `child_protocol` WRITE;
/*!40000 ALTER TABLE `child_protocol` DISABLE KEYS */;
/*!40000 ALTER TABLE `child_protocol` ENABLE KEYS */;
UNLOCK TABLES;
/*!40103 SET TIME_ZONE=@OLD_TIME_ZONE */;

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;

-- Dump completed on 2014-08-14 16:48:54
