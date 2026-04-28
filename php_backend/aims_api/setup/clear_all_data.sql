USE afterspace_db;

SET FOREIGN_KEY_CHECKS = 0;

TRUNCATE TABLE api_sessions;
TRUNCATE TABLE meeting_schedules;
TRUNCATE TABLE transactions;
TRUNCATE TABLE session_meta;
TRUNCATE TABLE sessions;
TRUNCATE TABLE booking_meta;
TRUNCATE TABLE bookings;
TRUNCATE TABLE memberships;
TRUNCATE TABLE membership_types;
TRUNCATE TABLE user_profiles;
TRUNCATE TABLE users;
TRUNCATE TABLE staff_accounts;
TRUNCATE TABLE promotions;
TRUNCATE TABLE space_pricing;

SET FOREIGN_KEY_CHECKS = 1;
