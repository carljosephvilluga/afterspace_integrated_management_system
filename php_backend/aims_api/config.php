<?php

$envFile = __DIR__ . '/.env';
if (is_file($envFile)) {
    $lines = file($envFile, FILE_IGNORE_NEW_LINES | FILE_SKIP_EMPTY_LINES) ?: [];
    foreach ($lines as $line) {
        $line = trim($line);
        if ($line === '' || str_starts_with($line, '#')) {
            continue;
        }

        [$key, $value] = array_pad(explode('=', $line, 2), 2, '');
        $key = trim($key);
        if ($key === '' || getenv($key) !== false) {
            continue;
        }

        $value = trim(trim($value), '"\'');
        putenv("{$key}={$value}");
        $_ENV[$key] = $value;
    }
}

return [
    'db_driver' => getenv('AIMS_DB_DRIVER') ?: 'mysql',
    'db_host' => getenv('AIMS_DB_HOST') ?: '127.0.0.1',
    'db_port' => getenv('AIMS_DB_PORT') ?: null,
    'db_name' => getenv('AIMS_DB_NAME') ?: null,
    'db_user' => getenv('AIMS_DB_USER') ?: null,
    'db_pass' => getenv('AIMS_DB_PASS') ?: '',
    'token_ttl_hours' => (int) (getenv('AIMS_TOKEN_TTL_HOURS') ?: 12),
];

