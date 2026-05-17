<?php

@set_time_limit(0);
@ini_set('max_execution_time', 0);
@ini_set('memory_limit', '256M');
@ini_set('output_buffering', 'Off');
@ini_set('zlib.output_compression', 0);

ignore_user_abort(true);
error_reporting(0);
ini_set('display_errors', 0);

$DESTINATION_HOST = '91.107.251.152';
$DESTINATION_PORT = 443;
$DESTINATION_PATH = '/stream';

header('X-Accel-Buffering: no');
header('Content-Encoding: none');
header('Cache-Control: no-cache, no-store, must-revalidate');
header('Pragma: no-cache');
header('Expires: 0');

$method = $_SERVER['REQUEST_METHOD'] ?? 'GET';
$isUpgrade = isset($_SERVER['HTTP_UPGRADE']) && strtoupper($_SERVER['HTTP_UPGRADE']) === 'WEBSOCKET';


if (!$isUpgrade && $method === 'GET') {
    $fp = @fsockopen($DESTINATION_HOST, $DESTINATION_PORT, $errno, $errstr, 3);
    if ($fp) {
        fclose($fp);
        echo "OK";
    } else {
        echo "ERROR";
    }
    exit;
}

$remote = @fsockopen('tcp://' . $DESTINATION_HOST, $DESTINATION_PORT, $errno, $errstr, 8);
if (!$remote) {
    http_response_code(502);
    exit;
}

stream_set_timeout($remote, 0, 500000);

$key = $_SERVER['HTTP_SEC_WEBSOCKET_KEY'] ?? base64_encode(random_bytes(16));

$req = "GET {$DESTINATION_PATH} HTTP/1.1\r\n";
$req .= "Host: {$DESTINATION_HOST}:{$DESTINATION_PORT}\r\n";
$req .= "Upgrade: websocket\r\n";
$req .= "Connection: Upgrade\r\n";
$req .= "Sec-WebSocket-Key: {$key}\r\n";
$req .= "Sec-WebSocket-Version: 13\r\n\r\n";

fwrite($remote, $req);

$resp = '';
$deadline = time() + 10;
while (!feof($remote) && time() < $deadline) {
    $line = fgets($remote, 1024);
    if ($line === false) break;
    $resp .= $line;
    if ($line === "\r\n") break;
}

if (strpos($resp, '101') === false) {
    http_response_code(502);
    fclose($remote);
    exit;
}

http_response_code(101);
header('Upgrade: websocket');
header('Connection: Upgrade');

$accept = base64_encode(sha1($key . '258EAFA5-E914-47DA-95CA-C5AB0DC85B11', true));
header('Sec-WebSocket-Accept: ' . $accept);

while (ob_get_level()) ob_end_flush();
flush();

stream_set_blocking($remote, false);
$input = fopen('php://input', 'rb');
stream_set_blocking($input, false);

$lastActivity = time();

while (true) {
    if (feof($remote) || (time() - $lastActivity > 300)) break;

    $r = [$remote, $input];
    $w = $e = null;
    $ready = @stream_select($r, $w, $e, 0, 200000);

    if ($ready === false) break;
    if ($ready === 0) continue;

    foreach ($r as $s) {
        $data = @fread($s, 65536);
        if ($data === false || $data === '') continue;

        $lastActivity = time();

        if ($s === $remote) {
            echo $data;
            flush();
        } else {
            if (@fwrite($remote, $data) === false) break 2;
        }
    }
}

@fclose($remote);
@fclose($input);
?>
