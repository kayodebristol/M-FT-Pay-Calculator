# Build Optimization Changes

## Problem
The GitHub Actions workflows were experiencing long-running builds due to extensive file downloads, causing builds to hang and potentially time out.

## Solution
Implemented comprehensive caching strategies across all build workflows to reduce download times and prevent indefinite hangs.

## Changes Made

### 1. Desktop Build Workflow (`desktop-build.yml`)

#### Windows Build
- Added `timeout-minutes: 60` to prevent indefinite hangs
- Added Rust cargo caching:
  - Caches: `~/.cargo/bin/`, `~/.cargo/registry/`, `~/.cargo/git/db/`, `src-tauri/target/`
  - Cache key based on `Cargo.lock` hash
  - Restores from `{OS}-cargo-` prefix on cache miss

#### macOS Build
- Added `timeout-minutes: 60`
- Added Rust cargo caching (same as Windows)
- Added Xcode derived data caching:
  - Caches: `~/Library/Developer/Xcode/DerivedData`
  - Speeds up incremental builds

#### Linux Build
- Added `timeout-minutes: 60`
- Added Rust cargo caching (same as Windows)
- Added APT package caching using `cache-apt-pkgs-action`:
  - Caches system dependencies: `libwebkit2gtk-4.1-dev`, `libssl-dev`, `libayatana-appindicator3-dev`, `librsvg2-dev`
  - Eliminates repeated `apt-get install` downloads

### 2. iOS Build Workflow (`ios-build.yml`)
- Added `timeout-minutes: 90` (iOS builds typically take longer)
- Added Rust cargo caching with iOS-specific cache key
- Added CocoaPods caching:
  - Caches: `~/Library/Caches/CocoaPods`, `src-tauri/ios/Pods`
  - Cache key based on `Podfile.lock` hash
  - Avoids re-downloading iOS dependencies
- Added Xcode derived data caching for faster incremental builds

### 3. Android Build Workflow (`android-build.yml`)
- Added `timeout-minutes: 60`
- Added Rust cargo caching with Android-specific cache key
- Added Gradle caching:
  - Enabled `cache: 'gradle'` in Java setup action
  - Manual Gradle cache for: `~/.gradle/caches`, `~/.gradle/wrapper`, `src-tauri/android/.gradle`
  - Cache key based on Gradle files hash
  - Prevents re-downloading Android SDK components and dependencies

### 4. Release Workflow (`release.yml`)
- Added `timeout-minutes: 90` to the build-and-release job
- Added platform-specific caching:
  - **All platforms**: Rust cargo caching with platform-specific keys
  - **Android**: Gradle caching (same as android-build.yml)
  - **iOS**: CocoaPods caching and Xcode derived data caching
  - **macOS**: Xcode derived data caching
  - **Linux**: APT package caching for system dependencies

## Expected Benefits

### Time Savings per Build
| Component | Estimated Savings | Impact |
|-----------|------------------|---------|
| Rust cargo compilation | 10-30+ minutes | ⭐⭐⭐⭐⭐ HIGH |
| Android Gradle dependencies | 5-15 minutes | ⭐⭐⭐⭐ HIGH |
| iOS CocoaPods dependencies | 5-20 minutes | ⭐⭐⭐⭐ HIGH |
| Linux APT packages | 1-3 minutes | ⭐⭐ MEDIUM |
| Xcode derived data | 2-10 minutes | ⭐⭐⭐ MEDIUM-HIGH |
| **Total potential savings** | **20-70+ minutes** per full build | |

### Additional Benefits
1. **Reliability**: Timeout protection prevents workflows from hanging indefinitely
2. **Cost**: Reduced GitHub Actions minutes usage
3. **Developer Experience**: Faster feedback loops on CI/CD
4. **Consistency**: Cache keys based on lock files ensure cache invalidation when dependencies change

## Cache Strategy

### Cache Keys
All caches use content-based keys (hashing lock files) to ensure:
- Automatic cache invalidation when dependencies change
- Proper cache restoration across workflow runs
- Platform-specific isolation to prevent conflicts

### Cache Hierarchy
1. **Exact match**: `{OS}-{platform}-{component}-{hash}`
2. **Prefix match**: `{OS}-{platform}-{component}-`
3. **Full rebuild**: When no cache is found

### Cache Locations
- **Rust**: Global cargo directories + project target directory
- **Node.js**: Managed by `setup-node` action with `cache: 'npm'`
- **Gradle**: Gradle wrapper, caches, and project-specific `.gradle` directories
- **CocoaPods**: Global CocoaPods cache + project Pods directory
- **Xcode**: Derived data directory for incremental builds
- **APT**: Cached using specialized action for system packages

## Testing Recommendations

1. Monitor first workflow run after this change (will populate caches)
2. Compare second+ workflow runs to see time improvements
3. Check GitHub Actions cache usage in repository settings
4. Verify builds complete within timeout windows

## Maintenance

### Cache Invalidation
Caches automatically invalidate when:
- `Cargo.lock` changes (Rust dependencies)
- `package-lock.json` changes (Node.js dependencies)
- `Podfile.lock` changes (iOS dependencies)
- `*.gradle*` or `gradle-wrapper.properties` change (Android dependencies)

### Manual Cache Clearing
If needed, caches can be cleared from: Repository Settings → Actions → Caches

## References
- [GitHub Actions Caching Documentation](https://docs.github.com/en/actions/using-workflows/caching-dependencies-to-speed-up-workflows)
- [actions/cache](https://github.com/actions/cache)
- [awalsh128/cache-apt-pkgs-action](https://github.com/awalsh128/cache-apt-pkgs-action)
