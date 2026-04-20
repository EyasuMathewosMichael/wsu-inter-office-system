-- phpMyAdmin SQL Dump
-- version 5.2.1
-- https://www.phpmyadmin.net/
--
-- Host: 127.0.0.1
-- Generation Time: Mar 02, 2026 at 01:02 PM
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
-- Database: `inter_office_db`
--

-- --------------------------------------------------------

--
-- Table structure for table `announcements`
--

CREATE TABLE `announcements` (
  `announcement_id` int(11) NOT NULL,
  `poster_id` int(11) DEFAULT NULL,
  `title` varchar(200) NOT NULL,
  `content` text NOT NULL,
  `attachment_path` varchar(255) DEFAULT NULL,
  `target_dept` varchar(100) DEFAULT 'All',
  `created_at` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `announcements`
--

INSERT INTO `announcements` (`announcement_id`, `poster_id`, `title`, `content`, `attachment_path`, `target_dept`, `created_at`) VALUES
(5, 1, 'Meeting', 'Meeting Call For All', NULL, 'Global', '2026-02-20 11:58:03'),
(7, 2, 'Meeting Call', 'This is to inform, that we will have meeting on monday, for cs from Arba', '', 'Computer Science', '2026-02-24 13:57:51'),
(8, 1, 'Announcement For all', 'From Admin', NULL, 'Global', '2026-02-24 14:21:59'),
(10, 1, 'exit exam schedule', 'to inform that', 'C:/university_uploads/1772027063766_AI outline.pdf', 'Global', '2026-02-25 13:44:23');

-- --------------------------------------------------------

--
-- Table structure for table `chats`
--

CREATE TABLE `chats` (
  `chat_id` int(11) NOT NULL,
  `sender_id` int(11) DEFAULT NULL,
  `receiver_id` int(11) NOT NULL DEFAULT 0,
  `message` text DEFAULT NULL,
  `reply_to_id` int(11) DEFAULT NULL,
  `attachment_path` varchar(255) DEFAULT '',
  `is_read` tinyint(1) DEFAULT 0,
  `sent_at` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `chats`
--

INSERT INTO `chats` (`chat_id`, `sender_id`, `receiver_id`, `message`, `reply_to_id`, `attachment_path`, `is_read`, `sent_at`) VALUES
(12, 2, 9, 'hi', NULL, '', 1, '2026-02-27 11:25:05'),
(13, 2, 9, '', NULL, 'assets/uploads/1772191519644_578b3a197bdf72755ce8fc4de8ab6e35.jpg', 1, '2026-02-27 11:25:19'),
(14, 2, 9, 'hi', NULL, '', 1, '2026-02-27 11:25:55'),
(15, 9, 2, 'hello', NULL, '', 1, '2026-02-27 11:26:39'),
(16, 2, 9, '', NULL, '', 1, '2026-02-27 11:32:59'),
(17, 2, 9, 'hi', NULL, '', 1, '2026-02-27 11:37:43'),
(22, 2, 9, 'tame endet neh hulu selam', NULL, '', 1, '2026-02-27 12:02:10'),
(23, 9, 2, 'alw dana negn', NULL, '', 1, '2026-02-27 12:02:51'),
(24, 2, 9, '', NULL, '', 1, '2026-02-27 12:03:59'),
(26, 2, 9, 'hello', NULL, '', 1, '2026-02-27 12:07:52'),
(27, 2, 9, 'hi', NULL, '', 1, '2026-02-27 13:26:18'),
(28, 2, 9, '', NULL, 'assets/uploads/1772198790233_josh.png', 1, '2026-02-27 13:26:30'),
(29, 2, 9, 'arif nw', 23, '', 1, '2026-02-27 13:41:33'),
(30, 9, 1, 'hi', NULL, '', 0, '2026-02-27 13:47:37'),
(45, 2, 9, 'hi', NULL, '', 1, '2026-02-27 14:12:17'),
(69, 2, 11, 'hello', NULL, '', 1, '2026-03-02 06:59:43'),
(76, 2, 11, 'hello Cs', NULL, '', 1, '2026-03-02 07:00:26'),
(77, 11, 2, 'ohh', 76, '', 0, '2026-03-02 07:01:13'),
(91, 11, 10, 'hi kasu', NULL, '', 0, '2026-03-02 07:20:00'),
(92, 11, 1, 'hi', NULL, '', 0, '2026-03-02 07:20:07'),
(120, 2, 1, 'hi', NULL, '', 0, '2026-03-02 07:34:46'),
(125, 9, 0, 'hello', NULL, '', 0, '2026-03-02 08:03:00'),
(127, 15, 0, 'hi', 125, '', 0, '2026-03-02 08:06:23'),
(129, 2, 0, '', NULL, 'assets/uploads/1772439841235_1772198790233_josh.png', 0, '2026-03-02 08:24:01'),
(130, 2, 0, '', NULL, 'assets/uploads/1772439857390_1772193839224_alpha.png', 0, '2026-03-02 08:24:17'),
(131, 2, 0, 'hello', NULL, 'assets/uploads/1772439875762_1772193839224_alpha.png', 0, '2026-03-02 08:24:35'),
(132, 9, 0, 'hj', 125, '', 0, '2026-03-02 08:31:19'),
(134, 2, 0, 'hello therre', 131, '', 0, '2026-03-02 08:48:21'),
(135, 2, 0, 'hello there', 127, '', 0, '2026-03-02 08:48:35'),
(136, 2, 0, 'hi', 127, '', 0, '2026-03-02 08:50:53'),
(137, 2, 0, 'hi', 125, '', 0, '2026-03-02 08:52:57'),
(138, 2, 1, 'hello', 120, '', 0, '2026-03-02 09:04:42');

-- --------------------------------------------------------

--
-- Table structure for table `tasks`
--

CREATE TABLE `tasks` (
  `task_id` int(11) NOT NULL,
  `creator_id` int(11) DEFAULT NULL,
  `assignee_id` int(11) DEFAULT NULL,
  `title` varchar(200) NOT NULL,
  `description` text DEFAULT NULL,
  `priority` enum('Low','Medium','High','Urgent') DEFAULT 'Medium',
  `status` enum('Pending','In Progress','Under Review','Completed') DEFAULT 'Pending',
  `due_date` date DEFAULT NULL,
  `initial_attachment_path` varchar(255) DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `staff_reply_text` text DEFAULT NULL,
  `completion_attachment_path` varchar(200) DEFAULT NULL,
  `acknowledged` tinyint(1) DEFAULT 0
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `tasks`
--

INSERT INTO `tasks` (`task_id`, `creator_id`, `assignee_id`, `title`, `description`, `priority`, `status`, `due_date`, `initial_attachment_path`, `created_at`, `staff_reply_text`, `completion_attachment_path`, `acknowledged`) VALUES
(1, 2, 9, 'task1', 'do', 'Urgent', 'Completed', '2026-02-23', NULL, '2026-02-22 13:40:46', 'doneeee', NULL, 0),
(2, 2, 9, 'task 2', 'fill the form', 'High', 'Completed', '2026-02-24', 'C:\\Users\\WINDOWS1\\OneDrive\\Documents\\CS 2nd year\\Test_blueprint_Computer Science.pdf', '2026-02-22 13:45:31', 'done', NULL, 0),
(4, 11, 10, 'Task', 'Fill the form and submit', 'Low', 'Completed', '2026-02-26', 'C:\\Users\\WINDOWS1\\OneDrive\\Documents\\CS 3rd year\\2nd semester\\WC and MC\\WC-MC (Course Overview).pptx', '2026-02-24 12:39:27', 'done', 'C:\\Users\\WINDOWS1\\OneDrive\\Documents\\CS 3rd year\\2nd semester\\AI\\AI outline.pdf', 0),
(5, 11, 10, 'Task2', 'Submit the students grade', 'Medium', 'Pending', '2026-02-27', NULL, '2026-02-24 12:44:47', NULL, NULL, 0);

-- --------------------------------------------------------

--
-- Table structure for table `task_replies`
--

CREATE TABLE `task_replies` (
  `reply_id` int(11) NOT NULL,
  `task_id` int(11) DEFAULT NULL,
  `user_id` int(11) DEFAULT NULL,
  `reply_text` text NOT NULL,
  `attachment_path` varchar(255) DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Table structure for table `password_reset_tokens`
--

CREATE TABLE `password_reset_tokens` (
  `token_id` int(11) NOT NULL,
  `user_id` int(11) NOT NULL,
  `token_hash` char(64) NOT NULL,
  `expires_at` timestamp NOT NULL,
  `used_at` timestamp NULL DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Table structure for table `users`
--

CREATE TABLE `users` (
  `user_id` int(11) NOT NULL,
  `username` varchar(50) NOT NULL,
  `password` varchar(255) NOT NULL,
  `full_name` varchar(100) NOT NULL,
  `role` enum('Admin','Dept Head','Staff') NOT NULL,
  `department` varchar(100) DEFAULT NULL,
  `profile_pic_path` varchar(255) DEFAULT 'default_profile.png',
  `bio` text DEFAULT NULL,
  `phone` varchar(20) DEFAULT NULL,
  `personal_email` varchar(255) DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `users`
--

INSERT INTO `users` (`user_id`, `username`, `password`, `full_name`, `role`, `department`, `profile_pic_path`, `bio`, `phone`, `personal_email`, `created_at`) VALUES
(1, 'admin', 'admin123', 'System Administrator', 'Admin', 'Information Technology', 'default_profile.png', NULL, NULL, NULL, '2026-02-18 10:48:18'),
(2, 'arba', 'arba123', 'Arba Asha', 'Dept Head', 'Computer Science', 'default_profile.png', NULL, NULL, NULL, '2026-02-18 20:30:06'),
(9, 'tame', 'tame123', 'Temesgen Tadesse', 'Staff', 'Computer Science', '1771695203057_578b3a197bdf72755ce8fc4de8ab6e35.jpg', NULL, NULL, NULL, '2026-02-21 17:33:23'),
(10, 'kasu', 'kasu123', 'Mr. Kassahun', 'Staff', 'Information Technology', 'default-avatar.png', NULL, NULL, NULL, '2026-02-24 11:51:29'),
(11, 'beka', 'beka123', 'Mr. Bereket', 'Dept Head', 'Information Technology', 'default-avatar.png', NULL, NULL, NULL, '2026-02-24 11:54:06'),
(13, 'info', 'info123', 'Info System', 'Dept Head', 'Information Systems', 'default-avatar.png', NULL, NULL, NULL, '2026-03-02 07:17:18'),
(14, 'isstaff', 'isstaff123', 'Info Staff', 'Staff', 'Information Systems', 'default-avatar.png', NULL, NULL, NULL, '2026-03-02 07:18:22'),
(15, 'eyob', 'eyob123', 'Mr. Eyob', 'Staff', 'Computer Science', 'default-avatar.png', NULL, NULL, NULL, '2026-03-02 08:03:56');

--
-- Indexes for dumped tables
--

--
-- Indexes for table `announcements`
--
ALTER TABLE `announcements`
  ADD PRIMARY KEY (`announcement_id`),
  ADD KEY `poster_id` (`poster_id`);

--
-- Indexes for table `chats`
--
ALTER TABLE `chats`
  ADD PRIMARY KEY (`chat_id`),
  ADD KEY `sender_id` (`sender_id`),
  ADD KEY `receiver_id` (`receiver_id`),
  ADD KEY `fk_reply_message` (`reply_to_id`);

--
-- Indexes for table `tasks`
--
ALTER TABLE `tasks`
  ADD PRIMARY KEY (`task_id`),
  ADD KEY `creator_id` (`creator_id`),
  ADD KEY `assignee_id` (`assignee_id`);

--
-- Indexes for table `task_replies`
--
ALTER TABLE `task_replies`
  ADD PRIMARY KEY (`reply_id`),
  ADD KEY `task_id` (`task_id`),
  ADD KEY `user_id` (`user_id`);

--
-- Indexes for table `password_reset_tokens`
--
ALTER TABLE `password_reset_tokens`
  ADD PRIMARY KEY (`token_id`),
  ADD KEY `idx_password_reset_user` (`user_id`),
  ADD KEY `idx_password_reset_hash` (`token_hash`);

--
-- Indexes for table `users`
--
ALTER TABLE `users`
  ADD PRIMARY KEY (`user_id`),
  ADD UNIQUE KEY `username` (`username`);

--
-- AUTO_INCREMENT for dumped tables
--

--
-- AUTO_INCREMENT for table `announcements`
--
ALTER TABLE `announcements`
  MODIFY `announcement_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=11;

--
-- AUTO_INCREMENT for table `chats`
--
ALTER TABLE `chats`
  MODIFY `chat_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=139;

--
-- AUTO_INCREMENT for table `tasks`
--
ALTER TABLE `tasks`
  MODIFY `task_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=6;

--
-- AUTO_INCREMENT for table `task_replies`
--
ALTER TABLE `task_replies`
  MODIFY `reply_id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `password_reset_tokens`
--
ALTER TABLE `password_reset_tokens`
  MODIFY `token_id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `users`
--
ALTER TABLE `users`
  MODIFY `user_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=16;

--
-- Constraints for dumped tables
--

--
-- Constraints for table `announcements`
--
ALTER TABLE `announcements`
  ADD CONSTRAINT `announcements_ibfk_1` FOREIGN KEY (`poster_id`) REFERENCES `users` (`user_id`) ON DELETE SET NULL;

--
-- Constraints for table `chats`
--
ALTER TABLE `chats`
  ADD CONSTRAINT `chats_ibfk_1` FOREIGN KEY (`sender_id`) REFERENCES `users` (`user_id`),
  ADD CONSTRAINT `fk_reply_message` FOREIGN KEY (`reply_to_id`) REFERENCES `chats` (`chat_id`) ON DELETE SET NULL;

--
-- Constraints for table `tasks`
--
ALTER TABLE `tasks`
  ADD CONSTRAINT `tasks_ibfk_1` FOREIGN KEY (`creator_id`) REFERENCES `users` (`user_id`),
  ADD CONSTRAINT `tasks_ibfk_2` FOREIGN KEY (`assignee_id`) REFERENCES `users` (`user_id`);

--
-- Constraints for table `task_replies`
--
ALTER TABLE `task_replies`
  ADD CONSTRAINT `task_replies_ibfk_1` FOREIGN KEY (`task_id`) REFERENCES `tasks` (`task_id`) ON DELETE CASCADE,
  ADD CONSTRAINT `task_replies_ibfk_2` FOREIGN KEY (`user_id`) REFERENCES `users` (`user_id`);

--
-- Constraints for table `password_reset_tokens`
--
ALTER TABLE `password_reset_tokens`
  ADD CONSTRAINT `fk_password_reset_user` FOREIGN KEY (`user_id`) REFERENCES `users` (`user_id`) ON DELETE CASCADE;
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
