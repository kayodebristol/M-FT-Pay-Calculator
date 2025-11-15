<script lang="ts">
	import { settings } from '$lib/stores/settings';
	import { onMount, onDestroy } from 'svelte';

	let autoUpdate = $state(false);
	let updateAvailable = $state(false);
	let updateInfo = $state<any>(null);
	let checkingUpdate = $state(false);
	let checkError = $state<string | null>(null);
	let checkSuccess = $state(false);
	let appVersion = $state('');

	// Subscribe to settings store to keep values in sync
	let unsubscribe: (() => void) | null = null;

	onMount(async () => {
		// Ensure settings are loaded
		await settings.load();
		
		// Load settings and subscribe to changes
		unsubscribe = settings.subscribe((s) => {
			autoUpdate = s.autoUpdate;
		});

		// Get app version (only in Tauri)
		if (typeof window !== 'undefined' && '__TAURI_INTERNALS__' in window) {
			try {
				const appModule = await import('@tauri-apps/api/app');
				appVersion = await appModule.getVersion();
			} catch (error) {
				console.error('Failed to get app version:', error);
			}
		} else {
			// Fallback for browser/dev mode
			appVersion = '0.1.0 (dev)';
		}

		// Check for updates on mount if auto-update is enabled
		if (autoUpdate) {
			checkForUpdate();
		}
	});

	// Cleanup subscription on unmount
	onDestroy(() => {
		if (unsubscribe) {
			unsubscribe();
		}
	});

	async function toggleAutoUpdate() {
		autoUpdate = !autoUpdate;
		await settings.update((s) => ({
			...s,
			autoUpdate,
		}));

		// If enabling auto-update, check for updates immediately
		if (autoUpdate) {
			checkForUpdate();
		}
	}

	async function checkForUpdate() {
		// Only check for updates in Tauri environment
		if (typeof window === 'undefined' || !('__TAURI_INTERNALS__' in window)) {
			checkError = 'Update check only available in Tauri app';
			checkingUpdate = false;
			checkSuccess = false;
			return;
		}

		try {
			checkingUpdate = true;
			checkError = null;
			checkSuccess = false;
			updateAvailable = false;
			updateInfo = null;

			const { check } = await import('@tauri-apps/plugin-updater');
			const updater = await check();
			
			if (updater) {
				updateAvailable = true;
				updateInfo = {
					version: updater.version,
					body: updater.body || 'Update available',
				};
				checkSuccess = true;
				checkError = null;
			} else {
				checkSuccess = true;
				checkError = null;
				updateAvailable = false;
				updateInfo = null;
			}
		} catch (error) {
			console.error('Failed to check for updates:', error);
			checkError = error instanceof Error ? error.message : 'Failed to check for updates';
			checkSuccess = false;
			updateAvailable = false;
			updateInfo = null;
		} finally {
			checkingUpdate = false;
		}
	}

	async function installUpdate() {
		// Only install updates in Tauri environment
		if (typeof window === 'undefined' || !('__TAURI_INTERNALS__' in window)) {
			console.warn('Update installation only available in Tauri app');
			return;
		}

		try {
			const { check } = await import('@tauri-apps/plugin-updater');
			const updater = await check();
			if (updater) {
				await updater.downloadAndInstall();
				// Restart app after installation
				// Use dynamic import with variable to prevent Vite from analyzing it
				try {
					// Use variable to make import truly dynamic (prevents Vite analysis)
					const processPath = '@tauri-apps/api/process';
					const processModule = await import(processPath);
					await processModule.relaunch();
				} catch (importError) {
					// Fallback if process API is not available
					console.warn('Could not relaunch app automatically. Please restart manually.');
					console.error('Import error:', importError);
				}
			}
		} catch (error) {
			console.error('Failed to install update:', error);
		}
	}
</script>

