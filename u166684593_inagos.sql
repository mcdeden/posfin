-- phpMyAdmin SQL Dump
-- version 4.9.5
-- https://www.phpmyadmin.net/
--
-- Host: 127.0.0.1:3306
-- Generation Time: Nov 17, 2020 at 01:25 PM
-- Server version: 10.4.15-MariaDB
-- PHP Version: 7.2.34

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
SET AUTOCOMMIT = 0;
START TRANSACTION;
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- Database: `u166684593_inagos`
--

DELIMITER $$
--
-- Procedures
--
CREATE DEFINER=`u166684593_inagosadmin`@`127.0.0.1` PROCEDURE `sp_delete_staging_member` (IN `bank_id` VARCHAR(3), IN `branch_id` VARCHAR(3))  BEGIN

  DELETE
    FROM staging_members
  WHERE bank_id = bank_id
    AND branch_id = branch_id;

END$$

CREATE DEFINER=`u166684593_inagosadmin`@`127.0.0.1` PROCEDURE `sp_delete_staging_mutasi` (IN `bank_id` VARCHAR(3), IN `branch_id` VARCHAR(3))  BEGIN

  DELETE
    FROM staging_mutasi
  WHERE bank_id = bank_id
    AND branch_id = branch_id;

END$$

CREATE DEFINER=`u166684593_inagosadmin`@`127.0.0.1` PROCEDURE `sp_delete_staging_polis` (IN `insurance_id` VARCHAR(3))  NO SQL
BEGIN

  DELETE
    FROM staging_polis
  WHERE insurance_id= insurance_id;

END$$

CREATE DEFINER=`u166684593_inagosadmin`@`127.0.0.1` PROCEDURE `sp_import_member` (IN `bank_id` VARCHAR(3), IN `branch_id` VARCHAR(3))  BEGIN

 UPDATE staging_members
  SET member_id = fn_generate_member_id(bank_id, branch_id);

  UPDATE data_members
  SET record_status_id = 2
  WHERE bank_id = bank_id
  AND branch_id = branch_id
  AND date (created_at) < date (NOW());

  -- if (validation_status_id=1) then
  INSERT INTO data_members (id, loan_id, bank_id, branch_id,insurance_id, product_id, total_premi, plafond, pertanggungan, currency, tenor, insurance_rate, start_date, start_month, start_year, end_date, end_month, end_year,
  customer_deposit_amount, cif, customer_name, birth_date, born_place, age, job,periode_upload, data_status_id, record_status_id, jw_th)
    SELECT
      member_id,
      no_loan,
      bank_id,
      branch_id,
      insurance_id,
      kode_produk,
      beban_nasabah + beban_bank,
      nominal_loan,
      pertanggungan,
      kurs,
      tenor,
      result_rate,
      tgl_mulai,
      MONTH(tgl_mulai),
      YEAR(tgl_mulai),
      tgl_selesai,
      MONTH(tgl_selesai),
      YEAR(tgl_selesai),
      no_rekening,
      cif,
      nama_nasabah,
      tgl_lahir,
      tempat_lahir,
      rounding_age,
      pekerjaan,
      periode_upload,
      1,
      1,
      tenor DIV 12
    FROM staging_members
    WHERE bank_id = bank_id
    AND branch_id = branch_id
    AND validation_status_id = 1
  ON DUPLICATE KEY UPDATE
  updated_at = CURRENT_TIMESTAMP();

  DELETE
    FROM data_hold_members
  WHERE bank_id = bank_id
    AND branch_id = branch_id
    AND loan_id IN (SELECT
        loan_id
      FROM data_members);

  -- else 
  INSERT INTO data_hold_members (loan_id, bank_id, branch_id,insurance_id, product_id, total_premi, plafond, pertanggungan, currency,
  tenor, insurance_rate, start_date, end_date, customer_deposit_amount, cif, customer_name, birth_date, born_place, job,periode_upload, data_status_id,
  rounding_age, rounding_jw, sum_age_jw, ass_premi_calculation, validation_status_id)
    SELECT
      no_loan,
      bank_id,
      branch_id,
      insurance_id,
      kode_produk,
      beban_nasabah + beban_bank,
      nominal_loan,
      pertanggungan,
      kurs,
      tenor,
      result_rate,
      tgl_mulai,
      tgl_selesai,
      no_rekening,
      cif,
      nama_nasabah,
      tgl_lahir,
      tempat_lahir,
      pekerjaan,
      periode_upload,
      6,
      rounding_age,
      rounding_jw,
      sum_age_jw,
      result_pertanggungan,
      validation_status_id
    FROM staging_members
    WHERE bank_id = bank_id
    AND branch_id = branch_id
    AND validation_status_id <> 1
  ON DUPLICATE KEY UPDATE
  updated_at = CURRENT_TIMESTAMP();
END$$

CREATE DEFINER=`u166684593_inagosadmin`@`127.0.0.1` PROCEDURE `sp_update_onclaiming` (IN `member_id` VARCHAR(25), IN `bank_id` VARCHAR(3), IN `branch_id` VARCHAR(3))  BEGIN

  UPDATE data_members
  SET data_status_id = 4
  WHERE bank_id = bank_id
  AND id = member_id
  AND branch_id = branch_id;


END$$

CREATE DEFINER=`u166684593_inagosadmin`@`127.0.0.1` PROCEDURE `sp_update_onproposingpelunasan` (IN `member_id` VARCHAR(25), IN `bank_id` VARCHAR(3), IN `branch_id` VARCHAR(3))  BEGIN

  UPDATE data_members
  SET data_status_id = 7
  WHERE bank_id = bank_id
  AND id = member_id
  AND branch_id = branch_id;


END$$

CREATE DEFINER=`u166684593_inagosadmin`@`127.0.0.1` PROCEDURE `sp_update_polis` (IN `insurance_id` VARCHAR(3))  NO SQL
BEGIN

 UPDATE data_members a
INNER JOIN staging_polis b ON a.loan_id = b.loan_id
SET a.polis_number = b.polis_number, a.data_status_id = 2
where b.insurance_id=insurance_id ;

END$$

CREATE DEFINER=`u166684593_inagosadmin`@`127.0.0.1` PROCEDURE `sp_validation` (IN `bank_id` VARCHAR(3), IN `branch_id` VARCHAR(3))  BEGIN

  UPDATE staging_members
  SET rounding_age = fn_calculate_round_age(tgl_lahir, tgl_mulai)
  WHERE bank_id = bank_id
  AND branch_id = branch_id;

  UPDATE staging_members a
  INNER JOIN master_validation_rules b
    ON a.kode_produk = b.product_id
  SET a.val_min_age = (
  CASE WHEN a.rounding_age < (SELECT
          param_value
        FROM master_validation_rules
        WHERE param_name = 'MIN_AGE'
        AND product_id = a.kode_produk) THEN 1 ELSE 1 END
  )
  WHERE a.bank_id = bank_id
  AND a.branch_id = branch_id;

  UPDATE staging_members
  SET rounding_jw = fn_calculate_round_jw(tenor)
  WHERE bank_id = bank_id
  AND branch_id = branch_id;

  UPDATE staging_members
  SET sum_age_jw = rounding_age + rounding_jw
  WHERE bank_id = bank_id
  AND branch_id = branch_id;

  UPDATE staging_members a
  INNER JOIN master_validation_rules b
    ON a.kode_produk = b.product_id
  SET a.val_max_age = (
  CASE WHEN a.sum_age_jw > (SELECT
          param_value
        FROM master_validation_rules
        WHERE param_name = 'MAX_AGE'
        AND product_id = a.kode_produk) THEN 1 ELSE 1 END
  )
  WHERE a.bank_id = bank_id
  AND a.branch_id = branch_id;

  UPDATE staging_members a
  INNER JOIN master_map_product_insurances b
    ON a.kode_produk = b.product_id
  SET a.result_rate = fn_get_rate_ajb(b.insurance_kind_id, a.bank_id, a.rounding_age, a.rounding_jw)
  WHERE a.bank_id = bank_id
  AND a.branch_id = branch_id;

  UPDATE staging_members
  SET result_pertanggungan = IFNULL((pertanggungan * result_rate) / 1000, 0)
  WHERE bank_id = bank_id
  AND branch_id = branch_id;

  UPDATE staging_members
  SET val_pertanggungan =
  (
  CASE WHEN beban_nasabah + beban_bank = result_pertanggungan THEN 1 ELSE 1 END
  )
  WHERE bank_id = bank_id
  AND branch_id = branch_id;

  UPDATE staging_members
  SET validation_status_id =
  (
  CASE WHEN val_min_age = 1 AND
      val_max_age = 1 AND
      val_pertanggungan = 1 THEN 1 ELSE (
      CASE WHEN val_min_age = 0 THEN 1 ELSE (
          CASE WHEN val_max_age = 0 THEN 1 ELSE (
              CASE WHEN val_pertanggungan = 0 THEN 1 ELSE 1 END
              ) END
          ) END
      ) END
  )
  WHERE bank_id = bank_id
  AND branch_id = branch_id;


END$$

CREATE DEFINER=`u166684593_inagosadmin`@`127.0.0.1` PROCEDURE `sp_validation_ori` (IN `bank_id` VARCHAR(3), IN `branch_id` VARCHAR(3))  BEGIN

  UPDATE staging_members
  SET rounding_age = fn_calculate_round_age(tgl_lahir, tgl_mulai)
  WHERE bank_id = bank_id
  AND branch_id = branch_id;

  UPDATE staging_members a
  INNER JOIN master_validation_rules b
    ON a.kode_produk = b.product_id
  SET a.val_min_age = (
  CASE WHEN a.rounding_age < (SELECT
          param_value
        FROM master_validation_rules
        WHERE param_name = 'MIN_AGE'
        AND product_id = a.kode_produk) THEN 0 ELSE 1 END
  )
  WHERE a.bank_id = bank_id
  AND a.branch_id = branch_id;

  UPDATE staging_members
  SET rounding_jw = fn_calculate_round_jw(tenor)
  WHERE bank_id = bank_id
  AND branch_id = branch_id;

  UPDATE staging_members
  SET sum_age_jw = rounding_age + rounding_jw
  WHERE bank_id = bank_id
  AND branch_id = branch_id;

  UPDATE staging_members a
  INNER JOIN master_validation_rules b
    ON a.kode_produk = b.product_id
  SET a.val_max_age = (
  CASE WHEN a.sum_age_jw > (SELECT
          param_value
        FROM master_validation_rules
        WHERE param_name = 'MAX_AGE'
        AND product_id = a.kode_produk) THEN 0 ELSE 1 END
  )
  WHERE a.bank_id = bank_id
  AND a.branch_id = branch_id;

  UPDATE staging_members a
  INNER JOIN master_map_product_insurances b
    ON a.kode_produk = b.product_id
  SET a.result_rate = fn_get_rate_ajb(b.insurance_kind_id, a.bank_id, a.rounding_age, a.rounding_jw)
  WHERE a.bank_id = bank_id
  AND a.branch_id = branch_id;

  UPDATE staging_members
  SET result_pertanggungan = IFNULL((pertanggungan * result_rate) / 1000, 0)
  WHERE bank_id = bank_id
  AND branch_id = branch_id;

  UPDATE staging_members
  SET val_pertanggungan =
  (
  CASE WHEN beban_nasabah + beban_bank = result_pertanggungan THEN 1 ELSE 0 END
  )
  WHERE bank_id = bank_id
  AND branch_id = branch_id;

  UPDATE staging_members
  SET validation_status_id =
  (
  CASE WHEN val_min_age = 1 AND
      val_max_age = 1 AND
      val_pertanggungan = 1 THEN 1 ELSE (
      CASE WHEN val_min_age = 0 THEN 2 ELSE (
          CASE WHEN val_max_age = 0 THEN 3 ELSE (
              CASE WHEN val_pertanggungan = 0 THEN 4 ELSE 1 END
              ) END
          ) END
      ) END
  )
  WHERE bank_id = bank_id
  AND branch_id = branch_id;


END$$

CREATE DEFINER=`u166684593_inagosadmin`@`127.0.0.1` PROCEDURE `sp_verify_mutasi` (IN `bank_id` VARCHAR(3))  BEGIN

  UPDATE data_members a
  INNER JOIN staging_mutasi b
    ON a.loan_id = b.loan_id
  SET a.data_status_id = CASE WHEN a.total_premi = b.nominal THEN 2 ELSE 1 END
  WHERE a.bank_id = bank_id;


END$$

--
-- Functions
--
CREATE DEFINER=`u166684593_inagosadmin`@`127.0.0.1` FUNCTION `fn_calculate_round_age` (`tgl_awal` DATE, `tgl_akhir` DATE) RETURNS INT(11) BEGIN
  DECLARE n_div integer;
  DECLARE n_mod integer;
  DECLARE result integer;

  SET n_div = TIMESTAMPDIFF(MONTH, tgl_awal, tgl_akhir) DIV 12;
  SET n_mod = TIMESTAMPDIFF(MONTH, tgl_awal, tgl_akhir) MOD 12;

  IF (n_mod <= 6) THEN
    SET result = n_div;
  ELSE
    SET result = n_div + 1;
  END IF;

  RETURN result;
END$$

CREATE DEFINER=`u166684593_inagosadmin`@`127.0.0.1` FUNCTION `fn_calculate_round_jw` (`jw` INT) RETURNS INT(11) BEGIN
  DECLARE n_div integer;
  DECLARE n_mod integer;
  DECLARE result integer;

  SET n_div = jw DIV 12;
  SET n_mod = jw MOD 12;

  IF (n_mod > 0) THEN
    SET result = n_div + 1;
  ELSE
    SET result = n_div;
  END IF;

  RETURN result;
END$$

CREATE DEFINER=`u166684593_inagosadmin`@`127.0.0.1` FUNCTION `fn_generate_claim_id` (`p_bank_id` VARCHAR(3), `p_branch_id` VARCHAR(3)) RETURNS VARCHAR(25) CHARSET utf8 BEGIN
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
END$$

CREATE DEFINER=`u166684593_inagosadmin`@`127.0.0.1` FUNCTION `fn_generate_member_id` (`p_bank_id` VARCHAR(3), `p_branch_id` VARCHAR(3)) RETURNS VARCHAR(25) CHARSET utf8 BEGIN
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
END$$

CREATE DEFINER=`u166684593_inagosadmin`@`127.0.0.1` FUNCTION `fn_generate_repayment_id` (`p_bank_id` VARCHAR(3), `p_branch_id` VARCHAR(3)) RETURNS VARCHAR(25) CHARSET utf8 BEGIN
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
END$$

CREATE DEFINER=`u166684593_inagosadmin`@`127.0.0.1` FUNCTION `fn_get_rate_ajb` (`p_asuransi_id` VARCHAR(10), `p_bank_id` VARCHAR(3), `p_age` INT, `p_jw` INT) RETURNS DECIMAL(10,2) BEGIN
  DECLARE n decimal(10, 2);

  SELECT
    rate INTO n
  FROM master_insurance_rates
  WHERE insurance_kind_id = p_asuransi_id
  AND bank_id = p_bank_id
  AND age = p_age
  AND jw = p_jw;

  RETURN IFNULL(n, 0);
END$$

CREATE DEFINER=`u166684593_inagosadmin`@`127.0.0.1` FUNCTION `fn_validate_by_loan` (`loan_id` VARCHAR(20)) RETURNS INT(11) BEGIN
  DECLARE result integer;
  DECLARE h_val_min_age int;
  DECLARE h_val_max_age int;
  DECLARE h_val_premi int;

  SET h_val_min_age = fn_validate_min_age(loan_id);
  SET h_val_max_age = fn_validate_max_age(loan_id);
  SET h_val_premi = fn_validate_premi(loan_id);

  IF ((h_val_min_age = 1)
    AND (h_val_max_age = 1)
    AND (h_val_premi = 1)) THEN
    SET result = 1;
  ELSE
    SET result = 0;
  END IF;

  RETURN result;

END$$

CREATE DEFINER=`u166684593_inagosadmin`@`127.0.0.1` FUNCTION `fn_validate_max_age` (`loan_id` VARCHAR(20)) RETURNS INT(11) BEGIN
  DECLARE result integer;

  DECLARE v_birth_date date;
  DECLARE v_start_date date;
  DECLARE v_tenor integer;
  DECLARE v_rounding_jw integer;
  DECLARE v_rounding_age integer;
  DECLARE v_sum_age_jw integer;
  DECLARE v_param_value integer;
  DECLARE v_product_id varchar(15);

  SELECT
    birth_date,
    start_date,
    tenor,
    product_id INTO v_birth_date, v_start_date, v_tenor, v_product_id
  FROM data_loan_holds
  WHERE id = loan_id;

  SET v_rounding_age = fn_calculate_round_age(v_birth_date, v_start_date);
  SET v_rounding_jw = fn_calculate_round_jw(v_tenor);
  SET v_sum_age_jw = v_rounding_age + v_rounding_jw;

  SELECT
    param_value INTO v_param_value
  FROM master_validation_rules
  WHERE param_name = 'MAX_AGE'
  AND product_id = v_product_id;

  IF (v_sum_age_jw > v_param_value) THEN
    SET result = 0;
  ELSE
    SET result = 1;
  END IF;

  RETURN result;

END$$

CREATE DEFINER=`u166684593_inagosadmin`@`127.0.0.1` FUNCTION `fn_validate_min_age` (`loan_id` VARCHAR(20)) RETURNS INT(11) BEGIN
  DECLARE result integer;

  DECLARE v_birth_date date;
  DECLARE v_start_date date;
  DECLARE v_product_id varchar(15);
  DECLARE v_param_value integer;
  DECLARE v_rounding_age integer;

  SELECT
    birth_date,
    start_date,
    product_id INTO v_birth_date, v_start_date, v_product_id
  FROM data_loan_holds
  WHERE id = loan_id;

  SET v_rounding_age = fn_calculate_round_age(v_birth_date, v_start_date);

  SELECT
    param_value INTO v_param_value
  FROM master_validation_rules
  WHERE param_name = 'MIN_AGE'
  AND product_id = v_product_id;

  IF (v_rounding_age < v_param_value) THEN
    SET result = 0;
  ELSE
    SET result = 1;
  END IF;

  RETURN result;

END$$

CREATE DEFINER=`u166684593_inagosadmin`@`127.0.0.1` FUNCTION `fn_validate_premi` (`loan_id` VARCHAR(20)) RETURNS INT(11) BEGIN
  DECLARE result integer;

  DECLARE v_rate decimal(10, 2);
  DECLARE v_birth_date date;
  DECLARE v_start_date date;
  DECLARE v_product_id varchar(15);
  DECLARE v_insurance_kind_id varchar(6);
  DECLARE v_bank_id varchar(3);
  DECLARE v_tenor integer;
  DECLARE v_result_pertanggungan decimal(20, 2);
  DECLARE v_pertanggungan decimal(20, 2);
  DECLARE v_rounding_jw integer;
  DECLARE v_rounding_age integer;
  DECLARE v_total_premi decimal(20, 2);

  SELECT
    birth_date,
    start_date,
    product_id,
    bank_id,
    tenor,
    pertanggungan,
    total_premi INTO v_birth_date, v_start_date, v_product_id, v_bank_id, v_tenor, v_pertanggungan, v_total_premi
  FROM data_loan_holds
  WHERE id = loan_id;

  SELECT
    insurance_kind_id INTO v_insurance_kind_id
  FROM master_map_product_insurances
  WHERE product_id = v_product_id;
  SET v_rounding_age = fn_calculate_round_age(v_birth_date, v_start_date);
  SET v_rounding_jw = fn_calculate_round_jw(v_tenor);

  SET v_rate = fn_get_rate_ajb(v_insurance_kind_id, v_bank_id, v_rounding_age, v_rounding_jw);

  SET v_result_pertanggungan = IFNULL((v_pertanggungan * v_rate) / 1000, 0);

  IF (v_total_premi = v_result_pertanggungan) THEN
    SET result = 1;
  ELSE
    SET result = 0;
  END IF;

  RETURN result;

END$$

DELIMITER ;

-- --------------------------------------------------------

--
-- Table structure for table `data_claims`
--

CREATE TABLE `data_claims` (
  `id` varchar(25) NOT NULL,
  `member_id` varchar(25) DEFAULT NULL,
  `bank_id` varchar(3) DEFAULT NULL,
  `branch_id` varchar(3) DEFAULT NULL,
  `customer_name` varchar(255) DEFAULT NULL,
  `product_id` varchar(15) DEFAULT NULL,
  `nominal_pengajuan` decimal(30,2) DEFAULT NULL,
  `tgl_meninggal` date DEFAULT NULL,
  `bulan_meninggal` int(11) DEFAULT NULL,
  `tahun_meninggal` int(11) DEFAULT NULL,
  `tgl_pengajuan` date DEFAULT NULL,
  `bulan_pengajuan` int(11) DEFAULT NULL,
  `tahun_pengajuan` int(11) DEFAULT NULL,
  `keterangan` varchar(255) DEFAULT NULL,
  `tgl_pembayaran` date DEFAULT NULL,
  `bulan_pembayaran` int(11) DEFAULT NULL,
  `tahun_pembayaran` int(11) DEFAULT NULL,
  `claim_status_id` int(11) DEFAULT 1,
  `keterangan_status_claim` varchar(200) DEFAULT NULL,
  `created_at` datetime DEFAULT current_timestamp(),
  `updated_at` datetime DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  `nominal_dibayarkan` decimal(30,2) DEFAULT NULL
) ENGINE=InnoDB AVG_ROW_LENGTH=5461 DEFAULT CHARSET=utf8 ROW_FORMAT=DYNAMIC;

--
-- Dumping data for table `data_claims`
--

INSERT INTO `data_claims` (`id`, `member_id`, `bank_id`, `branch_id`, `customer_name`, `product_id`, `nominal_pengajuan`, `tgl_meninggal`, `bulan_meninggal`, `tahun_meninggal`, `tgl_pengajuan`, `bulan_pengajuan`, `tahun_pengajuan`, `keterangan`, `tgl_pembayaran`, `bulan_pembayaran`, `tahun_pembayaran`, `claim_status_id`, `keterangan_status_claim`, `created_at`, `updated_at`, `nominal_dibayarkan`) VALUES
('CLM212110201903085QX3GOQE', 'AJB21211020190308037E2VT9', '212', '110', 'AMID', '3100400001', '1000000.00', '2018-11-01', 11, 2018, '2019-03-08', 3, 2019, 'meninggal', NULL, NULL, NULL, 2, 'surat kemaitian kurang', '2019-03-08 04:31:44', '2019-03-08 04:32:44', NULL),
('CLM21211020201016BV4PV048', 'AJB21211020201012SAROQEI0', '212', '110', 'IRFAN I', '3100400001', '10000000.00', '2020-10-16', 10, 2020, '2020-10-16', 10, 2020, 'test', '2020-10-16', NULL, NULL, 6, 'Dalam tahap review & verifikasi', '2020-10-16 11:37:57', '2020-10-16 11:50:07', '213123123.00'),
('CLM21211020201016Z0W6UD2W', 'AJB212110202010128VDX84NM', '212', '110', 'IRFAN J', '3100400001', '500000.00', '2020-10-16', 10, 2020, '2020-10-16', 10, 2020, 'test', '2020-10-19', NULL, NULL, 6, 'Sudah dibayar', '2020-10-16 10:14:16', '2020-10-16 11:23:23', NULL),
('CLM21211120190321PRFJ3LDU', 'AJB21211120190321033Y5NIM', '212', '111', 'ROHAEDI', '3100400001', '34535345435.00', '2019-03-21', 3, 2019, '2019-03-22', 3, 2019, '435354354353', NULL, NULL, NULL, 1, 'Dalam tahap review & verifikasi', '2019-03-21 03:03:10', '2019-03-21 03:03:10', NULL),
('CLM21211120190321W5TBTUJT', 'AJB21211120190321033Y5NIM', '212', '111', 'ROHAEDI', '3100400001', '32442.00', '2019-03-21', 3, 2019, '2019-03-21', 3, 2019, '2342344', '2020-09-10', NULL, NULL, 6, 'Dibayarkan', '2019-03-21 03:39:27', '2020-09-04 01:28:30', NULL);

-- --------------------------------------------------------

--
-- Table structure for table `data_documents`
--

CREATE TABLE `data_documents` (
  `id` bigint(20) NOT NULL,
  `member_id` varchar(25) DEFAULT NULL,
  `filename` varchar(255) DEFAULT NULL,
  `created_at` datetime DEFAULT current_timestamp(),
  `updated_at` datetime DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  `file_id` int(11) DEFAULT NULL
) ENGINE=InnoDB AVG_ROW_LENGTH=4096 DEFAULT CHARSET=utf8 ROW_FORMAT=DYNAMIC;

--
-- Dumping data for table `data_documents`
--

INSERT INTO `data_documents` (`id`, `member_id`, `filename`, `created_at`, `updated_at`, `file_id`) VALUES
(26, 'AJB212110202010128VDX84NM', '', '2020-10-16 11:04:28', '2020-10-16 11:04:28', 1),
(27, 'AJB212110202010128VDX84NM', '', '2020-10-16 11:04:28', '2020-10-16 11:04:28', 2),
(28, 'AJB212110202010128VDX84NM', '', '2020-10-16 11:04:28', '2020-10-16 11:04:28', 3),
(29, 'AJB212110202010128VDX84NM', '', '2020-10-16 11:04:28', '2020-10-16 11:04:28', 4),
(30, 'AJB212110202010128VDX84NM', '', '2020-10-16 11:04:28', '2020-10-16 11:04:28', 5),
(31, 'AJB212110202010128VDX84NM', '', '2020-10-16 11:04:28', '2020-10-16 11:04:28', 6),
(32, 'AJB21211020201012SAROQEI0', '', '2020-10-16 11:37:57', '2020-10-16 11:37:57', 1),
(33, 'AJB21211020201012SAROQEI0', '', '2020-10-16 11:37:57', '2020-10-16 11:37:57', 2),
(34, 'AJB21211020201012SAROQEI0', '', '2020-10-16 11:37:57', '2020-10-16 11:37:57', 3),
(35, 'AJB21211020201012SAROQEI0', '', '2020-10-16 11:37:57', '2020-10-16 11:37:57', 4),
(36, 'AJB21211020201012SAROQEI0', '', '2020-10-16 11:37:57', '2020-10-16 11:37:57', 5),
(37, 'AJB21211020201012SAROQEI0', '', '2020-10-16 11:37:57', '2020-10-16 11:37:57', 6);

-- --------------------------------------------------------

--
-- Table structure for table `data_hold_members`
--

CREATE TABLE `data_hold_members` (
  `id` bigint(20) NOT NULL,
  `loan_id` varchar(20) CHARACTER SET utf8 NOT NULL,
  `bank_id` varchar(3) CHARACTER SET utf8 DEFAULT NULL,
  `branch_id` varchar(3) CHARACTER SET utf8 DEFAULT NULL,
  `insurance_id` varchar(3) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `product_id` varchar(15) CHARACTER SET utf8 DEFAULT NULL,
  `total_premi` decimal(20,2) DEFAULT 0.00,
  `plafond` decimal(20,2) DEFAULT 0.00,
  `pertanggungan` decimal(20,2) DEFAULT 0.00,
  `currency` varchar(5) CHARACTER SET utf8 DEFAULT NULL,
  `tenor` int(11) DEFAULT 0,
  `insurance_rate` decimal(10,2) DEFAULT NULL,
  `start_date` date DEFAULT NULL,
  `end_date` date DEFAULT NULL,
  `customer_deposit_amount` varchar(15) CHARACTER SET utf8 DEFAULT NULL,
  `cif` varchar(10) CHARACTER SET utf8 DEFAULT NULL,
  `customer_name` varchar(255) CHARACTER SET utf8 DEFAULT NULL,
  `birth_date` date DEFAULT NULL,
  `born_place` varchar(100) CHARACTER SET utf8 DEFAULT NULL,
  `job` varchar(200) CHARACTER SET utf8 DEFAULT NULL,
  `periode_upload` date DEFAULT NULL,
  `data_status_id` int(11) DEFAULT NULL,
  `rounding_age` int(11) DEFAULT NULL,
  `rounding_jw` int(11) DEFAULT NULL,
  `sum_age_jw` int(11) DEFAULT NULL,
  `ass_premi_calculation` decimal(30,2) DEFAULT NULL,
  `validation_status_id` int(11) DEFAULT 0,
  `created_at` timestamp NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB AVG_ROW_LENGTH=8192 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci ROW_FORMAT=DYNAMIC;

--
-- Dumping data for table `data_hold_members`
--

INSERT INTO `data_hold_members` (`id`, `loan_id`, `bank_id`, `branch_id`, `insurance_id`, `product_id`, `total_premi`, `plafond`, `pertanggungan`, `currency`, `tenor`, `insurance_rate`, `start_date`, `end_date`, `customer_deposit_amount`, `cif`, `customer_name`, `birth_date`, `born_place`, `job`, `periode_upload`, `data_status_id`, `rounding_age`, `rounding_jw`, `sum_age_jw`, `ass_premi_calculation`, `validation_status_id`, `created_at`, `updated_at`) VALUES
(1, 'GEN2632018070001', '212', '110', NULL, '3100400001', '3624000.00', '230000000.00', '100000000.00', 'IDR', 156, '0.00', '2018-07-02', '2031-07-02', '200110000679', '503200', 'MULYAWATI', '2017-01-05', 'CIAMIS', 'PENSIONS', NULL, 6, 1, 13, 14, '0.00', 2, '2019-03-08 11:12:15', '2019-03-08 11:12:15'),
(2, 'GEN2612018070002', '212', '110', NULL, '3100400001', '3780000.00', '239000000.00', '100000000.00', 'IDR', 168, '0.00', '2018-07-02', '2032-07-02', '200110000679', '502942', 'YONNI KUSWARDIONO', '1912-06-24', 'CIAMIS', 'PENSIONS', NULL, 6, 106, 14, 120, '0.00', 3, '2019-03-08 11:12:15', '2019-03-08 11:12:15');

-- --------------------------------------------------------

--
-- Table structure for table `data_members`
--

CREATE TABLE `data_members` (
  `id` varchar(25) COLLATE utf8mb4_unicode_ci NOT NULL,
  `loan_id` varchar(20) CHARACTER SET utf8 NOT NULL,
  `polis_number` varchar(100) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `bank_id` varchar(3) CHARACTER SET utf8 DEFAULT NULL,
  `branch_id` varchar(3) CHARACTER SET utf8 DEFAULT NULL,
  `insurance_id` varchar(3) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `product_id` varchar(15) CHARACTER SET utf8 DEFAULT NULL,
  `total_premi` decimal(20,2) DEFAULT 0.00,
  `plafond` decimal(20,2) DEFAULT 0.00,
  `pertanggungan` decimal(20,2) DEFAULT 0.00,
  `currency` varchar(5) CHARACTER SET utf8 DEFAULT NULL,
  `tenor` int(11) DEFAULT 0,
  `jw_th` int(11) DEFAULT NULL,
  `jw_bl` int(11) DEFAULT 0,
  `jw_hr` int(11) DEFAULT 0,
  `insurance_rate` decimal(10,2) DEFAULT NULL,
  `start_date` date DEFAULT NULL,
  `start_month` int(11) DEFAULT NULL,
  `start_year` int(11) DEFAULT NULL,
  `end_date` date DEFAULT NULL,
  `end_year` int(11) DEFAULT NULL,
  `end_month` int(11) DEFAULT NULL,
  `customer_deposit_amount` varchar(15) CHARACTER SET utf8 DEFAULT NULL,
  `cif` varchar(10) CHARACTER SET utf8 DEFAULT NULL,
  `customer_name` varchar(255) CHARACTER SET utf8 DEFAULT NULL,
  `birth_date` date DEFAULT NULL,
  `born_place` varchar(100) CHARACTER SET utf8 DEFAULT NULL,
  `age` int(11) DEFAULT 0,
  `job` varchar(200) CHARACTER SET utf8 DEFAULT NULL,
  `periode_upload` date DEFAULT NULL,
  `ibu_kandung` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT 'IBU',
  `gender` varchar(1) COLLATE utf8mb4_unicode_ci DEFAULT 'L',
  `data_status_id` int(11) DEFAULT 1,
  `keterangan_loan_status` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `record_status_id` int(11) DEFAULT 1,
  `is_uploaded_to_ajb_core` int(11) DEFAULT 0,
  `created_at` timestamp NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB AVG_ROW_LENGTH=780 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci ROW_FORMAT=DYNAMIC;

--
-- Dumping data for table `data_members`
--

INSERT INTO `data_members` (`id`, `loan_id`, `polis_number`, `bank_id`, `branch_id`, `insurance_id`, `product_id`, `total_premi`, `plafond`, `pertanggungan`, `currency`, `tenor`, `jw_th`, `jw_bl`, `jw_hr`, `insurance_rate`, `start_date`, `start_month`, `start_year`, `end_date`, `end_year`, `end_month`, `customer_deposit_amount`, `cif`, `customer_name`, `birth_date`, `born_place`, `age`, `job`, `periode_upload`, `ibu_kandung`, `gender`, `data_status_id`, `keterangan_loan_status`, `record_status_id`, `is_uploaded_to_ajb_core`, `created_at`, `updated_at`) VALUES
('AJB21211020190308037E2VT9', 'GEN2372018070007', 'asdsewqeq3qewrw', '212', '110', 'AJB', '3100400001', '17595000.00', '208000000.00', '100000000.00', 'IDR', 168, 14, 0, 0, '175.95', '2018-07-03', 7, 2018, '2032-07-03', 2032, 7, '200110000679', '263647', 'AMID', '1957-08-19', 'CIANJUR', 61, 'PENSIONS', NULL, 'IBU', 'L', 2, NULL, 2, 1, '2019-03-08 11:12:15', '2020-10-17 03:29:40'),
('AJB212110201903080WF1O0QC', 'GEN3502018070003', '3434343434434', '212', '110', 'AJB', '3100400001', '14985000.00', '250000000.00', '100000000.00', 'IDR', 180, 15, 0, 0, '149.85', '2018-07-02', 7, 2018, '2033-07-02', 2033, 7, '200110000679', '502658', 'ALI MUKDIN', '1960-01-28', 'SIDOARJO', 58, 'PENSIONS', NULL, 'IBU', 'L', 2, NULL, 2, 1, '2019-03-08 11:12:15', '2020-10-17 03:29:59'),
('AJB2121102019030811RHUHL8', 'GEN2682018070003', NULL, '212', '110', 'AJB', '3100400001', '16240000.00', '188000000.00', '100000000.00', 'IDR', 168, 14, 0, 0, '162.40', '2018-07-02', 7, 2018, '2032-07-02', 2032, 7, '200110000679', '503131', 'ENTOM ABDUL AJID', '1958-05-02', 'TASIKMALAYA', 60, 'PENSIONS', NULL, 'IBU', 'L', 2, NULL, 2, 1, '2019-03-08 11:12:15', '2020-10-17 03:30:00'),
('AJB212110201903081A37IOH4', 'GEN2632018070002', NULL, '212', '110', 'AJB', '3100400001', '14985000.00', '222000000.00', '100000000.00', 'IDR', 180, 15, 0, 0, '149.85', '2018-07-02', 7, 2018, '2033-07-02', 2033, 7, '200110000679', '500973', 'SABRI AHMAD', '1959-12-13', 'CIAMIS', 58, 'PENSIONS', NULL, 'IBU', 'L', 2, NULL, 2, 1, '2019-03-08 11:12:15', '2020-10-17 03:30:00'),
('AJB212110201903081W06IONW', 'GEN3022018070003', NULL, '212', '110', 'AJB', '3100400001', '13837000.00', '217500000.00', '100000000.00', 'IDR', 180, 15, 0, 0, '138.37', '2018-07-02', 7, 2018, '2033-07-02', 2033, 7, '200110000679', '500974', 'SUYUDIN', '1961-06-04', 'KUNINGAN', 57, 'PENSIONS', NULL, 'IBU', 'L', 2, NULL, 2, 1, '2019-03-08 11:12:15', '2020-10-17 03:30:00'),
('AJB2121102019030826CV3I09', 'GEN1812018070001', NULL, '212', '110', 'AJB', '3100400001', '16225000.00', '219000000.00', '100000000.00', 'IDR', 180, 15, 0, 0, '162.25', '2018-07-02', 7, 2018, '2033-07-02', 2033, 7, '200110000679', '503351', 'MOMON', '1959-01-02', 'SUMEDANG', 59, 'EDUCATION', NULL, 'IBU', 'L', 2, NULL, 2, 1, '2019-03-08 11:12:15', '2020-10-17 03:30:00'),
('AJB212110201903082DB6MDMR', 'GEN1412018070002', NULL, '212', '110', 'AJB', '3100400001', '17566000.00', '227000000.00', '100000000.00', 'IDR', 180, 15, 0, 0, '175.66', '2018-07-02', 7, 2018, '2033-07-02', 2033, 7, '200110000679', '503219', 'ELY KUSNELY', '1958-11-11', 'GARUT', 60, 'PENSIONS', NULL, 'IBU', 'L', 2, NULL, 2, 1, '2019-03-08 11:12:15', '2020-10-17 03:30:00'),
('AJB212110201903082PZICV2C', 'GEN3002018070001', NULL, '212', '110', 'AJB', '3100400001', '16240000.00', '240000000.00', '100000000.00', 'IDR', 168, 14, 0, 0, '162.40', '2018-07-02', 7, 2018, '2032-07-02', 2032, 7, '200110000679', '503338', 'WARTA ATMAJA', '1958-04-12', 'CIREBON', 60, 'PENSIONS', NULL, 'IBU', 'L', 2, NULL, 2, 1, '2019-03-08 11:12:15', '2020-10-17 03:30:00'),
('AJB212110201903083EDEMLSY', 'GEN2632018070003', NULL, '212', '110', 'AJB', '3100400001', '16240000.00', '238000000.00', '100000000.00', 'IDR', 168, 14, 0, 0, '162.40', '2018-07-02', 7, 2018, '2032-07-02', 2032, 7, '200110000679', '503222', 'SRI RAHAYU', '1958-04-28', 'BANJAR', 60, 'PENSIONS', NULL, 'IBU', 'L', 2, NULL, 2, 1, '2019-03-08 11:12:15', '2020-10-17 03:30:00'),
('AJB212110201903088VE0KKSZ', 'GEN2702018070001', NULL, '212', '110', 'AJB', '3100400001', '17524000.00', '221000000.00', '100000000.00', 'IDR', 156, 13, 0, 0, '175.24', '2018-07-02', 7, 2018, '2031-07-02', 2031, 7, '200110000679', '503027', 'ERNI SUSTIATI', '1956-07-28', 'SUKABUMI', 62, 'PENSIONS', NULL, 'IBU', 'L', 2, NULL, 2, 1, '2019-03-08 11:12:15', '2020-10-17 03:30:00'),
('AJB212110201903088ZYH9IK0', 'GEN3002018070002', NULL, '212', '110', 'AJB', '3100400001', '17566000.00', '230000000.00', '100000000.00', 'IDR', 180, 15, 0, 0, '175.66', '2018-07-02', 7, 2018, '2033-07-02', 2033, 7, '200110000679', '503191', 'RODIANAH', '1958-07-14', 'JAKARTA', 60, 'PENSIONS', NULL, 'IBU', 'L', 2, NULL, 2, 1, '2019-03-08 11:12:15', '2020-10-17 03:30:00'),
('AJB212110201903089CNYIFB0', 'GEN3402018070002', NULL, '212', '110', 'AJB', '3100400001', '17332000.00', '195000000.00', '100000000.00', 'IDR', 144, 12, 0, 0, '173.32', '2018-07-03', 7, 2018, '2030-07-03', 2030, 7, '200110000679', '362681', 'LESTARIYANTO', '1955-08-04', 'GUNUNG KIDUL', 63, 'GOVERNMENT EMPLOYEES / STATE-OWNED ENTERPRISES', NULL, 'IBU', 'L', 2, NULL, 2, 1, '2019-03-08 11:12:15', '2020-10-17 03:30:00'),
('AJB21211020190308C4BYHBUY', 'GEN3002018070004', NULL, '212', '110', 'AJB', '3100400001', '8923500.00', '150000000.00', '75000000.00', 'IDR', 120, 10, 0, 0, '118.98', '2018-07-03', 7, 2018, '2028-07-03', 2028, 7, '200110000679', '503189', 'TOETY HERYANI', '1956-12-26', 'BANDUNG', 61, 'PENSIONS', NULL, 'IBU', 'L', 2, NULL, 2, 1, '2019-03-08 11:12:15', '2020-10-17 03:30:00'),
('AJB21211020190308CA7UBQEL', 'GEN2662018070001', NULL, '212', '110', 'AJB', '3100400001', '15977000.00', '241000000.00', '100000000.00', 'IDR', 144, 12, 0, 0, '159.77', '2018-07-02', 7, 2018, '2030-07-02', 2030, 7, '200110000679', '503346', 'ADE HASYIM', '1956-01-09', 'TASIKMALAYA', 62, 'PENSIONS', NULL, 'IBU', 'L', 2, NULL, 2, 1, '2019-03-08 11:12:15', '2020-10-17 03:30:01'),
('AJB21211020190308D341H1EN', 'GEN3532018070001', NULL, '212', '110', 'AJB', '3100400001', '9735000.00', '120000000.00', '60000000.00', 'IDR', 180, 15, 0, 0, '162.25', '2018-07-04', 7, 2018, '2033-07-04', 2033, 7, '200110000679', '503004', 'EDY WANTORO', '1959-11-07', 'SURABAYA', 59, 'PENSIONS', NULL, 'IBU', 'L', 2, NULL, 2, 1, '2019-03-08 11:12:15', '2020-10-17 03:30:01'),
('AJB21211020190308DKF41KDV', 'GEN3052018070001', NULL, '212', '110', 'AJB', '3100400001', '14985000.00', '250000000.00', '100000000.00', 'IDR', 180, 15, 0, 0, '149.85', '2018-07-03', 7, 2018, '2033-07-03', 2033, 7, '200110000679', '409049', 'HERY CASTARI BIN TARNYA', '1960-01-25', 'CIREBON', 58, 'SOLDIERS', NULL, 'IBU', 'L', 2, NULL, 2, 1, '2019-03-08 11:12:15', '2020-10-17 03:30:01'),
('AJB21211020190308EX7YU3LD', 'GEN3022018070001', NULL, '212', '110', 'AJB', '3100400001', '14985000.00', '160000000.00', '100000000.00', 'IDR', 180, 15, 0, 0, '149.85', '2018-07-02', 7, 2018, '2033-07-02', 2033, 7, '200110000679', '500957', 'UUS SUWARSA', '1960-08-28', 'KUNINGAN', 58, 'PENSIONS', NULL, 'IBU', 'L', 2, NULL, 2, 1, '2019-03-08 11:12:15', '2020-10-17 03:30:01'),
('AJB21211020190308G42LIJS1', 'GEN2612018070009', NULL, '212', '110', 'AJB', '3100400001', '16240000.00', '224500000.00', '100000000.00', 'IDR', 168, 14, 0, 0, '162.40', '2018-07-03', 7, 2018, '2032-07-03', 2032, 7, '200110000679', '501617', 'KADAR SOLIHAT', '1958-06-19', 'CIAMIS', 60, 'PENSIONS', NULL, 'IBU', 'L', 2, NULL, 2, 1, '2019-03-08 11:12:15', '2020-10-17 03:30:01'),
('AJB21211020190308I60B916F', 'GEN2312018070005', NULL, '212', '110', 'AJB', '3100300001', '138500.00', '50000000.00', '50000000.00', 'IDR', 36, 3, 0, 0, '2.77', '2018-07-03', 7, 2018, '2021-07-03', 2021, 7, '200110000679', '447089', 'CHOLIS JUMAELAH', '1983-03-27', 'JAKARTA', 35, 'BURUH (BURUH PABRIK, BURUH BANGUNAN, BURUH TANI)', NULL, 'IBU', 'L', 2, NULL, 2, 1, '2019-03-08 11:12:15', '2020-10-17 03:30:01'),
('AJB21211020190308JM6RZBBE', 'GEN2312018070004', NULL, '212', '110', 'AJB', '3100400001', '13445000.00', '169000000.00', '100000000.00', 'IDR', 84, 7, 0, 0, '134.45', '2018-07-02', 7, 2018, '2025-07-02', 2025, 7, '200110000679', '256063', 'MUHAMAD SYARKUL', '1950-12-16', 'TANGERANG', 67, 'PENSIONS', NULL, 'IBU', 'L', 2, NULL, 2, 1, '2019-03-08 11:12:15', '2020-10-17 03:30:01'),
('AJB21211020190308LSZ7S0FU', 'GEN3432018070004', NULL, '212', '110', 'AJB', '3100400001', '17566000.00', '224000000.00', '100000000.00', 'IDR', 180, 15, 0, 0, '175.66', '2018-07-03', 7, 2018, '2033-07-03', 2033, 7, '200110000679', '367469', 'RR.SUTRISNOWATI', '1958-07-19', 'KULON PROGO', 60, 'GOVERNMENT EMPLOYEES / STATE-OWNED ENTERPRISES', NULL, 'IBU', 'L', 2, NULL, 2, 1, '2019-03-08 11:12:15', '2020-10-17 03:30:01'),
('AJB21211020190308NEP59LWH', 'GEN2622018070002', NULL, '212', '110', 'AJB', '3100400001', '15278000.00', '184000000.00', '100000000.00', 'IDR', 120, 10, 0, 0, '152.78', '2018-07-04', 7, 2018, '2028-07-04', 2028, 7, '200110000679', '291345', 'TATANG SOFYAN IRAWAN', '1954-03-13', 'TASIKMALAYA', 64, 'PENSIONS', NULL, 'IBU', 'L', 2, NULL, 2, 1, '2019-03-08 11:12:15', '2020-10-17 03:30:01'),
('AJB21211020190308O1W02ZFX', 'GEN3042018070001', NULL, '212', '110', 'AJB', '3100400001', '11357500.00', '140000000.00', '70000000.00', 'IDR', 180, 15, 0, 0, '162.25', '2018-07-02', 7, 2018, '2033-07-02', 2033, 7, '200110000679', '502944', 'SRI SETIJANINGSIH', '1959-08-12', 'KOTA CIREBON', 59, 'PENSIONS', NULL, 'IBU', 'L', 2, NULL, 2, 1, '2019-03-08 11:12:15', '2020-10-17 03:30:01'),
('AJB21211020190308P1US3UNH', 'GEN2502018070001', NULL, '212', '110', 'AJB', '3100300001', '1045000.00', '100000000.00', '100000000.00', 'IDR', 60, 5, 0, 0, '10.45', '2018-07-02', 7, 2018, '2023-07-02', 2023, 7, '200110000679', '503348', 'PUTUT PRINGGODIGDO', '1973-06-04', 'PURWOKERTO', 45, 'SOLDIERS', NULL, 'IBU', 'L', 2, NULL, 2, 1, '2019-03-08 11:12:15', '2020-10-17 03:30:01'),
('AJB21211020190308PDENSPTP', 'GEN2612018070001', NULL, '212', '110', 'AJB', '3100400001', '17566000.00', '212000000.00', '100000000.00', 'IDR', 180, 15, 0, 0, '175.66', '2018-07-02', 7, 2018, '2033-07-02', 2033, 7, '200110000679', '503283', 'HERDIANA', '1958-10-10', 'CIAMIS', 60, 'PENSIONS', NULL, 'IBU', 'L', 2, NULL, 2, 1, '2019-03-08 11:12:15', '2020-10-17 03:30:01'),
('AJB21211020190308PUWL159M', 'GEN2142018070001', NULL, '212', '110', 'AJB', '3100300001', '627000.00', '60000000.00', '60000000.00', 'IDR', 48, 4, 0, 0, '10.45', '2018-07-02', 7, 2018, '2022-07-02', 2022, 7, '200110000679', '931106710', 'ARTIKA SARI', '1970-07-11', 'JAKARTA', 48, 'PRIVATE EMPLOYEES', NULL, 'IBU', 'L', 2, NULL, 2, 1, '2019-03-08 11:12:15', '2020-10-17 03:30:01'),
('AJB21211020190308PW4MDTMD', 'GEN2612018070003', NULL, '212', '110', 'AJB', '3100400001', '16240000.00', '192000000.00', '100000000.00', 'IDR', 168, 14, 0, 0, '162.40', '2018-07-02', 7, 2018, '2032-07-02', 2032, 7, '200110000679', '493902', 'ACENG RUSTAMAN', '1958-04-20', 'CIAMIS', 60, 'PENSIONS', NULL, 'IBU', 'L', 2, NULL, 2, 1, '2019-03-08 11:12:15', '2020-10-17 03:30:01'),
('AJB21211020190308REHWSXYS', 'GEN2682018070001', NULL, '212', '110', 'AJB', '3100400001', '17524000.00', '197500000.00', '100000000.00', 'IDR', 156, 13, 0, 0, '175.24', '2018-07-02', 7, 2018, '2031-07-02', 2031, 7, '200110000679', '503259', 'DIDI', '1956-09-25', 'TASIKMALAYA', 62, 'PENSIONS', NULL, 'IBU', 'L', 2, NULL, 2, 1, '2019-03-08 11:12:15', '2020-10-17 03:30:01'),
('AJB21211020190308SLDSJ2FL', 'GEN3702018070003', NULL, '212', '110', 'AJB', '3100400001', '6577580.00', '103000000.00', '51500000.00', 'IDR', 180, 15, 0, 0, '127.72', '2018-07-03', 7, 2018, '2033-07-03', 2033, 7, '200110000679', '394697', 'NI NYOMAN YUNIARI', '1961-12-31', 'BADUNG', 56, 'HOUSEWIFE', NULL, 'IBU', 'L', 2, NULL, 2, 1, '2019-03-08 11:12:15', '2020-10-17 03:30:01'),
('AJB21211020190308TPTNH9HE', 'GEN2682018070004', NULL, '212', '110', 'AJB', '3100400001', '17595000.00', '241500000.00', '100000000.00', 'IDR', 168, 14, 0, 0, '175.95', '2018-07-02', 7, 2018, '2032-07-02', 2032, 7, '200110000679', '503260', 'YETI MULYATI', '1957-11-27', 'TASIKMALAYA', 61, 'PENSIONS', NULL, 'IBU', 'L', 2, NULL, 2, 1, '2019-03-08 11:12:15', '2020-10-17 03:30:01'),
('AJB21211020190308WCRHUFAY', 'GEN3502018070002', NULL, '212', '110', 'AJB', '3100400001', '17595000.00', '250000000.00', '100000000.00', 'IDR', 168, 14, 0, 0, '175.95', '2018-07-02', 7, 2018, '2032-07-02', 2032, 7, '200110000679', '373247', 'SAMI\'AN', '1957-10-07', 'SURABAYA', 61, 'PENSIONS', NULL, 'IBU', 'L', 2, NULL, 2, 1, '2019-03-08 11:12:15', '2020-10-17 03:30:01'),
('AJB21211020190308XM0W4PVY', 'GEN3072018070001', NULL, '212', '110', 'AJB', '3100400001', '16240000.00', '220000000.00', '100000000.00', 'IDR', 168, 14, 0, 0, '162.40', '2018-07-02', 7, 2018, '2032-07-02', 2032, 7, '200110000679', '502560', 'RUKYAT', '1958-06-04', 'KUNINGAN', 60, 'GOVERNMENT EMPLOYEES / STATE-OWNED ENTERPRISES', NULL, 'IBU', 'L', 2, NULL, 2, 1, '2019-03-08 11:12:15', '2020-10-17 03:30:01'),
('AJB21211020190308XWHGJ19Y', 'GEN1192018070003', NULL, '212', '110', 'AJB', '3100400001', '16240000.00', '196600000.00', '100000000.00', 'IDR', 168, 14, 0, 0, '162.40', '2018-07-02', 7, 2018, '2032-07-02', 2032, 7, '200110000679', '503143', 'ADE TARSADI', '1958-05-15', 'GARUT', 60, 'PENSIONS', NULL, 'IBU', 'L', 2, NULL, 2, 1, '2019-03-08 11:12:15', '2020-10-17 03:30:01'),
('AJB21211020190308ZRI09XJN', 'GEN3012018070001', NULL, '212', '110', 'AJB', '3100400001', '17524000.00', '250000000.00', '100000000.00', 'IDR', 156, 13, 0, 0, '175.24', '2018-07-03', 7, 2018, '2031-07-03', 2031, 7, '200110000679', '502807', 'DURIAT HADISUSANTO', '1956-08-18', 'MAJALENGKA', 62, 'PENSIONS', NULL, 'IBU', 'L', 2, NULL, 2, 1, '2019-03-08 11:12:15', '2020-10-17 03:30:01'),
('AJB21211020201011SY26F9QK', 'GEN2120000000003', 'POL2120000000003', '212', '110', 'AJB', '3100400001', '17524000.00', '250000000.00', '100000000.00', 'IDR', 156, 13, 0, 0, '175.24', '2018-07-03', 7, 2018, '2031-07-03', 2031, 7, '200110000679', '000003', 'IRFAN A', '1956-08-18', 'BANDUNG', 62, 'PENSIONS', NULL, 'IBU', 'L', 2, NULL, 2, 0, '2020-10-11 21:41:42', '2020-10-17 03:30:01'),
('AJB21211020201011TPTPQA0U', 'GEN2120000000001', 'POL2120000000002', '212', '110', 'AJB', '3100300001', '3624000.00', '230000000.00', '100000000.00', 'IDR', 156, 13, 0, 0, '0.00', '2018-07-02', 7, 2018, '2031-07-02', 2031, 7, '200110000679', '000001', 'IRFAN', '1950-01-05', 'BANDUNG', 68, 'PENSIONS', NULL, 'IBU', 'L', 1, NULL, 2, 0, '2020-10-11 19:37:16', '2020-10-17 03:30:01'),
('AJB21211020201011YWCSJ3K9', 'GEN2120000000002', 'POL2120000000001', '212', '110', 'AJB', '3100400001', '3780000.00', '239000000.00', '100000000.00', 'IDR', 168, 14, 0, 0, '0.00', '2018-07-02', 7, 2018, '2032-07-02', 2032, 7, '200110000680', '000002', 'LUTHFI', '1950-06-24', 'BANDUNG', 68, 'PENSIONS', NULL, 'IBU', 'L', 1, NULL, 2, 0, '2020-10-11 19:37:16', '2020-10-17 03:30:02'),
('AJB2121102020101202XHCZLO', 'GEN2120000000005', 'POL2120000000005', '212', '110', 'AJB', '3100400001', '17524000.00', '250000000.00', '100000000.00', 'IDR', 156, 13, 0, 0, '175.24', '2018-07-03', 7, 2018, '2031-07-03', 2031, 7, '200110000679', '000005', 'IRFAN C', '1956-08-18', 'BANDUNG', 62, 'PENSIONS', NULL, 'IBU', 'L', 2, NULL, 2, 0, '2020-10-12 10:11:19', '2020-10-17 03:30:02'),
('AJB212110202010128VDX84NM', 'GEN2120000000012', 'POL2120000000012', '212', '110', 'AJB', '3100400001', '17524000.00', '250000000.00', '100000000.00', 'IDR', 156, 13, 0, 0, '175.24', '2018-07-03', 7, 2018, '2031-07-03', 2031, 7, '200110000679', '000012', 'IRFAN J', '1956-08-18', 'BANDUNG', 62, 'PENSIONS', NULL, 'IBU', 'L', 5, NULL, 2, 0, '2020-10-12 10:36:20', '2020-10-17 03:30:02'),
('AJB21211020201012DLIGHPTP', 'GEN2120000000006', 'POL2120000000006', '212', '110', 'AJB', '3100400001', '17524000.00', '250000000.00', '100000000.00', 'IDR', 156, 13, 0, 0, '175.24', '2018-07-03', 7, 2018, '2031-07-03', 2031, 7, '200110000679', '000006', 'IRFAN D', '1956-08-18', 'BANDUNG', 62, 'PENSIONS', NULL, 'IBU', 'L', 2, NULL, 2, 0, '2020-10-12 10:11:19', '2020-10-17 03:30:02'),
('AJB21211020201012GFGPUTBT', 'GEN2120000000010', 'POL2120000000010', '212', '110', 'AJB', '3100400001', '17524000.00', '250000000.00', '100000000.00', 'IDR', 156, 13, 0, 0, '175.24', '2018-07-03', 7, 2018, '2031-07-03', 2031, 7, '200110000679', '000010', 'IRFAN H', '1956-08-18', 'BANDUNG', 62, 'PENSIONS', NULL, 'IBU', 'L', 3, NULL, 2, 0, '2020-10-12 10:36:20', '2020-10-17 03:30:02'),
('AJB21211020201012OENQI1DG', 'GEN2120000000007', 'POL2120000000007', '212', '110', 'AJB', '3100400001', '17524000.00', '250000000.00', '100000000.00', 'IDR', 156, 13, 0, 0, '175.24', '2018-07-03', 7, 2018, '2031-07-03', 2031, 7, '200110000679', '000007', 'IRFAN E', '1956-08-18', 'BANDUNG', 62, 'PENSIONS', NULL, 'IBU', 'L', 2, NULL, 2, 0, '2020-10-12 10:14:26', '2020-10-17 03:30:02'),
('AJB21211020201012QNTR54UK', 'GEN2120000000004', 'POL2120000000004', '212', '110', 'AJB', '3100400001', '17524000.00', '250000000.00', '100000000.00', 'IDR', 156, 13, 0, 0, '175.24', '2018-07-03', 7, 2018, '2031-07-03', 2031, 7, '200110000679', '000004', 'IRFAN B', '1956-08-18', 'BANDUNG', 62, 'PENSIONS', NULL, 'IBU', 'L', 2, NULL, 2, 0, '2020-10-12 10:11:19', '2020-10-17 03:30:02'),
('AJB21211020201012SAROQEI0', 'GEN2120000000011', 'POL2120000000011', '212', '110', 'AJB', '3100400001', '17524000.00', '250000000.00', '100000000.00', 'IDR', 156, 13, 0, 0, '175.24', '2018-07-03', 7, 2018, '2031-07-03', 2031, 7, '200110000679', '000011', 'IRFAN I', '1956-08-18', 'BANDUNG', 62, 'PENSIONS', NULL, 'IBU', 'L', 5, NULL, 2, 0, '2020-10-12 10:36:20', '2020-10-17 03:30:02'),
('AJB21211020201012UL3HUHL7', 'GEN2120000000008', 'POL2120000000008', '212', '110', 'AJB', '3100400001', '17524000.00', '250000000.00', '100000000.00', 'IDR', 156, 13, 0, 0, '175.24', '2018-07-03', 7, 2018, '2031-07-03', 2031, 7, '200110000679', '000008', 'IRFAN F', '1956-08-18', 'BANDUNG', 62, 'PENSIONS', NULL, 'IBU', 'L', 2, NULL, 2, 0, '2020-10-12 10:14:26', '2020-10-17 03:30:02'),
('AJB21211020201012XSTHMEVW', 'GEN2120000000009', 'POL2120000000009', '212', '110', 'AJB', '3100400001', '17524000.00', '250000000.00', '100000000.00', 'IDR', 156, 13, 0, 0, '175.24', '2018-07-03', 7, 2018, '2031-07-03', 2031, 7, '200110000679', '000009', 'IRFAN G', '1956-08-18', 'BANDUNG', 62, 'PENSIONS', NULL, 'IBU', 'L', 2, NULL, 2, 0, '2020-10-12 10:14:26', '2020-10-17 03:30:02'),
('AJB21211020201013SR8KT5Z6', 'GEN2120000000013', 'POL2120000000013', '212', '110', 'AJB', '3100400001', '17524000.00', '250000000.00', '100000000.00', 'IDR', 156, 13, 0, 0, '175.24', '2018-07-03', 7, 2018, '2031-07-03', 2031, 7, '200110000679', '000013', 'IRFAN I', '1956-08-18', 'BANDUNG', 62, 'PENSIONS', NULL, 'IBU', 'L', 2, NULL, 2, 0, '2020-10-13 07:11:41', '2020-10-17 04:04:27'),
('AJB21211020201017KDW3HTE9', 'GEN2120000000019', NULL, '212', '110', 'LIP', '4100400001', '17524000.00', '250000000.00', '100000000.00', 'IDR', 156, 13, 0, 0, NULL, '2018-07-03', 7, 2018, '2031-07-03', 2031, 7, '200110000679', '000019', 'IRFAN LIP 3', '1956-08-18', 'BANDUNG', 62, 'PENSIONS', '2020-10-17', 'IBU', 'L', 1, NULL, 2, 0, '2020-10-17 04:26:28', '2020-11-16 05:22:04'),
('AJB21211020201017UZ3AW9BI', 'GEN2120000000016', NULL, '212', '110', 'AJB', '3100400001', '17524000.00', '250000000.00', '100000000.00', 'IDR', 156, 13, 0, 0, '175.24', '2018-07-03', 7, 2018, '2031-07-03', 2031, 7, '200110000679', '000016', 'IRFAN D', '1956-08-18', 'BANDUNG', 62, 'PENSIONS', '2020-10-17', 'IBU', 'L', 1, NULL, 2, 0, '2020-10-17 04:04:27', '2020-11-16 05:22:04'),
('AJB21211020201017W18RR7JR', 'GEN2120000000014', NULL, '212', '110', 'AJB', '3100400001', '17524000.00', '250000000.00', '100000000.00', 'IDR', 156, 13, 0, 0, '175.24', '2018-07-03', 7, 2018, '2031-07-03', 2031, 7, '200110000679', '000014', 'IRFAN B', '1956-08-18', 'BANDUNG', 62, 'PENSIONS', '2020-10-17', 'IBU', 'L', 1, NULL, 2, 0, '2020-10-17 04:04:27', '2020-11-16 05:22:04'),
('AJB21211020201017WJNDMPCD', 'GEN2120000000018', NULL, '212', '110', 'LIP', '4100400001', '17524000.00', '250000000.00', '100000000.00', 'IDR', 156, 13, 0, 0, NULL, '2018-07-03', 7, 2018, '2031-07-03', 2031, 7, '200110000679', '000018', 'IRFAN LIP 2', '1956-08-18', 'BANDUNG', 62, 'PENSIONS', '2020-10-17', 'IBU', 'L', 1, NULL, 2, 0, '2020-10-17 04:26:28', '2020-11-16 05:22:04'),
('AJB21211020201017X4K72CB8', 'GEN2120000000017', NULL, '212', '110', 'LIP', '4100400001', '17524000.00', '250000000.00', '100000000.00', 'IDR', 156, 13, 0, 0, NULL, '2018-07-03', 7, 2018, '2031-07-03', 2031, 7, '200110000679', '000017', 'IRFAN LIP 1', '1956-08-18', 'BANDUNG', 62, 'PENSIONS', '2020-10-17', 'IBU', 'L', 1, NULL, 2, 0, '2020-10-17 04:26:28', '2020-11-16 05:22:04'),
('AJB21211020201017Y6OKKRXZ', 'GEN2120000000015', NULL, '212', '110', 'AJB', '3100400001', '17524000.00', '250000000.00', '100000000.00', 'IDR', 156, 13, 0, 0, '175.24', '2018-07-03', 7, 2018, '2031-07-03', 2031, 7, '200110000679', '000015', 'IRFAN C', '1956-08-18', 'BANDUNG', 62, 'PENSIONS', '2020-10-17', 'IBU', 'L', 1, NULL, 2, 0, '2020-10-17 04:04:27', '2020-11-16 05:22:04'),
('AJB212110202011164662GVMA', '311012', NULL, '212', '110', 'AJB', 'INSPP', '300000.00', '100000000.00', '100000000.00', 'IDR', 120, 10, 0, 0, NULL, '2020-11-06', 11, 2020, '2030-11-06', 2030, 11, '222333444555', '502942', 'JOHN IDHAM', '1951-10-14', 'TASIKMALAYA', 69, 'PENSIONS', '2020-11-06', 'IBU', 'L', 1, NULL, 1, 0, '2020-11-16 05:22:04', '2020-11-16 05:22:04'),
('AJB212110202011166PRC4D5B', '311014', NULL, '212', '110', 'AJB', 'INSPP', '300000.00', '100000000.00', '100000000.00', 'IDR', 120, 10, 0, 0, NULL, '2020-11-06', 11, 2020, '2030-11-06', 2030, 11, '222333444555', '502942', 'JOHN SUNANG', '1951-10-14', 'TASIKMALAYA', 69, 'PENSIONS', '2020-11-06', 'IBU', 'L', 1, NULL, 1, 0, '2020-11-16 05:41:33', '2020-11-16 05:41:33'),
('AJB21211020201116ERD7NCGY', '311013', NULL, '212', '110', 'AJB', 'INSPN', '300000.00', '100000000.00', '100000000.00', 'IDR', 180, 15, 0, 0, NULL, '2020-11-06', 11, 2020, '2035-11-06', 2035, 11, '111222333444', '503200', 'MICHAEL SUNANG', '1950-10-14', 'TASIKMALAYA', 70, 'PENSIONS', '2020-11-06', 'IBU', 'L', 1, NULL, 1, 0, '2020-11-16 05:41:33', '2020-11-16 05:41:33'),
('AJB21211020201116K5R0KF7E', '311011', 'LAPOLIS001', '212', '110', 'AJB', 'INSPN', '300000.00', '100000000.00', '100000000.00', 'IDR', 180, 15, 0, 0, NULL, '2020-11-06', 11, 2020, '2035-11-06', 2035, 11, '111222333444', '503200', 'MICHAEL IDHAM', '1950-10-14', 'TASIKMALAYA', 70, 'PENSIONS', '2020-11-06', 'IBU', 'L', 2, NULL, 1, 0, '2020-11-16 05:22:04', '2020-11-16 06:43:19'),
('AJB21211120190321033Y5NIM', 'GEN2372018070018', NULL, '212', '111', 'AJB', '3100400001', '9167390.00', '123800000.00', '61900000.00', 'IDR', 108, 9, 0, 0, '148.10', '2018-07-04', 7, 2018, '2027-07-04', 2027, 7, '200110000679', '263300', 'ROHAEDI', '1953-06-17', 'BAYAH', 65, 'PENSIONS', NULL, 'IBU', 'L', 5, NULL, 2, 0, '2019-03-21 09:54:55', '2020-10-17 03:30:02'),
('AJB212111201903210C0RHSPE', 'GEN2372018070016', NULL, '212', '111', 'AJB', '3100400001', '7267268.00', '113800000.00', '56900000.00', 'IDR', 180, 15, 0, 0, '127.72', '2018-07-04', 7, 2018, '2033-07-04', 2033, 7, '200110000679', '263560', 'ENDIN MANGKULUDIN', '1961-12-27', 'LEBAK', 56, 'PENSIONS', NULL, 'IBU', 'L', 7, NULL, 2, 0, '2019-03-21 09:54:55', '2020-10-17 03:30:02'),
('AJB212111201903210H7DVZZN', 'GEN3602018070010', NULL, '212', '111', 'AJB', '3100400001', '10546250.00', '130000000.00', '65000000.00', 'IDR', 180, 15, 0, 0, '162.25', '2018-07-05', 7, 2018, '2033-07-05', 2033, 7, '200110000679', '503912', 'HARYONO', '1959-11-27', 'SRAGEN', 59, 'PENSIONS', NULL, 'IBU', 'L', 2, NULL, 2, 0, '2019-03-21 09:54:55', '2020-10-17 03:30:02'),
('AJB212111201903210PELHQI4', 'GEN3542018070002', NULL, '212', '111', 'AJB', '3100400001', '16240000.00', '271000000.00', '100000000.00', 'IDR', 168, 14, 0, 0, '162.40', '2018-07-05', 7, 2018, '2032-07-05', 2032, 7, '200110000679', '382744', 'BAMBANG HARY ERNOADI', '1958-06-18', 'NGANJUK', 60, 'GOVERNMENT EMPLOYEES / STATE-OWNED ENTERPRISES', NULL, 'IBU', 'L', 2, NULL, 2, 0, '2019-03-21 09:54:55', '2020-10-17 03:30:02'),
('AJB212111201903210V8EVT8E', 'GEN1422018070002', NULL, '212', '111', 'AJB', '3100300001', '306000.00', '60000000.00', '60000000.00', 'IDR', 60, 5, 0, 0, '5.10', '2018-07-05', 7, 2018, '2023-07-05', 2023, 7, '200110000679', '503865', 'ALOYSIUS EDI NURYAWAN', '1982-04-11', 'GUNUNGKIDUL', 36, 'PRIVATE EMPLOYEES', NULL, 'IBU', 'L', 1, NULL, 2, 0, '2019-03-21 10:31:02', '2020-10-17 03:30:02'),
('AJB212111201903210XT04HR3', 'GEN3042018070003', NULL, '212', '111', 'AJB', '3100400001', '14067000.00', '170000000.00', '100000000.00', 'IDR', 120, 10, 0, 0, '140.67', '2018-07-04', 7, 2018, '2028-07-04', 2028, 7, '200110000679', '322728', 'KANAH ROHYANAH', '1955-02-15', 'CIREBON', 63, 'PENSIONS', NULL, 'IBU', 'L', 2, NULL, 2, 0, '2019-03-21 09:54:55', '2020-10-17 03:30:02'),
('AJB2121112019032117M5MCMT', 'GEN1812018070008', NULL, '212', '111', 'AJB', '3100400001', '15278000.00', '184000000.00', '100000000.00', 'IDR', 120, 10, 0, 0, '152.78', '2018-07-05', 7, 2018, '2028-07-05', 2028, 7, '200110000679', '174737', 'YAYU RATNAYU', '1954-03-21', 'SUMEDANG', 64, 'PENSIONS', NULL, 'IBU', 'L', 2, NULL, 2, 0, '2019-03-21 09:54:55', '2020-10-17 03:30:02'),
('AJB212111201903211ZH51HXY', 'GEN1452018070001', NULL, '212', '111', 'AJB', '3100400001', '13837000.00', '192000000.00', '100000000.00', 'IDR', 180, 15, 0, 0, '138.37', '2018-07-05', 7, 2018, '2033-07-05', 2033, 7, '200110000679', '85215', 'SUTRISNO', '1960-12-27', 'BANDUNG', 57, 'PENSIONS', NULL, 'IBU', 'L', 2, NULL, 2, 0, '2019-03-21 09:54:55', '2020-10-17 03:30:02'),
('AJB212111201903213J4NLQLH', 'GEN1812018070006', NULL, '212', '111', 'AJB', '3100400001', '9890100.00', '132000000.00', '66000000.00', 'IDR', 180, 15, 0, 0, '149.85', '2018-07-04', 7, 2018, '2033-07-04', 2033, 7, '200110000679', '175603', 'N.TARSIH', '1960-05-05', 'SUMEDANG', 58, 'PENSIONS', NULL, 'IBU', 'L', 2, NULL, 2, 0, '2019-03-21 09:54:55', '2020-10-17 03:30:02'),
('AJB212111201903214GOO49N6', 'GEN3572018070001', NULL, '212', '111', 'AJB', '3100400001', '17332000.00', '225000000.00', '100000000.00', 'IDR', 144, 12, 0, 0, '173.32', '2018-07-04', 7, 2018, '2030-07-04', 2030, 7, '200110000679', '503827', 'M TAUFIK', '1955-07-28', 'SAMPANG', 63, 'PENSIONS', NULL, 'IBU', 'L', 2, NULL, 2, 0, '2019-03-21 09:54:55', '2020-10-17 03:30:02'),
('AJB2121112019032158F3Y6QU', 'GEN3402018070004', NULL, '212', '111', 'AJB', '3100300001', '81750.00', '25000000.00', '25000000.00', 'IDR', 36, 3, 0, 0, '3.27', '2018-07-05', 7, 2018, '2021-07-05', 2021, 7, '200110000679', '360446', 'PURWOKO RIANTO NUGROHO', '1980-12-24', 'KARANGANYAR', 37, 'PRIVATE EMPLOYEES', NULL, 'IBU', 'L', 1, NULL, 2, 0, '2019-03-21 10:31:02', '2020-10-17 03:30:02'),
('AJB212111201903215UK00TOO', 'GEN2532018070002', NULL, '212', '111', 'AJB', '3100300001', '1738800.00', '120000000.00', '120000000.00', 'IDR', 48, 4, 0, 0, '14.49', '2018-07-04', 7, 2018, '2022-07-04', 2022, 7, '200110000679', '494463', 'DEWI TRESNOWATI', '1966-08-28', 'JAKARTA', 52, 'PRIVATE EMPLOYEES', NULL, 'IBU', 'L', 2, NULL, 2, 0, '2019-03-21 09:54:55', '2020-10-17 03:30:03'),
('AJB212111201903217DXBFX16', 'GEN3522018070004', NULL, '212', '111', 'AJB', '3100400001', '15278000.00', '195000000.00', '100000000.00', 'IDR', 120, 10, 0, 0, '152.78', '2018-07-05', 7, 2018, '2028-07-05', 2028, 7, '200110000679', '379895', 'AKHMAD BAYADI', '1954-07-06', 'MOJOKERTO', 64, 'PENSIONS', NULL, 'IBU', 'L', 2, NULL, 2, 0, '2019-03-21 09:54:55', '2020-10-17 03:30:03'),
('AJB2121112019032183GOSK5S', 'GEN3502018070018', NULL, '212', '111', 'AJB', '3100400001', '15278000.00', '154000000.00', '100000000.00', 'IDR', 120, 10, 0, 0, '152.78', '2018-07-05', 7, 2018, '2028-07-05', 2028, 7, '200110000679', '433925', 'SRI KARTINI', '1954-05-11', 'MALANG', 64, 'PENSIONS', NULL, 'IBU', 'L', 2, NULL, 2, 0, '2019-03-21 09:54:55', '2020-10-17 03:30:03'),
('AJB2121112019032193HR55Z5', 'GEN2312018070007', NULL, '212', '111', 'AJB', '3100400001', '11982750.00', '150000000.00', '75000000.00', 'IDR', 144, 12, 0, 0, '159.77', '2018-07-04', 7, 2018, '2030-07-04', 2030, 7, '200110000679', '244144', 'MAD SOLEH', '1956-04-09', 'TANGERANG', 62, 'PENSIONS', NULL, 'IBU', 'L', 2, NULL, 2, 0, '2019-03-21 09:54:55', '2020-10-17 03:30:03'),
('AJB21211120190321BLPFR9PI', 'GEN2622018070001', NULL, '212', '111', 'AJB', '3100400001', '16163000.00', '212300000.00', '100000000.00', 'IDR', 156, 13, 0, 0, '161.63', '2018-07-04', 7, 2018, '2031-07-04', 2031, 7, '200110000679', '296522', 'RUHIYAT', '1957-02-03', 'TASIKMALAYA', 61, 'GOVERNMENT EMPLOYEES / STATE-OWNED ENTERPRISES', NULL, 'IBU', 'L', 2, NULL, 2, 0, '2019-03-21 09:54:55', '2020-10-17 03:30:03'),
('AJB21211120190321C34ZBBES', 'GEN2322018070010', NULL, '212', '111', 'AJB', '3100400001', '17524000.00', '180000000.00', '100000000.00', 'IDR', 156, 13, 0, 0, '175.24', '2018-07-05', 7, 2018, '2031-07-05', 2031, 7, '200110000679', '257639', 'SUMPENO', '1956-10-01', 'LAMPUNG', 62, 'PENSIONS', NULL, 'IBU', 'L', 2, NULL, 2, 0, '2019-03-21 09:54:55', '2020-10-17 03:30:03'),
('AJB21211120190321FB1YBI8D', 'GEN2352018070003', NULL, '212', '111', 'AJB', '3100400001', '14810000.00', '178000000.00', '100000000.00', 'IDR', 108, 9, 0, 0, '148.10', '2018-07-05', 7, 2018, '2027-07-05', 2027, 7, '200110000679', '261730', 'JURIAH', '1953-07-04', 'KUNINGAN', 65, 'PENSIONS', NULL, 'IBU', 'L', 2, NULL, 2, 0, '2019-03-21 09:54:55', '2020-10-17 03:30:03'),
('AJB21211120190321FFK885QY', 'GEN2112018070006', NULL, '212', '111', 'AJB', '3100400001', '15977000.00', '190000000.00', '100000000.00', 'IDR', 144, 12, 0, 0, '159.77', '2018-07-05', 7, 2018, '2030-07-05', 2030, 7, '200110000679', '216584', 'EDY SURYONO', '1956-02-10', 'SUKOHARJO', 62, 'GOVERNMENT EMPLOYEES / STATE-OWNED ENTERPRISES', NULL, 'IBU', 'L', 2, NULL, 2, 0, '2019-03-21 09:54:55', '2020-10-17 03:30:03'),
('AJB21211120190321ID31NTSA', 'GEN2322018070005', NULL, '212', '111', 'AJB', '3100400001', '14810000.00', '220000000.00', '100000000.00', 'IDR', 108, 9, 0, 0, '148.10', '2018-07-04', 7, 2018, '2027-07-04', 2027, 7, '200110000679', '257771', 'ARMAZAN', '1953-03-12', 'PADANG', 65, 'PENSIONS', NULL, 'IBU', 'L', 2, NULL, 2, 0, '2019-03-21 09:54:55', '2020-10-17 03:30:03'),
('AJB21211120190321IT9LXLV8', 'GEN2322018070006', NULL, '212', '111', 'AJB', '3100400001', '16225000.00', '244000000.00', '100000000.00', 'IDR', 180, 15, 0, 0, '162.25', '2018-07-04', 7, 2018, '2033-07-04', 2033, 7, '200110000679', '257837', 'MARTINES WARGA NEGARA', '1959-03-06', 'LAMPUNG', 59, 'PENSIONS', NULL, 'IBU', 'L', 2, NULL, 2, 0, '2019-03-21 09:54:55', '2020-10-17 03:30:03'),
('AJB21211120190321K4K6WNBA', 'GEN2672018070001', NULL, '212', '111', 'AJB', '3100400001', '17595000.00', '222000000.00', '100000000.00', 'IDR', 168, 14, 0, 0, '175.95', '2018-07-04', 7, 2018, '2032-07-04', 2032, 7, '200110000679', '302172', 'DODI KHAIRIL ANWAR', '1957-10-09', 'TASIKMALAYA', 61, 'PENSIONS', NULL, 'IBU', 'L', 2, NULL, 2, 0, '2019-03-21 09:54:55', '2020-10-17 03:30:03'),
('AJB21211120190321KEY97WM5', 'GEN2342018070011', NULL, '212', '111', 'AJB', '3100400001', '7717275.00', '103000000.00', '51500000.00', 'IDR', 180, 15, 0, 0, '149.85', '2018-07-04', 7, 2018, '2033-07-04', 2033, 7, '200110000679', '260388', 'PRIHARTINI', '1960-12-02', 'JAKARTA', 58, 'HOUSEWIFE', NULL, 'IBU', 'L', 2, NULL, 2, 0, '2019-03-21 09:54:55', '2020-10-17 03:30:03'),
('AJB21211120190321MCJCTR1N', 'GEN1502018070001', NULL, '212', '111', 'AJB', '3100400001', '16240000.00', '228000000.00', '100000000.00', 'IDR', 168, 14, 0, 0, '162.40', '2018-07-04', 7, 2018, '2032-07-04', 2032, 7, '200110000679', '493106', 'YAYAH KARTINI', '1958-02-15', 'BANDUNG', 60, 'PENSIONS', NULL, 'IBU', 'L', 2, NULL, 2, 0, '2019-03-21 09:54:55', '2020-10-17 03:30:03'),
('AJB21211120190321QZG1I4UK', 'GEN2322018070009', NULL, '212', '111', 'AJB', '3100400001', '16163000.00', '176000000.00', '100000000.00', 'IDR', 156, 13, 0, 0, '161.63', '2018-07-05', 7, 2018, '2031-07-05', 2031, 7, '200110000679', '257816', 'HOTMAN JAUHARI', '1957-07-07', 'LAMPUNG', 61, 'PENSIONS', NULL, 'IBU', 'L', 2, NULL, 2, 0, '2019-03-21 09:54:55', '2020-10-17 03:30:03'),
('AJB21211120190321RPX6VJQT', 'GEN1802018070002', NULL, '212', '111', 'AJB', '3100400001', '16240000.00', '210000000.00', '100000000.00', 'IDR', 168, 14, 0, 0, '162.40', '2018-07-04', 7, 2018, '2032-07-04', 2032, 7, '200110000679', '170406', 'SUHARLI', '1958-02-18', 'KLATEN', 60, 'PENSIONS', NULL, 'IBU', 'L', 2, NULL, 2, 0, '2019-03-21 09:54:55', '2020-10-17 03:30:03'),
('AJB21211120190321TUHK4K98', 'GEN1472018070001', NULL, '212', '111', 'AJB', '3100400001', '8020950.00', '105000000.00', '52500000.00', 'IDR', 120, 10, 0, 0, '152.78', '2018-07-04', 7, 2018, '2028-07-04', 2028, 7, '200110000679', '74916', 'ALBERT', '1954-04-04', 'BANDUNG', 64, 'ETC', NULL, 'IBU', 'L', 2, NULL, 2, 0, '2019-03-21 09:54:55', '2020-10-17 03:30:03'),
('AJB21211120190321U508VE44', 'GEN3512018070005', NULL, '212', '111', 'AJB', '3100400001', '17566000.00', '227000000.00', '100000000.00', 'IDR', 180, 15, 0, 0, '175.66', '2018-07-04', 7, 2018, '2033-07-04', 2033, 7, '200110000679', '377817', 'AGUS DANAM PRATOPO', '1958-08-31', 'SURABAYA', 60, 'PENSIONS', NULL, 'IBU', 'L', 2, NULL, 2, 0, '2019-03-21 09:54:55', '2020-10-17 03:30:03'),
('AJB21211120190321UPOYG54W', 'GEN3602018070007', NULL, '212', '111', 'AJB', '3100400001', '16240000.00', '152000000.00', '100000000.00', 'IDR', 168, 14, 0, 0, '162.40', '2018-07-04', 7, 2018, '2032-07-04', 2032, 7, '200110000679', '374208', 'ASMONO SATRIO', '1958-07-01', 'LAMPUNG', 60, 'PENSIONS', NULL, 'IBU', 'L', 2, NULL, 2, 0, '2019-03-21 09:54:55', '2020-10-17 03:30:04'),
('AJB21211120190321XT2KE0KG', 'GEN2622018070004', NULL, '212', '111', 'AJB', '3100400001', '14206000.00', '151800000.00', '100000000.00', 'IDR', 96, 8, 0, 0, '142.06', '2018-07-05', 7, 2018, '2026-07-05', 2026, 7, '200110000679', '495126', 'SADIN SUDARMAN', '1952-07-06', 'CIAMIS', 66, 'PENSIONS', NULL, 'IBU', 'L', 2, NULL, 2, 0, '2019-03-21 09:54:55', '2020-10-17 03:30:04'),
('AJB21211120190321ZG2MO9WF', 'GEN1422018070003', NULL, '212', '111', 'AJB', '3100300001', '336500.00', '50000000.00', '50000000.00', 'IDR', 36, 3, 0, 0, '6.73', '2018-07-05', 7, 2018, '2021-07-05', 2021, 7, '200110000679', '503860', 'AGUS WIJAYA', '1972-08-04', 'TANGERANG', 46, 'PRIVATE EMPLOYEES', NULL, 'IBU', 'L', 1, NULL, 2, 0, '2019-03-21 10:31:02', '2020-10-17 03:30:04'),
('AJB21211120190321ZO8U7886', 'GEN3052018070002', NULL, '212', '111', 'AJB', '3100400001', '5818200.00', '120000000.00', '60000000.00', 'IDR', 72, 6, 0, 0, '96.97', '2018-07-04', 7, 2018, '2024-07-04', 2024, 7, '200110000679', '323646', 'SUWANDI', '1953-04-17', 'CIREBON', 65, 'ETC', NULL, 'IBU', 'L', 2, NULL, 2, 0, '2019-03-21 09:54:55', '2020-10-17 03:30:04');

-- --------------------------------------------------------

--
-- Table structure for table `data_repayments`
--

CREATE TABLE `data_repayments` (
  `id` varchar(25) NOT NULL,
  `member_id` varchar(25) DEFAULT NULL,
  `bank_id` varchar(3) DEFAULT NULL,
  `branch_id` varchar(3) DEFAULT NULL,
  `customer_name` varchar(255) DEFAULT NULL,
  `product_id` varchar(15) DEFAULT NULL,
  `tgl_pelunasan` date DEFAULT NULL,
  `keterangan` varchar(255) DEFAULT NULL,
  `repayment_status_id` int(11) DEFAULT 1,
  `nominal_pengajuan` decimal(30,2) DEFAULT NULL,
  `tgl_approval` date DEFAULT NULL,
  `note_approval` varchar(255) DEFAULT NULL,
  `created_at` datetime DEFAULT current_timestamp(),
  `updated_at` datetime DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB AVG_ROW_LENGTH=5461 DEFAULT CHARSET=utf8 ROW_FORMAT=DYNAMIC;

--
-- Dumping data for table `data_repayments`
--

INSERT INTO `data_repayments` (`id`, `member_id`, `bank_id`, `branch_id`, `customer_name`, `product_id`, `tgl_pelunasan`, `keterangan`, `repayment_status_id`, `nominal_pengajuan`, `tgl_approval`, `note_approval`, `created_at`, `updated_at`) VALUES
('RPY21211020190308QMO6NCH6', 'AJB212110201903080WF1O0QC', '212', '110', 'ALI MUKDIN', '3100400001', '2019-03-08', 'lunas', 1, NULL, NULL, NULL, '2019-03-08 04:36:38', '2019-03-08 04:36:38'),
('RPY21211020190321U78884MI', 'AJB212110201903082PZICV2C', '212', '110', 'WARTA ATMAJA', '3100400001', '2019-03-20', 'sadadasdasd', 1, NULL, NULL, NULL, '2019-03-21 01:25:28', '2019-03-21 01:25:28'),
('RPY21211020201016VL5MFZBD', 'AJB21211020201012GFGPUTBT', '212', '110', 'IRFAN H', '3100400001', '2020-10-16', 'test', 2, '10000000.00', '2020-10-16', 'Finish', '2020-10-16 11:35:55', '2020-10-16 11:36:22'),
('RPY21211120190321RBYJIOIB', 'AJB212111201903210C0RHSPE', '212', '111', 'ENDIN MANGKULUDIN', '3100400001', '2019-03-21', 'lunas', 1, NULL, NULL, NULL, '2019-03-21 03:48:21', '2019-03-21 03:48:21');

-- --------------------------------------------------------

--
-- Table structure for table `db_total_per_bank`
--

CREATE TABLE `db_total_per_bank` (
  `bank_id` varchar(3) NOT NULL,
  `total_pertanggungan` decimal(30,2) DEFAULT NULL,
  `total_premi` decimal(30,2) DEFAULT NULL,
  `total_peserta` int(11) DEFAULT NULL,
  `created_at` datetime DEFAULT current_timestamp(),
  `updated_at` datetime DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8 ROW_FORMAT=DYNAMIC;

-- --------------------------------------------------------

--
-- Table structure for table `db_total_per_bank_per_branch`
--

CREATE TABLE `db_total_per_bank_per_branch` (
  `bank_id` varchar(3) NOT NULL,
  `branch_id` varchar(3) NOT NULL,
  `total_pertanggungan` decimal(30,2) DEFAULT NULL,
  `total_premi` decimal(30,2) DEFAULT NULL,
  `total_peserta` int(11) DEFAULT NULL,
  `created_at` datetime DEFAULT current_timestamp(),
  `updated_at` datetime DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8 ROW_FORMAT=DYNAMIC;

-- --------------------------------------------------------

--
-- Table structure for table `master_banks`
--

CREATE TABLE `master_banks` (
  `id` varchar(3) COLLATE utf8mb4_unicode_ci NOT NULL,
  `name` varchar(150) COLLATE utf8mb4_unicode_ci NOT NULL,
  `created_at` timestamp NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB AVG_ROW_LENGTH=4096 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci ROW_FORMAT=DYNAMIC;

--
-- Dumping data for table `master_banks`
--

INSERT INTO `master_banks` (`id`, `name`, `created_at`, `updated_at`) VALUES
('008', 'BANK MANDIRI', '2020-10-02 06:17:51', '2020-10-02 06:17:51'),
('212', 'Bank Woori Saudara', '2018-11-12 23:48:09', '2018-11-12 23:48:28'),
('798', 'Bank Yudha Bhakti', '2018-11-12 23:48:09', '2018-11-12 23:48:29');

-- --------------------------------------------------------

--
-- Table structure for table `master_branches`
--

CREATE TABLE `master_branches` (
  `id` varchar(6) COLLATE utf8mb4_unicode_ci NOT NULL,
  `name` varchar(150) COLLATE utf8mb4_unicode_ci NOT NULL,
  `bank_id` varchar(3) COLLATE utf8mb4_unicode_ci NOT NULL,
  `is_kp` int(11) DEFAULT 0,
  `created_at` timestamp NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB AVG_ROW_LENGTH=119 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci ROW_FORMAT=DYNAMIC;

--
-- Dumping data for table `master_branches`
--

INSERT INTO `master_branches` (`id`, `name`, `bank_id`, `is_kp`, `created_at`, `updated_at`) VALUES
('000', 'Kantor Pusat BWS', '212', 1, '2018-10-17 01:51:35', '2018-10-17 01:52:43'),
('0017', 'Bank Mandiri Kantor Pusat Operasional', '008', 1, '2020-10-02 06:19:08', '2020-10-02 06:19:08'),
('0033', 'Bank Mandiri Kantor Cabang Jakarta Pondok Indah', '008', 0, '2020-10-02 06:19:38', '2020-10-02 06:19:38'),
('0059', 'Bank Mandiri Kantor Cabang Jakarta Gedung Patrajasa', '008', 0, '2020-10-02 06:19:58', '2020-10-02 06:19:58'),
('110', 'KC Wastukancana', '212', 0, '2018-10-17 01:51:35', '2018-11-28 02:28:41'),
('111', 'KCP Diponegoro', '212', 0, '2018-10-17 01:51:35', '2018-10-17 01:51:35'),
('112', 'KCP Lembang', '212', 0, '2018-10-17 01:51:35', '2018-10-17 01:51:35'),
('114', 'KCP Padalarang', '212', 0, '2018-10-17 01:51:35', '2018-10-17 01:51:35'),
('115', 'KCP Pamanukan', '212', 0, '2018-10-17 01:51:35', '2018-10-17 01:51:35'),
('116', 'KCP Pangalengan', '212', 0, '2018-10-17 01:51:35', '2018-10-17 01:51:35'),
('117', 'KCP Cianjur', '212', 0, '2018-10-17 01:51:35', '2018-10-17 01:51:35'),
('118', 'KCP Martadinata', '212', 0, '2018-10-17 01:51:35', '2018-10-17 01:51:35'),
('119', 'KCP Cikajang', '212', 0, '2018-10-17 01:51:35', '2018-10-17 01:51:35'),
('120', 'KCP Buah Batu', '212', 0, '2018-10-17 01:51:35', '2018-10-17 01:51:35'),
('140', 'KC Surapati Core', '212', 0, '2018-10-17 01:51:35', '2018-11-28 02:28:43'),
('141', 'KC Garut', '212', 0, '2018-10-17 01:51:35', '2018-10-17 01:51:35'),
('142', 'KC Purwakarta', '212', 0, '2018-10-17 01:51:35', '2018-10-17 01:51:35'),
('143', 'KCP Cikampek', '212', 0, '2018-10-17 01:51:35', '2018-10-17 01:51:35'),
('144', 'KCP Soreang', '212', 0, '2018-10-17 01:51:35', '2018-10-17 01:51:35'),
('145', 'KCP Majalaya', '212', 0, '2018-10-17 01:51:35', '2018-10-17 01:51:35'),
('146', 'KCP Ujung Berung', '212', 0, '2018-10-17 01:51:35', '2018-10-17 01:51:35'),
('147', 'KCP Cibatu', '212', 0, '2018-10-17 01:51:35', '2018-10-17 01:51:35'),
('150', 'KCP Kopo', '212', 0, '2018-10-17 01:51:35', '2018-10-17 01:51:35'),
('160', 'KCP Cimahi', '212', 0, '2018-10-17 01:51:35', '2018-10-17 01:51:35'),
('170', 'KCP Sukajadi', '212', 0, '2018-10-17 01:51:35', '2018-10-17 01:51:35'),
('171', 'KC Subang', '212', 0, '2018-10-17 01:51:35', '2018-10-17 01:51:35'),
('180', 'KCP Soekarno Hatta', '212', 0, '2018-10-17 01:51:35', '2018-10-17 01:51:35'),
('181', 'KCP Sumedang', '212', 0, '2018-10-17 01:51:35', '2018-10-17 01:51:35'),
('200', 'KC The Energy', '212', 0, '2018-10-17 01:51:35', '2018-11-28 02:28:47'),
('201', 'KCP Radio Dalam', '212', 0, '2018-10-17 01:51:35', '2018-10-17 01:51:35'),
('202', 'KCP Tanjung Priok', '212', 0, '2018-10-17 01:51:35', '2018-10-17 01:51:35'),
('210', 'KCP Kebun Jeruk', '212', 0, '2018-10-17 01:51:35', '2018-10-17 01:51:35'),
('211', 'KCP Rawamangun', '212', 0, '2018-10-17 01:51:35', '2018-10-17 01:51:35'),
('212', 'KCP Kramat Jati', '212', 0, '2018-10-17 01:51:35', '2018-10-17 01:51:35'),
('213', 'KC Ampera Jakarta', '212', 0, '2018-10-17 01:51:35', '2018-10-17 01:51:35'),
('214', 'KC Tangerang City', '212', 0, '2018-10-17 01:51:35', '2018-10-17 01:51:35'),
('215', 'KCP Serang', '212', 0, '2018-10-17 01:51:35', '2018-10-17 01:51:35'),
('230', 'KCP DELTA MAS', '212', 0, '2018-10-17 01:51:35', '2018-10-17 01:51:35'),
('231', 'KCP Balaraja', '212', 0, '2018-10-17 01:51:35', '2018-10-17 01:51:35'),
('232', 'KCP Megablock Cilegon', '212', 0, '2018-10-17 01:51:35', '2018-10-17 01:51:35'),
('233', 'KCP Ciputat', '212', 0, '2018-10-17 01:51:35', '2018-10-17 01:51:35'),
('234', 'KCP Ciledug', '212', 0, '2018-10-17 01:51:35', '2018-10-17 01:51:35'),
('235', 'KCP Pondok Gede', '212', 0, '2018-10-17 01:51:35', '2018-10-17 01:51:35'),
('236', 'KCP Karawang', '212', 0, '2018-10-17 01:51:35', '2018-10-17 01:51:35'),
('237', 'KCP Rangkasbitung', '212', 0, '2018-10-17 01:51:35', '2018-10-17 01:51:35'),
('238', 'KCP Mangga Dua', '212', 0, '2018-10-17 01:51:35', '2018-10-17 01:51:35'),
('239', 'KCP Bintaro', '212', 0, '2018-10-17 01:51:35', '2018-10-17 01:51:35'),
('240', 'KCP Cakung', '212', 0, '2018-10-17 01:51:35', '2018-10-17 01:51:35'),
('245', 'KCP Pandeglang', '212', 0, '2018-10-17 01:51:35', '2018-10-17 01:51:35'),
('250', 'KC Bogor', '212', 0, '2018-10-17 01:51:35', '2018-10-17 01:51:35'),
('251', 'KC Sukabumi', '212', 0, '2018-10-17 01:51:35', '2018-10-17 01:51:35'),
('252', 'KCP Depok', '212', 0, '2018-10-17 01:51:35', '2018-10-17 01:51:35'),
('253', 'KCP Cibinong', '212', 0, '2018-10-17 01:51:35', '2018-10-17 01:51:35'),
('254', 'KCP Parung', '212', 0, '2018-10-17 01:51:35', '2018-10-17 01:51:35'),
('255', 'KCP Leuwiliang', '212', 0, '2018-10-17 01:51:35', '2018-10-17 01:51:35'),
('260', 'KC Tasikmalaya', '212', 0, '2018-10-17 01:51:35', '2018-10-17 01:51:35'),
('261', 'KCP Banjar', '212', 0, '2018-10-17 01:51:35', '2018-10-17 01:51:35'),
('262', 'KCP Singaparna', '212', 0, '2018-10-17 01:51:35', '2018-10-17 01:51:35'),
('263', 'KCP Ciamis', '212', 0, '2018-10-17 01:51:35', '2018-10-17 01:51:35'),
('264', 'KCP Pangandaran', '212', 0, '2018-10-17 01:51:35', '2018-10-17 01:51:35'),
('265', 'KCP GUNUNG SABEULAH', '212', 0, '2018-10-17 01:51:35', '2018-10-17 01:51:35'),
('266', 'KCP Ciawi Tasikmalaya', '212', 0, '2018-10-17 01:51:35', '2018-10-17 01:51:35'),
('267', 'KCP Manonjaya', '212', 0, '2018-10-17 01:51:35', '2018-10-17 01:51:35'),
('268', 'KCP Karang Nunggal', '212', 0, '2018-10-17 01:51:35', '2018-10-17 01:51:35'),
('269', 'KCP Kawali', '212', 0, '2018-10-17 01:51:35', '2018-10-17 01:51:35'),
('270', 'KCP Cibadak', '212', 0, '2018-10-17 01:51:35', '2018-10-17 01:51:35'),
('271', 'KCP Pelabuhan Ratu', '212', 0, '2018-10-17 01:51:35', '2018-10-17 01:51:35'),
('300', 'KC Cirebon', '212', 0, '2018-10-17 01:51:35', '2018-10-17 01:51:35'),
('301', 'KCP Majalengka', '212', 0, '2018-10-17 01:51:35', '2018-10-17 01:51:35'),
('302', 'KCP Kuningan', '212', 0, '2018-10-17 01:51:35', '2018-10-17 01:51:35'),
('303', 'KCP Indramayu', '212', 0, '2018-10-17 01:51:35', '2018-10-17 01:51:35'),
('304', 'KCP Sumber', '212', 0, '2018-10-17 01:51:35', '2018-10-17 01:51:35'),
('305', 'KCP Losari', '212', 0, '2018-10-17 01:51:35', '2018-10-17 01:51:35'),
('306', 'KCP Patrol', '212', 0, '2018-10-17 01:51:35', '2018-10-17 01:51:35'),
('307', 'KCP Luragung', '212', 0, '2018-10-17 01:51:35', '2018-10-17 01:51:35'),
('308', 'KCP Palimanan', '212', 0, '2018-10-17 01:51:35', '2018-10-17 01:51:35'),
('309', 'KCP Cilimus', '212', 0, '2018-10-17 01:51:35', '2018-10-17 01:51:35'),
('310', 'KC Semarang', '212', 0, '2018-10-17 01:51:35', '2018-10-17 01:51:35'),
('311', 'KCP Salatiga', '212', 0, '2018-10-17 01:51:35', '2018-10-17 01:51:35'),
('312', 'KCP Magelang', '212', 0, '2018-10-17 01:51:35', '2018-10-17 01:51:35'),
('313', 'KCP Kudus', '212', 0, '2018-10-17 01:51:35', '2018-10-17 01:51:35'),
('314', 'KCP Purwodadi', '212', 0, '2018-10-17 01:51:35', '2018-10-17 01:51:35'),
('315', 'KCP Pati', '212', 0, '2018-10-17 01:51:35', '2018-10-17 01:51:35'),
('316', 'KCP Kendal', '212', 0, '2018-10-17 01:51:35', '2018-10-17 01:51:35'),
('317', 'KCP Jepara', '212', 0, '2018-10-17 01:51:35', '2018-10-17 01:51:35'),
('320', 'KC Purwokerto', '212', 0, '2018-10-17 01:51:35', '2018-10-17 01:51:35'),
('321', 'KCP Cilacap', '212', 0, '2018-10-17 01:51:35', '2018-10-17 01:51:35'),
('322', 'KCP Purbalingga', '212', 0, '2018-10-17 01:51:35', '2018-10-17 01:51:35'),
('323', 'KCP Kebumen', '212', 0, '2018-10-17 01:51:35', '2018-10-17 01:51:35'),
('324', 'KCP Banjarnegara', '212', 0, '2018-10-17 01:51:35', '2018-10-17 01:51:35'),
('330', 'KC Solo', '212', 0, '2018-10-17 01:51:35', '2018-10-17 01:51:35'),
('331', 'KCP Boyolali', '212', 0, '2018-10-17 01:51:35', '2018-10-17 01:51:35'),
('332', 'KCP Sragen', '212', 0, '2018-10-17 01:51:35', '2018-10-17 01:51:35'),
('333', 'KCP Wonogiri', '212', 0, '2018-10-17 01:51:35', '2018-10-17 01:51:35'),
('334', 'KCP Klaten', '212', 0, '2018-10-17 01:51:35', '2018-10-17 01:51:35'),
('340', 'KC Yogyakarta', '212', 0, '2018-10-17 01:51:35', '2018-10-17 01:51:35'),
('341', 'KCP Bantul', '212', 0, '2018-10-17 01:51:35', '2018-10-17 01:51:35'),
('342', 'KCP Sleman', '212', 0, '2018-10-17 01:51:35', '2018-10-17 01:51:35'),
('343', 'KCP Wates', '212', 0, '2018-10-17 01:51:35', '2018-10-17 01:51:35'),
('344', 'KCP Wonosari', '212', 0, '2018-10-17 01:51:35', '2018-10-17 01:51:35'),
('350', 'KC Surabaya', '212', 0, '2018-10-17 01:51:35', '2018-10-17 01:51:35'),
('351', 'KCP Sidoarjo', '212', 0, '2018-10-17 01:51:35', '2018-10-17 01:51:35'),
('352', 'KCP Mojokerto', '212', 0, '2018-10-17 01:51:35', '2018-10-17 01:51:35'),
('353', 'KCP Gresik', '212', 0, '2018-10-17 01:51:35', '2018-10-17 01:51:35'),
('354', 'KCP Jemursari', '212', 0, '2018-10-17 01:51:35', '2018-10-17 01:51:35'),
('355', 'KCP Kertajaya', '212', 0, '2018-10-17 01:51:35', '2018-10-17 01:51:35'),
('356', 'KCP Jombang', '212', 0, '2018-10-17 01:51:35', '2018-10-17 01:51:35'),
('357', 'KCP Pamekasan', '212', 0, '2018-10-17 01:51:35', '2018-10-17 01:51:35'),
('358', 'KCP Sumenep', '212', 0, '2018-10-17 01:51:35', '2018-10-17 01:51:35'),
('359', 'KCP Darmo Boulevard', '212', 0, '2018-10-17 01:51:35', '2018-10-17 01:51:35'),
('360', 'KC Malang', '212', 0, '2018-10-17 01:51:35', '2018-10-17 01:51:35'),
('361', 'KCP Batu', '212', 0, '2018-10-17 01:51:35', '2018-10-17 01:51:35'),
('362', 'KCP Kepanjen', '212', 0, '2018-10-17 01:51:35', '2018-10-17 01:51:35'),
('363', 'KCP Pasuruan', '212', 0, '2018-10-17 01:51:35', '2018-10-17 01:51:35'),
('364', 'KCP Probolinggo', '212', 0, '2018-10-17 01:51:35', '2018-10-17 01:51:35'),
('370', 'KC Denpasar', '212', 0, '2018-10-17 01:51:35', '2018-10-17 01:51:35'),
('371', 'KCP Gianyar', '212', 0, '2018-10-17 01:51:35', '2018-10-17 01:51:35'),
('372', 'KCP Tabanan', '212', 0, '2018-10-17 01:51:35', '2018-10-17 01:51:35'),
('373', 'KCP Singaraja', '212', 0, '2018-10-17 01:51:35', '2018-10-17 01:51:35'),
('376', 'KCP Pasar Atom', '212', 0, '2018-10-17 01:51:35', '2018-10-17 01:51:35'),
('380', 'KC Pekalongan', '212', 0, '2018-10-17 01:51:35', '2018-10-17 01:51:35'),
('390', 'KC Madiun', '212', 0, '2018-10-17 01:51:35', '2018-10-17 01:51:35'),
('400', 'KC Palembang', '212', 0, '2018-10-17 01:51:35', '2018-10-17 01:51:35'),
('401', 'KCP Kayu Agung', '212', 0, '2018-10-17 01:51:35', '2018-10-17 01:51:35'),
('410', 'KC Kediri', '212', 0, '2018-10-17 01:51:35', '2018-10-17 01:51:35'),
('420', 'KC Jember', '212', 0, '2018-10-17 01:51:35', '2018-10-17 01:51:35'),
('900', 'sfsfdf', '798', 1, '2018-11-27 16:18:52', '2018-11-27 16:18:52'),
('913', 'KC Corporate Center', '212', 0, '2018-10-17 01:51:35', '2018-10-17 01:51:35'),
('931', 'KC Karawaci Tangerang', '212', 0, '2018-10-17 01:51:35', '2018-10-17 01:51:35'),
('932', 'KCP Commercial Center Cikarang', '212', 0, '2018-10-17 01:51:35', '2018-10-17 01:51:35'),
('933', 'KCP Cibubur', '212', 0, '2018-10-17 01:51:35', '2018-10-17 01:51:35'),
('934', 'KCP Posco Cilegon', '212', 0, '2018-10-17 01:51:35', '2018-10-17 01:51:35'),
('935', 'KCP Kemang Pratama Bekasi', '212', 0, '2018-10-17 01:51:35', '2018-10-17 01:51:35'),
('936', 'KCP Union Square Cikarang', '212', 0, '2018-10-17 01:51:35', '2018-10-17 01:51:35'),
('937', 'KCP Sadang', '212', 0, '2018-10-17 01:51:35', '2018-10-17 01:51:35'),
('939', 'KCP Kelapa Gading', '212', 0, '2018-10-17 01:51:35', '2018-10-17 01:51:35'),
('940', 'KCP Central Park', '212', 0, '2018-10-17 01:51:35', '2018-10-17 01:51:35'),
('941', 'KCP Pantai Indah Kapuk', '212', 0, '2018-10-17 01:51:35', '2018-10-17 01:51:35'),
('942', 'KCP Citra Raya', '212', 0, '2018-10-17 01:51:35', '2018-10-17 01:51:35'),
('AJB', 'AJB', 'AJB', 0, '2018-11-12 08:01:10', '2018-11-22 08:30:21');

-- --------------------------------------------------------

--
-- Table structure for table `master_claim_status`
--

CREATE TABLE `master_claim_status` (
  `id` int(11) NOT NULL,
  `name` varchar(100) DEFAULT NULL,
  `short_name` varchar(3) DEFAULT NULL,
  `created_at` datetime DEFAULT current_timestamp(),
  `updated_at` datetime DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB AVG_ROW_LENGTH=2730 DEFAULT CHARSET=utf8 ROW_FORMAT=DYNAMIC;

--
-- Dumping data for table `master_claim_status`
--

INSERT INTO `master_claim_status` (`id`, `name`, `short_name`, `created_at`, `updated_at`) VALUES
(1, 'On Review', 'ONR', '2018-11-13 14:17:13', '2018-12-12 15:40:17'),
(2, 'Kurang Dokumen', 'KRD', '2018-11-13 14:17:13', '2018-12-12 15:40:20'),
(3, 'Dokumen Belum di Terima', 'DBT', '2018-11-13 14:17:13', '2018-12-12 15:40:25'),
(4, 'Dokumen Lengkap', 'DKL', '2018-11-13 14:17:13', '2018-12-12 15:40:33'),
(5, 'Claim ditolak / Compromise Settlement', 'CCS', '2018-11-13 14:17:13', '2018-12-12 15:40:39'),
(6, 'Claim dibayar', 'CPD', '2018-11-13 14:17:13', '2018-12-12 15:40:43');

-- --------------------------------------------------------

--
-- Table structure for table `master_data_status`
--

CREATE TABLE `master_data_status` (
  `id` int(11) NOT NULL,
  `name` varchar(255) DEFAULT NULL,
  `short_name` varchar(5) DEFAULT NULL,
  `created_at` datetime DEFAULT current_timestamp(),
  `updated_at` datetime DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB AVG_ROW_LENGTH=2340 DEFAULT CHARSET=utf8 ROW_FORMAT=DYNAMIC;

--
-- Dumping data for table `master_data_status`
--

INSERT INTO `master_data_status` (`id`, `name`, `short_name`, `created_at`, `updated_at`) VALUES
(1, 'Unverified', 'UNV', '2018-11-13 18:50:48', '2018-12-12 11:47:39'),
(2, 'Open', 'OPN', '2018-11-13 18:50:48', '2018-12-12 11:47:41'),
(3, 'Closed', 'CLS', '2018-11-13 18:50:48', '2018-12-12 11:47:43'),
(4, 'On Claiming', 'ONC', '2018-11-13 18:50:48', '2018-12-12 11:47:48'),
(5, 'Claimed', 'CLM', '2018-11-13 18:50:48', '2018-12-12 11:47:50'),
(6, 'Validation Failed', 'VLF', '2018-11-13 18:50:48', '2018-12-12 11:47:54'),
(7, 'On Proposing Repayment', 'OPR', '2018-11-28 06:52:55', '2018-12-12 11:47:58');

-- --------------------------------------------------------

--
-- Table structure for table `master_document`
--

CREATE TABLE `master_document` (
  `id` int(11) NOT NULL,
  `document` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `master_document`
--

INSERT INTO `master_document` (`id`, `document`) VALUES
(1, 'Surat Kematian'),
(2, 'KTP'),
(3, 'KK'),
(4, 'Perjanjian Kredit'),
(5, 'Jadwal Angsuran'),
(6, 'Copy Polis Asuransi');

-- --------------------------------------------------------

--
-- Table structure for table `master_insurances`
--

CREATE TABLE `master_insurances` (
  `id` varchar(3) COLLATE utf8mb4_unicode_ci NOT NULL,
  `name` varchar(150) COLLATE utf8mb4_unicode_ci NOT NULL,
  `created_at` timestamp NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB AVG_ROW_LENGTH=4096 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci ROW_FORMAT=DYNAMIC;

--
-- Dumping data for table `master_insurances`
--

INSERT INTO `master_insurances` (`id`, `name`, `created_at`, `updated_at`) VALUES
('AJB', 'Asuransi Bumiputera', '2018-11-12 23:48:09', '2018-11-22 08:30:46'),
('LIP', 'Lippo Insurance', '2020-10-07 09:11:48', '2020-10-07 09:11:48');

-- --------------------------------------------------------

--
-- Table structure for table `master_insurance_kinds`
--

CREATE TABLE `master_insurance_kinds` (
  `id` varchar(6) NOT NULL,
  `name` varchar(200) DEFAULT NULL,
  `created_at` datetime DEFAULT current_timestamp(),
  `updated_at` datetime DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB AVG_ROW_LENGTH=16384 DEFAULT CHARSET=utf8 ROW_FORMAT=DYNAMIC;

--
-- Dumping data for table `master_insurance_kinds`
--

INSERT INTO `master_insurance_kinds` (`id`, `name`, `created_at`, `updated_at`) VALUES
('AJBAJK', 'Asuransi Jiwa Kredit', '2018-11-13 13:22:40', '2018-11-13 10:01:35');

-- --------------------------------------------------------

--
-- Table structure for table `master_insurance_rates`
--

CREATE TABLE `master_insurance_rates` (
  `id` bigint(20) NOT NULL,
  `insurance_kind_id` varchar(6) DEFAULT NULL,
  `bank_id` varchar(3) DEFAULT NULL,
  `age` int(11) DEFAULT NULL,
  `jw` int(255) DEFAULT NULL,
  `rate` decimal(10,2) DEFAULT NULL,
  `created_at` datetime DEFAULT current_timestamp(),
  `updated_at` datetime DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB AVG_ROW_LENGTH=89 DEFAULT CHARSET=utf8 ROW_FORMAT=DYNAMIC;

--
-- Dumping data for table `master_insurance_rates`
--

INSERT INTO `master_insurance_rates` (`id`, `insurance_kind_id`, `bank_id`, `age`, `jw`, `rate`, `created_at`, `updated_at`) VALUES
(1, 'AJBAJK', '212', 20, 1, '0.79', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(2, 'AJBAJK', '212', 20, 2, '1.34', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(3, 'AJBAJK', '212', 20, 3, '1.90', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(4, 'AJBAJK', '212', 20, 4, '2.48', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(5, 'AJBAJK', '212', 20, 5, '3.06', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(6, 'AJBAJK', '212', 20, 6, '3.65', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(7, 'AJBAJK', '212', 20, 7, '4.24', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(8, 'AJBAJK', '212', 20, 8, '4.84', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(9, 'AJBAJK', '212', 20, 9, '5.44', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(10, 'AJBAJK', '212', 20, 10, '6.03', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(11, 'AJBAJK', '212', 20, 11, '6.62', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(12, 'AJBAJK', '212', 20, 12, '7.19', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(13, 'AJBAJK', '212', 20, 13, '7.76', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(14, 'AJBAJK', '212', 20, 14, '8.32', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(15, 'AJBAJK', '212', 20, 15, '8.89', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(16, 'AJBAJK', '212', 20, 16, '9.44', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(17, 'AJBAJK', '212', 20, 17, '9.99', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(18, 'AJBAJK', '212', 20, 18, '10.53', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(19, 'AJBAJK', '212', 20, 19, '11.07', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(20, 'AJBAJK', '212', 20, 20, '11.61', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(21, 'AJBAJK', '212', 21, 1, '0.79', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(22, 'AJBAJK', '212', 21, 2, '1.34', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(23, 'AJBAJK', '212', 21, 3, '1.90', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(24, 'AJBAJK', '212', 21, 4, '2.48', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(25, 'AJBAJK', '212', 21, 5, '3.06', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(26, 'AJBAJK', '212', 21, 6, '3.65', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(27, 'AJBAJK', '212', 21, 7, '4.24', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(28, 'AJBAJK', '212', 21, 8, '4.85', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(29, 'AJBAJK', '212', 21, 9, '5.45', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(30, 'AJBAJK', '212', 21, 10, '6.05', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(31, 'AJBAJK', '212', 21, 11, '6.64', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(32, 'AJBAJK', '212', 21, 12, '7.21', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(33, 'AJBAJK', '212', 21, 13, '7.79', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(34, 'AJBAJK', '212', 21, 14, '8.37', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(35, 'AJBAJK', '212', 21, 15, '8.94', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(36, 'AJBAJK', '212', 21, 16, '9.51', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(37, 'AJBAJK', '212', 21, 17, '10.07', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(38, 'AJBAJK', '212', 21, 18, '10.63', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(39, 'AJBAJK', '212', 21, 19, '11.19', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(40, 'AJBAJK', '212', 21, 20, '11.75', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(41, 'AJBAJK', '212', 22, 1, '0.79', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(42, 'AJBAJK', '212', 22, 2, '1.34', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(43, 'AJBAJK', '212', 22, 3, '1.90', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(44, 'AJBAJK', '212', 22, 4, '2.48', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(45, 'AJBAJK', '212', 22, 5, '3.06', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(46, 'AJBAJK', '212', 22, 6, '3.65', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(47, 'AJBAJK', '212', 22, 7, '4.25', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(48, 'AJBAJK', '212', 22, 8, '4.85', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(49, 'AJBAJK', '212', 22, 9, '5.46', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(50, 'AJBAJK', '212', 22, 10, '6.07', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(51, 'AJBAJK', '212', 22, 11, '6.66', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(52, 'AJBAJK', '212', 22, 12, '7.25', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(53, 'AJBAJK', '212', 22, 13, '7.84', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(54, 'AJBAJK', '212', 22, 14, '8.43', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(55, 'AJBAJK', '212', 22, 15, '9.02', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(56, 'AJBAJK', '212', 22, 16, '9.60', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(57, 'AJBAJK', '212', 22, 17, '10.19', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(58, 'AJBAJK', '212', 22, 18, '10.77', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(59, 'AJBAJK', '212', 22, 19, '11.35', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(60, 'AJBAJK', '212', 22, 20, '11.94', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(61, 'AJBAJK', '212', 23, 1, '0.79', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(62, 'AJBAJK', '212', 23, 2, '1.34', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(63, 'AJBAJK', '212', 23, 3, '1.90', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(64, 'AJBAJK', '212', 23, 4, '2.48', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(65, 'AJBAJK', '212', 23, 5, '3.06', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(66, 'AJBAJK', '212', 23, 6, '3.66', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(67, 'AJBAJK', '212', 23, 7, '4.26', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(68, 'AJBAJK', '212', 23, 8, '4.87', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(69, 'AJBAJK', '212', 23, 9, '5.49', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(70, 'AJBAJK', '212', 23, 10, '6.10', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(71, 'AJBAJK', '212', 23, 11, '6.71', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(72, 'AJBAJK', '212', 23, 12, '7.31', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(73, 'AJBAJK', '212', 23, 13, '7.91', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(74, 'AJBAJK', '212', 23, 14, '8.52', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(75, 'AJBAJK', '212', 23, 15, '9.13', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(76, 'AJBAJK', '212', 23, 16, '9.74', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(77, 'AJBAJK', '212', 23, 17, '10.35', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(78, 'AJBAJK', '212', 23, 18, '10.96', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(79, 'AJBAJK', '212', 23, 19, '11.57', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(80, 'AJBAJK', '212', 23, 20, '12.18', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(81, 'AJBAJK', '212', 24, 1, '0.79', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(82, 'AJBAJK', '212', 24, 2, '1.34', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(83, 'AJBAJK', '212', 24, 3, '1.90', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(84, 'AJBAJK', '212', 24, 4, '2.48', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(85, 'AJBAJK', '212', 24, 5, '3.07', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(86, 'AJBAJK', '212', 24, 6, '3.67', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(87, 'AJBAJK', '212', 24, 7, '4.28', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(88, 'AJBAJK', '212', 24, 8, '4.90', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(89, 'AJBAJK', '212', 24, 9, '5.53', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(90, 'AJBAJK', '212', 24, 10, '6.16', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(91, 'AJBAJK', '212', 24, 11, '6.77', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(92, 'AJBAJK', '212', 24, 12, '7.39', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(93, 'AJBAJK', '212', 24, 13, '8.01', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(94, 'AJBAJK', '212', 24, 14, '8.64', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(95, 'AJBAJK', '212', 24, 15, '9.28', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(96, 'AJBAJK', '212', 24, 16, '9.92', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(97, 'AJBAJK', '212', 24, 17, '10.56', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(98, 'AJBAJK', '212', 24, 18, '11.20', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(99, 'AJBAJK', '212', 24, 19, '11.84', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(100, 'AJBAJK', '212', 24, 20, '12.49', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(101, 'AJBAJK', '212', 25, 1, '0.79', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(102, 'AJBAJK', '212', 25, 2, '1.34', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(103, 'AJBAJK', '212', 25, 3, '1.90', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(104, 'AJBAJK', '212', 25, 4, '2.49', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(105, 'AJBAJK', '212', 25, 5, '3.08', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(106, 'AJBAJK', '212', 25, 6, '3.70', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(107, 'AJBAJK', '212', 25, 7, '4.32', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(108, 'AJBAJK', '212', 25, 8, '4.95', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(109, 'AJBAJK', '212', 25, 9, '5.59', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(110, 'AJBAJK', '212', 25, 10, '6.23', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(111, 'AJBAJK', '212', 25, 11, '6.87', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(112, 'AJBAJK', '212', 25, 12, '7.51', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(113, 'AJBAJK', '212', 25, 13, '8.16', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(114, 'AJBAJK', '212', 25, 14, '8.82', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(115, 'AJBAJK', '212', 25, 15, '9.49', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(116, 'AJBAJK', '212', 25, 16, '10.16', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(117, 'AJBAJK', '212', 25, 17, '10.83', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(118, 'AJBAJK', '212', 25, 18, '11.51', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(119, 'AJBAJK', '212', 25, 19, '12.19', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(120, 'AJBAJK', '212', 25, 20, '12.87', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(121, 'AJBAJK', '212', 26, 1, '0.79', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(122, 'AJBAJK', '212', 26, 2, '1.34', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(123, 'AJBAJK', '212', 26, 3, '1.91', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(124, 'AJBAJK', '212', 26, 4, '2.51', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(125, 'AJBAJK', '212', 26, 5, '3.12', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(126, 'AJBAJK', '212', 26, 6, '3.74', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(127, 'AJBAJK', '212', 26, 7, '4.38', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(128, 'AJBAJK', '212', 26, 8, '5.03', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(129, 'AJBAJK', '212', 26, 9, '5.68', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(130, 'AJBAJK', '212', 26, 10, '6.34', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(131, 'AJBAJK', '212', 26, 11, '7.01', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(132, 'AJBAJK', '212', 26, 12, '7.68', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(133, 'AJBAJK', '212', 26, 13, '8.36', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(134, 'AJBAJK', '212', 26, 14, '9.06', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(135, 'AJBAJK', '212', 26, 15, '9.76', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(136, 'AJBAJK', '212', 26, 16, '10.47', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(137, 'AJBAJK', '212', 26, 17, '11.18', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(138, 'AJBAJK', '212', 26, 18, '11.90', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(139, 'AJBAJK', '212', 26, 19, '12.62', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(140, 'AJBAJK', '212', 26, 20, '13.35', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(141, 'AJBAJK', '212', 27, 1, '0.79', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(142, 'AJBAJK', '212', 27, 2, '1.36', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(143, 'AJBAJK', '212', 27, 3, '1.95', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(144, 'AJBAJK', '212', 27, 4, '2.56', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(145, 'AJBAJK', '212', 27, 5, '3.18', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(146, 'AJBAJK', '212', 27, 6, '3.82', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(147, 'AJBAJK', '212', 27, 7, '4.47', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(148, 'AJBAJK', '212', 27, 8, '5.13', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(149, 'AJBAJK', '212', 27, 9, '5.81', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(150, 'AJBAJK', '212', 27, 10, '6.51', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(151, 'AJBAJK', '212', 27, 11, '7.21', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(152, 'AJBAJK', '212', 27, 12, '7.91', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(153, 'AJBAJK', '212', 27, 13, '8.63', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(154, 'AJBAJK', '212', 27, 14, '9.37', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(155, 'AJBAJK', '212', 27, 15, '10.12', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(156, 'AJBAJK', '212', 27, 16, '10.87', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(157, 'AJBAJK', '212', 27, 17, '11.63', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(158, 'AJBAJK', '212', 27, 18, '12.40', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(159, 'AJBAJK', '212', 27, 19, '13.17', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(160, 'AJBAJK', '212', 27, 20, '13.94', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(161, 'AJBAJK', '212', 28, 1, '0.83', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(162, 'AJBAJK', '212', 28, 2, '1.41', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(163, 'AJBAJK', '212', 28, 3, '2.01', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(164, 'AJBAJK', '212', 28, 4, '2.64', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(165, 'AJBAJK', '212', 28, 5, '3.27', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(166, 'AJBAJK', '212', 28, 6, '3.93', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(167, 'AJBAJK', '212', 28, 7, '4.60', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(168, 'AJBAJK', '212', 28, 8, '5.29', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(169, 'AJBAJK', '212', 28, 9, '6.01', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(170, 'AJBAJK', '212', 28, 10, '6.74', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(171, 'AJBAJK', '212', 28, 11, '7.48', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(172, 'AJBAJK', '212', 28, 12, '8.23', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(173, 'AJBAJK', '212', 28, 13, '9.00', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(174, 'AJBAJK', '212', 28, 14, '9.78', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(175, 'AJBAJK', '212', 28, 15, '10.58', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(176, 'AJBAJK', '212', 28, 16, '11.38', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(177, 'AJBAJK', '212', 28, 17, '12.20', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(178, 'AJBAJK', '212', 28, 18, '13.02', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(179, 'AJBAJK', '212', 28, 19, '13.84', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(180, 'AJBAJK', '212', 28, 20, '14.67', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(181, 'AJBAJK', '212', 29, 1, '0.84', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(182, 'AJBAJK', '212', 29, 2, '1.44', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(183, 'AJBAJK', '212', 29, 3, '2.05', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(184, 'AJBAJK', '212', 29, 4, '2.68', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(185, 'AJBAJK', '212', 29, 5, '3.34', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(186, 'AJBAJK', '212', 29, 6, '4.01', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(187, 'AJBAJK', '212', 29, 7, '4.71', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(188, 'AJBAJK', '212', 29, 8, '5.44', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(189, 'AJBAJK', '212', 29, 9, '6.20', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(190, 'AJBAJK', '212', 29, 10, '6.98', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(191, 'AJBAJK', '212', 29, 11, '7.77', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(192, 'AJBAJK', '212', 29, 12, '8.56', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(193, 'AJBAJK', '212', 29, 13, '9.38', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(194, 'AJBAJK', '212', 29, 14, '10.22', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(195, 'AJBAJK', '212', 29, 15, '11.07', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(196, 'AJBAJK', '212', 29, 16, '11.94', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(197, 'AJBAJK', '212', 29, 17, '12.81', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(198, 'AJBAJK', '212', 29, 18, '13.69', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(199, 'AJBAJK', '212', 29, 19, '14.57', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(200, 'AJBAJK', '212', 29, 20, '15.46', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(201, 'AJBAJK', '212', 30, 1, '0.86', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(202, 'AJBAJK', '212', 30, 2, '1.46', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(203, 'AJBAJK', '212', 30, 3, '2.09', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(204, 'AJBAJK', '212', 30, 4, '2.74', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(205, 'AJBAJK', '212', 30, 5, '3.42', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(206, 'AJBAJK', '212', 30, 6, '4.13', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(207, 'AJBAJK', '212', 30, 7, '4.87', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(208, 'AJBAJK', '212', 30, 8, '5.65', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(209, 'AJBAJK', '212', 30, 9, '6.45', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(210, 'AJBAJK', '212', 30, 10, '7.28', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(211, 'AJBAJK', '212', 30, 11, '8.13', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(212, 'AJBAJK', '212', 30, 12, '8.98', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(213, 'AJBAJK', '212', 30, 13, '9.86', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(214, 'AJBAJK', '212', 30, 14, '10.76', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(215, 'AJBAJK', '212', 30, 15, '11.68', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(216, 'AJBAJK', '212', 30, 16, '12.60', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(217, 'AJBAJK', '212', 30, 17, '13.54', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(218, 'AJBAJK', '212', 30, 18, '14.48', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(219, 'AJBAJK', '212', 30, 19, '15.43', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(220, 'AJBAJK', '212', 30, 20, '16.39', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(221, 'AJBAJK', '212', 31, 1, '0.88', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(222, 'AJBAJK', '212', 31, 2, '1.50', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(223, 'AJBAJK', '212', 31, 3, '2.15', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(224, 'AJBAJK', '212', 31, 4, '2.82', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(225, 'AJBAJK', '212', 31, 5, '3.54', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(226, 'AJBAJK', '212', 31, 6, '4.29', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(227, 'AJBAJK', '212', 31, 7, '5.09', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(228, 'AJBAJK', '212', 31, 8, '5.92', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(229, 'AJBAJK', '212', 31, 9, '6.79', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(230, 'AJBAJK', '212', 31, 10, '7.68', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(231, 'AJBAJK', '212', 31, 11, '8.58', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(232, 'AJBAJK', '212', 31, 12, '9.50', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(233, 'AJBAJK', '212', 31, 13, '10.45', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(234, 'AJBAJK', '212', 31, 14, '11.42', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(235, 'AJBAJK', '212', 31, 15, '12.41', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(236, 'AJBAJK', '212', 31, 16, '13.40', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(237, 'AJBAJK', '212', 31, 17, '14.41', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(238, 'AJBAJK', '212', 31, 18, '15.43', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(239, 'AJBAJK', '212', 31, 19, '16.45', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(240, 'AJBAJK', '212', 31, 20, '17.49', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(241, 'AJBAJK', '212', 32, 1, '0.90', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(242, 'AJBAJK', '212', 32, 2, '1.53', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(243, 'AJBAJK', '212', 32, 3, '2.21', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(244, 'AJBAJK', '212', 32, 4, '2.93', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(245, 'AJBAJK', '212', 32, 5, '3.70', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(246, 'AJBAJK', '212', 32, 6, '4.51', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(247, 'AJBAJK', '212', 32, 7, '5.37', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(248, 'AJBAJK', '212', 32, 8, '6.27', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(249, 'AJBAJK', '212', 32, 9, '7.20', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(250, 'AJBAJK', '212', 32, 10, '8.16', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(251, 'AJBAJK', '212', 32, 11, '9.14', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(252, 'AJBAJK', '212', 32, 12, '10.13', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(253, 'AJBAJK', '212', 32, 13, '11.15', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(254, 'AJBAJK', '212', 32, 14, '12.20', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(255, 'AJBAJK', '212', 32, 15, '13.26', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(256, 'AJBAJK', '212', 32, 16, '14.34', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(257, 'AJBAJK', '212', 32, 17, '15.43', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(258, 'AJBAJK', '212', 32, 18, '16.53', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(259, 'AJBAJK', '212', 32, 19, '17.63', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(260, 'AJBAJK', '212', 32, 20, '18.75', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(261, 'AJBAJK', '212', 33, 1, '0.94', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(262, 'AJBAJK', '212', 33, 2, '1.61', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(263, 'AJBAJK', '212', 33, 3, '2.34', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(264, 'AJBAJK', '212', 33, 4, '3.12', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(265, 'AJBAJK', '212', 33, 5, '3.95', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(266, 'AJBAJK', '212', 33, 6, '4.84', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(267, 'AJBAJK', '212', 33, 7, '5.76', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(268, 'AJBAJK', '212', 33, 8, '6.74', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(269, 'AJBAJK', '212', 33, 9, '7.74', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(270, 'AJBAJK', '212', 33, 10, '8.78', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(271, 'AJBAJK', '212', 33, 11, '9.84', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(272, 'AJBAJK', '212', 33, 12, '10.92', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(273, 'AJBAJK', '212', 33, 13, '12.02', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(274, 'AJBAJK', '212', 33, 14, '13.15', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(275, 'AJBAJK', '212', 33, 15, '14.31', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(276, 'AJBAJK', '212', 33, 16, '15.47', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(277, 'AJBAJK', '212', 33, 17, '16.65', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(278, 'AJBAJK', '212', 33, 18, '17.84', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(279, 'AJBAJK', '212', 33, 19, '19.03', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(280, 'AJBAJK', '212', 33, 20, '20.24', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(281, 'AJBAJK', '212', 34, 1, '1.00', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(282, 'AJBAJK', '212', 34, 2, '1.73', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(283, 'AJBAJK', '212', 34, 3, '2.52', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(284, 'AJBAJK', '212', 34, 4, '3.38', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(285, 'AJBAJK', '212', 34, 5, '4.29', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(286, 'AJBAJK', '212', 34, 6, '5.25', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(287, 'AJBAJK', '212', 34, 7, '6.25', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(288, 'AJBAJK', '212', 34, 8, '7.30', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(289, 'AJBAJK', '212', 34, 9, '8.40', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(290, 'AJBAJK', '212', 34, 10, '9.53', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(291, 'AJBAJK', '212', 34, 11, '10.67', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(292, 'AJBAJK', '212', 34, 12, '11.84', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(293, 'AJBAJK', '212', 34, 13, '13.03', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(294, 'AJBAJK', '212', 34, 14, '14.26', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(295, 'AJBAJK', '212', 34, 15, '15.51', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(296, 'AJBAJK', '212', 34, 16, '16.77', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(297, 'AJBAJK', '212', 34, 17, '18.05', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(298, 'AJBAJK', '212', 34, 18, '19.33', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(299, 'AJBAJK', '212', 34, 19, '20.62', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(300, 'AJBAJK', '212', 34, 20, '21.93', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(301, 'AJBAJK', '212', 35, 1, '1.09', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(302, 'AJBAJK', '212', 35, 2, '1.90', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(303, 'AJBAJK', '212', 35, 3, '2.77', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(304, 'AJBAJK', '212', 35, 4, '3.70', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(305, 'AJBAJK', '212', 35, 5, '4.68', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(306, 'AJBAJK', '212', 35, 6, '5.72', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(307, 'AJBAJK', '212', 35, 7, '6.81', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(308, 'AJBAJK', '212', 35, 8, '7.95', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(309, 'AJBAJK', '212', 35, 9, '9.14', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(310, 'AJBAJK', '212', 35, 10, '10.36', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(311, 'AJBAJK', '212', 35, 11, '11.60', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(312, 'AJBAJK', '212', 35, 12, '12.87', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(313, 'AJBAJK', '212', 35, 13, '14.16', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(314, 'AJBAJK', '212', 35, 14, '15.49', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(315, 'AJBAJK', '212', 35, 15, '16.85', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(316, 'AJBAJK', '212', 35, 16, '18.21', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(317, 'AJBAJK', '212', 35, 17, '19.59', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(318, 'AJBAJK', '212', 35, 18, '20.98', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(319, 'AJBAJK', '212', 35, 19, '22.38', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(320, 'AJBAJK', '212', 35, 20, '23.80', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(321, 'AJBAJK', '212', 36, 1, '1.21', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(322, 'AJBAJK', '212', 36, 2, '2.09', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(323, 'AJBAJK', '212', 36, 3, '3.03', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(324, 'AJBAJK', '212', 36, 4, '4.04', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(325, 'AJBAJK', '212', 36, 5, '5.10', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(326, 'AJBAJK', '212', 36, 6, '6.22', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(327, 'AJBAJK', '212', 36, 7, '7.41', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(328, 'AJBAJK', '212', 36, 8, '8.65', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(329, 'AJBAJK', '212', 36, 9, '9.93', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(330, 'AJBAJK', '212', 36, 10, '11.26', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(331, 'AJBAJK', '212', 36, 11, '12.61', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(332, 'AJBAJK', '212', 36, 12, '13.97', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(333, 'AJBAJK', '212', 36, 13, '15.38', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(334, 'AJBAJK', '212', 36, 14, '16.82', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(335, 'AJBAJK', '212', 36, 15, '18.28', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(336, 'AJBAJK', '212', 36, 16, '19.76', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(337, 'AJBAJK', '212', 36, 17, '21.25', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(338, 'AJBAJK', '212', 36, 18, '22.76', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(339, 'AJBAJK', '212', 36, 19, '24.28', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(340, 'AJBAJK', '212', 36, 20, '25.81', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(341, 'AJBAJK', '212', 37, 1, '1.31', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(342, 'AJBAJK', '212', 37, 2, '2.26', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(343, 'AJBAJK', '212', 37, 3, '3.27', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(344, 'AJBAJK', '212', 37, 4, '4.36', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(345, 'AJBAJK', '212', 37, 5, '5.51', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(346, 'AJBAJK', '212', 37, 6, '6.73', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(347, 'AJBAJK', '212', 37, 7, '8.01', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(348, 'AJBAJK', '212', 37, 8, '9.35', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(349, 'AJBAJK', '212', 37, 9, '10.75', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(350, 'AJBAJK', '212', 37, 10, '12.18', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(351, 'AJBAJK', '212', 37, 11, '13.64', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(352, 'AJBAJK', '212', 37, 12, '15.12', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(353, 'AJBAJK', '212', 37, 13, '16.64', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(354, 'AJBAJK', '212', 37, 14, '18.20', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(355, 'AJBAJK', '212', 37, 15, '19.78', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(356, 'AJBAJK', '212', 37, 16, '21.38', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(357, 'AJBAJK', '212', 37, 17, '23.00', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(358, 'AJBAJK', '212', 37, 18, '24.63', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(359, 'AJBAJK', '212', 37, 19, '26.27', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(360, 'AJBAJK', '212', 37, 20, '27.92', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(361, 'AJBAJK', '212', 38, 1, '1.40', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(362, 'AJBAJK', '212', 38, 2, '2.42', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(363, 'AJBAJK', '212', 38, 3, '3.52', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(364, 'AJBAJK', '212', 38, 4, '4.70', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(365, 'AJBAJK', '212', 38, 5, '5.95', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(366, 'AJBAJK', '212', 38, 6, '7.27', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(367, 'AJBAJK', '212', 38, 7, '8.65', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(368, 'AJBAJK', '212', 38, 8, '10.11', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(369, 'AJBAJK', '212', 38, 9, '11.62', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(370, 'AJBAJK', '212', 38, 10, '13.17', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(371, 'AJBAJK', '212', 38, 11, '14.75', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(372, 'AJBAJK', '212', 38, 12, '16.35', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(373, 'AJBAJK', '212', 38, 13, '18.00', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(374, 'AJBAJK', '212', 38, 14, '19.68', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(375, 'AJBAJK', '212', 38, 15, '21.39', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(376, 'AJBAJK', '212', 38, 16, '23.12', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(377, 'AJBAJK', '212', 38, 17, '24.87', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(378, 'AJBAJK', '212', 38, 18, '26.64', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(379, 'AJBAJK', '212', 38, 19, '28.41', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(380, 'AJBAJK', '212', 38, 20, '30.19', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(381, 'AJBAJK', '212', 39, 1, '1.52', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(382, 'AJBAJK', '212', 39, 2, '2.63', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(383, 'AJBAJK', '212', 39, 3, '3.82', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(384, 'AJBAJK', '212', 39, 4, '5.10', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(385, 'AJBAJK', '212', 39, 5, '6.45', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(386, 'AJBAJK', '212', 39, 6, '7.88', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(387, 'AJBAJK', '212', 39, 7, '9.39', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(388, 'AJBAJK', '212', 39, 8, '10.96', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(389, 'AJBAJK', '212', 39, 9, '12.60', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(390, 'AJBAJK', '212', 39, 10, '14.28', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(391, 'AJBAJK', '212', 39, 11, '15.99', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(392, 'AJBAJK', '212', 39, 12, '17.72', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(393, 'AJBAJK', '212', 39, 13, '19.50', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(394, 'AJBAJK', '212', 39, 14, '21.32', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(395, 'AJBAJK', '212', 39, 15, '23.18', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(396, 'AJBAJK', '212', 39, 16, '25.05', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(397, 'AJBAJK', '212', 39, 17, '26.94', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(398, 'AJBAJK', '212', 39, 18, '28.85', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(399, 'AJBAJK', '212', 39, 19, '30.76', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(400, 'AJBAJK', '212', 39, 20, '32.69', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(401, 'AJBAJK', '212', 40, 1, '1.65', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(402, 'AJBAJK', '212', 40, 2, '2.85', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(403, 'AJBAJK', '212', 40, 3, '4.15', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(404, 'AJBAJK', '212', 40, 4, '5.53', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(405, 'AJBAJK', '212', 40, 5, '7.00', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(406, 'AJBAJK', '212', 40, 6, '8.55', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(407, 'AJBAJK', '212', 40, 7, '10.18', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(408, 'AJBAJK', '212', 40, 8, '11.89', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(409, 'AJBAJK', '212', 40, 9, '13.66', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(410, 'AJBAJK', '212', 40, 10, '15.48', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(411, 'AJBAJK', '212', 40, 11, '17.33', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(412, 'AJBAJK', '212', 40, 12, '19.20', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(413, 'AJBAJK', '212', 40, 13, '21.13', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(414, 'AJBAJK', '212', 40, 14, '23.10', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(415, 'AJBAJK', '212', 40, 15, '25.11', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(416, 'AJBAJK', '212', 40, 16, '27.14', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(417, 'AJBAJK', '212', 40, 17, '29.18', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(418, 'AJBAJK', '212', 40, 18, '31.24', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(419, 'AJBAJK', '212', 40, 19, '33.30', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(420, 'AJBAJK', '212', 40, 20, '35.40', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(421, 'AJBAJK', '212', 41, 1, '1.79', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(422, 'AJBAJK', '212', 41, 2, '3.10', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(423, 'AJBAJK', '212', 41, 3, '4.50', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(424, 'AJBAJK', '212', 41, 4, '6.00', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(425, 'AJBAJK', '212', 41, 5, '7.60', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(426, 'AJBAJK', '212', 41, 6, '9.28', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(427, 'AJBAJK', '212', 41, 7, '11.04', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(428, 'AJBAJK', '212', 41, 8, '12.89', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(429, 'AJBAJK', '212', 41, 9, '14.81', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(430, 'AJBAJK', '212', 41, 10, '16.77', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(431, 'AJBAJK', '212', 41, 11, '18.77', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(432, 'AJBAJK', '212', 41, 12, '20.80', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(433, 'AJBAJK', '212', 41, 13, '22.89', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(434, 'AJBAJK', '212', 41, 14, '25.02', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(435, 'AJBAJK', '212', 41, 15, '27.19', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(436, 'AJBAJK', '212', 41, 16, '29.38', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(437, 'AJBAJK', '212', 41, 17, '31.59', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(438, 'AJBAJK', '212', 41, 18, '33.81', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(439, 'AJBAJK', '212', 41, 19, '36.05', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(440, 'AJBAJK', '212', 41, 20, '38.32', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(441, 'AJBAJK', '212', 42, 1, '1.95', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(442, 'AJBAJK', '212', 42, 2, '3.36', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(443, 'AJBAJK', '212', 42, 3, '4.88', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(444, 'AJBAJK', '212', 42, 4, '6.51', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(445, 'AJBAJK', '212', 42, 5, '8.24', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(446, 'AJBAJK', '212', 42, 6, '10.06', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(447, 'AJBAJK', '212', 42, 7, '11.96', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(448, 'AJBAJK', '212', 42, 8, '13.96', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(449, 'AJBAJK', '212', 42, 9, '16.03', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(450, 'AJBAJK', '212', 42, 10, '18.16', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(451, 'AJBAJK', '212', 42, 11, '20.33', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(452, 'AJBAJK', '212', 42, 12, '22.52', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(453, 'AJBAJK', '212', 42, 13, '24.78', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(454, 'AJBAJK', '212', 42, 14, '27.09', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(455, 'AJBAJK', '212', 42, 15, '29.43', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(456, 'AJBAJK', '212', 42, 16, '31.80', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(457, 'AJBAJK', '212', 42, 17, '34.18', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(458, 'AJBAJK', '212', 42, 18, '36.59', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(459, 'AJBAJK', '212', 42, 19, '39.02', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(460, 'AJBAJK', '212', 42, 20, '41.49', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(461, 'AJBAJK', '212', 43, 1, '2.10', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(462, 'AJBAJK', '212', 43, 2, '3.64', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(463, 'AJBAJK', '212', 43, 3, '5.28', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(464, 'AJBAJK', '212', 43, 4, '7.05', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(465, 'AJBAJK', '212', 43, 5, '8.92', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(466, 'AJBAJK', '212', 43, 6, '10.88', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(467, 'AJBAJK', '212', 43, 7, '12.95', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(468, 'AJBAJK', '212', 43, 8, '15.11', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(469, 'AJBAJK', '212', 43, 9, '17.35', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(470, 'AJBAJK', '212', 43, 10, '19.65', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(471, 'AJBAJK', '212', 43, 11, '22.00', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(472, 'AJBAJK', '212', 43, 12, '24.37', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(473, 'AJBAJK', '212', 43, 13, '26.82', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(474, 'AJBAJK', '212', 43, 14, '29.31', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(475, 'AJBAJK', '212', 43, 15, '31.84', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(476, 'AJBAJK', '212', 43, 16, '34.39', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(477, 'AJBAJK', '212', 43, 17, '36.98', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(478, 'AJBAJK', '212', 43, 18, '39.59', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(479, 'AJBAJK', '212', 43, 19, '42.23', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(480, 'AJBAJK', '212', 43, 20, '44.90', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(481, 'AJBAJK', '212', 44, 1, '2.29', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(482, 'AJBAJK', '212', 44, 2, '3.95', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(483, 'AJBAJK', '212', 44, 3, '5.73', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(484, 'AJBAJK', '212', 44, 4, '7.64', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(485, 'AJBAJK', '212', 44, 5, '9.66', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(486, 'AJBAJK', '212', 44, 6, '11.79', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(487, 'AJBAJK', '212', 44, 7, '14.02', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(488, 'AJBAJK', '212', 44, 8, '16.36', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(489, 'AJBAJK', '212', 44, 9, '18.78', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(490, 'AJBAJK', '212', 44, 10, '21.28', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(491, 'AJBAJK', '212', 44, 11, '23.82', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(492, 'AJBAJK', '212', 44, 12, '26.39', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(493, 'AJBAJK', '212', 44, 13, '29.02', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(494, 'AJBAJK', '212', 44, 14, '31.71', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(495, 'AJBAJK', '212', 44, 15, '34.45', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(496, 'AJBAJK', '212', 44, 16, '37.22', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(497, 'AJBAJK', '212', 44, 17, '40.02', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(498, 'AJBAJK', '212', 44, 18, '43.86', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(499, 'AJBAJK', '212', 44, 19, '45.72', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(500, 'AJBAJK', '212', 44, 20, '48.64', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(501, 'AJBAJK', '212', 45, 1, '2.47', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(502, 'AJBAJK', '212', 45, 2, '4.27', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(503, 'AJBAJK', '212', 45, 3, '6.20', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(504, 'AJBAJK', '212', 45, 4, '8.27', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(505, 'AJBAJK', '212', 45, 5, '10.45', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(506, 'AJBAJK', '212', 45, 6, '12.75', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(507, 'AJBAJK', '212', 45, 7, '15.16', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(508, 'AJBAJK', '212', 45, 8, '17.70', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(509, 'AJBAJK', '212', 45, 9, '20.32', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(510, 'AJBAJK', '212', 45, 10, '23.03', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(511, 'AJBAJK', '212', 45, 11, '25.77', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(512, 'AJBAJK', '212', 45, 12, '28.54', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(513, 'AJBAJK', '212', 45, 13, '31.38', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(514, 'AJBAJK', '212', 45, 14, '34.29', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(515, 'AJBAJK', '212', 45, 15, '37.26', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(516, 'AJBAJK', '212', 45, 16, '40.27', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(517, 'AJBAJK', '212', 45, 17, '43.31', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(518, 'AJBAJK', '212', 45, 18, '46.40', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(519, 'AJBAJK', '212', 45, 19, '49.51', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(520, 'AJBAJK', '212', 45, 20, '52.68', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(521, 'AJBAJK', '212', 46, 1, '2.69', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(522, 'AJBAJK', '212', 46, 2, '4.64', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(523, 'AJBAJK', '212', 46, 3, '6.73', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(524, 'AJBAJK', '212', 46, 4, '8.96', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(525, 'AJBAJK', '212', 46, 5, '11.32', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(526, 'AJBAJK', '212', 46, 6, '13.80', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(527, 'AJBAJK', '212', 46, 7, '16.42', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(528, 'AJBAJK', '212', 46, 8, '19.16', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(529, 'AJBAJK', '212', 46, 9, '22.01', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(530, 'AJBAJK', '212', 46, 10, '24.93', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(531, 'AJBAJK', '212', 46, 11, '27.89', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(532, 'AJBAJK', '212', 46, 12, '30.88', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(533, 'AJBAJK', '212', 46, 13, '33.96', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(534, 'AJBAJK', '212', 46, 14, '37.11', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(535, 'AJBAJK', '212', 46, 15, '40.33', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(536, 'AJBAJK', '212', 46, 16, '43.59', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(537, 'AJBAJK', '212', 46, 17, '46.91', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(538, 'AJBAJK', '212', 46, 18, '50.26', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(539, 'AJBAJK', '212', 46, 19, '53.66', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(540, 'AJBAJK', '212', 46, 20, '57.05', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(541, 'AJBAJK', '212', 47, 1, '2.90', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(542, 'AJBAJK', '212', 47, 2, '5.00', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(543, 'AJBAJK', '212', 47, 3, '7.26', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(544, 'AJBAJK', '212', 47, 4, '9.67', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(545, 'AJBAJK', '212', 47, 5, '12.22', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(546, 'AJBAJK', '212', 47, 6, '14.91', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(547, 'AJBAJK', '212', 47, 7, '17.75', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(548, 'AJBAJK', '212', 47, 8, '20.72', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(549, 'AJBAJK', '212', 47, 9, '23.79', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(550, 'AJBAJK', '212', 47, 10, '26.94', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(551, 'AJBAJK', '212', 47, 11, '30.14', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(552, 'AJBAJK', '212', 47, 12, '33.37', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(553, 'AJBAJK', '212', 47, 13, '36.71', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(554, 'AJBAJK', '212', 47, 14, '40.13', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(555, 'AJBAJK', '212', 47, 15, '43.63', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(556, 'AJBAJK', '212', 47, 16, '47.18', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(557, 'AJBAJK', '212', 47, 17, '50.79', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(558, 'AJBAJK', '212', 47, 18, '54.45', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(559, 'AJBAJK', '212', 47, 19, '58.14', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(560, 'AJBAJK', '212', 47, 20, '61.80', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(561, 'AJBAJK', '212', 48, 1, '3.13', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(562, 'AJBAJK', '212', 48, 2, '5.41', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(563, 'AJBAJK', '212', 48, 3, '7.84', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(564, 'AJBAJK', '212', 48, 4, '10.45', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(565, 'AJBAJK', '212', 48, 5, '13.22', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(566, 'AJBAJK', '212', 48, 6, '16.14', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(567, 'AJBAJK', '212', 48, 7, '19.22', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(568, 'AJBAJK', '212', 48, 8, '22.43', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(569, 'AJBAJK', '212', 48, 9, '25.74', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(570, 'AJBAJK', '212', 48, 10, '29.14', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(571, 'AJBAJK', '212', 48, 11, '32.60', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(572, 'AJBAJK', '212', 48, 12, '36.11', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(573, 'AJBAJK', '212', 48, 13, '39.73', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(574, 'AJBAJK', '212', 48, 14, '43.45', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(575, 'AJBAJK', '212', 48, 15, '47.26', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(576, 'AJBAJK', '212', 48, 16, '51.13', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(577, 'AJBAJK', '212', 48, 17, '55.06', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(578, 'AJBAJK', '212', 48, 18, '59.03', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(579, 'AJBAJK', '212', 48, 19, '63.01', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(580, 'AJBAJK', '212', 48, 20, '66.97', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(581, 'AJBAJK', '212', 49, 1, '3.39', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(582, 'AJBAJK', '212', 49, 2, '5.85', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(583, 'AJBAJK', '212', 49, 3, '8.48', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(584, 'AJBAJK', '212', 49, 4, '11.31', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(585, 'AJBAJK', '212', 49, 5, '14.32', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(586, 'AJBAJK', '212', 49, 6, '17.50', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(587, 'AJBAJK', '212', 49, 7, '20.81', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(588, 'AJBAJK', '212', 49, 8, '24.27', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(589, 'AJBAJK', '212', 49, 9, '27.85', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(590, 'AJBAJK', '212', 49, 10, '31.53', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(591, 'AJBAJK', '212', 49, 11, '35.28', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(592, 'AJBAJK', '212', 49, 12, '39.10', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(593, 'AJBAJK', '212', 49, 13, '43.04', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(594, 'AJBAJK', '212', 49, 14, '47.10', '2018-11-13 22:25:36', '2018-11-13 22:25:36');
INSERT INTO `master_insurance_rates` (`id`, `insurance_kind_id`, `bank_id`, `age`, `jw`, `rate`, `created_at`, `updated_at`) VALUES
(595, 'AJBAJK', '212', 49, 15, '51.25', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(596, 'AJBAJK', '212', 49, 16, '55.47', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(597, 'AJBAJK', '212', 49, 17, '59.74', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(598, 'AJBAJK', '212', 49, 18, '64.02', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(599, 'AJBAJK', '212', 49, 19, '68.32', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(600, 'AJBAJK', '212', 49, 20, '72.58', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(601, 'AJBAJK', '212', 50, 1, '3.65', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(602, 'AJBAJK', '212', 50, 2, '6.31', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(603, 'AJBAJK', '212', 50, 3, '9.18', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(604, 'AJBAJK', '212', 50, 4, '12.26', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(605, 'AJBAJK', '212', 50, 5, '15.53', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(606, 'AJBAJK', '212', 50, 6, '18.95', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(607, 'AJBAJK', '212', 50, 7, '22.53', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(608, 'AJBAJK', '212', 50, 8, '26.26', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(609, 'AJBAJK', '212', 50, 9, '30.13', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(610, 'AJBAJK', '212', 50, 10, '34.13', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(611, 'AJBAJK', '212', 50, 11, '38.21', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(612, 'AJBAJK', '212', 50, 12, '42.36', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(613, 'AJBAJK', '212', 50, 13, '46.67', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(614, 'AJBAJK', '212', 50, 14, '51.09', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(615, 'AJBAJK', '212', 50, 15, '55.62', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(616, 'AJBAJK', '212', 50, 16, '60.23', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(617, 'AJBAJK', '212', 50, 17, '64.84', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(618, 'AJBAJK', '212', 50, 18, '69.46', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(619, 'AJBAJK', '212', 50, 19, '74.09', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(620, 'AJBAJK', '212', 50, 20, '78.65', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(621, 'AJBAJK', '212', 51, 1, '3.97', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(622, 'AJBAJK', '212', 51, 2, '6.88', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(623, 'AJBAJK', '212', 51, 3, '10.01', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(624, 'AJBAJK', '212', 51, 4, '13.36', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(625, 'AJBAJK', '212', 51, 5, '16.87', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(626, 'AJBAJK', '212', 51, 6, '20.56', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(627, 'AJBAJK', '212', 51, 7, '24.41', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(628, 'AJBAJK', '212', 51, 8, '28.46', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(629, 'AJBAJK', '212', 51, 9, '32.67', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(630, 'AJBAJK', '212', 51, 10, '37.02', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(631, 'AJBAJK', '212', 51, 11, '41.47', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(632, 'AJBAJK', '212', 51, 12, '46.00', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(633, 'AJBAJK', '212', 51, 13, '50.70', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(634, 'AJBAJK', '212', 51, 14, '55.53', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(635, 'AJBAJK', '212', 51, 15, '60.45', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(636, 'AJBAJK', '212', 51, 16, '65.43', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(637, 'AJBAJK', '212', 51, 17, '70.41', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(638, 'AJBAJK', '212', 51, 18, '75.38', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(639, 'AJBAJK', '212', 51, 19, '80.35', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(640, 'AJBAJK', '212', 51, 20, '119.33', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(641, 'AJBAJK', '212', 52, 1, '4.34', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(642, 'AJBAJK', '212', 52, 2, '7.52', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(643, 'AJBAJK', '212', 52, 3, '10.91', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(644, 'AJBAJK', '212', 52, 4, '14.49', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(645, 'AJBAJK', '212', 52, 5, '18.27', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(646, 'AJBAJK', '212', 52, 6, '22.24', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(647, 'AJBAJK', '212', 52, 7, '26.42', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(648, 'AJBAJK', '212', 52, 8, '30.82', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(649, 'AJBAJK', '212', 52, 9, '35.41', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(650, 'AJBAJK', '212', 52, 10, '40.15', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(651, 'AJBAJK', '212', 52, 11, '45.01', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(652, 'AJBAJK', '212', 52, 12, '49.96', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(653, 'AJBAJK', '212', 52, 13, '55.10', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(654, 'AJBAJK', '212', 52, 14, '60.37', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(655, 'AJBAJK', '212', 52, 15, '65.70', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(656, 'AJBAJK', '212', 52, 16, '71.07', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(657, 'AJBAJK', '212', 52, 17, '76.44', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(658, 'AJBAJK', '212', 52, 18, '81.79', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(659, 'AJBAJK', '212', 52, 19, '121.95', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(660, 'AJBAJK', '212', 52, 20, '129.27', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(661, 'AJBAJK', '212', 53, 1, '4.75', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(662, 'AJBAJK', '212', 53, 2, '8.17', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(663, 'AJBAJK', '212', 53, 3, '11.79', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(664, 'AJBAJK', '212', 53, 4, '15.63', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(665, 'AJBAJK', '212', 53, 5, '19.70', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(666, 'AJBAJK', '212', 53, 6, '24.01', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(667, 'AJBAJK', '212', 53, 7, '28.55', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(668, 'AJBAJK', '212', 53, 8, '33.35', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(669, 'AJBAJK', '212', 53, 9, '38.35', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(670, 'AJBAJK', '212', 53, 10, '43.54', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(671, 'AJBAJK', '212', 53, 11, '48.85', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(672, 'AJBAJK', '212', 53, 12, '54.27', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(673, 'AJBAJK', '212', 53, 13, '59.93', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(674, 'AJBAJK', '212', 53, 14, '65.64', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(675, 'AJBAJK', '212', 53, 15, '71.39', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(676, 'AJBAJK', '212', 53, 16, '77.19', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(677, 'AJBAJK', '212', 53, 17, '82.96', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(678, 'AJBAJK', '212', 53, 18, '124.16', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(679, 'AJBAJK', '212', 53, 19, '132.13', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(680, 'AJBAJK', '212', 53, 20, '139.94', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(681, 'AJBAJK', '212', 54, 1, '5.05', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(682, 'AJBAJK', '212', 54, 2, '8.68', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(683, 'AJBAJK', '212', 54, 3, '12.55', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(684, 'AJBAJK', '212', 54, 4, '16.70', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(685, 'AJBAJK', '212', 54, 5, '21.12', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(686, 'AJBAJK', '212', 54, 6, '25.82', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(687, 'AJBAJK', '212', 54, 7, '30.78', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(688, 'AJBAJK', '212', 54, 8, '36.03', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(689, 'AJBAJK', '212', 54, 9, '41.50', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(690, 'AJBAJK', '212', 54, 10, '47.18', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(691, 'AJBAJK', '212', 54, 11, '52.99', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(692, 'AJBAJK', '212', 54, 12, '59.03', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(693, 'AJBAJK', '212', 54, 13, '65.16', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(694, 'AJBAJK', '212', 54, 14, '71.33', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(695, 'AJBAJK', '212', 54, 15, '77.54', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(696, 'AJBAJK', '212', 54, 16, '83.77', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(697, 'AJBAJK', '212', 54, 17, '125.94', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(698, 'AJBAJK', '212', 54, 18, '134.53', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(699, 'AJBAJK', '212', 54, 19, '143.05', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(700, 'AJBAJK', '212', 54, 20, '151.38', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(701, 'AJBAJK', '212', 55, 1, '5.36', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(702, 'AJBAJK', '212', 55, 2, '9.27', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(703, 'AJBAJK', '212', 55, 3, '13.47', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(704, 'AJBAJK', '212', 55, 4, '18.00', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(705, 'AJBAJK', '212', 55, 5, '22.84', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(706, 'AJBAJK', '212', 55, 6, '27.99', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(707, 'AJBAJK', '212', 55, 7, '33.43', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(708, 'AJBAJK', '212', 55, 8, '39.18', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(709, 'AJBAJK', '212', 55, 9, '45.19', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(710, 'AJBAJK', '212', 55, 10, '51.42', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(711, 'AJBAJK', '212', 55, 11, '57.62', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(712, 'AJBAJK', '212', 55, 12, '64.17', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(713, 'AJBAJK', '212', 55, 13, '70.79', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(714, 'AJBAJK', '212', 55, 14, '77.46', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(715, 'AJBAJK', '212', 55, 15, '84.14', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(716, 'AJBAJK', '212', 55, 16, '127.16', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(717, 'AJBAJK', '212', 55, 17, '136.44', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(718, 'AJBAJK', '212', 55, 18, '145.63', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(719, 'AJBAJK', '212', 55, 19, '154.72', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(720, 'AJBAJK', '212', 55, 20, '163.60', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(721, 'AJBAJK', '212', 56, 1, '5.83', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(722, 'AJBAJK', '212', 56, 2, '10.09', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(723, 'AJBAJK', '212', 56, 3, '14.70', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(724, 'AJBAJK', '212', 56, 4, '19.68', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(725, 'AJBAJK', '212', 56, 5, '25.00', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(726, 'AJBAJK', '212', 56, 6, '30.65', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(727, 'AJBAJK', '212', 56, 7, '36.64', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(728, 'AJBAJK', '212', 56, 8, '42.96', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(729, 'AJBAJK', '212', 56, 9, '49.56', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(730, 'AJBAJK', '212', 56, 10, '55.89', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(731, 'AJBAJK', '212', 56, 11, '62.62', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(732, 'AJBAJK', '212', 56, 12, '69.71', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(733, 'AJBAJK', '212', 56, 13, '76.87', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(734, 'AJBAJK', '212', 56, 14, '84.05', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(735, 'AJBAJK', '212', 56, 15, '127.72', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(736, 'AJBAJK', '212', 56, 16, '137.76', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(737, 'AJBAJK', '212', 56, 17, '147.70', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(738, 'AJBAJK', '212', 56, 18, '157.51', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(739, 'AJBAJK', '212', 56, 19, '167.21', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(740, 'AJBAJK', '212', 56, 20, '0.00', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(741, 'AJBAJK', '212', 57, 1, '6.36', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(742, 'AJBAJK', '212', 57, 2, '11.06', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(743, 'AJBAJK', '212', 57, 3, '16.14', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(744, 'AJBAJK', '212', 57, 4, '21.62', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(745, 'AJBAJK', '212', 57, 5, '27.48', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(746, 'AJBAJK', '212', 57, 6, '33.70', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(747, 'AJBAJK', '212', 57, 7, '40.29', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(748, 'AJBAJK', '212', 57, 8, '47.25', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(749, 'AJBAJK', '212', 57, 9, '53.87', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(750, 'AJBAJK', '212', 57, 10, '60.74', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(751, 'AJBAJK', '212', 57, 11, '68.04', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(752, 'AJBAJK', '212', 57, 12, '75.70', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(753, 'AJBAJK', '212', 57, 13, '83.42', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(754, 'AJBAJK', '212', 57, 14, '127.60', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(755, 'AJBAJK', '212', 57, 15, '138.37', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(756, 'AJBAJK', '212', 57, 16, '149.13', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(757, 'AJBAJK', '212', 57, 17, '159.76', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(758, 'AJBAJK', '212', 57, 18, '170.24', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(759, 'AJBAJK', '212', 57, 19, '0.00', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(760, 'AJBAJK', '212', 57, 20, '0.00', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(761, 'AJBAJK', '212', 58, 1, '7.07', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(762, 'AJBAJK', '212', 58, 2, '12.24', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(763, 'AJBAJK', '212', 58, 3, '17.84', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(764, 'AJBAJK', '212', 58, 4, '23.87', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(765, 'AJBAJK', '212', 58, 5, '30.32', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(766, 'AJBAJK', '212', 58, 6, '37.18', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(767, 'AJBAJK', '212', 58, 7, '44.43', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(768, 'AJBAJK', '212', 58, 8, '51.38', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(769, 'AJBAJK', '212', 58, 9, '58.57', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(770, 'AJBAJK', '212', 58, 10, '66.03', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(771, 'AJBAJK', '212', 58, 11, '73.92', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(772, 'AJBAJK', '212', 58, 12, '82.19', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(773, 'AJBAJK', '212', 58, 13, '126.69', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(774, 'AJBAJK', '212', 58, 14, '138.30', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(775, 'AJBAJK', '212', 58, 15, '149.85', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(776, 'AJBAJK', '212', 58, 16, '161.37', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(777, 'AJBAJK', '212', 58, 17, '172.73', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(778, 'AJBAJK', '212', 58, 18, '0.00', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(779, 'AJBAJK', '212', 58, 19, '0.00', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(780, 'AJBAJK', '212', 58, 20, '0.00', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(781, 'AJBAJK', '212', 59, 1, '7.77', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(782, 'AJBAJK', '212', 59, 2, '13.46', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(783, 'AJBAJK', '212', 59, 3, '19.62', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(784, 'AJBAJK', '212', 59, 4, '26.27', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(785, 'AJBAJK', '212', 59, 5, '33.38', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(786, 'AJBAJK', '212', 59, 6, '40.93', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(787, 'AJBAJK', '212', 59, 7, '48.36', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(788, 'AJBAJK', '212', 59, 8, '55.92', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(789, 'AJBAJK', '212', 59, 9, '63.73', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(790, 'AJBAJK', '212', 59, 10, '71.81', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(791, 'AJBAJK', '212', 59, 11, '80.32', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(792, 'AJBAJK', '212', 59, 12, '124.92', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(793, 'AJBAJK', '212', 59, 13, '137.41', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(794, 'AJBAJK', '212', 59, 14, '149.87', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(795, 'AJBAJK', '212', 59, 15, '162.25', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(796, 'AJBAJK', '212', 59, 16, '174.58', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(797, 'AJBAJK', '212', 59, 17, '0.00', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(798, 'AJBAJK', '212', 59, 18, '0.00', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(799, 'AJBAJK', '212', 59, 19, '0.00', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(800, 'AJBAJK', '212', 59, 20, '0.00', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(801, 'AJBAJK', '212', 60, 1, '8.55', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(802, 'AJBAJK', '212', 60, 2, '14.82', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(803, 'AJBAJK', '212', 60, 3, '21.62', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(804, 'AJBAJK', '212', 60, 4, '28.96', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(805, 'AJBAJK', '212', 60, 5, '36.78', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(806, 'AJBAJK', '212', 60, 6, '44.62', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(807, 'AJBAJK', '212', 60, 7, '52.72', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(808, 'AJBAJK', '212', 60, 8, '60.93', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(809, 'AJBAJK', '212', 60, 9, '69.39', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(810, 'AJBAJK', '212', 60, 10, '78.12', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(811, 'AJBAJK', '212', 60, 11, '122.21', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(812, 'AJBAJK', '212', 60, 12, '135.62', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(813, 'AJBAJK', '212', 60, 13, '149.04', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(814, 'AJBAJK', '212', 60, 14, '162.40', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(815, 'AJBAJK', '212', 60, 15, '175.66', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(816, 'AJBAJK', '212', 60, 16, '0.00', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(817, 'AJBAJK', '212', 60, 17, '0.00', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(818, 'AJBAJK', '212', 60, 18, '0.00', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(819, 'AJBAJK', '212', 60, 19, '0.00', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(820, 'AJBAJK', '212', 60, 20, '0.00', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(821, 'AJBAJK', '212', 61, 1, '9.43', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(822, 'AJBAJK', '212', 61, 2, '16.37', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(823, 'AJBAJK', '212', 61, 3, '23.88', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(824, 'AJBAJK', '212', 61, 4, '31.95', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(825, 'AJBAJK', '212', 61, 5, '40.18', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(826, 'AJBAJK', '212', 61, 6, '48.73', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(827, 'AJBAJK', '212', 61, 7, '57.53', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(828, 'AJBAJK', '212', 61, 8, '66.44', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(829, 'AJBAJK', '212', 61, 9, '75.58', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(830, 'AJBAJK', '212', 61, 10, '118.98', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(831, 'AJBAJK', '212', 61, 11, '132.80', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(832, 'AJBAJK', '212', 61, 12, '147.22', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(833, 'AJBAJK', '212', 61, 13, '161.63', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(834, 'AJBAJK', '212', 61, 14, '175.95', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(835, 'AJBAJK', '212', 61, 15, '0.00', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(836, 'AJBAJK', '212', 61, 16, '0.00', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(837, 'AJBAJK', '212', 61, 17, '0.00', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(838, 'AJBAJK', '212', 61, 18, '0.00', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(839, 'AJBAJK', '212', 61, 19, '0.00', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(840, 'AJBAJK', '212', 61, 20, '0.00', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(841, 'AJBAJK', '212', 62, 1, '10.47', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(842, 'AJBAJK', '212', 62, 2, '18.12', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(843, 'AJBAJK', '212', 62, 3, '26.37', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(844, 'AJBAJK', '212', 62, 4, '34.97', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(845, 'AJBAJK', '212', 62, 5, '43.96', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(846, 'AJBAJK', '212', 62, 6, '53.26', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(847, 'AJBAJK', '212', 62, 7, '62.82', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(848, 'AJBAJK', '212', 62, 8, '72.45', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(849, 'AJBAJK', '212', 62, 9, '115.23', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(850, 'AJBAJK', '212', 62, 10, '129.40', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(851, 'AJBAJK', '212', 62, 11, '144.28', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(852, 'AJBAJK', '212', 62, 12, '159.77', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(853, 'AJBAJK', '212', 62, 13, '175.24', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(854, 'AJBAJK', '212', 62, 14, '0.00', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(855, 'AJBAJK', '212', 62, 15, '0.00', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(856, 'AJBAJK', '212', 62, 16, '0.00', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(857, 'AJBAJK', '212', 62, 17, '0.00', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(858, 'AJBAJK', '212', 62, 18, '0.00', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(859, 'AJBAJK', '212', 62, 19, '0.00', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(860, 'AJBAJK', '212', 62, 20, '0.00', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(861, 'AJBAJK', '212', 63, 1, '11.49', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(862, 'AJBAJK', '212', 63, 2, '19.90', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(863, 'AJBAJK', '212', 63, 3, '28.92', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(864, 'AJBAJK', '212', 63, 4, '38.33', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(865, 'AJBAJK', '212', 63, 5, '48.11', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(866, 'AJBAJK', '212', 63, 6, '58.22', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(867, 'AJBAJK', '212', 63, 7, '68.56', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(868, 'AJBAJK', '212', 63, 8, '110.54', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(869, 'AJBAJK', '212', 63, 9, '125.41', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(870, 'AJBAJK', '212', 63, 10, '140.67', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(871, 'AJBAJK', '212', 63, 11, '156.66', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(872, 'AJBAJK', '212', 63, 12, '173.32', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(873, 'AJBAJK', '212', 63, 13, '0.00', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(874, 'AJBAJK', '212', 63, 14, '0.00', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(875, 'AJBAJK', '212', 63, 15, '0.00', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(876, 'AJBAJK', '212', 63, 16, '0.00', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(877, 'AJBAJK', '212', 63, 17, '0.00', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(878, 'AJBAJK', '212', 63, 18, '0.00', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(879, 'AJBAJK', '212', 63, 19, '0.00', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(880, 'AJBAJK', '212', 63, 20, '0.00', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(881, 'AJBAJK', '212', 64, 1, '12.62', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(882, 'AJBAJK', '212', 64, 2, '21.85', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(883, 'AJBAJK', '212', 64, 3, '31.72', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(884, 'AJBAJK', '212', 64, 4, '41.98', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(885, 'AJBAJK', '212', 64, 5, '52.61', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(886, 'AJBAJK', '212', 64, 6, '63.56', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(887, 'AJBAJK', '212', 64, 7, '104.63', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(888, 'AJBAJK', '212', 64, 8, '120.32', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(889, 'AJBAJK', '212', 64, 9, '136.35', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(890, 'AJBAJK', '212', 64, 10, '152.78', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(891, 'AJBAJK', '212', 64, 11, '169.99', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(892, 'AJBAJK', '212', 64, 12, '0.00', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(893, 'AJBAJK', '212', 64, 13, '0.00', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(894, 'AJBAJK', '212', 64, 14, '0.00', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(895, 'AJBAJK', '212', 64, 15, '0.00', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(896, 'AJBAJK', '212', 64, 16, '0.00', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(897, 'AJBAJK', '212', 64, 17, '0.00', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(898, 'AJBAJK', '212', 64, 18, '0.00', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(899, 'AJBAJK', '212', 64, 19, '0.00', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(900, 'AJBAJK', '212', 64, 20, '0.00', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(901, 'AJBAJK', '212', 65, 1, '13.87', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(902, 'AJBAJK', '212', 65, 2, '23.97', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(903, 'AJBAJK', '212', 65, 3, '34.74', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(904, 'AJBAJK', '212', 65, 4, '45.90', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(905, 'AJBAJK', '212', 65, 5, '57.43', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(906, 'AJBAJK', '212', 65, 6, '96.97', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(907, 'AJBAJK', '212', 65, 7, '113.87', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(908, 'AJBAJK', '212', 65, 8, '130.80', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(909, 'AJBAJK', '212', 65, 9, '148.10', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(910, 'AJBAJK', '212', 65, 10, '165.80', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(911, 'AJBAJK', '212', 65, 11, '0.00', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(912, 'AJBAJK', '212', 65, 12, '0.00', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(913, 'AJBAJK', '212', 65, 13, '0.00', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(914, 'AJBAJK', '212', 65, 14, '0.00', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(915, 'AJBAJK', '212', 65, 15, '0.00', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(916, 'AJBAJK', '212', 65, 16, '0.00', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(917, 'AJBAJK', '212', 65, 17, '0.00', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(918, 'AJBAJK', '212', 65, 18, '0.00', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(919, 'AJBAJK', '212', 65, 19, '0.00', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(920, 'AJBAJK', '212', 65, 20, '0.00', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(921, 'AJBAJK', '212', 66, 1, '15.19', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(922, 'AJBAJK', '212', 66, 2, '26.23', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(923, 'AJBAJK', '212', 66, 3, '37.95', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(924, 'AJBAJK', '212', 66, 4, '50.06', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(925, 'AJBAJK', '212', 66, 5, '87.56', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(926, 'AJBAJK', '212', 66, 6, '105.49', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(927, 'AJBAJK', '212', 66, 7, '123.76', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(928, 'AJBAJK', '212', 66, 8, '142.06', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(929, 'AJBAJK', '212', 66, 9, '160.73', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(930, 'AJBAJK', '212', 66, 10, '0.00', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(931, 'AJBAJK', '212', 66, 11, '0.00', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(932, 'AJBAJK', '212', 66, 12, '0.00', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(933, 'AJBAJK', '212', 66, 13, '0.00', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(934, 'AJBAJK', '212', 66, 14, '0.00', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(935, 'AJBAJK', '212', 66, 15, '0.00', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(936, 'AJBAJK', '212', 66, 16, '0.00', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(937, 'AJBAJK', '212', 66, 17, '0.00', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(938, 'AJBAJK', '212', 66, 18, '0.00', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(939, 'AJBAJK', '212', 66, 19, '0.00', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(940, 'AJBAJK', '212', 66, 20, '0.00', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(941, 'AJBAJK', '212', 67, 1, '16.61', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(942, 'AJBAJK', '212', 67, 2, '28.63', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(943, 'AJBAJK', '212', 67, 3, '41.37', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(944, 'AJBAJK', '212', 67, 4, '76.29', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(945, 'AJBAJK', '212', 67, 5, '95.23', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(946, 'AJBAJK', '212', 67, 6, '114.66', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(947, 'AJBAJK', '212', 67, 7, '134.45', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(948, 'AJBAJK', '212', 67, 8, '154.25', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(949, 'AJBAJK', '212', 67, 9, '0.00', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(950, 'AJBAJK', '212', 67, 10, '0.00', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(951, 'AJBAJK', '212', 67, 11, '0.00', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(952, 'AJBAJK', '212', 67, 12, '0.00', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(953, 'AJBAJK', '212', 67, 13, '0.00', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(954, 'AJBAJK', '212', 67, 14, '0.00', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(955, 'AJBAJK', '212', 67, 15, '0.00', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(956, 'AJBAJK', '212', 67, 16, '0.00', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(957, 'AJBAJK', '212', 67, 17, '0.00', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(958, 'AJBAJK', '212', 67, 18, '0.00', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(959, 'AJBAJK', '212', 67, 19, '0.00', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(960, 'AJBAJK', '212', 67, 20, '0.00', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(961, 'AJBAJK', '212', 68, 1, '18.11', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(962, 'AJBAJK', '212', 68, 2, '31.18', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(963, 'AJBAJK', '212', 68, 3, '63.04', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(964, 'AJBAJK', '212', 68, 4, '83.00', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(965, 'AJBAJK', '212', 68, 5, '103.57', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(966, 'AJBAJK', '212', 68, 6, '124.66', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(967, 'AJBAJK', '212', 68, 7, '146.13', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(968, 'AJBAJK', '212', 68, 8, '0.00', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(969, 'AJBAJK', '212', 68, 9, '0.00', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(970, 'AJBAJK', '212', 68, 10, '0.00', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(971, 'AJBAJK', '212', 68, 11, '0.00', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(972, 'AJBAJK', '212', 68, 12, '0.00', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(973, 'AJBAJK', '212', 68, 13, '0.00', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(974, 'AJBAJK', '212', 68, 14, '0.00', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(975, 'AJBAJK', '212', 68, 15, '0.00', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(976, 'AJBAJK', '212', 68, 16, '0.00', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(977, 'AJBAJK', '212', 68, 17, '0.00', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(978, 'AJBAJK', '212', 68, 18, '0.00', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(979, 'AJBAJK', '212', 68, 19, '0.00', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(980, 'AJBAJK', '212', 68, 20, '0.00', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(981, 'AJBAJK', '212', 69, 1, '19.73', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(982, 'AJBAJK', '212', 69, 2, '47.57', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(983, 'AJBAJK', '212', 69, 3, '68.67', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(984, 'AJBAJK', '212', 69, 4, '90.41', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(985, 'AJBAJK', '212', 69, 5, '112.81', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(986, 'AJBAJK', '212', 69, 6, '135.74', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(987, 'AJBAJK', '212', 69, 7, '0.00', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(988, 'AJBAJK', '212', 69, 8, '0.00', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(989, 'AJBAJK', '212', 69, 9, '0.00', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(990, 'AJBAJK', '212', 69, 10, '0.00', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(991, 'AJBAJK', '212', 69, 11, '0.00', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(992, 'AJBAJK', '212', 69, 12, '0.00', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(993, 'AJBAJK', '212', 69, 13, '0.00', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(994, 'AJBAJK', '212', 69, 14, '0.00', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(995, 'AJBAJK', '212', 69, 15, '0.00', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(996, 'AJBAJK', '212', 69, 16, '0.00', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(997, 'AJBAJK', '212', 69, 17, '0.00', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(998, 'AJBAJK', '212', 69, 18, '0.00', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(999, 'AJBAJK', '212', 69, 19, '0.00', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(1000, 'AJBAJK', '212', 69, 20, '0.00', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(1001, 'AJBAJK', '212', 70, 1, '30.18', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(1002, 'AJBAJK', '212', 70, 2, '51.96', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(1003, 'AJBAJK', '212', 70, 3, '75.01', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(1004, 'AJBAJK', '212', 70, 4, '98.75', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(1005, 'AJBAJK', '212', 70, 5, '123.17', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(1006, 'AJBAJK', '212', 70, 6, '0.00', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(1007, 'AJBAJK', '212', 70, 7, '0.00', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(1008, 'AJBAJK', '212', 70, 8, '0.00', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(1009, 'AJBAJK', '212', 70, 9, '0.00', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(1010, 'AJBAJK', '212', 70, 10, '0.00', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(1011, 'AJBAJK', '212', 70, 11, '0.00', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(1012, 'AJBAJK', '212', 70, 12, '0.00', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(1013, 'AJBAJK', '212', 70, 13, '0.00', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(1014, 'AJBAJK', '212', 70, 14, '0.00', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(1015, 'AJBAJK', '212', 70, 15, '0.00', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(1016, 'AJBAJK', '212', 70, 16, '0.00', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(1017, 'AJBAJK', '212', 70, 17, '0.00', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(1018, 'AJBAJK', '212', 70, 18, '0.00', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(1019, 'AJBAJK', '212', 70, 19, '0.00', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(1020, 'AJBAJK', '212', 70, 20, '0.00', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(1021, 'AJBAJK', '212', 71, 1, '33.07', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(1022, 'AJBAJK', '212', 71, 2, '56.94', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(1023, 'AJBAJK', '212', 71, 3, '82.21', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(1024, 'AJBAJK', '212', 71, 4, '108.18', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(1025, 'AJBAJK', '212', 71, 5, '0.00', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(1026, 'AJBAJK', '212', 71, 6, '0.00', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(1027, 'AJBAJK', '212', 71, 7, '0.00', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(1028, 'AJBAJK', '212', 71, 8, '0.00', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(1029, 'AJBAJK', '212', 71, 9, '0.00', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(1030, 'AJBAJK', '212', 71, 10, '0.00', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(1031, 'AJBAJK', '212', 71, 11, '0.00', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(1032, 'AJBAJK', '212', 71, 12, '0.00', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(1033, 'AJBAJK', '212', 71, 13, '0.00', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(1034, 'AJBAJK', '212', 71, 14, '0.00', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(1035, 'AJBAJK', '212', 71, 15, '0.00', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(1036, 'AJBAJK', '212', 71, 16, '0.00', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(1037, 'AJBAJK', '212', 71, 17, '0.00', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(1038, 'AJBAJK', '212', 71, 18, '0.00', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(1039, 'AJBAJK', '212', 71, 19, '0.00', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(1040, 'AJBAJK', '212', 71, 20, '0.00', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(1041, 'AJBAJK', '212', 72, 1, '36.39', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(1042, 'AJBAJK', '212', 72, 2, '62.65', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(1043, 'AJBAJK', '212', 72, 3, '90.38', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(1044, 'AJBAJK', '212', 72, 4, '0.00', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(1045, 'AJBAJK', '212', 72, 5, '0.00', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(1046, 'AJBAJK', '212', 72, 6, '0.00', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(1047, 'AJBAJK', '212', 72, 7, '0.00', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(1048, 'AJBAJK', '212', 72, 8, '0.00', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(1049, 'AJBAJK', '212', 72, 9, '0.00', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(1050, 'AJBAJK', '212', 72, 10, '0.00', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(1051, 'AJBAJK', '212', 72, 11, '0.00', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(1052, 'AJBAJK', '212', 72, 12, '0.00', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(1053, 'AJBAJK', '212', 72, 13, '0.00', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(1054, 'AJBAJK', '212', 72, 14, '0.00', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(1055, 'AJBAJK', '212', 72, 15, '0.00', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(1056, 'AJBAJK', '212', 72, 16, '0.00', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(1057, 'AJBAJK', '212', 72, 17, '0.00', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(1058, 'AJBAJK', '212', 72, 18, '0.00', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(1059, 'AJBAJK', '212', 72, 19, '0.00', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(1060, 'AJBAJK', '212', 72, 20, '0.00', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(1061, 'AJBAJK', '212', 73, 1, '40.20', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(1062, 'AJBAJK', '212', 73, 2, '69.13', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(1063, 'AJBAJK', '212', 73, 3, '0.00', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(1064, 'AJBAJK', '212', 73, 4, '0.00', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(1065, 'AJBAJK', '212', 73, 5, '0.00', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(1066, 'AJBAJK', '212', 73, 6, '0.00', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(1067, 'AJBAJK', '212', 73, 7, '0.00', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(1068, 'AJBAJK', '212', 73, 8, '0.00', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(1069, 'AJBAJK', '212', 73, 9, '0.00', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(1070, 'AJBAJK', '212', 73, 10, '0.00', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(1071, 'AJBAJK', '212', 73, 11, '0.00', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(1072, 'AJBAJK', '212', 73, 12, '0.00', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(1073, 'AJBAJK', '212', 73, 13, '0.00', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(1074, 'AJBAJK', '212', 73, 14, '0.00', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(1075, 'AJBAJK', '212', 73, 15, '0.00', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(1076, 'AJBAJK', '212', 73, 16, '0.00', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(1077, 'AJBAJK', '212', 73, 17, '0.00', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(1078, 'AJBAJK', '212', 73, 18, '0.00', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(1079, 'AJBAJK', '212', 73, 19, '0.00', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(1080, 'AJBAJK', '212', 73, 20, '0.00', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(1081, 'AJBAJK', '212', 74, 1, '44.44', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(1082, 'AJBAJK', '212', 74, 2, '0.00', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(1083, 'AJBAJK', '212', 74, 3, '0.00', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(1084, 'AJBAJK', '212', 74, 4, '0.00', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(1085, 'AJBAJK', '212', 74, 5, '0.00', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(1086, 'AJBAJK', '212', 74, 6, '0.00', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(1087, 'AJBAJK', '212', 74, 7, '0.00', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(1088, 'AJBAJK', '212', 74, 8, '0.00', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(1089, 'AJBAJK', '212', 74, 9, '0.00', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(1090, 'AJBAJK', '212', 74, 10, '0.00', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(1091, 'AJBAJK', '212', 74, 11, '0.00', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(1092, 'AJBAJK', '212', 74, 12, '0.00', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(1093, 'AJBAJK', '212', 74, 13, '0.00', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(1094, 'AJBAJK', '212', 74, 14, '0.00', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(1095, 'AJBAJK', '212', 74, 15, '0.00', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(1096, 'AJBAJK', '212', 74, 16, '0.00', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(1097, 'AJBAJK', '212', 74, 17, '0.00', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(1098, 'AJBAJK', '212', 74, 18, '0.00', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(1099, 'AJBAJK', '212', 74, 19, '45.09', '2018-11-13 22:25:36', '2018-11-15 15:25:27'),
(1100, 'AJBAJK', '212', 12, 13, '14.00', '2018-11-13 22:25:36', '2019-03-22 05:19:42'),
(1101, 'AJBAJK', '008', 20, 1, '0.79', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(1102, 'AJBAJK', '008', 20, 2, '1.34', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(1103, 'AJBAJK', '008', 20, 3, '1.90', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(1104, 'AJBAJK', '008', 20, 4, '2.48', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(1105, 'AJBAJK', '008', 20, 5, '3.06', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(1106, 'AJBAJK', '008', 20, 6, '3.65', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(1107, 'AJBAJK', '008', 20, 7, '4.24', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(1108, 'AJBAJK', '008', 20, 8, '4.84', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(1109, 'AJBAJK', '008', 20, 9, '5.44', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(1110, 'AJBAJK', '008', 20, 10, '6.03', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(1111, 'AJBAJK', '008', 20, 11, '6.62', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(1112, 'AJBAJK', '008', 20, 12, '7.19', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(1113, 'AJBAJK', '008', 20, 13, '7.76', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(1114, 'AJBAJK', '008', 20, 14, '8.32', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(1115, 'AJBAJK', '008', 20, 15, '8.89', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(1116, 'AJBAJK', '008', 20, 16, '9.44', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(1117, 'AJBAJK', '008', 20, 17, '9.99', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(1118, 'AJBAJK', '008', 20, 18, '10.53', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(1119, 'AJBAJK', '008', 20, 19, '11.07', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(1120, 'AJBAJK', '008', 20, 20, '11.61', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(1121, 'AJBAJK', '008', 21, 1, '0.79', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(1122, 'AJBAJK', '008', 21, 2, '1.34', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(1123, 'AJBAJK', '008', 21, 3, '1.90', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(1124, 'AJBAJK', '008', 21, 4, '2.48', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(1125, 'AJBAJK', '008', 21, 5, '3.06', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(1126, 'AJBAJK', '008', 21, 6, '3.65', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(1127, 'AJBAJK', '008', 21, 7, '4.24', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(1128, 'AJBAJK', '008', 21, 8, '4.85', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(1129, 'AJBAJK', '008', 21, 9, '5.45', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(1130, 'AJBAJK', '008', 21, 10, '6.05', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(1131, 'AJBAJK', '008', 21, 11, '6.64', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(1132, 'AJBAJK', '008', 21, 12, '7.21', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(1133, 'AJBAJK', '008', 21, 13, '7.79', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(1134, 'AJBAJK', '008', 21, 14, '8.37', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(1135, 'AJBAJK', '008', 21, 15, '8.94', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(1136, 'AJBAJK', '008', 21, 16, '9.51', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(1137, 'AJBAJK', '008', 21, 17, '10.07', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(1138, 'AJBAJK', '008', 21, 18, '10.63', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(1139, 'AJBAJK', '008', 21, 19, '11.19', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(1140, 'AJBAJK', '008', 21, 20, '11.75', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(1141, 'AJBAJK', '008', 22, 1, '0.79', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(1142, 'AJBAJK', '008', 22, 2, '1.34', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(1143, 'AJBAJK', '008', 22, 3, '1.90', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(1144, 'AJBAJK', '008', 22, 4, '2.48', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(1145, 'AJBAJK', '008', 22, 5, '3.06', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(1146, 'AJBAJK', '008', 22, 6, '3.65', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(1147, 'AJBAJK', '008', 22, 7, '4.25', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(1148, 'AJBAJK', '008', 22, 8, '4.85', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(1149, 'AJBAJK', '008', 22, 9, '5.46', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(1150, 'AJBAJK', '008', 22, 10, '6.07', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(1151, 'AJBAJK', '008', 22, 11, '6.66', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(1152, 'AJBAJK', '008', 22, 12, '7.25', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(1153, 'AJBAJK', '008', 22, 13, '7.84', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(1154, 'AJBAJK', '008', 22, 14, '8.43', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(1155, 'AJBAJK', '008', 22, 15, '9.02', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(1156, 'AJBAJK', '008', 22, 16, '9.60', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(1157, 'AJBAJK', '008', 22, 17, '10.19', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(1158, 'AJBAJK', '008', 22, 18, '10.77', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(1159, 'AJBAJK', '008', 22, 19, '11.35', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(1160, 'AJBAJK', '008', 22, 20, '11.94', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(1161, 'AJBAJK', '008', 23, 1, '0.79', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(1162, 'AJBAJK', '008', 23, 2, '1.34', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(1163, 'AJBAJK', '008', 23, 3, '1.90', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(1164, 'AJBAJK', '008', 23, 4, '2.48', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(1165, 'AJBAJK', '008', 23, 5, '3.06', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(1166, 'AJBAJK', '008', 23, 6, '3.66', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(1167, 'AJBAJK', '008', 23, 7, '4.26', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(1168, 'AJBAJK', '008', 23, 8, '4.87', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(1169, 'AJBAJK', '008', 23, 9, '5.49', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(1170, 'AJBAJK', '008', 23, 10, '6.10', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(1171, 'AJBAJK', '008', 23, 11, '6.71', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(1172, 'AJBAJK', '008', 23, 12, '7.31', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(1173, 'AJBAJK', '008', 23, 13, '7.91', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(1174, 'AJBAJK', '008', 23, 14, '8.52', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(1175, 'AJBAJK', '008', 23, 15, '9.13', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(1176, 'AJBAJK', '008', 23, 16, '9.74', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(1177, 'AJBAJK', '008', 23, 17, '10.35', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(1178, 'AJBAJK', '008', 23, 18, '10.96', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(1179, 'AJBAJK', '008', 23, 19, '11.57', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(1180, 'AJBAJK', '008', 23, 20, '12.18', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(1181, 'AJBAJK', '008', 24, 1, '0.79', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(1182, 'AJBAJK', '008', 24, 2, '1.34', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(1183, 'AJBAJK', '008', 24, 3, '1.90', '2018-11-13 22:25:36', '2018-11-13 22:25:36');
INSERT INTO `master_insurance_rates` (`id`, `insurance_kind_id`, `bank_id`, `age`, `jw`, `rate`, `created_at`, `updated_at`) VALUES
(1184, 'AJBAJK', '008', 24, 4, '2.48', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(1185, 'AJBAJK', '008', 24, 5, '3.07', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(1186, 'AJBAJK', '008', 24, 6, '3.67', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(1187, 'AJBAJK', '008', 24, 7, '4.28', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(1188, 'AJBAJK', '008', 24, 8, '4.90', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(1189, 'AJBAJK', '008', 24, 9, '5.53', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(1190, 'AJBAJK', '008', 24, 10, '6.16', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(1191, 'AJBAJK', '008', 24, 11, '6.77', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(1192, 'AJBAJK', '008', 24, 12, '7.39', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(1193, 'AJBAJK', '008', 24, 13, '8.01', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(1194, 'AJBAJK', '008', 24, 14, '8.64', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(1195, 'AJBAJK', '008', 24, 15, '9.28', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(1196, 'AJBAJK', '008', 24, 16, '9.92', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(1197, 'AJBAJK', '008', 24, 17, '10.56', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(1198, 'AJBAJK', '008', 24, 18, '11.20', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(1199, 'AJBAJK', '008', 24, 19, '11.84', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(1200, 'AJBAJK', '008', 24, 20, '12.49', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(1201, 'AJBAJK', '008', 25, 1, '0.79', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(1202, 'AJBAJK', '008', 25, 2, '1.34', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(1203, 'AJBAJK', '008', 25, 3, '1.90', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(1204, 'AJBAJK', '008', 25, 4, '2.49', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(1205, 'AJBAJK', '008', 25, 5, '3.08', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(1206, 'AJBAJK', '008', 25, 6, '3.70', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(1207, 'AJBAJK', '008', 25, 7, '4.32', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(1208, 'AJBAJK', '008', 25, 8, '4.95', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(1209, 'AJBAJK', '008', 25, 9, '5.59', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(1210, 'AJBAJK', '008', 25, 10, '6.23', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(1211, 'AJBAJK', '008', 25, 11, '6.87', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(1212, 'AJBAJK', '008', 25, 12, '7.51', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(1213, 'AJBAJK', '008', 25, 13, '8.16', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(1214, 'AJBAJK', '008', 25, 14, '8.82', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(1215, 'AJBAJK', '008', 25, 15, '9.49', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(1216, 'AJBAJK', '008', 25, 16, '10.16', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(1217, 'AJBAJK', '008', 25, 17, '10.83', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(1218, 'AJBAJK', '008', 25, 18, '11.51', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(1219, 'AJBAJK', '008', 25, 19, '12.19', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(1220, 'AJBAJK', '008', 25, 20, '12.87', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(1221, 'AJBAJK', '008', 26, 1, '0.79', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(1222, 'AJBAJK', '008', 26, 2, '1.34', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(1223, 'AJBAJK', '008', 26, 3, '1.91', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(1224, 'AJBAJK', '008', 26, 4, '2.51', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(1225, 'AJBAJK', '008', 26, 5, '3.12', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(1226, 'AJBAJK', '008', 26, 6, '3.74', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(1227, 'AJBAJK', '008', 26, 7, '4.38', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(1228, 'AJBAJK', '008', 26, 8, '5.03', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(1229, 'AJBAJK', '008', 26, 9, '5.68', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(1230, 'AJBAJK', '008', 26, 10, '6.34', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(1231, 'AJBAJK', '008', 26, 11, '7.01', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(1232, 'AJBAJK', '008', 26, 12, '7.68', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(1233, 'AJBAJK', '008', 26, 13, '8.36', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(1234, 'AJBAJK', '008', 26, 14, '9.06', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(1235, 'AJBAJK', '008', 26, 15, '9.76', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(1236, 'AJBAJK', '008', 26, 16, '10.47', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(1237, 'AJBAJK', '008', 26, 17, '11.18', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(1238, 'AJBAJK', '008', 26, 18, '11.90', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(1239, 'AJBAJK', '008', 26, 19, '12.62', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(1240, 'AJBAJK', '008', 26, 20, '13.35', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(1241, 'AJBAJK', '008', 27, 1, '0.79', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(1242, 'AJBAJK', '008', 27, 2, '1.36', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(1243, 'AJBAJK', '008', 27, 3, '1.95', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(1244, 'AJBAJK', '008', 27, 4, '2.56', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(1245, 'AJBAJK', '008', 27, 5, '3.18', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(1246, 'AJBAJK', '008', 27, 6, '3.82', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(1247, 'AJBAJK', '008', 27, 7, '4.47', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(1248, 'AJBAJK', '008', 27, 8, '5.13', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(1249, 'AJBAJK', '008', 27, 9, '5.81', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(1250, 'AJBAJK', '008', 27, 10, '6.51', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(1251, 'AJBAJK', '008', 27, 11, '7.21', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(1252, 'AJBAJK', '008', 27, 12, '7.91', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(1253, 'AJBAJK', '008', 27, 13, '8.63', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(1254, 'AJBAJK', '008', 27, 14, '9.37', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(1255, 'AJBAJK', '008', 27, 15, '10.12', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(1256, 'AJBAJK', '008', 27, 16, '10.87', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(1257, 'AJBAJK', '008', 27, 17, '11.63', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(1258, 'AJBAJK', '008', 27, 18, '12.40', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(1259, 'AJBAJK', '008', 27, 19, '13.17', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(1260, 'AJBAJK', '008', 27, 20, '13.94', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(1261, 'AJBAJK', '008', 28, 1, '0.83', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(1262, 'AJBAJK', '008', 28, 2, '1.41', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(1263, 'AJBAJK', '008', 28, 3, '2.01', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(1264, 'AJBAJK', '008', 28, 4, '2.64', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(1265, 'AJBAJK', '008', 28, 5, '3.27', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(1266, 'AJBAJK', '008', 28, 6, '3.93', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(1267, 'AJBAJK', '008', 28, 7, '4.60', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(1268, 'AJBAJK', '008', 28, 8, '5.29', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(1269, 'AJBAJK', '008', 28, 9, '6.01', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(1270, 'AJBAJK', '008', 28, 10, '6.74', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(1271, 'AJBAJK', '008', 28, 11, '7.48', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(1272, 'AJBAJK', '008', 28, 12, '8.23', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(1273, 'AJBAJK', '008', 28, 13, '9.00', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(1274, 'AJBAJK', '008', 28, 14, '9.78', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(1275, 'AJBAJK', '008', 28, 15, '10.58', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(1276, 'AJBAJK', '008', 28, 16, '11.38', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(1277, 'AJBAJK', '008', 28, 17, '12.20', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(1278, 'AJBAJK', '008', 28, 18, '13.02', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(1279, 'AJBAJK', '008', 28, 19, '13.84', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(1280, 'AJBAJK', '008', 28, 20, '14.67', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(1281, 'AJBAJK', '008', 29, 1, '0.84', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(1282, 'AJBAJK', '008', 29, 2, '1.44', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(1283, 'AJBAJK', '008', 29, 3, '2.05', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(1284, 'AJBAJK', '008', 29, 4, '2.68', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(1285, 'AJBAJK', '008', 29, 5, '3.34', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(1286, 'AJBAJK', '008', 29, 6, '4.01', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(1287, 'AJBAJK', '008', 29, 7, '4.71', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(1288, 'AJBAJK', '008', 29, 8, '5.44', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(1289, 'AJBAJK', '008', 29, 9, '6.20', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(1290, 'AJBAJK', '008', 29, 10, '6.98', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(1291, 'AJBAJK', '008', 29, 11, '7.77', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(1292, 'AJBAJK', '008', 29, 12, '8.56', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(1293, 'AJBAJK', '008', 29, 13, '9.38', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(1294, 'AJBAJK', '008', 29, 14, '10.22', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(1295, 'AJBAJK', '008', 29, 15, '11.07', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(1296, 'AJBAJK', '008', 29, 16, '11.94', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(1297, 'AJBAJK', '008', 29, 17, '12.81', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(1298, 'AJBAJK', '008', 29, 18, '13.69', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(1299, 'AJBAJK', '008', 29, 19, '14.57', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(1300, 'AJBAJK', '008', 29, 20, '15.46', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(1301, 'AJBAJK', '008', 30, 1, '0.86', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(1302, 'AJBAJK', '008', 30, 2, '1.46', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(1303, 'AJBAJK', '008', 30, 3, '2.09', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(1304, 'AJBAJK', '008', 30, 4, '2.74', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(1305, 'AJBAJK', '008', 30, 5, '3.42', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(1306, 'AJBAJK', '008', 30, 6, '4.13', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(1307, 'AJBAJK', '008', 30, 7, '4.87', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(1308, 'AJBAJK', '008', 30, 8, '5.65', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(1309, 'AJBAJK', '008', 30, 9, '6.45', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(1310, 'AJBAJK', '008', 30, 10, '7.28', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(1311, 'AJBAJK', '008', 30, 11, '8.13', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(1312, 'AJBAJK', '008', 30, 12, '8.98', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(1313, 'AJBAJK', '008', 30, 13, '9.86', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(1314, 'AJBAJK', '008', 30, 14, '10.76', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(1315, 'AJBAJK', '008', 30, 15, '11.68', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(1316, 'AJBAJK', '008', 30, 16, '12.60', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(1317, 'AJBAJK', '008', 30, 17, '13.54', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(1318, 'AJBAJK', '008', 30, 18, '14.48', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(1319, 'AJBAJK', '008', 30, 19, '15.43', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(1320, 'AJBAJK', '008', 30, 20, '16.39', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(1321, 'AJBAJK', '008', 31, 1, '0.88', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(1322, 'AJBAJK', '008', 31, 2, '1.50', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(1323, 'AJBAJK', '008', 31, 3, '2.15', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(1324, 'AJBAJK', '008', 31, 4, '2.82', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(1325, 'AJBAJK', '008', 31, 5, '3.54', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(1326, 'AJBAJK', '008', 31, 6, '4.29', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(1327, 'AJBAJK', '008', 31, 7, '5.09', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(1328, 'AJBAJK', '008', 31, 8, '5.92', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(1329, 'AJBAJK', '008', 31, 9, '6.79', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(1330, 'AJBAJK', '008', 31, 10, '7.68', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(1331, 'AJBAJK', '008', 31, 11, '8.58', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(1332, 'AJBAJK', '008', 31, 12, '9.50', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(1333, 'AJBAJK', '008', 31, 13, '10.45', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(1334, 'AJBAJK', '008', 31, 14, '11.42', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(1335, 'AJBAJK', '008', 31, 15, '12.41', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(1336, 'AJBAJK', '008', 31, 16, '13.40', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(1337, 'AJBAJK', '008', 31, 17, '14.41', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(1338, 'AJBAJK', '008', 31, 18, '15.43', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(1339, 'AJBAJK', '008', 31, 19, '16.45', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(1340, 'AJBAJK', '008', 31, 20, '17.49', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(1341, 'AJBAJK', '008', 32, 1, '0.90', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(1342, 'AJBAJK', '008', 32, 2, '1.53', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(1343, 'AJBAJK', '008', 32, 3, '2.21', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(1344, 'AJBAJK', '008', 32, 4, '2.93', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(1345, 'AJBAJK', '008', 32, 5, '3.70', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(1346, 'AJBAJK', '008', 32, 6, '4.51', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(1347, 'AJBAJK', '008', 32, 7, '5.37', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(1348, 'AJBAJK', '008', 32, 8, '6.27', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(1349, 'AJBAJK', '008', 32, 9, '7.20', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(1350, 'AJBAJK', '008', 32, 10, '8.16', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(1351, 'AJBAJK', '008', 32, 11, '9.14', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(1352, 'AJBAJK', '008', 32, 12, '10.13', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(1353, 'AJBAJK', '008', 32, 13, '11.15', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(1354, 'AJBAJK', '008', 32, 14, '12.20', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(1355, 'AJBAJK', '008', 32, 15, '13.26', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(1356, 'AJBAJK', '008', 32, 16, '14.34', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(1357, 'AJBAJK', '008', 32, 17, '15.43', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(1358, 'AJBAJK', '008', 32, 18, '16.53', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(1359, 'AJBAJK', '008', 32, 19, '17.63', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(1360, 'AJBAJK', '008', 32, 20, '18.75', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(1361, 'AJBAJK', '008', 33, 1, '0.94', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(1362, 'AJBAJK', '008', 33, 2, '1.61', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(1363, 'AJBAJK', '008', 33, 3, '2.34', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(1364, 'AJBAJK', '008', 33, 4, '3.12', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(1365, 'AJBAJK', '008', 33, 5, '3.95', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(1366, 'AJBAJK', '008', 33, 6, '4.84', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(1367, 'AJBAJK', '008', 33, 7, '5.76', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(1368, 'AJBAJK', '008', 33, 8, '6.74', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(1369, 'AJBAJK', '008', 33, 9, '7.74', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(1370, 'AJBAJK', '008', 33, 10, '8.78', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(1371, 'AJBAJK', '008', 33, 11, '9.84', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(1372, 'AJBAJK', '008', 33, 12, '10.92', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(1373, 'AJBAJK', '008', 33, 13, '12.02', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(1374, 'AJBAJK', '008', 33, 14, '13.15', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(1375, 'AJBAJK', '008', 33, 15, '14.31', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(1376, 'AJBAJK', '008', 33, 16, '15.47', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(1377, 'AJBAJK', '008', 33, 17, '16.65', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(1378, 'AJBAJK', '008', 33, 18, '17.84', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(1379, 'AJBAJK', '008', 33, 19, '19.03', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(1380, 'AJBAJK', '008', 33, 20, '20.24', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(1381, 'AJBAJK', '008', 34, 1, '1.00', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(1382, 'AJBAJK', '008', 34, 2, '1.73', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(1383, 'AJBAJK', '008', 34, 3, '2.52', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(1384, 'AJBAJK', '008', 34, 4, '3.38', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(1385, 'AJBAJK', '008', 34, 5, '4.29', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(1386, 'AJBAJK', '008', 34, 6, '5.25', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(1387, 'AJBAJK', '008', 34, 7, '6.25', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(1388, 'AJBAJK', '008', 34, 8, '7.30', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(1389, 'AJBAJK', '008', 34, 9, '8.40', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(1390, 'AJBAJK', '008', 34, 10, '9.53', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(1391, 'AJBAJK', '008', 34, 11, '10.67', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(1392, 'AJBAJK', '008', 34, 12, '11.84', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(1393, 'AJBAJK', '008', 34, 13, '13.03', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(1394, 'AJBAJK', '008', 34, 14, '14.26', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(1395, 'AJBAJK', '008', 34, 15, '15.51', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(1396, 'AJBAJK', '008', 34, 16, '16.77', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(1397, 'AJBAJK', '008', 34, 17, '18.05', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(1398, 'AJBAJK', '008', 34, 18, '19.33', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(1399, 'AJBAJK', '008', 34, 19, '20.62', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(1400, 'AJBAJK', '008', 34, 20, '21.93', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(1401, 'AJBAJK', '008', 35, 1, '1.09', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(1402, 'AJBAJK', '008', 35, 2, '1.90', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(1403, 'AJBAJK', '008', 35, 3, '2.77', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(1404, 'AJBAJK', '008', 35, 4, '3.70', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(1405, 'AJBAJK', '008', 35, 5, '4.68', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(1406, 'AJBAJK', '008', 35, 6, '5.72', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(1407, 'AJBAJK', '008', 35, 7, '6.81', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(1408, 'AJBAJK', '008', 35, 8, '7.95', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(1409, 'AJBAJK', '008', 35, 9, '9.14', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(1410, 'AJBAJK', '008', 35, 10, '10.36', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(1411, 'AJBAJK', '008', 35, 11, '11.60', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(1412, 'AJBAJK', '008', 35, 12, '12.87', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(1413, 'AJBAJK', '008', 35, 13, '14.16', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(1414, 'AJBAJK', '008', 35, 14, '15.49', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(1415, 'AJBAJK', '008', 35, 15, '16.85', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(1416, 'AJBAJK', '008', 35, 16, '18.21', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(1417, 'AJBAJK', '008', 35, 17, '19.59', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(1418, 'AJBAJK', '008', 35, 18, '20.98', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(1419, 'AJBAJK', '008', 35, 19, '22.38', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(1420, 'AJBAJK', '008', 35, 20, '23.80', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(1421, 'AJBAJK', '008', 36, 1, '1.21', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(1422, 'AJBAJK', '008', 36, 2, '2.09', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(1423, 'AJBAJK', '008', 36, 3, '3.03', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(1424, 'AJBAJK', '008', 36, 4, '4.04', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(1425, 'AJBAJK', '008', 36, 5, '5.10', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(1426, 'AJBAJK', '008', 36, 6, '6.22', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(1427, 'AJBAJK', '008', 36, 7, '7.41', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(1428, 'AJBAJK', '008', 36, 8, '8.65', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(1429, 'AJBAJK', '008', 36, 9, '9.93', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(1430, 'AJBAJK', '008', 36, 10, '11.26', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(1431, 'AJBAJK', '008', 36, 11, '12.61', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(1432, 'AJBAJK', '008', 36, 12, '13.97', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(1433, 'AJBAJK', '008', 36, 13, '15.38', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(1434, 'AJBAJK', '008', 36, 14, '16.82', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(1435, 'AJBAJK', '008', 36, 15, '18.28', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(1436, 'AJBAJK', '008', 36, 16, '19.76', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(1437, 'AJBAJK', '008', 36, 17, '21.25', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(1438, 'AJBAJK', '008', 36, 18, '22.76', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(1439, 'AJBAJK', '008', 36, 19, '24.28', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(1440, 'AJBAJK', '008', 36, 20, '25.81', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(1441, 'AJBAJK', '008', 37, 1, '1.31', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(1442, 'AJBAJK', '008', 37, 2, '2.26', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(1443, 'AJBAJK', '008', 37, 3, '3.27', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(1444, 'AJBAJK', '008', 37, 4, '4.36', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(1445, 'AJBAJK', '008', 37, 5, '5.51', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(1446, 'AJBAJK', '008', 37, 6, '6.73', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(1447, 'AJBAJK', '008', 37, 7, '8.01', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(1448, 'AJBAJK', '008', 37, 8, '9.35', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(1449, 'AJBAJK', '008', 37, 9, '10.75', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(1450, 'AJBAJK', '008', 37, 10, '12.18', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(1451, 'AJBAJK', '008', 37, 11, '13.64', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(1452, 'AJBAJK', '008', 37, 12, '15.12', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(1453, 'AJBAJK', '008', 37, 13, '16.64', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(1454, 'AJBAJK', '008', 37, 14, '18.20', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(1455, 'AJBAJK', '008', 37, 15, '19.78', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(1456, 'AJBAJK', '008', 37, 16, '21.38', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(1457, 'AJBAJK', '008', 37, 17, '23.00', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(1458, 'AJBAJK', '008', 37, 18, '24.63', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(1459, 'AJBAJK', '008', 37, 19, '26.27', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(1460, 'AJBAJK', '008', 37, 20, '27.92', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(1461, 'AJBAJK', '008', 38, 1, '1.40', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(1462, 'AJBAJK', '008', 38, 2, '2.42', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(1463, 'AJBAJK', '008', 38, 3, '3.52', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(1464, 'AJBAJK', '008', 38, 4, '4.70', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(1465, 'AJBAJK', '008', 38, 5, '5.95', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(1466, 'AJBAJK', '008', 38, 6, '7.27', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(1467, 'AJBAJK', '008', 38, 7, '8.65', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(1468, 'AJBAJK', '008', 38, 8, '10.11', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(1469, 'AJBAJK', '008', 38, 9, '11.62', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(1470, 'AJBAJK', '008', 38, 10, '13.17', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(1471, 'AJBAJK', '008', 38, 11, '14.75', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(1472, 'AJBAJK', '008', 38, 12, '16.35', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(1473, 'AJBAJK', '008', 38, 13, '18.00', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(1474, 'AJBAJK', '008', 38, 14, '19.68', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(1475, 'AJBAJK', '008', 38, 15, '21.39', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(1476, 'AJBAJK', '008', 38, 16, '23.12', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(1477, 'AJBAJK', '008', 38, 17, '24.87', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(1478, 'AJBAJK', '008', 38, 18, '26.64', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(1479, 'AJBAJK', '008', 38, 19, '28.41', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(1480, 'AJBAJK', '008', 38, 20, '30.19', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(1481, 'AJBAJK', '008', 39, 1, '1.52', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(1482, 'AJBAJK', '008', 39, 2, '2.63', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(1483, 'AJBAJK', '008', 39, 3, '3.82', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(1484, 'AJBAJK', '008', 39, 4, '5.10', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(1485, 'AJBAJK', '008', 39, 5, '6.45', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(1486, 'AJBAJK', '008', 39, 6, '7.88', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(1487, 'AJBAJK', '008', 39, 7, '9.39', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(1488, 'AJBAJK', '008', 39, 8, '10.96', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(1489, 'AJBAJK', '008', 39, 9, '12.60', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(1490, 'AJBAJK', '008', 39, 10, '14.28', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(1491, 'AJBAJK', '008', 39, 11, '15.99', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(1492, 'AJBAJK', '008', 39, 12, '17.72', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(1493, 'AJBAJK', '008', 39, 13, '19.50', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(1494, 'AJBAJK', '008', 39, 14, '21.32', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(1495, 'AJBAJK', '008', 39, 15, '23.18', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(1496, 'AJBAJK', '008', 39, 16, '25.05', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(1497, 'AJBAJK', '008', 39, 17, '26.94', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(1498, 'AJBAJK', '008', 39, 18, '28.85', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(1499, 'AJBAJK', '008', 39, 19, '30.76', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(1500, 'AJBAJK', '008', 39, 20, '32.69', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(1501, 'AJBAJK', '008', 40, 1, '1.65', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(1502, 'AJBAJK', '008', 40, 2, '2.85', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(1503, 'AJBAJK', '008', 40, 3, '4.15', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(1504, 'AJBAJK', '008', 40, 4, '5.53', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(1505, 'AJBAJK', '008', 40, 5, '7.00', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(1506, 'AJBAJK', '008', 40, 6, '8.55', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(1507, 'AJBAJK', '008', 40, 7, '10.18', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(1508, 'AJBAJK', '008', 40, 8, '11.89', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(1509, 'AJBAJK', '008', 40, 9, '13.66', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(1510, 'AJBAJK', '008', 40, 10, '15.48', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(1511, 'AJBAJK', '008', 40, 11, '17.33', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(1512, 'AJBAJK', '008', 40, 12, '19.20', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(1513, 'AJBAJK', '008', 40, 13, '21.13', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(1514, 'AJBAJK', '008', 40, 14, '23.10', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(1515, 'AJBAJK', '008', 40, 15, '25.11', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(1516, 'AJBAJK', '008', 40, 16, '27.14', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(1517, 'AJBAJK', '008', 40, 17, '29.18', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(1518, 'AJBAJK', '008', 40, 18, '31.24', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(1519, 'AJBAJK', '008', 40, 19, '33.30', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(1520, 'AJBAJK', '008', 40, 20, '35.40', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(1521, 'AJBAJK', '008', 41, 1, '1.79', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(1522, 'AJBAJK', '008', 41, 2, '3.10', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(1523, 'AJBAJK', '008', 41, 3, '4.50', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(1524, 'AJBAJK', '008', 41, 4, '6.00', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(1525, 'AJBAJK', '008', 41, 5, '7.60', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(1526, 'AJBAJK', '008', 41, 6, '9.28', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(1527, 'AJBAJK', '008', 41, 7, '11.04', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(1528, 'AJBAJK', '008', 41, 8, '12.89', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(1529, 'AJBAJK', '008', 41, 9, '14.81', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(1530, 'AJBAJK', '008', 41, 10, '16.77', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(1531, 'AJBAJK', '008', 41, 11, '18.77', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(1532, 'AJBAJK', '008', 41, 12, '20.80', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(1533, 'AJBAJK', '008', 41, 13, '22.89', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(1534, 'AJBAJK', '008', 41, 14, '25.02', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(1535, 'AJBAJK', '008', 41, 15, '27.19', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(1536, 'AJBAJK', '008', 41, 16, '29.38', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(1537, 'AJBAJK', '008', 41, 17, '31.59', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(1538, 'AJBAJK', '008', 41, 18, '33.81', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(1539, 'AJBAJK', '008', 41, 19, '36.05', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(1540, 'AJBAJK', '008', 41, 20, '38.32', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(1541, 'AJBAJK', '008', 42, 1, '1.95', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(1542, 'AJBAJK', '008', 42, 2, '3.36', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(1543, 'AJBAJK', '008', 42, 3, '4.88', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(1544, 'AJBAJK', '008', 42, 4, '6.51', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(1545, 'AJBAJK', '008', 42, 5, '8.24', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(1546, 'AJBAJK', '008', 42, 6, '10.06', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(1547, 'AJBAJK', '008', 42, 7, '11.96', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(1548, 'AJBAJK', '008', 42, 8, '13.96', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(1549, 'AJBAJK', '008', 42, 9, '16.03', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(1550, 'AJBAJK', '008', 42, 10, '18.16', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(1551, 'AJBAJK', '008', 42, 11, '20.33', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(1552, 'AJBAJK', '008', 42, 12, '22.52', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(1553, 'AJBAJK', '008', 42, 13, '24.78', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(1554, 'AJBAJK', '008', 42, 14, '27.09', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(1555, 'AJBAJK', '008', 42, 15, '29.43', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(1556, 'AJBAJK', '008', 42, 16, '31.80', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(1557, 'AJBAJK', '008', 42, 17, '34.18', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(1558, 'AJBAJK', '008', 42, 18, '36.59', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(1559, 'AJBAJK', '008', 42, 19, '39.02', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(1560, 'AJBAJK', '008', 42, 20, '41.49', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(1561, 'AJBAJK', '008', 43, 1, '2.10', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(1562, 'AJBAJK', '008', 43, 2, '3.64', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(1563, 'AJBAJK', '008', 43, 3, '5.28', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(1564, 'AJBAJK', '008', 43, 4, '7.05', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(1565, 'AJBAJK', '008', 43, 5, '8.92', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(1566, 'AJBAJK', '008', 43, 6, '10.88', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(1567, 'AJBAJK', '008', 43, 7, '12.95', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(1568, 'AJBAJK', '008', 43, 8, '15.11', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(1569, 'AJBAJK', '008', 43, 9, '17.35', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(1570, 'AJBAJK', '008', 43, 10, '19.65', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(1571, 'AJBAJK', '008', 43, 11, '22.00', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(1572, 'AJBAJK', '008', 43, 12, '24.37', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(1573, 'AJBAJK', '008', 43, 13, '26.82', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(1574, 'AJBAJK', '008', 43, 14, '29.31', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(1575, 'AJBAJK', '008', 43, 15, '31.84', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(1576, 'AJBAJK', '008', 43, 16, '34.39', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(1577, 'AJBAJK', '008', 43, 17, '36.98', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(1578, 'AJBAJK', '008', 43, 18, '39.59', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(1579, 'AJBAJK', '008', 43, 19, '42.23', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(1580, 'AJBAJK', '008', 43, 20, '44.90', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(1581, 'AJBAJK', '008', 44, 1, '2.29', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(1582, 'AJBAJK', '008', 44, 2, '3.95', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(1583, 'AJBAJK', '008', 44, 3, '5.73', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(1584, 'AJBAJK', '008', 44, 4, '7.64', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(1585, 'AJBAJK', '008', 44, 5, '9.66', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(1586, 'AJBAJK', '008', 44, 6, '11.79', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(1587, 'AJBAJK', '008', 44, 7, '14.02', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(1588, 'AJBAJK', '008', 44, 8, '16.36', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(1589, 'AJBAJK', '008', 44, 9, '18.78', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(1590, 'AJBAJK', '008', 44, 10, '21.28', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(1591, 'AJBAJK', '008', 44, 11, '23.82', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(1592, 'AJBAJK', '008', 44, 12, '26.39', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(1593, 'AJBAJK', '008', 44, 13, '29.02', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(1594, 'AJBAJK', '008', 44, 14, '31.71', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(1595, 'AJBAJK', '008', 44, 15, '34.45', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(1596, 'AJBAJK', '008', 44, 16, '37.22', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(1597, 'AJBAJK', '008', 44, 17, '40.02', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(1598, 'AJBAJK', '008', 44, 18, '43.86', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(1599, 'AJBAJK', '008', 44, 19, '45.72', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(1600, 'AJBAJK', '008', 44, 20, '48.64', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(1601, 'AJBAJK', '008', 45, 1, '2.47', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(1602, 'AJBAJK', '008', 45, 2, '4.27', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(1603, 'AJBAJK', '008', 45, 3, '6.20', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(1604, 'AJBAJK', '008', 45, 4, '8.27', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(1605, 'AJBAJK', '008', 45, 5, '10.45', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(1606, 'AJBAJK', '008', 45, 6, '12.75', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(1607, 'AJBAJK', '008', 45, 7, '15.16', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(1608, 'AJBAJK', '008', 45, 8, '17.70', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(1609, 'AJBAJK', '008', 45, 9, '20.32', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(1610, 'AJBAJK', '008', 45, 10, '23.03', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(1611, 'AJBAJK', '008', 45, 11, '25.77', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(1612, 'AJBAJK', '008', 45, 12, '28.54', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(1613, 'AJBAJK', '008', 45, 13, '31.38', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(1614, 'AJBAJK', '008', 45, 14, '34.29', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(1615, 'AJBAJK', '008', 45, 15, '37.26', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(1616, 'AJBAJK', '008', 45, 16, '40.27', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(1617, 'AJBAJK', '008', 45, 17, '43.31', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(1618, 'AJBAJK', '008', 45, 18, '46.40', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(1619, 'AJBAJK', '008', 45, 19, '49.51', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(1620, 'AJBAJK', '008', 45, 20, '52.68', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(1621, 'AJBAJK', '008', 46, 1, '2.69', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(1622, 'AJBAJK', '008', 46, 2, '4.64', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(1623, 'AJBAJK', '008', 46, 3, '6.73', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(1624, 'AJBAJK', '008', 46, 4, '8.96', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(1625, 'AJBAJK', '008', 46, 5, '11.32', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(1626, 'AJBAJK', '008', 46, 6, '13.80', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(1627, 'AJBAJK', '008', 46, 7, '16.42', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(1628, 'AJBAJK', '008', 46, 8, '19.16', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(1629, 'AJBAJK', '008', 46, 9, '22.01', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(1630, 'AJBAJK', '008', 46, 10, '24.93', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(1631, 'AJBAJK', '008', 46, 11, '27.89', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(1632, 'AJBAJK', '008', 46, 12, '30.88', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(1633, 'AJBAJK', '008', 46, 13, '33.96', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(1634, 'AJBAJK', '008', 46, 14, '37.11', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(1635, 'AJBAJK', '008', 46, 15, '40.33', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(1636, 'AJBAJK', '008', 46, 16, '43.59', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(1637, 'AJBAJK', '008', 46, 17, '46.91', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(1638, 'AJBAJK', '008', 46, 18, '50.26', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(1639, 'AJBAJK', '008', 46, 19, '53.66', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(1640, 'AJBAJK', '008', 46, 20, '57.05', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(1641, 'AJBAJK', '008', 47, 1, '2.90', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(1642, 'AJBAJK', '008', 47, 2, '5.00', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(1643, 'AJBAJK', '008', 47, 3, '7.26', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(1644, 'AJBAJK', '008', 47, 4, '9.67', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(1645, 'AJBAJK', '008', 47, 5, '12.22', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(1646, 'AJBAJK', '008', 47, 6, '14.91', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(1647, 'AJBAJK', '008', 47, 7, '17.75', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(1648, 'AJBAJK', '008', 47, 8, '20.72', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(1649, 'AJBAJK', '008', 47, 9, '23.79', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(1650, 'AJBAJK', '008', 47, 10, '26.94', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(1651, 'AJBAJK', '008', 47, 11, '30.14', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(1652, 'AJBAJK', '008', 47, 12, '33.37', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(1653, 'AJBAJK', '008', 47, 13, '36.71', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(1654, 'AJBAJK', '008', 47, 14, '40.13', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(1655, 'AJBAJK', '008', 47, 15, '43.63', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(1656, 'AJBAJK', '008', 47, 16, '47.18', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(1657, 'AJBAJK', '008', 47, 17, '50.79', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(1658, 'AJBAJK', '008', 47, 18, '54.45', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(1659, 'AJBAJK', '008', 47, 19, '58.14', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(1660, 'AJBAJK', '008', 47, 20, '61.80', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(1661, 'AJBAJK', '008', 48, 1, '3.13', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(1662, 'AJBAJK', '008', 48, 2, '5.41', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(1663, 'AJBAJK', '008', 48, 3, '7.84', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(1664, 'AJBAJK', '008', 48, 4, '10.45', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(1665, 'AJBAJK', '008', 48, 5, '13.22', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(1666, 'AJBAJK', '008', 48, 6, '16.14', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(1667, 'AJBAJK', '008', 48, 7, '19.22', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(1668, 'AJBAJK', '008', 48, 8, '22.43', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(1669, 'AJBAJK', '008', 48, 9, '25.74', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(1670, 'AJBAJK', '008', 48, 10, '29.14', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(1671, 'AJBAJK', '008', 48, 11, '32.60', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(1672, 'AJBAJK', '008', 48, 12, '36.11', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(1673, 'AJBAJK', '008', 48, 13, '39.73', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(1674, 'AJBAJK', '008', 48, 14, '43.45', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(1675, 'AJBAJK', '008', 48, 15, '47.26', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(1676, 'AJBAJK', '008', 48, 16, '51.13', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(1677, 'AJBAJK', '008', 48, 17, '55.06', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(1678, 'AJBAJK', '008', 48, 18, '59.03', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(1679, 'AJBAJK', '008', 48, 19, '63.01', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(1680, 'AJBAJK', '008', 48, 20, '66.97', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(1681, 'AJBAJK', '008', 49, 1, '3.39', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(1682, 'AJBAJK', '008', 49, 2, '5.85', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(1683, 'AJBAJK', '008', 49, 3, '8.48', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(1684, 'AJBAJK', '008', 49, 4, '11.31', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(1685, 'AJBAJK', '008', 49, 5, '14.32', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(1686, 'AJBAJK', '008', 49, 6, '17.50', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(1687, 'AJBAJK', '008', 49, 7, '20.81', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(1688, 'AJBAJK', '008', 49, 8, '24.27', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(1689, 'AJBAJK', '008', 49, 9, '27.85', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(1690, 'AJBAJK', '008', 49, 10, '31.53', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(1691, 'AJBAJK', '008', 49, 11, '35.28', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(1692, 'AJBAJK', '008', 49, 12, '39.10', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(1693, 'AJBAJK', '008', 49, 13, '43.04', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(1694, 'AJBAJK', '008', 49, 14, '47.10', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(1695, 'AJBAJK', '008', 49, 15, '51.25', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(1696, 'AJBAJK', '008', 49, 16, '55.47', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(1697, 'AJBAJK', '008', 49, 17, '59.74', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(1698, 'AJBAJK', '008', 49, 18, '64.02', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(1699, 'AJBAJK', '008', 49, 19, '68.32', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(1700, 'AJBAJK', '008', 49, 20, '72.58', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(1701, 'AJBAJK', '008', 50, 1, '3.65', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(1702, 'AJBAJK', '008', 50, 2, '6.31', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(1703, 'AJBAJK', '008', 50, 3, '9.18', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(1704, 'AJBAJK', '008', 50, 4, '12.26', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(1705, 'AJBAJK', '008', 50, 5, '15.53', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(1706, 'AJBAJK', '008', 50, 6, '18.95', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(1707, 'AJBAJK', '008', 50, 7, '22.53', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(1708, 'AJBAJK', '008', 50, 8, '26.26', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(1709, 'AJBAJK', '008', 50, 9, '30.13', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(1710, 'AJBAJK', '008', 50, 10, '34.13', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(1711, 'AJBAJK', '008', 50, 11, '38.21', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(1712, 'AJBAJK', '008', 50, 12, '42.36', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(1713, 'AJBAJK', '008', 50, 13, '46.67', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(1714, 'AJBAJK', '008', 50, 14, '51.09', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(1715, 'AJBAJK', '008', 50, 15, '55.62', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(1716, 'AJBAJK', '008', 50, 16, '60.23', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(1717, 'AJBAJK', '008', 50, 17, '64.84', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(1718, 'AJBAJK', '008', 50, 18, '69.46', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(1719, 'AJBAJK', '008', 50, 19, '74.09', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(1720, 'AJBAJK', '008', 50, 20, '78.65', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(1721, 'AJBAJK', '008', 51, 1, '3.97', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(1722, 'AJBAJK', '008', 51, 2, '6.88', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(1723, 'AJBAJK', '008', 51, 3, '10.01', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(1724, 'AJBAJK', '008', 51, 4, '13.36', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(1725, 'AJBAJK', '008', 51, 5, '16.87', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(1726, 'AJBAJK', '008', 51, 6, '20.56', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(1727, 'AJBAJK', '008', 51, 7, '24.41', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(1728, 'AJBAJK', '008', 51, 8, '28.46', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(1729, 'AJBAJK', '008', 51, 9, '32.67', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(1730, 'AJBAJK', '008', 51, 10, '37.02', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(1731, 'AJBAJK', '008', 51, 11, '41.47', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(1732, 'AJBAJK', '008', 51, 12, '46.00', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(1733, 'AJBAJK', '008', 51, 13, '50.70', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(1734, 'AJBAJK', '008', 51, 14, '55.53', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(1735, 'AJBAJK', '008', 51, 15, '60.45', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(1736, 'AJBAJK', '008', 51, 16, '65.43', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(1737, 'AJBAJK', '008', 51, 17, '70.41', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(1738, 'AJBAJK', '008', 51, 18, '75.38', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(1739, 'AJBAJK', '008', 51, 19, '80.35', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(1740, 'AJBAJK', '008', 51, 20, '119.33', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(1741, 'AJBAJK', '008', 52, 1, '4.34', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(1742, 'AJBAJK', '008', 52, 2, '7.52', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(1743, 'AJBAJK', '008', 52, 3, '10.91', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(1744, 'AJBAJK', '008', 52, 4, '14.49', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(1745, 'AJBAJK', '008', 52, 5, '18.27', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(1746, 'AJBAJK', '008', 52, 6, '22.24', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(1747, 'AJBAJK', '008', 52, 7, '26.42', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(1748, 'AJBAJK', '008', 52, 8, '30.82', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(1749, 'AJBAJK', '008', 52, 9, '35.41', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(1750, 'AJBAJK', '008', 52, 10, '40.15', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(1751, 'AJBAJK', '008', 52, 11, '45.01', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(1752, 'AJBAJK', '008', 52, 12, '49.96', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(1753, 'AJBAJK', '008', 52, 13, '55.10', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(1754, 'AJBAJK', '008', 52, 14, '60.37', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(1755, 'AJBAJK', '008', 52, 15, '65.70', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(1756, 'AJBAJK', '008', 52, 16, '71.07', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(1757, 'AJBAJK', '008', 52, 17, '76.44', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(1758, 'AJBAJK', '008', 52, 18, '81.79', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(1759, 'AJBAJK', '008', 52, 19, '121.95', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(1760, 'AJBAJK', '008', 52, 20, '129.27', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(1761, 'AJBAJK', '008', 53, 1, '4.75', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(1762, 'AJBAJK', '008', 53, 2, '8.17', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(1763, 'AJBAJK', '008', 53, 3, '11.79', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(1764, 'AJBAJK', '008', 53, 4, '15.63', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(1765, 'AJBAJK', '008', 53, 5, '19.70', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(1766, 'AJBAJK', '008', 53, 6, '24.01', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(1767, 'AJBAJK', '008', 53, 7, '28.55', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(1768, 'AJBAJK', '008', 53, 8, '33.35', '2018-11-13 22:25:36', '2018-11-13 22:25:36');
INSERT INTO `master_insurance_rates` (`id`, `insurance_kind_id`, `bank_id`, `age`, `jw`, `rate`, `created_at`, `updated_at`) VALUES
(1769, 'AJBAJK', '008', 53, 9, '38.35', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(1770, 'AJBAJK', '008', 53, 10, '43.54', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(1771, 'AJBAJK', '008', 53, 11, '48.85', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(1772, 'AJBAJK', '008', 53, 12, '54.27', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(1773, 'AJBAJK', '008', 53, 13, '59.93', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(1774, 'AJBAJK', '008', 53, 14, '65.64', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(1775, 'AJBAJK', '008', 53, 15, '71.39', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(1776, 'AJBAJK', '008', 53, 16, '77.19', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(1777, 'AJBAJK', '008', 53, 17, '82.96', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(1778, 'AJBAJK', '008', 53, 18, '124.16', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(1779, 'AJBAJK', '008', 53, 19, '132.13', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(1780, 'AJBAJK', '008', 53, 20, '139.94', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(1781, 'AJBAJK', '008', 54, 1, '5.05', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(1782, 'AJBAJK', '008', 54, 2, '8.68', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(1783, 'AJBAJK', '008', 54, 3, '12.55', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(1784, 'AJBAJK', '008', 54, 4, '16.70', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(1785, 'AJBAJK', '008', 54, 5, '21.12', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(1786, 'AJBAJK', '008', 54, 6, '25.82', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(1787, 'AJBAJK', '008', 54, 7, '30.78', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(1788, 'AJBAJK', '008', 54, 8, '36.03', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(1789, 'AJBAJK', '008', 54, 9, '41.50', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(1790, 'AJBAJK', '008', 54, 10, '47.18', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(1791, 'AJBAJK', '008', 54, 11, '52.99', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(1792, 'AJBAJK', '008', 54, 12, '59.03', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(1793, 'AJBAJK', '008', 54, 13, '65.16', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(1794, 'AJBAJK', '008', 54, 14, '71.33', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(1795, 'AJBAJK', '008', 54, 15, '77.54', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(1796, 'AJBAJK', '008', 54, 16, '83.77', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(1797, 'AJBAJK', '008', 54, 17, '125.94', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(1798, 'AJBAJK', '008', 54, 18, '134.53', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(1799, 'AJBAJK', '008', 54, 19, '143.05', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(1800, 'AJBAJK', '008', 54, 20, '151.38', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(1801, 'AJBAJK', '008', 55, 1, '5.36', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(1802, 'AJBAJK', '008', 55, 2, '9.27', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(1803, 'AJBAJK', '008', 55, 3, '13.47', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(1804, 'AJBAJK', '008', 55, 4, '18.00', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(1805, 'AJBAJK', '008', 55, 5, '22.84', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(1806, 'AJBAJK', '008', 55, 6, '27.99', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(1807, 'AJBAJK', '008', 55, 7, '33.43', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(1808, 'AJBAJK', '008', 55, 8, '39.18', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(1809, 'AJBAJK', '008', 55, 9, '45.19', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(1810, 'AJBAJK', '008', 55, 10, '51.42', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(1811, 'AJBAJK', '008', 55, 11, '57.62', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(1812, 'AJBAJK', '008', 55, 12, '64.17', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(1813, 'AJBAJK', '008', 55, 13, '70.79', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(1814, 'AJBAJK', '008', 55, 14, '77.46', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(1815, 'AJBAJK', '008', 55, 15, '84.14', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(1816, 'AJBAJK', '008', 55, 16, '127.16', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(1817, 'AJBAJK', '008', 55, 17, '136.44', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(1818, 'AJBAJK', '008', 55, 18, '145.63', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(1819, 'AJBAJK', '008', 55, 19, '154.72', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(1820, 'AJBAJK', '008', 55, 20, '163.60', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(1821, 'AJBAJK', '008', 56, 1, '5.83', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(1822, 'AJBAJK', '008', 56, 2, '10.09', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(1823, 'AJBAJK', '008', 56, 3, '14.70', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(1824, 'AJBAJK', '008', 56, 4, '19.68', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(1825, 'AJBAJK', '008', 56, 5, '25.00', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(1826, 'AJBAJK', '008', 56, 6, '30.65', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(1827, 'AJBAJK', '008', 56, 7, '36.64', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(1828, 'AJBAJK', '008', 56, 8, '42.96', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(1829, 'AJBAJK', '008', 56, 9, '49.56', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(1830, 'AJBAJK', '008', 56, 10, '55.89', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(1831, 'AJBAJK', '008', 56, 11, '62.62', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(1832, 'AJBAJK', '008', 56, 12, '69.71', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(1833, 'AJBAJK', '008', 56, 13, '76.87', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(1834, 'AJBAJK', '008', 56, 14, '84.05', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(1835, 'AJBAJK', '008', 56, 15, '127.72', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(1836, 'AJBAJK', '008', 56, 16, '137.76', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(1837, 'AJBAJK', '008', 56, 17, '147.70', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(1838, 'AJBAJK', '008', 56, 18, '157.51', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(1839, 'AJBAJK', '008', 56, 19, '167.21', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(1840, 'AJBAJK', '008', 56, 20, '0.00', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(1841, 'AJBAJK', '008', 57, 1, '6.36', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(1842, 'AJBAJK', '008', 57, 2, '11.06', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(1843, 'AJBAJK', '008', 57, 3, '16.14', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(1844, 'AJBAJK', '008', 57, 4, '21.62', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(1845, 'AJBAJK', '008', 57, 5, '27.48', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(1846, 'AJBAJK', '008', 57, 6, '33.70', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(1847, 'AJBAJK', '008', 57, 7, '40.29', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(1848, 'AJBAJK', '008', 57, 8, '47.25', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(1849, 'AJBAJK', '008', 57, 9, '53.87', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(1850, 'AJBAJK', '008', 57, 10, '60.74', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(1851, 'AJBAJK', '008', 57, 11, '68.04', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(1852, 'AJBAJK', '008', 57, 12, '75.70', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(1853, 'AJBAJK', '008', 57, 13, '83.42', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(1854, 'AJBAJK', '008', 57, 14, '127.60', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(1855, 'AJBAJK', '008', 57, 15, '138.37', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(1856, 'AJBAJK', '008', 57, 16, '149.13', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(1857, 'AJBAJK', '008', 57, 17, '159.76', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(1858, 'AJBAJK', '008', 57, 18, '170.24', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(1859, 'AJBAJK', '008', 57, 19, '0.00', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(1860, 'AJBAJK', '008', 57, 20, '0.00', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(1861, 'AJBAJK', '008', 58, 1, '7.07', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(1862, 'AJBAJK', '008', 58, 2, '12.24', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(1863, 'AJBAJK', '008', 58, 3, '17.84', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(1864, 'AJBAJK', '008', 58, 4, '23.87', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(1865, 'AJBAJK', '008', 58, 5, '30.32', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(1866, 'AJBAJK', '008', 58, 6, '37.18', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(1867, 'AJBAJK', '008', 58, 7, '44.43', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(1868, 'AJBAJK', '008', 58, 8, '51.38', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(1869, 'AJBAJK', '008', 58, 9, '58.57', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(1870, 'AJBAJK', '008', 58, 10, '66.03', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(1871, 'AJBAJK', '008', 58, 11, '73.92', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(1872, 'AJBAJK', '008', 58, 12, '82.19', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(1873, 'AJBAJK', '008', 58, 13, '126.69', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(1874, 'AJBAJK', '008', 58, 14, '138.30', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(1875, 'AJBAJK', '008', 58, 15, '149.85', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(1876, 'AJBAJK', '008', 58, 16, '161.37', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(1877, 'AJBAJK', '008', 58, 17, '172.73', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(1878, 'AJBAJK', '008', 58, 18, '0.00', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(1879, 'AJBAJK', '008', 58, 19, '0.00', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(1880, 'AJBAJK', '008', 58, 20, '0.00', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(1881, 'AJBAJK', '008', 59, 1, '7.77', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(1882, 'AJBAJK', '008', 59, 2, '13.46', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(1883, 'AJBAJK', '008', 59, 3, '19.62', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(1884, 'AJBAJK', '008', 59, 4, '26.27', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(1885, 'AJBAJK', '008', 59, 5, '33.38', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(1886, 'AJBAJK', '008', 59, 6, '40.93', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(1887, 'AJBAJK', '008', 59, 7, '48.36', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(1888, 'AJBAJK', '008', 59, 8, '55.92', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(1889, 'AJBAJK', '008', 59, 9, '63.73', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(1890, 'AJBAJK', '008', 59, 10, '71.81', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(1891, 'AJBAJK', '008', 59, 11, '80.32', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(1892, 'AJBAJK', '008', 59, 12, '124.92', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(1893, 'AJBAJK', '008', 59, 13, '137.41', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(1894, 'AJBAJK', '008', 59, 14, '149.87', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(1895, 'AJBAJK', '008', 59, 15, '162.25', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(1896, 'AJBAJK', '008', 59, 16, '174.58', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(1897, 'AJBAJK', '008', 59, 17, '0.00', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(1898, 'AJBAJK', '008', 59, 18, '0.00', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(1899, 'AJBAJK', '008', 59, 19, '0.00', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(1900, 'AJBAJK', '008', 59, 20, '0.00', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(1901, 'AJBAJK', '008', 60, 1, '8.55', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(1902, 'AJBAJK', '008', 60, 2, '14.82', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(1903, 'AJBAJK', '008', 60, 3, '21.62', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(1904, 'AJBAJK', '008', 60, 4, '28.96', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(1905, 'AJBAJK', '008', 60, 5, '36.78', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(1906, 'AJBAJK', '008', 60, 6, '44.62', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(1907, 'AJBAJK', '008', 60, 7, '52.72', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(1908, 'AJBAJK', '008', 60, 8, '60.93', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(1909, 'AJBAJK', '008', 60, 9, '69.39', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(1910, 'AJBAJK', '008', 60, 10, '78.12', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(1911, 'AJBAJK', '008', 60, 11, '122.21', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(1912, 'AJBAJK', '008', 60, 12, '135.62', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(1913, 'AJBAJK', '008', 60, 13, '149.04', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(1914, 'AJBAJK', '008', 60, 14, '162.40', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(1915, 'AJBAJK', '008', 60, 15, '175.66', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(1916, 'AJBAJK', '008', 60, 16, '0.00', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(1917, 'AJBAJK', '008', 60, 17, '0.00', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(1918, 'AJBAJK', '008', 60, 18, '0.00', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(1919, 'AJBAJK', '008', 60, 19, '0.00', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(1920, 'AJBAJK', '008', 60, 20, '0.00', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(1921, 'AJBAJK', '008', 61, 1, '9.43', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(1922, 'AJBAJK', '008', 61, 2, '16.37', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(1923, 'AJBAJK', '008', 61, 3, '23.88', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(1924, 'AJBAJK', '008', 61, 4, '31.95', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(1925, 'AJBAJK', '008', 61, 5, '40.18', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(1926, 'AJBAJK', '008', 61, 6, '48.73', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(1927, 'AJBAJK', '008', 61, 7, '57.53', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(1928, 'AJBAJK', '008', 61, 8, '66.44', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(1929, 'AJBAJK', '008', 61, 9, '75.58', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(1930, 'AJBAJK', '008', 61, 10, '118.98', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(1931, 'AJBAJK', '008', 61, 11, '132.80', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(1932, 'AJBAJK', '008', 61, 12, '147.22', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(1933, 'AJBAJK', '008', 61, 13, '161.63', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(1934, 'AJBAJK', '008', 61, 14, '175.95', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(1935, 'AJBAJK', '008', 61, 15, '0.00', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(1936, 'AJBAJK', '008', 61, 16, '0.00', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(1937, 'AJBAJK', '008', 61, 17, '0.00', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(1938, 'AJBAJK', '008', 61, 18, '0.00', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(1939, 'AJBAJK', '008', 61, 19, '0.00', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(1940, 'AJBAJK', '008', 61, 20, '0.00', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(1941, 'AJBAJK', '008', 62, 1, '10.47', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(1942, 'AJBAJK', '008', 62, 2, '18.12', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(1943, 'AJBAJK', '008', 62, 3, '26.37', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(1944, 'AJBAJK', '008', 62, 4, '34.97', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(1945, 'AJBAJK', '008', 62, 5, '43.96', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(1946, 'AJBAJK', '008', 62, 6, '53.26', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(1947, 'AJBAJK', '008', 62, 7, '62.82', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(1948, 'AJBAJK', '008', 62, 8, '72.45', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(1949, 'AJBAJK', '008', 62, 9, '115.23', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(1950, 'AJBAJK', '008', 62, 10, '129.40', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(1951, 'AJBAJK', '008', 62, 11, '144.28', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(1952, 'AJBAJK', '008', 62, 12, '159.77', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(1953, 'AJBAJK', '008', 62, 13, '175.24', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(1954, 'AJBAJK', '008', 62, 14, '0.00', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(1955, 'AJBAJK', '008', 62, 15, '0.00', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(1956, 'AJBAJK', '008', 62, 16, '0.00', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(1957, 'AJBAJK', '008', 62, 17, '0.00', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(1958, 'AJBAJK', '008', 62, 18, '0.00', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(1959, 'AJBAJK', '008', 62, 19, '0.00', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(1960, 'AJBAJK', '008', 62, 20, '0.00', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(1961, 'AJBAJK', '008', 63, 1, '11.49', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(1962, 'AJBAJK', '008', 63, 2, '19.90', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(1963, 'AJBAJK', '008', 63, 3, '28.92', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(1964, 'AJBAJK', '008', 63, 4, '38.33', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(1965, 'AJBAJK', '008', 63, 5, '48.11', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(1966, 'AJBAJK', '008', 63, 6, '58.22', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(1967, 'AJBAJK', '008', 63, 7, '68.56', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(1968, 'AJBAJK', '008', 63, 8, '110.54', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(1969, 'AJBAJK', '008', 63, 9, '125.41', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(1970, 'AJBAJK', '008', 63, 10, '140.67', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(1971, 'AJBAJK', '008', 63, 11, '156.66', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(1972, 'AJBAJK', '008', 63, 12, '173.32', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(1973, 'AJBAJK', '008', 63, 13, '0.00', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(1974, 'AJBAJK', '008', 63, 14, '0.00', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(1975, 'AJBAJK', '008', 63, 15, '0.00', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(1976, 'AJBAJK', '008', 63, 16, '0.00', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(1977, 'AJBAJK', '008', 63, 17, '0.00', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(1978, 'AJBAJK', '008', 63, 18, '0.00', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(1979, 'AJBAJK', '008', 63, 19, '0.00', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(1980, 'AJBAJK', '008', 63, 20, '0.00', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(1981, 'AJBAJK', '008', 64, 1, '12.62', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(1982, 'AJBAJK', '008', 64, 2, '21.85', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(1983, 'AJBAJK', '008', 64, 3, '31.72', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(1984, 'AJBAJK', '008', 64, 4, '41.98', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(1985, 'AJBAJK', '008', 64, 5, '52.61', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(1986, 'AJBAJK', '008', 64, 6, '63.56', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(1987, 'AJBAJK', '008', 64, 7, '104.63', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(1988, 'AJBAJK', '008', 64, 8, '120.32', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(1989, 'AJBAJK', '008', 64, 9, '136.35', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(1990, 'AJBAJK', '008', 64, 10, '152.78', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(1991, 'AJBAJK', '008', 64, 11, '169.99', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(1992, 'AJBAJK', '008', 64, 12, '0.00', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(1993, 'AJBAJK', '008', 64, 13, '0.00', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(1994, 'AJBAJK', '008', 64, 14, '0.00', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(1995, 'AJBAJK', '008', 64, 15, '0.00', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(1996, 'AJBAJK', '008', 64, 16, '0.00', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(1997, 'AJBAJK', '008', 64, 17, '0.00', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(1998, 'AJBAJK', '008', 64, 18, '0.00', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(1999, 'AJBAJK', '008', 64, 19, '0.00', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(2000, 'AJBAJK', '008', 64, 20, '0.00', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(2001, 'AJBAJK', '008', 65, 1, '13.87', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(2002, 'AJBAJK', '008', 65, 2, '23.97', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(2003, 'AJBAJK', '008', 65, 3, '34.74', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(2004, 'AJBAJK', '008', 65, 4, '45.90', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(2005, 'AJBAJK', '008', 65, 5, '57.43', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(2006, 'AJBAJK', '008', 65, 6, '96.97', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(2007, 'AJBAJK', '008', 65, 7, '113.87', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(2008, 'AJBAJK', '008', 65, 8, '130.80', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(2009, 'AJBAJK', '008', 65, 9, '148.10', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(2010, 'AJBAJK', '008', 65, 10, '165.80', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(2011, 'AJBAJK', '008', 65, 11, '0.00', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(2012, 'AJBAJK', '008', 65, 12, '0.00', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(2013, 'AJBAJK', '008', 65, 13, '0.00', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(2014, 'AJBAJK', '008', 65, 14, '0.00', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(2015, 'AJBAJK', '008', 65, 15, '0.00', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(2016, 'AJBAJK', '008', 65, 16, '0.00', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(2017, 'AJBAJK', '008', 65, 17, '0.00', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(2018, 'AJBAJK', '008', 65, 18, '0.00', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(2019, 'AJBAJK', '008', 65, 19, '0.00', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(2020, 'AJBAJK', '008', 65, 20, '0.00', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(2021, 'AJBAJK', '008', 66, 1, '15.19', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(2022, 'AJBAJK', '008', 66, 2, '26.23', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(2023, 'AJBAJK', '008', 66, 3, '37.95', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(2024, 'AJBAJK', '008', 66, 4, '50.06', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(2025, 'AJBAJK', '008', 66, 5, '87.56', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(2026, 'AJBAJK', '008', 66, 6, '105.49', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(2027, 'AJBAJK', '008', 66, 7, '123.76', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(2028, 'AJBAJK', '008', 66, 8, '142.06', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(2029, 'AJBAJK', '008', 66, 9, '160.73', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(2030, 'AJBAJK', '008', 66, 10, '0.00', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(2031, 'AJBAJK', '008', 66, 11, '0.00', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(2032, 'AJBAJK', '008', 66, 12, '0.00', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(2033, 'AJBAJK', '008', 66, 13, '0.00', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(2034, 'AJBAJK', '008', 66, 14, '0.00', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(2035, 'AJBAJK', '008', 66, 15, '0.00', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(2036, 'AJBAJK', '008', 66, 16, '0.00', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(2037, 'AJBAJK', '008', 66, 17, '0.00', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(2038, 'AJBAJK', '008', 66, 18, '0.00', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(2039, 'AJBAJK', '008', 66, 19, '0.00', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(2040, 'AJBAJK', '008', 66, 20, '0.00', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(2041, 'AJBAJK', '008', 67, 1, '16.61', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(2042, 'AJBAJK', '008', 67, 2, '28.63', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(2043, 'AJBAJK', '008', 67, 3, '41.37', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(2044, 'AJBAJK', '008', 67, 4, '76.29', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(2045, 'AJBAJK', '008', 67, 5, '95.23', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(2046, 'AJBAJK', '008', 67, 6, '114.66', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(2047, 'AJBAJK', '008', 67, 7, '134.45', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(2048, 'AJBAJK', '008', 67, 8, '154.25', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(2049, 'AJBAJK', '008', 67, 9, '0.00', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(2050, 'AJBAJK', '008', 67, 10, '0.00', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(2051, 'AJBAJK', '008', 67, 11, '0.00', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(2052, 'AJBAJK', '008', 67, 12, '0.00', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(2053, 'AJBAJK', '008', 67, 13, '0.00', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(2054, 'AJBAJK', '008', 67, 14, '0.00', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(2055, 'AJBAJK', '008', 67, 15, '0.00', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(2056, 'AJBAJK', '008', 67, 16, '0.00', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(2057, 'AJBAJK', '008', 67, 17, '0.00', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(2058, 'AJBAJK', '008', 67, 18, '0.00', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(2059, 'AJBAJK', '008', 67, 19, '0.00', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(2060, 'AJBAJK', '008', 67, 20, '0.00', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(2061, 'AJBAJK', '008', 68, 1, '18.11', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(2062, 'AJBAJK', '008', 68, 2, '31.18', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(2063, 'AJBAJK', '008', 68, 3, '63.04', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(2064, 'AJBAJK', '008', 68, 4, '83.00', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(2065, 'AJBAJK', '008', 68, 5, '103.57', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(2066, 'AJBAJK', '008', 68, 6, '124.66', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(2067, 'AJBAJK', '008', 68, 7, '146.13', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(2068, 'AJBAJK', '008', 68, 8, '0.00', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(2069, 'AJBAJK', '008', 68, 9, '0.00', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(2070, 'AJBAJK', '008', 68, 10, '0.00', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(2071, 'AJBAJK', '008', 68, 11, '0.00', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(2072, 'AJBAJK', '008', 68, 12, '0.00', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(2073, 'AJBAJK', '008', 68, 13, '0.00', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(2074, 'AJBAJK', '008', 68, 14, '0.00', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(2075, 'AJBAJK', '008', 68, 15, '0.00', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(2076, 'AJBAJK', '008', 68, 16, '0.00', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(2077, 'AJBAJK', '008', 68, 17, '0.00', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(2078, 'AJBAJK', '008', 68, 18, '0.00', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(2079, 'AJBAJK', '008', 68, 19, '0.00', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(2080, 'AJBAJK', '008', 68, 20, '0.00', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(2081, 'AJBAJK', '008', 69, 1, '19.73', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(2082, 'AJBAJK', '008', 69, 2, '47.57', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(2083, 'AJBAJK', '008', 69, 3, '68.67', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(2084, 'AJBAJK', '008', 69, 4, '90.41', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(2085, 'AJBAJK', '008', 69, 5, '112.81', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(2086, 'AJBAJK', '008', 69, 6, '135.74', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(2087, 'AJBAJK', '008', 69, 7, '0.00', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(2088, 'AJBAJK', '008', 69, 8, '0.00', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(2089, 'AJBAJK', '008', 69, 9, '0.00', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(2090, 'AJBAJK', '008', 69, 10, '0.00', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(2091, 'AJBAJK', '008', 69, 11, '0.00', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(2092, 'AJBAJK', '008', 69, 12, '0.00', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(2093, 'AJBAJK', '008', 69, 13, '0.00', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(2094, 'AJBAJK', '008', 69, 14, '0.00', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(2095, 'AJBAJK', '008', 69, 15, '0.00', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(2096, 'AJBAJK', '008', 69, 16, '0.00', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(2097, 'AJBAJK', '008', 69, 17, '0.00', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(2098, 'AJBAJK', '008', 69, 18, '0.00', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(2099, 'AJBAJK', '008', 69, 19, '0.00', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(2100, 'AJBAJK', '008', 69, 20, '0.00', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(2101, 'AJBAJK', '008', 70, 1, '30.18', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(2102, 'AJBAJK', '008', 70, 2, '51.96', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(2103, 'AJBAJK', '008', 70, 3, '75.01', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(2104, 'AJBAJK', '008', 70, 4, '98.75', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(2105, 'AJBAJK', '008', 70, 5, '123.17', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(2106, 'AJBAJK', '008', 70, 6, '0.00', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(2107, 'AJBAJK', '008', 70, 7, '0.00', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(2108, 'AJBAJK', '008', 70, 8, '0.00', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(2109, 'AJBAJK', '008', 70, 9, '0.00', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(2110, 'AJBAJK', '008', 70, 10, '0.00', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(2111, 'AJBAJK', '008', 70, 11, '0.00', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(2112, 'AJBAJK', '008', 70, 12, '0.00', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(2113, 'AJBAJK', '008', 70, 13, '0.00', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(2114, 'AJBAJK', '008', 70, 14, '0.00', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(2115, 'AJBAJK', '008', 70, 15, '0.00', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(2116, 'AJBAJK', '008', 70, 16, '0.00', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(2117, 'AJBAJK', '008', 70, 17, '0.00', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(2118, 'AJBAJK', '008', 70, 18, '0.00', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(2119, 'AJBAJK', '008', 70, 19, '0.00', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(2120, 'AJBAJK', '008', 70, 20, '0.00', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(2121, 'AJBAJK', '008', 71, 1, '33.07', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(2122, 'AJBAJK', '008', 71, 2, '56.94', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(2123, 'AJBAJK', '008', 71, 3, '82.21', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(2124, 'AJBAJK', '008', 71, 4, '108.18', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(2125, 'AJBAJK', '008', 71, 5, '0.00', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(2126, 'AJBAJK', '008', 71, 6, '0.00', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(2127, 'AJBAJK', '008', 71, 7, '0.00', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(2128, 'AJBAJK', '008', 71, 8, '0.00', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(2129, 'AJBAJK', '008', 71, 9, '0.00', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(2130, 'AJBAJK', '008', 71, 10, '0.00', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(2131, 'AJBAJK', '008', 71, 11, '0.00', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(2132, 'AJBAJK', '008', 71, 12, '0.00', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(2133, 'AJBAJK', '008', 71, 13, '0.00', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(2134, 'AJBAJK', '008', 71, 14, '0.00', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(2135, 'AJBAJK', '008', 71, 15, '0.00', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(2136, 'AJBAJK', '008', 71, 16, '0.00', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(2137, 'AJBAJK', '008', 71, 17, '0.00', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(2138, 'AJBAJK', '008', 71, 18, '0.00', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(2139, 'AJBAJK', '008', 71, 19, '0.00', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(2140, 'AJBAJK', '008', 71, 20, '0.00', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(2141, 'AJBAJK', '008', 72, 1, '36.39', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(2142, 'AJBAJK', '008', 72, 2, '62.65', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(2143, 'AJBAJK', '008', 72, 3, '90.38', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(2144, 'AJBAJK', '008', 72, 4, '0.00', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(2145, 'AJBAJK', '008', 72, 5, '0.00', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(2146, 'AJBAJK', '008', 72, 6, '0.00', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(2147, 'AJBAJK', '008', 72, 7, '0.00', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(2148, 'AJBAJK', '008', 72, 8, '0.00', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(2149, 'AJBAJK', '008', 72, 9, '0.00', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(2150, 'AJBAJK', '008', 72, 10, '0.00', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(2151, 'AJBAJK', '008', 72, 11, '0.00', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(2152, 'AJBAJK', '008', 72, 12, '0.00', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(2153, 'AJBAJK', '008', 72, 13, '0.00', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(2154, 'AJBAJK', '008', 72, 14, '0.00', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(2155, 'AJBAJK', '008', 72, 15, '0.00', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(2156, 'AJBAJK', '008', 72, 16, '0.00', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(2157, 'AJBAJK', '008', 72, 17, '0.00', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(2158, 'AJBAJK', '008', 72, 18, '0.00', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(2159, 'AJBAJK', '008', 72, 19, '0.00', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(2160, 'AJBAJK', '008', 72, 20, '0.00', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(2161, 'AJBAJK', '008', 73, 1, '40.20', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(2162, 'AJBAJK', '008', 73, 2, '69.13', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(2163, 'AJBAJK', '008', 73, 3, '0.00', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(2164, 'AJBAJK', '008', 73, 4, '0.00', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(2165, 'AJBAJK', '008', 73, 5, '0.00', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(2166, 'AJBAJK', '008', 73, 6, '0.00', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(2167, 'AJBAJK', '008', 73, 7, '0.00', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(2168, 'AJBAJK', '008', 73, 8, '0.00', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(2169, 'AJBAJK', '008', 73, 9, '0.00', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(2170, 'AJBAJK', '008', 73, 10, '0.00', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(2171, 'AJBAJK', '008', 73, 11, '0.00', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(2172, 'AJBAJK', '008', 73, 12, '0.00', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(2173, 'AJBAJK', '008', 73, 13, '0.00', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(2174, 'AJBAJK', '008', 73, 14, '0.00', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(2175, 'AJBAJK', '008', 73, 15, '0.00', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(2176, 'AJBAJK', '008', 73, 16, '0.00', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(2177, 'AJBAJK', '008', 73, 17, '0.00', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(2178, 'AJBAJK', '008', 73, 18, '0.00', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(2179, 'AJBAJK', '008', 73, 19, '0.00', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(2180, 'AJBAJK', '008', 73, 20, '0.00', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(2181, 'AJBAJK', '008', 74, 1, '44.44', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(2182, 'AJBAJK', '008', 74, 2, '0.00', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(2183, 'AJBAJK', '008', 74, 3, '0.00', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(2184, 'AJBAJK', '008', 74, 4, '0.00', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(2185, 'AJBAJK', '008', 74, 5, '0.00', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(2186, 'AJBAJK', '008', 74, 6, '0.00', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(2187, 'AJBAJK', '008', 74, 7, '0.00', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(2188, 'AJBAJK', '008', 74, 8, '0.00', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(2189, 'AJBAJK', '008', 74, 9, '0.00', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(2190, 'AJBAJK', '008', 74, 10, '0.00', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(2191, 'AJBAJK', '008', 74, 11, '0.00', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(2192, 'AJBAJK', '008', 74, 12, '0.00', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(2193, 'AJBAJK', '008', 74, 13, '0.00', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(2194, 'AJBAJK', '008', 74, 14, '0.00', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(2195, 'AJBAJK', '008', 74, 15, '0.00', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(2196, 'AJBAJK', '008', 74, 16, '0.00', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(2197, 'AJBAJK', '008', 74, 17, '0.00', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(2198, 'AJBAJK', '008', 74, 18, '0.00', '2018-11-13 22:25:36', '2018-11-13 22:25:36'),
(2199, 'AJBAJK', '008', 74, 19, '45.09', '2018-11-13 22:25:36', '2018-11-15 15:25:27'),
(2200, 'AJBAJK', '008', 12, 13, '14.00', '2018-11-13 22:25:36', '2019-03-22 05:19:42');

-- --------------------------------------------------------

--
-- Table structure for table `master_map_banks_insurances`
--

CREATE TABLE `master_map_banks_insurances` (
  `id` int(11) NOT NULL,
  `bank_id` varchar(3) NOT NULL,
  `insurance_id` varchar(6) NOT NULL,
  `created_at` datetime DEFAULT current_timestamp(),
  `updated_at` datetime DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB AVG_ROW_LENGTH=8192 DEFAULT CHARSET=utf8 ROW_FORMAT=DYNAMIC;

--
-- Dumping data for table `master_map_banks_insurances`
--

INSERT INTO `master_map_banks_insurances` (`id`, `bank_id`, `insurance_id`, `created_at`, `updated_at`) VALUES
(11, '008', 'AJB', '2020-10-07 09:17:37', '2020-10-07 09:17:37'),
(12, '008', 'LIP', '2020-10-07 09:17:49', '2020-10-07 09:18:42'),
(13, '212', 'AJB', '2020-10-07 09:17:58', '2020-10-07 09:18:01'),
(14, '798', 'LIP', '2020-10-07 09:18:12', '2020-10-07 09:18:45'),
(15, '212', 'LIP', '2020-10-17 04:32:43', '2020-10-17 04:32:43');

-- --------------------------------------------------------

--
-- Table structure for table `master_map_product_insurances`
--

CREATE TABLE `master_map_product_insurances` (
  `id` int(11) NOT NULL,
  `product_id` varchar(10) NOT NULL,
  `insurance_kind_id` varchar(6) DEFAULT NULL,
  `created_at` datetime DEFAULT current_timestamp(),
  `updated_at` datetime DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB AVG_ROW_LENGTH=8192 DEFAULT CHARSET=utf8 ROW_FORMAT=DYNAMIC;

--
-- Dumping data for table `master_map_product_insurances`
--

INSERT INTO `master_map_product_insurances` (`id`, `product_id`, `insurance_kind_id`, `created_at`, `updated_at`) VALUES
(1, '3100300001', 'AJBAJK', '2018-11-13 22:43:40', '2018-11-13 22:43:40'),
(2, '3100400001', 'AJBAJK', '2018-11-13 22:43:40', '2018-11-13 22:43:40'),
(7, '3100400004', 'AJBAJK', '2018-11-16 08:19:36', '2018-11-16 08:19:36'),
(8, '0080000001', 'AJBAJK', '2020-10-02 06:30:06', '2020-10-02 06:30:06'),
(9, '0080000002', 'AJBAJK', '2020-10-02 06:30:14', '2020-10-02 06:30:14'),
(10, '0080000003', 'AJBAJK', '2020-10-02 06:30:41', '2020-10-02 06:30:41'),
(12, '4100300001', 'AJBAJK', '2020-10-17 04:28:59', '2020-10-17 04:28:59'),
(13, '4100400001', 'AJBAJK', '2020-10-17 04:28:59', '2020-10-17 04:28:59'),
(14, '4100400004', 'AJBAJK', '2020-10-17 04:28:59', '2020-10-17 04:28:59');

-- --------------------------------------------------------

--
-- Table structure for table `master_products`
--

CREATE TABLE `master_products` (
  `id` varchar(10) COLLATE utf8mb4_unicode_ci NOT NULL,
  `name` varchar(150) COLLATE utf8mb4_unicode_ci NOT NULL,
  `short_name` varchar(100) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `bank_id` varchar(3) COLLATE utf8mb4_unicode_ci NOT NULL,
  `created_at` timestamp NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  `insurance_id` varchar(3) COLLATE utf8mb4_unicode_ci DEFAULT NULL
) ENGINE=InnoDB AVG_ROW_LENGTH=5461 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci ROW_FORMAT=DYNAMIC;

--
-- Dumping data for table `master_products`
--

INSERT INTO `master_products` (`id`, `name`, `short_name`, `bank_id`, `created_at`, `updated_at`, `insurance_id`) VALUES
('0080000001', 'Kredit Umum Pensiunan Janda/Duda Mandiri', 'Kupen Janda/Duda Mandiri', '008', '2020-10-02 06:22:10', '2020-10-17 04:20:52', 'LIP'),
('0080000002', 'Kredit Umum Pensiunan Mandiri', 'Kupen Mandiri', '008', '2020-10-02 06:22:30', '2020-10-08 03:45:41', 'LIP'),
('0080000003', 'Kredit Umum Pegawai Mandiri', 'Kupeg Mandri', '008', '2020-10-02 06:29:11', '2020-10-08 03:45:33', 'LIP'),
('3100300001', 'Kredit Umum Pegawai', 'Kupeg', '212', '2018-11-13 21:18:22', '2020-10-08 09:26:16', 'AJB'),
('3100400001', 'Kredit Umum Pensiunan', 'Kupen', '212', '2018-11-13 21:18:22', '2020-10-08 09:26:18', 'AJB'),
('3100400004', 'Kredit Umum Pensiunan Janda/Duda', 'Kupen Janda/Duda', '212', '2018-11-13 21:18:22', '2020-10-08 09:26:21', 'AJB'),
('4100300001', 'Kredit Umum Pegawai Lippo', 'Kupeg', '212', '2018-11-13 21:18:22', '2020-10-17 04:22:12', 'LIP'),
('4100400001', 'Kredit Umum Pensiunan Lippo', 'Kupen', '212', '2018-11-13 21:18:22', '2020-10-17 04:22:12', 'LIP'),
('4100400004', 'Kredit Umum Pensiunan Janda/Duda Lippo', 'Kupen Janda/Duda', '212', '2018-11-13 21:18:22', '2020-10-17 04:22:12', 'LIP');

-- --------------------------------------------------------

--
-- Table structure for table `master_record_status`
--

CREATE TABLE `master_record_status` (
  `id` int(11) NOT NULL,
  `name` varchar(255) DEFAULT NULL,
  `created_at` datetime DEFAULT current_timestamp(),
  `updated_at` datetime DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB AVG_ROW_LENGTH=8192 DEFAULT CHARSET=utf8 ROW_FORMAT=DYNAMIC;

--
-- Dumping data for table `master_record_status`
--

INSERT INTO `master_record_status` (`id`, `name`, `created_at`, `updated_at`) VALUES
(1, 'Baru', '2018-11-14 15:18:31', '2018-11-14 15:18:31'),
(2, 'Lama', '2018-11-14 15:18:31', '2018-11-14 15:18:31');

-- --------------------------------------------------------

--
-- Table structure for table `master_repayment_status`
--

CREATE TABLE `master_repayment_status` (
  `id` int(11) NOT NULL,
  `name` varchar(255) DEFAULT NULL
) ENGINE=InnoDB AVG_ROW_LENGTH=5461 DEFAULT CHARSET=utf8 ROW_FORMAT=DYNAMIC;

--
-- Dumping data for table `master_repayment_status`
--

INSERT INTO `master_repayment_status` (`id`, `name`) VALUES
(1, 'On Review'),
(2, 'Approved'),
(3, 'Rejected');

-- --------------------------------------------------------

--
-- Table structure for table `master_validation_rules`
--

CREATE TABLE `master_validation_rules` (
  `id` int(11) NOT NULL,
  `product_id` varchar(10) DEFAULT NULL,
  `bank_id` varchar(3) DEFAULT NULL,
  `param_name` varchar(200) DEFAULT NULL,
  `param_value` int(11) DEFAULT NULL,
  `created_at` datetime DEFAULT current_timestamp(),
  `updated_at` datetime DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB AVG_ROW_LENGTH=2730 DEFAULT CHARSET=utf8 ROW_FORMAT=DYNAMIC;

--
-- Dumping data for table `master_validation_rules`
--

INSERT INTO `master_validation_rules` (`id`, `product_id`, `bank_id`, `param_name`, `param_value`, `created_at`, `updated_at`) VALUES
(1, '3100300001', '212', 'MIN_AGE', 20, '2018-11-13 19:54:50', '2018-11-13 19:54:50'),
(2, '3100300001', '212', 'MAX_AGE', 56, '2018-11-13 19:54:50', '2018-11-13 19:54:50'),
(3, '3100400001', '212', 'MIN_AGE', 40, '2018-11-13 19:54:50', '2018-11-13 19:54:50'),
(4, '3100400001', '212', 'MAX_AGE', 75, '2018-11-13 19:54:50', '2018-11-13 19:54:50'),
(5, '3100400004', '212', 'MIN_AGE', 40, '2018-11-13 19:54:50', '2018-11-13 19:54:50'),
(6, '3100400004', '212', 'MAX_AGE', 75, '2018-11-13 19:54:50', '2018-11-13 19:54:50');

-- --------------------------------------------------------

--
-- Table structure for table `master_validation_status`
--

CREATE TABLE `master_validation_status` (
  `id` int(11) NOT NULL,
  `name` varchar(255) DEFAULT NULL,
  `created_at` datetime DEFAULT current_timestamp(),
  `updated_at` datetime DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB AVG_ROW_LENGTH=4096 DEFAULT CHARSET=utf8 ROW_FORMAT=DYNAMIC;

--
-- Dumping data for table `master_validation_status`
--

INSERT INTO `master_validation_status` (`id`, `name`, `created_at`, `updated_at`) VALUES
(1, 'On Review', '2018-11-13 16:24:57', '2018-11-14 22:42:15'),
(2, 'Usia belum memenuhi syarat batas minimal', '2018-11-13 16:24:57', '2018-11-13 16:24:57'),
(3, 'Usia telah melewati syarat batas maksimal', '2018-11-13 16:24:57', '2018-11-13 16:24:57'),
(4, 'Perhitungan premi tidak sesuai', '2018-11-13 16:24:57', '2018-11-13 16:24:57');

-- --------------------------------------------------------

--
-- Table structure for table `migrations`
--

CREATE TABLE `migrations` (
  `id` int(10) UNSIGNED NOT NULL,
  `migration` varchar(191) COLLATE utf8mb4_unicode_ci NOT NULL,
  `batch` int(11) NOT NULL
) ENGINE=InnoDB AVG_ROW_LENGTH=2048 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci ROW_FORMAT=DYNAMIC;

--
-- Dumping data for table `migrations`
--

INSERT INTO `migrations` (`id`, `migration`, `batch`) VALUES
(1, '2014_10_12_000000_create_users_table', 1),
(2, '2014_10_12_100000_create_password_resets_table', 1),
(3, '2018_10_09_071017_create_klaims_table', 1),
(4, '2018_10_09_071028_create_penutupans_table', 1),
(5, '2018_10_09_082355_laratrust_setup_tables', 1),
(6, '2018_10_10_030948_create_banks_table', 1),
(7, '2018_10_10_031135_create_branches_table', 1),
(8, '2018_10_10_031153_create_products_table', 1);

-- --------------------------------------------------------

--
-- Table structure for table `password_resets`
--

CREATE TABLE `password_resets` (
  `email` varchar(191) COLLATE utf8mb4_unicode_ci NOT NULL,
  `token` varchar(191) COLLATE utf8mb4_unicode_ci NOT NULL,
  `created_at` timestamp NULL DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci ROW_FORMAT=DYNAMIC;

-- --------------------------------------------------------

--
-- Table structure for table `permissions`
--

CREATE TABLE `permissions` (
  `id` int(10) UNSIGNED NOT NULL,
  `name` varchar(191) COLLATE utf8mb4_unicode_ci NOT NULL,
  `display_name` varchar(191) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `description` varchar(191) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB AVG_ROW_LENGTH=390 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci ROW_FORMAT=DYNAMIC;

--
-- Dumping data for table `permissions`
--

INSERT INTO `permissions` (`id`, `name`, `display_name`, `description`, `created_at`, `updated_at`) VALUES
(1, 'can_view_root_menu_dashboard', 'View Menu Dashboard', 'Pengguna dapat membuka menu dashboard', '2018-10-10 03:52:23', '2019-03-21 16:26:44'),
(2, 'can_view_root_menu_upload', 'View Menu Upload', 'Pengguna dapat membuka menu upload', '2018-10-10 03:52:23', '2019-03-21 16:26:52'),
(3, 'can_view_sub_menu_upload_peserta', 'View Menu Upload Penutupan', 'Pengguna dapat membuka menu upload peserta baru', '2018-10-10 03:52:23', '2019-03-21 16:26:59'),
(4, 'can_view_sub_menu_upload_mutasi', 'View Menu Upload Mutasi', 'Pengguna dapat membuka menu upload mutasi rekening', '2018-10-10 03:52:23', '2019-03-21 16:27:06'),
(5, 'can_view_root_menu_peserta', 'View Menu Penutupan', 'Pengguna dapat membuka menu peserta', '2018-10-10 03:52:23', '2019-03-21 16:27:16'),
(6, 'can_view_sub_menu_list_peserta_bank', 'View Menu List Penutupan Bank', 'Pengguna dapat membuka menu list data peserta untuk bank', '2018-10-10 03:52:23', '2019-03-21 16:27:39'),
(7, 'can_view_sub_menu_list_datahold_peserta', 'View Menu List Datahold Penutupan Bank', 'Pengguna dapat membuka menu datahold peserta untuk bank', '2018-10-10 03:52:23', '2019-03-21 16:27:45'),
(8, 'can_view_sub_menu_list_peserta_ajb', 'View Menu List Penutupan AJB', 'Pengguna dapat membuka menu list data peserta untuk AJB', '2018-10-10 03:52:23', '2019-03-21 16:27:49'),
(9, 'can_view_root_menu_claim', 'View Menu Claim', 'Pengguna dapat membuka menu claim', '2018-10-10 03:52:23', '2019-03-21 16:27:57'),
(10, 'can_view_sub_menu_list_claim_bank', 'View Menu List Claim Bank', 'Pengguna dapat membuka menu list claim untuk bank', '2018-10-10 03:52:23', '2019-03-21 16:28:03'),
(12, 'can_view_sub_menu_input_claim', 'View Menu Input Claim', 'Pengguna dapat membuka menu input claim', '2018-11-23 10:05:28', '2019-03-21 16:28:08'),
(13, 'can_view_sub_menu_list_claim_ajb', 'View Menu List Claim AJB', 'Pengguna dapat membuka menu list claim untuk AJB', '2018-11-23 10:05:28', '2019-03-21 16:28:11'),
(14, 'can_view_root_menu_root_pelunasan', 'View Menu Pengaturan', 'Pengguna dapat membuka menu pengaturan', '2018-11-23 10:05:28', '2019-03-21 16:28:16'),
(15, 'can_view_sub_menu_list_pengajuan_pelunasan_bank', 'View Menu Akses', 'Pengguna dapat membuka menu akses', '2018-11-23 10:05:28', '2019-03-21 16:50:08'),
(16, 'can_view_sub_menu_input_pengajuan_pelunasan', 'View Menu Pengguna', 'Pengguna dapat membuka menu pemeliharaan data pengguna', '2018-11-23 10:05:28', '2019-03-21 16:50:19'),
(17, 'can_view_sub_menu_list_pengajuan_pelunasan_ajb', 'View Menu Role', 'Pengguna dapat membuka menu pemeliharaan data role', '2018-11-23 10:05:28', '2019-03-21 16:50:28'),
(18, 'can_view_root_menu_master_access', 'View Menu Permission', 'Pengguna dapat membuka menu pemeliharaan data permission', '2018-11-23 10:05:28', '2019-03-21 16:26:34'),
(19, 'can_view_sub_menu_pemeliharaan_user', 'View Menu Client', 'Pengguna dapat membuka menu client', '2018-11-23 10:05:28', '2019-03-21 16:51:12'),
(20, 'can_view_sub_menu_pemeliharaan_role', 'View Menu Bank', 'Pengguna dapat membuka menu pemeliharaan data bank', '2018-11-23 10:05:28', '2019-03-21 16:51:20'),
(21, 'can_view_sub_menu_pemeliharaan_permission', 'View Menu Kantor Cabang', 'Pengguna dapat membuka menu pemeliharaan data kantor cabang', '2018-11-23 10:05:28', '2019-03-21 16:51:26'),
(22, 'can_view_root_menu_master_client', 'View Menu Jenis Status', 'Pengguna dapat membuka menu pemeliharaan data jenis status', '2018-11-23 10:05:28', '2019-03-21 16:51:42'),
(23, 'can_view_sub_menu_pemeliharaan_bank', 'View Menu Jenis Asuransi', 'Pengguna dapat membuka menu pemeliharaan data jenis asuransi', '2018-11-23 10:05:28', '2019-03-21 16:51:50'),
(24, 'can_view_sub_menu_pemeliharaan_kantor_cabang', 'View Menu Status Validasi', 'Pengguna dapat membuka menu pemeliharaan data status validasi', '2018-11-23 10:05:28', '2019-03-21 16:51:59'),
(25, 'can_view_root_menu_master_jenis_status', 'View Menu Status Claim', 'Pengguna dapat membuka menu pemeliharaan data status claim', '2018-11-23 10:05:28', '2019-03-21 16:52:11'),
(26, 'can_view_sub_menu_pemeliharaan_jenis_asuransi', 'View Menu Status Loan', 'Pengguna dapat membuka menu pemeliharaan data status loan', '2018-11-23 10:05:28', '2019-03-21 16:52:47'),
(27, 'can_view_sub_menu_pemeliharaan_status_validasi', 'View Menu Rule Validasi', 'Pengguna dapat membuka menu pemeliharaan data rule validasi', '2018-11-23 10:05:28', '2019-03-21 16:53:02'),
(28, 'can_view_sub_menu_pemeliharaan_status_claim', 'View Menu Master Produk', 'Pengguna dapat membuka menu pemeliharaan data produk', '2018-11-23 10:05:28', '2019-03-21 16:53:11'),
(29, 'can_view_sub_menu_pemeliharaan_status_loan', 'View Menu Rate Asuransi', 'Pengguna dapat membuka menu pemeliharaan data rate asuransi', '2018-11-23 10:05:28', '2019-03-21 16:53:17'),
(30, 'can_view_sub_menu_pemeliharaan_rule_validasi', 'View Menu Mapping', 'Pengguna dapat membuka menu pemeliharaan data mapping produk dengan jenis asurnasi', '2018-11-23 10:05:28', '2019-03-21 16:53:25'),
(31, 'can_view_root_menu_master_produk_rate', 'View Menu Report', 'Pengguna dapat membuka menu report', '2018-11-23 10:05:28', '2019-03-21 16:53:40'),
(32, 'can_view_sub_menu_pemeliharaan_produk', NULL, NULL, '2019-03-21 16:53:51', '2019-03-21 16:53:51'),
(33, 'can_view_sub_menu_pemeliharaan_rate_asuransi', NULL, NULL, '2019-03-21 16:54:00', '2019-03-21 16:54:00'),
(34, 'can_view_sub_menu_pemeliharaan_mapping_produk', NULL, NULL, '2019-03-21 16:54:08', '2019-03-21 16:54:08'),
(35, 'can_view_root_menu_laporan', NULL, NULL, '2019-03-21 16:54:25', '2019-03-21 16:54:25'),
(36, 'can_view_sub_menu_laporan_peserta_bank', NULL, NULL, '2019-03-21 16:54:46', '2019-03-21 16:55:39'),
(37, 'can_view_sub_menu_laporan_claim_bank', NULL, NULL, '2019-03-21 16:54:54', '2019-03-21 16:55:42'),
(38, 'can_view_sub_menu_laporan_nominatif_premi_pertanggungan_bank', NULL, NULL, '2019-03-21 16:55:11', '2019-03-21 16:55:45'),
(39, 'can_view_sub_menu_laporan_nominatif_claim_bank', NULL, NULL, '2019-03-21 16:55:24', '2019-03-21 16:55:48'),
(40, 'can_view_sub_menu_laporan_peserta_ajb', NULL, NULL, '2019-03-21 16:55:54', '2019-03-21 16:55:54'),
(41, 'can_view_sub_menu_laporan_claim_ajb', NULL, NULL, '2019-03-21 16:56:00', '2019-03-21 16:56:00'),
(42, 'can_view_sub_menu_laporan_nominatif_premi_pertanggungan_ajb', NULL, NULL, '2019-03-21 16:56:07', '2019-03-21 16:56:07'),
(43, 'can_view_sub_menu_laporan_nominatif_claim_ajb', NULL, NULL, '2019-03-21 16:56:20', '2019-03-21 16:56:20'),
(44, 'can_view_sub_menu_download_pst', NULL, NULL, '2019-03-21 16:56:39', '2019-03-21 16:56:39');

-- --------------------------------------------------------

--
-- Table structure for table `permission_role`
--

CREATE TABLE `permission_role` (
  `permission_id` int(10) UNSIGNED NOT NULL,
  `role_id` int(10) UNSIGNED NOT NULL
) ENGINE=InnoDB AVG_ROW_LENGTH=197 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci ROW_FORMAT=DYNAMIC;

--
-- Dumping data for table `permission_role`
--

INSERT INTO `permission_role` (`permission_id`, `role_id`) VALUES
(1, 1),
(1, 2),
(1, 3),
(1, 4),
(1, 5),
(2, 4),
(2, 5),
(3, 5),
(4, 4),
(5, 3),
(5, 4),
(5, 5),
(6, 4),
(6, 5),
(7, 4),
(7, 5),
(8, 3),
(9, 3),
(9, 4),
(9, 5),
(10, 4),
(10, 5),
(12, 5),
(13, 3),
(14, 3),
(14, 4),
(14, 5),
(15, 4),
(15, 5),
(16, 5),
(17, 3),
(18, 1),
(18, 2),
(19, 1),
(19, 2),
(20, 1),
(20, 2),
(21, 1),
(21, 2),
(22, 1),
(22, 2),
(23, 1),
(23, 2),
(24, 1),
(24, 2),
(25, 1),
(25, 2),
(26, 1),
(26, 2),
(27, 1),
(27, 2),
(28, 1),
(28, 2),
(29, 1),
(29, 2),
(30, 1),
(30, 2),
(31, 1),
(31, 2),
(32, 1),
(32, 2),
(33, 1),
(33, 2),
(34, 1),
(34, 2),
(35, 2),
(35, 3),
(35, 4),
(35, 5),
(36, 4),
(36, 5),
(37, 4),
(37, 5),
(38, 4),
(38, 5),
(39, 4),
(39, 5),
(40, 3),
(41, 3),
(42, 3),
(43, 3),
(44, 2),
(44, 3);

-- --------------------------------------------------------

--
-- Table structure for table `permission_user`
--

CREATE TABLE `permission_user` (
  `permission_id` int(10) UNSIGNED NOT NULL,
  `user_id` int(10) UNSIGNED NOT NULL,
  `user_type` varchar(191) COLLATE utf8mb4_unicode_ci NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci ROW_FORMAT=DYNAMIC;

-- --------------------------------------------------------

--
-- Table structure for table `roles`
--

CREATE TABLE `roles` (
  `id` int(10) UNSIGNED NOT NULL,
  `name` varchar(191) COLLATE utf8mb4_unicode_ci NOT NULL,
  `display_name` varchar(191) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `description` varchar(191) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL
) ENGINE=InnoDB AVG_ROW_LENGTH=3276 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci ROW_FORMAT=DYNAMIC;

--
-- Dumping data for table `roles`
--

INSERT INTO `roles` (`id`, `name`, `display_name`, `description`, `created_at`, `updated_at`) VALUES
(1, 'ROLE_ADMINISTRATOR', 'ADMINISTRATOR', 'Administrator untuk AJB', '2018-10-10 03:52:23', '2018-11-23 09:37:50'),
(2, 'ROLE_INSURANCE_ADMIN', 'Admin Asuransi', 'Admin Asuransi', '2018-10-10 03:52:23', '2018-10-10 03:52:23'),
(3, 'ROLE_INSURANCE_OPERATOR', 'Operator Asuransi', 'User non admin Asuransi', '2018-10-10 03:52:23', '2018-10-10 03:52:23'),
(4, 'ROLE_CLIENTKP', 'Client KP', 'User bank untuk kantor pusat', '2018-10-10 03:52:23', '2018-10-10 03:52:23'),
(5, 'ROLE_CLIENTCABANG', 'Client Cabang', 'User bank untuk kantor cabang', '2018-10-10 03:52:23', '2018-10-10 03:52:23');

-- --------------------------------------------------------

--
-- Table structure for table `role_user`
--

CREATE TABLE `role_user` (
  `role_id` int(10) UNSIGNED NOT NULL,
  `user_id` int(10) UNSIGNED NOT NULL,
  `user_type` varchar(191) COLLATE utf8mb4_unicode_ci NOT NULL
) ENGINE=InnoDB AVG_ROW_LENGTH=1489 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci ROW_FORMAT=DYNAMIC;

--
-- Dumping data for table `role_user`
--

INSERT INTO `role_user` (`role_id`, `user_id`, `user_type`) VALUES
(1, 1, 'App\\User'),
(4, 2, 'App\\User'),
(5, 3, 'App\\User'),
(5, 4, 'App\\User'),
(5, 5, 'App\\User'),
(5, 6, 'App\\User'),
(5, 7, 'App\\User'),
(5, 8, 'App\\User'),
(3, 10, 'App\\User'),
(3, 11, 'App\\User'),
(2, 12, 'App\\User'),
(2, 13, 'App\\User'),
(3, 15, 'App\\User'),
(4, 16, 'App\\User'),
(5, 17, 'App\\User');

-- --------------------------------------------------------

--
-- Table structure for table `staging_members`
--

CREATE TABLE `staging_members` (
  `id` int(11) UNSIGNED NOT NULL,
  `no_loan` varchar(50) CHARACTER SET utf8 DEFAULT NULL,
  `nama_cabang` varchar(200) CHARACTER SET utf8 DEFAULT NULL,
  `insurance_id` varchar(3) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `kode_produk` varchar(50) CHARACTER SET utf8 NOT NULL,
  `nama_produk` varchar(200) CHARACTER SET utf8 DEFAULT NULL,
  `cif` varchar(50) CHARACTER SET utf8 DEFAULT NULL,
  `nama_nasabah` varchar(200) CHARACTER SET utf8 DEFAULT NULL,
  `beban_nasabah` decimal(30,2) DEFAULT 0.00,
  `beban_bank` decimal(30,2) DEFAULT 0.00,
  `nominal_loan` decimal(30,2) DEFAULT 0.00,
  `pertanggungan` decimal(30,2) DEFAULT 0.00,
  `kurs` varchar(3) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `tenor` int(11) DEFAULT 0,
  `tgl_mulai` date DEFAULT NULL,
  `tgl_selesai` date DEFAULT NULL,
  `no_rekening` varchar(50) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `tgl_lahir` date DEFAULT NULL,
  `tempat_lahir` varchar(200) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `pekerjaan` varchar(200) CHARACTER SET utf8 DEFAULT NULL,
  `periode_upload` date DEFAULT NULL,
  `bank_id` varchar(3) CHARACTER SET utf8 DEFAULT NULL,
  `branch_id` varchar(10) CHARACTER SET utf8 DEFAULT NULL,
  `rounding_age` int(11) DEFAULT 0,
  `val_min_age` int(11) DEFAULT 0,
  `rounding_jw` int(11) DEFAULT 0,
  `sum_age_jw` int(10) DEFAULT 0,
  `val_max_age` int(11) DEFAULT 0,
  `result_rate` decimal(10,2) DEFAULT NULL,
  `result_pertanggungan` decimal(20,2) DEFAULT 0.00,
  `val_pertanggungan` int(11) DEFAULT 0,
  `validation_status_id` int(11) DEFAULT 1,
  `member_id` varchar(25) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB AVG_ROW_LENGTH=5461 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci ROW_FORMAT=DYNAMIC;

--
-- Dumping data for table `staging_members`
--

INSERT INTO `staging_members` (`id`, `no_loan`, `nama_cabang`, `insurance_id`, `kode_produk`, `nama_produk`, `cif`, `nama_nasabah`, `beban_nasabah`, `beban_bank`, `nominal_loan`, `pertanggungan`, `kurs`, `tenor`, `tgl_mulai`, `tgl_selesai`, `no_rekening`, `tgl_lahir`, `tempat_lahir`, `pekerjaan`, `periode_upload`, `bank_id`, `branch_id`, `rounding_age`, `val_min_age`, `rounding_jw`, `sum_age_jw`, `val_max_age`, `result_rate`, `result_pertanggungan`, `val_pertanggungan`, `validation_status_id`, `member_id`, `created_at`, `updated_at`) VALUES
(130, '311013', 'KCP KALANGSARI', 'AJB', 'INSPN', 'KREDIT UMUM PENSIUNAN (KUPEN)', '503200', 'MICHAEL SUNANG', '300000.00', '0.00', '100000000.00', '100000000.00', 'IDR', 180, '2020-11-06', '2035-11-06', '111222333444', '1950-10-14', 'TASIKMALAYA', 'PENSIONS', '2020-11-06', '212', '110', 70, 0, 15, 85, 0, NULL, '0.00', 1, 1, 'AJB21211020201116ERD7NCGY', '2020-11-16 05:41:33', '2020-11-16 05:41:33'),
(131, '311014', 'KCP KALANGSARI', 'AJB', 'INSPP', 'KREDIT UMUM PENSIUNAN (KUPEN)', '502942', 'JOHN SUNANG', '300000.00', '0.00', '100000000.00', '100000000.00', 'IDR', 120, '2020-11-06', '2030-11-06', '222333444555', '1951-10-14', 'TASIKMALAYA', 'PENSIONS', '2020-11-06', '212', '110', 69, 0, 10, 79, 0, NULL, '0.00', 1, 1, 'AJB212110202011166PRC4D5B', '2020-11-16 05:41:33', '2020-11-16 05:41:33');

-- --------------------------------------------------------

--
-- Table structure for table `staging_mutasi`
--

CREATE TABLE `staging_mutasi` (
  `trx_date` date DEFAULT NULL,
  `loan_id` varchar(20) DEFAULT NULL,
  `bank_id` varchar(3) DEFAULT NULL,
  `branch_id` varchar(3) DEFAULT NULL,
  `nominal` decimal(30,2) DEFAULT NULL,
  `created_at` datetime DEFAULT current_timestamp(),
  `updated_at` datetime DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB AVG_ROW_LENGTH=100 DEFAULT CHARSET=utf8 ROW_FORMAT=DYNAMIC;

--
-- Dumping data for table `staging_mutasi`
--

INSERT INTO `staging_mutasi` (`trx_date`, `loan_id`, `bank_id`, `branch_id`, `nominal`, `created_at`, `updated_at`) VALUES
('2018-10-01', 'GEN1192018070003', '212', '110', '16240000.00', '2019-03-21 10:00:09', '2019-03-21 10:00:09'),
('2018-10-01', 'GEN1412018070002', '212', '110', '17566000.00', '2019-03-21 10:00:09', '2019-03-21 10:00:09'),
('2018-10-01', 'GEN1422018070065', '212', '144', '1718400.00', '2019-03-21 10:00:09', '2019-03-21 10:00:09'),
('2018-10-01', 'GEN1452018070001', '212', '111', '13837000.00', '2019-03-21 10:00:09', '2019-03-21 10:00:09'),
('2018-10-01', 'GEN1472018070001', '212', '111', '8020950.00', '2019-03-21 10:00:09', '2019-03-21 10:00:09'),
('2018-10-01', 'GEN1502018070001', '212', '111', '16240000.00', '2019-03-21 10:00:09', '2019-03-21 10:00:09'),
('2018-10-01', 'GEN1802018070002', '212', '111', '16240000.00', '2019-03-21 10:00:09', '2019-03-21 10:00:09'),
('2018-10-01', 'GEN1812018070001', '212', '110', '16225000.00', '2019-03-21 10:00:09', '2019-03-21 10:00:09'),
('2018-10-01', 'GEN1812018070006', '212', '111', '9890100.00', '2019-03-21 10:00:09', '2019-03-21 10:00:09'),
('2018-10-01', 'GEN1812018070008', '212', '111', '15278000.00', '2019-03-21 10:00:09', '2019-03-21 10:00:09'),
('2018-10-01', 'GEN1812018070016', '212', '140', '17524000.00', '2019-03-21 10:00:09', '2019-03-21 10:00:09'),
('2018-10-01', 'GEN2112018070006', '212', '111', '15977000.00', '2019-03-21 10:00:09', '2019-03-21 10:00:09'),
('2018-10-01', 'GEN2142018070001', '212', '110', '627000.00', '2019-03-21 10:00:09', '2019-03-21 10:00:09'),
('2018-10-01', 'GEN2142018070030', '212', '145', '15666000.00', '2019-03-21 10:00:09', '2019-03-21 10:00:09'),
('2018-10-01', 'GEN2312018070004', '212', '110', '13445000.00', '2019-03-21 10:00:09', '2019-03-21 10:00:09'),
('2018-10-01', 'GEN2312018070005', '212', '110', '138500.00', '2019-03-21 10:00:09', '2019-03-21 10:00:09'),
('2018-10-01', 'GEN2312018070007', '212', '111', '11982750.00', '2019-03-21 10:00:09', '2019-03-21 10:00:09'),
('2018-10-01', 'GEN2322018070005', '212', '111', '14810000.00', '2019-03-21 10:00:09', '2019-03-21 10:00:09'),
('2018-10-01', 'GEN2322018070006', '212', '111', '16225000.00', '2019-03-21 10:00:09', '2019-03-21 10:00:09'),
('2018-10-01', 'GEN2322018070009', '212', '111', '16163000.00', '2019-03-21 10:00:09', '2019-03-21 10:00:09'),
('2018-10-01', 'GEN2322018070010', '212', '111', '17524000.00', '2019-03-21 10:00:09', '2019-03-21 10:00:09'),
('2018-10-01', 'GEN2322018070011', '212', '112', '15977000.00', '2019-03-21 10:00:09', '2019-03-21 10:00:09'),
('2018-10-01', 'GEN2322018070012', '212', '112', '15977000.00', '2019-03-21 10:00:09', '2019-03-21 10:00:09'),
('2018-10-01', 'GEN2322018070021', '212', '112', '16240000.00', '2019-03-21 10:00:09', '2019-03-21 10:00:09'),
('2018-10-01', 'GEN2322018070022', '212', '112', '16225000.00', '2019-03-21 10:00:09', '2019-03-21 10:00:09'),
('2018-10-01', 'GEN2322018070023', '212', '140', '11474325.00', '2019-03-21 10:00:09', '2019-03-21 10:00:09'),
('2018-10-01', 'GEN2322018070024', '212', '140', '12296200.00', '2019-03-21 10:00:09', '2019-03-21 10:00:09'),
('2018-10-01', 'GEN2342018070011', '212', '111', '7717275.00', '2019-03-21 10:00:09', '2019-03-21 10:00:09'),
('2018-10-01', 'GEN2352018070003', '212', '111', '14810000.00', '2019-03-21 10:00:09', '2019-03-21 10:00:09'),
('2018-10-01', 'GEN2372018070007', '212', '110', '17595000.00', '2019-03-21 10:00:09', '2019-03-21 10:00:09'),
('2018-10-01', 'GEN2372018070016', '212', '111', '7267268.00', '2019-03-21 10:00:09', '2019-03-21 10:00:09'),
('2018-10-01', 'GEN2372018070018', '212', '111', '9167390.00', '2019-03-21 10:00:09', '2019-03-21 10:00:09'),
('2018-10-01', 'GEN2372018070027', '212', '112', '16240000.00', '2019-03-21 10:00:09', '2019-03-21 10:00:09'),
('2018-10-01', 'GEN2372018070040', '212', '140', '14810000.00', '2019-03-21 10:00:09', '2019-03-21 10:00:09'),
('2018-10-01', 'GEN2372018070056', '212', '144', '9738832.50', '2019-03-21 10:00:09', '2019-03-21 10:00:09'),
('2018-10-01', 'GEN2502018070001', '212', '110', '1045000.00', '2019-03-21 10:00:09', '2019-03-21 10:00:09'),
('2018-10-01', 'GEN2512018070036', '212', '145', '16163000.00', '2019-03-21 10:00:09', '2019-03-21 10:00:09'),
('2018-10-01', 'GEN2532018070002', '212', '111', '1738800.00', '2019-03-21 10:00:09', '2019-03-21 10:00:09'),
('2018-10-01', 'GEN2612018070001', '212', '110', '17566000.00', '2019-03-21 10:00:09', '2019-03-21 10:00:09'),
('2018-10-01', 'GEN2612018070003', '212', '110', '16240000.00', '2019-03-21 10:00:09', '2019-03-21 10:00:09'),
('2018-10-01', 'GEN2612018070009', '212', '110', '16240000.00', '2019-03-21 10:00:09', '2019-03-21 10:00:09'),
('2018-10-01', 'GEN2612018070011', '212', '112', '14985000.00', '2019-03-21 10:00:09', '2019-03-21 10:00:09'),
('2018-10-01', 'GEN2612018070013', '212', '112', '10140625.00', '2019-03-21 10:00:09', '2019-03-21 10:00:09'),
('2018-10-01', 'GEN2612018070015', '212', '140', '10465125.00', '2019-03-21 10:00:09', '2019-03-21 10:00:09'),
('2018-10-01', 'GEN2612018070021', '212', '140', '16580000.00', '2019-03-21 10:00:09', '2019-03-21 10:00:09'),
('2018-10-01', 'GEN2612018070027', '212', '145', '11718175.00', '2019-03-21 10:00:09', '2019-03-21 10:00:09'),
('2018-10-01', 'GEN2622018070001', '212', '111', '16163000.00', '2019-03-21 10:00:09', '2019-03-21 10:00:09'),
('2018-10-01', 'GEN2622018070002', '212', '110', '15278000.00', '2019-03-21 10:00:09', '2019-03-21 10:00:09'),
('2018-10-01', 'GEN2622018070004', '212', '111', '14206000.00', '2019-03-21 10:00:09', '2019-03-21 10:00:09'),
('2018-10-01', 'GEN2622018070006', '212', '112', '16225000.00', '2019-03-21 10:00:09', '2019-03-21 10:00:09'),
('2018-10-01', 'GEN2622018070007', '212', '140', '14810000.00', '2019-03-21 10:00:09', '2019-03-21 10:00:09'),
('2018-10-01', 'GEN2622018070009', '212', '140', '11819912.50', '2019-03-21 10:00:09', '2019-03-21 10:00:09'),
('2018-10-01', 'GEN2622018070013', '212', '140', '10463000.00', '2019-03-21 10:00:09', '2019-03-21 10:00:09'),
('2018-10-01', 'GEN2622018070015', '212', '145', '15666000.00', '2019-03-21 10:00:09', '2019-03-21 10:00:09'),
('2018-10-01', 'GEN2632018070002', '212', '110', '14985000.00', '2019-03-21 10:00:09', '2019-03-21 10:00:09'),
('2018-10-01', 'GEN2632018070003', '212', '110', '16240000.00', '2019-03-21 10:00:09', '2019-03-21 10:00:09'),
('2018-10-01', 'GEN2632018070007', '212', '112', '10951750.00', '2019-03-21 10:00:09', '2019-03-21 10:00:09'),
('2018-10-01', 'GEN2632018070012', '212', '140', '16073000.00', '2019-03-21 10:00:09', '2019-03-21 10:00:09'),
('2018-10-01', 'GEN2642018070013', '212', '140', '16240000.00', '2019-03-21 10:00:09', '2019-03-21 10:00:09'),
('2018-10-01', 'GEN2642018070015', '212', '140', '16240000.00', '2019-03-21 10:00:09', '2019-03-21 10:00:09'),
('2018-10-01', 'GEN2642018070019', '212', '144', '12054750.00', '2019-03-21 10:00:09', '2019-03-21 10:00:09'),
('2018-10-01', 'GEN2662018070001', '212', '110', '15977000.00', '2019-03-21 10:00:09', '2019-03-21 10:00:09'),
('2018-10-01', 'GEN2662018070009', '212', '144', '16240000.00', '2019-03-21 10:00:09', '2019-03-21 10:00:09'),
('2018-10-01', 'GEN2672018070001', '212', '111', '17595000.00', '2019-03-21 10:00:09', '2019-03-21 10:00:09'),
('2018-10-01', 'GEN2672018070005', '212', '112', '14985000.00', '2019-03-21 10:00:09', '2019-03-21 10:00:09'),
('2018-10-01', 'GEN2672018070006', '212', '112', '16163000.00', '2019-03-21 10:00:09', '2019-03-21 10:00:09'),
('2018-10-01', 'GEN2672018070012', '212', '145', '17595000.00', '2019-03-21 10:00:09', '2019-03-21 10:00:09'),
('2018-10-01', 'GEN2672018070013', '212', '145', '16240000.00', '2019-03-21 10:00:09', '2019-03-21 10:00:09'),
('2018-10-01', 'GEN2672018070019', '212', '144', '16225000.00', '2019-03-21 10:00:09', '2019-03-21 10:00:09'),
('2018-10-01', 'GEN2672018070020', '212', '144', '17332000.00', '2019-03-21 10:00:09', '2019-03-21 10:00:09'),
('2018-10-01', 'GEN2682018070001', '212', '110', '17524000.00', '2019-03-21 10:00:09', '2019-03-21 10:00:09'),
('2018-10-01', 'GEN2682018070003', '212', '110', '16240000.00', '2019-03-21 10:00:09', '2019-03-21 10:00:09'),
('2018-10-01', 'GEN2682018070004', '212', '110', '17595000.00', '2019-03-21 10:00:09', '2019-03-21 10:00:09'),
('2018-10-01', 'GEN2682018070012', '212', '140', '16163000.00', '2019-03-21 10:00:09', '2019-03-21 10:00:09'),
('2018-10-01', 'GEN2702018070001', '212', '110', '17524000.00', '2019-03-21 10:00:09', '2019-03-21 10:00:09'),
('2018-10-01', 'GEN2702018070017', '212', '144', '17524000.00', '2019-03-21 10:00:09', '2019-03-21 10:00:09'),
('2018-10-01', 'GEN3002018070001', '212', '110', '16240000.00', '2019-03-21 10:00:09', '2019-03-21 10:00:09'),
('2018-10-01', 'GEN3002018070002', '212', '110', '17566000.00', '2019-03-21 10:00:09', '2019-03-21 10:00:09'),
('2018-10-01', 'GEN3002018070004', '212', '110', '8923500.00', '2019-03-21 10:00:09', '2019-03-21 10:00:09'),
('2018-10-01', 'GEN3002018070007', '212', '112', '14206000.00', '2019-03-21 10:00:09', '2019-03-21 10:00:09'),
('2018-10-01', 'GEN3002018070017', '212', '112', '16225000.00', '2019-03-21 10:00:09', '2019-03-21 10:00:09'),
('2018-10-01', 'GEN3002018070018', '212', '112', '8791875.00', '2019-03-21 10:00:09', '2019-03-21 10:00:09'),
('2018-10-01', 'GEN3002018070025', '212', '140', '17566000.00', '2019-03-21 10:00:09', '2019-03-21 10:00:09'),
('2018-10-01', 'GEN3002018070038', '212', '145', '10399200.00', '2019-03-21 10:00:09', '2019-03-21 10:00:09'),
('2018-10-01', 'GEN3002018070039', '212', '145', '17566000.00', '2019-03-21 10:00:09', '2019-03-21 10:00:09'),
('2018-10-01', 'GEN3012018070001', '212', '110', '17524000.00', '2019-03-21 10:00:09', '2019-03-21 10:00:09'),
('2018-10-01', 'GEN3012018070006', '212', '112', '8616300.00', '2019-03-21 10:00:09', '2019-03-21 10:00:09'),
('2018-10-01', 'GEN3012018070007', '212', '112', '10411875.00', '2019-03-21 10:00:09', '2019-03-21 10:00:09'),
('2018-10-01', 'GEN3012018070011', '212', '140', '6987685.00', '2019-03-21 10:00:09', '2019-03-21 10:00:09'),
('2018-10-01', 'GEN3022018070001', '212', '110', '14985000.00', '2019-03-21 10:00:09', '2019-03-21 10:00:09'),
('2018-10-01', 'GEN3022018070003', '212', '110', '13837000.00', '2019-03-21 10:00:09', '2019-03-21 10:00:09'),
('2018-10-01', 'GEN3022018070009', '212', '112', '17332000.00', '2019-03-21 10:00:09', '2019-03-21 10:00:09'),
('2018-10-01', 'GEN3022018070019', '212', '140', '13837000.00', '2019-03-21 10:00:09', '2019-03-21 10:00:09'),
('2018-10-01', 'GEN3022018070023', '212', '145', '14985000.00', '2019-03-21 10:00:09', '2019-03-21 10:00:09'),
('2018-10-01', 'GEN3042018070001', '212', '110', '11357500.00', '2019-03-21 10:00:09', '2019-03-21 10:00:09'),
('2018-10-01', 'GEN3042018070003', '212', '111', '14067000.00', '2019-03-21 10:00:09', '2019-03-21 10:00:09'),
('2018-10-01', 'GEN3042018070004', '212', '112', '14904000.00', '2019-03-21 10:00:09', '2019-03-21 10:00:09'),
('2018-10-01', 'GEN3042018070008', '212', '140', '17332000.00', '2019-03-21 10:00:09', '2019-03-21 10:00:09'),
('2018-10-01', 'GEN3042018070021', '212', '144', '8932000.00', '2019-03-21 10:00:09', '2019-03-21 10:00:09'),
('2018-10-01', 'GEN3052018070001', '212', '110', '14985000.00', '2019-03-21 10:00:09', '2019-03-21 10:00:09'),
('2018-10-01', 'GEN3052018070002', '212', '111', '5818200.00', '2019-03-21 10:00:09', '2019-03-21 10:00:09'),
('2018-10-01', 'GEN3062018070002', '212', '140', '7299017.50', '2019-03-21 10:00:09', '2019-03-21 10:00:09'),
('2018-10-01', 'GEN3072018070001', '212', '110', '16240000.00', '2019-03-21 10:00:09', '2019-03-21 10:00:09'),
('2018-10-01', 'GEN3072018070009', '212', '145', '10539600.00', '2019-03-21 10:00:09', '2019-03-21 10:00:09'),
('2018-10-01', 'GEN3072018070013', '212', '144', '17566000.00', '2019-03-21 10:00:09', '2019-03-21 10:00:09'),
('2018-10-01', 'GEN3072018070015', '212', '144', '15425000.00', '2019-03-21 10:00:09', '2019-03-21 10:00:09'),
('2018-10-01', 'GEN3082018070002', '212', '140', '13837000.00', '2019-03-21 10:00:09', '2019-03-21 10:00:09'),
('2018-10-01', 'GEN3092018070001', '212', '112', '7394750.00', '2019-03-21 10:00:09', '2019-03-21 10:00:09'),
('2018-10-01', 'GEN3102018070033', '212', '144', '16240000.00', '2019-03-21 10:00:09', '2019-03-21 10:00:09'),
('2018-10-01', 'GEN3102018070037', '212', '144', '16999000.00', '2019-03-21 10:00:09', '2019-03-21 10:00:09'),
('2018-10-01', 'GEN3102018070042', '212', '144', '429600.00', '2019-03-21 10:00:09', '2019-03-21 10:00:09'),
('2018-10-01', 'GEN3122018070001', '212', '112', '14985000.00', '2019-03-21 10:00:09', '2019-03-21 10:00:09'),
('2018-10-01', 'GEN3122018070013', '212', '144', '16073000.00', '2019-03-21 10:00:09', '2019-03-21 10:00:09'),
('2018-10-01', 'GEN3142018070003', '212', '112', '16240000.00', '2019-03-21 10:00:09', '2019-03-21 10:00:09'),
('2018-10-01', 'GEN3152018070011', '212', '144', '14985000.00', '2019-03-21 10:00:09', '2019-03-21 10:00:09'),
('2018-10-01', 'GEN3302018070016', '212', '145', '13837000.00', '2019-03-21 10:00:09', '2019-03-21 10:00:09'),
('2018-10-01', 'GEN3322018070009', '212', '145', '14985000.00', '2019-03-21 10:00:09', '2019-03-21 10:00:09'),
('2018-10-01', 'GEN3402018070002', '212', '110', '17332000.00', '2019-03-21 10:00:09', '2019-03-21 10:00:09'),
('2018-10-01', 'GEN3402018070020', '212', '140', '9339975.00', '2019-03-21 10:00:09', '2019-03-21 10:00:09'),
('2018-10-01', 'GEN3402018070031', '212', '144', '11238750.00', '2019-03-21 10:00:09', '2019-03-21 10:00:09'),
('2018-10-01', 'GEN3412018070006', '212', '112', '11774000.00', '2019-03-21 10:00:09', '2019-03-21 10:00:09'),
('2018-10-01', 'GEN3422018070007', '212', '140', '11828700.00', '2019-03-21 10:00:09', '2019-03-21 10:00:09'),
('2018-10-01', 'GEN3432018070004', '212', '110', '17566000.00', '2019-03-21 10:00:09', '2019-03-21 10:00:09'),
('2018-10-01', 'GEN3432018070009', '212', '140', '16163000.00', '2019-03-21 10:00:09', '2019-03-21 10:00:09'),
('2018-10-01', 'GEN3432018070014', '212', '145', '10465430.00', '2019-03-21 10:00:09', '2019-03-21 10:00:09'),
('2018-10-01', 'GEN3432018070020', '212', '144', '16240000.00', '2019-03-21 10:00:09', '2019-03-21 10:00:09'),
('2018-10-01', 'GEN3502018070002', '212', '110', '17595000.00', '2019-03-21 10:00:09', '2019-03-21 10:00:09'),
('2018-10-01', 'GEN3502018070003', '212', '110', '14985000.00', '2019-03-21 10:00:09', '2019-03-21 10:00:09'),
('2018-10-01', 'GEN3502018070018', '212', '111', '15278000.00', '2019-03-21 10:00:09', '2019-03-21 10:00:09'),
('2018-10-01', 'GEN3512018070005', '212', '111', '17566000.00', '2019-03-21 10:00:09', '2019-03-21 10:00:09'),
('2018-10-01', 'GEN3512018070025', '212', '145', '12772000.00', '2019-03-21 10:00:09', '2019-03-21 10:00:09'),
('2018-10-01', 'GEN3522018070004', '212', '111', '15278000.00', '2019-03-21 10:00:09', '2019-03-21 10:00:09'),
('2018-10-01', 'GEN3522018070006', '212', '112', '14985000.00', '2019-03-21 10:00:09', '2019-03-21 10:00:09'),
('2018-10-01', 'GEN3522018070013', '212', '140', '16240000.00', '2019-03-21 10:00:09', '2019-03-21 10:00:09'),
('2018-10-01', 'GEN3532018070001', '212', '110', '9735000.00', '2019-03-21 10:00:09', '2019-03-21 10:00:09'),
('2018-10-01', 'GEN3532018070016', '212', '145', '15977000.00', '2019-03-21 10:00:09', '2019-03-21 10:00:09'),
('2018-10-01', 'GEN3532018070017', '212', '145', '14985000.00', '2019-03-21 10:00:09', '2019-03-21 10:00:09'),
('2018-10-01', 'GEN3532018070024', '212', '145', '8616375.00', '2019-03-21 10:00:09', '2019-03-21 10:00:09'),
('2018-10-01', 'GEN3532018070027', '212', '144', '14985000.00', '2019-03-21 10:00:09', '2019-03-21 10:00:09'),
('2018-10-01', 'GEN3542018070002', '212', '111', '16240000.00', '2019-03-21 10:00:09', '2019-03-21 10:00:09'),
('2018-10-01', 'GEN3542018070028', '212', '140', '16073000.00', '2019-03-21 10:00:09', '2019-03-21 10:00:09'),
('2018-10-01', 'GEN3542018070047', '212', '145', '17524000.00', '2019-03-21 10:00:09', '2019-03-21 10:00:09'),
('2018-10-01', 'GEN3542018070050', '212', '144', '15977000.00', '2019-03-21 10:00:09', '2019-03-21 10:00:09'),
('2018-10-01', 'GEN3562018070004', '212', '112', '15666000.00', '2019-03-21 10:00:09', '2019-03-21 10:00:09'),
('2018-10-01', 'GEN3562018070015', '212', '145', '14985000.00', '2019-03-21 10:00:09', '2019-03-21 10:00:09'),
('2018-10-01', 'GEN3572018070001', '212', '111', '17332000.00', '2019-03-21 10:00:09', '2019-03-21 10:00:09'),
('2018-10-01', 'GEN3602018070007', '212', '111', '16240000.00', '2019-03-21 10:00:09', '2019-03-21 10:00:09'),
('2018-10-01', 'GEN3602018070010', '212', '111', '10546250.00', '2019-03-21 10:00:09', '2019-03-21 10:00:09'),
('2018-10-01', 'GEN3602018070019', '212', '140', '13837000.00', '2019-03-21 10:00:09', '2019-03-21 10:00:09'),
('2018-10-01', 'GEN3612018070018', '212', '145', '8912641.50', '2019-03-21 10:00:09', '2019-03-21 10:00:09'),
('2018-10-01', 'GEN3612018070023', '212', '145', '16240000.00', '2019-03-21 10:00:09', '2019-03-21 10:00:09'),
('2018-10-01', 'GEN3622018070024', '212', '145', '9744000.00', '2019-03-21 10:00:09', '2019-03-21 10:00:09'),
('2018-10-01', 'GEN3702018070003', '212', '110', '6577580.00', '2019-03-21 10:00:09', '2019-03-21 10:00:09'),
('2018-10-01', 'GEN3702018070012', '212', '140', '8991000.00', '2019-03-21 10:00:09', '2019-03-21 10:00:09'),
('2018-10-01', 'GEN3702018070015', '212', '140', '8102900.00', '2019-03-21 10:00:09', '2019-03-21 10:00:09'),
('2018-10-01', 'GEN3712018070018', '212', '145', '11314100.00', '2019-03-21 10:00:09', '2019-03-21 10:00:09'),
('2018-10-01', 'GEN3712018070019', '212', '145', '16240000.00', '2019-03-21 10:00:09', '2019-03-21 10:00:09'),
('2018-10-01', 'GEN3722018070004', '212', '140', '17595000.00', '2019-03-21 10:00:09', '2019-03-21 10:00:09'),
('2018-10-01', 'GEN3722018070011', '212', '144', '14985000.00', '2019-03-21 10:00:09', '2019-03-21 10:00:09'),
('2018-10-01', 'GEN4002018070008', '212', '112', '15977000.00', '2019-03-21 10:00:09', '2019-03-21 10:00:09'),
('2018-10-01', 'GEN4002018070010', '212', '112', '14985000.00', '2019-03-21 10:00:09', '2019-03-21 10:00:09'),
('2018-10-01', 'GEN4002018070014', '212', '140', '14985000.00', '2019-03-21 10:00:09', '2019-03-21 10:00:09'),
('2018-10-01', 'GEN4002018070025', '212', '144', '15666000.00', '2019-03-21 10:00:09', '2019-03-21 10:00:09');

-- --------------------------------------------------------

--
-- Table structure for table `staging_polis`
--

CREATE TABLE `staging_polis` (
  `id` int(11) UNSIGNED NOT NULL,
  `bank_id` varchar(3) CHARACTER SET utf8 DEFAULT NULL,
  `loan_id` varchar(20) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `polis_number` varchar(50) CHARACTER SET utf8 DEFAULT NULL,
  `insurance_id` varchar(3) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB AVG_ROW_LENGTH=5461 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci ROW_FORMAT=DYNAMIC;

--
-- Dumping data for table `staging_polis`
--

INSERT INTO `staging_polis` (`id`, `bank_id`, `loan_id`, `polis_number`, `insurance_id`, `created_at`, `updated_at`) VALUES
(1, '212', 'GEN2120000000013', 'POL2120000000013', 'AJB', '2020-10-16 12:09:40', '2020-10-16 12:09:40');

-- --------------------------------------------------------

--
-- Table structure for table `test`
--

CREATE TABLE `test` (
  `id` int(11) NOT NULL,
  `ket` varchar(255) DEFAULT NULL,
  `created_at` datetime DEFAULT current_timestamp(),
  `updated_at` datetime DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB AVG_ROW_LENGTH=963 DEFAULT CHARSET=utf8 ROW_FORMAT=DYNAMIC;

--
-- Dumping data for table `test`
--

INSERT INTO `test` (`id`, `ket`, `created_at`, `updated_at`) VALUES
(1, 'test', '2018-11-28 13:03:00', '2018-11-28 13:03:00'),
(2, 'test', '2018-11-28 13:04:00', '2018-11-28 13:04:00'),
(3, 'test', '2018-11-28 13:05:00', '2018-11-28 13:05:00'),
(4, 'test', '2018-11-28 13:06:00', '2018-11-28 13:06:00'),
(5, 'test', '2018-11-28 13:07:00', '2018-11-28 13:07:00'),
(6, 'test', '2018-11-28 13:08:00', '2018-11-28 13:08:00'),
(7, 'test', '2018-11-28 13:09:00', '2018-11-28 13:09:00'),
(8, 'test', '2018-11-28 13:10:00', '2018-11-28 13:10:00'),
(9, 'test', '2018-11-28 13:11:00', '2018-11-28 13:11:00'),
(10, 'test', '2018-11-28 13:12:00', '2018-11-28 13:12:00'),
(11, 'test', '2018-11-28 13:13:00', '2018-11-28 13:13:00'),
(12, 'test', '2018-11-28 13:14:00', '2018-11-28 13:14:00'),
(13, 'test', '2018-11-29 00:59:41', '2018-11-29 00:59:41'),
(14, 'test', '2018-11-29 01:00:00', '2018-11-29 01:00:00'),
(15, 'test', '2018-11-29 01:01:00', '2018-11-29 01:01:00'),
(16, 'test', '2018-11-29 01:03:57', '2018-11-29 01:03:57'),
(17, 'test', '2018-11-29 01:04:00', '2018-11-29 01:04:00'),
(18, 'test', '2018-11-29 01:05:00', '2018-11-29 01:05:00'),
(19, 'test', '2018-11-29 01:06:00', '2018-11-29 01:06:00');

-- --------------------------------------------------------

--
-- Table structure for table `users`
--

CREATE TABLE `users` (
  `id` int(10) UNSIGNED NOT NULL,
  `name` varchar(191) COLLATE utf8mb4_unicode_ci NOT NULL,
  `bank_id` varchar(3) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `branch_id` varchar(6) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `pic_bank_id` varchar(3) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `insurance_id` varchar(3) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `email` varchar(150) COLLATE utf8mb4_unicode_ci NOT NULL,
  `password` varchar(191) COLLATE utf8mb4_unicode_ci NOT NULL,
  `remember_token` varchar(100) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `is_active` int(11) DEFAULT 1,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL
) ENGINE=InnoDB AVG_ROW_LENGTH=1489 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci ROW_FORMAT=DYNAMIC;

--
-- Dumping data for table `users`
--

INSERT INTO `users` (`id`, `name`, `bank_id`, `branch_id`, `pic_bank_id`, `insurance_id`, `email`, `password`, `remember_token`, `is_active`, `created_at`, `updated_at`) VALUES
(1, 'Administrator', 'AJB', 'AJB', 'AJB', NULL, 'administrator@ajbcs.bumiputera.com', '$2y$10$sSrsfAPRi.IhEX6BXwW8xeklZztjli.QNC1laS516nVfD.ekjnlmq', 'hL33g0sIqF62kDAgnyM3gQxL2hvsQ1mR0kUgnMoV43p2dlKSACwWiAncfvxJ', 1, '2018-10-10 03:52:23', '2018-10-10 03:52:23'),
(2, 'Admin BWS', '212', '000', '212', NULL, 'bwsadmin@ajbcs.bumiputera.com', '$2y$10$sSrsfAPRi.IhEX6BXwW8xeklZztjli.QNC1laS516nVfD.ekjnlmq', 'HBbmH9b9rcKWYitaSa8JNJhybc6bsS0QCjXX4k1IbQXhUj4EwM8umpDzAWvT', 1, '2018-10-10 03:52:23', '2018-11-23 17:43:21'),
(3, 'User BWS KC Wastu', '212', '110', '212', NULL, 'bws11001@ajbcs.bumiputera.com', '$2y$10$sSrsfAPRi.IhEX6BXwW8xeklZztjli.QNC1laS516nVfD.ekjnlmq', 'C0lrN4i8vnxt0ifDRzirCCXlrN0swa91Vc8nVF48dHl6MC6S3G9uXU1yqTA4', 1, '2018-10-10 03:52:23', '2018-11-23 17:53:32'),
(4, 'User BWS KCP Buahbatu', '212', '111', '212', NULL, 'bws11101@ajbcs.bumiputera.com', '$2y$10$sSrsfAPRi.IhEX6BXwW8xeklZztjli.QNC1laS516nVfD.ekjnlmq', 'fHBkTSmnWiMYfgtE5uzhCJS9yAcnnNbQQVzgG6mHA5W5nDtzPxF0lmC8VcKl', 1, '2018-11-22 10:41:15', '2018-11-23 17:27:05'),
(5, 'User BWS KCP Diponegoro', '212', '112', '212', NULL, 'bws11201@ajbcs.bumiputera.com', '$2y$10$sSrsfAPRi.IhEX6BXwW8xeklZztjli.QNC1laS516nVfD.ekjnlmq', 'p9t4rixwxrBPbACqDw5X5fTWcTGBxxIXY6cXXm1TQj9HLXBpL769998M4tEh', 1, '2018-11-22 10:41:18', '2018-11-23 17:53:20'),
(6, 'User BWS KC Surapati', '212', '140', '212', NULL, 'bws14001@ajbcs.bumiputera.com', '$2y$10$sSrsfAPRi.IhEX6BXwW8xeklZztjli.QNC1laS516nVfD.ekjnlmq', 'TGLgoK0g6ykOQKLRFs9UG31pWOlJgJiMuuRU3Mn5osWp2jpIwxy091JMKK6C', 1, '2018-11-22 10:41:21', '2018-11-23 17:53:00'),
(7, 'User BWS KCP Subang', '212', '144', '212', NULL, 'bws14401@ajbcs.bumiputera.com', '$2y$10$sSrsfAPRi.IhEX6BXwW8xeklZztjli.QNC1laS516nVfD.ekjnlmq', 'UZQEWUywyzWO1lloitqID4DM69BG3yJgNceFqlktabTslkUvwurFkehRjzyV', 1, '2018-11-22 10:41:25', '2018-11-23 17:52:45'),
(8, 'User BWS KCP CIbiru', '212', '145', '212', NULL, 'bws14501@ajbcs.bumiputera.com', '$2y$10$sSrsfAPRi.IhEX6BXwW8xeklZztjli.QNC1laS516nVfD.ekjnlmq', 'WTM66DXDUxQK7KUXPU7xlzEs1nFayPxixOWeHLZak4zWw23l1U6Clw40qOdD', 1, '2018-11-22 10:41:28', '2018-11-23 17:47:11'),
(10, 'AJB PIC BWS', NULL, NULL, '212', 'AJB', 'ajbbws@ajbcs.bumiputera.com', '$2y$10$sSrsfAPRi.IhEX6BXwW8xeklZztjli.QNC1laS516nVfD.ekjnlmq', 'gan22jwL1NXk5146KPcD5Io4UvMD2rXxnCzZRNUqWiEI7IqWjvpolDEQiKi9', 1, '2018-11-24 03:39:56', '2018-12-26 04:27:36'),
(11, 'LIP PIC BYB', NULL, NULL, '088', 'LIP', 'ajbbyb@ajbcs.bumiputera.com', '$2y$10$sSrsfAPRi.IhEX6BXwW8xeklZztjli.QNC1laS516nVfD.ekjnlmq', 'Si18ZmLH1Vlq0jzREmLszwXpqVhtruJ1LXAk2xo2yViv1ZKRKpcNmxMN7ned', 1, '2018-11-24 03:41:13', '2019-03-07 13:59:15'),
(12, 'Admin AJB', NULL, NULL, NULL, 'AJB', 'ajbadmin@ajbcs.bumiputera.com', '$2y$10$sSrsfAPRi.IhEX6BXwW8xeklZztjli.QNC1laS516nVfD.ekjnlmq', 'LQARVA0C00JumF7elbb9oXW9uifq2JdQRVvSKFhQ0lnlgXafCEAvRpnIbzMx', 1, '2018-11-24 03:41:44', '2018-11-24 03:41:44'),
(13, 'Admin LIPPO', NULL, NULL, NULL, 'LIP', 'lippoadmin@ajbcs.bumiputera.com', '$2y$10$sSrsfAPRi.IhEX6BXwW8xeklZztjli.QNC1laS516nVfD.ekjnlmq', 'SPjg1L9QqSjsbr5ZQFlUyXTYzExzxnpkGefVHxzUB9RdX0F3LNLoJCugXGsg', 1, '2018-11-24 03:41:44', '2018-11-24 03:41:44'),
(15, 'LIP PIC MANDIRI', '008', '0017', '008', 'LIP', 'lippomandiri@ajbcs.bumiputera.com', '$2y$10$mkwUZVmIIsC75kJxcpMJjuYR0B0MXJmmU4.GJ3/9fDn.V.ixOxV/O', NULL, 1, '2020-10-10 15:15:36', '2020-10-10 15:16:13'),
(16, 'Admin Mandiri', '008', '0017', '008', NULL, 'mandiriadmin@ajbcs.bumiputera.com', '$2y$10$yPS9JHcZ71ugsNJaIUwTEes70IpdwB4yWVBQSpXp/nIaHJyKLqAfO', 'wo9erWZzVGiVi2D2diGtWqUbYQ2ZEL37zBLuy6KrPucrPuf91ovWxJmvzIAU', 1, '2020-10-10 15:23:43', '2020-10-10 15:23:43'),
(17, 'User Mandiri KC Pndok Indah', '008', '0033', '008', NULL, 'mandiri0033@ajbcs.bumiputera.com', '$2y$10$YY.waHg.Cj2APeMf/Z2CCOJR9gsKN/qb6yCIV.0p7vfAgWip8LzEy', NULL, 1, '2020-10-10 15:47:11', '2020-10-10 15:47:11');

--
-- Indexes for dumped tables
--

--
-- Indexes for table `data_claims`
--
ALTER TABLE `data_claims`
  ADD PRIMARY KEY (`id`) USING BTREE;

--
-- Indexes for table `data_documents`
--
ALTER TABLE `data_documents`
  ADD PRIMARY KEY (`id`) USING BTREE;

--
-- Indexes for table `data_hold_members`
--
ALTER TABLE `data_hold_members`
  ADD PRIMARY KEY (`id`) USING BTREE,
  ADD UNIQUE KEY `unique_key` (`loan_id`) USING BTREE;

--
-- Indexes for table `data_members`
--
ALTER TABLE `data_members`
  ADD PRIMARY KEY (`id`) USING BTREE,
  ADD UNIQUE KEY `unique_key` (`loan_id`) USING BTREE,
  ADD KEY `fk_member_master_status` (`data_status_id`) USING BTREE;

--
-- Indexes for table `data_repayments`
--
ALTER TABLE `data_repayments`
  ADD PRIMARY KEY (`id`) USING BTREE;

--
-- Indexes for table `db_total_per_bank`
--
ALTER TABLE `db_total_per_bank`
  ADD UNIQUE KEY `uniq_key` (`bank_id`) USING BTREE;

--
-- Indexes for table `db_total_per_bank_per_branch`
--
ALTER TABLE `db_total_per_bank_per_branch`
  ADD UNIQUE KEY `uniq_key` (`bank_id`,`branch_id`) USING BTREE;

--
-- Indexes for table `master_banks`
--
ALTER TABLE `master_banks`
  ADD PRIMARY KEY (`id`) USING BTREE;

--
-- Indexes for table `master_branches`
--
ALTER TABLE `master_branches`
  ADD PRIMARY KEY (`id`) USING BTREE;

--
-- Indexes for table `master_claim_status`
--
ALTER TABLE `master_claim_status`
  ADD PRIMARY KEY (`id`) USING BTREE;

--
-- Indexes for table `master_data_status`
--
ALTER TABLE `master_data_status`
  ADD PRIMARY KEY (`id`) USING BTREE;

--
-- Indexes for table `master_document`
--
ALTER TABLE `master_document`
  ADD PRIMARY KEY (`id`) USING BTREE;

--
-- Indexes for table `master_insurances`
--
ALTER TABLE `master_insurances`
  ADD PRIMARY KEY (`id`) USING BTREE;

--
-- Indexes for table `master_insurance_kinds`
--
ALTER TABLE `master_insurance_kinds`
  ADD PRIMARY KEY (`id`) USING BTREE;

--
-- Indexes for table `master_insurance_rates`
--
ALTER TABLE `master_insurance_rates`
  ADD PRIMARY KEY (`id`) USING BTREE;

--
-- Indexes for table `master_map_banks_insurances`
--
ALTER TABLE `master_map_banks_insurances`
  ADD PRIMARY KEY (`id`,`bank_id`,`insurance_id`) USING BTREE,
  ADD UNIQUE KEY `unique_key` (`bank_id`,`insurance_id`) USING BTREE;

--
-- Indexes for table `master_map_product_insurances`
--
ALTER TABLE `master_map_product_insurances`
  ADD PRIMARY KEY (`id`) USING BTREE,
  ADD UNIQUE KEY `unique_key` (`product_id`,`insurance_kind_id`) USING BTREE;

--
-- Indexes for table `master_products`
--
ALTER TABLE `master_products`
  ADD PRIMARY KEY (`id`) USING BTREE;

--
-- Indexes for table `master_record_status`
--
ALTER TABLE `master_record_status`
  ADD PRIMARY KEY (`id`) USING BTREE;

--
-- Indexes for table `master_repayment_status`
--
ALTER TABLE `master_repayment_status`
  ADD PRIMARY KEY (`id`) USING BTREE;

--
-- Indexes for table `master_validation_rules`
--
ALTER TABLE `master_validation_rules`
  ADD PRIMARY KEY (`id`) USING BTREE;

--
-- Indexes for table `master_validation_status`
--
ALTER TABLE `master_validation_status`
  ADD PRIMARY KEY (`id`) USING BTREE;

--
-- Indexes for table `migrations`
--
ALTER TABLE `migrations`
  ADD PRIMARY KEY (`id`) USING BTREE;

--
-- Indexes for table `password_resets`
--
ALTER TABLE `password_resets`
  ADD KEY `password_resets_email_index` (`email`) USING BTREE;

--
-- Indexes for table `permissions`
--
ALTER TABLE `permissions`
  ADD PRIMARY KEY (`id`) USING BTREE,
  ADD UNIQUE KEY `permissions_name_unique` (`name`) USING BTREE;

--
-- Indexes for table `permission_role`
--
ALTER TABLE `permission_role`
  ADD PRIMARY KEY (`permission_id`,`role_id`) USING BTREE,
  ADD KEY `permission_role_role_id_foreign` (`role_id`) USING BTREE;

--
-- Indexes for table `permission_user`
--
ALTER TABLE `permission_user`
  ADD PRIMARY KEY (`user_id`,`permission_id`,`user_type`) USING BTREE,
  ADD KEY `permission_user_permission_id_foreign` (`permission_id`) USING BTREE;

--
-- Indexes for table `roles`
--
ALTER TABLE `roles`
  ADD PRIMARY KEY (`id`) USING BTREE,
  ADD UNIQUE KEY `roles_name_unique` (`name`) USING BTREE;

--
-- Indexes for table `role_user`
--
ALTER TABLE `role_user`
  ADD PRIMARY KEY (`user_id`,`role_id`,`user_type`) USING BTREE,
  ADD KEY `role_user_role_id_foreign` (`role_id`) USING BTREE;

--
-- Indexes for table `staging_members`
--
ALTER TABLE `staging_members`
  ADD PRIMARY KEY (`id`) USING BTREE;

--
-- Indexes for table `staging_polis`
--
ALTER TABLE `staging_polis`
  ADD PRIMARY KEY (`id`) USING BTREE;

--
-- Indexes for table `test`
--
ALTER TABLE `test`
  ADD PRIMARY KEY (`id`) USING BTREE;

--
-- Indexes for table `users`
--
ALTER TABLE `users`
  ADD PRIMARY KEY (`id`) USING BTREE,
  ADD UNIQUE KEY `users_email_unique` (`email`) USING BTREE;

--
-- AUTO_INCREMENT for dumped tables
--

--
-- AUTO_INCREMENT for table `data_documents`
--
ALTER TABLE `data_documents`
  MODIFY `id` bigint(20) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=38;

--
-- AUTO_INCREMENT for table `data_hold_members`
--
ALTER TABLE `data_hold_members`
  MODIFY `id` bigint(20) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=6;

--
-- AUTO_INCREMENT for table `master_claim_status`
--
ALTER TABLE `master_claim_status`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=7;

--
-- AUTO_INCREMENT for table `master_data_status`
--
ALTER TABLE `master_data_status`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=8;

--
-- AUTO_INCREMENT for table `master_document`
--
ALTER TABLE `master_document`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=7;

--
-- AUTO_INCREMENT for table `master_insurance_rates`
--
ALTER TABLE `master_insurance_rates`
  MODIFY `id` bigint(20) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=2201;

--
-- AUTO_INCREMENT for table `master_map_banks_insurances`
--
ALTER TABLE `master_map_banks_insurances`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=17;

--
-- AUTO_INCREMENT for table `master_map_product_insurances`
--
ALTER TABLE `master_map_product_insurances`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=15;

--
-- AUTO_INCREMENT for table `master_record_status`
--
ALTER TABLE `master_record_status`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=3;

--
-- AUTO_INCREMENT for table `master_repayment_status`
--
ALTER TABLE `master_repayment_status`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=4;

--
-- AUTO_INCREMENT for table `master_validation_rules`
--
ALTER TABLE `master_validation_rules`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=7;

--
-- AUTO_INCREMENT for table `master_validation_status`
--
ALTER TABLE `master_validation_status`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=5;

--
-- AUTO_INCREMENT for table `migrations`
--
ALTER TABLE `migrations`
  MODIFY `id` int(10) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=9;

--
-- AUTO_INCREMENT for table `permissions`
--
ALTER TABLE `permissions`
  MODIFY `id` int(10) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=45;

--
-- AUTO_INCREMENT for table `roles`
--
ALTER TABLE `roles`
  MODIFY `id` int(10) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=6;

--
-- AUTO_INCREMENT for table `staging_members`
--
ALTER TABLE `staging_members`
  MODIFY `id` int(11) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=132;

--
-- AUTO_INCREMENT for table `staging_polis`
--
ALTER TABLE `staging_polis`
  MODIFY `id` int(11) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=2;

--
-- AUTO_INCREMENT for table `test`
--
ALTER TABLE `test`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=20;

--
-- AUTO_INCREMENT for table `users`
--
ALTER TABLE `users`
  MODIFY `id` int(10) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=18;

--
-- Constraints for dumped tables
--

--
-- Constraints for table `data_members`
--
ALTER TABLE `data_members`
  ADD CONSTRAINT `fk_member_master_status` FOREIGN KEY (`data_status_id`) REFERENCES `master_data_status` (`id`) ON DELETE NO ACTION ON UPDATE NO ACTION;

--
-- Constraints for table `permission_role`
--
ALTER TABLE `permission_role`
  ADD CONSTRAINT `permission_role_permission_id_foreign` FOREIGN KEY (`permission_id`) REFERENCES `permissions` (`id`) ON DELETE CASCADE ON UPDATE CASCADE,
  ADD CONSTRAINT `permission_role_role_id_foreign` FOREIGN KEY (`role_id`) REFERENCES `roles` (`id`) ON DELETE CASCADE ON UPDATE CASCADE;

--
-- Constraints for table `permission_user`
--
ALTER TABLE `permission_user`
  ADD CONSTRAINT `permission_user_permission_id_foreign` FOREIGN KEY (`permission_id`) REFERENCES `permissions` (`id`) ON DELETE CASCADE ON UPDATE CASCADE;

--
-- Constraints for table `role_user`
--
ALTER TABLE `role_user`
  ADD CONSTRAINT `role_user_role_id_foreign` FOREIGN KEY (`role_id`) REFERENCES `roles` (`id`) ON DELETE CASCADE ON UPDATE CASCADE;

DELIMITER $$
--
-- Events
--
CREATE DEFINER=`u166684593_inagosadmin`@`127.0.0.1` EVENT `EV_CHECKING_CLOSED_LOAN` ON SCHEDULE EVERY 1 DAY STARTS '2018-11-28 01:05:00' ON COMPLETION PRESERVE ENABLE DO update data_members
set loan_status_id=3, keterangan_loan_status='Normal Closed'
where end_date=CURDATE()$$

DELIMITER ;
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
