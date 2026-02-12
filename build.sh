#!/bin/bash
#
# build.sh - Build Markdown Viewer from command line
#
# Usage:
#   ./build.sh [--release|--debug] [--clean] [--dev-account]
#
# Options:
#   --release, -r     Build in Release configuration (default)
#   --debug, -d       Build in Debug configuration
#   --clean, -c       Clean before building
#   --dev-account     Sign with Apple developer account (requires Xcode sign-in)
#   --help, -h        Show this help message
#

set -euo pipefail

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Default values
CONFIGURATION="Release"
CLEAN=false
DEV_ACCOUNT=false
PROJECT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BUILD_DIR="${PROJECT_DIR}/build"
XCODE_PROJECT="${PROJECT_DIR}/MarkdownViewer/MarkdownViewer.xcodeproj"
SCHEME="MarkdownViewer"
APP_NAME="Markdown Viewer.app"

# Parse arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        -r|--release)
            CONFIGURATION="Release"
            shift
            ;;
        -d|--debug)
            CONFIGURATION="Debug"
            shift
            ;;
        -c|--clean)
            CLEAN=true
            shift
            ;;
        --dev-account)
            DEV_ACCOUNT=true
            shift
            ;;
        -h|--help)
            echo "Usage: $0 [--release|--debug] [--clean] [--dev-account]"
            echo ""
            echo "Build Markdown Viewer from the command line."
            echo ""
            echo "Options:"
            echo "  --release, -r     Build in Release configuration (default)"
            echo "  --debug, -d       Build in Debug configuration"
            echo "  --clean, -c       Clean before building"
            echo "  --dev-account     Sign with Apple developer account (requires Xcode sign-in)"
            echo "  --help, -h        Show this help message"
            echo ""
            echo "Output:"
            echo "  Build artifacts will be placed in: ${BUILD_DIR}/"
            echo "  Application will be: ${BUILD_DIR}/${APP_NAME}"
            exit 0
            ;;
        *)
            echo -e "${RED}Error: Unknown option: $1${NC}" >&2
            echo "Run '$0 --help' for usage information" >&2
            exit 1
            ;;
    esac
done

# Determine signing settings
if [[ "${DEV_ACCOUNT}" == true ]]; then
    SIGN_ARGS=()
    SIGNING_LABEL="Apple developer account (automatic)"
else
    SIGN_ARGS=(
        CODE_SIGN_STYLE=Manual
        CODE_SIGN_IDENTITY="-"
        DEVELOPMENT_TEAM=""
    )
    SIGNING_LABEL="Ad-hoc (no developer account required)"
fi

# Print build info
echo -e "${BLUE}╔════════════════════════════════════════════════════════╗${NC}"
echo -e "${BLUE}║${NC}  Markdown Viewer Build Script                        ${BLUE}║${NC}"
echo -e "${BLUE}╚════════════════════════════════════════════════════════╝${NC}"
echo ""
echo -e "${YELLOW}Configuration:${NC} ${CONFIGURATION}"
echo -e "${YELLOW}Signing:${NC}       ${SIGNING_LABEL}"
echo -e "${YELLOW}Clean build:${NC}   ${CLEAN}"
echo -e "${YELLOW}Output dir:${NC}    ${BUILD_DIR}"
echo ""

# Verify Xcode project exists
if [[ ! -d "${XCODE_PROJECT}" ]]; then
    echo -e "${RED}Error: Xcode project not found at ${XCODE_PROJECT}${NC}" >&2
    exit 1
fi

# Create build directory
mkdir -p "${BUILD_DIR}"

# Clean if requested
if [[ "${CLEAN}" == true ]]; then
    echo -e "${YELLOW}→ Cleaning build artifacts...${NC}"
    rm -rf "${BUILD_DIR:?}"/*
    xcodebuild clean \
        -project "${XCODE_PROJECT}" \
        -scheme "${SCHEME}" \
        -configuration "${CONFIGURATION}" \
        > /dev/null 2>&1 || true
    echo -e "${GREEN}✓ Clean complete${NC}"
    echo ""
fi

# Build the project
echo -e "${YELLOW}→ Building ${SCHEME} (${CONFIGURATION})...${NC}"
echo ""

BUILD_OUTPUT=$(mktemp)
trap 'rm -f ${BUILD_OUTPUT}' EXIT

if xcodebuild build \
    -project "${XCODE_PROJECT}" \
    -scheme "${SCHEME}" \
    -configuration "${CONFIGURATION}" \
    -derivedDataPath "${BUILD_DIR}/DerivedData" \
    CONFIGURATION_BUILD_DIR="${BUILD_DIR}" \
    "${SIGN_ARGS[@]}" \
    > "${BUILD_OUTPUT}" 2>&1; then

    echo -e "${GREEN}✓ Build succeeded${NC}"
    echo ""

    # Verify app was created
    if [[ -d "${BUILD_DIR}/${APP_NAME}" ]]; then
        APP_SIZE=$(du -sh "${BUILD_DIR}/${APP_NAME}" | cut -f1)
        echo -e "${GREEN}╔════════════════════════════════════════════════════════╗${NC}"
        echo -e "${GREEN}║${NC}  Build Complete!                                      ${GREEN}║${NC}"
        echo -e "${GREEN}╚════════════════════════════════════════════════════════╝${NC}"
        echo ""
        echo -e "${YELLOW}Application:${NC} ${BUILD_DIR}/${APP_NAME}"
        echo -e "${YELLOW}Size:${NC}        ${APP_SIZE}"
        echo ""
        echo -e "${BLUE}To run the app:${NC}"
        echo -e "  open \"${BUILD_DIR}/${APP_NAME}\""
        echo ""
        exit 0
    else
        echo -e "${RED}Error: Build succeeded but app not found at expected location${NC}" >&2
        echo "Expected: ${BUILD_DIR}/${APP_NAME}" >&2
        exit 1
    fi
else
    echo -e "${RED}✗ Build failed${NC}" >&2
    echo "" >&2
    echo -e "${RED}Build errors:${NC}" >&2
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" >&2
    tail -50 "${BUILD_OUTPUT}" >&2
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" >&2
    echo "" >&2
    echo -e "${YELLOW}For full build output, see: ${BUILD_OUTPUT}${NC}" >&2
    exit 1
fi
