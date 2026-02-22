<?php
/**
 * Code Updater for AWS Migration
 * This script updates your existing code to use the config.php helper functions
 * 
 * IMPORTANT: Run this BEFORE provisioning AWS resources
 * This prepares your code but keeps it working locally
 */

// ==================== CONFIGURATION ====================
$PROJECT_ROOT = __DIR__; // Directory to scan
$BACKUP_ENABLED = true; // Create backups before modifying

// File extensions to scan
$FILE_EXTENSIONS = ['php', 'html', 'htm'];

// Directories to exclude
$EXCLUDE_DIRS = ['vendor', 'node_modules', '.git', 'backups'];

// Files to skip (config file itself, etc.)
$SKIP_FILES = ['config.php', 'code_updater.php', 'aws_resource_updater.php'];

// ==================== UPDATE PATTERNS ====================
$patterns = [
    // Image tags with /images/ path
    [
        'find' => '/(<img[^>]+src=["\'])(?:\.\/)?(?:\/)?images\/([^"\']+)(["\'])/i',
        'replace' => '$1<?php echo img(\'$2\'); ?>$3',
        'desc' => 'Image tags with /images/ path'
    ],
    // Image tags with ./images/ path
    [
        'find' => '/(<img[^>]+src=["\'])\.\/images\/([^"\']+)(["\'])/i',
        'replace' => '$1<?php echo img(\'$2\'); ?>$3',
        'desc' => 'Image tags with ./images/ path'
    ],
    // CSS link tags
    [
        'find' => '/(<link[^>]+href=["\'])(?:\.\/)?(?:\/)?css\/([^"\']+)(["\'])/i',
        'replace' => '$1<?php echo css(\'$2\'); ?>$3',
        'desc' => 'CSS link tags'
    ],
    // JavaScript script tags
    [
        'find' => '/(<script[^>]+src=["\'])(?:\.\/)?(?:\/)?js\/([^"\']+)(["\'])/i',
        'replace' => '$1<?php echo js(\'$2\'); ?>$3',
        'desc' => 'JavaScript script tags'
    ],
    // Generic assets folder
    [
        'find' => '/(<[^>]+(src|href)=["\'])(?:\.\/)?(?:\/)?assets\/([^"\']+)(["\'])/i',
        'replace' => '$1<?php echo asset(\'assets/$3\'); ?>$4',
        'desc' => 'Assets folder references'
    ],
    // Documents folder
    [
        'find' => '/(<[^>]+(src|href)=["\'])(?:\.\/)?(?:\/)?documents\/([^"\']+)(["\'])/i',
        'replace' => '$1<?php echo asset(\'documents/$3\'); ?>$4',
        'desc' => 'Documents folder references'
    ],
    // Uploads folder
    [
        'find' => '/(<[^>]+(src|href)=["\'])(?:\.\/)?(?:\/)?uploads\/([^"\']+)(["\'])/i',
        'replace' => '$1<?php echo asset(\'uploads/$3\'); ?>$4',
        'desc' => 'Uploads folder references'
    ],
];

// ==================== FUNCTIONS ====================

function scanDirectory($dir, $excludeDirs = []) {
    $files = [];
    
    $iterator = new RecursiveIteratorIterator(
        new RecursiveDirectoryIterator($dir, RecursiveDirectoryIterator::SKIP_DOTS),
        RecursiveIteratorIterator::SELF_FIRST
    );
    
    foreach ($iterator as $file) {
        if ($file->isFile()) {
            $path = $file->getPathname();
            
            $excluded = false;
            foreach ($excludeDirs as $excludeDir) {
                if (strpos($path, DIRECTORY_SEPARATOR . $excludeDir . DIRECTORY_SEPARATOR) !== false) {
                    $excluded = true;
                    break;
                }
            }
            
            if (!$excluded) {
                $files[] = $path;
            }
        }
    }
    
    return $files;
}

function shouldProcessFile($file, $extensions, $skipFiles) {
    $basename = basename($file);
    
    if (in_array($basename, $skipFiles)) {
        return false;
    }
    
    $ext = strtolower(pathinfo($file, PATHINFO_EXTENSION));
    return in_array($ext, $extensions);
}

function createBackup($file) {
    $backupDir = dirname($file) . DIRECTORY_SEPARATOR . 'backups';
    if (!is_dir($backupDir)) {
        mkdir($backupDir, 0755, true);
    }
    
    $backupFile = $backupDir . DIRECTORY_SEPARATOR . basename($file) . '.backup.' . date('Y-m-d_H-i-s');
    copy($file, $backupFile);
    return $backupFile;
}

