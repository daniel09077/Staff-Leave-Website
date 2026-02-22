#!/bin/bash

set -e  # Stop script immediately if any command fails

echo "🔧 Initializing Terraform..."
#terraform init
echo ""

# ---------------------------------------------------------
# 2. Format all .tf files
#    Fixes indentation and style automatically
# ---------------------------------------------------------
echo "🎨 Formatting Terraform files..."
terraform fmt -recursive
echo ""

# ---------------------------------------------------------
# 3. Validate configuration
#    Checks for syntax errors before spending any money
# ---------------------------------------------------------
echo "✅ Validating configuration..."
terraform validate
echo ""

# ---------------------------------------------------------
# 4. Plan — preview what will be created/changed/destroyed
#    Saves plan to file so apply uses exact same plan
# ---------------------------------------------------------
echo "📋 Generating plan..."
terraform plan -out=tfplan
echo ""

# ---------------------------------------------------------
# 5. Wait 30 seconds so you can review the plan output
#    Press Ctrl+C here to abort before anything is created
# ---------------------------------------------------------
echo "⏳ Review the plan above. Applying in 30 seconds..."
echo "   Press Ctrl+C NOW to cancel."
echo ""
sleep 30

# ---------------------------------------------------------
# 6. Apply using the saved plan file
# ---------------------------------------------------------
echo "🚀 Applying Terraform plan..."
terraform apply tfplan
echo ""

# ---------------------------------------------------------
# 7. Show outputs — copy these into aws_config.php
# ---------------------------------------------------------
echo "╔══════════════════════════════════════════════════════╗"
echo "║                    OUTPUTS                           ║"
echo "╚══════════════════════════════════════════════════════╝"
terraform output
echo ""
echo "✅ Deployment complete!"
echo ""
echo "  NEXT STEPS:"
echo "  1. Copy the cloudfront_domain_name from outputs above"
echo "  2. Open aws_config.php and update:"
echo "       define('ENVIRONMENT', 'aws');"
echo "       define('CLOUDFRONT_URL', 'https://YOUR-URL.cloudfront.net');"
echo "  3. Upload your PHP files to EC2"
echo "  4. Run your code_updater.php if not done already"
echo ""

# ---------------------------------------------------------
# Cleanup saved plan file
# ---------------------------------------------------------
rm -f tfplan