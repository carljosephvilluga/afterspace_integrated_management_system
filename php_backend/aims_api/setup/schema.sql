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
    discount_rate DECIMAL(5,2),
    start_date DATE,
    end_date DATE,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
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

INSERT INTO users (full_name, contact_number, email, status)
SELECT * FROM (
    SELECT 'Mika Santos', '09171234567', 'mika.santos@example.com', 'Active'
) AS tmp
WHERE NOT EXISTS (SELECT 1 FROM users WHERE email = 'mika.santos@example.com')
LIMIT 1;

INSERT INTO users (full_name, contact_number, email, status)
SELECT * FROM (
    SELECT 'Paolo Reyes', '09179876543', 'paolo.reyes@example.com', 'Active'
) AS tmp
WHERE NOT EXISTS (SELECT 1 FROM users WHERE email = 'paolo.reyes@example.com')
LIMIT 1;

INSERT INTO users (full_name, contact_number, email, status)
SELECT * FROM (
    SELECT 'Andrea Lim', '09175550000', 'andrea.lim@example.com', 'Inactive'
) AS tmp
WHERE NOT EXISTS (SELECT 1 FROM users WHERE email = 'andrea.lim@example.com')
LIMIT 1;

INSERT INTO user_profiles (user_id, first_name, last_name, user_type, membership_type, history_json)
SELECT
    u.user_id,
    'Mika',
    'Santos',
    'Student',
    'Annual',
    JSON_ARRAY('User added on 2026-04-15 09:00 AM')
FROM users u
WHERE u.email = 'mika.santos@example.com'
  AND NOT EXISTS (
      SELECT 1 FROM user_profiles up WHERE up.user_id = u.user_id
  );

INSERT INTO memberships (user_id, membership_type, discount_rate, start_date, end_date)
SELECT
    u.user_id,
    'Annual',
    NULL,
    NULL,
    NULL
FROM users u
WHERE u.email = 'mika.santos@example.com'
  AND NOT EXISTS (
      SELECT 1 FROM memberships m WHERE m.user_id = u.user_id
  );

INSERT INTO memberships (user_id, membership_type, discount_rate, start_date, end_date)
SELECT
    u.user_id,
    'Monthly Membership',
    NULL,
    NULL,
    NULL
FROM users u
WHERE u.email = 'paolo.reyes@example.com'
  AND NOT EXISTS (
      SELECT 1 FROM memberships m WHERE m.user_id = u.user_id
  );

INSERT INTO memberships (user_id, membership_type, discount_rate, start_date, end_date)
SELECT
    u.user_id,
    'Open Time',
    NULL,
    NULL,
    NULL
FROM users u
WHERE u.email = 'andrea.lim@example.com'
  AND NOT EXISTS (
      SELECT 1 FROM memberships m WHERE m.user_id = u.user_id
  );

INSERT INTO user_profiles (user_id, first_name, last_name, user_type, membership_type, history_json)
SELECT
    u.user_id,
    'Paolo',
    'Reyes',
    'Professional',
    'Monthly Membership',
    JSON_ARRAY('User added on 2026-04-14 10:20 AM', 'User edited on 2026-04-16 04:05 PM')
FROM users u
WHERE u.email = 'paolo.reyes@example.com'
  AND NOT EXISTS (
      SELECT 1 FROM user_profiles up WHERE up.user_id = u.user_id
  );

INSERT INTO user_profiles (user_id, first_name, last_name, user_type, membership_type, history_json)
SELECT
    u.user_id,
    'Andrea',
    'Lim',
    'Student',
    'Open Time',
    JSON_ARRAY('User added on 2026-04-11 11:40 AM')
FROM users u
WHERE u.email = 'andrea.lim@example.com'
  AND NOT EXISTS (
      SELECT 1 FROM user_profiles up WHERE up.user_id = u.user_id
  );

INSERT INTO bookings (user_id, booking_date, start_time, end_time, status)
SELECT
    u.user_id,
    CURDATE(),
    '09:00:00',
    '12:00:00',
    'Pending'
FROM users u
WHERE u.email = 'mika.santos@example.com'
  AND NOT EXISTS (
      SELECT 1
      FROM bookings b
      WHERE b.user_id = u.user_id
        AND b.booking_date = CURDATE()
        AND b.start_time = '09:00:00'
  );

INSERT INTO booking_meta (booking_id, space_type, customer_type)
SELECT
    b.booking_id,
    'Open Space',
    'Guest'
FROM bookings b
WHERE NOT EXISTS (
    SELECT 1 FROM booking_meta bm WHERE bm.booking_id = b.booking_id
);

INSERT INTO sessions (user_id, check_in, check_out, status)
SELECT
    u.user_id,
    NOW() - INTERVAL 2 HOUR,
    NULL,
    'Active'
FROM users u
WHERE u.email = 'paolo.reyes@example.com'
  AND NOT EXISTS (
      SELECT 1
      FROM sessions s
      WHERE s.user_id = u.user_id
        AND s.status = 'Active'
  );

INSERT INTO session_meta (session_id, space_used)
SELECT
    s.session_id,
    'Open Space'
FROM sessions s
WHERE NOT EXISTS (
    SELECT 1 FROM session_meta sm WHERE sm.session_id = s.session_id
);

INSERT INTO transactions (user_id, session_id, amount, discount_applied, final_amount, payment_method, status)
SELECT
    u.user_id,
    s.session_id,
    500.00,
    50.00,
    450.00,
    'cash',
    'paid'
FROM users u
LEFT JOIN sessions s ON s.user_id = u.user_id
WHERE u.email = 'mika.santos@example.com'
  AND NOT EXISTS (
      SELECT 1
      FROM transactions t
      WHERE t.user_id = u.user_id
  )
LIMIT 1;

INSERT INTO meeting_schedules (title, notes, start_at, end_at, created_by_staff_id)
SELECT
    'Operations Sync',
    'Daily operations touchpoint.',
    TIMESTAMP(CURDATE(), '09:00:00'),
    TIMESTAMP(CURDATE(), '10:00:00'),
    s.staff_id
FROM staff_accounts s
WHERE s.employee_id = 'ADMIN-001'
  AND NOT EXISTS (
      SELECT 1
      FROM meeting_schedules ms
      WHERE ms.title = 'Operations Sync'
        AND DATE(ms.start_at) = CURDATE()
  )
LIMIT 1;
