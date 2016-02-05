DROP TABLE IF EXISTS `counseling_question`;
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
);

DROP TABLE IF EXISTS `counseling_answer`;
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
);