function needsConfigRequire($content) {
    // Check if file already has require_once 'config.php'
    return (strpos($content, "require_once 'config.php'") === false && 
            strpos($content, 'require_once "config.php"') === false &&
            strpos($content, "require 'config.php'") === false &&
            strpos($content, 'require "config.php"') === false);
}

function addConfigRequire($content) {
    // Find the position after <?php tag
    if (preg_match('/<\?php/i', $content, $matches, PREG_OFFSET_CAPTURE)) {
        $pos = $matches[0][1] + strlen($matches[0][0]);
        $before = substr($content, 0, $pos);
        $after = substr($content, $pos);
        return $before . "\nrequire_once 'config.php';\n" . $after;
    }
    
    // If no <?php tag, add it at the beginning
    return "<?php require_once 'config.php'; ?>\n" . $content;
}

function updateFile($file, $patterns) {
    $content = file_get_contents($file);
    $originalContent = $content;
    $changes = [];
    
    foreach ($patterns as $pattern) {
        $count = 0;
        $content = preg_replace($pattern['find'], $pattern['replace'], $content, -1, $count);
        
        if ($count > 0) {
            $changes[] = [
                'desc' => $pattern['desc'],
                'count' => $count
            ];
        }
    }
    
    if ($content !== $originalContent) {
        // Add config.php require if needed
        if (needsConfigRequire($content)) {
            $content = addConfigRequire($content);
            $changes[] = [
                'desc' => 'Added config.php require',
                'count' => 1
            ];
        }
        
        file_put_contents($file, $content);
        return $changes;
    }
    
    return false;
}

// ==================== MAIN SCRIPT ====================

echo "╔════════════════════════════════════════════════════════╗\n";
echo "║     Code Updater for AWS Migration Preparation        ║\n";
echo "╚════════════════════════════════════════════════════════╝\n\n";

echo "This script will prepare your code for AWS migration.\n";
echo "Your site will still work locally after this update.\n\n";

echo "Configuration:\n";
echo "  Project Root: $PROJECT_ROOT\n";
echo "  Backup Enabled: " . ($BACKUP_ENABLED ? 'Yes' : 'No') . "\n\n";

echo "⚠️  This script will modify your files!\n";
echo "Backups will be created automatically.\n\n";
echo "Do you want to proceed? (yes/no): ";

$handle = fopen("php://stdin", "r");
$line = fgets($handle);
fclose($handle);

if (trim(strtolower($line)) !== 'yes') {
    echo "Aborted.\n";
    exit(0);
}

echo "\n🔍 Scanning files...\n\n";

$files = scanDirectory($PROJECT_ROOT, $EXCLUDE_DIRS);
$processedFiles = 0;
$modifiedFiles = 0;
$totalChanges = 0;

foreach ($files as $file) {
    if (shouldProcessFile($file, $FILE_EXTENSIONS, $SKIP_FILES)) {
        $processedFiles++;
        
        $changes = updateFile($file, $patterns);
        
        if ($changes) {
            if ($BACKUP_ENABLED) {
                $backupFile = createBackup($file);
            }
            
            $modifiedFiles++;
            $relativePath = str_replace($PROJECT_ROOT, '.', $file);
            echo "✅ Modified: $relativePath\n";
            
            foreach ($changes as $change) {
                echo "   - {$change['desc']}: {$change['count']} change(s)\n";
                $totalChanges += $change['count'];
            }
            echo "\n";
        }
    }
}

echo "\n╔════════════════════════════════════════════════════════╗\n";
echo "║                    SUMMARY                             ║\n";
echo "╚════════════════════════════════════════════════════════╝\n";
echo "Files scanned: $processedFiles\n";
echo "Files modified: $modifiedFiles\n";
echo "Total changes: $totalChanges\n\n";

if ($modifiedFiles > 0) {
    echo "✨ Your code is now prepared for AWS migration!\n\n";
    echo "NEXT STEPS:\n";
    echo "1. Test your site locally - everything should still work\n";
    echo "2. When ready to deploy to AWS:\n";
    echo "   - Provision AWS resources (S3, CloudFront, EC2)\n";
    echo "   - Update config.php with your AWS URLs\n";
    echo "   - Upload static files to S3\n";
    echo "   - Upload PHP files to EC2\n\n";
    
    if ($BACKUP_ENABLED) {
        echo "💾 Backups created in 'backups' folders\n";
    }
} else {
    echo "ℹ️  No changes needed - your code might already be updated!\n";
}

echo "\n✅ Done!\n";
?>
