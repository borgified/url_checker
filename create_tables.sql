CREATE TABLE IF NOT EXISTS `freeprogrammingbooks` (
	`id` int(10) unsigned NOT NULL,
	`url` varchar(2083) NOT NULL,
	`checksum` char(40) NOT NULL,
	`timestamp` timestamp NOT NULL DEFAULT '0000-00-00 00:00:00' ON UPDATE CURRENT_TIMESTAMP,
	PRIMARY KEY (`id`)
	) ENGINE=InnoDB DEFAULT CHARSET=latin1;
