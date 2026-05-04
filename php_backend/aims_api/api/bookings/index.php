<?php

require __DIR__ . '/../../lib/bootstrap.php';

aims_ensure_operational_tables();
$currentUser = aims_current_user(true);
aims_require_roles($currentUser, ['admin', 'manager', 'staff']);

$method = strtoupper($_SERVER['REQUEST_METHOD']);
if ($method === 'GET') {
    handle_get_bookings();
}
if ($method === 'POST') {
    handle_create_booking();
}
aims_error(405, 'Method not allowed.');

function handle_get_bookings(): void
{
    $pdo = aims_pdo();
    $status = normalize_booking_status_filter(aims_str($_GET['status'] ?? ''));
    $date = aims_str($_GET['date'] ?? '');
    $limit = aims_int($_GET['limit'] ?? 200);
    $limit = max(1, min($limit, 500));

    $where = [];
    $params = [];

    if ($status !== null) {
        $where[] = 'LOWER(b.status) = :status';
        $params[':status'] = strtolower($status);
    }

    if ($date !== '') {
        if (!preg_match('/^\d{4}-\d{2}-\d{2}$/', $date)) {
            aims_error(400, 'date must use YYYY-MM-DD format.');
        }
        $where[] = 'b.booking_date = :booking_date';
        $params[':booking_date'] = $date;
    }

    $whereSql = count($where) > 0 ? 'WHERE ' . implode(' AND ', $where) : '';

    $sql = <<<SQL
SELECT
    b.booking_id,
    b.user_id,
    b.booking_date,
    b.start_time,
    b.end_time,
    b.status,
    b.created_at,
    u.full_name,
    u.email,
    u.contact_number,
    COALESCE(bm.space_type, 'Open Space') AS space_type,
    COALESCE(bm.customer_type, 'Guest') AS customer_type
FROM bookings b
INNER JOIN users u ON u.user_id = b.user_id
LEFT JOIN booking_meta bm ON bm.booking_id = b.booking_id
{$whereSql}
ORDER BY b.booking_date ASC, b.start_time ASC, b.booking_id ASC
LIMIT {$limit}
SQL;

    $stmt = $pdo->prepare($sql);
    $stmt->execute($params);
    $rows = $stmt->fetchAll();

    $bookings = array_map('to_booking_payload', $rows ?: []);
    aims_ok(['bookings' => $bookings]);
}

function handle_create_booking(): void
{
    $body = aims_body();

    $customerName = aims_require_field($body, 'customerName');
    $contactDetails = aims_require_field($body, 'contactDetails');
    $spaceType = aims_space_label(aims_require_field($body, 'spaceType'));
    $customerType = aims_str($body['customerType'] ?? 'Guest');
    if ($customerType === '') {
        $customerType = 'Guest';
    }

    $startAt = aims_parse_datetime(aims_require_field($body, 'startAt'), 'startAt');
    $endAt = aims_parse_datetime(aims_require_field($body, 'endAt'), 'endAt');

    if ($endAt <= $startAt) {
        aims_error(400, 'endAt must be later than startAt.');
    }

    $startDate = $startAt->format('Y-m-d');
    $endDate = $endAt->format('Y-m-d');
    if ($startDate !== $endDate) {
        aims_error(400, 'Booking startAt and endAt must be on the same date.');
    }

    $pdo = aims_pdo();
    $pdo->beginTransaction();
    try {
        $userId = resolve_or_create_user($pdo, $customerName, $contactDetails);

        $bookingId = aims_insert_returning_id(
            $pdo,
            <<<SQL
INSERT INTO bookings (user_id, booking_date, start_time, end_time, status)
VALUES (:user_id, :booking_date, :start_time, :end_time, 'Pending')
SQL,
            [
            ':user_id' => $userId,
            ':booking_date' => $startDate,
            ':start_time' => $startAt->format('H:i:s'),
            ':end_time' => $endAt->format('H:i:s'),
            ],
            'booking_id'
        );

        $insertMeta = $pdo->prepare(
            <<<SQL
INSERT INTO booking_meta (booking_id, space_type, customer_type)
VALUES (:booking_id, :space_type, :customer_type)
SQL
        );
        $insertMeta->execute([
            ':booking_id' => $bookingId,
            ':space_type' => $spaceType,
            ':customer_type' => $customerType,
        ]);

        $pdo->commit();
    } catch (Throwable $error) {
        if ($pdo->inTransaction()) {
            $pdo->rollBack();
        }
        aims_error(500, 'Failed to save booking.');
    }

    $booking = fetch_booking_by_id($bookingId);
    aims_ok(['booking' => $booking]);
}

