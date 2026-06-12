-- ═══════════════════════════════════════════════════
--  TORNEXT — Main Database Schema
--  DB Name: exnnnooz_tornext
--  Run this ONCE in phpMyAdmin
-- ═══════════════════════════════════════════════════

SET NAMES utf8mb4;
SET time_zone = '+05:30';

-- ── 1. DEVELOPERS ──────────────────────────────────
CREATE TABLE IF NOT EXISTS `tn_developers` (
  `id`             INT AUTO_INCREMENT PRIMARY KEY,
  `name`           VARCHAR(100) NOT NULL,
  `email`          VARCHAR(255) NOT NULL UNIQUE,
  `mobile`         VARCHAR(15) DEFAULT NULL,
  `username`       VARCHAR(50) DEFAULT NULL UNIQUE,
  `password_hash`  VARCHAR(255) DEFAULT NULL,
  `google_uid`     VARCHAR(128) DEFAULT NULL UNIQUE,
  `avatar_url`     TEXT DEFAULT NULL,
  `referral_code`  VARCHAR(20) DEFAULT NULL UNIQUE,
  `referred_by`    VARCHAR(20) DEFAULT NULL,
  `wallet`         DECIMAL(10,2) DEFAULT 0.00,
  `device_ip`      VARCHAR(50) DEFAULT NULL,
  `plan`           VARCHAR(30) DEFAULT 'free',
  `plan_expires`   BIGINT DEFAULT 0,
  `active_project` INT DEFAULT NULL,
  `permissions_ok` TINYINT DEFAULT 0,
  `active`         TINYINT DEFAULT 1,
  `banned`         TINYINT DEFAULT 0,
  `ban_reason`     TEXT DEFAULT NULL,
  `session_token`  VARCHAR(255) DEFAULT NULL,
  `token_expires`  BIGINT DEFAULT 0,
  `source`         VARCHAR(100) DEFAULT NULL,
  `created_at`     BIGINT NOT NULL,
  `last_login`     BIGINT DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- ── 2. PROJECTS ────────────────────────────────────
CREATE TABLE IF NOT EXISTS `tn_projects` (
  `id`                      INT AUTO_INCREMENT PRIMARY KEY,
  `dev_id`                  INT NOT NULL,
  `app_name`                VARCHAR(100) NOT NULL,
  `app_slug`                VARCHAR(100) NOT NULL UNIQUE,
  `package_name`            VARCHAR(200) DEFAULT NULL,
  `app_logo_url`            TEXT DEFAULT NULL,
  `theme_mode`              VARCHAR(10) DEFAULT 'dark',
  `primary_color`           VARCHAR(20) DEFAULT '#E91E8C',
  `firebase_api_key`        VARCHAR(255) DEFAULT NULL,
  `firebase_auth_domain`    VARCHAR(255) DEFAULT NULL,
  `firebase_project_id`     VARCHAR(255) DEFAULT NULL,
  `firebase_storage_bucket` VARCHAR(255) DEFAULT NULL,
  `firebase_sender_id`      VARCHAR(100) DEFAULT NULL,
  `firebase_app_id`         VARCHAR(255) DEFAULT NULL,
  `firebase_measurement_id` VARCHAR(100) DEFAULT NULL,
  `onesignal_app_id`        VARCHAR(255) DEFAULT NULL,
  `onesignal_rest_key`      VARCHAR(255) DEFAULT NULL,
  `db_name`                 VARCHAR(100) DEFAULT NULL,
  `db_user`                 VARCHAR(100) DEFAULT NULL,
  `db_pass`                 VARCHAR(255) DEFAULT NULL,
  `admin_email`             VARCHAR(255) DEFAULT NULL,
  `admin_mobile`            VARCHAR(15) DEFAULT NULL,
  `admin_password_hash`     VARCHAR(255) DEFAULT NULL,
  `zap_merchant_id`         VARCHAR(255) DEFAULT NULL,
  `zap_secret_key`          VARCHAR(255) DEFAULT NULL,
  `imb_merchant_id`         VARCHAR(255) DEFAULT NULL,
  `imb_secret_key`          VARCHAR(255) DEFAULT NULL,
  `webhook_url`             VARCHAR(500) DEFAULT NULL,
  `subscription_id`         INT DEFAULT NULL,
  `sub_expires`             BIGINT DEFAULT 0,
  `total_users`             INT DEFAULT 0,
  `active_users_today`      INT DEFAULT 0,
  `status`                  VARCHAR(30) DEFAULT 'active',
  `folder_created`          TINYINT DEFAULT 0,
  `apk_status`              VARCHAR(30) DEFAULT 'pending',
  `apk_url`                 TEXT DEFAULT NULL,
  `aab_status`              VARCHAR(30) DEFAULT 'pending',
  `aab_url`                 TEXT DEFAULT NULL,
  `created_at`              BIGINT NOT NULL,
  `updated_at`              BIGINT DEFAULT NULL,
  FOREIGN KEY (`dev_id`) REFERENCES `tn_developers`(`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- ── 3. SUBSCRIPTION PLANS ──────────────────────────
CREATE TABLE IF NOT EXISTS `tn_plans` (
  `id`              INT AUTO_INCREMENT PRIMARY KEY,
  `name`            VARCHAR(50) NOT NULL,
  `price`           DECIMAL(10,2) DEFAULT 0.00,
  `validity_days`   INT DEFAULT 7,
  `max_users`       INT DEFAULT 500,
  `max_active`      INT DEFAULT 50,
  `max_projects`    INT DEFAULT 1,
  `features`        TEXT DEFAULT NULL,
  `is_free`         TINYINT DEFAULT 0,
  `sort_order`      INT DEFAULT 0,
  `active`          TINYINT DEFAULT 1
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- Default Plans
INSERT IGNORE INTO `tn_plans` (`id`,`name`,`price`,`validity_days`,`max_users`,`max_active`,`max_projects`,`is_free`,`sort_order`) VALUES
(1, 'Starter',  0,   7,  500,  50,  2, 1, 1),
(2, 'Basic',    100, 15, 500,  100, 3, 0, 2),
(3, 'Pro',      299, 30, 1000, 150, 5, 0, 3),
(4, 'Growth',   499, 30, 1000, 500, 8, 0, 4),
(5, 'Ultimate', 799, 30, 2000, 800, 15,0, 5);

-- ── 4. SUBSCRIPTIONS (Developer purchases) ─────────
CREATE TABLE IF NOT EXISTS `tn_subscriptions` (
  `id`            INT AUTO_INCREMENT PRIMARY KEY,
  `dev_id`        INT NOT NULL,
  `project_id`    INT DEFAULT NULL,
  `plan_id`       INT NOT NULL,
  `amount`        DECIMAL(10,2) DEFAULT 0.00,
  `payment_ref`   VARCHAR(255) DEFAULT NULL,
  `payment_via`   VARCHAR(30) DEFAULT NULL,
  `status`        VARCHAR(20) DEFAULT 'pending',
  `start_date`    BIGINT DEFAULT NULL,
  `end_date`      BIGINT DEFAULT NULL,
  `created_at`    BIGINT NOT NULL,
  FOREIGN KEY (`dev_id`) REFERENCES `tn_developers`(`id`) ON DELETE CASCADE,
  FOREIGN KEY (`plan_id`) REFERENCES `tn_plans`(`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- ── 5. PAYMENTS ────────────────────────────────────
CREATE TABLE IF NOT EXISTS `tn_payments` (
  `id`            INT AUTO_INCREMENT PRIMARY KEY,
  `dev_id`        INT NOT NULL,
  `order_id`      VARCHAR(128) NOT NULL UNIQUE,
  `amount`        DECIMAL(10,2) DEFAULT NULL,
  `gateway`       VARCHAR(30) DEFAULT NULL,
  `status`        VARCHAR(20) DEFAULT 'pending',
  `payload`       TEXT DEFAULT NULL,
  `plan_id`       INT DEFAULT NULL,
  `project_id`    INT DEFAULT NULL,
  `created_at`    BIGINT NOT NULL,
  `updated_at`    BIGINT DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- ── 6. REFERRALS ───────────────────────────────────
CREATE TABLE IF NOT EXISTS `tn_referrals` (
  `id`            INT AUTO_INCREMENT PRIMARY KEY,
  `referrer_id`   INT NOT NULL,
  `referred_id`   INT NOT NULL,
  `commission`    DECIMAL(10,2) DEFAULT 0.00,
  `status`        VARCHAR(20) DEFAULT 'pending',
  `paid_at`       BIGINT DEFAULT NULL,
  `created_at`    BIGINT NOT NULL,
  FOREIGN KEY (`referrer_id`) REFERENCES `tn_developers`(`id`) ON DELETE CASCADE,
  FOREIGN KEY (`referred_id`) REFERENCES `tn_developers`(`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- ── 7. WALLET TRANSACTIONS ─────────────────────────
CREATE TABLE IF NOT EXISTS `tn_wallet_txns` (
  `id`            INT AUTO_INCREMENT PRIMARY KEY,
  `dev_id`        INT NOT NULL,
  `type`          VARCHAR(30) DEFAULT NULL,
  `amount`        DECIMAL(10,2) DEFAULT NULL,
  `description`   TEXT DEFAULT NULL,
  `ref_id`        VARCHAR(128) DEFAULT NULL,
  `created_at`    BIGINT NOT NULL,
  FOREIGN KEY (`dev_id`) REFERENCES `tn_developers`(`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- ── 8. BUILD QUEUE ─────────────────────────────────
CREATE TABLE IF NOT EXISTS `tn_builds` (
  `id`            INT AUTO_INCREMENT PRIMARY KEY,
  `project_id`    INT NOT NULL,
  `dev_id`        INT NOT NULL,
  `build_type`    VARCHAR(10) DEFAULT 'apk',
  `status`        VARCHAR(20) DEFAULT 'pending',
  `download_url`  TEXT DEFAULT NULL,
  `error_log`     TEXT DEFAULT NULL,
  `requested_at`  BIGINT NOT NULL,
  `started_at`    BIGINT DEFAULT NULL,
  `completed_at`  BIGINT DEFAULT NULL,
  FOREIGN KEY (`project_id`) REFERENCES `tn_projects`(`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- ── 9. SUPPORT TICKETS ─────────────────────────────
CREATE TABLE IF NOT EXISTS `tn_tickets` (
  `id`            INT AUTO_INCREMENT PRIMARY KEY,
  `dev_id`        INT NOT NULL,
  `subject`       VARCHAR(255) DEFAULT NULL,
  `message`       TEXT DEFAULT NULL,
  `status`        VARCHAR(20) DEFAULT 'open',
  `admin_reply`   TEXT DEFAULT NULL,
  `created_at`    BIGINT NOT NULL,
  `updated_at`    BIGINT DEFAULT NULL,
  FOREIGN KEY (`dev_id`) REFERENCES `tn_developers`(`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- ── 10. SUPER ADMIN ────────────────────────────────
CREATE TABLE IF NOT EXISTS `tn_super_admins` (
  `id`            INT AUTO_INCREMENT PRIMARY KEY,
  `name`          VARCHAR(100) DEFAULT NULL,
  `email`         VARCHAR(255) NOT NULL UNIQUE,
  `google_uid`    VARCHAR(128) DEFAULT NULL UNIQUE,
  `session_token` VARCHAR(255) DEFAULT NULL,
  `token_expires` BIGINT DEFAULT 0,
  `active`        TINYINT DEFAULT 1,
  `created_at`    BIGINT NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- ── 11. PAYMENT GATEWAY SETTINGS ───────────────────
CREATE TABLE IF NOT EXISTS `tn_gateway_settings` (
  `k`   VARCHAR(100) PRIMARY KEY,
  `v`   TEXT DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

INSERT IGNORE INTO `tn_gateway_settings` (`k`,`v`) VALUES
('zap_merchant_id',''),
('zap_secret_key',''),
('zap_webhook_url',''),
('imb_merchant_id',''),
('imb_secret_key',''),
('imb_webhook_url',''),
('active_gateway','zap');

-- ── 12. PLATFORM SETTINGS ──────────────────────────
CREATE TABLE IF NOT EXISTS `tn_settings` (
  `k`   VARCHAR(100) PRIMARY KEY,
  `v`   TEXT DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

INSERT IGNORE INTO `tn_settings` (`k`,`v`) VALUES
('platform_name','Tornext'),
('platform_logo',''),
('platform_domain','https://rsybattle.xyz/tornext'),
('referral_commission_percent','10'),
('free_plan_max_projects','2'),
('maintenance_mode','0'),
('signup_enabled','1'),
('github_token','ghp_GJ4M5SN0hsCeB20y7170XzJ4pI5wno2sekTI'),
('github_repo','abhinavrajput7037-cmd/tornext-app'),
('build_engine_status','off');

-- ── 13. ACTIVITY LOG ───────────────────────────────
CREATE TABLE IF NOT EXISTS `tn_logs` (
  `id`         BIGINT AUTO_INCREMENT PRIMARY KEY,
  `type`       VARCHAR(30) DEFAULT NULL,
  `dev_id`     INT DEFAULT NULL,
  `action`     VARCHAR(255) DEFAULT NULL,
  `detail`     TEXT DEFAULT NULL,
  `ip`         VARCHAR(50) DEFAULT NULL,
  `created_at` BIGINT NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- ═══════════════════════════════════════════════════
--  DONE! 13 tables created.
--  Next: shared/tn-db.php
-- ═══════════════════════════════════════════════════

-- Developer Notifications
CREATE TABLE IF NOT EXISTS `tn_notifications` (
  `id` bigint AUTO_INCREMENT PRIMARY KEY,
  `dev_id` int NOT NULL,
  `title` varchar(255) DEFAULT NULL,
  `message` text DEFAULT NULL,
  `type` varchar(30) DEFAULT 'info',
  `is_read` tinyint DEFAULT 0,
  `created_at` bigint NOT NULL,
  KEY `dev_id` (`dev_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
