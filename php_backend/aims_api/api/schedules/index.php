<?php

require __DIR__ . '/../../lib/bootstrap.php';

aims_ensure_operational_tables();
$currentUser = aims_current_user(true);
aims_require_roles($currentUser, ['admin', 'manager']);

$method = strtoupper($_SERVER['REQUEST_METHOD']);
if ($method === 'GET') {
    handle_get_schedules();
}
if ($method === 'POST') {
    handle_create_schedule($currentUser);
}
if ($method === 'PATCH') {
    handle_update_schedule();
}
if ($method === 'DELETE') {
    handle_delete_schedule();
}
aims_error(405, 'Method not allowed.');

function handle_get_schedules(): void
{
    $from = aims_str($_GET['from'] ?? '');
    $to = aims_str($_GET['to'] ?? '');

    $where = [];
    $params = [];
    if ($from !== '') {
        if (!preg_match('/^\d{4}-\d{2}-\d{2}$/', $from)) {
            aims_error(400, 'from must use YYYY-MM-DD format.');
        }
        $where[] = 'ms.end_at >= :from_at';
        $params[':from_at'] = $from . ' 00:00:00';
    }
    if ($to !== '') {
        if (!preg_match('/^\d{4}-\d{2}-\d{2}$/', $to)) {
            aims_error(400, 'to must use YYYY-MM-DD format.');
        }
        $where[] = 'ms.start_at < DATE_ADD(:to_at, INTERVAL 1 DAY)';
        $params[':to_at'] = $to . ' 00:00:00';
    }

    $whereSql = count($where) > 0 ? 'WHERE ' . implode(' AND ', $where) : '';
    $sql = <<<SQL
SELECT
    ms.schedule_id,
    ms.title,
    ms.notes,
    ms.start_at,
    ms.end_at,
    ms.created_at,
    ms.updated_at,
    ms.created_by_staff_id,
    sa.employee_id AS created_by_employee_id,
    sa.full_name AS created_by_name
FROM meeting_schedules ms
LEFT JOIN staff_accounts sa ON sa.staff_id = ms.created_by_staff_id
{$whereSql}
ORDER BY ms.start_at ASC, ms.schedule_id ASC
LIMIT 500
SQL;

    $stmt = aims_pdo()->prepare($sql);
    $stmt->execute($params);
    $rows = $stmt->fetchAll() ?: [];
    $schedules = array_map('to_schedule_payload', $rows);

    aims_ok(['schedules' => $schedules]);
}

function handle_create_schedule(array $currentUser): void
{
    $body = aims_body();

    $title = aims_require_field($body, 'title');
    $notes = aims_str($body['notes'] ?? '');
    if (strlen($title) > 150) {
        aims_error(400, 'title must be 150 characters or less.');
    }
    if (strlen($notes) > 255) {
        aims_error(400, 'notes must be 255 characters or less.');
    }

    $startAt = aims_parse_datetime(aims_require_field($body, 'startAt'), 'startAt');
    $endAt = aims_parse_datetime(aims_require_field($body, 'endAt'), 'endAt');

    if ($endAt <= $startAt) {
        aims_error(400, 'endAt must be later than startAt.');
    }

    $creatorStaffId = aims_int($currentUser['staff_id'] ?? 0);
    if ($creatorStaffId <= 0) {
        $creatorStaffId = null;
    }

    $pdo = aims_pdo();
    $insert = $pdo->prepare(
        <<<SQL
INSERT INTO meeting_schedules (
    title,
    notes,
    start_at,
    end_at,
    created_by_staff_id
)
VALUES (
    :title,
    :notes,
    :start_at,
    :end_at,
    :created_by_staff_id
)
SQL
    );
    $insert->bindValue(':title', $title);
    $insert->bindValue(':notes', $notes !== '' ? $notes : null);
    $insert->bindValue(':start_at', $startAt->format('Y-m-d H:i:s'));
    $insert->bindValue(':end_at', $endAt->format('Y-m-d H:i:s'));
    if ($creatorStaffId === null) {
        $insert->bindValue(':created_by_staff_id', null, PDO::PARAM_NULL);
    } else {
        $insert->bindValue(':created_by_staff_id', $creatorStaffId, PDO::PARAM_INT);
    }
    $insert->execute();

    $scheduleId = aims_int($pdo->lastInsertId());
    aims_ok(['schedule' => fetch_schedule_payload($scheduleId)]);
}

