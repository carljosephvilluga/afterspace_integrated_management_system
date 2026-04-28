<?php

declare(strict_types=1);

$aimsConfig = require __DIR__ . '/../config.php';

header('Access-Control-Allow-Origin: *');
header('Access-Control-Allow-Methods: GET,POST,PATCH,DELETE,OPTIONS');
header('Access-Control-Allow-Headers: Content-Type, Authorization');
header('Content-Type: application/json');

if ($_SERVER['REQUEST_METHOD'] === 'OPTIONS') {
    http_response_code(204);
    exit;
}

function aims_config(string $key, $default = null)
{
    global $aimsConfig;
    return $aimsConfig[$key] ?? $default;
}

function aims_pdo(): PDO
{
    static $pdo = null;
    if ($pdo instanceof PDO) {
        return $pdo;
    }

    $host = aims_config('db_host', '127.0.0.1');
    $port = aims_config('db_port', '3306');
    $db = aims_config('db_name', 'afterspace_db');
    $user = aims_config('db_user', 'root');
    $pass = aims_config('db_pass', '');

    $dsn = "mysql:host={$host};port={$port};dbname={$db};charset=utf8mb4";
    $pdo = new PDO($dsn, $user, $pass, [
        PDO::ATTR_ERRMODE => PDO::ERRMODE_EXCEPTION,
        PDO::ATTR_DEFAULT_FETCH_MODE => PDO::FETCH_ASSOC,
        PDO::ATTR_EMULATE_PREPARES => false,
    ]);

    return $pdo;
}

function aims_json(int $statusCode, array $payload): void
{
    http_response_code($statusCode);
    echo json_encode($payload, JSON_UNESCAPED_SLASHES);
    exit;
}

function aims_ok($data): void
{
    aims_json(200, ['ok' => true, 'data' => $data]);
}

function aims_error(int $statusCode, string $message): void
{
    aims_json($statusCode, ['ok' => false, 'error' => ['message' => $message]]);
}

function aims_require_method(string $method): void
{
    if (strtoupper($_SERVER['REQUEST_METHOD']) !== strtoupper($method)) {
        aims_error(405, 'Method not allowed.');
    }
}

function aims_body(): array
{
    $raw = file_get_contents('php://input');
    if ($raw === false || trim($raw) === '') {
        return [];
    }

    $decoded = json_decode($raw, true);
    if (!is_array($decoded)) {
        aims_error(400, 'Request body must be a JSON object.');
    }
    return $decoded;
}

function aims_str($value): string
{
    if ($value === null) {
        return '';
    }
    return trim((string) $value);
}

function aims_require_field(array $body, string $field): string
{
    $value = aims_str($body[$field] ?? '');
    if ($value === '') {
        aims_error(400, "Missing required field: {$field}.");
    }
    return $value;
}

function aims_role_normalize(string $role): string
{
    $normalized = strtolower(trim($role));
    if (!in_array($normalized, ['admin', 'manager', 'staff'], true)) {
        aims_error(400, 'Role must be admin, manager, or staff.');
    }
    return $normalized;
}

function aims_bearer_token(): ?string
{
    $header = $_SERVER['HTTP_AUTHORIZATION'] ?? '';
    if ($header === '' && function_exists('apache_request_headers')) {
        $headers = apache_request_headers();
        if (is_array($headers)) {
            $header = $headers['Authorization'] ?? $headers['authorization'] ?? '';
        }
    }

    if (!preg_match('/^Bearer\s+(.+)$/i', (string) $header, $matches)) {
        return null;
    }

    $token = trim($matches[1]);
    return $token === '' ? null : $token;
}

function aims_user_without_secret(array $row): array
{
    unset($row['password_hash']);
    $row['role'] = strtolower((string) ($row['role'] ?? ''));
    return $row;
}

function aims_current_user(bool $required = true): ?array
{
    $token = aims_bearer_token();
    if ($token === null) {
        if ($required) {
            aims_error(401, 'Missing or invalid token.');
        }
        return null;
    }

    $sql = <<<SQL
SELECT
    s.staff_id,
    s.employee_id,
    s.full_name,
    s.email,
    s.role,
    s.status
FROM api_sessions sess
INNER JOIN staff_accounts s ON s.staff_id = sess.staff_id
WHERE sess.token = :token AND sess.expires_at > NOW()
LIMIT 1
SQL;

    $stmt = aims_pdo()->prepare($sql);
    $stmt->execute([':token' => $token]);
    $user = $stmt->fetch();

    if (!$user) {
        if ($required) {
            aims_error(401, 'Missing or invalid token.');
        }
        return null;
    }

    return aims_user_without_secret($user);
}

