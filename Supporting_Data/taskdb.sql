/*
 Navicat Premium Data Transfer

 Source Server         : local-mysql
 Source Server Type    : MySQL
 Source Server Version : 80025
 Source Host           : localhost:3306
 Source Schema         : taskdb

 Target Server Type    : MySQL
 Target Server Version : 80025
 File Encoding         : 65001

 Date: 13/08/2021 20:36:26
*/

SET NAMES utf8mb4;
SET FOREIGN_KEY_CHECKS = 0;

-- ----------------------------
-- Table structure for data_claims
-- ----------------------------
DROP TABLE IF EXISTS `data_claims`;
CREATE TABLE `data_claims`  (
  `id` varchar(25) CHARACTER SET utf8 COLLATE utf8_general_ci NOT NULL,
  `member_id` varchar(25) CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT NULL,
  `bank_id` varchar(3) CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT NULL,
  `branch_id` varchar(3) CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT NULL,
  `customer_name` varchar(255) CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT NULL,
  `product_id` varchar(15) CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT NULL,
  `nominal_pengajuan` decimal(30, 2) NULL DEFAULT NULL,
  `tgl_meninggal` date NULL DEFAULT NULL,
  `bulan_meninggal` int NULL DEFAULT NULL,
  `tahun_meninggal` int NULL DEFAULT NULL,
  `tgl_pengajuan` date NULL DEFAULT NULL,
  `bulan_pengajuan` int NULL DEFAULT NULL,
  `tahun_pengajuan` int NULL DEFAULT NULL,
  `keterangan` varchar(255) CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT NULL,
  `tgl_pembayaran` date NULL DEFAULT NULL,
  `bulan_pembayaran` int NULL DEFAULT NULL,
  `tahun_pembayaran` int NULL DEFAULT NULL,
  `claim_status_id` int NULL DEFAULT 1,
  `keterangan_status_claim` varchar(200) CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT NULL,
  `created_at` datetime NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` datetime NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `nominal_dibayarkan` decimal(30, 2) NULL DEFAULT NULL,
  PRIMARY KEY (`id`) USING BTREE
) ENGINE = InnoDB AVG_ROW_LENGTH = 5461 CHARACTER SET = utf8 COLLATE = utf8_general_ci ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of data_claims
-- ----------------------------
INSERT INTO `data_claims` VALUES ('CLM001110202108130TUIPNV3', 'INS2121102020101202XHCZLO', '001', '110', 'IRFAN C', '3100400001', 1000000.00, '2021-08-18', 8, 2021, '2021-08-20', 8, 2021, 'asdsad', NULL, NULL, NULL, 1, 'Dalam tahap review & verifikasi', '2021-08-13 10:38:28', '2021-08-13 10:38:28', NULL);
INSERT INTO `data_claims` VALUES ('CLM212110201903085QX3GOQE', 'AJB21211020190308037E2VT9', '001', '110', 'AMID', '3100400001', 1000000.00, '2018-11-01', 11, 2018, '2019-03-08', 3, 2019, 'meninggal', NULL, NULL, NULL, 2, 'surat kemaitian kurang', '2019-03-08 04:31:44', '2021-08-13 17:17:02', NULL);
INSERT INTO `data_claims` VALUES ('CLM21211020201016BV4PV048', 'AJB21211020201012SAROQEI0', '001', '110', 'IRFAN I', '3100400001', 10000000.00, '2020-10-16', 10, 2020, '2020-10-16', 10, 2020, 'test', '2020-10-16', NULL, NULL, 4, 'Dalam tahap review & verifikasi', '2020-10-16 11:37:57', '2021-08-13 17:17:05', 213123123.00);
INSERT INTO `data_claims` VALUES ('CLM21211020201016Z0W6UD2W', 'AJB212110202010128VDX84NM', '001', '110', 'IRFAN J', '3100400001', 500000.00, '2020-10-16', 10, 2020, '2020-10-16', 10, 2020, 'test', '2020-10-19', NULL, NULL, 6, 'Sudah dibayar', '2020-10-16 10:14:16', '2021-08-13 17:17:05', NULL);
INSERT INTO `data_claims` VALUES ('CLM21211120190321PRFJ3LDU', 'AJB21211120190321033Y5NIM', '001', '110', 'ROHAEDI', '3100400001', 34535345435.00, '2019-03-21', 3, 2019, '2019-03-22', 3, 2019, '435354354353', NULL, NULL, NULL, 1, 'Dalam tahap review & verifikasi', '2019-03-21 03:03:10', '2021-08-13 17:17:08', NULL);
INSERT INTO `data_claims` VALUES ('CLM21211120190321W5TBTUJT', 'AJB21211120190321033Y5NIM', '001', '110', 'ROHAEDI', '3100400001', 32442.00, '2019-03-21', 3, 2019, '2019-03-21', 3, 2019, '2342344', '2020-09-10', NULL, NULL, 6, 'Dibayarkan', '2019-03-21 03:39:27', '2021-08-13 17:17:08', NULL);
INSERT INTO `data_claims` VALUES ('CLM212111202104265Z5JYXF1', 'AJB212111201903210H7DVZZN', '001', '110', 'HARYONO', '3100400001', 9898888.00, '2021-04-15', 4, 2021, '2021-04-14', 4, 2021, NULL, NULL, NULL, NULL, 1, 'Dalam tahap review & verifikasi', '2021-04-26 10:50:45', '2021-08-13 17:17:08', NULL);

-- ----------------------------
-- Table structure for data_hold_members
-- ----------------------------
DROP TABLE IF EXISTS `data_hold_members`;
CREATE TABLE `data_hold_members`  (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `loan_id` varchar(20) CHARACTER SET utf8 COLLATE utf8_general_ci NOT NULL,
  `bank_id` varchar(3) CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT NULL,
  `branch_id` varchar(3) CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT NULL,
  `insurance_id` varchar(3) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `product_id` varchar(15) CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT NULL,
  `total_premi` decimal(20, 2) NULL DEFAULT 0.00,
  `plafond` decimal(20, 2) NULL DEFAULT 0.00,
  `pertanggungan` decimal(20, 2) NULL DEFAULT 0.00,
  `currency` varchar(5) CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT NULL,
  `tenor` int NULL DEFAULT 0,
  `insurance_rate` decimal(10, 2) NULL DEFAULT NULL,
  `start_date` date NULL DEFAULT NULL,
  `end_date` date NULL DEFAULT NULL,
  `customer_deposit_amount` varchar(15) CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT NULL,
  `cif` varchar(10) CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT NULL,
  `customer_name` varchar(255) CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT NULL,
  `birth_date` date NULL DEFAULT NULL,
  `born_place` varchar(100) CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT NULL,
  `job` varchar(200) CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT NULL,
  `periode_upload` date NULL DEFAULT NULL,
  `data_status_id` int NULL DEFAULT NULL,
  `rounding_age` int NULL DEFAULT NULL,
  `rounding_jw` int NULL DEFAULT NULL,
  `sum_age_jw` int NULL DEFAULT NULL,
  `ass_premi_calculation` decimal(30, 2) NULL DEFAULT NULL,
  `validation_status_id` int NULL DEFAULT 0,
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`) USING BTREE,
  UNIQUE INDEX `unique_key`(`loan_id`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 3 AVG_ROW_LENGTH = 8192 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of data_hold_members
-- ----------------------------
INSERT INTO `data_hold_members` VALUES (1, 'GEN2632018070001', '001', '110', NULL, '3100400001', 3624000.00, 230000000.00, 100000000.00, 'IDR', 156, 0.00, '2018-07-02', '2031-07-02', '200110000679', '503200', 'MULYAWATI', '2017-01-05', 'CIAMIS', 'PENSIONS', NULL, 6, 1, 13, 14, 0.00, 2, '2019-03-08 18:12:15', '2021-08-13 17:21:13');
INSERT INTO `data_hold_members` VALUES (2, 'GEN2612018070002', '001', '110', NULL, '3100400001', 3780000.00, 239000000.00, 100000000.00, 'IDR', 168, 0.00, '2018-07-02', '2032-07-02', '200110000679', '502942', 'YONNI KUSWARDIONO', '1912-06-24', 'CIAMIS', 'PENSIONS', NULL, 6, 106, 14, 120, 0.00, 3, '2019-03-08 18:12:15', '2021-08-13 17:21:15');

-- ----------------------------
-- Table structure for data_members
-- ----------------------------
DROP TABLE IF EXISTS `data_members`;
CREATE TABLE `data_members`  (
  `id` varchar(25) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `loan_id` varchar(20) CHARACTER SET utf8 COLLATE utf8_general_ci NOT NULL,
  `polis_number` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `bank_id` varchar(3) CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT NULL,
  `branch_id` varchar(3) CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT NULL,
  `insurance_id` varchar(3) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `product_id` varchar(15) CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT NULL,
  `total_premi` decimal(20, 2) NULL DEFAULT 0.00,
  `plafond` decimal(20, 2) NULL DEFAULT 0.00,
  `pertanggungan` decimal(20, 2) NULL DEFAULT 0.00,
  `currency` varchar(5) CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT NULL,
  `tenor` int NULL DEFAULT 0,
  `jw_th` int NULL DEFAULT NULL,
  `jw_bl` int NULL DEFAULT 0,
  `jw_hr` int NULL DEFAULT 0,
  `insurance_rate` decimal(10, 2) NULL DEFAULT NULL,
  `start_date` date NULL DEFAULT NULL,
  `start_month` int NULL DEFAULT NULL,
  `start_year` int NULL DEFAULT NULL,
  `end_date` date NULL DEFAULT NULL,
  `end_year` int NULL DEFAULT NULL,
  `end_month` int NULL DEFAULT NULL,
  `customer_deposit_amount` varchar(15) CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT NULL,
  `cif` varchar(10) CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT NULL,
  `customer_name` varchar(255) CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT NULL,
  `birth_date` date NULL DEFAULT NULL,
  `born_place` varchar(100) CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT NULL,
  `age` int NULL DEFAULT 0,
  `job` varchar(200) CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT NULL,
  `periode_upload` date NULL DEFAULT NULL,
  `ibu_kandung` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT 'IBU',
  `gender` varchar(1) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT 'L',
  `data_status_id` int NULL DEFAULT 1,
  `keterangan_loan_status` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `record_status_id` int NULL DEFAULT 1,
  `is_uploaded_to_ajb_core` int NULL DEFAULT 0,
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`) USING BTREE,
  UNIQUE INDEX `unique_key`(`loan_id`) USING BTREE,
  INDEX `fk_member_master_status`(`data_status_id`) USING BTREE,
  CONSTRAINT `fk_member_master_status` FOREIGN KEY (`data_status_id`) REFERENCES `master_data_status` (`id`) ON DELETE RESTRICT ON UPDATE RESTRICT
) ENGINE = InnoDB AVG_ROW_LENGTH = 780 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of data_members
-- ----------------------------
INSERT INTO `data_members` VALUES ('INS21211020190308XWHGJ19Y', 'GEN1192018070003', NULL, '001', '110', '001', '3100400001', 16240000.00, 196600000.00, 100000000.00, 'IDR', 168, 14, 0, 0, 162.40, '2018-07-02', 7, 2018, '2032-07-02', 2032, 7, '200110000679', '503143', 'ADE TARSADI', '1958-05-15', 'GARUT', 60, 'PENSIONS', NULL, 'IBU', 'L', 2, NULL, 2, 1, '2019-03-08 18:12:15', '2021-08-13 17:21:54');
INSERT INTO `data_members` VALUES ('INS21211020190308ZRI09XJN', 'GEN3012018070001', NULL, '001', '110', '001', '3100400001', 17524000.00, 250000000.00, 100000000.00, 'IDR', 156, 13, 0, 0, 175.24, '2018-07-03', 7, 2018, '2031-07-03', 2031, 7, '200110000679', '502807', 'DURIAT HADISUSANTO', '1956-08-18', 'MAJALENGKA', 62, 'PENSIONS', NULL, 'IBU', 'L', 2, NULL, 2, 1, '2019-03-08 18:12:15', '2021-08-13 17:21:54');
INSERT INTO `data_members` VALUES ('INS21211020201011SY26F9QK', 'GEN2120000000003', 'POL2120000000003', '001', '110', '001', '3100400001', 17524000.00, 250000000.00, 100000000.00, 'IDR', 156, 13, 0, 0, 175.24, '2018-07-03', 7, 2018, '2031-07-03', 2031, 7, '200110000679', '000003', 'IRFAN A', '1956-08-18', 'BANDUNG', 62, 'PENSIONS', NULL, 'IBU', 'L', 2, NULL, 2, 0, '2020-10-12 04:41:42', '2021-08-13 17:21:54');
INSERT INTO `data_members` VALUES ('INS21211020201011TPTPQA0U', 'GEN2120000000001', 'POL2120000000002', '001', '110', '001', '3100300001', 3624000.00, 230000000.00, 100000000.00, 'IDR', 156, 13, 0, 0, 0.00, '2018-07-02', 7, 2018, '2031-07-02', 2031, 7, '200110000679', '000001', 'IRFAN', '1950-01-05', 'BANDUNG', 68, 'PENSIONS', NULL, 'IBU', 'L', 1, NULL, 2, 0, '2020-10-12 02:37:16', '2021-08-13 17:21:54');
INSERT INTO `data_members` VALUES ('INS21211020201011YWCSJ3K9', 'GEN2120000000002', 'POL2120000000001', '001', '110', '001', '3100400001', 3780000.00, 239000000.00, 100000000.00, 'IDR', 168, 14, 0, 0, 0.00, '2018-07-02', 7, 2018, '2032-07-02', 2032, 7, '200110000680', '000002', 'LUTHFI', '1950-06-24', 'BANDUNG', 68, 'PENSIONS', NULL, 'IBU', 'L', 1, NULL, 2, 0, '2020-10-12 02:37:16', '2021-08-13 17:21:54');
INSERT INTO `data_members` VALUES ('INS2121102020101202XHCZLO', 'GEN2120000000005', 'POL2120000000005', '001', '110', '001', '3100400001', 17524000.00, 250000000.00, 100000000.00, 'IDR', 156, 13, 0, 0, 175.24, '2018-07-03', 7, 2018, '2031-07-03', 2031, 7, '200110000679', '000005', 'IRFAN C', '1956-08-18', 'BANDUNG', 62, 'PENSIONS', NULL, 'IBU', 'L', 3, NULL, 2, 0, '2020-10-12 17:11:19', '2021-08-13 11:04:07');
INSERT INTO `data_members` VALUES ('INS212110202010128VDX84NM', 'GEN2120000000012', 'POL2120000000015', '001', '110', '001', '3100400001', 17524000.00, 250000000.00, 100000000.00, 'IDR', 156, 13, 0, 0, 175.24, '2018-07-03', 7, 2018, '2031-07-03', 2031, 7, '200110000679', '000012', 'IRFAN J', '1956-08-18', 'BANDUNG', 62, 'PENSIONS', NULL, 'IBU', 'L', 2, NULL, 2, 0, '2020-10-12 17:36:20', '2021-08-13 11:03:11');
INSERT INTO `data_members` VALUES ('INS21211020201012DLIGHPTP', 'GEN2120000000006', 'POL2120000000006', '001', '110', '001', '3100400001', 17524000.00, 250000000.00, 100000000.00, 'IDR', 156, 13, 0, 0, 175.24, '2018-07-03', 7, 2018, '2031-07-03', 2031, 7, '200110000679', '000006', 'IRFAN D', '1956-08-18', 'BANDUNG', 62, 'PENSIONS', NULL, 'IBU', 'L', 2, NULL, 2, 0, '2020-10-12 17:11:19', '2021-08-13 17:21:54');
INSERT INTO `data_members` VALUES ('INS21211020201012GFGPUTBT', 'GEN2120000000010', 'POL2120000000010', '001', '110', '001', '3100400001', 17524000.00, 250000000.00, 100000000.00, 'IDR', 156, 13, 0, 0, 175.24, '2018-07-03', 7, 2018, '2031-07-03', 2031, 7, '200110000679', '000010', 'IRFAN H', '1956-08-18', 'BANDUNG', 62, 'PENSIONS', NULL, 'IBU', 'L', 3, NULL, 2, 0, '2020-10-12 17:36:20', '2021-08-13 17:21:54');
INSERT INTO `data_members` VALUES ('INS21211120190321ZO8U7886', 'GEN3052018070002', NULL, '001', '111', '001', '3100400001', 5818200.00, 120000000.00, 60000000.00, 'IDR', 72, 6, 0, 0, 96.97, '2018-07-04', 7, 2018, '2024-07-04', 2024, 7, '200110000679', '323646', 'SUWANDI', '1953-04-17', 'CIREBON', 65, 'ETC', NULL, 'IBU', 'L', 2, NULL, 2, 0, '2019-03-21 16:54:55', '2021-08-13 17:21:54');

-- ----------------------------
-- Table structure for master_banks
-- ----------------------------
DROP TABLE IF EXISTS `master_banks`;
CREATE TABLE `master_banks`  (
  `id` varchar(3) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `name` varchar(150) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`) USING BTREE
) ENGINE = InnoDB AVG_ROW_LENGTH = 4096 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of master_banks
-- ----------------------------
INSERT INTO `master_banks` VALUES ('000', 'Non BNK', '2021-08-13 15:57:45', '2021-08-13 16:42:10');
INSERT INTO `master_banks` VALUES ('001', 'BNK 001', '2020-10-02 13:17:51', '2021-08-13 16:42:13');

