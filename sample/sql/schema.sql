-- phpMyAdmin SQL Dump
-- version 4.1.14
-- http://www.phpmyadmin.net
--
-- Host: 127.0.0.1
-- Generation Time: Oct 15, 2014 at 12:02 AM
-- Server version: 5.6.17-log
-- PHP Version: 5.5.12

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
SET time_zone = "+00:00";

--
-- Database: `bts_db`
--

-- --------------------------------------------------------

--
-- Table structure for table `cars`
--

CREATE TABLE IF NOT EXISTS `cars` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `name` varchar(20) NOT NULL,
  `logo` varchar(200) NOT NULL,
  `max_pers` int(10) unsigned NOT NULL,
  `max_luggage` int(10) unsigned NOT NULL,
  `is_lux` int(1) unsigned NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB  DEFAULT CHARSET=utf8 AUTO_INCREMENT=5 ;

-- --------------------------------------------------------

--
-- Table structure for table `car_prices`
--

CREATE TABLE IF NOT EXISTS `car_prices` (
  `port_id` int(10) unsigned NOT NULL,
  `destination_id` int(10) unsigned NOT NULL,
  `car_id` int(10) unsigned NOT NULL,
  `outbound_price` double NOT NULL,
  `return_price` double NOT NULL,
  `late_price` double NOT NULL DEFAULT '0',
  `is_popular` int(1) NOT NULL DEFAULT '0',
  `travel_time_estimate` double NOT NULL DEFAULT '0',
  `travel_distance_estimate` double NOT NULL DEFAULT '0',
  UNIQUE KEY `port_id_3` (`port_id`,`destination_id`,`car_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

-- --------------------------------------------------------

--
-- Table structure for table `cr_cities`
--

CREATE TABLE IF NOT EXISTS `cr_cities` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(225) NOT NULL,
  `country` int(11) NOT NULL,
  PRIMARY KEY (`id`),
  KEY `country` (`country`)
) ENGINE=InnoDB  DEFAULT CHARSET=utf8 AUTO_INCREMENT=2706 ;

-- --------------------------------------------------------

--
-- Table structure for table `cr_countries`
--

CREATE TABLE IF NOT EXISTS `cr_countries` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(225) NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB  DEFAULT CHARSET=utf8 AUTO_INCREMENT=250 ;

-- --------------------------------------------------------

--
-- Table structure for table `cr_iata_codes`
--

CREATE TABLE IF NOT EXISTS `cr_iata_codes` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `city` int(11) NOT NULL,
  `country` int(11) NOT NULL,
  `airport_name` varchar(225) NOT NULL,
  `iata_code` varchar(5) NOT NULL,
  PRIMARY KEY (`id`),
  KEY `city` (`city`,`country`)
) ENGINE=InnoDB  DEFAULT CHARSET=utf8 AUTO_INCREMENT=2706 ;

-- --------------------------------------------------------

--
-- Table structure for table `destinations`
--

CREATE TABLE IF NOT EXISTS `destinations` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(100) NOT NULL,
  `slug` varchar(150) NOT NULL,
  `about` text NOT NULL,
  `country_id` int(11) NOT NULL,
  `country_slug` varchar(150) NOT NULL,
  `code` varchar(5) NOT NULL,
  `photo` varchar(250) NOT NULL,
  `yt_video` varchar(15) NOT NULL,
  `active` int(1) NOT NULL DEFAULT '1',
  PRIMARY KEY (`id`),
  UNIQUE KEY `slug` (`slug`)
) ENGINE=MyISAM  DEFAULT CHARSET=utf8 AUTO_INCREMENT=5 ;

-- --------------------------------------------------------

--
-- Table structure for table `partners`
--

CREATE TABLE IF NOT EXISTS `partners` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(100) NOT NULL,
  `email` varchar(100) NOT NULL,
  `address` varchar(350) NOT NULL,
  `phone` varchar(20) NOT NULL,
  `contact_person` varchar(150) NOT NULL,
  `contact_person_email` varchar(100) NOT NULL,
  `contact_person_phone` varchar(20) NOT NULL,
  PRIMARY KEY (`id`),
  KEY `id` (`id`)
) ENGINE=MyISAM  DEFAULT CHARSET=utf8 AUTO_INCREMENT=4 ;

-- --------------------------------------------------------

--
-- Table structure for table `ports`
--

CREATE TABLE IF NOT EXISTS `ports` (
  `id` int(11) unsigned NOT NULL AUTO_INCREMENT,
  `name` varchar(100) NOT NULL,
  `slug` varchar(150) NOT NULL,
  `about` text NOT NULL,
  `code` varchar(5) NOT NULL,
  `country_id` int(11) NOT NULL,
  `country_slug` varchar(50) NOT NULL,
  `type` enum('airport','seaport') NOT NULL,
  `type_name` varchar(100) NOT NULL,
  `photo` varchar(250) NOT NULL,
  `logo` varchar(250) NOT NULL,
  `address` text NOT NULL,
  `min_price` double NOT NULL DEFAULT '0',
  `partner_id` int(10) unsigned NOT NULL DEFAULT '1',
  `active` int(1) NOT NULL DEFAULT '1',
  PRIMARY KEY (`id`),
  UNIQUE KEY `slug` (`slug`),
  KEY `type` (`type`,`country_id`)
) ENGINE=MyISAM  DEFAULT CHARSET=utf8 AUTO_INCREMENT=4 ;

-- --------------------------------------------------------

--
-- Table structure for table `reviews`
--

CREATE TABLE IF NOT EXISTS `reviews` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `review` text CHARACTER SET utf8 COLLATE utf8_estonian_ci NOT NULL,
  `rating` int(11) NOT NULL DEFAULT '3',
  `review_title` varchar(250) CHARACTER SET utf8 NOT NULL,
  `publish` int(11) NOT NULL DEFAULT '0',
  `date` int(11) NOT NULL,
  `city` varchar(50) CHARACTER SET utf8 NOT NULL,
  `country` varchar(50) CHARACTER SET utf8 NOT NULL,
  `name` varchar(50) CHARACTER SET utf8 NOT NULL,
  `email` varchar(50) CHARACTER SET utf8 NOT NULL,
  PRIMARY KEY (`id`),
  KEY `publish` (`publish`)
) ENGINE=InnoDB  DEFAULT CHARSET=latin1 AUTO_INCREMENT=10 ;

-- --------------------------------------------------------

--
-- Table structure for table `special_requests`
--

CREATE TABLE IF NOT EXISTS `special_requests` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `datetime` int(10) unsigned NOT NULL,
  `contact_firstname` varchar(50) NOT NULL,
  `contact_lastname` varchar(50) NOT NULL,
  `contact_email` varchar(50) NOT NULL,
  `contact_phone` varchar(50) NOT NULL,
  `pass_firstname` varchar(50) NOT NULL,
  `pass_lastname` varchar(50) NOT NULL,
  `pass_email` varchar(50) NOT NULL,
  `pass_phone` varchar(50) NOT NULL,
  `read` int(1) unsigned NOT NULL DEFAULT '0',
  `replied` int(1) NOT NULL DEFAULT '0',
  `processed` int(1) unsigned NOT NULL DEFAULT '0',
  `token` varchar(15) NOT NULL,
  `price` double NOT NULL,
  `paid` int(1) NOT NULL DEFAULT '0',
  `number` varchar(50) NOT NULL,
  `email_sent` int(1) unsigned NOT NULL DEFAULT '0',
  `pay_method` varchar(10) NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `token` (`token`)
) ENGINE=MyISAM  DEFAULT CHARSET=utf8 AUTO_INCREMENT=5 ;

-- --------------------------------------------------------

--
-- Table structure for table `special_requests_journeys`
--

CREATE TABLE IF NOT EXISTS `special_requests_journeys` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `request_id` int(10) unsigned NOT NULL,
  `transfer_type` varchar(50) NOT NULL,
  `transfer_datetime` int(11) NOT NULL,
  `return_datetime` int(11) NOT NULL DEFAULT '0',
  `country` varchar(50) NOT NULL,
  `pickup_city` varchar(100) NOT NULL,
  `pickup_address` text NOT NULL,
  `dropoff_city` varchar(100) NOT NULL,
  `dropoff_address` text NOT NULL,
  `adults` int(10) unsigned NOT NULL DEFAULT '0',
  `children` int(10) unsigned NOT NULL DEFAULT '0',
  `infants` int(10) unsigned NOT NULL DEFAULT '0',
  `other` text NOT NULL,
  `partner_id` int(10) unsigned NOT NULL DEFAULT '0',
  `has_return` int(1) unsigned NOT NULL DEFAULT '0',
  PRIMARY KEY (`id`),
  KEY `request_id` (`request_id`)
) ENGINE=InnoDB  DEFAULT CHARSET=utf8 AUTO_INCREMENT=7 ;

-- --------------------------------------------------------

--
-- Table structure for table `temp_booking`
--

CREATE TABLE IF NOT EXISTS `temp_booking` (
  `token` varchar(15) NOT NULL,
  `data` text NOT NULL,
  `date` int(11) NOT NULL,
  PRIMARY KEY (`token`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;

-- --------------------------------------------------------

--
-- Table structure for table `tours`
--

CREATE TABLE IF NOT EXISTS `tours` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `name` varchar(200) NOT NULL,
  `slug` varchar(250) NOT NULL,
  `about` text NOT NULL,
  `excerpt` varchar(350) NOT NULL,
  `from_1` int(10) unsigned NOT NULL,
  `to_1` int(10) unsigned NOT NULL,
  `from_2` int(10) unsigned NOT NULL,
  `to_2` int(10) unsigned NOT NULL,
  `places` varchar(300) NOT NULL,
  `country` int(10) unsigned NOT NULL DEFAULT '1',
  `meta_title` varchar(200) NOT NULL,
  `meta_keywords` varchar(250) NOT NULL,
  `meta_description` varchar(350) NOT NULL,
  `publish` int(1) NOT NULL DEFAULT '1',
  `price_adult` double NOT NULL,
  `price_kid` double NOT NULL,
  `photo` varchar(300) NOT NULL,
  PRIMARY KEY (`id`),
  KEY `country` (`country`)
) ENGINE=MyISAM  DEFAULT CHARSET=utf8 AUTO_INCREMENT=13 ;

-- --------------------------------------------------------

--
-- Table structure for table `tour_bookings`
--

CREATE TABLE IF NOT EXISTS `tour_bookings` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `number` varchar(50) NOT NULL,
  `first_name` varchar(50) NOT NULL,
  `last_name` varchar(50) NOT NULL,
  `phone` varchar(50) NOT NULL,
  `email` varchar(100) NOT NULL,
  `language` varchar(15) NOT NULL,
  `address` varchar(300) NOT NULL,
  `hotel` varchar(50) NOT NULL,
  `adults` tinyint(4) NOT NULL,
  `children` tinyint(4) NOT NULL,
  `pay_method` varchar(10) NOT NULL,
  `paid` int(1) NOT NULL,
  `read` int(1) NOT NULL,
  `email_sent` int(1) NOT NULL,
  `outsourced` int(1) NOT NULL,
  `outsourced_partner` int(10) unsigned NOT NULL,
  `outsourced_price` double NOT NULL,
  `booking_date` int(10) unsigned NOT NULL,
  `timestamp` int(10) unsigned NOT NULL,
  `timestamp_end` int(10) unsigned NOT NULL,
  `tour` int(10) unsigned NOT NULL,
  `cancelled` int(1) NOT NULL,
  `other` text NOT NULL,
  `price` double NOT NULL,
  `country` tinyint(4) NOT NULL,
  `meta` text NOT NULL,
  PRIMARY KEY (`id`),
  KEY `number` (`number`)
) ENGINE=MyISAM  DEFAULT CHARSET=utf8 AUTO_INCREMENT=12 ;

-- --------------------------------------------------------

--
-- Table structure for table `tour_places`
--

CREATE TABLE IF NOT EXISTS `tour_places` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `name` varchar(100) NOT NULL,
  `about` text NOT NULL,
  `photo` varchar(250) NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=MyISAM  DEFAULT CHARSET=utf8 AUTO_INCREMENT=5 ;

-- --------------------------------------------------------

--
-- Table structure for table `transfer_bookings`
--

CREATE TABLE IF NOT EXISTS `transfer_bookings` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `direction` int(1) NOT NULL,
  `number` varchar(32) NOT NULL,
  `pickup` varchar(100) NOT NULL,
  `dropoff` varchar(100) NOT NULL,
  `port` int(10) unsigned NOT NULL,
  `destination` int(10) unsigned NOT NULL,
  `hotel` varchar(100) NOT NULL,
  `address` varchar(250) NOT NULL,
  `timestamp` int(10) unsigned NOT NULL,
  `passengers` int(10) unsigned NOT NULL,
  `pay_method` enum('cash','paypal','cc') NOT NULL,
  `paid` int(1) unsigned NOT NULL,
  `first_name` varchar(50) NOT NULL,
  `last_name` varchar(50) NOT NULL,
  `phone` varchar(50) NOT NULL,
  `email` varchar(100) NOT NULL,
  `price` double NOT NULL,
  `other` text NOT NULL,
  `booking_date` int(10) unsigned NOT NULL,
  `babies` int(10) unsigned NOT NULL,
  `children` int(10) unsigned NOT NULL,
  `flight_number` varchar(20) NOT NULL,
  `flight_time` int(10) unsigned NOT NULL,
  `flight_company` varchar(50) NOT NULL,
  `flight_airport` varchar(20) NOT NULL,
  `outsourced` int(1) NOT NULL DEFAULT '0',
  `outsourced_partner` int(10) unsigned NOT NULL,
  `outsourced_price` double NOT NULL,
  `return` int(10) unsigned NOT NULL,
  `cancelled` int(1) NOT NULL,
  `country` int(10) unsigned NOT NULL,
  `refunded_amount` double NOT NULL DEFAULT '0',
  `email_sent` int(1) NOT NULL DEFAULT '0',
  `read` int(1) NOT NULL DEFAULT '0',
  `meta` text NOT NULL,
  `car_id` int(10) unsigned NOT NULL,
  `car_name` varchar(20) NOT NULL,
  `cars` int(10) unsigned NOT NULL,
  `type` enum('airport','seaport') NOT NULL DEFAULT 'airport',
  PRIMARY KEY (`id`),
  KEY `number` (`number`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8 AUTO_INCREMENT=1 ;
