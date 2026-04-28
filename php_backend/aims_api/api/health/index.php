<?php

require __DIR__ . '/../../lib/bootstrap.php';

aims_require_method('GET');
aims_ok([
    'status' => 'healthy',
    'time' => gmdate('c'),
]);
