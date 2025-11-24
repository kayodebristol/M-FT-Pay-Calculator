import { settings } from '$lib/stores/settings';

let checkInterval: number | null = null;
const CHECK_INTERVAL_MS = 60 * 60 * 1000; // Check every hour

// Check if we're in Tauri environment
function isTauri(): boolean {
	return typeof window !== 'undefined' && '__TAURI_INTERNALS__' in window;
}

export async function initializeAutoUpdate() {
	// Only initialize in Tauri environment
	if (!isTauri()) {
		console.log('Auto-update: Not in Tauri environment, skipping initialization');
		return () => {}; // Return no-op unsubscribe
	}

	// Load settings
	let autoUpdateEnabled = true;
	const unsubscribe = settings.subscribe((s) => {
		autoUpdateEnabled = s.autoUpdate;
		if (autoUpdateEnabled) {
			startAutoUpdate();
		} else {
			stopAutoUpdate();
		}
	});

	// Initial check if auto-update is enabled
	if (autoUpdateEnabled) {
		await checkForUpdate();
		startAutoUpdate();
	}

	return unsubscribe;
}

async function checkForUpdate() {
	if (!isTauri()) {
		return;
	}

	try {
		// Use variable to make import truly dynamic (prevents Vite analysis)
		const updaterPath = '@tauri-apps/plugin-updater';
		const { check } = await import(updaterPath);
		const updater = await check();
		if (updater) {
			console.log('Update available:', updater.version);
			// The updater dialog will be shown automatically if configured in tauri.conf.json
		} else {
			console.log('No updates available');
		}
	} catch (error) {
		console.error('Failed to check for updates:', error);
	}
}

function startAutoUpdate() {
	stopAutoUpdate(); // Clear any existing interval

	// Check immediately
	checkForUpdate();

	// Set up periodic checks
	checkInterval = setInterval(() => {
		checkForUpdate();
	}, CHECK_INTERVAL_MS) as unknown as number;
}

function stopAutoUpdate() {
	if (checkInterval !== null) {
		clearInterval(checkInterval);
		checkInterval = null;
	}
}