function resolve_or_create_user(PDO $pdo, string $customerName, string $contactDetails): int
{
    $email = filter_var($contactDetails, FILTER_VALIDATE_EMAIL) ?: null;

    if ($email !== null) {
        $findByEmail = $pdo->prepare(
            'SELECT user_id FROM users WHERE LOWER(email) = :email LIMIT 1'
        );
        $findByEmail->execute([':email' => strtolower($email)]);
        $existingEmail = $findByEmail->fetchColumn();
        if ($existingEmail !== false) {
            return aims_int($existingEmail);
        }
    }

    $findByContact = $pdo->prepare(
        'SELECT user_id FROM users WHERE contact_number = :contact_number LIMIT 1'
    );
    $findByContact->execute([':contact_number' => $contactDetails]);
    $existingContact = $findByContact->fetchColumn();
    if ($existingContact !== false) {
        return aims_int($existingContact);
    }

    return aims_insert_returning_id(
        $pdo,
        <<<SQL
INSERT INTO users (full_name, contact_number, email, status)
VALUES (:full_name, :contact_number, :email, 'Inactive')
SQL,
        [
        ':full_name' => $customerName,
        ':contact_number' => $email !== null ? null : $contactDetails,
        ':email' => $email !== null ? strtolower($email) : null,
        ],
        'user_id'
    );
}

function fetch_booking_by_id(int $bookingId): array
{
    $pdo = aims_pdo();
    $sql = <<<SQL
SELECT
    b.booking_id,
    b.user_id,
    b.booking_date,
    b.start_time,
    b.end_time,
    b.status,
    b.created_at,
    u.full_name,
    u.email,
    u.contact_number,
    COALESCE(bm.space_type, 'Open Space') AS space_type,
    COALESCE(bm.customer_type, 'Guest') AS customer_type
FROM bookings b
INNER JOIN users u ON u.user_id = b.user_id
LEFT JOIN booking_meta bm ON bm.booking_id = b.booking_id
WHERE b.booking_id = :booking_id
LIMIT 1
SQL;

    $stmt = $pdo->prepare($sql);
    $stmt->execute([':booking_id' => $bookingId]);
    $row = $stmt->fetch();
    if (!$row) {
        aims_error(404, 'Booking not found.');
    }

    return to_booking_payload($row);
}

function to_booking_payload(array $row): array
{
    $statusRaw = strtolower((string) ($row['status'] ?? 'pending'));
    $status = 'reserved';
    if ($statusRaw === 'confirmed') {
        $status = 'checkedIn';
    } elseif ($statusRaw === 'cancelled') {
        $status = 'cancelled';
    }

    $date = (string) ($row['booking_date'] ?? '');
    $start = (string) ($row['start_time'] ?? '00:00:00');
    $end = (string) ($row['end_time'] ?? '00:00:00');

    return [
        'bookingId' => aims_int($row['booking_id'] ?? 0),
        'bookingCode' => 'BK-' . str_pad((string) aims_int($row['booking_id'] ?? 0), 6, '0', STR_PAD_LEFT),
        'userId' => aims_int($row['user_id'] ?? 0),
        'customerName' => aims_str($row['full_name'] ?? ''),
        'email' => aims_str($row['email'] ?? ''),
        'contactDetails' => aims_str($row['email'] ?? '') !== ''
            ? aims_str($row['email'] ?? '')
            : aims_str($row['contact_number'] ?? ''),
        'spaceType' => aims_str($row['space_type'] ?? 'Open Space'),
        'customerType' => aims_str($row['customer_type'] ?? 'Guest'),
        'status' => $status,
        'rawStatus' => aims_str($row['status'] ?? ''),
        'startAt' => "{$date} {$start}",
        'endAt' => "{$date} {$end}",
        'createdAt' => aims_str($row['created_at'] ?? ''),
    ];
}

function normalize_booking_status_filter(string $status): ?string
{
    if ($status === '') {
        return null;
    }

    $normalized = strtolower(trim($status));
    if ($normalized === 'reserved' || $normalized === 'pending') {
        return 'Pending';
    }
    if ($normalized === 'checkedin' || $normalized === 'checked-in' || $normalized === 'confirmed') {
        return 'Confirmed';
    }
    if ($normalized === 'cancelled' || $normalized === 'canceled') {
        return 'Cancelled';
    }

    aims_error(400, 'Invalid status filter.');
}
