<?php
/**
 * AWS Configuration File - Staff Leave System
 * 
 * HOW TO USE:
 * - Locally:  Works as-is, no changes needed
 * - On AWS:   Change ENVIRONMENT to 'aws' and fill in CLOUDFRONT_URL
 * 
 * Add this line at the top of every PHP file:
 *   require_once 'aws_config.php';  (adjust path if in subfolder)
 */

// =====================================================
// STEP 1: Change to 'aws' after terraform apply
// =====================================================
define('ENVIRONMENT', 'aws'); // 'local' or 'aws'

// =====================================================
// STEP 2: Paste your CloudFront URL after provisioning
// You'll get this from your terraform apply output:
//   cloudfront_domain_name = "d1234abcd.cloudfront.net"
// =====================================================
define('CLOUDFRONT_URL', 'https://d16vspqnnrbzcq.cloudfront.net'); // e.g. https://d1234abcd.cloudfront.net

// =====================================================
// AUTO LOGIC — do not change below this line
// =====================================================
if (ENVIRONMENT === 'aws') {
    if (empty(CLOUDFRONT_URL)) {
        die('ERROR: CLOUDFRONT_URL is not set in aws_config.php');
    }
    define('VENDORS_BASE', rtrim(CLOUDFRONT_URL, '/') . '/vendors');
} else {
    // Local: use relative path
    define('VENDORS_BASE', 'vendors');
}

// =====================================================
// HELPER FUNCTIONS
// All your assets live under vendors/ so we only
// need one function that builds the full path
// =====================================================

/**
 * Returns full URL to any file inside the vendors folder
 * 
 * Usage:
 *   vendor('https://d1234abcd.cloudfront.net/images/logo.png')
 *   vendor('styles/core.css')
 *   vendor('scripts/core.js')
 * 
 * Local result:  vendors/images/logo.png
 * AWS result:    https://d123.cloudfront.net/vendors/images/logo.png
 */
function vendor_asset($path) {
    $path = ltrim($path, '/');
    return VENDORS_BASE . '/' . $path;
}

// Short alias — use vendor() in your PHP files
// vendor('https://d1234abcd.cloudfront.net/images/logo.png') is cleaner to type
if (!function_exists('vendor')) {
    function vendor($path) {
        return vendor_asset($path);
    }
}
?>