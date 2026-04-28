<?php

require __DIR__ . '/../../../lib/bootstrap.php';

aims_require_method('GET');
aims_ensure_operational_tables();
$user = aims_current_user(true);
aims_require_roles($user, ['admin', 'manager']);

$days = aims_int($_GET['days'] ?? 7);
$days = max(1, min($days, 365));

$endAt = (new DateTimeImmutable('today'))->add(new DateInterval('P1D'));
$startAt = (new DateTimeImmutable('today'))->sub(new DateInterval('P' . ($days - 1) . 'D'));

$pdo = aims_pdo();
$stmt = $pdo->prepare(
    <<<SQL
SELECT
    COALESCE(SUM(CASE WHEN report_data.membership_group = 'Monthly Membership' THEN 1 ELSE 0 END), 0) AS monthly_membership,
    COALESCE(SUM(CASE WHEN report_data.membership_group = 'Walk-in' THEN 1 ELSE 0 END), 0) AS walk_in,
    COALESCE(SUM(CASE WHEN report_data.membership_group = 'Monthly Subscription' THEN 1 ELSE 0 END), 0) AS monthly_subscription,
    COALESCE(SUM(CASE WHEN report_data.membership_group = 'Loyal Customers' THEN 1 ELSE 0 END), 0) AS loyal_customers,
    COUNT(*) AS total_customers
FROM (
    SELECT DISTINCT
        s.user_id,
        CASE
            WHEN LOWER(COALESCE(up.membership_type, '')) = 'monthly membership' THEN 'Monthly Membership'
            WHEN LOWER(COALESCE(up.membership_type, '')) = 'loyalty rewards' THEN 'Loyal Customers'
            WHEN LOWER(COALESCE(up.membership_type, '')) = 'annual' THEN 'Monthly Subscription'
            ELSE 'Walk-in'
        END AS membership_group
    FROM sessions s
    LEFT JOIN user_profiles up ON up.user_id = s.user_id
    WHERE s.check_in >= :start_at
      AND s.check_in < :end_at
) report_data
SQL
);
$stmt->execute([
    ':start_at' => $startAt->format('Y-m-d H:i:s'),
    ':end_at' => $endAt->format('Y-m-d H:i:s'),
]);
$row = $stmt->fetch() ?: [];

$monthlyMembership = aims_int($row['monthly_membership'] ?? 0);
$walkIn = aims_int($row['walk_in'] ?? 0);
$monthlySubscription = aims_int($row['monthly_subscription'] ?? 0);
$loyalCustomers = aims_int($row['loyal_customers'] ?? 0);
$totalCustomers = aims_int($row['total_customers'] ?? 0);
$maxValue = max(1, $monthlyMembership, $walkIn, $monthlySubscription, $loyalCustomers);

aims_ok([
    'days' => $days,
    'from' => $startAt->format('Y-m-d'),
    'to' => $endAt->sub(new DateInterval('P1D'))->format('Y-m-d'),
    'monthlyMembership' => $monthlyMembership,
    'walkIn' => $walkIn,
    'monthlySubscription' => $monthlySubscription,
    'loyalCustomers' => $loyalCustomers,
    'totalCustomers' => $totalCustomers,
    'maxValue' => $maxValue,
    'categories' => [
        ['key' => 'monthlyMembership', 'label' => 'Monthly Membership', 'count' => $monthlyMembership],
        ['key' => 'walkIn', 'label' => 'Walk-in', 'count' => $walkIn],
        ['key' => 'monthlySubscription', 'label' => 'Monthly Subscription', 'count' => $monthlySubscription],
        ['key' => 'loyalCustomers', 'label' => 'Loyal Customers', 'count' => $loyalCustomers],
    ],
]);
