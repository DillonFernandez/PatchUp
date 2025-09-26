-- phpMyAdmin SQL Dump
-- version 5.2.1
-- https://www.phpmyadmin.net/
--
-- Host: 127.0.0.1
-- Generation Time: Sep 26, 2025 at 10:12 AM
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
(1, 1, 1, 'I reported a pothole last week. Any update on it?', '2025-09-25 18:53:58', NULL, 0, 0, 0),
(2, 1, 7, 'Your report is in the system. It has already been validated by two people.', '2025-09-25 19:03:58', NULL, 0, 0, 1),
(3, 1, 1, 'What happens next?', '2025-09-25 19:04:12', NULL, 0, 0, 0),
(4, 1, 8, 'With multiple validations, it is now in the queue for field inspection.', '2025-09-25 19:04:21', NULL, 0, 0, 1),
(5, 1, 1, 'Okay', '2025-09-25 19:04:37', '2025-09-25 19:04:48', 1, 0, 0),
(6, 1, 9, 'You will receive a notification once the inspection is completed.', '2025-09-25 19:04:58', NULL, 0, 0, 1),
(7, 1, 1, 'I think this process will take too long.', '2025-09-25 19:05:20', '2025-09-25 19:05:24', 0, 1, 0),
(8, 1, 1, 'Admin, will I be able to see who validated it', '2025-09-25 19:05:40', NULL, 0, 0, 0),
(9, 1, 10, 'The validation notification will show the names, but not their contact details.', '2025-09-25 19:06:09', NULL, 0, 0, 1),
(10, 1, 1, 'Alright', '2025-09-25 19:06:19', '2025-09-25 19:06:37', 1, 0, 0),
(11, 1, 11, 'Your report has been marked are in progress', '2025-09-25 19:31:31', NULL, 0, 0, 1),
(12, 1, 1, '👍', '2025-09-25 19:32:01', NULL, 0, 0, 0);

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
(1, 1, 1, 'Pothole #1 validated', 'Ishara Rathnayake validated your pothole report.', '{\"type\": \"pothole_validation\", \"ValidationID\": 1, \"ReportID\": 1, \"ValidatorUserID\": 5, \"ValidatorName\": \"Ishara Rathnayake\", \"ValidatedAt\": \"2025-09-16 14:54:42\"}', 1, '2025-09-16 14:54:42', '2025-09-25 19:07:15'),
(2, 1, 1, 'Pothole #1 validated', 'Tharindu Jayasuriya validated your pothole report.', '{\"type\": \"pothole_validation\", \"ValidationID\": 2, \"ReportID\": 1, \"ValidatorUserID\": 4, \"ValidatorName\": \"Tharindu Jayasuriya\", \"ValidatedAt\": \"2025-09-16 14:55:37\"}', 1, '2025-09-16 14:55:37', '2025-09-25 19:07:15'),
(3, 1, 1, 'Pothole #1 validated', 'Hiranya Nirmal validated your pothole report.', '{\"type\": \"pothole_validation\", \"ValidationID\": 4, \"ReportID\": 1, \"ValidatorUserID\": 6, \"ValidatorName\": \"Hiranya Nirmal\", \"ValidatedAt\": \"2025-09-25 18:36:57\"}', 1, '2025-09-25 18:36:57', '2025-09-25 19:07:15'),
(4, 1, 1, 'New message on Pothole #1', 'Dillon Fernandez | Admin commented: \"Your report is in the system. It has already been validated by two people.\"', '{\"type\": \"chat_message\", \"MessageID\": 2, \"ReportID\": 1, \"SenderUserID\": 7, \"IsAdmin\": 1, \"SenderName\": \"Dillon Fernandez\", \"SenderDisplayName\": \"Dillon Fernandez | Admin\", \"MessageText\": \"Your report is in the system. It has already been validated by two people.\", \"CreatedAt\": \"2025-09-25 19:03:58\"}', 1, '2025-09-25 19:03:58', '2025-09-25 19:07:15'),
(5, 1, 1, 'New message on Pothole #1', 'Dillon Fernandez | Admin commented: \"With multiple validations, it is now in the queue for field inspection.\"', '{\"type\": \"chat_message\", \"MessageID\": 4, \"ReportID\": 1, \"SenderUserID\": 8, \"IsAdmin\": 1, \"SenderName\": \"Dillon Fernandez\", \"SenderDisplayName\": \"Dillon Fernandez | Admin\", \"MessageText\": \"With multiple validations, it is now in the queue for field inspection.\", \"CreatedAt\": \"2025-09-25 19:04:21\"}', 1, '2025-09-25 19:04:21', '2025-09-25 19:07:15'),
(6, 1, 1, 'New message on Pothole #1', 'Dillon Fernandez | Admin commented: \"You will receive a notification once the inspection is completed.\"', '{\"type\": \"chat_message\", \"MessageID\": 6, \"ReportID\": 1, \"SenderUserID\": 9, \"IsAdmin\": 1, \"SenderName\": \"Dillon Fernandez\", \"SenderDisplayName\": \"Dillon Fernandez | Admin\", \"MessageText\": \"You will receive a notification once the inspection is completed.\", \"CreatedAt\": \"2025-09-25 19:04:58\"}', 1, '2025-09-25 19:04:58', '2025-09-25 19:07:15'),
(7, 1, 1, 'New message on Pothole #1', 'Dillon Fernandez | Admin commented: \"The validation notification will show the names, but not their contact details.\"', '{\"type\": \"chat_message\", \"MessageID\": 9, \"ReportID\": 1, \"SenderUserID\": 10, \"IsAdmin\": 1, \"SenderName\": \"Dillon Fernandez\", \"SenderDisplayName\": \"Dillon Fernandez | Admin\", \"MessageText\": \"The validation notification will show the names, but not their contact details.\", \"CreatedAt\": \"2025-09-25 19:06:09\"}', 1, '2025-09-25 19:06:09', '2025-09-25 19:07:15'),
(8, 1, 1, 'Pothole #1 status updated', 'Status changed from Reported to In Progress.', '{\"old_status\": \"Reported\", \"new_status\": \"In Progress\"}', 1, '2025-09-25 19:31:17', '2025-09-26 13:23:54'),
(9, 1, 1, 'New message on Pothole #1', 'Hiranya Nirmal | Admin commented: \"Your report has been marked are in progress\"', '{\"type\": \"chat_message\", \"MessageID\": 11, \"ReportID\": 1, \"SenderUserID\": 11, \"IsAdmin\": 1, \"SenderName\": \"Hiranya Nirmal\", \"SenderDisplayName\": \"Hiranya Nirmal | Admin\", \"MessageText\": \"Your report has been marked are in progress\", \"CreatedAt\": \"2025-09-25 19:31:31\"}', 1, '2025-09-25 19:31:31', '2025-09-26 13:23:54'),
(10, 1, 1, 'Pothole #1 validated', 'Nadeesha Silva validated your pothole report.', '{\"type\": \"pothole_validation\", \"ValidationID\": 5, \"ReportID\": 1, \"ValidatorUserID\": 3, \"ValidatorName\": \"Nadeesha Silva\", \"ValidatedAt\": \"2025-09-26 13:34:42\"}', 0, '2025-09-26 13:34:42', NULL);

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
(1, 1, 'Small Pothole Near Kandana Station Road Food City', 'Small', '/patchup_app/uploads/img_68a2a2b8e1139_69d786b5-a9a8-47a2-a383-4aad6023585c6346341258487748645.jpg', '2025-09-16 14:52:40', 'In Progress', 'Western Province', 7.047527, 79.899396),
(2, 3, 'Moderate Pothole Near Kandana Station Road Temple', 'Moderate', '/patchup_app/uploads/img_68d649721f835_7cc3dd04-f719-4624-a20d-27d05f22f6038074854529183763235.jpg', '2025-09-26 13:36:10', 'Reported', 'Western Province', 7.047645, 79.899417);