-- ----------------------------
-- Table structure for master_branches
-- ----------------------------
DROP TABLE IF EXISTS `master_branches`;
CREATE TABLE `master_branches`  (
  `id` varchar(6) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `name` varchar(150) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `bank_id` varchar(3) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `is_kp` int NULL DEFAULT 0,
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`) USING BTREE
) ENGINE = InnoDB AVG_ROW_LENGTH = 119 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of master_branches
-- ----------------------------
INSERT INTO `master_branches` VALUES ('000', 'Bank Head Quearter', '001', 1, '2018-10-17 08:51:35', '2021-08-13 16:22:59');
INSERT INTO `master_branches` VALUES ('110', 'Bank Branch 001', '001', 0, '2018-10-17 08:51:35', '2021-08-13 16:23:04');
INSERT INTO `master_branches` VALUES ('INS', 'INS', '000', 0, '2018-11-12 15:01:10', '2021-08-13 16:22:04');

-- ----------------------------
-- Table structure for master_claim_status
-- ----------------------------
DROP TABLE IF EXISTS `master_claim_status`;
CREATE TABLE `master_claim_status`  (
  `id` int NOT NULL AUTO_INCREMENT,
  `name` varchar(100) CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT NULL,
  `short_name` varchar(3) CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT NULL,
  `created_at` datetime NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` datetime NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 7 AVG_ROW_LENGTH = 2730 CHARACTER SET = utf8 COLLATE = utf8_general_ci ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of master_claim_status
-- ----------------------------
INSERT INTO `master_claim_status` VALUES (1, 'On Review', 'ONR', '2018-11-13 14:17:13', '2018-12-12 15:40:17');
INSERT INTO `master_claim_status` VALUES (2, 'Kurang Dokumen', 'KRD', '2018-11-13 14:17:13', '2018-12-12 15:40:20');
INSERT INTO `master_claim_status` VALUES (3, 'Dokumen Belum di Terima', 'DBT', '2018-11-13 14:17:13', '2018-12-12 15:40:25');
INSERT INTO `master_claim_status` VALUES (4, 'Dokumen Lengkap', 'DKL', '2018-11-13 14:17:13', '2018-12-12 15:40:33');
INSERT INTO `master_claim_status` VALUES (5, 'Claim ditolak / Compromise Settlement', 'CCS', '2018-11-13 14:17:13', '2018-12-12 15:40:39');
INSERT INTO `master_claim_status` VALUES (6, 'Claim dibayar', 'CPD', '2018-11-13 14:17:13', '2018-12-12 15:40:43');

-- ----------------------------
-- Table structure for master_data_status
-- ----------------------------
DROP TABLE IF EXISTS `master_data_status`;
CREATE TABLE `master_data_status`  (
  `id` int NOT NULL AUTO_INCREMENT,
  `name` varchar(255) CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT NULL,
  `short_name` varchar(5) CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT NULL,
  `created_at` datetime NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` datetime NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 8 AVG_ROW_LENGTH = 2340 CHARACTER SET = utf8 COLLATE = utf8_general_ci ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of master_data_status
-- ----------------------------
INSERT INTO `master_data_status` VALUES (1, 'Unverified', 'UNV', '2018-11-13 18:50:48', '2018-12-12 11:47:39');
INSERT INTO `master_data_status` VALUES (2, 'Open', 'OPN', '2018-11-13 18:50:48', '2018-12-12 11:47:41');
INSERT INTO `master_data_status` VALUES (3, 'Closed', 'CLS', '2018-11-13 18:50:48', '2018-12-12 11:47:43');
INSERT INTO `master_data_status` VALUES (4, 'On Claiming', 'ONC', '2018-11-13 18:50:48', '2018-12-12 11:47:48');
INSERT INTO `master_data_status` VALUES (5, 'Claimed', 'CLM', '2018-11-13 18:50:48', '2018-12-12 11:47:50');
INSERT INTO `master_data_status` VALUES (6, 'Validation Failed', 'VLF', '2018-11-13 18:50:48', '2018-12-12 11:47:54');
INSERT INTO `master_data_status` VALUES (7, 'On Proposing Repayment', 'OPR', '2018-11-28 06:52:55', '2018-12-12 11:47:58');

-- ----------------------------
-- Table structure for master_insurances
-- ----------------------------
DROP TABLE IF EXISTS `master_insurances`;
CREATE TABLE `master_insurances`  (
  `id` varchar(3) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `name` varchar(150) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`) USING BTREE
) ENGINE = InnoDB AVG_ROW_LENGTH = 4096 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of master_insurances
-- ----------------------------
INSERT INTO `master_insurances` VALUES ('001', 'Insurance Company 001', '2018-11-13 06:48:09', '2021-08-13 16:32:19');
INSERT INTO `master_insurances` VALUES ('002', 'Insurance Company 002', '2020-10-07 16:11:48', '2021-08-13 16:32:23');

