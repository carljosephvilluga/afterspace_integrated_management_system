<?php

require __DIR__ . '/../../../lib/bootstrap.php';

aims_require_method('GET');
$user = aims_current_user(true);
aims_require_roles($user, ['admin']);

$pdo = aims_pdo();

$staffCount = aims_int($pdo->query('SELECT COUNT(*) FROM staff_accounts')->fetchColumn());
$userCount = aims_int($pdo->query('SELECT COUNT(*) FROM users')->fetchColumn());
$activeSessions = aims_int(
    $pdo->query("SELECT COUNT(*) FROM sessions WHERE LOWER(status) = 'active'")->fetchColumn()
);
$totalRevenue = aims_float(
    $pdo->query('SELECT COALESCE(SUM(final_amount), 0) FROM transactions')->fetchColumn()
);
$bookingCount = aims_int($pdo->query('SELECT COUNT(*) FROM bookings')->fetchColumn());

aims_ok([
    'staffCount' => $staffCount,
    'userCount' => $userCount,
    'activeSessions' => $activeSessions,
    'totalRevenue' => $totalRevenue,
    'bookingCount' => $bookingCount,
]);
