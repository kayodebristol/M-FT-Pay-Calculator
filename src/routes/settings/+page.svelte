<script lang="ts">
	import { settings } from '$lib/stores/settings';
	import { onMount } from 'svelte';
	import { check, onUpdaterEvent } from '@tauri-apps/plugin-updater';
	import { getCurrent } from '@tauri-apps/api/window';

	let autoUpdate = $state(false);
	let updateAvailable = $state(false);
	let updateInfo: any = null;
	let checkingUpdate = $state(false);
	let appVersion = $state('');

	onMount(async () => {
		// Load settings
		settings.subscribe((s) => {
			autoUpdate = s.autoUpdate;
		})();

		// Get app version
		try {
			const { getVersion } = await import('@tauri-apps/api/app');
			appVersion = await getVersion();
		} catch (error) {
			console.error('Failed to get app version:', error);
		}

		// Set up updater event listener
		onUpdaterEvent(({ event, data }) => {
			if (event === 'CHECKING_FOR_UPDATE') {
				checkingUpdate = true;
			} else if (event === 'UPDATE_AVAILABLE') {
				updateAvailable = true;
				updateInfo = data;
				checkingUpdate = false;
			} else if (event === 'UPDATE_NOT_AVAILABLE') {
				updateAvailable = false;
				checkingUpdate = false;
			} else if (event === 'UPDATE_ERROR') {
				console.error('Update error:', data);
				checkingUpdate = false;
			}
		});

		// Check for updates on mount if auto-update is enabled
		if (autoUpdate) {
			checkForUpdate();
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
		try {
			checkingUpdate = true;
			const updater = await check();
			if (updater) {
				updateAvailable = true;
				updateInfo = {
					version: updater.version,
					body: updater.body || 'Update available',
				};
			} else {
				updateAvailable = false;
			}
			checkingUpdate = false;
		} catch (error) {
			console.error('Failed to check for updates:', error);
			checkingUpdate = false;
		}
	}

	async function installUpdate() {
		try {
			const updater = await check();
			if (updater) {
				await updater.downloadAndInstall();
				// Restart app after installation
				const { relaunch } = await import('@tauri-apps/api/process');
				await relaunch();
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
				<label class="setting-label">Version</label>
				<p class="setting-description">Current application version</p>
			</div>
			<div class="setting-value">{appVersion}</div>
		</div>

		<div class="setting-item">
			<div class="setting-info">
				<label class="setting-label">Check for Updates</label>
				<p class="setting-description">Manually check for available updates</p>
			</div>
			<button
				class="btn-check-update"
				onclick={checkForUpdate}
				disabled={checkingUpdate}
			>
				{checkingUpdate ? 'Checking...' : 'Check Now'}
			</button>
		</div>

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
		padding: 2rem;
	}

	.settings-header {
		margin-bottom: 2rem;
		border-bottom: 2px solid #e0e0e0;
		padding-bottom: 1rem;
	}

	.settings-header h1 {
		margin: 0;
		font-size: 2rem;
		color: #333;
	}

	.settings-section {
		margin-bottom: 2rem;
	}

	.section-title {
		font-size: 1.5rem;
		margin-bottom: 1.5rem;
		color: #333;
	}

	.setting-item {
		display: flex;
		justify-content: space-between;
		align-items: center;
		padding: 1.5rem;
		margin-bottom: 1rem;
		background: #f9f9f9;
		border-radius: 8px;
		border: 1px solid #e0e0e0;
	}

	.setting-info {
		flex: 1;
		margin-right: 1rem;
	}

	.setting-label {
		display: block;
		font-weight: 600;
		margin-bottom: 0.5rem;
		color: #333;
		font-size: 1rem;
	}

	.setting-description {
		margin: 0;
		color: #666;
		font-size: 0.9rem;
	}

	.setting-value {
		font-weight: 600;
		color: #333;
	}

	/* Toggle Switch */
	.toggle-switch {
		position: relative;
		display: inline-block;
		width: 60px;
		height: 34px;
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
		border-radius: 34px;
	}

	.toggle-slider:before {
		position: absolute;
		content: '';
		height: 26px;
		width: 26px;
		left: 4px;
		bottom: 4px;
		background-color: white;
		transition: 0.4s;
		border-radius: 50%;
	}

	input:checked + .toggle-slider {
		background-color: #0078d4;
	}

	input:checked + .toggle-slider:before {
		transform: translateX(26px);
	}

	input:disabled + .toggle-slider {
		opacity: 0.5;
		cursor: not-allowed;
	}

	/* Buttons */
	.btn-check-update,
	.btn-install-update {
		padding: 0.75rem 1.5rem;
		background-color: #0078d4;
		color: white;
		border: none;
		border-radius: 6px;
		font-size: 0.9rem;
		font-weight: 600;
		cursor: pointer;
		transition: background-color 0.2s;
	}

	.btn-check-update:hover:not(:disabled),
	.btn-install-update:hover {
		background-color: #106ebe;
	}

	.btn-check-update:disabled {
		opacity: 0.6;
		cursor: not-allowed;
	}

	/* Update Notification */
	.update-notification {
		margin-top: 2rem;
		padding: 1.5rem;
		background: #e3f2fd;
		border: 2px solid #2196f3;
		border-radius: 8px;
		display: flex;
		justify-content: space-between;
		align-items: flex-start;
		gap: 1rem;
	}

	.update-info h3 {
		margin: 0 0 0.5rem 0;
		color: #1976d2;
	}

	.update-info p {
		margin: 0 0 0.5rem 0;
		color: #333;
	}

	.update-notes {
		margin-top: 0.5rem;
		padding: 0.75rem;
		background: white;
		border-radius: 4px;
		font-size: 0.9rem;
		color: #555;
		white-space: pre-wrap;
	}

	.btn-install-update {
		flex-shrink: 0;
	}
</style>

