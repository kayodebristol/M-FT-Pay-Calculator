# Microsoft Pay Calculator

A cross-platform pay calculator application built with Svelte 5 and Tauri 2, supporting Desktop (Windows, macOS, Linux), Android, and iOS.

## 🚀 Features

- Calculate Microsoft employee compensation packages
- Support for base salary, bonuses, stock options, and more
- Modern, responsive UI built with Svelte 5
- Cross-platform: Desktop (Windows 7+, macOS 10.15+, Linux), Android 8+, and iOS 9+
- Built with Tauri 2 for native performance

## 📱 Build & Deploy iOS Apps Without a Mac!

This project uses **GitHub Actions** to build iOS apps and **automatically deploy to TestFlight** without needing a Mac! See [CI_CD_SETUP.md](./CI_CD_SETUP.md) and [TESTFLIGHT_SETUP.md](./TESTFLIGHT_SETUP.md) for details.

### Quick Start for iOS Builds:

1. Push your code to GitHub
2. Go to **Actions** tab
3. Select **Build iOS App** workflow
4. Click **Run workflow**
5. Download the `.ipa` file from artifacts

**It's completely free for public repositories!** 🎉

## 🛠️ Development

### Prerequisites

- **Node.js** 20+ and npm
- **Rust** (install via [rustup.rs](https://rustup.rs/))
- **Platform-specific tools** (see [TAURI_SETUP.md](./TAURI_SETUP.md))

### Local Development

```bash
# Install dependencies
npm install

# Run development server
npm run dev

# Run with Tauri (Desktop)
npm run tauri:dev

# Build for production
npm run build
npm run tauri:build
```

### Mobile Development

See [MOBILE_SETUP.md](./MOBILE_SETUP.md) for detailed mobile setup instructions.

**Android:**
```bash
npm run tauri:android:dev    # Development
npm run tauri:android:build  # Release
```

**iOS (requires macOS):**
```bash
npm run tauri:ios:dev    # Development
npm run tauri:ios:build  # Release
```

**Or use GitHub Actions** (no Mac needed for iOS!):
- See [CI_CD_SETUP.md](./CI_CD_SETUP.md)

## 🏛️ Architectural Discipline

This project uses the **Architectural Discipline Package (ADP)** to maintain high code quality and architectural standards.

### Quick Commands

```bash
# Analyze codebase architecture
npm run adp:analyze

# Get refactoring recommendations
npm run adp:recommend

# Check architecture (JSON format)
npm run adp:check
```

ADP automatically analyzes:
- **TypeScript/JavaScript** files (`.ts`, `.tsx`, `.js`, `.jsx`)
- **Rust** files (`.rs`) in `src-tauri/`
- Code complexity, maintainability, and architectural patterns

See `.adp-config.json` for configuration.

## 📚 Documentation

- [TAURI_SETUP.md](./TAURI_SETUP.md) - Tauri setup and configuration
- [DISTRIBUTION.md](./DISTRIBUTION.md) - **Complete distribution guide** 📦
- [MOBILE_SETUP.md](./MOBILE_SETUP.md) - Mobile development setup
- [CI_CD_SETUP.md](./CI_CD_SETUP.md) - CI/CD and building without a Mac
- [TESTFLIGHT_SETUP.md](./TESTFLIGHT_SETUP.md) - **TestFlight deployment guide** 🚀

## 🏗️ Project Structure

```
├── src/                    # SvelteKit frontend
│   ├── routes/            # App routes
│   └── lib/               # Shared components
├── src-tauri/             # Tauri backend (Rust)
│   ├── src/               # Rust source code
│   ├── android/           # Android project (after init)
│   ├── ios/               # iOS project (after init)
│   └── tauri.conf.json    # Tauri configuration
├── .github/workflows/     # GitHub Actions workflows
└── build/                 # Frontend build output
```

## 🎯 Build Targets & Distribution

### Desktop
- **Windows 7+**: MSI installer (Microsoft Store support available)
- **macOS 10.15+**: App bundle, DMG (App Store support available)
- **Linux** (webkit2gtk 4.1, e.g., Ubuntu 22.04+): DEB, AppImage, RPM

### Mobile
- **Android 8+**: APK, AAB (Google Play ready)
- **iOS/iPadOS 9+**: IPA (App Store ready, via GitHub Actions - no Mac needed!)

See [DISTRIBUTION.md](./DISTRIBUTION.md) for complete distribution guide.

## 📦 Scripts

```bash
# Development
npm run dev                 # Frontend dev server
npm run tauri:dev          # Tauri desktop dev
npm run tauri:android:dev   # Android dev
npm run tauri:ios:dev       # iOS dev (macOS only)

# Build
npm run build               # Build frontend
npm run tauri:build         # Build desktop
npm run tauri:android:build # Build Android
npm run tauri:ios:build     # Build iOS (macOS only)

# Platform-specific builds
npm run tauri:build:windows
npm run tauri:build:macos
npm run tauri:build:linux
```

## 🔧 Configuration

- **Tauri**: `src-tauri/tauri.conf.json`
- **SvelteKit**: `svelte.config.js`
- **Vite**: `vite.config.ts`
- **TypeScript**: `tsconfig.json`

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Push to GitHub
5. Create a Pull Request

## 📄 License

[Add your license here]

## 🙏 Acknowledgments

- Built with [Tauri](https://tauri.app/)
- Frontend powered by [Svelte](https://svelte.dev/) and [SvelteKit](https://kit.svelte.dev/)
- CI/CD powered by [GitHub Actions](https://github.com/features/actions)

---

**Note**: iOS builds require either macOS locally or GitHub Actions (free for public repos). See [CI_CD_SETUP.md](./CI_CD_SETUP.md) for building iOS apps without a Mac.
