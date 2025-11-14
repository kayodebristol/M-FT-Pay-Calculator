import { writable } from 'svelte/store';

// Default settings
const DEFAULT_SETTINGS = {
	autoUpdate: true,
};

// Check if we're in Tauri environment
function isTauri(): boolean {
	return typeof window !== 'undefined' && '__TAURI_INTERNALS__' in window;
}

// Initialize Tauri store
async function initStore() {
	if (!isTauri()) {
		return null;
	}
	try {
		const { Store } = await import('@tauri-apps/plugin-store');
		const store = new Store('.settings.dat');
		// Store is automatically loaded when created in Tauri v2
		return store;
	} catch (error) {
		console.error('Failed to initialize Tauri store:', error);
		return null;
	}
}

// Create writable store
function createSettingsStore() {
	const { subscribe, set: setStore, update } = writable(DEFAULT_SETTINGS);

	// Load settings from Tauri store on initialization
	async function load() {
		if (!isTauri()) {
			// In browser, use localStorage as fallback
			try {
				const saved = localStorage.getItem('app-settings');
				if (saved) {
					const parsed = JSON.parse(saved);
					setStore({ ...DEFAULT_SETTINGS, ...parsed });
				} else {
					setStore(DEFAULT_SETTINGS);
				}
			} catch (error) {
				console.error('Failed to load settings from localStorage:', error);
				setStore(DEFAULT_SETTINGS);
			}
			return;
		}

		try {
			const store = await initStore();
			if (!store) {
				setStore(DEFAULT_SETTINGS);
				return;
			}
			const saved = await store.get<typeof DEFAULT_SETTINGS>('settings');
			if (saved) {
				setStore({ ...DEFAULT_SETTINGS, ...saved });
			} else {
				// Save defaults on first run
				await save(DEFAULT_SETTINGS);
			}
		} catch (error) {
			console.error('Failed to load settings:', error);
			setStore(DEFAULT_SETTINGS);
		}
	}

	// Save settings to Tauri store
	async function save(settings: typeof DEFAULT_SETTINGS) {
		if (!isTauri()) {
			// In browser, use localStorage as fallback
			try {
				localStorage.setItem('app-settings', JSON.stringify(settings));
				setStore(settings);
			} catch (error) {
				console.error('Failed to save settings to localStorage:', error);
			}
			return;
		}

		try {
			const store = await initStore();
			if (!store) {
				setStore(settings);
				return;
			}
			await store.set('settings', settings);
			await store.save();
			setStore(settings);
		} catch (error) {
			console.error('Failed to save settings:', error);
		}
	}

	return {
		subscribe,
		load,
		save,
		update: async (updater: (settings: typeof DEFAULT_SETTINGS) => typeof DEFAULT_SETTINGS) => {
			let currentSettings: typeof DEFAULT_SETTINGS = DEFAULT_SETTINGS;
			const unsubscribe = subscribe((s) => {
				currentSettings = s;
			});
			unsubscribe();
			const newSettings = updater(currentSettings);
			await save(newSettings);
		},
	};
}

export const settings = createSettingsStore();

// Initialize settings on import
settings.load();

