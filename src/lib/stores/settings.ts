import { writable } from 'svelte/store';
import { Store } from '@tauri-apps/plugin-store';

// Default settings
const DEFAULT_SETTINGS = {
	autoUpdate: true,
};

// Create settings store instance
let settingsStore: Store | null = null;

// Initialize Tauri store
async function initStore() {
	if (!settingsStore) {
		settingsStore = new Store('.settings.dat');
		await settingsStore.load();
	}
	return settingsStore;
}

// Create writable store
function createSettingsStore() {
	const { subscribe, set: setStore, update } = writable(DEFAULT_SETTINGS);

	// Load settings from Tauri store on initialization
	async function load() {
		try {
			const store = await initStore();
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
		try {
			const store = await initStore();
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

