<?php

function getIps($hostname) {
    $result = dns_get_record($hostname, DNS_A);
    $ips = [];
    foreach ($result as $record) {
        if (isset($record['ip'])) {
            $ips[] = $record['ip'];
        }
    }
    return $ips;
}

function downloadContent($url, $hostname, $ip, $protocol, $debug) {
    $ch = curl_init();
    curl_setopt($ch, CURLOPT_URL, $url);
    curl_setopt($ch, CURLOPT_RETURNTRANSFER, true);
    curl_setopt($ch, CURLOPT_RESOLVE, ["$hostname:$protocol:$ip"]);
    $content = curl_exec($ch);
    curl_close($ch);

    if ($debug) {
        echo "Downloaded content from $url to $ip directory\n";
    }

    return $content;
}

function computeHash($content, $hashAlg) {
    return hash($hashAlg, $content);
}

function main() {
    $url = $_GET['url'] ?? null;
    $hash = $_GET['hash'] ?? null;
    $file = $_GET['file'] ?? null;
    $hashAlg = $_GET['hash_alg'] ?? 'md5';
    $debug = isset($_GET['debug']);

    if (!$url) {
        echo "Usage: ?url=<URL>&hash=<HASH>&file=<FILE>&hash_alg=<HASH_ALG>&debug\n";
        exit(1);
    }

    if ($file) {
        if (file_exists($file)) {
            $hash = hash_file($hashAlg, $file);
        } else {
            echo "File $file does not exist.\n";
            exit(1);
        }
    }

    $protocol = (strpos($url, 'https://') === 0) ? 443 : 80;
    $hostname = parse_url($url, PHP_URL_HOST);
    $ips = getIps($hostname);

    if ($debug) {
        echo "URL: $url\n";
        echo "HASH: $hash\n";
        echo "PROTOCOL: $protocol\n";
        echo "HOSTNAME: $hostname\n";
        echo "HASH_ALG: $hashAlg\n";
        echo "IPS: " . implode(', ', $ips) . "\n";
    }

    foreach ($ips as $ip) {
        $content = downloadContent($url, $hostname, $ip, $protocol, $debug);
        $computedHash = computeHash($content, $hashAlg);

        if ($hash) {
            if ($computedHash === $hash) {
                echo "Hash matches || $ip\n";
            } else {
                echo "Hash \033[0;31mNOT\033[0m matches || $ip\n";
            }
        } else {
            echo "$hashAlg hash: $computedHash\n";
        }
    }
}

main();
?>