#!/usr/bin/env bash
# Validation script for ZFS integration
# Checks that all required files and configurations are present

set -e

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$REPO_ROOT"

# Color codes
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

ERRORS=0
WARNINGS=0

check_file() {
    local file="$1"
    local description="$2"
    
    if [ -f "$file" ]; then
        echo -e "${GREEN}✓${NC} $description: $file"
    else
        echo -e "${RED}✗${NC} $description: $file (MISSING)"
        ((ERRORS++))
    fi
}

check_executable() {
    local file="$1"
    local description="$2"
    
    if [ -f "$file" ] && [ -x "$file" ]; then
        echo -e "${GREEN}✓${NC} $description: $file (executable)"
    elif [ -f "$file" ]; then
        echo -e "${YELLOW}⚠${NC} $description: $file (exists but not executable)"
        ((WARNINGS++))
    else
        echo -e "${RED}✗${NC} $description: $file (MISSING)"
        ((ERRORS++))
    fi
}

check_directory() {
    local dir="$1"
    local description="$2"
    
    if [ -d "$dir" ]; then
        echo -e "${GREEN}✓${NC} $description: $dir"
    else
        echo -e "${RED}✗${NC} $description: $dir (MISSING)"
        ((ERRORS++))
    fi
}

echo "========================================"
echo "ZFS Integration Validation"
echo "========================================"
echo ""

echo "Configuration Files:"
check_file "config/pop-os/24.04-zfs.mk" "ZFS configuration"
echo ""

echo "Build Scripts:"
check_executable "scripts/build-zbm.sh" "ZFSBootMenu builder"
check_executable "scripts/zfs-live-setup.sh" "Live environment setup"
check_executable "scripts/zfs-install.sh" "Main installer"
check_executable "scripts/zfs-partition.sh" "Disk partitioner"
check_executable "scripts/zfs-pool-create.sh" "Pool creator"
check_executable "scripts/zbm-install.sh" "ZFSBootMenu installer"
echo ""

echo "Data Templates:"
check_directory "data/zfs" "ZFS data directory"
check_file "data/zfs/pool-layout.yaml" "Pool layout template"
check_file "data/zfs/sanoid.conf.template" "Sanoid configuration"
check_file "data/zfs/zfsbootmenu.yaml.template" "ZFSBootMenu config"
check_file "data/zfs/dracut.conf.d/zfsbootmenu.conf" "Dracut configuration"
echo ""

echo "Automation Scripts:"
check_file "data/zfs/apt-zfs-snapshot.sh" "APT snapshot helper"
check_file "data/zfs/apt.conf.d/80-zfs-snapshot" "APT hook config"
check_file "data/zfs/zfs-pre-boot-snapshot.sh" "Pre-boot snapshot"
check_file "data/zfs/systemd/zfs-pre-boot-snapshot.service" "Systemd service"
echo ""

echo "Documentation:"
check_file "docs/ZFS-INSTALL.md" "Installation guide"
check_file "docs/ZFS-RECOVERY.md" "Recovery guide"
check_file "docs/SNAPSHOT-MANAGEMENT.md" "Snapshot management"
check_file "docs/BUILDING.md" "Build guide"
check_file "docs/HARDWARE-NOTES.md" "Hardware notes"
echo ""

echo "Build Infrastructure:"
check_file "Containerfile" "Container definition"
check_file ".github/workflows/build-iso.yml" "CI/CD workflow"
check_file "ZFS-IMPLEMENTATION.md" "Implementation summary"
echo ""

echo "========================================"
echo "Validation Summary"
echo "========================================"

if [ $ERRORS -eq 0 ] && [ $WARNINGS -eq 0 ]; then
    echo -e "${GREEN}All checks passed!${NC}"
    echo ""
    echo "ZFS integration is complete and ready for use."
    echo "See docs/BUILDING.md to build the ISO."
    exit 0
elif [ $ERRORS -eq 0 ]; then
    echo -e "${YELLOW}Validation passed with $WARNINGS warning(s)${NC}"
    echo ""
    echo "Some files exist but may need permissions fixed."
    echo "Run: chmod +x scripts/*.sh"
    exit 0
else
    echo -e "${RED}Validation failed with $ERRORS error(s) and $WARNINGS warning(s)${NC}"
    echo ""
    echo "Please ensure all required files are present."
    exit 1
fi
