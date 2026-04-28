<?php

require __DIR__ . '/../../../lib/bootstrap.php';

aims_require_method('GET');
$user = aims_current_user(true);
aims_require_roles($user, ['admin', 'manager']);

$range = strtolower(aims_str($_GET['range'] ?? 'monthly'));
$allowed = ['daily', 'weekly', 'monthly', 'yearly'];
if (!in_array($range, $allowed, true)) {
    aims_error(400, 'range must be daily, weekly, monthly, or yearly.');
}

$points = build_sales_points($range);
$revenues = array_map(static fn($point) => aims_float($point['revenue']), $points);
$transactions = array_map(static fn($point) => aims_int($point['transactions']), $points);

$maxRevenue = max(1.0, max($revenues ?: [1.0]));
$maxTransactions = max(1, max($transactions ?: [1]));

$areaValues = $revenues;
$lineValues = [];
foreach ($transactions as $txCount) {
    $lineValues[] = ($txCount / $maxTransactions) * ($maxRevenue * 0.6);
}

$highlightIndex = 0;
for ($i = count($revenues) - 1; $i >= 0; $i--) {
    if ($revenues[$i] > 0) {
        $highlightIndex = $i;
        break;
    }
}

$maxY = max($maxRevenue * 1.25, 10.0);

aims_ok([
    'range' => $range,
    'labels' => array_map(static fn($point) => $point['label'], $points),
    'tooltipTitles' => array_map(static fn($point) => $point['title'], $points),
    'tooltipValues' => array_map(
        static fn($point) => '$' . number_format(aims_float($point['revenue']), 2),
        $points
    ),
    'areaValues' => $areaValues,
    'lineValues' => $lineValues,
    'highlightX' => $highlightIndex,
    'maxY' => $maxY,
    'totals' => [
        'revenue' => array_sum($revenues),
        'transactions' => array_sum($transactions),
    ],
]);

function build_sales_points(string $range): array
{
    $pdo = aims_pdo();
    $points = [];

    if ($range === 'daily') {
        $hours = [6, 8, 10, 12, 14, 16, 18];
        foreach ($hours as $hour) {
            $start = (new DateTimeImmutable('today'))->setTime($hour, 0, 0);
            $end = $start->add(new DateInterval('PT2H'));
            $summary = query_sales_summary($pdo, $start, $end);
            $points[] = [
                'label' => format_hour_label($hour),
                'title' => $start->format('gA') . ' Today',
                'revenue' => $summary['revenue'],
                'transactions' => $summary['transactions'],
            ];
        }
        return $points;
    }

    if ($range === 'weekly') {
        for ($i = 6; $i >= 0; $i--) {
            $day = (new DateTimeImmutable('today'))->sub(new DateInterval("P{$i}D"));
            $start = $day->setTime(0, 0, 0);
            $end = $start->add(new DateInterval('P1D'));
            $summary = query_sales_summary($pdo, $start, $end);
            $points[] = [
                'label' => $day->format('D'),
                'title' => $day->format('D, M j Y'),
                'revenue' => $summary['revenue'],
                'transactions' => $summary['transactions'],
            ];
        }
        return $points;
    }

    if ($range === 'monthly') {
        for ($i = 11; $i >= 0; $i--) {
            $monthStart = (new DateTimeImmutable('first day of this month'))
                ->sub(new DateInterval("P{$i}M"))
                ->setTime(0, 0, 0);
            $monthEnd = $monthStart->add(new DateInterval('P1M'));
            $summary = query_sales_summary($pdo, $monthStart, $monthEnd);
            $points[] = [
                'label' => $monthStart->format('M'),
                'title' => $monthStart->format('F Y'),
                'revenue' => $summary['revenue'],
                'transactions' => $summary['transactions'],
            ];
        }
        return $points;
    }

    // yearly
    for ($i = 5; $i >= 0; $i--) {
        $yearStart = (new DateTimeImmutable('first day of january this year'))
            ->sub(new DateInterval("P{$i}Y"))
            ->setTime(0, 0, 0);
        $yearEnd = $yearStart->add(new DateInterval('P1Y'));
        $summary = query_sales_summary($pdo, $yearStart, $yearEnd);
        $points[] = [
            'label' => $yearStart->format('Y'),
            'title' => 'Year ' . $yearStart->format('Y'),
            'revenue' => $summary['revenue'],
            'transactions' => $summary['transactions'],
        ];
    }

    return $points;
}

function query_sales_summary(PDO $pdo, DateTimeImmutable $start, DateTimeImmutable $end): array
{
    $stmt = $pdo->prepare(
        <<<SQL
SELECT
    COALESCE(SUM(final_amount), 0) AS revenue,
    COUNT(*) AS transactions
FROM transactions
WHERE created_at >= :start_at
  AND created_at < :end_at
SQL
    );
    $stmt->execute([
        ':start_at' => $start->format('Y-m-d H:i:s'),
        ':end_at' => $end->format('Y-m-d H:i:s'),
    ]);
    $row = $stmt->fetch() ?: ['revenue' => 0, 'transactions' => 0];

    return [
        'revenue' => aims_float($row['revenue'] ?? 0),
        'transactions' => aims_int($row['transactions'] ?? 0),
    ];
}

function format_hour_label(int $hour): string
{
    if ($hour === 0) {
        return '12AM';
    }
    if ($hour < 12) {
        return $hour . 'AM';
    }
    if ($hour === 12) {
        return '12PM';
    }
    return ($hour - 12) . 'PM';
}
