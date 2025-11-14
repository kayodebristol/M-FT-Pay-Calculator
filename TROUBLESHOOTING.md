# Troubleshooting Guide

Common issues and solutions for the Microsoft Pay Calculator project.

## 🔧 Build Issues

### Vite Cache Lock Error (EBUSY)

**Error:**
```
Error: EBUSY: resource busy or locked, rename 'node_modules\.vite\deps_temp_*' -> 'node_modules\.vite\deps'
```

**Solution:**
1. Stop all running dev servers (`Ctrl+C`)
2. Clear Vite cache:
   ```powershell
   npm run clean:vite
   # Or manually:
   Remove-Item -Path node_modules\.vite -Recurse -Force
   ```
3. Restart the dev server:
   ```powershell
   npm run dev
   ```

**Prevention:**
- Always stop dev servers before running builds
- Close file explorers that might be accessing `node_modules`
- Disable antivirus real-time scanning for the project folder (if safe)

### Tauri API Import Errors

**Error:**
```
Rollup failed to resolve import "@tauri-apps/api/process"
```

**Solution:**
- Tauri APIs are externalized in `vite.config.ts` - this is correct
- Ensure you're using dynamic imports for Tauri APIs:
  ```typescript
  const { relaunch } = await import('@tauri-apps/api/process');
  ```

### Svelte 5 Reactivity Warnings

**Error:**
```
`updateInfo` is updated, but is not declared with `$state(...)`
```

**Solution:**
- Use `$state()` for reactive variables in Svelte 5:
  ```typescript
  let updateInfo = $state<any>(null); // ✅ Correct
  let updateInfo: any = null; // ❌ Wrong
  ```

## 🌐 Network Issues

### Favicon 404 Error

**Error:**
```
[404] GET /favicon.ico
```

**Solution:**
- Favicon is already configured in `src/routes/+layout.svelte`
- A `favicon.svg` is available in `static/` folder
- The 404 is harmless - browsers automatically request `/favicon.ico` even when SVG is set
- To suppress: Add `favicon.ico` to `static/` folder (optional)

## 🚀 Development Issues

### Port Already in Use

**Error:**
```
Port 5173 is already in use
```

**Solution:**
```powershell
# Find process using port
netstat -ano | findstr :5173

# Kill process (replace PID with actual process ID)
taskkill /PID <PID> /F

# Or use a different port
$env:TAURI_DEV_PORT=5174; npm run tauri:dev
```

### Node Modules Issues

**Error:**
```
Module not found or dependency errors
```

**Solution:**
```powershell
# Clean install
Remove-Item -Path node_modules -Recurse -Force
Remove-Item -Path package-lock.json -Force
npm install
```

## 🔐 Secret Management Issues

### GitHub CLI Not Found

**Error:**
```
gh: command not found
```

**Solution:**
```powershell
# Install GitHub CLI
winget install GitHub.cli

# Or download from: https://cli.github.com/
```

### Authentication Required

**Error:**
```
Authentication required
```

**Solution:**
```powershell
gh auth login
# Follow the prompts
```

## 📦 Build & Release Issues

### Windows Build Fails

**Common causes:**
1. **Missing Rust toolchain:**
   ```powershell
   # Install Rust
   winget install Rustlang.Rustup
   ```

2. **Missing Windows SDK:**
   - Install Visual Studio Build Tools with C++ workload
   - Or install Visual Studio Community

3. **Path issues with special characters:**
   - Project path contains `$` (e.g., `M$FT-Pay-Calculator`)
   - Some tools may have issues - consider renaming folder

### Signing Errors

**Error:**
```
Certificate not found or invalid
```

**Solution:**
- Verify certificate path is correct
- Check certificate is base64 encoded correctly
- Ensure password is set correctly in GitHub secrets
- Use `scripts/setup-secrets.ps1` to set up secrets properly

## 🐛 Runtime Issues

### App Won't Start

**Check:**
1. Build completed successfully: `npm run build`
2. Tauri backend compiled: Check `src-tauri/target/`
3. Frontend built: Check `build/` directory exists
4. Logs: Check console for errors

### Auto-Update Not Working

**Check:**
1. Updater plugin enabled in `tauri.conf.json`
2. Public key set in `tauri.conf.json`
3. Endpoint URL is correct (GitHub Gist)
4. Settings store permissions granted
5. Network connectivity

## 🔍 Debugging Tips

### Enable Debug Logging

```typescript
// In your code
console.log('Debug info:', data);

// In Tauri (Rust)
log::info!("Debug message");
```

### Check Tauri Logs

```powershell
# Development
npm run tauri:dev
# Logs appear in terminal

# Production
# Check system logs or use Tauri's log plugin
```

### Inspect Network Requests

1. Open DevTools (`F12` or `Ctrl+Shift+I`)
2. Go to Network tab
3. Check for failed requests
4. Verify CORS and CSP settings

## 📚 Additional Resources

- [Tauri Troubleshooting](https://v2.tauri.app/guides/debugging/)
- [SvelteKit Documentation](https://kit.svelte.dev/docs)
- [Vite Troubleshooting](https://vitejs.dev/guide/troubleshooting.html)
- [GitHub CLI Documentation](https://cli.github.com/manual/)

## 🆘 Still Having Issues?

1. Check the error message carefully
2. Search for the error in the documentation
3. Check GitHub Issues for similar problems
4. Clear caches and rebuild
5. Check system requirements are met

