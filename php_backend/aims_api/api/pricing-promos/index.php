<?php

require __DIR__ . '/../../lib/bootstrap.php';

aims_ensure_operational_tables();
$currentUser = aims_current_user(true);
aims_require_roles($currentUser, ['admin', 'manager', 'staff']);

$method = strtoupper($_SERVER['REQUEST_METHOD']);
if ($method === 'GET') {
    handle_get();
}
if ($method === 'POST') {
    handle_post($currentUser);
}
if ($method === 'PATCH') {
    handle_patch($currentUser);
}
if ($method === 'DELETE') {
    handle_delete();
}
aims_error(405, 'Method not allowed.');

function handle_get(): void
{
    $pdo = aims_pdo();

    $membershipRows = $pdo->query(
        <<<SQL
SELECT
    membership_type_id,
    plan_name,
    duration_label,
    price_label,
    benefits
FROM membership_types
ORDER BY membership_type_id DESC
SQL
    )->fetchAll() ?: [];

    $promotionRows = $pdo->query(
        <<<SQL
SELECT
    promo_id,
    promo_name,
    promo_type,
    discount_rate,
    discount_label,
    end_date
FROM promotions
ORDER BY created_at DESC, promo_id DESC
SQL
    )->fetchAll() ?: [];

    $loyaltyRows = $pdo->query(
        <<<SQL
SELECT
    u.full_name,
    COUNT(s.session_id) AS entries_count
FROM users u
LEFT JOIN sessions s ON s.user_id = u.user_id
GROUP BY u.user_id, u.full_name
HAVING COUNT(s.session_id) > 0
ORDER BY entries_count DESC, u.full_name ASC
LIMIT 20
SQL
    )->fetchAll() ?: [];

    $pricingStmt = $pdo->prepare(
        <<<SQL
SELECT board_room_hourly_rate, ordinary_space_hourly_rate
FROM space_pricing
WHERE pricing_id = 1
LIMIT 1
SQL
    );
    $pricingStmt->execute();
    $pricingRow = $pricingStmt->fetch() ?: [];

    $membershipTypes = array_map(
        static fn(array $row): array => membership_payload($row),
        $membershipRows
    );
    $promotions = array_map(
        static fn(array $row): array => promotion_payload($row),
        $promotionRows
    );
    $loyaltyRewards = array_map(
        static fn(array $row): array => loyalty_payload($row),
        $loyaltyRows
    );

    aims_ok([
        'membershipTypes' => $membershipTypes,
        'promotions' => $promotions,
        'loyaltyRewards' => $loyaltyRewards,
        'spacePricing' => [
            'boardRoomHourlyRate' => aims_float($pricingRow['board_room_hourly_rate'] ?? 0),
            'ordinarySpaceHourlyRate' => aims_float($pricingRow['ordinary_space_hourly_rate'] ?? 0),
        ],
    ]);
}

function handle_post(array $currentUser): void
{
    $body = aims_body();
    $kind = strtolower(aims_require_field($body, 'kind'));

    if ($kind === 'membership') {
        create_membership_type($body, $currentUser);
    }
    if ($kind === 'promotion') {
        create_promotion($body, $currentUser);
    }

    aims_error(400, 'kind must be membership or promotion.');
}

function handle_patch(array $currentUser): void
{
    $body = aims_body();
    $kind = strtolower(aims_require_field($body, 'kind'));

    if ($kind === 'membership') {
        update_membership_type($body);
    }
    if ($kind === 'pricing') {
        update_space_pricing($body, $currentUser);
    }

    aims_error(400, 'kind must be membership or pricing.');
}