-- ----------------------------
-- Table structure for master_map_banks_insurances
-- ----------------------------
DROP TABLE IF EXISTS `master_map_banks_insurances`;
CREATE TABLE `master_map_banks_insurances`  (
  `id` int NOT NULL AUTO_INCREMENT,
  `bank_id` varchar(3) CHARACTER SET utf8 COLLATE utf8_general_ci NOT NULL,
  `insurance_id` varchar(6) CHARACTER SET utf8 COLLATE utf8_general_ci NOT NULL,
  `created_at` datetime NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` datetime NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`, `bank_id`, `insurance_id`) USING BTREE,
  UNIQUE INDEX `unique_key`(`bank_id`, `insurance_id`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 16 AVG_ROW_LENGTH = 8192 CHARACTER SET = utf8 COLLATE = utf8_general_ci ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of master_map_banks_insurances
-- ----------------------------
INSERT INTO `master_map_banks_insurances` VALUES (13, '001', '001', '2020-10-07 09:17:58', '2021-08-13 17:25:55');

-- ----------------------------
-- Table structure for master_products
-- ----------------------------
DROP TABLE IF EXISTS `master_products`;
CREATE TABLE `master_products`  (
  `id` varchar(10) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `name` varchar(150) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `short_name` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `bank_id` varchar(3) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `insurance_id` varchar(3) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`) USING BTREE
) ENGINE = InnoDB AVG_ROW_LENGTH = 5461 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of master_products
-- ----------------------------
INSERT INTO `master_products` VALUES ('3100300001', 'KUPG', 'KUPG', '001', '001', '2018-11-14 04:18:22', '2021-08-13 16:44:22');
INSERT INTO `master_products` VALUES ('3100400001', 'KUPN', 'KUPN', '001', '001', '2018-11-14 04:18:22', '2021-08-13 16:44:23');
INSERT INTO `master_products` VALUES ('3100400004', 'KUJD', 'KUJD', '001', '001', '2018-11-14 04:18:22', '2021-08-13 16:44:24');

-- ----------------------------
-- Table structure for master_record_status
-- ----------------------------
DROP TABLE IF EXISTS `master_record_status`;
CREATE TABLE `master_record_status`  (
  `id` int NOT NULL AUTO_INCREMENT,
  `name` varchar(255) CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT NULL,
  `created_at` datetime NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` datetime NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 3 AVG_ROW_LENGTH = 8192 CHARACTER SET = utf8 COLLATE = utf8_general_ci ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of master_record_status
-- ----------------------------
INSERT INTO `master_record_status` VALUES (1, 'Baru', '2018-11-14 15:18:31', '2018-11-14 15:18:31');
INSERT INTO `master_record_status` VALUES (2, 'Lama', '2018-11-14 15:18:31', '2018-11-14 15:18:31');

-- ----------------------------
-- Table structure for migrations
-- ----------------------------
DROP TABLE IF EXISTS `migrations`;
CREATE TABLE `migrations`  (
  `id` int UNSIGNED NOT NULL AUTO_INCREMENT,
  `migration` varchar(191) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `batch` int NOT NULL,
  PRIMARY KEY (`id`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 9 AVG_ROW_LENGTH = 2048 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of migrations
-- ----------------------------
INSERT INTO `migrations` VALUES (1, '2014_10_12_000000_create_users_table', 1);
INSERT INTO `migrations` VALUES (2, '2014_10_12_100000_create_password_resets_table', 1);
INSERT INTO `migrations` VALUES (3, '2018_10_09_071017_create_klaims_table', 1);
INSERT INTO `migrations` VALUES (4, '2018_10_09_071028_create_penutupans_table', 1);
INSERT INTO `migrations` VALUES (5, '2018_10_09_082355_laratrust_setup_tables', 1);
INSERT INTO `migrations` VALUES (6, '2018_10_10_030948_create_banks_table', 1);
INSERT INTO `migrations` VALUES (7, '2018_10_10_031135_create_branches_table', 1);
INSERT INTO `migrations` VALUES (8, '2018_10_10_031153_create_products_table', 1);

-- ----------------------------
-- Table structure for password_resets
-- ----------------------------
DROP TABLE IF EXISTS `password_resets`;
CREATE TABLE `password_resets`  (
  `email` varchar(191) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `token` varchar(191) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  INDEX `password_resets_email_index`(`email`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of password_resets
-- ----------------------------

-- ----------------------------
-- Table structure for permission_role
-- ----------------------------
DROP TABLE IF EXISTS `permission_role`;
CREATE TABLE `permission_role`  (
  `permission_id` int UNSIGNED NOT NULL,
  `role_id` int UNSIGNED NOT NULL,
  PRIMARY KEY (`permission_id`, `role_id`) USING BTREE,
  INDEX `permission_role_role_id_foreign`(`role_id`) USING BTREE,
  CONSTRAINT `permission_role_permission_id_foreign` FOREIGN KEY (`permission_id`) REFERENCES `permissions` (`id`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `permission_role_role_id_foreign` FOREIGN KEY (`role_id`) REFERENCES `roles` (`id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE = InnoDB AVG_ROW_LENGTH = 197 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of permission_role
-- ----------------------------
INSERT INTO `permission_role` VALUES (1, 1);
INSERT INTO `permission_role` VALUES (18, 1);
INSERT INTO `permission_role` VALUES (19, 1);
INSERT INTO `permission_role` VALUES (20, 1);
INSERT INTO `permission_role` VALUES (21, 1);
INSERT INTO `permission_role` VALUES (22, 1);
INSERT INTO `permission_role` VALUES (23, 1);
INSERT INTO `permission_role` VALUES (24, 1);
INSERT INTO `permission_role` VALUES (25, 1);
INSERT INTO `permission_role` VALUES (26, 1);
INSERT INTO `permission_role` VALUES (27, 1);
INSERT INTO `permission_role` VALUES (28, 1);
INSERT INTO `permission_role` VALUES (29, 1);
INSERT INTO `permission_role` VALUES (30, 1);
INSERT INTO `permission_role` VALUES (31, 1);
INSERT INTO `permission_role` VALUES (32, 1);
INSERT INTO `permission_role` VALUES (33, 1);
INSERT INTO `permission_role` VALUES (34, 1);
INSERT INTO `permission_role` VALUES (1, 2);
INSERT INTO `permission_role` VALUES (2, 2);
INSERT INTO `permission_role` VALUES (3, 2);
INSERT INTO `permission_role` VALUES (4, 2);
INSERT INTO `permission_role` VALUES (5, 2);
INSERT INTO `permission_role` VALUES (8, 2);
INSERT INTO `permission_role` VALUES (9, 2);
INSERT INTO `permission_role` VALUES (13, 2);
INSERT INTO `permission_role` VALUES (14, 2);
INSERT INTO `permission_role` VALUES (15, 2);
INSERT INTO `permission_role` VALUES (16, 2);
INSERT INTO `permission_role` VALUES (17, 2);
INSERT INTO `permission_role` VALUES (18, 2);
INSERT INTO `permission_role` VALUES (19, 2);
INSERT INTO `permission_role` VALUES (20, 2);
INSERT INTO `permission_role` VALUES (21, 2);
INSERT INTO `permission_role` VALUES (22, 2);
INSERT INTO `permission_role` VALUES (23, 2);
INSERT INTO `permission_role` VALUES (24, 2);
INSERT INTO `permission_role` VALUES (25, 2);
INSERT INTO `permission_role` VALUES (26, 2);
INSERT INTO `permission_role` VALUES (27, 2);
INSERT INTO `permission_role` VALUES (28, 2);
INSERT INTO `permission_role` VALUES (29, 2);
INSERT INTO `permission_role` VALUES (30, 2);
INSERT INTO `permission_role` VALUES (31, 2);
INSERT INTO `permission_role` VALUES (32, 2);
INSERT INTO `permission_role` VALUES (33, 2);
INSERT INTO `permission_role` VALUES (34, 2);
INSERT INTO `permission_role` VALUES (35, 2);
INSERT INTO `permission_role` VALUES (36, 2);
INSERT INTO `permission_role` VALUES (37, 2);
INSERT INTO `permission_role` VALUES (38, 2);
INSERT INTO `permission_role` VALUES (39, 2);
INSERT INTO `permission_role` VALUES (40, 2);
INSERT INTO `permission_role` VALUES (41, 2);
INSERT INTO `permission_role` VALUES (42, 2);
INSERT INTO `permission_role` VALUES (43, 2);
INSERT INTO `permission_role` VALUES (44, 2);
INSERT INTO `permission_role` VALUES (1, 3);
INSERT INTO `permission_role` VALUES (5, 3);
INSERT INTO `permission_role` VALUES (8, 3);
INSERT INTO `permission_role` VALUES (9, 3);
INSERT INTO `permission_role` VALUES (13, 3);
INSERT INTO `permission_role` VALUES (14, 3);
INSERT INTO `permission_role` VALUES (17, 3);
INSERT INTO `permission_role` VALUES (35, 3);
INSERT INTO `permission_role` VALUES (40, 3);
INSERT INTO `permission_role` VALUES (41, 3);
INSERT INTO `permission_role` VALUES (42, 3);
INSERT INTO `permission_role` VALUES (43, 3);
INSERT INTO `permission_role` VALUES (44, 3);
INSERT INTO `permission_role` VALUES (1, 4);
INSERT INTO `permission_role` VALUES (2, 4);
INSERT INTO `permission_role` VALUES (4, 4);
INSERT INTO `permission_role` VALUES (5, 4);
INSERT INTO `permission_role` VALUES (6, 4);
INSERT INTO `permission_role` VALUES (7, 4);
INSERT INTO `permission_role` VALUES (9, 4);
INSERT INTO `permission_role` VALUES (10, 4);
INSERT INTO `permission_role` VALUES (14, 4);
INSERT INTO `permission_role` VALUES (15, 4);
INSERT INTO `permission_role` VALUES (35, 4);
INSERT INTO `permission_role` VALUES (36, 4);
INSERT INTO `permission_role` VALUES (37, 4);
INSERT INTO `permission_role` VALUES (38, 4);
INSERT INTO `permission_role` VALUES (39, 4);
INSERT INTO `permission_role` VALUES (1, 5);
INSERT INTO `permission_role` VALUES (2, 5);
INSERT INTO `permission_role` VALUES (3, 5);
INSERT INTO `permission_role` VALUES (5, 5);
INSERT INTO `permission_role` VALUES (6, 5);
INSERT INTO `permission_role` VALUES (7, 5);
INSERT INTO `permission_role` VALUES (9, 5);
INSERT INTO `permission_role` VALUES (10, 5);
INSERT INTO `permission_role` VALUES (12, 5);
INSERT INTO `permission_role` VALUES (14, 5);
INSERT INTO `permission_role` VALUES (15, 5);
INSERT INTO `permission_role` VALUES (16, 5);
INSERT INTO `permission_role` VALUES (35, 5);
INSERT INTO `permission_role` VALUES (36, 5);
INSERT INTO `permission_role` VALUES (37, 5);
INSERT INTO `permission_role` VALUES (38, 5);
INSERT INTO `permission_role` VALUES (39, 5);

-- ----------------------------
-- Table structure for permission_user
-- ----------------------------
DROP TABLE IF EXISTS `permission_user`;
CREATE TABLE `permission_user`  (
  `permission_id` int UNSIGNED NOT NULL,
  `user_id` int UNSIGNED NOT NULL,
  `user_type` varchar(191) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  PRIMARY KEY (`user_id`, `permission_id`, `user_type`) USING BTREE,
  INDEX `permission_user_permission_id_foreign`(`permission_id`) USING BTREE,
  CONSTRAINT `permission_user_permission_id_foreign` FOREIGN KEY (`permission_id`) REFERENCES `permissions` (`id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of permission_user
-- ----------------------------

-- ----------------------------
-- Table structure for permissions
-- ----------------------------
DROP TABLE IF EXISTS `permissions`;
CREATE TABLE `permissions`  (
  `id` int UNSIGNED NOT NULL AUTO_INCREMENT,
  `name` varchar(191) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `display_name` varchar(191) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `description` varchar(191) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`) USING BTREE,
  UNIQUE INDEX `permissions_name_unique`(`name`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 45 AVG_ROW_LENGTH = 390 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of permissions
-- ----------------------------
INSERT INTO `permissions` VALUES (1, 'can_view_root_menu_dashboard', 'View Menu Dashboard', 'Pengguna dapat membuka menu dashboard', '2018-10-10 10:52:23', '2019-03-21 23:26:44');
INSERT INTO `permissions` VALUES (2, 'can_view_root_menu_upload', 'View Menu Upload', 'Pengguna dapat membuka menu upload', '2018-10-10 10:52:23', '2019-03-21 23:26:52');
INSERT INTO `permissions` VALUES (3, 'can_view_sub_menu_upload_peserta', 'View Menu Upload Penutupan', 'Pengguna dapat membuka menu upload peserta baru', '2018-10-10 10:52:23', '2019-03-21 23:26:59');
INSERT INTO `permissions` VALUES (4, 'can_view_sub_menu_upload_mutasi', 'View Menu Upload Mutasi', 'Pengguna dapat membuka menu upload mutasi rekening', '2018-10-10 10:52:23', '2019-03-21 23:27:06');
INSERT INTO `permissions` VALUES (5, 'can_view_root_menu_peserta', 'View Menu Penutupan', 'Pengguna dapat membuka menu peserta', '2018-10-10 10:52:23', '2019-03-21 23:27:16');
INSERT INTO `permissions` VALUES (6, 'can_view_sub_menu_list_peserta_bnk', 'View Menu List Penutupan BNK', 'Pengguna dapat membuka menu list data peserta untuk bnk', '2018-10-10 10:52:23', '2021-08-13 16:37:14');
INSERT INTO `permissions` VALUES (7, 'can_view_sub_menu_list_datahold_peserta', 'View Menu List Datahold Penutupan BNK', 'Pengguna dapat membuka menu datahold peserta untuk bnk', '2018-10-10 10:52:23', '2021-08-13 16:37:16');
INSERT INTO `permissions` VALUES (8, 'can_view_sub_menu_list_peserta_ins', 'View Menu List Penutupan INS', 'Pengguna dapat membuka menu list data peserta untuk ins', '2018-10-10 10:52:23', '2021-08-13 16:37:21');
INSERT INTO `permissions` VALUES (9, 'can_view_root_menu_claim', 'View Menu Claim', 'Pengguna dapat membuka menu claim', '2018-10-10 10:52:23', '2019-03-21 23:27:57');
INSERT INTO `permissions` VALUES (10, 'can_view_sub_menu_list_claim_bnk', 'View Menu List Claim BNK', 'Pengguna dapat membuka menu list claim untuk bnk', '2018-10-10 10:52:23', '2021-08-13 16:37:24');
INSERT INTO `permissions` VALUES (12, 'can_view_sub_menu_input_claim', 'View Menu Input Claim', 'Pengguna dapat membuka menu input claim', '2018-11-23 17:05:28', '2019-03-21 23:28:08');
INSERT INTO `permissions` VALUES (13, 'can_view_sub_menu_list_claim_ins', 'View Menu List Claim INS', 'Pengguna dapat membuka menu list claim untuk ins', '2018-11-23 17:05:28', '2021-08-13 16:37:27');
INSERT INTO `permissions` VALUES (14, 'can_view_root_menu_root_pelunasan', 'View Menu Pengaturan', 'Pengguna dapat membuka menu pengaturan', '2018-11-23 17:05:28', '2019-03-21 23:28:16');
INSERT INTO `permissions` VALUES (15, 'can_view_sub_menu_list_pengajuan_pelunasan_bnk', 'View Menu Akses', 'Pengguna dapat membuka menu akses', '2018-11-23 17:05:28', '2021-08-13 16:34:57');
INSERT INTO `permissions` VALUES (16, 'can_view_sub_menu_input_pengajuan_pelunasan', 'View Menu Pengguna', 'Pengguna dapat membuka menu pemeliharaan data pengguna', '2018-11-23 17:05:28', '2019-03-21 23:50:19');
INSERT INTO `permissions` VALUES (17, 'can_view_sub_menu_list_pengajuan_pelunasan_ins', 'View Menu Role', 'Pengguna dapat membuka menu pemeliharaan data role', '2018-11-23 17:05:28', '2021-08-13 16:34:59');
INSERT INTO `permissions` VALUES (18, 'can_view_root_menu_master_access', 'View Menu Permission', 'Pengguna dapat membuka menu pemeliharaan data permission', '2018-11-23 17:05:28', '2019-03-21 23:26:34');
INSERT INTO `permissions` VALUES (19, 'can_view_sub_menu_pemeliharaan_user', 'View Menu Client', 'Pengguna dapat membuka menu client', '2018-11-23 17:05:28', '2019-03-21 23:51:12');
INSERT INTO `permissions` VALUES (20, 'can_view_sub_menu_pemeliharaan_role', 'View Menu BNK', 'Pengguna dapat membuka menu pemeliharaan data bnk', '2018-11-23 17:05:28', '2021-08-13 16:37:32');
INSERT INTO `permissions` VALUES (21, 'can_view_sub_menu_pemeliharaan_permission', 'View Menu BRC', 'Pengguna dapat membuka menu pemeliharaan data brc', '2018-11-23 17:05:28', '2021-08-13 16:37:38');
INSERT INTO `permissions` VALUES (22, 'can_view_root_menu_master_client', 'View Menu Jenis Status', 'Pengguna dapat membuka menu pemeliharaan data jenis status', '2018-11-23 17:05:28', '2019-03-21 23:51:42');
INSERT INTO `permissions` VALUES (23, 'can_view_sub_menu_pemeliharaan_bnk', 'View Menu Jenis INS', 'Pengguna dapat membuka menu pemeliharaan data jenis ins', '2018-11-23 17:05:28', '2021-08-13 16:37:42');
INSERT INTO `permissions` VALUES (24, 'can_view_sub_menu_pemeliharaan_brc', 'View Menu Status Validasi', 'Pengguna dapat membuka menu pemeliharaan data status validasi', '2018-11-23 17:05:28', '2021-08-13 16:35:10');
INSERT INTO `permissions` VALUES (25, 'can_view_root_menu_master_jenis_status', 'View Menu Status Claim', 'Pengguna dapat membuka menu pemeliharaan data status claim', '2018-11-23 17:05:28', '2019-03-21 23:52:11');
INSERT INTO `permissions` VALUES (26, 'can_view_sub_menu_pemeliharaan_jenis_ins', 'View Menu Status Loan', 'Pengguna dapat membuka menu pemeliharaan data status loan', '2018-11-23 17:05:28', '2021-08-13 16:35:14');
INSERT INTO `permissions` VALUES (27, 'can_view_sub_menu_pemeliharaan_status_validasi', 'View Menu Rule Validasi', 'Pengguna dapat membuka menu pemeliharaan data rule validasi', '2018-11-23 17:05:28', '2019-03-21 23:53:02');
INSERT INTO `permissions` VALUES (28, 'can_view_sub_menu_pemeliharaan_status_claim', 'View Menu Master Produk', 'Pengguna dapat membuka menu pemeliharaan data produk', '2018-11-23 17:05:28', '2019-03-21 23:53:11');
INSERT INTO `permissions` VALUES (29, 'can_view_sub_menu_pemeliharaan_status_loan', 'View Menu Rate INS', 'Pengguna dapat membuka menu pemeliharaan data rate ins', '2018-11-23 17:05:28', '2021-08-13 16:37:46');
INSERT INTO `permissions` VALUES (30, 'can_view_sub_menu_pemeliharaan_rule_validasi', 'View Menu Mapping', 'Pengguna dapat membuka menu pemeliharaan data mapping produk dengan jenis ins', '2018-11-23 17:05:28', '2021-08-13 16:37:50');
INSERT INTO `permissions` VALUES (31, 'can_view_root_menu_master_produk_rate', 'View Menu Report', 'Pengguna dapat membuka menu report', '2018-11-23 17:05:28', '2019-03-21 23:53:40');
INSERT INTO `permissions` VALUES (32, 'can_view_sub_menu_pemeliharaan_produk', NULL, NULL, '2019-03-21 23:53:51', '2019-03-21 23:53:51');
INSERT INTO `permissions` VALUES (33, 'can_view_sub_menu_pemeliharaan_rate_asuransi', NULL, NULL, '2019-03-21 23:54:00', '2019-03-21 23:54:00');
INSERT INTO `permissions` VALUES (34, 'can_view_sub_menu_pemeliharaan_mapping_produk', NULL, NULL, '2019-03-21 23:54:08', '2019-03-21 23:54:08');
INSERT INTO `permissions` VALUES (35, 'can_view_root_menu_laporan', NULL, NULL, '2019-03-21 23:54:25', '2019-03-21 23:54:25');
INSERT INTO `permissions` VALUES (36, 'can_view_sub_menu_laporan_peserta_bnk', NULL, NULL, '2019-03-21 23:54:46', '2021-08-13 16:36:08');
INSERT INTO `permissions` VALUES (37, 'can_view_sub_menu_laporan_claim_bnk', NULL, NULL, '2019-03-21 23:54:54', '2021-08-13 16:36:06');
INSERT INTO `permissions` VALUES (38, 'can_view_sub_menu_laporan_nominatif_premi_pertanggungan_bnk', NULL, NULL, '2019-03-21 23:55:11', '2021-08-13 16:35:49');
INSERT INTO `permissions` VALUES (39, 'can_view_sub_menu_laporan_nominatif_claim_bnk', NULL, NULL, '2019-03-21 23:55:24', '2021-08-13 16:35:47');
INSERT INTO `permissions` VALUES (40, 'can_view_sub_menu_laporan_peserta_ins', NULL, NULL, '2019-03-21 23:55:54', '2021-08-13 16:35:28');
INSERT INTO `permissions` VALUES (41, 'can_view_sub_menu_laporan_claim_ins', NULL, NULL, '2019-03-21 23:56:00', '2021-08-13 16:35:30');
INSERT INTO `permissions` VALUES (42, 'can_view_sub_menu_laporan_nominatif_premi_pertanggungan_ins', NULL, NULL, '2019-03-21 23:56:07', '2021-08-13 16:35:44');
INSERT INTO `permissions` VALUES (43, 'can_view_sub_menu_laporan_nominatif_claim_ins', NULL, NULL, '2019-03-21 23:56:20', '2021-08-13 16:35:37');
INSERT INTO `permissions` VALUES (44, 'can_view_sub_menu_download_pst', NULL, NULL, '2019-03-21 23:56:39', '2019-03-21 23:56:39');
INSERT INTO `permissions` VALUES (45, 'dfgdfg', 'dfgdfg', 'dfgdfgdfgdfgd', '2021-08-13 09:01:14', '2021-08-13 09:01:14');
INSERT INTO `permissions` VALUES (46, 'sadsadsad', 'asdsad', 'asdsadsad', '2021-08-13 12:52:06', '2021-08-13 12:52:06');

-- ----------------------------
-- Table structure for role_user
-- ----------------------------
DROP TABLE IF EXISTS `role_user`;
CREATE TABLE `role_user`  (
  `role_id` int UNSIGNED NOT NULL,
  `user_id` int UNSIGNED NOT NULL,
  `user_type` varchar(191) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  PRIMARY KEY (`user_id`, `role_id`, `user_type`) USING BTREE,
  INDEX `role_user_role_id_foreign`(`role_id`) USING BTREE,
  CONSTRAINT `role_user_role_id_foreign` FOREIGN KEY (`role_id`) REFERENCES `roles` (`id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE = InnoDB AVG_ROW_LENGTH = 1489 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of role_user
-- ----------------------------
INSERT INTO `role_user` VALUES (1, 1, 'App\\User');
INSERT INTO `role_user` VALUES (2, 13, 'App\\User');
INSERT INTO `role_user` VALUES (3, 11, 'App\\User');
INSERT INTO `role_user` VALUES (3, 15, 'App\\User');
INSERT INTO `role_user` VALUES (4, 2, 'App\\User');
INSERT INTO `role_user` VALUES (4, 16, 'App\\User');
INSERT INTO `role_user` VALUES (5, 3, 'App\\User');
INSERT INTO `role_user` VALUES (5, 4, 'App\\User');
INSERT INTO `role_user` VALUES (5, 5, 'App\\User');
INSERT INTO `role_user` VALUES (5, 6, 'App\\User');
INSERT INTO `role_user` VALUES (5, 7, 'App\\User');
INSERT INTO `role_user` VALUES (5, 8, 'App\\User');
INSERT INTO `role_user` VALUES (5, 17, 'App\\User');

-- ----------------------------
-- Table structure for roles
-- ----------------------------
DROP TABLE IF EXISTS `roles`;
CREATE TABLE `roles`  (
  `id` int UNSIGNED NOT NULL AUTO_INCREMENT,
  `name` varchar(191) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `display_name` varchar(191) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `description` varchar(191) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`) USING BTREE,
  UNIQUE INDEX `roles_name_unique`(`name`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 6 AVG_ROW_LENGTH = 3276 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of roles
-- ----------------------------
INSERT INTO `roles` VALUES (1, 'ROLE_ADMINISTRATOR', 'ADMINISTRATOR', 'Role for System Administrator', '2018-10-10 10:52:23', '2018-11-23 16:37:50');
INSERT INTO `roles` VALUES (2, 'ROLE_INS_ADMIN', 'Admin INS', 'Admin INS', '2018-10-10 10:52:23', '2018-10-10 10:52:23');
INSERT INTO `roles` VALUES (3, 'ROLE_INS_OPERATOR', 'Operator INS', 'User non admin INS', '2018-10-10 10:52:23', '2018-10-10 10:52:23');
INSERT INTO `roles` VALUES (4, 'ROLE_CLIENT_BNK_KPO', 'Client KPO', 'User BNK untuk KPO', '2018-10-10 10:52:23', '2018-10-10 10:52:23');
INSERT INTO `roles` VALUES (5, 'ROLE_CLIENT_BNK_BRC', 'Client BRC', 'User BNK untuk BRC', '2018-10-10 10:52:23', '2018-10-10 10:52:23');

-- ----------------------------
-- Table structure for total_per_bank
-- ----------------------------
DROP TABLE IF EXISTS `total_per_bank`;
CREATE TABLE `total_per_bank`  (
  `bank_id` varchar(3) CHARACTER SET utf8 COLLATE utf8_general_ci NOT NULL,
  `total_pertanggungan` decimal(30, 2) NULL DEFAULT NULL,
  `total_premi` decimal(30, 2) NULL DEFAULT NULL,
  `total_peserta` int NULL DEFAULT NULL,
  `created_at` datetime NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` datetime NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  UNIQUE INDEX `uniq_key`(`bank_id`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8 COLLATE = utf8_general_ci ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of total_per_bank
-- ----------------------------

-- ----------------------------
-- Table structure for users
-- ----------------------------
DROP TABLE IF EXISTS `users`;
CREATE TABLE `users`  (
  `id` int UNSIGNED NOT NULL AUTO_INCREMENT,
  `name` varchar(191) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `bank_id` varchar(3) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `branch_id` varchar(6) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `pic_bank_id` varchar(3) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `insurance_id` varchar(3) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `email` varchar(150) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `password` varchar(191) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `remember_token` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `is_active` int NULL DEFAULT 1,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`) USING BTREE,
  UNIQUE INDEX `users_email_unique`(`email`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 18 AVG_ROW_LENGTH = 1489 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of users
-- ----------------------------
INSERT INTO `users` VALUES (1, 'Administrator', '000', 'INS', '000', '001', 'sysadmin@bootcampposfin.com', '$2y$10$sSrsfAPRi.IhEX6BXwW8xeklZztjli.QNC1laS516nVfD.ekjnlmq', 'Sb8ien93dpUrrBwIvSqy7o4sNj1lznqFYgFhhSK9WZOCSIyYNK3H4LyaJZJC', 1, '2018-10-10 10:52:23', '2018-10-10 10:52:23');
INSERT INTO `users` VALUES (3, 'User BNK', '001', '110', '001', '001', 'bnkopr001@bootcampposfin.com', '$2y$10$sSrsfAPRi.IhEX6BXwW8xeklZztjli.QNC1laS516nVfD.ekjnlmq', 'JMinY5jp0LeglCtwdM3aMeT0s6KAc0desXQT206YqOXlxfMJeHq4U9anFEIN', 1, '2018-10-10 10:52:23', '2018-11-24 00:53:32');

-- ----------------------------
-- Function structure for fn_generate_claim_id
-- ----------------------------
DROP FUNCTION IF EXISTS `fn_generate_claim_id`;
delimiter ;;
CREATE FUNCTION `fn_generate_claim_id`(`p_bank_id` VARCHAR(3), `p_branch_id` VARCHAR(3))
 RETURNS varchar(25) CHARSET utf8
BEGIN
  DECLARE hasil varchar(25);

  SELECT
    CONCAT(CONCAT('CLM', SUBSTRING(p_bank_id, 1, 3), SUBSTRING(p_branch_id, 1, 3), DATE_FORMAT(NOW(), '%Y%m%d')), LPAD(CONCAT(SUBSTRING('ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789', RAND() * 36 + 1, 1),
    SUBSTRING('ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789', RAND() * 36 + 1, 1),
    SUBSTRING('ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789', RAND() * 36 + 1, 1),
    SUBSTRING('ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789', RAND() * 36 + 1, 1),
    SUBSTRING('ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789', RAND() * 36 + 1, 1),
    SUBSTRING('ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789', RAND() * 36 + 1, 1),
    SUBSTRING('ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789', RAND() * 36 + 1, 1),
    SUBSTRING('ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789', RAND() * 36 + 1, 1)
    ), 8, '0')) INTO hasil;

  RETURN hasil;
END
;;
delimiter ;

-- ----------------------------
-- Function structure for fn_generate_member_id
-- ----------------------------
DROP FUNCTION IF EXISTS `fn_generate_member_id`;
delimiter ;;
CREATE FUNCTION `fn_generate_member_id`(`p_bank_id` VARCHAR(3), `p_branch_id` VARCHAR(3))
 RETURNS varchar(25) CHARSET utf8
BEGIN
  DECLARE hasil varchar(25);

  SELECT
    CONCAT(CONCAT('AJB', SUBSTRING(p_bank_id, 1, 3), SUBSTRING(p_branch_id, 1, 3), DATE_FORMAT(NOW(), '%Y%m%d')), LPAD(CONCAT(SUBSTRING('ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789', RAND() * 36 + 1, 1),
    SUBSTRING('ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789', RAND() * 36 + 1, 1),
    SUBSTRING('ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789', RAND() * 36 + 1, 1),
    SUBSTRING('ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789', RAND() * 36 + 1, 1),
    SUBSTRING('ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789', RAND() * 36 + 1, 1),
    SUBSTRING('ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789', RAND() * 36 + 1, 1),
    SUBSTRING('ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789', RAND() * 36 + 1, 1),
    SUBSTRING('ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789', RAND() * 36 + 1, 1)
    ), 8, '0')) INTO hasil;

  RETURN hasil;
END
;;
delimiter ;

-- ----------------------------
-- Function structure for fn_generate_repayment_id
-- ----------------------------
DROP FUNCTION IF EXISTS `fn_generate_repayment_id`;
delimiter ;;
CREATE FUNCTION `fn_generate_repayment_id`(`p_bank_id` VARCHAR(3), `p_branch_id` VARCHAR(3))
 RETURNS varchar(25) CHARSET utf8
BEGIN
  DECLARE hasil varchar(25);

  SELECT
    CONCAT(CONCAT('RPY', SUBSTRING(p_bank_id, 1, 3), SUBSTRING(p_branch_id, 1, 3), DATE_FORMAT(NOW(), '%Y%m%d')), LPAD(CONCAT(SUBSTRING('ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789', RAND() * 36 + 1, 1),
    SUBSTRING('ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789', RAND() * 36 + 1, 1),
    SUBSTRING('ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789', RAND() * 36 + 1, 1),
    SUBSTRING('ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789', RAND() * 36 + 1, 1),
    SUBSTRING('ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789', RAND() * 36 + 1, 1),
    SUBSTRING('ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789', RAND() * 36 + 1, 1),
    SUBSTRING('ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789', RAND() * 36 + 1, 1),
    SUBSTRING('ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789', RAND() * 36 + 1, 1)
    ), 8, '0')) INTO hasil;

  RETURN hasil;
END
;;
delimiter ;

-- ----------------------------
-- Procedure structure for sp_update_onclaiming
-- ----------------------------
DROP PROCEDURE IF EXISTS `sp_update_onclaiming`;
delimiter ;;
CREATE PROCEDURE `sp_update_onclaiming`(IN `member_id` VARCHAR(25), IN `bank_id` VARCHAR(3), IN `branch_id` VARCHAR(3))
BEGIN

  UPDATE data_members
  SET data_status_id = 4
  WHERE bank_id = bank_id
  AND id = member_id
  AND branch_id = branch_id;


END
;;
delimiter ;

-- ----------------------------
-- Procedure structure for sp_update_onproposingpelunasan
-- ----------------------------
DROP PROCEDURE IF EXISTS `sp_update_onproposingpelunasan`;
delimiter ;;
CREATE PROCEDURE `sp_update_onproposingpelunasan`(IN `member_id` VARCHAR(25), IN `bank_id` VARCHAR(3), IN `branch_id` VARCHAR(3))
BEGIN

  UPDATE data_members
  SET data_status_id = 7
  WHERE bank_id = bank_id
  AND id = member_id
  AND branch_id = branch_id;


END
;;
delimiter ;

SET FOREIGN_KEY_CHECKS = 1;