--
-- Triggers `potholereport`
--
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
-- Table structure for table `pothole_validation`
--

CREATE TABLE `pothole_validation` (
  `ValidationID` int(11) NOT NULL,
  `ReportID` int(11) NOT NULL,
  `UserID` int(11) NOT NULL,
  `Timestamp` datetime NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `pothole_validation`
--

INSERT INTO `pothole_validation` (`ValidationID`, `ReportID`, `UserID`, `Timestamp`) VALUES
(1, 1, 5, '2025-09-16 14:54:42'),
(2, 1, 4, '2025-09-16 14:55:37'),
(3, 1, 6, '2025-09-25 18:36:57');

--
-- Triggers `pothole_validation`
--
DELIMITER $$
CREATE TRIGGER `trg_pothole_validation_notify` AFTER INSERT ON `pothole_validation` FOR EACH ROW BEGIN
    DECLARE report_owner INT;
    DECLARE validator_name VARCHAR(255);
    DECLARE display_name VARCHAR(255);
    DECLARE body_text VARCHAR(255);

    -- Fetch report owner
    SELECT UserID INTO report_owner
    FROM potholereport
    WHERE ReportID = NEW.ReportID;

    -- Only notify if:
    --  * report exists (FK assures)
    --  * validator is not the owner
    IF report_owner IS NOT NULL AND report_owner <> NEW.UserID THEN

        -- Fetch validator name
        SELECT Name INTO validator_name
        FROM user
        WHERE UserID = NEW.UserID
        LIMIT 1;

        IF validator_name IS NULL THEN
            SET validator_name = 'Someone';
        END IF;
        SET display_name = validator_name;

        -- Build body (keep short)
        SET body_text = CONCAT(
            display_name,
            ' validated your pothole report.'
        );

        INSERT INTO notification
            (UserID, ReportID, Title, Body, DataJSON)
        VALUES
            (
                report_owner,
                NEW.ReportID,
                CONCAT('Pothole #', NEW.ReportID, ' validated'),
                body_text,
                JSON_OBJECT(
                    'type', 'pothole_validation',
                    'ValidationID', NEW.ValidationID,
                    'ReportID', NEW.ReportID,
                    'ValidatorUserID', NEW.UserID,
                    'ValidatorName', validator_name,
                    'ValidatedAt', DATE_FORMAT(NEW.Timestamp, '%Y-%m-%d %H:%i:%s')
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
  `PasswordHash` varchar(255) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `user`
--

INSERT INTO `user` (`UserID`, `Name`, `Email`, `PasswordHash`) VALUES
(1, 'Dillon Fernandez', 'dillon@gmail.com', '$2y$10$f/3orTFJRINDJLz3LdGzseKJcacSY2CO/8mbciUoa8q2QnffVXRHq'),
(2, 'Kasun Fernando', 'kasun@gmail.com', '$2y$10$f/3orTFJRINDJLz3LdGzseKJcacSY2CO/8mbciUoa8q2QnffVXRHq'),
(3, 'Nadeesha Silva', 'nadeesha@gmail.com', '$2y$10$f/3orTFJRINDJLz3LdGzseKJcacSY2CO/8mbciUoa8q2QnffVXRHq'),
(4, 'Tharindu Jayasuriya', 'tharindu@gmail.com', '$2y$10$f/3orTFJRINDJLz3LdGzseKJcacSY2CO/8mbciUoa8q2QnffVXRHq'),
(5, 'Ishara Rathnayake', 'ishara@gmail.com', '$2y$10$f/3orTFJRINDJLz3LdGzseKJcacSY2CO/8mbciUoa8q2QnffVXRHq'),
(6, 'Hiranya Nirmal', 'hiranya@gmail.com', '$2y$10$ljfy0oj.TJxqchHQ1xHUx.Q3hNTTzYHpHknz4FVDfADZvg2Yui3Z.'),
(7, 'Dillon Fernandez', 'admin+68d544c69b29d@local', '$2y$10$Xdir7kqddUqVeQzRJgmy5u4AgChjObb3Mt/b9LqoBeN9B4a.A8cZC'),
(8, 'Dillon Fernandez', 'admin+68d544dd2415f@local', '$2y$10$FiAbQKmk1Ca3FZm1tmJTB..sBmIWgcmevW/M46oEe1Em9N5NRDf6G'),
(9, 'Dillon Fernandez', 'admin+68d54502d4459@local', '$2y$10$llHCkecOWU5BMbmx8d6zXe3w24bokEjkMdK3EprFLppTDImbPObWK'),
(10, 'Dillon Fernandez', 'admin+68d545491a57c@local', '$2y$10$zpEibQ7iZfMFDxoHGvnFEuBOp4DaiCOTta9LtyqxZqXcX9DmKoDFC'),
(11, 'Hiranya Nirmal', 'admin+68d54b3b5c60e@local', '$2y$10$on48HQOJqoXl7Mv/gYglnOxPTPe.tem30eUyw6txk2HllhchHXCXy');

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
-- Indexes for table `pothole_validation`
--
ALTER TABLE `pothole_validation`
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
-- AUTO_INCREMENT for dumped tables
--

--
-- AUTO_INCREMENT for table `admin`
--
ALTER TABLE `admin`
  MODIFY `AdminID` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=5;

--
-- AUTO_INCREMENT for table `chat_messages`
--
ALTER TABLE `chat_messages`
  MODIFY `MessageID` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=13;

--
-- AUTO_INCREMENT for table `notification`
--
ALTER TABLE `notification`
  MODIFY `NotificationID` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=11;

--
-- AUTO_INCREMENT for table `potholereport`
--
ALTER TABLE `potholereport`
  MODIFY `ReportID` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=3;

--
-- AUTO_INCREMENT for table `pothole_validation`
--
ALTER TABLE `pothole_validation`
  MODIFY `ValidationID` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=4;

--
-- AUTO_INCREMENT for table `user`
--
ALTER TABLE `user`
  MODIFY `UserID` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=12;

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
-- Constraints for table `pothole_validation`
--
ALTER TABLE `pothole_validation`
  ADD CONSTRAINT `pothole_validation_ibfk_1` FOREIGN KEY (`ReportID`) REFERENCES `potholereport` (`ReportID`) ON DELETE CASCADE,
  ADD CONSTRAINT `pothole_validation_ibfk_2` FOREIGN KEY (`UserID`) REFERENCES `user` (`UserID`) ON DELETE CASCADE;
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