function handle_delete(): void
{
    $body = aims_body();
    $kind = strtolower(aims_require_field($body, 'kind'));

    if ($kind === 'membership') {
        $membershipTypeId = aims_int($body['membershipTypeId'] ?? 0);
        if ($membershipTypeId <= 0) {
            aims_error(400, 'Missing required field: membershipTypeId.');
        }

        $delete = aims_pdo()->prepare(
            'DELETE FROM membership_types WHERE membership_type_id = :membership_type_id'
        );
        $delete->execute([':membership_type_id' => $membershipTypeId]);

        if ($delete->rowCount() < 1) {
            aims_error(404, 'Membership type not found.');
        }

        aims_ok(['membershipTypeId' => $membershipTypeId]);
    }

    if ($kind === 'promotion') {
        $promoId = aims_int($body['promoId'] ?? 0);
        if ($promoId <= 0) {
            aims_error(400, 'Missing required field: promoId.');
        }

        $delete = aims_pdo()->prepare('DELETE FROM promotions WHERE promo_id = :promo_id');
        $delete->execute([':promo_id' => $promoId]);
        if ($delete->rowCount() < 1) {
            aims_error(404, 'Promotion not found.');
        }

        aims_ok(['promoId' => $promoId]);
    }

    aims_error(400, 'kind must be membership or promotion.');
}

function create_membership_type(array $body, array $currentUser): void
{
    $type = aims_require_field($body, 'type');
    $duration = aims_require_field($body, 'duration');
    $price = aims_require_field($body, 'price');
    $benefits = aims_require_field($body, 'benefits');

    $membershipTypeId = aims_insert_returning_id(
        aims_pdo(),
        <<<SQL
INSERT INTO membership_types (
    plan_name,
    duration_label,
    price_label,
    benefits,
    created_by_staff_id
)
VALUES (
    :plan_name,
    :duration_label,
    :price_label,
    :benefits,
    :created_by_staff_id
)
SQL,
        [
        ':plan_name' => $type,
        ':duration_label' => $duration,
        ':price_label' => $price,
        ':benefits' => $benefits,
        ':created_by_staff_id' => aims_int($currentUser['staff_id'] ?? 0) ?: null,
        ],
        'membership_type_id'
    );
    aims_ok(['membershipType' => fetch_membership_type($membershipTypeId)]);
}

function create_promotion(array $body, array $currentUser): void
{
    $name = aims_require_field($body, 'name');
    $type = aims_require_field($body, 'type');
    $discount = aims_require_field($body, 'discount');
    $expiry = aims_require_field($body, 'expiry');
    $benefits = aims_str($body['benefits'] ?? '');

    $endDate = parse_date_to_sql($expiry, 'expiry');
    $discountRate = parse_discount_rate($discount);

    $promoId = aims_insert_returning_id(
        aims_pdo(),
        <<<SQL
INSERT INTO promotions (
    promo_name,
    promo_type,
    discount_rate,
    discount_label,
    start_date,
    end_date,
    benefits
)
VALUES (
    :promo_name,
    :promo_type,
    :discount_rate,
    :discount_label,
    CURRENT_DATE,
    :end_date,
    :benefits
)
SQL,
        [
        ':promo_name' => $name,
        ':promo_type' => $type,
        ':discount_rate' => $discountRate,
        ':discount_label' => $discount,
        ':end_date' => $endDate,
        ':benefits' => $benefits === '' ? null : $benefits,
        ],
        'promo_id'
    );
    aims_ok(['promotion' => fetch_promotion($promoId)]);
}

function update_membership_type(array $body): void
{
    $membershipTypeId = aims_int($body['membershipTypeId'] ?? 0);
    if ($membershipTypeId <= 0) {
        aims_error(400, 'Missing required field: membershipTypeId.');
    }

    $type = aims_require_field($body, 'type');
    $duration = aims_require_field($body, 'duration');
    $price = aims_require_field($body, 'price');
    $benefits = aims_require_field($body, 'benefits');

    $update = aims_pdo()->prepare(
        <<<SQL
UPDATE membership_types
SET plan_name = :plan_name,
    duration_label = :duration_label,
    price_label = :price_label,
    benefits = :benefits
WHERE membership_type_id = :membership_type_id
SQL
    );
    $update->execute([
        ':plan_name' => $type,
        ':duration_label' => $duration,
        ':price_label' => $price,
        ':benefits' => $benefits,
        ':membership_type_id' => $membershipTypeId,
    ]);

    aims_ok(['membershipType' => fetch_membership_type($membershipTypeId)]);
}

