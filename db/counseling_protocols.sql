DROP TABLE IF EXISTS `counseling_question`;
CREATE TABLE `counseling_question` (
  `question_id` int(11)  NOT NULL AUTO_INCREMENT,
  `name` text DEFAULT NULL,
  `description` text DEFAULT NULL,
  `date_created` datetime DEFAULT NULL,
  `date_updated` datetime DEFAULT NULL,
	`retired` int(11) NOT NULL  DEFAULT '0',
  `creator` int(11) NOT NULL  REFERENCES users (user_id),
   PRIMARY KEY (`question_id`)
);

DROP TABLE IF EXISTS `counseling_answer`;
CREATE TABLE `counseling_answer` (
  `answer_id` int(11) NOT NULL AUTO_INCREMENT,
  `question_id` int(11)  REFERENCES counseling_question (question_id),
  `patient_id` int(11)  REFERENCES patient (patient_id),
	`encounter_id` int(11)  REFERENCES encounter (encounter_id),
	`value_coded` int(11) NOT NULL,
  `date_created` datetime DEFAULT NULL,
  `date_updated` datetime DEFAULT NULL,
  `creator` int(11) DEFAULT NULL  REFERENCES users (user_id),
  `voided` tinyint(1) NOT NULL  DEFAULT '0',
  `voided_by` int(11) DEFAULT NULL,
  PRIMARY KEY (`answer_id`)
);
