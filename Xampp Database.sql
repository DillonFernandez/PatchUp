-- phpMyAdmin SQL Dump
-- version 5.2.1
-- https://www.phpmyadmin.net/
--
-- Host: 127.0.0.1
-- Generation Time: Sep 13, 2025 at 06:31 PM
-- Server version: 10.4.32-MariaDB
-- PHP Version: 8.2.12

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
START TRANSACTION;
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- Database: `patchup`
--

-- --------------------------------------------------------

--
-- Table structure for table `admin`
--

CREATE TABLE `admin` (
  `AdminID` int(11) NOT NULL,
  `Name` varchar(100) NOT NULL,
  `Email` varchar(150) NOT NULL,
  `PasswordHash` varchar(255) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `admin`
--

INSERT INTO `admin` (`AdminID`, `Name`, `Email`, `PasswordHash`) VALUES
(1, 'Dillon Fernandez', 'dillon@gmail.com', 'Dillon@1'),
(2, 'Hiranya Nirmal', 'hiranya@gmail.com', 'Hiranya@1'),
(3, 'Sanura Devjan', 'sanura@gmail.com', 'Sanura@1'),
(4, 'Akshith Rithushan', 'akshith@gmail.com', 'Akshith@1');

-- --------------------------------------------------------

--
-- Table structure for table `badge`
--

CREATE TABLE `badge` (
  `BadgeID` int(11) NOT NULL,
  `BadgeName` varchar(100) NOT NULL,
  `Description` text DEFAULT NULL,
  `BadgeType` varchar(50) NOT NULL,
  `ImagePath` varchar(255) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `badge`
--

INSERT INTO `badge` (`BadgeID`, `BadgeName`, `Description`, `BadgeType`, `ImagePath`) VALUES
(1, 'Trailblazer', 'Your first pothole report', 'Reporting', '/patchup_app/assets/images/badges/trailblazer.png'),
(2, 'Street Scout', 'Ten potholes discovered', 'Reporting', '/patchup_app/assets/images/badges/street_scout.png'),
(3, 'Neighborhood Star', 'Fifty potholes reported', 'Reporting', '/patchup_app/assets/images/badges/neighborhood_star.png'),
(4, 'City Legend', 'Hundred potholes reported', 'Reporting', '/patchup_app/assets/images/badges/city_legend.png'),
(5, 'Fact Finder', 'First report confirmed', 'Validation', '/patchup_app/assets/images/badges/fact_finder.png'),
(6, 'Trusted Witness', 'Twenty confirmations made', 'Validation', '/patchup_app/assets/images/badges/trusted_witness.png'),
(7, 'Community Booster', 'Fifty upvotes given', 'Validation', '/patchup_app/assets/images/badges/community_booster.png'),
(8, 'Problem Solver', 'First fix achieved', 'Impact', '/patchup_app/assets/images/badges/problem_solver.png'),
(9, 'Change Maker', 'Ten fixes credited', 'Impact', '/patchup_app/assets/images/badges/change_maker.png'),
(10, 'Road Saver', 'Fifty fixes credited', 'Impact', '/patchup_app/assets/images/badges/road_saver.png'),
(11, 'Daily Hero', 'Seven days reporting streak', 'Consistency', '/patchup_app/assets/images/badges/daily_hero.png'),
(12, 'Weekly Watch', 'Four weeks reporting streak', 'Consistency', '/patchup_app/assets/images/badges/weekly_watch.png'),
(13, 'Long Haul', 'Six months active', 'Consistency', '/patchup_app/assets/images/badges/long_haul.png'),
(14, 'Night Owl', 'Report between 6pm-6am', 'Special Event', '/patchup_app/assets/images/badges/night_owl.png');

-- --------------------------------------------------------

--
-- Table structure for table `chat_messages`
--

CREATE TABLE `chat_messages` (
  `MessageID` int(11) NOT NULL,
  `ReportID` int(11) NOT NULL,
  `UserID` int(11) NOT NULL,
  `MessageText` text NOT NULL,
  `CreatedAt` datetime NOT NULL DEFAULT current_timestamp(),
  `EditedAt` datetime DEFAULT NULL,
  `IsEdited` tinyint(1) NOT NULL DEFAULT 0,
  `IsDeleted` tinyint(1) NOT NULL DEFAULT 0,
  `IsAdmin` tinyint(1) NOT NULL DEFAULT 0
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `chat_messages`
--

INSERT INTO `chat_messages` (`MessageID`, `ReportID`, `UserID`, `MessageText`, `CreatedAt`, `EditedAt`, `IsEdited`, `IsDeleted`, `IsAdmin`) VALUES
(6, 29, 1, 'I reported a pothole 21 days ago and It’s still not fixed and has gotten worse. Can I know the status?', '2025-09-13 13:22:09', NULL, 0, 0, 0),
(7, 29, 21, 'Hello User 1, thanks for following up. I see your report in the system. The issue is marked as pending. I’ll check with the maintenance team for an update.', '2025-09-13 13:22:25', NULL, 0, 0, 1),
(8, 29, 20, 'Jumping in here—are you talking about the big pothole near the bus stop? I pass it daily, and it’s definitely dangerous now.', '2025-09-13 13:22:42', NULL, 0, 0, 0),
(9, 29, 1, 'Yes, that’s the same one. It’s grown larger, and last night a motorbike almost lost balance there.', '2025-09-13 13:23:03', NULL, 0, 0, 0),
(10, 29, 22, 'I understand the urgency. Our records show it was scheduled for inspection on 28th August, but no action log has been entered since. I’ll escalate this today.', '2025-09-13 13:23:10', NULL, 0, 0, 1),
(11, 29, 20, 'Thanks Admin. Just to add, it gets filled with water every time it rains, making it invisible. Someone’s bound to get hurt soon.', '2025-09-13 13:23:31', NULL, 0, 0, 0),
(12, 29, 1, 'Exactly my concern. It’s been nearly 3 weeks with no progress. Can we get a timeline for repair?', '2025-09-13 13:23:59', NULL, 0, 0, 0),
(13, 29, 23, 'I’ll push this to the urgent priority list. Typically, urgent repairs are addressed within 48–72 hours once escalated. I’ll confirm once a crew is assigned.', '2025-09-13 13:24:07', NULL, 0, 0, 1),
(14, 29, 20, 'Appreciate that. Could you also update the status in the app so others know it’s being worked on? Right now it still shows “reported.”', '2025-09-13 13:24:45', NULL, 0, 0, 0),
(15, 29, 24, 'Good point, User 20. I’ll update the status to “In Progress” and notify you both once the work order is dispatched. Thank you for bringing this back to our attention.', '2025-09-13 13:25:08', NULL, 0, 0, 1),
(16, 29, 25, 'Update: The maintenance crew has been dispatched to repair the pothole. They should arrive within the next few hours.', '2025-09-13 13:26:43', NULL, 0, 0, 1),
(17, 29, 1, 'Thank you, Finally some action. I’ll check later today and let you know if it’s fully fixed.', '2025-09-13 13:27:05', NULL, 0, 0, 0),
(18, 29, 20, 'Great to hear! Appreciate the quick response this time. Hopefully, no one gets hurt before it’s repaired.', '2025-09-13 13:27:21', NULL, 0, 0, 0);

--
-- Triggers `chat_messages`
--
DELIMITER $$
CREATE TRIGGER `trg_chat_new_message_notify` AFTER INSERT ON `chat_messages` FOR EACH ROW BEGIN
  DECLARE report_owner INT;
  DECLARE sender_name VARCHAR(255);
  DECLARE display_name VARCHAR(300);
  DECLARE body_text VARCHAR(255);

  -- Owner of the report
  SELECT UserID INTO report_owner
  FROM potholereport
  WHERE ReportID = NEW.ReportID;

  -- Only notify if:
  --  * report exists
  --  * commenter is not the owner
  --  * message not soft-deleted
  IF report_owner IS NOT NULL
     AND report_owner <> NEW.UserID
     AND NEW.IsDeleted = 0 THEN

    -- Try to get a name from user table
    SELECT Name INTO sender_name
    FROM user
    WHERE UserID = NEW.UserID
    LIMIT 1;

    -- If admin flag set and no user name found, try admin table
    IF sender_name IS NULL AND NEW.IsAdmin = 1 THEN
       SELECT Name INTO sender_name
       FROM admin
       WHERE AdminID = NEW.UserID
       LIMIT 1;
    END IF;

    -- Fallback
    IF sender_name IS NULL THEN
       SET sender_name = 'Someone';
    END IF;

    -- Build display name (append label if admin)
    IF NEW.IsAdmin = 1 THEN
       SET display_name = CONCAT(sender_name, ' | Admin');
    ELSE
       SET display_name = sender_name;
    END IF;

    -- Build body (truncate message portion to stay within 255)
    SET body_text = CONCAT(
        display_name,
        ' commented: "',
        LEFT(NEW.MessageText, 200),
        CASE WHEN CHAR_LENGTH(NEW.MessageText) > 200 THEN '…"' ELSE '"' END
    );

    INSERT INTO notification
      (UserID, ReportID, Title, Body, DataJSON)
    VALUES
      (
        report_owner,
        NEW.ReportID,
        CONCAT('New message on Pothole #', NEW.ReportID),
        body_text,
        JSON_OBJECT(
          'type', 'chat_message',
          'MessageID', NEW.MessageID,
          'ReportID', NEW.ReportID,
          'SenderUserID', NEW.UserID,
          'IsAdmin', NEW.IsAdmin,
          'SenderName', sender_name,
          'SenderDisplayName', display_name,
          'MessageText', NEW.MessageText,
          'CreatedAt', DATE_FORMAT(NEW.CreatedAt, '%Y-%m-%d %H:%i:%s')
        )
      );
  END IF;
END
$$
DELIMITER ;

-- --------------------------------------------------------

--
-- Table structure for table `notification`
--

CREATE TABLE `notification` (
  `NotificationID` int(11) NOT NULL,
  `UserID` int(11) NOT NULL,
  `ReportID` int(11) NOT NULL,
  `Title` varchar(120) NOT NULL,
  `Body` varchar(255) NOT NULL,
  `DataJSON` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL CHECK (json_valid(`DataJSON`)),
  `IsRead` tinyint(1) NOT NULL DEFAULT 0,
  `CreatedAt` datetime NOT NULL DEFAULT current_timestamp(),
  `ReadAt` datetime DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `notification`
--

INSERT INTO `notification` (`NotificationID`, `UserID`, `ReportID`, `Title`, `Body`, `DataJSON`, `IsRead`, `CreatedAt`, `ReadAt`) VALUES
(1, 2, 1, 'Badge Earned: Trailblazer', 'Congratulations! You earned the \"Trailblazer\" badge!', '{\"BadgeID\": 1, \"BadgeName\": \"Trailblazer\", \"EarnedAt\": \"2025-07-26 10:00:00\"}', 0, '2025-07-26 10:00:00', NULL),
(2, 7, 2, 'Badge Earned: Trailblazer', 'Congratulations! You earned the \"Trailblazer\" badge!', '{\"BadgeID\": 1, \"BadgeName\": \"Trailblazer\", \"EarnedAt\": \"2025-07-27 11:00:00\"}', 0, '2025-07-27 11:00:00', NULL),
(3, 15, 4, 'Badge Earned: Trailblazer', 'Congratulations! You earned the \"Trailblazer\" badge!', '{\"BadgeID\": 1, \"BadgeName\": \"Trailblazer\", \"EarnedAt\": \"2025-07-29 13:30:00\"}', 0, '2025-07-29 13:30:00', NULL),
(4, 18, 8, 'Badge Earned: Trailblazer', 'Congratulations! You earned the \"Trailblazer\" badge!', '{\"BadgeID\": 1, \"BadgeName\": \"Trailblazer\", \"EarnedAt\": \"2025-08-02 17:30:00\"}', 0, '2025-08-02 17:30:00', NULL),
(5, 20, 10, 'Badge Earned: Trailblazer', 'Congratulations! You earned the \"Trailblazer\" badge!', '{\"BadgeID\": 1, \"BadgeName\": \"Trailblazer\", \"EarnedAt\": \"2025-08-04 11:00:00\"}', 1, '2025-08-04 11:00:00', '2025-08-23 23:03:30'),
(6, 1, 28, 'Badge Earned: Trailblazer', 'Congratulations! You earned the \"Trailblazer\" badge!', '{\"BadgeID\": 1, \"BadgeName\": \"Trailblazer\", \"EarnedAt\": \"2025-08-23 23:04:24\"}', 1, '2025-08-23 23:04:24', '2025-08-23 23:06:34'),
(7, 1, 28, 'Badge Earned: Night Owl', 'Congratulations! You earned the \"Night Owl\" badge!', '{\"BadgeID\": 14, \"BadgeName\": \"Night Owl\", \"EarnedAt\": \"2025-08-23 23:04:24\"}', 1, '2025-08-23 23:04:24', '2025-08-23 23:06:34'),
(8, 1, 28, 'Pothole #28 status updated', 'Status changed from Reported to In Progress.', '{\"old_status\": \"Reported\", \"new_status\": \"In Progress\"}', 1, '2025-08-23 23:06:27', '2025-08-23 23:06:34'),
(9, 1, 28, 'Pothole #28 status updated', 'Status changed from In Progress to Resolved.', '{\"old_status\": \"In Progress\", \"new_status\": \"Resolved\"}', 1, '2025-08-23 23:07:19', '2025-08-23 23:07:27'),
(10, 1, 28, 'Badge Earned: Problem Solver', 'Congratulations! You earned the \"Problem Solver\" badge!', '{\"BadgeID\": 8, \"BadgeName\": \"Problem Solver\", \"EarnedAt\": \"2025-08-23 23:07:19\"}', 1, '2025-08-23 23:07:19', '2025-08-23 23:07:27'),
(11, 7, 2, 'Pothole #2 status updated', 'Status changed from Reported to In Progress.', '{\"old_status\": \"Reported\", \"new_status\": \"In Progress\"}', 0, '2025-08-23 23:34:09', NULL),
(12, 15, 4, 'Pothole #4 status updated', 'Status changed from Reported to In Progress.', '{\"old_status\": \"Reported\", \"new_status\": \"In Progress\"}', 0, '2025-08-23 23:34:09', NULL),
(13, 7, 5, 'Pothole #5 status updated', 'Status changed from Reported to In Progress.', '{\"old_status\": \"Reported\", \"new_status\": \"In Progress\"}', 0, '2025-08-23 23:34:09', NULL),
(14, 7, 7, 'Pothole #7 status updated', 'Status changed from Reported to In Progress.', '{\"old_status\": \"Reported\", \"new_status\": \"In Progress\"}', 0, '2025-08-23 23:34:09', NULL),
(15, 18, 8, 'Pothole #8 status updated', 'Status changed from Reported to In Progress.', '{\"old_status\": \"Reported\", \"new_status\": \"In Progress\"}', 0, '2025-08-23 23:34:09', NULL),
(16, 20, 10, 'Pothole #10 status updated', 'Status changed from Reported to In Progress.', '{\"old_status\": \"Reported\", \"new_status\": \"In Progress\"}', 1, '2025-08-23 23:34:09', '2025-08-24 00:05:49'),
(17, 7, 12, 'Pothole #12 status updated', 'Status changed from Reported to In Progress.', '{\"old_status\": \"Reported\", \"new_status\": \"In Progress\"}', 0, '2025-08-23 23:34:09', NULL),
(18, 18, 13, 'Pothole #13 status updated', 'Status changed from Reported to In Progress.', '{\"old_status\": \"Reported\", \"new_status\": \"In Progress\"}', 0, '2025-08-23 23:34:09', NULL),
(19, 18, 15, 'Pothole #15 status updated', 'Status changed from Reported to In Progress.', '{\"old_status\": \"Reported\", \"new_status\": \"In Progress\"}', 0, '2025-08-23 23:34:09', NULL),
(20, 18, 17, 'Pothole #17 status updated', 'Status changed from Reported to In Progress.', '{\"old_status\": \"Reported\", \"new_status\": \"In Progress\"}', 0, '2025-08-23 23:34:09', NULL),
(21, 18, 19, 'Pothole #19 status updated', 'Status changed from Reported to In Progress.', '{\"old_status\": \"Reported\", \"new_status\": \"In Progress\"}', 0, '2025-08-23 23:34:09', NULL),
(22, 20, 21, 'Pothole #21 status updated', 'Status changed from Reported to In Progress.', '{\"old_status\": \"Reported\", \"new_status\": \"In Progress\"}', 1, '2025-08-23 23:34:09', '2025-08-24 00:05:49'),
(23, 20, 23, 'Pothole #23 status updated', 'Status changed from Reported to In Progress.', '{\"old_status\": \"Reported\", \"new_status\": \"In Progress\"}', 1, '2025-08-23 23:34:09', '2025-08-24 00:05:49'),
(24, 7, 25, 'Pothole #25 status updated', 'Status changed from Reported to In Progress.', '{\"old_status\": \"Reported\", \"new_status\": \"In Progress\"}', 0, '2025-08-23 23:34:09', NULL),
(25, 15, 4, 'Badge Earned: Problem Solver', 'Congratulations! You earned the \"Problem Solver\" badge!', '{\"BadgeID\": 8, \"BadgeName\": \"Problem Solver\", \"EarnedAt\": \"2025-08-23 23:34:09\"}', 0, '2025-08-23 23:34:09', NULL),
(26, 15, 4, 'Pothole #4 status updated', 'Status changed from In Progress to Resolved.', '{\"old_status\": \"In Progress\", \"new_status\": \"Resolved\"}', 0, '2025-08-23 23:34:09', NULL),
(27, 18, 8, 'Badge Earned: Problem Solver', 'Congratulations! You earned the \"Problem Solver\" badge!', '{\"BadgeID\": 8, \"BadgeName\": \"Problem Solver\", \"EarnedAt\": \"2025-08-23 23:34:09\"}', 0, '2025-08-23 23:34:09', NULL),
(28, 18, 8, 'Pothole #8 status updated', 'Status changed from In Progress to Resolved.', '{\"old_status\": \"In Progress\", \"new_status\": \"Resolved\"}', 0, '2025-08-23 23:34:09', NULL),
(29, 18, 13, 'Pothole #13 status updated', 'Status changed from In Progress to Resolved.', '{\"old_status\": \"In Progress\", \"new_status\": \"Resolved\"}', 0, '2025-08-23 23:34:09', NULL),
(30, 18, 19, 'Pothole #19 status updated', 'Status changed from In Progress to Resolved.', '{\"old_status\": \"In Progress\", \"new_status\": \"Resolved\"}', 0, '2025-08-23 23:34:09', NULL),
(31, 7, 25, 'Badge Earned: Problem Solver', 'Congratulations! You earned the \"Problem Solver\" badge!', '{\"BadgeID\": 8, \"BadgeName\": \"Problem Solver\", \"EarnedAt\": \"2025-08-23 23:34:09\"}', 0, '2025-08-23 23:34:09', NULL),
(32, 7, 25, 'Pothole #25 status updated', 'Status changed from In Progress to Resolved.', '{\"old_status\": \"In Progress\", \"new_status\": \"Resolved\"}', 0, '2025-08-23 23:34:09', NULL),
(33, 5, 4, 'Badge Earned: Fact Finder', 'Congratulations! You earned the \"Fact Finder\" badge!', '{\"BadgeID\": 5, \"BadgeName\": \"Fact Finder\", \"EarnedAt\": \"2025-09-01 01:39:57\"}', 0, '2025-09-01 01:39:57', NULL),
(34, 11, 4, 'Badge Earned: Fact Finder', 'Congratulations! You earned the \"Fact Finder\" badge!', '{\"BadgeID\": 5, \"BadgeName\": \"Fact Finder\", \"EarnedAt\": \"2025-09-01 01:39:57\"}', 0, '2025-09-01 01:39:57', NULL),
(35, 2, 4, 'Badge Earned: Fact Finder', 'Congratulations! You earned the \"Fact Finder\" badge!', '{\"BadgeID\": 5, \"BadgeName\": \"Fact Finder\", \"EarnedAt\": \"2025-09-01 01:39:57\"}', 0, '2025-09-01 01:39:57', NULL),
(36, 10, 8, 'Badge Earned: Fact Finder', 'Congratulations! You earned the \"Fact Finder\" badge!', '{\"BadgeID\": 5, \"BadgeName\": \"Fact Finder\", \"EarnedAt\": \"2025-09-01 01:39:57\"}', 0, '2025-09-01 01:39:57', NULL),
(37, 9, 8, 'Badge Earned: Fact Finder', 'Congratulations! You earned the \"Fact Finder\" badge!', '{\"BadgeID\": 5, \"BadgeName\": \"Fact Finder\", \"EarnedAt\": \"2025-09-01 01:39:57\"}', 0, '2025-09-01 01:39:57', NULL),
(38, 16, 12, 'Badge Earned: Fact Finder', 'Congratulations! You earned the \"Fact Finder\" badge!', '{\"BadgeID\": 5, \"BadgeName\": \"Fact Finder\", \"EarnedAt\": \"2025-09-01 01:39:57\"}', 0, '2025-09-01 01:39:57', NULL),
(39, 3, 1, 'Badge Earned: Fact Finder', 'Congratulations! You earned the \"Fact Finder\" badge!', '{\"BadgeID\": 5, \"BadgeName\": \"Fact Finder\", \"EarnedAt\": \"2025-09-01 01:39:57\"}', 0, '2025-09-01 01:39:57', NULL),
(40, 14, 1, 'Badge Earned: Fact Finder', 'Congratulations! You earned the \"Fact Finder\" badge!', '{\"BadgeID\": 5, \"BadgeName\": \"Fact Finder\", \"EarnedAt\": \"2025-09-01 01:39:57\"}', 0, '2025-09-01 01:39:57', NULL),
(41, 13, 25, 'Badge Earned: Fact Finder', 'Congratulations! You earned the \"Fact Finder\" badge!', '{\"BadgeID\": 5, \"BadgeName\": \"Fact Finder\", \"EarnedAt\": \"2025-09-01 01:39:57\"}', 0, '2025-09-01 01:39:57', NULL),
(42, 8, 25, 'Badge Earned: Fact Finder', 'Congratulations! You earned the \"Fact Finder\" badge!', '{\"BadgeID\": 5, \"BadgeName\": \"Fact Finder\", \"EarnedAt\": \"2025-09-01 01:39:57\"}', 0, '2025-09-01 01:39:57', NULL),
(43, 15, 17, 'Badge Earned: Fact Finder', 'Congratulations! You earned the \"Fact Finder\" badge!', '{\"BadgeID\": 5, \"BadgeName\": \"Fact Finder\", \"EarnedAt\": \"2025-09-01 01:39:57\"}', 0, '2025-09-01 01:39:57', NULL),
(44, 20, 17, 'Badge Earned: Fact Finder', 'Congratulations! You earned the \"Fact Finder\" badge!', '{\"BadgeID\": 5, \"BadgeName\": \"Fact Finder\", \"EarnedAt\": \"2025-09-01 01:39:57\"}', 1, '2025-09-01 01:39:57', '2025-09-12 09:12:29'),
(45, 18, 9, 'Badge Earned: Fact Finder', 'Congratulations! You earned the \"Fact Finder\" badge!', '{\"BadgeID\": 5, \"BadgeName\": \"Fact Finder\", \"EarnedAt\": \"2025-09-01 01:39:57\"}', 0, '2025-09-01 01:39:57', NULL),
(46, 7, 26, 'Badge Earned: Fact Finder', 'Congratulations! You earned the \"Fact Finder\" badge!', '{\"BadgeID\": 5, \"BadgeName\": \"Fact Finder\", \"EarnedAt\": \"2025-09-01 01:39:57\"}', 0, '2025-09-01 01:39:57', NULL),
(47, 6, 27, 'Badge Earned: Fact Finder', 'Congratulations! You earned the \"Fact Finder\" badge!', '{\"BadgeID\": 5, \"BadgeName\": \"Fact Finder\", \"EarnedAt\": \"2025-09-01 01:39:57\"}', 0, '2025-09-01 01:39:57', NULL),
(48, 4, 19, 'Badge Earned: Fact Finder', 'Congratulations! You earned the \"Fact Finder\" badge!', '{\"BadgeID\": 5, \"BadgeName\": \"Fact Finder\", \"EarnedAt\": \"2025-09-01 01:39:57\"}', 0, '2025-09-01 01:39:57', NULL),
(49, 17, 6, 'Badge Earned: Fact Finder', 'Congratulations! You earned the \"Fact Finder\" badge!', '{\"BadgeID\": 5, \"BadgeName\": \"Fact Finder\", \"EarnedAt\": \"2025-09-01 01:39:57\"}', 0, '2025-09-01 01:39:57', NULL),
(50, 19, 22, 'Badge Earned: Fact Finder', 'Congratulations! You earned the \"Fact Finder\" badge!', '{\"BadgeID\": 5, \"BadgeName\": \"Fact Finder\", \"EarnedAt\": \"2025-09-01 01:39:57\"}', 0, '2025-09-01 01:39:57', NULL),
(51, 12, 5, 'Badge Earned: Fact Finder', 'Congratulations! You earned the \"Fact Finder\" badge!', '{\"BadgeID\": 5, \"BadgeName\": \"Fact Finder\", \"EarnedAt\": \"2025-09-01 01:39:57\"}', 0, '2025-09-01 01:39:57', NULL),
(52, 1, 27, 'Badge Earned: Fact Finder', 'Congratulations! You earned the \"Fact Finder\" badge!', '{\"BadgeID\": 5, \"BadgeName\": \"Fact Finder\", \"EarnedAt\": \"2025-09-01 01:53:24\"}', 1, '2025-09-01 01:53:24', '2025-09-01 01:53:31'),
(53, 1, 29, 'New message on Pothole #29', 'Dillon Fernandez | Admin commented: \"Hello User 1, thanks for following up. I see your report in the system. The issue is marked as pending. I’ll check with the maintenance team for an update.\"', '{\"type\": \"chat_message\", \"MessageID\": 7, \"ReportID\": 29, \"SenderUserID\": 21, \"IsAdmin\": 1, \"SenderName\": \"Dillon Fernandez\", \"SenderDisplayName\": \"Dillon Fernandez | Admin\", \"MessageText\": \"Hello User 1, thanks for following up. I see your report in the system. The issue is marked as pending. I’ll check with the maintenance team for an update.\", \"CreatedAt\": \"2025-09-13 13:22:25\"}', 1, '2025-09-13 13:22:25', '2025-09-13 13:28:29'),
(54, 1, 29, 'New message on Pothole #29', 'Test User 20 commented: \"Jumping in here—are you talking about the big pothole near the bus stop? I pass it daily, and it’s definitely dangerous now.\"', '{\"type\": \"chat_message\", \"MessageID\": 8, \"ReportID\": 29, \"SenderUserID\": 20, \"IsAdmin\": 0, \"SenderName\": \"Test User 20\", \"SenderDisplayName\": \"Test User 20\", \"MessageText\": \"Jumping in here—are you talking about the big pothole near the bus stop? I pass it daily, and it’s definitely dangerous now.\", \"CreatedAt\": \"2025-09-13 13:22:42\"}', 1, '2025-09-13 13:22:42', '2025-09-13 13:28:29'),
(55, 1, 29, 'New message on Pothole #29', 'Dillon Fernandez | Admin commented: \"I understand the urgency. Our records show it was scheduled for inspection on 28th August, but no action log has been entered since. I’ll escalate this today.\"', '{\"type\": \"chat_message\", \"MessageID\": 10, \"ReportID\": 29, \"SenderUserID\": 22, \"IsAdmin\": 1, \"SenderName\": \"Dillon Fernandez\", \"SenderDisplayName\": \"Dillon Fernandez | Admin\", \"MessageText\": \"I understand the urgency. Our records show it was scheduled for inspection on 28th August, but no action log has been entered since. I’ll escalate this today.\", \"CreatedAt\": \"2025-09-13 13:23:10\"}', 1, '2025-09-13 13:23:10', '2025-09-13 13:28:29'),
(56, 1, 29, 'New message on Pothole #29', 'Test User 20 commented: \"Thanks Admin. Just to add, it gets filled with water every time it rains, making it invisible. Someone’s bound to get hurt soon.\"', '{\"type\": \"chat_message\", \"MessageID\": 11, \"ReportID\": 29, \"SenderUserID\": 20, \"IsAdmin\": 0, \"SenderName\": \"Test User 20\", \"SenderDisplayName\": \"Test User 20\", \"MessageText\": \"Thanks Admin. Just to add, it gets filled with water every time it rains, making it invisible. Someone’s bound to get hurt soon.\", \"CreatedAt\": \"2025-09-13 13:23:31\"}', 1, '2025-09-13 13:23:31', '2025-09-13 13:28:29'),
(57, 1, 29, 'New message on Pothole #29', 'Dillon Fernandez | Admin commented: \"I’ll push this to the urgent priority list. Typically, urgent repairs are addressed within 48–72 hours once escalated. I’ll confirm once a crew is assigned.\"', '{\"type\": \"chat_message\", \"MessageID\": 13, \"ReportID\": 29, \"SenderUserID\": 23, \"IsAdmin\": 1, \"SenderName\": \"Dillon Fernandez\", \"SenderDisplayName\": \"Dillon Fernandez | Admin\", \"MessageText\": \"I’ll push this to the urgent priority list. Typically, urgent repairs are addressed within 48–72 hours once escalated. I’ll confirm once a crew is assigned.\", \"CreatedAt\": \"2025-09-13 13:24:07\"}', 1, '2025-09-13 13:24:07', '2025-09-13 13:28:29'),
(58, 1, 29, 'New message on Pothole #29', 'Test User 20 commented: \"Appreciate that. Could you also update the status in the app so others know it’s being worked on? Right now it still shows “reported.”\"', '{\"type\": \"chat_message\", \"MessageID\": 14, \"ReportID\": 29, \"SenderUserID\": 20, \"IsAdmin\": 0, \"SenderName\": \"Test User 20\", \"SenderDisplayName\": \"Test User 20\", \"MessageText\": \"Appreciate that. Could you also update the status in the app so others know it’s being worked on? Right now it still shows “reported.”\", \"CreatedAt\": \"2025-09-13 13:24:45\"}', 1, '2025-09-13 13:24:45', '2025-09-13 13:28:29'),
(59, 1, 29, 'New message on Pothole #29', 'Dillon Fernandez | Admin commented: \"Good point, User 20. I’ll update the status to “In Progress” and notify you both once the work order is dispatched. Thank you for bringing this back to our attention.\"', '{\"type\": \"chat_message\", \"MessageID\": 15, \"ReportID\": 29, \"SenderUserID\": 24, \"IsAdmin\": 1, \"SenderName\": \"Dillon Fernandez\", \"SenderDisplayName\": \"Dillon Fernandez | Admin\", \"MessageText\": \"Good point, User 20. I’ll update the status to “In Progress” and notify you both once the work order is dispatched. Thank you for bringing this back to our attention.\", \"CreatedAt\": \"2025-09-13 13:25:08\"}', 1, '2025-09-13 13:25:08', '2025-09-13 13:28:29'),
(60, 1, 29, 'Pothole #29 status updated', 'Status changed from Reported to In Progress.', '{\"old_status\": \"Reported\", \"new_status\": \"In Progress\"}', 1, '2025-09-13 13:25:38', '2025-09-13 13:28:29'),
(61, 1, 29, 'New message on Pothole #29', 'Dillon Fernandez | Admin commented: \"Update: The maintenance crew has been dispatched to repair the pothole. They should arrive within the next few hours.\"', '{\"type\": \"chat_message\", \"MessageID\": 16, \"ReportID\": 29, \"SenderUserID\": 25, \"IsAdmin\": 1, \"SenderName\": \"Dillon Fernandez\", \"SenderDisplayName\": \"Dillon Fernandez | Admin\", \"MessageText\": \"Update: The maintenance crew has been dispatched to repair the pothole. They should arrive within the next few hours.\", \"CreatedAt\": \"2025-09-13 13:26:43\"}', 1, '2025-09-13 13:26:43', '2025-09-13 13:28:29'),
(62, 1, 29, 'New message on Pothole #29', 'Test User 20 commented: \"Great to hear! Appreciate the quick response this time. Hopefully, no one gets hurt before it’s repaired.\"', '{\"type\": \"chat_message\", \"MessageID\": 18, \"ReportID\": 29, \"SenderUserID\": 20, \"IsAdmin\": 0, \"SenderName\": \"Test User 20\", \"SenderDisplayName\": \"Test User 20\", \"MessageText\": \"Great to hear! Appreciate the quick response this time. Hopefully, no one gets hurt before it’s repaired.\", \"CreatedAt\": \"2025-09-13 13:27:21\"}', 1, '2025-09-13 13:27:21', '2025-09-13 14:23:21'),
(63, 1, 29, 'Pothole #29 confirmed', 'Test User 20 confirmed your pothole report.', '{\"type\": \"pothole_confirmation\", \"ValidationID\": 28, \"ReportID\": 29, \"ConfirmerUserID\": 20, \"ConfirmerName\": \"Test User 20\", \"ConfirmedAt\": \"2025-09-13 13:32:35\"}', 1, '2025-09-13 13:32:35', '2025-09-13 16:02:44');

-- --------------------------------------------------------

--
-- Table structure for table `potholereport`
--

CREATE TABLE `potholereport` (
  `ReportID` int(11) NOT NULL,
  `UserID` int(11) NOT NULL,
  `Description` text DEFAULT NULL,
  `SeverityLevel` varchar(10) NOT NULL,
  `ImageURL` varchar(255) DEFAULT NULL,
  `Timestamp` datetime NOT NULL DEFAULT current_timestamp(),
  `Status` varchar(20) NOT NULL DEFAULT 'Reported',
  `Province` varchar(50) NOT NULL,
  `Latitude` decimal(9,6) NOT NULL,
  `Longitude` decimal(9,6) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `potholereport`
--

INSERT INTO `potholereport` (`ReportID`, `UserID`, `Description`, `SeverityLevel`, `ImageURL`, `Timestamp`, `Status`, `Province`, `Latitude`, `Longitude`) VALUES
(1, 2, 'Pothole near Colombo Fort on Galle Road causing traffic delays.', 'Small', '/patchup_app/uploads/img_68a6bdea05c06_1000071859.jpg', '2025-07-26 10:00:00', 'Reported', 'Western Province', 6.927079, 79.861244),
(2, 7, 'Large pothole on Kandy Lake Road near the market area.', 'Small', '/patchup_app/uploads/img_68a6bdea05c06_1000071859.jpg', '2025-07-27 11:00:00', 'In Progress', 'Central Province', 7.290572, 80.633728),
(3, 7, 'Pothole on Matara Road, Galle, affecting bus routes.', 'Moderate', '/patchup_app/uploads/img_68a6bdea05c06_1000071859.jpg', '2025-07-28 12:15:00', 'Reported', 'Southern Province', 6.053518, 80.220963),
(4, 15, 'Damaged road near Jaffna town center with water accumulation.', 'Small', '/patchup_app/uploads/img_68a6bdea05c06_1000071859.jpg', '2025-07-29 14:30:00', 'Resolved', 'Northern Province', 8.587634, 80.532852),
(5, 7, 'Deep pothole on Batticaloa Main Street causing vehicle damage.', 'Critical', '/patchup_app/uploads/img_68a6bdea05c06_1000071859.jpg', '2025-07-30 14:45:00', 'In Progress', 'Eastern Province', 7.290631, 81.844667),
(6, 15, 'Pothole near Ratnapura town on Colombo–Kandy Highway.', 'Moderate', '/patchup_app/uploads/img_68a6bdea05c06_1000071859.jpg', '2025-07-31 15:30:00', 'Reported', 'Sabaragamuwa Province', 6.980001, 80.760002),
(7, 7, 'Cracked road near Badulla city with a large pothole.', 'Small', '/patchup_app/uploads/img_68a6bdea05c06_1000071859.jpg', '2025-08-01 16:15:00', 'In Progress', 'Uva Province', 6.991944, 81.056111),
(8, 18, 'Road damage near Vavuniya main junction causing unsafe driving conditions.', 'Moderate', '/patchup_app/uploads/img_68a6bdea05c06_1000071859.jpg', '2025-08-02 17:30:00', 'Resolved', 'Western Province', 6.927079, 79.861244),
(9, 15, 'Pothole on Katugastota Road, Kandy near the bus stop.', 'Small', '/patchup_app/uploads/img_68a6bdea05c06_1000071859.jpg', '2025-08-03 10:45:00', 'Reported', 'Southern Province', 6.053518, 80.220963),
(10, 20, 'Collapsed section of road on Matara–Hambantota Highway.', 'Critical', '/patchup_app/uploads/img_68a6bdea05c06_1000071859.jpg', '2025-08-04 11:00:00', 'In Progress', 'Central Province', 7.290572, 80.633728),
(11, 18, 'Pothole on Marine Drive, Colombo, next to pedestrian walkway.', 'Moderate', '/patchup_app/uploads/img_68a6bdea05c06_1000071859.jpg', '2025-08-05 12:15:00', 'Reported', 'Northern Province', 8.587634, 80.532852),
(12, 7, 'Pothole on Monaragala–Wellawaya road affecting bus transport.', 'Small', '/patchup_app/uploads/img_68a6bdea05c06_1000071859.jpg', '2025-08-06 13:30:00', 'In Progress', 'Western Province', 6.927079, 79.861244),
(13, 18, 'Road erosion near Ratnapura city causing deep potholes.', 'Moderate', '/patchup_app/uploads/img_68a6bdea05c06_1000071859.jpg', '2025-08-07 15:45:00', 'Resolved', 'Central Province', 7.290572, 80.633728),
(14, 18, 'Large pothole near Trincomalee town along main road.', 'Critical', '/patchup_app/uploads/img_68a6bdea05c06_1000071859.jpg', '2025-08-08 15:00:00', 'Reported', 'Southern Province', 6.053518, 80.220963),
(15, 18, 'Pothole on Jaffna Point Road causing risk to motorbikes.', 'Moderate', '/patchup_app/uploads/img_68a6bdea05c06_1000071859.jpg', '2025-08-09 16:15:00', 'In Progress', 'Northern Province', 8.587634, 80.532852),
(16, 20, 'Damaged pavement near Galle Face Green.', 'Small', '/patchup_app/uploads/img_68a6bdea05c06_1000071859.jpg', '2025-08-10 17:30:00', 'Reported', 'Eastern Province', 7.290631, 81.844667),
(17, 18, 'Cracked road section on Kandy–Nuwara Eliya highway.', 'Moderate', '/patchup_app/uploads/img_68a6bdea05c06_1000071859.jpg', '2025-08-11 10:45:00', 'In Progress', 'Sabaragamuwa Province', 6.980001, 80.760002),
(18, 20, 'Pothole on Havelock Road, Colombo, near commercial shops.', 'Critical', '/patchup_app/uploads/img_68a6bdea05c06_1000071859.jpg', '2025-08-12 11:59:59', 'Reported', 'Uva Province', 6.991944, 81.056111),
(19, 18, 'Cracked road near Kurunegala city center affecting vehicles.', 'Moderate', '/patchup_app/uploads/img_68a6bdea05c06_1000071859.jpg', '2025-08-13 13:30:00', 'Resolved', 'Western Province', 6.927079, 79.861244),
(20, 20, 'Pothole on Badulla–Welimada road, central lane badly affected.', 'Small', '/patchup_app/uploads/img_68a6bdea05c06_1000071859.jpg', '2025-08-14 13:05:12', 'Reported', 'Central Province', 7.290572, 80.633728),
(21, 20, 'Damaged highway near Ratnapura junction causing unsafe driving.', 'Critical', '/patchup_app/uploads/img_68a6bdea05c06_1000071859.jpg', '2025-08-15 14:40:21', 'In Progress', 'Southern Province', 6.053518, 80.220963),
(22, 15, 'Pothole on Batticaloa coastal road next to local market.', 'Moderate', '/patchup_app/uploads/img_68a6bdea05c06_1000071859.jpg', '2025-08-16 15:55:33', 'Reported', 'Northern Province', 8.587634, 80.532852),
(23, 20, 'Road cracks on Jaffna Main Street with water pooling.', 'Small', '/patchup_app/uploads/img_68a6bdea05c06_1000071859.jpg', '2025-08-17 16:10:05', 'In Progress', 'Eastern Province', 7.290631, 81.844667),
(24, 20, 'Pothole near Matara railway station causing traffic slowdown.', 'Moderate', '/patchup_app/uploads/img_68a6bdea05c06_1000071859.jpg', '2025-08-18 17:23:41', 'Reported', 'Sabaragamuwa Province', 6.980001, 80.760002),
(25, 7, 'Damaged road section on Kandy city main street.', 'Critical', '/patchup_app/uploads/img_68a6bdea05c06_1000071859.jpg', '2025-08-19 11:45:55', 'Resolved', 'Uva Province', 6.991944, 81.056111),
(26, 20, 'Pothole on Galle Road, Colombo near residential area.', 'Small', '/patchup_app/uploads/img_68a6bdea05c06_1000071859.jpg', '2025-08-20 11:12:10', 'Reported', 'North Western Province', 7.338242, 80.518707),
(27, 20, 'Pothole on Anuradhapura main road close to temple area.', 'Moderate', '/patchup_app/uploads/img_68a6bdea05c06_1000071859.jpg', '2025-08-21 15:34:29', 'Reported', 'Northern Province', 8.587634, 80.532852),
(28, 1, 'Pothole on Kandana Station Road near Food City.', 'Small', '/patchup_app/uploads/img_68a6bdea05c06_1000071859.jpg', '2025-08-23 23:04:24', 'Resolved', 'Western Province', 7.047445, 79.899384),
(29, 1, 'Moderate pothole near the commercial complex on Main Road.', 'Moderate', '/patchup_app/uploads/img_68a6bdea05c06_1000071859.jpg', '2025-08-23 23:51:51', 'In Progress', 'Western Province', 7.047541, 79.899443);

--
-- Triggers `potholereport`
--
DELIMITER $$
CREATE TRIGGER `trg_award_impact_badges` AFTER UPDATE ON `potholereport` FOR EACH ROW BEGIN
    DECLARE resolved_count INT;

    IF NEW.Status = 'Resolved' AND OLD.Status <> 'Resolved' THEN
        -- Problem Solver
        IF NOT EXISTS (
            SELECT 1 FROM userbadge WHERE UserID = NEW.UserID AND BadgeID = (SELECT BadgeID FROM badge WHERE BadgeName='Problem Solver')
        ) THEN
            INSERT INTO userbadge(UserID, BadgeID)
            SELECT NEW.UserID, BadgeID FROM badge WHERE BadgeName='Problem Solver';

            INSERT INTO notification(UserID, ReportID, Title, Body, DataJSON)
            SELECT NEW.UserID, NEW.ReportID,
                   'Badge Earned: Problem Solver',
                   'Congratulations! You earned the "Problem Solver" badge!',
                   JSON_OBJECT('BadgeID', BadgeID, 'BadgeName','Problem Solver', 'EarnedAt', NOW())
            FROM badge WHERE BadgeName='Problem Solver';
        END IF;

        -- Count resolved reports
        SELECT COUNT(*) INTO resolved_count
        FROM potholereport
        WHERE UserID=NEW.UserID AND Status='Resolved';

        -- Change Maker (10 resolves)
        IF resolved_count = 10 AND NOT EXISTS (
            SELECT 1 FROM userbadge WHERE UserID = NEW.UserID AND BadgeID = (SELECT BadgeID FROM badge WHERE BadgeName='Change Maker')
        ) THEN
            INSERT INTO userbadge(UserID, BadgeID)
            SELECT NEW.UserID, BadgeID FROM badge WHERE BadgeName='Change Maker';

            INSERT INTO notification(UserID, ReportID, Title, Body, DataJSON)
            SELECT NEW.UserID, NEW.ReportID,
                   'Badge Earned: Change Maker',
                   'Congratulations! You earned the "Change Maker" badge!',
                   JSON_OBJECT('BadgeID', BadgeID, 'BadgeName','Change Maker', 'EarnedAt', NOW())
            FROM badge WHERE BadgeName='Change Maker';
        END IF;

        -- Road Saver (50 resolves)
        IF resolved_count = 50 AND NOT EXISTS (
            SELECT 1 FROM userbadge WHERE UserID = NEW.UserID AND BadgeID = (SELECT BadgeID FROM badge WHERE BadgeName='Road Saver')
        ) THEN
            INSERT INTO userbadge(UserID, BadgeID)
            SELECT NEW.UserID, BadgeID FROM badge WHERE BadgeName='Road Saver';

            INSERT INTO notification(UserID, ReportID, Title, Body, DataJSON)
            SELECT NEW.UserID, NEW.ReportID,
                   'Badge Earned: Road Saver',
                   'Congratulations! You earned the "Road Saver" badge!',
                   JSON_OBJECT('BadgeID', BadgeID, 'BadgeName','Road Saver', 'EarnedAt', NOW())
            FROM badge WHERE BadgeName='Road Saver';
        END IF;
    END IF;
END
$$
DELIMITER ;
DELIMITER $$
CREATE TRIGGER `trg_award_reporting_badges` AFTER INSERT ON `potholereport` FOR EACH ROW BEGIN
    DECLARE report_count INT;

    SELECT COUNT(*) INTO report_count 
    FROM potholereport 
    WHERE UserID = NEW.UserID;

    -- Trailblazer
    IF report_count = 1 AND NOT EXISTS (
        SELECT 1 FROM userbadge WHERE UserID = NEW.UserID AND BadgeID = (SELECT BadgeID FROM badge WHERE BadgeName='Trailblazer')
    ) THEN
        INSERT INTO userbadge(UserID, BadgeID)
        SELECT NEW.UserID, BadgeID FROM badge WHERE BadgeName='Trailblazer';

        INSERT INTO notification(UserID, ReportID, Title, Body, DataJSON)
        SELECT NEW.UserID, NEW.ReportID,
               CONCAT('Badge Earned: Trailblazer'),
               'Congratulations! You earned the "Trailblazer" badge!',
               JSON_OBJECT('BadgeID', BadgeID, 'BadgeName','Trailblazer', 'EarnedAt', NOW())
        FROM badge WHERE BadgeName='Trailblazer';
    END IF;

    -- Street Scout
    IF report_count = 10 AND NOT EXISTS (
        SELECT 1 FROM userbadge WHERE UserID = NEW.UserID AND BadgeID = (SELECT BadgeID FROM badge WHERE BadgeName='Street Scout')
    ) THEN
        INSERT INTO userbadge(UserID, BadgeID)
        SELECT NEW.UserID, BadgeID FROM badge WHERE BadgeName='Street Scout';

        INSERT INTO notification(UserID, ReportID, Title, Body, DataJSON)
        SELECT NEW.UserID, NEW.ReportID,
               CONCAT('Badge Earned: Street Scout'),
               'Congratulations! You earned the "Street Scout" badge!',
               JSON_OBJECT('BadgeID', BadgeID, 'BadgeName','Street Scout', 'EarnedAt', NOW())
        FROM badge WHERE BadgeName='Street Scout';
    END IF;

    -- Neighborhood Star
    IF report_count = 50 AND NOT EXISTS (
        SELECT 1 FROM userbadge WHERE UserID = NEW.UserID AND BadgeID = (SELECT BadgeID FROM badge WHERE BadgeName='Neighborhood Star')
    ) THEN
        INSERT INTO userbadge(UserID, BadgeID)
        SELECT NEW.UserID, BadgeID FROM badge WHERE BadgeName='Neighborhood Star';

        INSERT INTO notification(UserID, ReportID, Title, Body, DataJSON)
        SELECT NEW.UserID, NEW.ReportID,
               CONCAT('Badge Earned: Neighborhood Star'),
               'Congratulations! You earned the "Neighborhood Star" badge!',
               JSON_OBJECT('BadgeID', BadgeID, 'BadgeName','Neighborhood Star', 'EarnedAt', NOW())
        FROM badge WHERE BadgeName='Neighborhood Star';
    END IF;

    -- City Legend
    IF report_count >= 100 AND NOT EXISTS (
        SELECT 1 FROM userbadge WHERE UserID = NEW.UserID AND BadgeID = (SELECT BadgeID FROM badge WHERE BadgeName='City Legend')
    ) THEN
        INSERT INTO userbadge(UserID, BadgeID)
        SELECT NEW.UserID, BadgeID FROM badge WHERE BadgeName='City Legend';

        INSERT INTO notification(UserID, ReportID, Title, Body, DataJSON)
        SELECT NEW.UserID, NEW.ReportID,
               CONCAT('Badge Earned: City Legend'),
               'Congratulations! You earned the "City Legend" badge!',
               JSON_OBJECT('BadgeID', BadgeID, 'BadgeName','City Legend', 'EarnedAt', NOW())
        FROM badge WHERE BadgeName='City Legend';
    END IF;

    -- Night Owl
    IF (HOUR(NEW.Timestamp) >= 18 OR HOUR(NEW.Timestamp) < 6) AND NOT EXISTS (
        SELECT 1 FROM userbadge WHERE UserID = NEW.UserID AND BadgeID = (SELECT BadgeID FROM badge WHERE BadgeName='Night Owl')
    ) THEN
        INSERT INTO userbadge(UserID, BadgeID)
        SELECT NEW.UserID, BadgeID FROM badge WHERE BadgeName='Night Owl';

        INSERT INTO notification(UserID, ReportID, Title, Body, DataJSON)
        SELECT NEW.UserID, NEW.ReportID,
               CONCAT('Badge Earned: Night Owl'),
               'Congratulations! You earned the "Night Owl" badge!',
               JSON_OBJECT('BadgeID', BadgeID, 'BadgeName','Night Owl', 'EarnedAt', NOW())
        FROM badge WHERE BadgeName='Night Owl';
    END IF;

    -- Daily Hero (7 consecutive days)
    IF (SELECT COUNT(DISTINCT DATE(Timestamp))
        FROM potholereport
        WHERE UserID = NEW.UserID
          AND Timestamp >= DATE_SUB(CURDATE(), INTERVAL 6 DAY)) = 7
        AND NOT EXISTS (
            SELECT 1 FROM userbadge WHERE UserID = NEW.UserID AND BadgeID = (SELECT BadgeID FROM badge WHERE BadgeName='Daily Hero')
        )
    THEN
        INSERT INTO userbadge(UserID, BadgeID)
        SELECT NEW.UserID, BadgeID FROM badge WHERE BadgeName='Daily Hero';

        INSERT INTO notification(UserID, ReportID, Title, Body, DataJSON)
        SELECT NEW.UserID, NEW.ReportID,
               CONCAT('Badge Earned: Daily Hero'),
               'Congratulations! You earned the "Daily Hero" badge!',
               JSON_OBJECT('BadgeID', BadgeID, 'BadgeName','Daily Hero', 'EarnedAt', NOW())
        FROM badge WHERE BadgeName='Daily Hero';
    END IF;

    -- Weekly Watch (28 days)
    IF (SELECT COUNT(DISTINCT DATE(Timestamp))
        FROM potholereport
        WHERE UserID = NEW.UserID
          AND Timestamp >= DATE_SUB(CURDATE(), INTERVAL 27 DAY)) >= 28
        AND NOT EXISTS (
            SELECT 1 FROM userbadge WHERE UserID = NEW.UserID AND BadgeID = (SELECT BadgeID FROM badge WHERE BadgeName='Weekly Watch')
        )
    THEN
        INSERT INTO userbadge(UserID, BadgeID)
        SELECT NEW.UserID, BadgeID FROM badge WHERE BadgeName='Weekly Watch';

        INSERT INTO notification(UserID, ReportID, Title, Body, DataJSON)
        SELECT NEW.UserID, NEW.ReportID,
               CONCAT('Badge Earned: Weekly Watch'),
               'Congratulations! You earned the "Weekly Watch" badge!',
               JSON_OBJECT('BadgeID', BadgeID, 'BadgeName','Weekly Watch', 'EarnedAt', NOW())
        FROM badge WHERE BadgeName='Weekly Watch';
    END IF;
END
$$
DELIMITER ;
DELIMITER $$
CREATE TRIGGER `trg_pothole_status_notify` AFTER UPDATE ON `potholereport` FOR EACH ROW BEGIN
  IF NEW.`Status` <> OLD.`Status` THEN
    INSERT INTO `notification`
      (`UserID`, `ReportID`, `Title`, `Body`, `DataJSON`)
    VALUES
      (
        NEW.`UserID`,
        NEW.`ReportID`,
        CONCAT('Pothole #', NEW.`ReportID`, ' status updated'),
        CONCAT('Status changed from ', OLD.`Status`, ' to ', NEW.`Status`, '.'),
        JSON_OBJECT(
          'old_status', OLD.`Status`,
          'new_status', NEW.`Status`
        )
      );
  END IF;
END
$$
DELIMITER ;

-- --------------------------------------------------------

--
-- Table structure for table `pothole_confirmation`
--

CREATE TABLE `pothole_confirmation` (
  `ValidationID` int(11) NOT NULL,
  `ReportID` int(11) NOT NULL,
  `UserID` int(11) NOT NULL,
  `Timestamp` datetime NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `pothole_confirmation`
--

INSERT INTO `pothole_confirmation` (`ValidationID`, `ReportID`, `UserID`, `Timestamp`) VALUES
(1, 4, 5, '2025-09-01 01:39:57'),
(2, 4, 11, '2025-09-01 01:39:57'),
(3, 4, 2, '2025-09-01 01:39:57'),
(4, 8, 10, '2025-09-01 01:39:57'),
(5, 8, 9, '2025-09-01 01:39:57'),
(6, 12, 5, '2025-09-01 01:39:57'),
(7, 12, 16, '2025-09-01 01:39:57'),
(8, 1, 3, '2025-09-01 01:39:57'),
(9, 1, 14, '2025-09-01 01:39:57'),
(10, 25, 13, '2025-09-01 01:39:57'),
(11, 25, 8, '2025-09-01 01:39:57'),
(12, 17, 15, '2025-09-01 01:39:57'),
(13, 17, 20, '2025-09-01 01:39:57'),
(14, 9, 18, '2025-09-01 01:39:57'),
(15, 2, 11, '2025-09-01 01:39:57'),
(16, 26, 7, '2025-09-01 01:39:57'),
(17, 24, 14, '2025-09-01 01:39:57'),
(18, 27, 6, '2025-09-01 01:39:57'),
(19, 19, 4, '2025-09-01 01:39:57'),
(20, 14, 20, '2025-09-01 01:39:57'),
(21, 28, 3, '2025-09-01 01:39:57'),
(22, 18, 2, '2025-09-01 01:39:57'),
(23, 6, 17, '2025-09-01 01:39:57'),
(24, 22, 19, '2025-09-01 01:39:57'),
(25, 5, 12, '2025-09-01 01:39:57'),
(26, 27, 1, '2025-09-01 01:53:24'),
(27, 25, 1, '2025-09-01 12:31:27'),
(28, 29, 20, '2025-09-13 13:32:35');

--
-- Triggers `pothole_confirmation`
--
DELIMITER $$
CREATE TRIGGER `trg_award_validation_badges` AFTER INSERT ON `pothole_confirmation` FOR EACH ROW BEGIN
    DECLARE user_validations INT;
    DECLARE user_upvotes INT;

    -- Fact Finder: first validation
    IF (SELECT COUNT(*) FROM pothole_confirmation WHERE UserID=NEW.UserID) = 1
        AND NOT EXISTS (
            SELECT 1 FROM userbadge WHERE UserID = NEW.UserID AND BadgeID = (SELECT BadgeID FROM badge WHERE BadgeName='Fact Finder')
        )
    THEN
        INSERT INTO userbadge(UserID, BadgeID)
        SELECT NEW.UserID, BadgeID FROM badge WHERE BadgeName='Fact Finder';

        INSERT INTO notification(UserID, ReportID, Title, Body, DataJSON)
        SELECT NEW.UserID, NEW.ReportID,
               'Badge Earned: Fact Finder',
               'Congratulations! You earned the "Fact Finder" badge!',
               JSON_OBJECT('BadgeID', BadgeID, 'BadgeName','Fact Finder', 'EarnedAt', NOW())
        FROM badge WHERE BadgeName='Fact Finder';
    END IF;

    -- Trusted Witness: 20 validations
    SELECT COUNT(*) INTO user_validations 
    FROM pothole_confirmation WHERE UserID=NEW.UserID;

    IF user_validations = 20 AND NOT EXISTS (
        SELECT 1 FROM userbadge WHERE UserID = NEW.UserID AND BadgeID = (SELECT BadgeID FROM badge WHERE BadgeName='Trusted Witness')
    ) THEN
        INSERT INTO userbadge(UserID, BadgeID)
        SELECT NEW.UserID, BadgeID FROM badge WHERE BadgeName='Trusted Witness';

        INSERT INTO notification(UserID, ReportID, Title, Body, DataJSON)
        SELECT NEW.UserID, NEW.ReportID,
               'Badge Earned: Trusted Witness',
               'Congratulations! You earned the "Trusted Witness" badge!',
               JSON_OBJECT('BadgeID', BadgeID, 'BadgeName','Trusted Witness', 'EarnedAt', NOW())
        FROM badge WHERE BadgeName='Trusted Witness';
    END IF;

    -- Community Booster: 50 validations
    IF user_validations = 50 AND NOT EXISTS (
        SELECT 1 FROM userbadge WHERE UserID = NEW.UserID AND BadgeID = (SELECT BadgeID FROM badge WHERE BadgeName='Community Booster')
    ) THEN
        INSERT INTO userbadge(UserID, BadgeID)
        SELECT NEW.UserID, BadgeID FROM badge WHERE BadgeName='Community Booster';

        INSERT INTO notification(UserID, ReportID, Title, Body, DataJSON)
        SELECT NEW.UserID, NEW.ReportID,
               'Badge Earned: Community Booster',
               'Congratulations! You earned the "Community Booster" badge!',
               JSON_OBJECT('BadgeID', BadgeID, 'BadgeName','Community Booster', 'EarnedAt', NOW())
        FROM badge WHERE BadgeName='Community Booster';
    END IF;

END
$$
DELIMITER ;
DELIMITER $$
CREATE TRIGGER `trg_pothole_confirmation_notify` AFTER INSERT ON `pothole_confirmation` FOR EACH ROW BEGIN
    DECLARE report_owner INT;
    DECLARE confirmer_name VARCHAR(255);
    DECLARE display_name VARCHAR(255);
    DECLARE body_text VARCHAR(255);

    -- Fetch report owner
    SELECT UserID INTO report_owner
    FROM potholereport
    WHERE ReportID = NEW.ReportID;

    -- Only notify if:
    --  * report exists (FK assures)
    --  * confirmer is not the owner
    IF report_owner IS NOT NULL AND report_owner <> NEW.UserID THEN

        -- Fetch confirmer name
        SELECT Name INTO confirmer_name
        FROM user
        WHERE UserID = NEW.UserID
        LIMIT 1;

        IF confirmer_name IS NULL THEN
            SET confirmer_name = 'Someone';
        END IF;
        SET display_name = confirmer_name;

        -- Build body (keep short)
        SET body_text = CONCAT(
            display_name,
            ' confirmed your pothole report.'
        );

        INSERT INTO notification
            (UserID, ReportID, Title, Body, DataJSON)
        VALUES
            (
                report_owner,
                NEW.ReportID,
                CONCAT('Pothole #', NEW.ReportID, ' confirmed'),
                body_text,
                JSON_OBJECT(
                    'type', 'pothole_confirmation',
                    'ValidationID', NEW.ValidationID,
                    'ReportID', NEW.ReportID,
                    'ConfirmerUserID', NEW.UserID,
                    'ConfirmerName', confirmer_name,
                    'ConfirmedAt', DATE_FORMAT(NEW.Timestamp, '%Y-%m-%d %H:%i:%s')
                )
            );
    END IF;
END
$$
DELIMITER ;

-- --------------------------------------------------------

--
-- Table structure for table `user`
--

CREATE TABLE `user` (
  `UserID` int(11) NOT NULL,
  `Name` varchar(255) NOT NULL,
  `Email` varchar(255) NOT NULL,
  `PasswordHash` varchar(255) NOT NULL,
  `Points` int(11) DEFAULT 0
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `user`
--

INSERT INTO `user` (`UserID`, `Name`, `Email`, `PasswordHash`, `Points`) VALUES
(1, 'Test User 1', 'testuser1@gmail.com', '$2y$10$u65jXE/2TeQmxJNTKF1FGulZ48ZT6/pFUJT0l/TJACYsNGlAP5you', 20),
(2, 'Test User 2', 'testuser2@gmail.com', '$2y$10$u65jXE/2TeQmxJNTKF1FGulZ48ZT6/pFUJT0l/TJACYsNGlAP5you', 15),
(3, 'Test User 3', 'testuser3@gmail.com', '$2y$10$u65jXE/2TeQmxJNTKF1FGulZ48ZT6/pFUJT0l/TJACYsNGlAP5you', 10),
(4, 'Test User 4', 'testuser4@gmail.com', '$2y$10$u65jXE/2TeQmxJNTKF1FGulZ48ZT6/pFUJT0l/TJACYsNGlAP5you', 5),
(5, 'Test User 5', 'testuser5@gmail.com', '$2y$10$u65jXE/2TeQmxJNTKF1FGulZ48ZT6/pFUJT0l/TJACYsNGlAP5you', 10),
(6, 'Test User 6', 'testuser6@gmail.com', '$2y$10$u65jXE/2TeQmxJNTKF1FGulZ48ZT6/pFUJT0l/TJACYsNGlAP5you', 5),
(7, 'Test User 7', 'testuser7@gmail.com', '$2y$10$u65jXE/2TeQmxJNTKF1FGulZ48ZT6/pFUJT0l/TJACYsNGlAP5you', 35),
(8, 'Test User 8', 'testuser8@gmail.com', '$2y$10$u65jXE/2TeQmxJNTKF1FGulZ48ZT6/pFUJT0l/TJACYsNGlAP5you', 5),
(9, 'Test User 9', 'testuser9@gmail.com', '$2y$10$u65jXE/2TeQmxJNTKF1FGulZ48ZT6/pFUJT0l/TJACYsNGlAP5you', 5),
(10, 'Test User 10', 'testuser10@gmail.com', '$2y$10$u65jXE/2TeQmxJNTKF1FGulZ48ZT6/pFUJT0l/TJACYsNGlAP5you', 5),
(11, 'Test User 11', 'testuser11@gmail.com', '$2y$10$u65jXE/2TeQmxJNTKF1FGulZ48ZT6/pFUJT0l/TJACYsNGlAP5you', 10),
(12, 'Test User 12', 'testuser12@gmail.com', '$2y$10$u65jXE/2TeQmxJNTKF1FGulZ48ZT6/pFUJT0l/TJACYsNGlAP5you', 5),
(13, 'Test User 13', 'testuser13@gmail.com', '$2y$10$u65jXE/2TeQmxJNTKF1FGulZ48ZT6/pFUJT0l/TJACYsNGlAP5you', 5),
(14, 'Test User 14', 'testuser14@gmail.com', '$2y$10$u65jXE/2TeQmxJNTKF1FGulZ48ZT6/pFUJT0l/TJACYsNGlAP5you', 10),
(15, 'Test User 15', 'testuser15@gmail.com', '$2y$10$u65jXE/2TeQmxJNTKF1FGulZ48ZT6/pFUJT0l/TJACYsNGlAP5you', 25),
(16, 'Test User 16', 'testuser16@gmail.com', '$2y$10$u65jXE/2TeQmxJNTKF1FGulZ48ZT6/pFUJT0l/TJACYsNGlAP5you', 5),
(17, 'Test User 17', 'testuser17@gmail.com', '$2y$10$u65jXE/2TeQmxJNTKF1FGulZ48ZT6/pFUJT0l/TJACYsNGlAP5you', 5),
(18, 'Test User 18', 'testuser18@gmail.com', '$2y$10$u65jXE/2TeQmxJNTKF1FGulZ48ZT6/pFUJT0l/TJACYsNGlAP5you', 40),
(19, 'Test User 19', 'testuser19@gmail.com', '$2y$10$u65jXE/2TeQmxJNTKF1FGulZ48ZT6/pFUJT0l/TJACYsNGlAP5you', 5),
(20, 'Test User 20', 'testuser20@gmail.com', '$2y$10$u65jXE/2TeQmxJNTKF1FGulZ48ZT6/pFUJT0l/TJACYsNGlAP5you', 65),
(21, 'Dillon Fernandez', 'admin+68c522b9702ea@local', '$2y$10$EjjxGwYtpfGzXyNaTik1EugdXMLJuCL0k1UKDbv1unpQtgqQGY7oO', 0),
(22, 'Dillon Fernandez', 'admin+68c522e67d9ca@local', '$2y$10$hKpIwfGKRa7EjrBXdWxZ8.a.syFGyW3kszYJEd2Jdei6k7M/BslPK', 0),
(23, 'Dillon Fernandez', 'admin+68c5231fbf511@local', '$2y$10$xLY87yCyyoPIDaEbZvbvCO9BGa8rATKG5CIpzr2pS.KuehzC84VyS', 0),
(24, 'Dillon Fernandez', 'admin+68c5235c12701@local', '$2y$10$K17obkaSqb.68s0I.I.BK.g/IWsnZrJDgDLuRloZQL7QO0syBVbte', 0),
(25, 'Dillon Fernandez', 'admin+68c523bbcfc8e@local', '$2y$10$Ip3XhhmdqUh.hIjVlj0PcuBK6XSOzMTuDYVQU5knN00vxfGIXGRcm', 0);

-- --------------------------------------------------------

--
-- Table structure for table `userbadge`
--

CREATE TABLE `userbadge` (
  `UserBadgeID` int(11) NOT NULL,
  `UserID` int(11) NOT NULL,
  `BadgeID` int(11) NOT NULL,
  `EarnedAt` datetime NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `userbadge`
--

INSERT INTO `userbadge` (`UserBadgeID`, `UserID`, `BadgeID`, `EarnedAt`) VALUES
(1, 2, 1, '2025-07-26 10:00:00'),
(2, 7, 1, '2025-07-27 11:00:00'),
(3, 15, 1, '2025-07-29 14:30:00'),
(4, 18, 1, '2025-08-02 17:30:00'),
(5, 20, 1, '2025-08-04 11:00:00'),
(6, 1, 1, '2025-08-23 23:04:24'),
(7, 1, 14, '2025-08-23 23:04:24'),
(8, 1, 8, '2025-08-23 23:07:19'),
(9, 15, 8, '2025-08-23 23:34:09'),
(10, 18, 8, '2025-08-23 23:34:09'),
(11, 7, 8, '2025-08-23 23:34:09'),
(12, 5, 5, '2025-09-01 01:39:57'),
(13, 11, 5, '2025-09-01 01:39:57'),
(14, 2, 5, '2025-09-01 01:39:57'),
(15, 10, 5, '2025-09-01 01:39:57'),
(16, 9, 5, '2025-09-01 01:39:57'),
(17, 16, 5, '2025-09-01 01:39:57'),
(18, 3, 5, '2025-09-01 01:39:57'),
(19, 14, 5, '2025-09-01 01:39:57'),
(20, 13, 5, '2025-09-01 01:39:57'),
(21, 8, 5, '2025-09-01 01:39:57'),
(22, 15, 5, '2025-09-01 01:39:57'),
(23, 20, 5, '2025-09-01 01:39:57'),
(24, 18, 5, '2025-09-01 01:39:57'),
(25, 7, 5, '2025-09-01 01:39:57'),
(26, 6, 5, '2025-09-01 01:39:57'),
(27, 4, 5, '2025-09-01 01:39:57'),
(28, 17, 5, '2025-09-01 01:39:57'),
(29, 19, 5, '2025-09-01 01:39:57'),
(30, 12, 5, '2025-09-01 01:39:57'),
(31, 1, 5, '2025-09-01 01:53:24');

--
-- Indexes for dumped tables
--

--
-- Indexes for table `admin`
--
ALTER TABLE `admin`
  ADD PRIMARY KEY (`AdminID`),
  ADD UNIQUE KEY `Email` (`Email`);

--
-- Indexes for table `badge`
--
ALTER TABLE `badge`
  ADD PRIMARY KEY (`BadgeID`),
  ADD UNIQUE KEY `BadgeName` (`BadgeName`);

--
-- Indexes for table `chat_messages`
--
ALTER TABLE `chat_messages`
  ADD PRIMARY KEY (`MessageID`),
  ADD KEY `fk_chat_user` (`UserID`),
  ADD KEY `idx_chat_report_created` (`ReportID`,`CreatedAt`),
  ADD KEY `idx_chat_report_id` (`ReportID`,`MessageID`);

--
-- Indexes for table `notification`
--
ALTER TABLE `notification`
  ADD PRIMARY KEY (`NotificationID`),
  ADD KEY `idx_user_created` (`UserID`,`CreatedAt`),
  ADD KEY `idx_report_created` (`ReportID`,`CreatedAt`);

--
-- Indexes for table `potholereport`
--
ALTER TABLE `potholereport`
  ADD PRIMARY KEY (`ReportID`),
  ADD KEY `UserID` (`UserID`);

--
-- Indexes for table `pothole_confirmation`
--
ALTER TABLE `pothole_confirmation`
  ADD PRIMARY KEY (`ValidationID`),
  ADD UNIQUE KEY `ReportID` (`ReportID`,`UserID`),
  ADD KEY `UserID` (`UserID`);

--
-- Indexes for table `user`
--
ALTER TABLE `user`
  ADD PRIMARY KEY (`UserID`),
  ADD UNIQUE KEY `Email` (`Email`);

--
-- Indexes for table `userbadge`
--
ALTER TABLE `userbadge`
  ADD PRIMARY KEY (`UserBadgeID`),
  ADD KEY `UserID` (`UserID`),
  ADD KEY `BadgeID` (`BadgeID`);

--
-- AUTO_INCREMENT for dumped tables
--

--
-- AUTO_INCREMENT for table `admin`
--
ALTER TABLE `admin`
  MODIFY `AdminID` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=5;

--
-- AUTO_INCREMENT for table `badge`
--
ALTER TABLE `badge`
  MODIFY `BadgeID` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=15;

--
-- AUTO_INCREMENT for table `chat_messages`
--
ALTER TABLE `chat_messages`
  MODIFY `MessageID` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=19;

--
-- AUTO_INCREMENT for table `notification`
--
ALTER TABLE `notification`
  MODIFY `NotificationID` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=64;

--
-- AUTO_INCREMENT for table `potholereport`
--
ALTER TABLE `potholereport`
  MODIFY `ReportID` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=30;

--
-- AUTO_INCREMENT for table `pothole_confirmation`
--
ALTER TABLE `pothole_confirmation`
  MODIFY `ValidationID` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=29;

--
-- AUTO_INCREMENT for table `user`
--
ALTER TABLE `user`
  MODIFY `UserID` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=26;

--
-- AUTO_INCREMENT for table `userbadge`
--
ALTER TABLE `userbadge`
  MODIFY `UserBadgeID` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=32;

--
-- Constraints for dumped tables
--

--
-- Constraints for table `chat_messages`
--
ALTER TABLE `chat_messages`
  ADD CONSTRAINT `fk_chat_report` FOREIGN KEY (`ReportID`) REFERENCES `potholereport` (`ReportID`) ON DELETE CASCADE,
  ADD CONSTRAINT `fk_chat_user` FOREIGN KEY (`UserID`) REFERENCES `user` (`UserID`) ON DELETE CASCADE;

--
-- Constraints for table `notification`
--
ALTER TABLE `notification`
  ADD CONSTRAINT `fk_notification_report` FOREIGN KEY (`ReportID`) REFERENCES `potholereport` (`ReportID`) ON DELETE CASCADE,
  ADD CONSTRAINT `fk_notification_user` FOREIGN KEY (`UserID`) REFERENCES `user` (`UserID`) ON DELETE CASCADE;

--
-- Constraints for table `potholereport`
--
ALTER TABLE `potholereport`
  ADD CONSTRAINT `potholereport_ibfk_1` FOREIGN KEY (`UserID`) REFERENCES `user` (`UserID`);

--
-- Constraints for table `pothole_confirmation`
--
ALTER TABLE `pothole_confirmation`
  ADD CONSTRAINT `pothole_confirmation_ibfk_1` FOREIGN KEY (`ReportID`) REFERENCES `potholereport` (`ReportID`) ON DELETE CASCADE,
  ADD CONSTRAINT `pothole_confirmation_ibfk_2` FOREIGN KEY (`UserID`) REFERENCES `user` (`UserID`) ON DELETE CASCADE;

--
-- Constraints for table `userbadge`
--
ALTER TABLE `userbadge`
  ADD CONSTRAINT `userbadge_ibfk_1` FOREIGN KEY (`UserID`) REFERENCES `user` (`UserID`),
  ADD CONSTRAINT `userbadge_ibfk_2` FOREIGN KEY (`BadgeID`) REFERENCES `badge` (`BadgeID`);
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
