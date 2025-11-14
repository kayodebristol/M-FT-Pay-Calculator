import { check, onUpdaterEvent } from '@tauri-apps/plugin-updater';
import { settings } from '$lib/stores/settings';

let checkInterval: number | null = null;
const CHECK_INTERVAL_MS = 60 * 60 * 1000; // Check every hour

export async function initializeAutoUpdate() {
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

	// Set up updater event listener
	await onUpdaterEvent(({ event, data }) => {
		if (event === 'UPDATE_AVAILABLE') {
			console.log('Update available:', data);
			// The updater dialog will be shown automatically if configured
		} else if (event === 'UPDATE_ERROR') {
			console.error('Update error:', data);
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
	try {
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

