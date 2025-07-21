#!/bin/bash
set -e

echo "🚀 Committing all enhancements..."

# Stage all new files
git add .

# Commit 1: Terraform module completions
git add terraform/modules/aks/outputs.tf terraform/modules/networking/main.tf terraform/modules/networking/outputs.tf
git commit -m "🏗️ Complete Terraform modules with missing outputs and networking

✨ Additions:
- Complete AKS module outputs for cluster integration
- Virtual network and subnet configuration for networking module
- Proper module structure for enterprise deployment

🔧 Technical Details:
- AKS cluster connection information and credentials
- Network infrastructure with 10.0.0.0/8 VNet allocation
- Module outputs for cross-module integration" || echo "Already committed"

# Commit 2: Kubernetes namespaces and RBAC
git add kubernetes/namespaces/ kubernetes/rbac/
git commit -m "🔐 Add production-ready namespaces and RBAC configuration

✨ Features:
- Production and staging namespace separation
- Developer RBAC with limited permissions
- Service account and role binding configuration
- Proper namespace labeling for management

🛡️ Security:
- Least privilege access for developers
- Environment-based namespace isolation
- Proper RBAC role definitions" || echo "Already committed"

# Commit 3: Enhanced validation and monitoring scripts
git add scripts/validate-platform.sh scripts/cost-monitor.sh
git commit -m "✅ Add comprehensive validation and cost monitoring tools

🔍 Validation Features:
- Colored output for better readability
- Complete cluster health checks
- Security policy validation
- Resource utilization monitoring
- GitOps sync status verification

💰 Cost Monitoring:
- Node type and usage tracking
- Spot instance utilization reporting
- Resource consumption analysis
- Cost optimization recommendations" || echo "Already committed"

# Commit 4: Project documentation and configuration
git add DEPLOYMENT-CHECKLIST.md LICENSE kubernetes/monitoring/dashboards/
git commit -m "📚 Add professional project documentation and monitoring

📋 Documentation:
- Complete deployment checklist for operations
- MIT license for open source compliance
- Monitoring dashboard configurations
- Troubleshooting command reference

📊 Monitoring:
- Cost monitoring dashboard configuration
- Resource utilization tracking
- Performance metrics visualization" || echo "Already committed"

# Commit 5: Enhanced gitignore and final cleanup
git add .gitignore commit-enhancements.sh
git commit -m "🔧 Final project cleanup and git configuration

✨ Improvements:
- Comprehensive .gitignore for all environments
- Enhanced development workflow support
- Backup and temporary file exclusions
- Cross-platform compatibility

🎯 Result:
Professional-grade Kubernetes platform ready for production deployment
and impressive for cloud engineering resume!" || echo "Already committed"

echo ""
echo "🎉 All enhancements committed successfully!"
echo ""
echo "📊 Project Statistics:"
echo "- $(find . -name "*.tf" | wc -l) Terraform files"
echo "- $(find kubernetes -name "*.yaml" -o -name "*.yml" | wc -l) Kubernetes manifests"
echo "- $(find scripts -name "*.sh" | wc -l) automation scripts"
echo "- $(find . -name "*.md" | wc -l) documentation files"
echo ""
echo "🚀 Ready to push to GitHub:"
echo "git push origin main"
echo ""
echo "💼 This project demonstrates:"
echo "• Infrastructure as Code expertise with Terraform"
echo "• Kubernetes administration and security"
echo "• GitOps and CI/CD pipeline implementation"
echo "• Cloud cost optimization strategies"
echo "• Production-ready monitoring and observability"
echo "• Enterprise security best practices"
echo ""
echo "Perfect for a cloud engineer resume! 🎯"
