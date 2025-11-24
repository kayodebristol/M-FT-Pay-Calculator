# Svelte 5 + Tauri 2 Cross-Platform Template

An extensible template for bootstrapping cross-platform applications using **Svelte 5** and **Tauri 2**.

## 🎯 Purpose

This template provides a foundation for creating cross-platform applications with:
- **Svelte 5** - Modern reactive UI framework
- **Tauri 2** - Cross-platform desktop and mobile framework
- **Extensible Plugin System** - Add features via plugins
- **CI/CD Ready** - GitHub Actions workflows included
- **Code Quality** - ADP integration for architectural discipline

## 🚀 Quick Start

### Create a New Project

```bash
npm run template:create my-new-app
```

Follow the interactive prompts to configure your project.

### Start Development

```bash
cd my-new-app
npm install
npm run dev
```

## 📦 Features

- **Cross-Platform**: Desktop (Windows, macOS, Linux), Android, and iOS
- **Modern Stack**: Svelte 5 + Tauri 2
- **Extensible**: Plugin system for adding features
- **CI/CD Ready**: GitHub Actions workflows included
- **Code Quality**: ADP integration for architectural discipline
- **Auto-Updates**: Built-in update system
- **Multi-Platform Builds**: Automated package generation

## 🔌 Plugin System

### Available Plugins

- **adp** (Required): Architectural Discipline Package
- **state-docs** (Planned): State documentation generation
- **pluresdb** (Planned): Database integration
- **unum** (Planned): Numeric computation library
- **fsm** (Planned): Finite State Machine library

### List Plugins

```bash
npm run plugin:list
```

### Add Plugin

```bash
npm run plugin:add <plugin-name>
```

## 📚 Documentation

- [TEMPLATE_ARCHITECTURE.md](./TEMPLATE_ARCHITECTURE.md) - Architecture overview
- [TEMPLATE_USAGE.md](./TEMPLATE_USAGE.md) - Usage guide
- [TAURI_SETUP.md](./TAURI_SETUP.md) - Tauri setup
- [DISTRIBUTION.md](./DISTRIBUTION.md) - Distribution guide

## 🏗️ Structure

```
├── template/           # Template files with placeholders
├── cli/               # Bootstrap CLI tools
├── plugins/           # Extensible plugin system
└── docs/              # Documentation
```

## 🔮 Future Integrations

This template is designed to integrate with:

- ✅ **plures/ADP** - Architectural Discipline Package (integrated)
- 🔜 **plures/State-docs** - State documentation
- 🔜 **plures/pluresdb** - Database system
- 🔜 **plures/unum** - Numeric computation
- 🔜 **plures/fsm** - Finite State Machine (to be created)

## 📄 License

MIT