<div class="settings-container">
	<header class="settings-header">
		<h1>Settings</h1>
	</header>

	<section class="settings-section">
		<h2 class="section-title">Application</h2>

		<div class="setting-item">
			<div class="setting-info">
				<label for="auto-update" class="setting-label">Auto Update</label>
				<p class="setting-description">
					Automatically check for and install updates when available
				</p>
			</div>
			<label class="toggle-switch">
				<input
					id="auto-update"
					type="checkbox"
					checked={autoUpdate}
					onchange={toggleAutoUpdate}
				/>
				<span class="toggle-slider"></span>
			</label>
		</div>

		<div class="setting-item">
			<div class="setting-info">
				<div class="setting-label">Version</div>
				<p class="setting-description">Current application version</p>
			</div>
			<div class="setting-value">{appVersion}</div>
		</div>

		<div class="setting-item setting-item-compact">
			<div class="setting-info">
				<div class="setting-label">Check for Updates</div>
				<p class="setting-description">Manually check for available updates</p>
			</div>
			<button
				class="btn-check-update btn-compact"
				onclick={checkForUpdate}
				disabled={checkingUpdate}
			>
				{#if checkingUpdate}
					<span class="spinner spinner-small"></span>
					Checking...
				{:else}
					Check Now
				{/if}
			</button>
		</div>

		{#if checkError}
			<div class="update-status error">
				<svg width="12" height="12" viewBox="0 0 20 20" fill="currentColor">
					<path fill-rule="evenodd" d="M10 18a8 8 0 100-16 8 8 0 000 16zM8.707 7.293a1 1 0 00-1.414 1.414L8.586 10l-1.293 1.293a1 1 0 101.414 1.414L10 11.414l1.293 1.293a1 1 0 001.414-1.414L11.414 10l1.293-1.293a1 1 0 00-1.414-1.414L10 8.586 8.707 7.293z" clip-rule="evenodd" />
				</svg>
				<span>{checkError}</span>
			</div>
		{/if}

		{#if checkSuccess && !updateAvailable && !checkingUpdate}
			<div class="update-status success">
				<svg width="12" height="12" viewBox="0 0 20 20" fill="currentColor">
					<path fill-rule="evenodd" d="M10 18a8 8 0 100-16 8 8 0 000 16zm3.707-9.293a1 1 0 00-1.414-1.414L9 10.586 7.707 9.293a1 1 0 00-1.414 1.414l2 2a1 1 0 001.414 0l4-4z" clip-rule="evenodd" />
				</svg>
				<span>You're up to date! No updates available.</span>
			</div>
		{/if}

		{#if updateAvailable && updateInfo}
			<div class="update-notification">
				<div class="update-info">
					<h3>Update Available</h3>
					<p>Version {updateInfo.version} is available</p>
					{#if updateInfo.body}
						<div class="update-notes">{updateInfo.body}</div>
					{/if}
				</div>
				<button class="btn-install-update" onclick={installUpdate}>
					Install Update
				</button>
			</div>
		{/if}
	</section>
</div>

<style>
	.settings-container {
		max-width: 800px;
		margin: 0 auto;
		padding: 1rem;
	}

	.settings-header {
		margin-bottom: 1rem;
		border-bottom: 2px solid #e0e0e0;
		padding-bottom: 0.75rem;
	}

	.settings-header h1 {
		margin: 0;
		font-size: 1.5rem;
		color: #333;
	}

	.settings-section {
		margin-bottom: 1rem;
	}

	.section-title {
		font-size: 1.125rem;
		margin-bottom: 0.75rem;
		color: #333;
	}

	.setting-item {
		display: flex;
		justify-content: space-between;
		align-items: center;
		padding: 0.75rem;
		margin-bottom: 0.5rem;
		background: #f9f9f9;
		border-radius: 6px;
		border: 1px solid #e0e0e0;
	}

	.setting-info {
		flex: 1;
		margin-right: 0.75rem;
	}

	.setting-label {
		display: block;
		font-weight: 600;
		margin-bottom: 0.25rem;
		color: #333;
		font-size: 0.9rem;
	}

	.setting-description {
		margin: 0;
		color: #666;
		font-size: 0.8rem;
	}

	.setting-value {
		font-weight: 600;
		color: #333;
		font-size: 0.9rem;
	}

	/* Toggle Switch */
	.toggle-switch {
		position: relative;
		display: inline-block;
		width: 25px;
		height: 14px;
	}

	.toggle-switch input {
		opacity: 0;
		width: 0;
		height: 0;
	}

	.toggle-slider {
		position: absolute;
		cursor: pointer;
		top: 0;
		left: 0;
		right: 0;
		bottom: 0;
		background-color: #ccc;
		transition: 0.4s;
		border-radius: 14px;
	}

	.toggle-slider:before {
		position: absolute;
		content: '';
		height: 11px;
		width: 11px;
		left: 1.5px;
		bottom: 1.5px;
		background-color: white;
		transition: 0.4s;
		border-radius: 50%;
	}

	input:checked + .toggle-slider {
		background-color: #0078d4;
	}

	input:checked + .toggle-slider:before {
		transform: translateX(11px);
	}

	input:disabled + .toggle-slider {
		opacity: 0.5;
		cursor: not-allowed;
	}

	/* Buttons */
	.btn-check-update,
	.btn-install-update {
		padding: 0.5rem 1rem;
		background-color: #0078d4;
		color: white;
		border: none;
		border-radius: 4px;
		font-size: 0.85rem;
		font-weight: 600;
		cursor: pointer;
		transition: background-color 0.2s;
	}

	.btn-compact {
		padding: 0.25rem 0.5rem;
		font-size: 0.7rem;
	}

	.setting-item-compact {
		padding: 0.5rem;
		margin-bottom: 0.375rem;
	}

	.btn-check-update:hover:not(:disabled),
	.btn-install-update:hover {
		background-color: #106ebe;
	}

	.btn-check-update:disabled {
		opacity: 0.6;
		cursor: not-allowed;
	}

	.btn-check-update {
		display: flex;
		align-items: center;
		gap: 0.5rem;
	}

	/* Loading Spinner */
	.spinner {
		width: 16px;
		height: 16px;
		border: 2px solid rgba(255, 255, 255, 0.3);
		border-top-color: white;
		border-radius: 50%;
		animation: spin 0.8s linear infinite;
	}

	.spinner-small {
		width: 12px;
		height: 12px;
		border-width: 1.5px;
	}

	@keyframes spin {
		to {
			transform: rotate(360deg);
		}
	}

	/* Update Status Messages */
	.update-status {
		margin-top: 0.25rem;
		padding: 0.25rem;
		border-radius: 3px;
		display: flex;
		align-items: center;
		gap: 0.375rem;
		font-size: 0.7rem;
	}

	.update-status.error {
		background: #ffebee;
		border: 1px solid #ef5350;
		color: #c62828;
	}

	.update-status.success {
		background: #e8f5e9;
		border: 1px solid #66bb6a;
		color: #2e7d32;
	}

	.update-status svg {
		flex-shrink: 0;
		width: 12px;
		height: 12px;
	}

	/* Update Notification */
	.update-notification {
		margin-top: 0.5rem;
		padding: 0.375rem;
		background: #e3f2fd;
		border: 1.5px solid #2196f3;
		border-radius: 4px;
		display: flex;
		justify-content: space-between;
		align-items: flex-start;
		gap: 0.5rem;
	}

	.update-info h3 {
		margin: 0 0 0.125rem 0;
		color: #1976d2;
		font-size: 0.85rem;
	}

	.update-info p {
		margin: 0 0 0.125rem 0;
		color: #333;
		font-size: 0.75rem;
	}

	.update-notes {
		margin-top: 0.125rem;
		padding: 0.375rem;
		background: white;
		border-radius: 3px;
		font-size: 0.7rem;
		color: #555;
		white-space: pre-wrap;
	}

	.btn-install-update {
		flex-shrink: 0;
		padding: 0.25rem 0.5rem;
		font-size: 0.7rem;
	}
</style>

