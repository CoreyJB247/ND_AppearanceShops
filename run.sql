CREATE TABLE IF NOT EXISTS `nd_characters_outfits` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `character_id` int(11) NOT NULL,
  `name` varchar(50) NOT NULL,
  `appearance` longtext NOT NULL,
  PRIMARY KEY (`id`),
  KEY `character_id` (`character_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;