function aims_require_roles(array $user, array $roles): void
{
    $userRole = strtolower((string) ($user['role'] ?? ''));
    $normalized = array_map(static fn($role) => strtolower((string) $role), $roles);
    if (!in_array($userRole, $normalized, true)) {
        aims_error(403, 'You do not have permission for this action.');
    }
}

function aims_issue_session_token(int $staffId): string
{
    $token = bin2hex(random_bytes(32));
    $ttlHours = (int) aims_config('token_ttl_hours', 12);

    $sql = <<<SQL
INSERT INTO api_sessions (token, staff_id, expires_at)
VALUES (:token, :staff_id, DATE_ADD(NOW(), INTERVAL :ttl HOUR))
SQL;
    $stmt = aims_pdo()->prepare($sql);
    $stmt->bindValue(':token', $token);
    $stmt->bindValue(':staff_id', $staffId, PDO::PARAM_INT);
    $stmt->bindValue(':ttl', $ttlHours, PDO::PARAM_INT);
    $stmt->execute();

    return $token;
}

function aims_logout_token(?string $token): void
{
    if ($token === null) {
        return;
    }
    $stmt = aims_pdo()->prepare('DELETE FROM api_sessions WHERE token = :token');
    $stmt->execute([':token' => $token]);
}

function aims_int($value): int
{
    return (int) $value;
}

function aims_float($value): float
{
    return (float) $value;
}

function aims_parse_datetime(string $value, string $fieldName): DateTimeImmutable
{
    $trimmed = trim($value);
    if ($trimmed === '') {
        aims_error(400, "Missing required field: {$fieldName}.");
    }

    try {
        return new DateTimeImmutable($trimmed);
    } catch (Throwable $error) {
        aims_error(400, "Invalid datetime format for {$fieldName}.");
    }
}

function aims_space_label(string $value): string
{
    $normalized = strtolower(trim($value));
    if (in_array($normalized, ['board room', 'boardroom'], true)) {
        return 'Board Room';
    }

    if (in_array($normalized, ['open space', 'ordinary space', 'open'], true)) {
        return 'Open Space';
    }

    aims_error(400, 'Space type must be Board Room or Open Space.');
}

function aims_ensure_operational_tables(): void
{
    static $ensured = false;
    if ($ensured) {
        return;
    }

    $pdo = aims_pdo();
    $pdo->exec(
        <<<SQL
CREATE TABLE IF NOT EXISTS booking_meta (
    booking_id INT PRIMARY KEY,
    space_type ENUM('Board Room', 'Open Space') NOT NULL DEFAULT 'Open Space',
    customer_type VARCHAR(50) NOT NULL DEFAULT 'Guest',
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_booking_meta_booking
        FOREIGN KEY (booking_id) REFERENCES bookings(booking_id)
        ON DELETE CASCADE
)
SQL
    );
    $pdo->exec(
        <<<SQL
CREATE TABLE IF NOT EXISTS session_meta (
    session_id INT PRIMARY KEY,
    space_used ENUM('Board Room', 'Open Space') NOT NULL DEFAULT 'Open Space',
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_session_meta_session
        FOREIGN KEY (session_id) REFERENCES sessions(session_id)
        ON DELETE CASCADE
)
SQL
    );
    $pdo->exec(
        <<<SQL
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
)
SQL
    );
    $pdo->exec(
        <<<SQL
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
)
SQL
    );
    $pdo->exec(
        <<<SQL
INSERT INTO user_profiles (
    user_id,
    first_name,
    last_name,
    user_type,
    membership_type,
    history_json
)
SELECT
    u.user_id,
    SUBSTRING_INDEX(u.full_name, ' ', 1),
    TRIM(SUBSTRING(u.full_name, LENGTH(SUBSTRING_INDEX(u.full_name, ' ', 1)) + 1)),
    'Student',
    'Open Time',
    '[]'
FROM users u
WHERE NOT EXISTS (
    SELECT 1 FROM user_profiles up WHERE up.user_id = u.user_id
)
SQL
    );

    $ensured = true;
}
