CREATE DATABASE IF NOT EXISTS afterspace_db;
USE afterspace_db;

CREATE TABLE IF NOT EXISTS staff_accounts (
    staff_id INT AUTO_INCREMENT PRIMARY KEY,
    employee_id VARCHAR(32) NOT NULL UNIQUE,
    full_name VARCHAR(100) NOT NULL,
    email VARCHAR(100) NOT NULL UNIQUE,
    password_hash VARCHAR(255) NOT NULL,
    role ENUM('Admin', 'Manager', 'Staff') NOT NULL,
    status ENUM('Active', 'Inactive') NOT NULL DEFAULT 'Active',
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS users (
    user_id INT AUTO_INCREMENT PRIMARY KEY,
    full_name VARCHAR(100) NOT NULL,
    contact_number VARCHAR(20),
    email VARCHAR(100),
    status ENUM('Active', 'Inactive') NOT NULL DEFAULT 'Active',
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS user_profiles (
    user_id INT PRIMARY KEY,
    first_name VARCHAR(100) NOT NULL,
    last_name VARCHAR(100) NOT NULL DEFAULT '',
    user_type VARCHAR(50) NOT NULL DEFAULT 'Student',
    membership_type VARCHAR(100) NOT NULL DEFAULT 'Open Time',
    history_json LONGTEXT NULL,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    CONSTRAINT fk_user_profiles_user
        FOREIGN KEY (user_id) REFERENCES users(user_id)
        ON DELETE CASCADE
);

CREATE TABLE IF NOT EXISTS memberships (
    membership_id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT NOT NULL,
    membership_type VARCHAR(50),
    discount_rate DECIMAL(5,2),
    start_date DATE,
    end_date DATE,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_memberships_user
        FOREIGN KEY (user_id) REFERENCES users(user_id)
        ON DELETE CASCADE
);

CREATE TABLE IF NOT EXISTS promotions (
    promo_id INT AUTO_INCREMENT PRIMARY KEY,
    promo_name VARCHAR(100),
    promo_type VARCHAR(100),
    discount_rate DECIMAL(5,2),
    discount_label VARCHAR(100),
    start_date DATE,
    end_date DATE,
    benefits TEXT,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS membership_types (
    membership_type_id INT AUTO_INCREMENT PRIMARY KEY,
    plan_name VARCHAR(120) NOT NULL,
    duration_label VARCHAR(80) NOT NULL,
    price_label VARCHAR(80) NOT NULL,
    benefits TEXT NOT NULL,
    created_by_staff_id INT NULL,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    CONSTRAINT fk_membership_types_staff
        FOREIGN KEY (created_by_staff_id) REFERENCES staff_accounts(staff_id)
        ON DELETE SET NULL
);

CREATE TABLE IF NOT EXISTS bookings (
    booking_id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT NOT NULL,
    booking_date DATE,
    start_time TIME,
    end_time TIME,
    status ENUM('Pending', 'Confirmed', 'Cancelled') NOT NULL DEFAULT 'Pending',
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_bookings_user
        FOREIGN KEY (user_id) REFERENCES users(user_id)
        ON DELETE CASCADE
);

CREATE TABLE IF NOT EXISTS booking_meta (
    booking_id INT PRIMARY KEY,
    space_type ENUM('Board Room', 'Open Space') NOT NULL DEFAULT 'Open Space',
    customer_type VARCHAR(50) NOT NULL DEFAULT 'Guest',
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_booking_meta_booking
        FOREIGN KEY (booking_id) REFERENCES bookings(booking_id)
        ON DELETE CASCADE
);

CREATE TABLE IF NOT EXISTS sessions (
    session_id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT NOT NULL,
    check_in DATETIME,
    check_out DATETIME,
    status ENUM('Active', 'Completed') NOT NULL DEFAULT 'Active',
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_sessions_user
        FOREIGN KEY (user_id) REFERENCES users(user_id)
        ON DELETE CASCADE
);

CREATE TABLE IF NOT EXISTS session_meta (
    session_id INT PRIMARY KEY,
    space_used ENUM('Board Room', 'Open Space') NOT NULL DEFAULT 'Open Space',
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_session_meta_session
        FOREIGN KEY (session_id) REFERENCES sessions(session_id)
        ON DELETE CASCADE
);

CREATE TABLE IF NOT EXISTS transactions (
    transaction_id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT NOT NULL,
    session_id INT NULL,
    amount DECIMAL(10,2) NOT NULL DEFAULT 0,
    discount_applied DECIMAL(10,2) NOT NULL DEFAULT 0,
    final_amount DECIMAL(10,2) NOT NULL DEFAULT 0,
    payment_method VARCHAR(50) DEFAULT 'cash',
    status ENUM('paid', 'pending', 'failed') NOT NULL DEFAULT 'paid',
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_transactions_user
        FOREIGN KEY (user_id) REFERENCES users(user_id)
        ON DELETE CASCADE,
    CONSTRAINT fk_transactions_session
        FOREIGN KEY (session_id) REFERENCES sessions(session_id)
        ON DELETE SET NULL
);

CREATE TABLE IF NOT EXISTS api_sessions (
    token CHAR(64) PRIMARY KEY,
    staff_id INT NOT NULL,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    expires_at DATETIME NOT NULL,
    CONSTRAINT fk_api_sessions_staff
        FOREIGN KEY (staff_id) REFERENCES staff_accounts(staff_id)
        ON DELETE CASCADE
);

CREATE TABLE IF NOT EXISTS space_pricing (
    pricing_id TINYINT UNSIGNED PRIMARY KEY,
    board_room_hourly_rate DECIMAL(10,2) NOT NULL,
    ordinary_space_hourly_rate DECIMAL(10,2) NOT NULL,
    updated_by_staff_id INT NULL,
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    CONSTRAINT fk_space_pricing_staff
        FOREIGN KEY (updated_by_staff_id) REFERENCES staff_accounts(staff_id)
        ON DELETE SET NULL
);

CREATE TABLE IF NOT EXISTS meeting_schedules (
    schedule_id INT AUTO_INCREMENT PRIMARY KEY,
    title VARCHAR(150) NOT NULL,
    notes VARCHAR(255) NULL,
    start_at DATETIME NOT NULL,
    end_at DATETIME NOT NULL,
    created_by_staff_id INT NULL,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    KEY idx_meeting_schedules_start_at (start_at),
    CONSTRAINT fk_meeting_schedules_staff
        FOREIGN KEY (created_by_staff_id) REFERENCES staff_accounts(staff_id)
        ON DELETE SET NULL
);

-- Only login accounts are seeded by default.

INSERT INTO staff_accounts (employee_id, full_name, email, password_hash, role, status)
SELECT * FROM (
    SELECT 'ADMIN-001', 'System Administrator', 'admin@afterspace.local', 'admin123', 'Admin', 'Active'
) AS tmp
WHERE NOT EXISTS (SELECT 1 FROM staff_accounts WHERE employee_id = 'ADMIN-001')
LIMIT 1;

INSERT INTO staff_accounts (employee_id, full_name, email, password_hash, role, status)
SELECT * FROM (
    SELECT 'MGR-001', 'Operations Manager', 'manager@afterspace.local', 'manager123', 'Manager', 'Active'
) AS tmp
WHERE NOT EXISTS (SELECT 1 FROM staff_accounts WHERE employee_id = 'MGR-001')
LIMIT 1;

INSERT INTO staff_accounts (employee_id, full_name, email, password_hash, role, status)
SELECT * FROM (
    SELECT 'STF-001', 'Front Desk Staff', 'staff@afterspace.local', 'staff123', 'Staff', 'Active'
) AS tmp
WHERE NOT EXISTS (SELECT 1 FROM staff_accounts WHERE employee_id = 'STF-001')
LIMIT 1;
