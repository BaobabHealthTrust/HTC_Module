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
-- Table structure for table `privilege`
--

DROP TABLE IF EXISTS `privilege`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `privilege` (
  `privilege` varchar(50) NOT NULL DEFAULT '',
  `description` varchar(250) NOT NULL DEFAULT '',
  `uuid` char(38) DEFAULT NULL,
  PRIMARY KEY (`privilege`),
  UNIQUE KEY `privilege_uuid_index` (`uuid`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `privilege`
--

LOCK TABLES `privilege` WRITE;
/*!40000 ALTER TABLE `privilege` DISABLE KEYS */;
INSERT INTO `privilege` VALUES ('Add Allergies','Add allergies','886d2620-4a9b-40aa-a85f-b2330f4e4ecd'),('Add Cohorts','Able to add a cohort to the system','3d1c9dd1-0754-11e4-94f6-30f9edcc2607'),('Add Concept Proposals','Able to add concept proposals to the system','3d1ca0bc-0754-11e4-94f6-30f9edcc2607'),('Add Encounters','Able to add patient encounters','3d1ca1d2-0754-11e4-94f6-30f9edcc2607'),('Add HL7 Inbound Archive','Able to add an HL7 archive item','56bca5eb-9a04-406b-b0bc-03377f7f57af'),('Add HL7 Inbound Exception','Able to add an HL7 error item','22043d56-b139-4323-a828-07c6eb279de8'),('Add HL7 Inbound Queue','Able to add an HL7 Queue item','4aa8f5a0-e541-44ab-b140-75cd0794b433'),('Add HL7 Source','Able to add an HL7 Source','ece9811d-7c26-4803-950a-5964da2f6a30'),('Add Observations','Able to add patient observations','3d1ca2c1-0754-11e4-94f6-30f9edcc2607'),('Add Orders','Able to add orders','3d1ca3a9-0754-11e4-94f6-30f9edcc2607'),('Add Patient Identifiers','Able to add patient identifiers','3d1ca48d-0754-11e4-94f6-30f9edcc2607'),('Add Patient Programs','Able to add patients to programs','3d1ca586-0754-11e4-94f6-30f9edcc2607'),('Add Patients','Able to add patients','3d1ca678-0754-11e4-94f6-30f9edcc2607'),('Add People','Able to add person objects','3d1ca750-0754-11e4-94f6-30f9edcc2607'),('Add Problems','Add problems','6ae2429b-156c-4b22-b4ed-300afa78c0e9'),('Add Relationships','Able to add relationships','3d1ca7f8-0754-11e4-94f6-30f9edcc2607'),('Add Report Objects','Able to add report objects','3d1ca89e-0754-11e4-94f6-30f9edcc2607'),('Add Reports','Able to add reports','3d1ca93e-0754-11e4-94f6-30f9edcc2607'),('Add Users','Able to add users to OpenMRS','3d1ca9d5-0754-11e4-94f6-30f9edcc2607'),('Add Visits','Able to add visits','9c9b886b-ff67-48da-8941-e37ccbe19cb8'),('Configure Visits','Able to choose encounter visit handler and enable/disable encounter visits','ae6645d6-15e1-4f47-88e7-021c4b66c2ea'),('Delete Cohorts','Able to add a cohort to the system','3d1caa71-0754-11e4-94f6-30f9edcc2607'),('Delete Concept Proposals','Able to delete concept proposals from the system','3d1cab0d-0754-11e4-94f6-30f9edcc2607'),('Delete Encounters','Able to delete patient encounters','3d1cabb3-0754-11e4-94f6-30f9edcc2607'),('Delete HL7 Inbound Archive','Able to delete/retire an HL7 archive item','8dd1627b-9046-43ad-823d-86a887988eee'),('Delete HL7 Inbound Exception','Able to delete an HL7 archive item','3378bd9a-790a-4a96-8265-1adf1d9aec19'),('Delete HL7 Inbound Queue','Able to delete an HL7 Queue item','b246ef14-18b4-4249-86bb-da98db24769f'),('Delete Observations','Able to delete patient observations','3d1cac50-0754-11e4-94f6-30f9edcc2607'),('Delete Orders','Able to delete orders','3d1cacf0-0754-11e4-94f6-30f9edcc2607'),('Delete Patient Identifiers','Able to delete patient identifiers','3d1cad8e-0754-11e4-94f6-30f9edcc2607'),('Delete Patient Programs','Able to delete patients from programs','3d1cae31-0754-11e4-94f6-30f9edcc2607'),('Delete Patients','Able to delete patients','3d1caed8-0754-11e4-94f6-30f9edcc2607'),('Delete People','Able to delete objects','3d1caf7d-0754-11e4-94f6-30f9edcc2607'),('Delete Relationships','Able to delete relationships','3d1cb022-0754-11e4-94f6-30f9edcc2607'),('Delete Report Objects','Able to delete report objects','3d1cb0c4-0754-11e4-94f6-30f9edcc2607'),('Delete Reports','Able to delete reports','3d1cb163-0754-11e4-94f6-30f9edcc2607'),('Delete Users','Able to delete users in OpenMRS','3d1cb203-0754-11e4-94f6-30f9edcc2607'),('Delete Visits','Able to delete visits','d596e590-f124-4b89-886f-cd63b34bfc3d'),('Edit Allergies','Able to edit allergies','804d77ff-fb57-4329-819d-4088ca8caa6d'),('Edit Cohorts','Able to add a cohort to the system','3d1cb2a0-0754-11e4-94f6-30f9edcc2607'),('Edit Concept Proposals','Able to edit concept proposals in the system','3d1cb33c-0754-11e4-94f6-30f9edcc2607'),('Edit Encounters','Able to edit patient encounters','3d1cb3d9-0754-11e4-94f6-30f9edcc2607'),('Edit Observations','Able to edit patient observations','3d1cb475-0754-11e4-94f6-30f9edcc2607'),('Edit Orders','Able to edit orders','3d1cb510-0754-11e4-94f6-30f9edcc2607'),('Edit Patient Identifiers','Able to edit patient identifiers','3d1cb5a9-0754-11e4-94f6-30f9edcc2607'),('Edit Patient Programs','Able to edit patients in programs','3d1cb64d-0754-11e4-94f6-30f9edcc2607'),('Edit Patients','Able to edit patients','3d1cb6f0-0754-11e4-94f6-30f9edcc2607'),('Edit People','Able to edit person objects','3d1cb792-0754-11e4-94f6-30f9edcc2607'),('Edit Problems','Able to edit problems','9fd5b56b-fda5-4a23-8f94-a5d045a68e3b'),('Edit Relationships','Able to edit relationships','3d1cb82e-0754-11e4-94f6-30f9edcc2607'),('Edit Report Objects','Able to edit report objects','3d1cb8c8-0754-11e4-94f6-30f9edcc2607'),('Edit Reports','Able to edit reports','3d1cb96a-0754-11e4-94f6-30f9edcc2607'),('Edit User Passwords','Able to change the passwords of users in OpenMRS','3d1cba06-0754-11e4-94f6-30f9edcc2607'),('Edit Users','Able to edit users in OpenMRS','3d1cbaa8-0754-11e4-94f6-30f9edcc2607'),('Edit Visits','Able to edit visits','60681642-cd28-4984-b7dc-1b943dfcff27'),('Form Entry','Allows user to access Form Entry pages/functions','3d1cbb3d-0754-11e4-94f6-30f9edcc2607'),('Manage Address Templates','Able to add/edit/delete address templates','f646b5b1-4734-40cf-a151-79ae7d032163'),('Manage Alerts','Able to add/edit/delete user alerts','3d1cbbd2-0754-11e4-94f6-30f9edcc2607'),('Manage Cohort Definitions','Add/Edit/Remove Cohort Definitions','98c9c1e2-3982-4f16-993b-b2eeef6ab88f'),('Manage Concept Classes','Able to add/edit/retire concept classes','3d1cbc6e-0754-11e4-94f6-30f9edcc2607'),('Manage Concept Datatypes','Able to add/edit/retire concept datatypes','3d1cbd0f-0754-11e4-94f6-30f9edcc2607'),('Manage Concept Map Types','Able to add/edit/retire concept map types','2aa0419d-5196-4315-a387-3a34d618ebf5'),('Manage Concept Name tags','Able to add/edit/delete concept name tags','c5f472d9-89d6-40ce-97c7-38e22ef772d5'),('Manage Concept Reference Terms','Able to add/edit/retire reference terms','ed3c8fbf-b447-4fb2-8499-241a09cf0842'),('Manage Concept Sources','Able to add/edit/delete concept sources','3d1cbdb1-0754-11e4-94f6-30f9edcc2607'),('Manage Concept Stop Words','Able to view/add/remove the concept stop words','f28f4d73-0c62-44c1-b8b9-d72edff99755'),('Manage Concepts','Able to add/edit/delete concept entries','3d1cbe53-0754-11e4-94f6-30f9edcc2607'),('Manage Data Set Definitions','Add/Edit/Remove Data Set Definitions','6fbe6298-72cb-4719-9dea-481ed526dee1'),('Manage Dimension Definitions','Add/Edit/Remove Dimension Definitions','d87484cd-1c97-45db-863e-2d82b3027ed7'),('Manage Encounter Roles','Able to add/edit/retire encounter roles','1cf7e1fd-3029-437c-8253-0adc327702ad'),('Manage Encounter Types','Able to add/edit/delete encounter types','3d1cbef9-0754-11e4-94f6-30f9edcc2607'),('Manage Field Types','Able to add/edit/retire field types','3d1cbf9d-0754-11e4-94f6-30f9edcc2607'),('Manage Flags','Allows user add, edit, and remove flags','3307505b-5f5b-4fae-be32-dd137f7c9648'),('Manage FormEntry XSN','Allows user to upload and edit the xsns stored on the server','3d1cc039-0754-11e4-94f6-30f9edcc2607'),('Manage Forms','Able to add/edit/delete forms','3d1cc0dd-0754-11e4-94f6-30f9edcc2607'),('Manage Global Properties','Able to add/edit global properties','3d1cc17e-0754-11e4-94f6-30f9edcc2607'),('Manage Identifier Types','Able to add/edit/delete patient identifier types','3d1cc226-0754-11e4-94f6-30f9edcc2607'),('Manage Implementation Id','Able to view/add/edit the implementation id for the system','ef6412db-38a8-46c6-88e1-a63d62dacdb0'),('Manage Indicator Definitions','Add/Edit/Remove Indicator Definitions','ef30078a-358e-4a25-966e-9e0b1f7103b3'),('Manage Location Attribute Types','Able to add/edit/retire location attribute types','23abe28f-2fe8-4689-b046-e9969ac170b6'),('Manage Location Tags','Able to add/edit/delete location tags','3be949e6-5cf6-4f34-9dbb-9e94ebace076'),('Manage Locations','Able to add/edit/delete locations','3d1cc2c5-0754-11e4-94f6-30f9edcc2607'),('Manage Modules','Able to add/remove modules to the system','3d1cc361-0754-11e4-94f6-30f9edcc2607'),('Manage Order Types','Able to add/edit/retire order types','3d1cc3fe-0754-11e4-94f6-30f9edcc2607'),('Manage Person Attribute Types','Able to add/edit/delete person attribute types','3d1cc4a1-0754-11e4-94f6-30f9edcc2607'),('Manage Privileges','Able to add/edit/delete privileges','3d1cc546-0754-11e4-94f6-30f9edcc2607'),('Manage Programs','Able to add/view/delete patient programs','3d1cc5e5-0754-11e4-94f6-30f9edcc2607'),('Manage Providers','Able to edit Provider','a0ba69c1-8ae1-4c74-8846-e7e79bd8a691'),('Manage Relationship Types','Able to add/edit/retire relationship types','3d1cc68a-0754-11e4-94f6-30f9edcc2607'),('Manage Relationships','Able to add/edit/delete relationships','3d1cc731-0754-11e4-94f6-30f9edcc2607'),('Manage Report Definitions','Add/Edit/Remove Report Definitions','3ab2e46a-db36-4411-8fae-8e94d62069a6'),('Manage Report Designs','Add/Edit/Remove Report Designs','f6e870f0-f031-466c-a6e7-abc354448659'),('Manage Reports','Base privilege for add/edit/delete reporting definitions. This gives access to the administrative menus, but you need to grant additional privileges to manage each specific type of reporting definition','e84bbc15-070d-453b-af20-36ea6acd607b'),('Manage Roles','Able to add/edit/delete user roles','3d1cc7d4-0754-11e4-94f6-30f9edcc2607'),('Manage Rule Definitions','Allows creation and editing of user-defined rules','901916ae-fc37-49db-a87a-83218bc5bfc1'),('Manage Scheduled Report Tasks','Manage Task Scheduling in Reporting Module','3f98687b-7f46-43ca-9ec8-3385a9fe5e08'),('Manage Scheduler','Able to add/edit/remove scheduled tasks','3d1cc871-0754-11e4-94f6-30f9edcc2607'),('Manage Tokens','Allows registering and removal of tokens','66e1bc99-75c6-48fd-951f-ba595f7be01d'),('Manage Visit Attribute Types','Able to add/edit/retire visit attribute types','836c7450-9a48-4859-8d73-95fd08bec990'),('Manage Visit Types','Able to add/edit/delete visit types','93cfddd8-bd3c-4f5d-b6dd-0867a5716e4b'),('Patient Dashboard - View Demographics Section','Able to view the \'Demographics\' tab on the patient dashboard','3d1cc911-0754-11e4-94f6-30f9edcc2607'),('Patient Dashboard - View Encounters Section','Able to view the \'Encounters\' tab on the patient dashboard','3d1cc9fd-0754-11e4-94f6-30f9edcc2607'),('Patient Dashboard - View Forms Section','Allows user to view the Forms tab on the patient dashboard','3d1ccbb3-0754-11e4-94f6-30f9edcc2607'),('Patient Dashboard - View Graphs Section','Able to view the \'Graphs\' tab on the patient dashboard','3d1ccc46-0754-11e4-94f6-30f9edcc2607'),('Patient Dashboard - View Overview Section','Able to view the \'Overview\' tab on the patient dashboard','3d1cccfe-0754-11e4-94f6-30f9edcc2607'),('Patient Dashboard - View Patient Summary','Able to view the \'Summary\' tab on the patient dashboard','3d1ccd68-0754-11e4-94f6-30f9edcc2607'),('Patient Dashboard - View Regimen Section','Able to view the \'Regimen\' tab on the patient dashboard','3d1ccdc0-0754-11e4-94f6-30f9edcc2607'),('Patient Dashboard - View Visits Section','Able to view the \'Visits\' tab on the patient dashboard','c3f67fa4-b3f3-438b-b95e-3bb4bc333086'),('Purge Field Types','Able to purge field types','3d1cce1e-0754-11e4-94f6-30f9edcc2607'),('Remove Allergies','Remove allergies','f4902a2f-06d1-45d4-ac41-8865d0a72294'),('Remove Problems','Remove problems','aa21eb32-30d6-4f21-9bb2-7257fe21e659'),('Test Flags','Allows the user to test a flag, or set of flags, against a Patient set','d15f0d65-23a6-4820-b987-5e70b2ddcaba'),('Update HL7 Inbound Archive','Able to update an HL7 archive item','6725e8d7-bcf9-4bb3-9999-ecac4fbaa79f'),('Update HL7 Inbound Exception','Able to update an HL7 archive item','6bcf0555-dbec-4499-8741-e2199904da14'),('Update HL7 Inbound Queue','Able to update an HL7 Queue item','87c85c81-16c7-46dd-b323-e8bb7dc1e8b7'),('Update HL7 Source','Able to update an HL7 Source','69f5b813-43ec-47ec-abb6-d9c13834754b'),('Upload XSN','Allows user to upload/overwrite the XSNs defined for forms','3d1cce71-0754-11e4-94f6-30f9edcc2607'),('View Administration Functions','Able to view the \'Administration\' link in the navigation bar','3d1ccebc-0754-11e4-94f6-30f9edcc2607'),('View Allergies','Able to view allergies in OpenMRS','3d1ccf0b-0754-11e4-94f6-30f9edcc2607'),('View Concept Classes','Able to view concept classes','3d1cd081-0754-11e4-94f6-30f9edcc2607'),('View Concept Datatypes','Able to view concept datatypes','3d1cd0d7-0754-11e4-94f6-30f9edcc2607'),('View Concept Map Types','Able to view concept map types','68443b46-53fb-462b-84f8-f2e760c41e87'),('View Concept Proposals','Able to view concept proposals to the system','3d1cd129-0754-11e4-94f6-30f9edcc2607'),('View Concept Reference Terms','Able to view concept reference terms','347fefd1-829f-4c82-bc15-b319c3e264da'),('View Concept Sources','Able to view concept sources','3d1cd17a-0754-11e4-94f6-30f9edcc2607'),('View Concepts','Able to view concept entries','3d1cd1c7-0754-11e4-94f6-30f9edcc2607'),('View Data Entry Statistics','Able to view data entry statistics from the admin screen','3d1cd211-0754-11e4-94f6-30f9edcc2607'),('View Database Changes','Able to view database changes from the admin screen','2b6177f2-2a2a-4922-af32-f8e764952605'),('View Encounter Roles','Able to view encounter roles','98f48eab-9d6e-4fb3-a387-b1d83acfb1e5'),('View Encounter Types','Able to view encounter types','3d1cd260-0754-11e4-94f6-30f9edcc2607'),('View Encounters','Able to view patient encounters','3d1cd2ac-0754-11e4-94f6-30f9edcc2607'),('View Field Types','Able to view field types','3d1cd2f9-0754-11e4-94f6-30f9edcc2607'),('View Forms','Able to view forms','3d1cd343-0754-11e4-94f6-30f9edcc2607'),('View Global Properties','Able to view global properties on the administration screen','3d1cd38f-0754-11e4-94f6-30f9edcc2607'),('View HL7 Inbound Archive','Able to view an HL7 archive item','d7e904bf-28f9-4e03-89cf-25635334cc85'),('View HL7 Inbound Exception','Able to view an HL7 archive item','a22e5d89-b924-455d-be6f-5c3149446c45'),('View HL7 Inbound Queue','Able to view an HL7 Queue item','32d623f2-5ef3-4b08-8f52-0ab66dc7267e'),('View HL7 Source','Able to view an HL7 Source','a5ded122-0a22-46db-8a20-3702a11d0e6f'),('View Identifier Types','Able to view patient identifier types','3d1cd3de-0754-11e4-94f6-30f9edcc2607'),('View Location Attribute Types','Able to view location attribute types','cb647952-e671-48bf-951e-4cbfa43e567d'),('View Locations','Able to view locations','3d1cd429-0754-11e4-94f6-30f9edcc2607'),('View Navigation Menu','Ability to see the navigation menu','3d1cd474-0754-11e4-94f6-30f9edcc2607'),('View Observations','Able to view patient observations','3d1cd4c0-0754-11e4-94f6-30f9edcc2607'),('View Order Types','Able to view order types','3d1cd510-0754-11e4-94f6-30f9edcc2607'),('View Orders','Able to view orders','3d1cd55e-0754-11e4-94f6-30f9edcc2607'),('View Patient Cohorts','Able to view patient cohorts','3d1cd5a9-0754-11e4-94f6-30f9edcc2607'),('View Patient Identifiers','Able to view patient identifiers','3d1cd5f9-0754-11e4-94f6-30f9edcc2607'),('View Patient Programs','Able to see which programs that patients are in','3d1cd649-0754-11e4-94f6-30f9edcc2607'),('View Patients','Able to view patients','3d1cd697-0754-11e4-94f6-30f9edcc2607'),('View People','Able to view person objects','3d1cd6e3-0754-11e4-94f6-30f9edcc2607'),('View Person Attribute Types','Able to view person attribute types','3d1cd72f-0754-11e4-94f6-30f9edcc2607'),('View Privileges','Able to view user privileges','3d1cd84f-0754-11e4-94f6-30f9edcc2607'),('View Problems','Able to view problems in OpenMRS','3d1cd8f4-0754-11e4-94f6-30f9edcc2607'),('View Programs','Able to view patient programs','3d1cd996-0754-11e4-94f6-30f9edcc2607'),('View Providers','Able to view Provider','55a3536a-c4a0-4376-a840-7b4496975cc2'),('View Relationship Types','Able to view relationship types','3d1cda36-0754-11e4-94f6-30f9edcc2607'),('View Relationships','Able to view relationships','3d1cdadd-0754-11e4-94f6-30f9edcc2607'),('View Report Objects','Able to view report objects','3d1cdb7e-0754-11e4-94f6-30f9edcc2607'),('View Reports','Able to view reports','3d1cdc1f-0754-11e4-94f6-30f9edcc2607'),('View Roles','Able to view user roles','3d1cdcc4-0754-11e4-94f6-30f9edcc2607'),('View Rule Definitions','Allows viewing of user-defined rules. (This privilege is not necessary to run rules under normal usage.)','ac34918d-8883-45e9-a9ea-da10d8e7e9e9'),('View Unpublished Forms','Able to view and fill out unpublished forms','3d1cdd64-0754-11e4-94f6-30f9edcc2607'),('View Users','Able to view users in OpenMRS','3d1cde12-0754-11e4-94f6-30f9edcc2607'),('View Visit Attribute Types','Able to view visit attribute types','6ca003b9-3355-414e-8140-2f18086b835c'),('View Visit Types','Able to view visit types','a6f4b42d-08a7-4421-89ed-9658a1d0323e'),('View Visits','Able to view visits','8c5942e1-38a7-4fac-a177-f931853b43b7');
/*!40000 ALTER TABLE `privilege` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `role`
--

DROP TABLE IF EXISTS `role`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `role` (
  `role` varchar(50) NOT NULL DEFAULT '',
  `description` varchar(255) NOT NULL DEFAULT '',
  `uuid` char(38) DEFAULT NULL,
  PRIMARY KEY (`role`),
  UNIQUE KEY `role_uuid_index` (`uuid`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `role`
--

LOCK TABLES `role` WRITE;
/*!40000 ALTER TABLE `role` DISABLE KEYS */;
INSERT INTO `role` VALUES ('Anonymous','Privileges for non-authenticated users.','774b2af3-6437-4e5a-a310-547554c7c65c'),('Authenticated','Privileges gained once authentication has been established.','f7fd42ef-880e-40c5-972d-e4ae7c990de2'),('Provider','All users with the \'Provider\' role will appear as options in the default Infopath ','8d94f280-c2cc-11de-8d13-0010c6dffd0f'),('System Developer','Developers of the OpenMRS .. have additional access to change fundamental structure of the database model.','8d94f852-c2cc-11de-8d13-0010c6dffd0f');
/*!40000 ALTER TABLE `role` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `role_privilege`
--

DROP TABLE IF EXISTS `role_privilege`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `role_privilege` (
  `role` varchar(50) NOT NULL DEFAULT '',
  `privilege` varchar(50) NOT NULL DEFAULT '',
  PRIMARY KEY (`privilege`,`role`),
  KEY `role_privilege_to_role` (`role`),
  CONSTRAINT `role_privilege_to_role` FOREIGN KEY (`role`) REFERENCES `role` (`role`),
  CONSTRAINT `privilege_definitons` FOREIGN KEY (`privilege`) REFERENCES `privilege` (`privilege`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `role_privilege`
--

LOCK TABLES `role_privilege` WRITE;
/*!40000 ALTER TABLE `role_privilege` DISABLE KEYS */;
INSERT INTO `role_privilege` VALUES ('Authenticated','View Concept Classes'),('Authenticated','View Concept Datatypes'),('Authenticated','View Encounter Types'),('Authenticated','View Field Types'),('Authenticated','View Global Properties'),('Authenticated','View Identifier Types'),('Authenticated','View Locations'),('Authenticated','View Order Types'),('Authenticated','View Person Attribute Types'),('Authenticated','View Privileges'),('Authenticated','View Relationship Types'),('Authenticated','View Relationships'),('Authenticated','View Roles');
/*!40000 ALTER TABLE `role_privilege` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `role_role`
--

DROP TABLE IF EXISTS `role_role`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `role_role` (
  `parent_role` varchar(50) NOT NULL DEFAULT '',
  `child_role` varchar(50) NOT NULL DEFAULT '',
  PRIMARY KEY (`parent_role`,`child_role`),
  KEY `inherited_role` (`child_role`),
  CONSTRAINT `parent_role` FOREIGN KEY (`parent_role`) REFERENCES `role` (`role`),
  CONSTRAINT `inherited_role` FOREIGN KEY (`child_role`) REFERENCES `role` (`role`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `role_role`
--

LOCK TABLES `role_role` WRITE;
/*!40000 ALTER TABLE `role_role` DISABLE KEYS */;
/*!40000 ALTER TABLE `role_role` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `users`
--

DROP TABLE IF EXISTS `users`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `users` (
  `user_id` int(11) NOT NULL AUTO_INCREMENT,
  `system_id` varchar(50) NOT NULL DEFAULT '',
  `username` varchar(50) DEFAULT NULL,
  `password` varchar(128) DEFAULT NULL,
  `salt` varchar(128) DEFAULT NULL,
  `secret_question` varchar(255) DEFAULT NULL,
  `secret_answer` varchar(255) DEFAULT NULL,
  `creator` int(11) NOT NULL DEFAULT '0',
  `date_created` datetime NOT NULL DEFAULT '0002-11-30 00:00:00',
  `changed_by` int(11) DEFAULT NULL,
  `date_changed` datetime DEFAULT NULL,
  `person_id` int(11) NOT NULL,
  `retired` tinyint(1) NOT NULL DEFAULT '0',
  `retired_by` int(11) DEFAULT NULL,
  `date_retired` datetime DEFAULT NULL,
  `retire_reason` varchar(255) DEFAULT NULL,
  `uuid` char(38) NOT NULL,
  PRIMARY KEY (`user_id`),
  KEY `user_who_changed_user` (`changed_by`),
  KEY `user_creator` (`creator`),
  KEY `user_who_retired_this_user` (`retired_by`),
  KEY `person_id_for_user` (`person_id`),
  CONSTRAINT `person_id_for_user` FOREIGN KEY (`person_id`) REFERENCES `person` (`person_id`),
  CONSTRAINT `user_creator` FOREIGN KEY (`creator`) REFERENCES `users` (`user_id`),
  CONSTRAINT `user_who_changed_user` FOREIGN KEY (`changed_by`) REFERENCES `users` (`user_id`),
  CONSTRAINT `user_who_retired_this_user` FOREIGN KEY (`retired_by`) REFERENCES `users` (`user_id`)
) ENGINE=InnoDB AUTO_INCREMENT=3 DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `users`
--

LOCK TABLES `users` WRITE;
/*!40000 ALTER TABLE `users` DISABLE KEYS */;
INSERT INTO `users` VALUES (1,'admin','','b1ffe3dc201139e1b7ac3b0da2fe1f533d7313a62f6dfbc840769bec6d734ef18cd705713a65fd4b9ec498431c8a9346a8660b38711d73375bb41101440acd0f','cc53e2fcc86215fbb017cfaf567911e0bd1c19d0952bd2163b25e7fb51fff6e231affa08bbc58da600dc1192abebda799a92ddbe9acb4d92b8ff87af7ef2d03a',NULL,NULL,1,'2005-01-01 00:00:00',1,'2014-07-09 12:34:07',1,0,NULL,NULL,NULL,'57c48677-0754-11e4-94f6-30f9edcc2607'),(2,'daemon','daemon',NULL,NULL,NULL,NULL,1,'2010-04-26 13:25:00',NULL,NULL,1,0,NULL,NULL,NULL,'A4F30A1B-5EB9-11DF-A648-37A07F9C90FB');
/*!40000 ALTER TABLE `users` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `user_property`
--

DROP TABLE IF EXISTS `user_property`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `user_property` (
  `user_id` int(11) NOT NULL DEFAULT '0',
  `property` varchar(100) NOT NULL DEFAULT '',
  `property_value` varchar(255) NOT NULL DEFAULT '',
  PRIMARY KEY (`user_id`,`property`),
  CONSTRAINT `user_property_to_users` FOREIGN KEY (`user_id`) REFERENCES `users` (`user_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `user_property`
--

LOCK TABLES `user_property` WRITE;
/*!40000 ALTER TABLE `user_property` DISABLE KEYS */;
INSERT INTO `user_property` VALUES (1,'defaultLocale','en'),(1,'loginAttempts','1');
/*!40000 ALTER TABLE `user_property` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `user_role`
--

DROP TABLE IF EXISTS `user_role`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `user_role` (
  `user_id` int(11) NOT NULL DEFAULT '0',
  `role` varchar(50) NOT NULL DEFAULT '',
  PRIMARY KEY (`role`,`user_id`),
  KEY `user_role_to_users` (`user_id`),
  CONSTRAINT `user_role_to_users` FOREIGN KEY (`user_id`) REFERENCES `users` (`user_id`),
  CONSTRAINT `role_definitions` FOREIGN KEY (`role`) REFERENCES `role` (`role`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `user_role`
--

LOCK TABLES `user_role` WRITE;
/*!40000 ALTER TABLE `user_role` DISABLE KEYS */;
INSERT INTO `user_role` VALUES (1,'Provider'),(1,'System Developer');
/*!40000 ALTER TABLE `user_role` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `field`
--

DROP TABLE IF EXISTS `field`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `field` (
  `field_id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(255) NOT NULL DEFAULT '',
  `description` text,
  `field_type` int(11) DEFAULT NULL,
  `concept_id` int(11) DEFAULT NULL,
  `table_name` varchar(50) DEFAULT NULL,
  `attribute_name` varchar(50) DEFAULT NULL,
  `default_value` text,
  `select_multiple` tinyint(1) NOT NULL DEFAULT '0',
  `creator` int(11) NOT NULL DEFAULT '0',
  `date_created` datetime NOT NULL DEFAULT '0002-11-30 00:00:00',
  `changed_by` int(11) DEFAULT NULL,
  `date_changed` datetime DEFAULT NULL,
  `retired` tinyint(1) NOT NULL DEFAULT '0',
  `retired_by` int(11) DEFAULT NULL,
  `date_retired` datetime DEFAULT NULL,
  `retire_reason` varchar(255) DEFAULT NULL,
  `uuid` char(38) DEFAULT NULL,
  PRIMARY KEY (`field_id`),
  UNIQUE KEY `field_uuid_index` (`uuid`),
  KEY `field_retired_status` (`retired`),
  KEY `user_who_changed_field` (`changed_by`),
  KEY `concept_for_field` (`concept_id`),
  KEY `user_who_created_field` (`creator`),
  KEY `type_of_field` (`field_type`),
  KEY `user_who_retired_field` (`retired_by`),
  CONSTRAINT `user_who_retired_field` FOREIGN KEY (`retired_by`) REFERENCES `users` (`user_id`),
  CONSTRAINT `concept_for_field` FOREIGN KEY (`concept_id`) REFERENCES `concept` (`concept_id`),
  CONSTRAINT `type_of_field` FOREIGN KEY (`field_type`) REFERENCES `field_type` (`field_type_id`),
  CONSTRAINT `user_who_changed_field` FOREIGN KEY (`changed_by`) REFERENCES `users` (`user_id`),
  CONSTRAINT `user_who_created_field` FOREIGN KEY (`creator`) REFERENCES `users` (`user_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `field`
--

LOCK TABLES `field` WRITE;
/*!40000 ALTER TABLE `field` DISABLE KEYS */;
/*!40000 ALTER TABLE `field` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `field_type`
--

DROP TABLE IF EXISTS `field_type`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `field_type` (
  `field_type_id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(50) DEFAULT NULL,
  `description` text,
  `is_set` tinyint(1) NOT NULL DEFAULT '0',
  `creator` int(11) NOT NULL DEFAULT '0',
  `date_created` datetime NOT NULL DEFAULT '0002-11-30 00:00:00',
  `uuid` char(38) DEFAULT NULL,
  PRIMARY KEY (`field_type_id`),
  UNIQUE KEY `field_type_uuid_index` (`uuid`),
  KEY `user_who_created_field_type` (`creator`),
  CONSTRAINT `user_who_created_field_type` FOREIGN KEY (`creator`) REFERENCES `users` (`user_id`)
) ENGINE=InnoDB AUTO_INCREMENT=6 DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `field_type`
--

LOCK TABLES `field_type` WRITE;
/*!40000 ALTER TABLE `field_type` DISABLE KEYS */;
INSERT INTO `field_type` VALUES (1,'Concept','',0,1,'2005-02-22 00:00:00','8d5e7d7c-c2cc-11de-8d13-0010c6dffd0f'),(2,'Database element','',0,1,'2005-02-22 00:00:00','8d5e8196-c2cc-11de-8d13-0010c6dffd0f'),(3,'Set of Concepts','',1,1,'2005-02-22 00:00:00','8d5e836c-c2cc-11de-8d13-0010c6dffd0f'),(4,'Miscellaneous Set','',1,1,'2005-02-22 00:00:00','8d5e852e-c2cc-11de-8d13-0010c6dffd0f'),(5,'Section','',1,1,'2005-02-22 00:00:00','8d5e86fa-c2cc-11de-8d13-0010c6dffd0f');
/*!40000 ALTER TABLE `field_type` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `field_answer`
--

DROP TABLE IF EXISTS `field_answer`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `field_answer` (
  `field_id` int(11) NOT NULL DEFAULT '0',
  `answer_id` int(11) NOT NULL DEFAULT '0',
  `creator` int(11) NOT NULL DEFAULT '0',
  `date_created` datetime NOT NULL DEFAULT '0002-11-30 00:00:00',
  `uuid` char(38) DEFAULT NULL,
  PRIMARY KEY (`field_id`,`answer_id`),
  UNIQUE KEY `field_answer_uuid_index` (`uuid`),
  KEY `field_answer_concept` (`answer_id`),
  KEY `user_who_created_field_answer` (`creator`),
  CONSTRAINT `answers_for_field` FOREIGN KEY (`field_id`) REFERENCES `field` (`field_id`),
  CONSTRAINT `field_answer_concept` FOREIGN KEY (`answer_id`) REFERENCES `concept` (`concept_id`),
  CONSTRAINT `user_who_created_field_answer` FOREIGN KEY (`creator`) REFERENCES `users` (`user_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `field_answer`
--

LOCK TABLES `field_answer` WRITE;
/*!40000 ALTER TABLE `field_answer` DISABLE KEYS */;
/*!40000 ALTER TABLE `field_answer` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `form`
--

DROP TABLE IF EXISTS `form`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `form` (
  `form_id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(255) NOT NULL DEFAULT '',
  `version` varchar(50) NOT NULL DEFAULT '',
  `build` int(11) DEFAULT NULL,
  `published` tinyint(1) NOT NULL DEFAULT '0',
  `xslt` text,
  `template` text,
  `description` text,
  `encounter_type` int(11) DEFAULT NULL,
  `creator` int(11) NOT NULL DEFAULT '0',
  `date_created` datetime NOT NULL DEFAULT '0002-11-30 00:00:00',
  `changed_by` int(11) DEFAULT NULL,
  `date_changed` datetime DEFAULT NULL,
  `retired` tinyint(1) NOT NULL DEFAULT '0',
  `retired_by` int(11) DEFAULT NULL,
  `date_retired` datetime DEFAULT NULL,
  `retired_reason` varchar(255) DEFAULT NULL,
  `uuid` char(38) DEFAULT NULL,
  PRIMARY KEY (`form_id`),
  UNIQUE KEY `form_uuid_index` (`uuid`),
  KEY `form_published_index` (`published`),
  KEY `form_retired_index` (`retired`),
  KEY `form_published_and_retired_index` (`published`,`retired`),
  KEY `user_who_last_changed_form` (`changed_by`),
  KEY `user_who_created_form` (`creator`),
  KEY `form_encounter_type` (`encounter_type`),
  KEY `user_who_retired_form` (`retired_by`),
  CONSTRAINT `user_who_retired_form` FOREIGN KEY (`retired_by`) REFERENCES `users` (`user_id`),
  CONSTRAINT `form_encounter_type` FOREIGN KEY (`encounter_type`) REFERENCES `encounter_type` (`encounter_type_id`),
  CONSTRAINT `user_who_created_form` FOREIGN KEY (`creator`) REFERENCES `users` (`user_id`),
  CONSTRAINT `user_who_last_changed_form` FOREIGN KEY (`changed_by`) REFERENCES `users` (`user_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `form`
--

LOCK TABLES `form` WRITE;
/*!40000 ALTER TABLE `form` DISABLE KEYS */;
/*!40000 ALTER TABLE `form` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `form_field`
--

DROP TABLE IF EXISTS `form_field`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `form_field` (
  `form_field_id` int(11) NOT NULL AUTO_INCREMENT,
  `form_id` int(11) NOT NULL DEFAULT '0',
  `field_id` int(11) NOT NULL DEFAULT '0',
  `field_number` int(11) DEFAULT NULL,
  `field_part` varchar(5) DEFAULT NULL,
  `page_number` int(11) DEFAULT NULL,
  `parent_form_field` int(11) DEFAULT NULL,
  `min_occurs` int(11) DEFAULT NULL,
  `max_occurs` int(11) DEFAULT NULL,
  `required` tinyint(1) NOT NULL DEFAULT '0',
  `changed_by` int(11) DEFAULT NULL,
  `date_changed` datetime DEFAULT NULL,
  `creator` int(11) NOT NULL DEFAULT '0',
  `date_created` datetime NOT NULL DEFAULT '0002-11-30 00:00:00',
  `sort_weight` double DEFAULT NULL,
  `uuid` char(38) DEFAULT NULL,
  PRIMARY KEY (`form_field_id`),
  UNIQUE KEY `form_field_uuid_index` (`uuid`),
  KEY `user_who_last_changed_form_field` (`changed_by`),
  KEY `user_who_created_form_field` (`creator`),
  KEY `field_within_form` (`field_id`),
  KEY `form_containing_field` (`form_id`),
  KEY `form_field_hierarchy` (`parent_form_field`),
  CONSTRAINT `form_field_hierarchy` FOREIGN KEY (`parent_form_field`) REFERENCES `form_field` (`form_field_id`),
  CONSTRAINT `field_within_form` FOREIGN KEY (`field_id`) REFERENCES `field` (`field_id`),
  CONSTRAINT `form_containing_field` FOREIGN KEY (`form_id`) REFERENCES `form` (`form_id`),
  CONSTRAINT `user_who_created_form_field` FOREIGN KEY (`creator`) REFERENCES `users` (`user_id`),
  CONSTRAINT `user_who_last_changed_form_field` FOREIGN KEY (`changed_by`) REFERENCES `users` (`user_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `form_field`
--

LOCK TABLES `form_field` WRITE;
/*!40000 ALTER TABLE `form_field` DISABLE KEYS */;
/*!40000 ALTER TABLE `form_field` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `form_resource`
--

DROP TABLE IF EXISTS `form_resource`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `form_resource` (
  `form_resource_id` int(11) NOT NULL AUTO_INCREMENT,
  `form_id` int(11) NOT NULL,
  `name` varchar(255) NOT NULL,
  `value_reference` text NOT NULL,
  `datatype` varchar(255) DEFAULT NULL,
  `datatype_config` text,
  `preferred_handler` varchar(255) DEFAULT NULL,
  `handler_config` text,
  `uuid` char(38) NOT NULL,
  PRIMARY KEY (`form_resource_id`),
  UNIQUE KEY `uuid` (`uuid`),
  UNIQUE KEY `unique_form_and_name` (`form_id`,`name`),
  CONSTRAINT `form_resource_form_fk` FOREIGN KEY (`form_id`) REFERENCES `form` (`form_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `form_resource`
--

LOCK TABLES `form_resource` WRITE;
/*!40000 ALTER TABLE `form_resource` DISABLE KEYS */;
/*!40000 ALTER TABLE `form_resource` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `obs`
--

DROP TABLE IF EXISTS `obs`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `obs` (
  `obs_id` int(11) NOT NULL AUTO_INCREMENT,
  `person_id` int(11) NOT NULL,
  `concept_id` int(11) NOT NULL DEFAULT '0',
  `encounter_id` int(11) DEFAULT NULL,
  `order_id` int(11) DEFAULT NULL,
  `obs_datetime` datetime NOT NULL DEFAULT '0002-11-30 00:00:00',
  `location_id` int(11) DEFAULT NULL,
  `obs_group_id` int(11) DEFAULT NULL,
  `accession_number` varchar(255) DEFAULT NULL,
  `value_group_id` int(11) DEFAULT NULL,
  `value_boolean` tinyint(1) DEFAULT NULL,
  `value_coded` int(11) DEFAULT NULL,
  `value_coded_name_id` int(11) DEFAULT NULL,
  `value_drug` int(11) DEFAULT NULL,
  `value_datetime` datetime DEFAULT NULL,
  `value_numeric` double DEFAULT NULL,
  `value_modifier` varchar(2) DEFAULT NULL,
  `value_text` text,
  `value_complex` varchar(255) DEFAULT NULL,
  `comments` varchar(255) DEFAULT NULL,
  `creator` int(11) NOT NULL DEFAULT '0',
  `date_created` datetime NOT NULL DEFAULT '0002-11-30 00:00:00',
  `voided` tinyint(1) NOT NULL DEFAULT '0',
  `voided_by` int(11) DEFAULT NULL,
  `date_voided` datetime DEFAULT NULL,
  `void_reason` varchar(255) DEFAULT NULL,
  `uuid` char(38) DEFAULT NULL,
  `previous_version` int(11) DEFAULT NULL,
  PRIMARY KEY (`obs_id`),
  UNIQUE KEY `obs_uuid_index` (`uuid`),
  KEY `obs_datetime_idx` (`obs_datetime`),
  KEY `obs_concept` (`concept_id`),
  KEY `obs_enterer` (`creator`),
  KEY `encounter_observations` (`encounter_id`),
  KEY `obs_location` (`location_id`),
  KEY `obs_grouping_id` (`obs_group_id`),
  KEY `obs_order` (`order_id`),
  KEY `person_obs` (`person_id`),
  KEY `answer_concept` (`value_coded`),
  KEY `obs_name_of_coded_value` (`value_coded_name_id`),
  KEY `answer_concept_drug` (`value_drug`),
  KEY `user_who_voided_obs` (`voided_by`),
  KEY `previous_version` (`previous_version`),
  CONSTRAINT `previous_version` FOREIGN KEY (`previous_version`) REFERENCES `obs` (`obs_id`),
  CONSTRAINT `answer_concept` FOREIGN KEY (`value_coded`) REFERENCES `concept` (`concept_id`),
  CONSTRAINT `answer_concept_drug` FOREIGN KEY (`value_drug`) REFERENCES `drug` (`drug_id`),
  CONSTRAINT `encounter_observations` FOREIGN KEY (`encounter_id`) REFERENCES `encounter` (`encounter_id`),
  CONSTRAINT `obs_concept` FOREIGN KEY (`concept_id`) REFERENCES `concept` (`concept_id`),
  CONSTRAINT `obs_enterer` FOREIGN KEY (`creator`) REFERENCES `users` (`user_id`),
  CONSTRAINT `obs_grouping_id` FOREIGN KEY (`obs_group_id`) REFERENCES `obs` (`obs_id`),
  CONSTRAINT `obs_location` FOREIGN KEY (`location_id`) REFERENCES `location` (`location_id`),
  CONSTRAINT `obs_name_of_coded_value` FOREIGN KEY (`value_coded_name_id`) REFERENCES `concept_name` (`concept_name_id`),
  CONSTRAINT `obs_order` FOREIGN KEY (`order_id`) REFERENCES `orders` (`order_id`),
  CONSTRAINT `person_obs` FOREIGN KEY (`person_id`) REFERENCES `person` (`person_id`) ON UPDATE CASCADE,
  CONSTRAINT `user_who_voided_obs` FOREIGN KEY (`voided_by`) REFERENCES `users` (`user_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `obs`
--

LOCK TABLES `obs` WRITE;
/*!40000 ALTER TABLE `obs` DISABLE KEYS */;
/*!40000 ALTER TABLE `obs` ENABLE KEYS */;
UNLOCK TABLES;
/*!40103 SET TIME_ZONE=@OLD_TIME_ZONE */;

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;

-- Dump completed on 2014-07-09 14:35:12