function update_space_pricing(array $body, array $currentUser): void
{
    aims_require_roles($currentUser, ['admin', 'manager']);

    $boardRoomRate = aims_float($body['boardRoomHourlyRate'] ?? 0);
    $ordinarySpaceRate = aims_float($body['ordinarySpaceHourlyRate'] ?? 0);

    if ($boardRoomRate <= 0 || $ordinarySpaceRate <= 0) {
        aims_error(
            400,
            'boardRoomHourlyRate and ordinarySpaceHourlyRate must be greater than 0.'
        );
    }

    $pricingUpsertClause = aims_upsert_clause(
        'pricing_id',
        ['board_room_hourly_rate', 'ordinary_space_hourly_rate', 'updated_by_staff_id']
    );
    $upsert = aims_pdo()->prepare(
        <<<SQL
INSERT INTO space_pricing (
    pricing_id,
    board_room_hourly_rate,
    ordinary_space_hourly_rate,
    updated_by_staff_id
)
VALUES (
    1,
    :board_room_hourly_rate,
    :ordinary_space_hourly_rate,
    :updated_by_staff_id
)
{$pricingUpsertClause}
SQL
    );
    $upsert->execute([
        ':board_room_hourly_rate' => $boardRoomRate,
        ':ordinary_space_hourly_rate' => $ordinarySpaceRate,
        ':updated_by_staff_id' => aims_int($currentUser['staff_id'] ?? 0) ?: null,
    ]);

    aims_ok([
        'spacePricing' => [
            'boardRoomHourlyRate' => $boardRoomRate,
            'ordinarySpaceHourlyRate' => $ordinarySpaceRate,
        ],
    ]);
}

function fetch_membership_type(int $membershipTypeId): array
{
    $stmt = aims_pdo()->prepare(
        <<<SQL
SELECT
    membership_type_id,
    plan_name,
    duration_label,
    price_label,
    benefits
FROM membership_types
WHERE membership_type_id = :membership_type_id
LIMIT 1
SQL
    );
    $stmt->execute([':membership_type_id' => $membershipTypeId]);
    $row = $stmt->fetch();
    if (!$row) {
        aims_error(404, 'Membership type not found.');
    }
    return membership_payload($row);
}

function fetch_promotion(int $promoId): array
{
    $stmt = aims_pdo()->prepare(
        <<<SQL
SELECT
    promo_id,
    promo_name,
    promo_type,
    discount_rate,
    discount_label,
    end_date
FROM promotions
WHERE promo_id = :promo_id
LIMIT 1
SQL
    );
    $stmt->execute([':promo_id' => $promoId]);
    $row = $stmt->fetch();
    if (!$row) {
        aims_error(404, 'Promotion not found.');
    }
    return promotion_payload($row);
}

function membership_payload(array $row): array
{
    return [
        'membershipTypeId' => aims_int($row['membership_type_id'] ?? 0),
        'type' => aims_str($row['plan_name'] ?? ''),
        'duration' => aims_str($row['duration_label'] ?? ''),
        'price' => aims_str($row['price_label'] ?? ''),
        'benefits' => aims_str($row['benefits'] ?? ''),
    ];
}

function promotion_payload(array $row): array
{
    $discountLabel = aims_str($row['discount_label'] ?? '');
    if ($discountLabel === '') {
        $rate = aims_float($row['discount_rate'] ?? 0);
        $discountLabel = $rate > 0 ? number_format($rate, 2) : '';
    }

    return [
        'promoId' => aims_int($row['promo_id'] ?? 0),
        'name' => aims_str($row['promo_name'] ?? ''),
        'type' => aims_str($row['promo_type'] ?? ''),
        'discount' => $discountLabel,
        'expiry' => aims_str($row['end_date'] ?? ''),
    ];
}

function loyalty_payload(array $row): array
{
    $entries = aims_int($row['entries_count'] ?? 0);
    return [
        'memberName' => aims_str($row['full_name'] ?? ''),
        'entries' => $entries,
        'freeHours' => intdiv($entries, 5),
    ];
}

function parse_discount_rate(string $discountLabel): ?float
{
    $raw = preg_replace('/[^0-9.]+/', '', $discountLabel) ?? '';
    if ($raw === '') {
        return null;
    }

    $value = (float) $raw;
    if ($value <= 0) {
        return null;
    }
    return $value;
}

function parse_date_to_sql(string $value, string $field): string
{
    try {
        $date = new DateTimeImmutable($value);
    } catch (Throwable $error) {
        aims_error(400, "Invalid date format for {$field}.");
    }

    return $date->format('Y-m-d');
}
