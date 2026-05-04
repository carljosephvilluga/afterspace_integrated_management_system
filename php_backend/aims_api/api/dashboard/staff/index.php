<?php

require __DIR__ . '/../../../lib/bootstrap.php';

aims_require_method('GET');
aims_ensure_operational_tables();
$user = aims_current_user(true);
aims_require_roles($user, ['admin', 'manager', 'staff']);

$pdo = aims_pdo();

$activeCustomers = aims_int(
    $pdo->query(
        "SELECT COUNT(DISTINCT user_id) FROM sessions WHERE LOWER(status) = 'active'"
    )->fetchColumn()
);
$reservedBookings = aims_int(
    $pdo->query("SELECT COUNT(*) FROM bookings WHERE LOWER(status) = 'pending'")->fetchColumn()
);
$activeSessions = aims_int(
    $pdo->query("SELECT COUNT(*) FROM sessions WHERE LOWER(status) = 'active'")->fetchColumn()
);

$today = new DateTimeImmutable('today');
$weekStart = $today->sub(new DateInterval('P6D'));
$weekEnd = $today->add(new DateInterval('P1D'));
$checkInDateSql = aims_date_sql('s.check_in');
$weeklyActivityStmt = $pdo->prepare(
    <<<SQL
SELECT
    {$checkInDateSql} AS day_key,
    COUNT(*) AS total
FROM sessions s
WHERE s.check_in >= :week_start
  AND s.check_in < :week_end
GROUP BY {$checkInDateSql}
SQL
);
$weeklyActivityStmt->execute([
    ':week_start' => $weekStart->format('Y-m-d H:i:s'),
    ':week_end' => $weekEnd->format('Y-m-d H:i:s'),
]);
$weeklyCountsByDay = [];
foreach ($weeklyActivityStmt->fetchAll() ?: [] as $row) {
    $dayKey = aims_str($row['day_key'] ?? '');
    if ($dayKey === '') {
        continue;
    }
    $weeklyCountsByDay[$dayKey] = aims_int($row['total'] ?? 0);
}

$weeklyActivity = [];
for ($offset = 6; $offset >= 0; $offset--) {
    $day = $today->sub(new DateInterval('P' . $offset . 'D'));
    $dayKey = $day->format('Y-m-d');
    $weeklyActivity[] = [
        'date' => $dayKey,
        'label' => $day->format('D'),
        'count' => $weeklyCountsByDay[$dayKey] ?? 0,
    ];
}

$pendingReservationsStmt = $pdo->query(
    <<<SQL
SELECT
    b.booking_id,
    b.booking_date,
    b.start_time,
    b.end_time,
    u.full_name,
    u.email,
    u.contact_number
FROM bookings b
INNER JOIN users u ON u.user_id = b.user_id
WHERE LOWER(b.status) = 'pending'
ORDER BY b.booking_date ASC, b.start_time ASC, b.booking_id ASC
LIMIT 8
SQL
);
$pendingReservations = [];
foreach ($pendingReservationsStmt->fetchAll() ?: [] as $row) {
    $pendingReservations[] = [
        'bookingId' => aims_int($row['booking_id'] ?? 0),
        'customerName' => aims_str($row['full_name'] ?? ''),
        'email' => aims_str($row['email'] ?? ''),
        'contactDetails' => aims_str($row['email'] ?? '') !== ''
            ? aims_str($row['email'] ?? '')
            : aims_str($row['contact_number'] ?? ''),
        'startAt' => aims_str($row['booking_date'] ?? '') . ' ' . aims_str($row['start_time'] ?? ''),
        'endAt' => aims_str($row['booking_date'] ?? '') . ' ' . aims_str($row['end_time'] ?? ''),
    ];
}

$activeCustomersStmt = $pdo->query(
    <<<SQL
SELECT
    s.session_id,
    s.check_in,
    u.full_name,
    u.email,
    COALESCE(sm.space_used, 'Open Space') AS space_used,
    COALESCE(MAX(m.membership_type), 'Open Time') AS membership_type
FROM sessions s
INNER JOIN users u ON u.user_id = s.user_id
LEFT JOIN session_meta sm ON sm.session_id = s.session_id
LEFT JOIN memberships m ON m.user_id = u.user_id
WHERE LOWER(s.status) = 'active'
GROUP BY s.session_id, s.check_in, u.full_name, u.email, sm.space_used
ORDER BY s.check_in DESC
LIMIT 8
SQL
);
$activeCustomerRows = [];
foreach ($activeCustomersStmt->fetchAll() ?: [] as $row) {
    $activeCustomerRows[] = [
        'sessionId' => aims_int($row['session_id'] ?? 0),
        'name' => aims_str($row['full_name'] ?? ''),
        'email' => aims_str($row['email'] ?? ''),
        'spaceUsed' => aims_str($row['space_used'] ?? 'Open Space'),
        'membershipType' => aims_str($row['membership_type'] ?? 'Open Time'),
        'timeIn' => aims_str($row['check_in'] ?? ''),
        'status' => 'Active',
    ];
}

$latestTransactionsStmt = $pdo->query(
    <<<SQL
SELECT
    t.transaction_id,
    t.amount,
    t.discount_applied,
    t.final_amount,
    t.payment_method,
    t.status,
    t.created_at,
    u.full_name,
    u.email
FROM transactions t
INNER JOIN users u ON u.user_id = t.user_id
ORDER BY t.created_at DESC, t.transaction_id DESC
LIMIT 8
SQL
);
$latestTransactions = [];
foreach ($latestTransactionsStmt->fetchAll() ?: [] as $row) {
    $latestTransactions[] = [
        'transactionId' => aims_int($row['transaction_id'] ?? 0),
        'customerName' => aims_str($row['full_name'] ?? ''),
        'email' => aims_str($row['email'] ?? ''),
        'amount' => aims_float($row['amount'] ?? 0),
        'discountApplied' => aims_float($row['discount_applied'] ?? 0),
        'finalAmount' => aims_float($row['final_amount'] ?? 0),
        'paymentMethod' => aims_str($row['payment_method'] ?? 'cash'),
        'status' => aims_str($row['status'] ?? 'paid'),
        'createdAt' => aims_str($row['created_at'] ?? ''),
    ];
}

aims_ok([
    'activeCustomers' => $activeCustomers,
    'reservedBookings' => $reservedBookings,
    'activeSessions' => $activeSessions,
    'weeklyActivity' => $weeklyActivity,
    'pendingReservations' => $pendingReservations,
    'activeCustomerRows' => $activeCustomerRows,
    'latestTransactions' => $latestTransactions,
]);