function handle_update_schedule(): void
{
    $body = aims_body();
    $scheduleId = aims_int($body['scheduleId'] ?? 0);
    if ($scheduleId <= 0) {
        aims_error(400, 'Missing required field: scheduleId.');
    }

    $title = aims_require_field($body, 'title');
    $notes = aims_str($body['notes'] ?? '');
    if (strlen($title) > 150) {
        aims_error(400, 'title must be 150 characters or less.');
    }
    if (strlen($notes) > 255) {
        aims_error(400, 'notes must be 255 characters or less.');
    }

    $startAt = aims_parse_datetime(aims_require_field($body, 'startAt'), 'startAt');
    $endAt = aims_parse_datetime(aims_require_field($body, 'endAt'), 'endAt');

    if ($endAt <= $startAt) {
        aims_error(400, 'endAt must be later than startAt.');
    }

    $update = aims_pdo()->prepare(
        <<<SQL
UPDATE meeting_schedules
SET title = :title,
    notes = :notes,
    start_at = :start_at,
    end_at = :end_at
WHERE schedule_id = :schedule_id
SQL
    );
    $update->bindValue(':title', $title);
    $update->bindValue(':notes', $notes !== '' ? $notes : null);
    $update->bindValue(':start_at', $startAt->format('Y-m-d H:i:s'));
    $update->bindValue(':end_at', $endAt->format('Y-m-d H:i:s'));
    $update->bindValue(':schedule_id', $scheduleId, PDO::PARAM_INT);
    $update->execute();

    if ($update->rowCount() < 1) {
        // Distinguish "no row found" from "no field changed"
        fetch_schedule_payload($scheduleId);
    }

    aims_ok(['schedule' => fetch_schedule_payload($scheduleId)]);
}

function handle_delete_schedule(): void
{
    $body = aims_body();
    $scheduleId = aims_int($body['scheduleId'] ?? 0);
    if ($scheduleId <= 0) {
        aims_error(400, 'Missing required field: scheduleId.');
    }

    $delete = aims_pdo()->prepare(
        'DELETE FROM meeting_schedules WHERE schedule_id = :schedule_id'
    );
    $delete->execute([':schedule_id' => $scheduleId]);

    if ($delete->rowCount() < 1) {
        aims_error(404, 'Schedule not found.');
    }

    aims_ok(['scheduleId' => $scheduleId]);
}

function fetch_schedule_payload(int $scheduleId): array
{
    $stmt = aims_pdo()->prepare(
        <<<SQL
SELECT
    ms.schedule_id,
    ms.title,
    ms.notes,
    ms.start_at,
    ms.end_at,
    ms.created_at,
    ms.updated_at,
    ms.created_by_staff_id,
    sa.employee_id AS created_by_employee_id,
    sa.full_name AS created_by_name
FROM meeting_schedules ms
LEFT JOIN staff_accounts sa ON sa.staff_id = ms.created_by_staff_id
WHERE ms.schedule_id = :schedule_id
LIMIT 1
SQL
    );
    $stmt->execute([':schedule_id' => $scheduleId]);
    $row = $stmt->fetch();
    if (!$row) {
        aims_error(404, 'Schedule not found.');
    }

    return to_schedule_payload($row);
}

function to_schedule_payload(array $row): array
{
    return [
        'scheduleId' => aims_int($row['schedule_id'] ?? 0),
        'title' => aims_str($row['title'] ?? ''),
        'notes' => aims_str($row['notes'] ?? ''),
        'startAt' => aims_str($row['start_at'] ?? ''),
        'endAt' => aims_str($row['end_at'] ?? ''),
        'createdAt' => aims_str($row['created_at'] ?? ''),
        'updatedAt' => aims_str($row['updated_at'] ?? ''),
        'createdByStaffId' => aims_int($row['created_by_staff_id'] ?? 0),
        'createdByEmployeeId' => aims_str($row['created_by_employee_id'] ?? ''),
        'createdByName' => aims_str($row['created_by_name'] ?? ''),
    ];
}
