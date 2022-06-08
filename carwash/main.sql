CREATE TABLE IF NOT EXISTS `owned_carwash` (
	`owner` VARCHAR(46) NULL DEFAULT NULL COLLATE 'utf8mb4_unicode_ci',
	`price` INT(11) NOT NULL DEFAULT '300',
	`location` VARCHAR(20) NOT NULL COLLATE 'utf8mb4_unicode_ci',
	`balance` INT(11) NOT NULL DEFAULT '0',
	`buyprice` INT(11) NOT NULL DEFAULT '100000',
	PRIMARY KEY (`location`) USING BTREE
)
COLLATE='utf8mb4_unicode_ci'
ENGINE=InnoDB
;

--To add more carwash places you have to add one in the database and in the config
INSERT INTO `owned_carwash` (`owner`, `price`, `location`, `balance`) VALUES ('0', '300', '1', '0', '100000);
INSERT INTO `owned_carwash` (`owner`, `price`, `location`, `balance`) VALUES ('0', '300', '2', '0', '100000);
INSERT INTO `owned_carwash` (`owner`, `price`, `location`, `balance`) VALUES ('0', '300', '3', '0', '100000');


