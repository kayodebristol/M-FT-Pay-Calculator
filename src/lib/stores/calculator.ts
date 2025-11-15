import { writable } from 'svelte/store';

// Default calculator values
export const DEFAULT_CALCULATOR_VALUES = {
	base: '100000',
	clearanceBonus: '15',
	additionalBonus: '10',
	startingBonus: '0',
	stockBonus: '20000',
	relocationBonus: '0',
	contribution401K: '0',
	employer401KMatch: '50',
	hsaEmployeeContribution: '8550',
	hsaEmployerContribution: '1000',
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
		const store = new Store('.calculator.dat');
		// Store is automatically loaded when created in Tauri v2
		return store;
	} catch (error) {
		console.error('Failed to initialize Tauri store:', error);
		return null;
	}
}

// Create writable store
function createCalculatorStore() {
	const { subscribe, set: setStore } = writable(DEFAULT_CALCULATOR_VALUES);

	// Load calculator values from Tauri store on initialization
	async function load() {
		if (!isTauri()) {
			// In browser, use localStorage as fallback
			try {
				const saved = localStorage.getItem('calculator-values');
				if (saved) {
					const parsed = JSON.parse(saved);
					setStore({ ...DEFAULT_CALCULATOR_VALUES, ...parsed });
				} else {
					setStore(DEFAULT_CALCULATOR_VALUES);
				}
			} catch (error) {
				console.error('Failed to load calculator values from localStorage:', error);
				setStore(DEFAULT_CALCULATOR_VALUES);
			}
			return;
		}

		try {
			const store = await initStore();
			if (!store) {
				setStore(DEFAULT_CALCULATOR_VALUES);
				return;
			}
			const saved = await store.get<typeof DEFAULT_CALCULATOR_VALUES>('values');
			if (saved) {
				setStore({ ...DEFAULT_CALCULATOR_VALUES, ...saved });
			} else {
				// Save defaults on first run
				await save(DEFAULT_CALCULATOR_VALUES);
			}
		} catch (error) {
			console.error('Failed to load calculator values:', error);
			setStore(DEFAULT_CALCULATOR_VALUES);
		}
	}

	// Save calculator values to Tauri store
	async function save(values: typeof DEFAULT_CALCULATOR_VALUES) {
		if (!isTauri()) {
			// In browser, use localStorage as fallback
			try {
				localStorage.setItem('calculator-values', JSON.stringify(values));
				setStore(values);
			} catch (error) {
				console.error('Failed to save calculator values to localStorage:', error);
			}
			return;
		}

		try {
			const store = await initStore();
			if (!store) {
				setStore(values);
				return;
			}
			await store.set('values', values);
			await store.save();
			setStore(values);
		} catch (error) {
			console.error('Failed to save calculator values:', error);
		}
	}

	// Reset to default values
	async function reset() {
		await save(DEFAULT_CALCULATOR_VALUES);
	}

	return {
		subscribe,
		load,
		save,
		reset,
		update: async (updater: (values: typeof DEFAULT_CALCULATOR_VALUES) => typeof DEFAULT_CALCULATOR_VALUES) => {
			let currentValues: typeof DEFAULT_CALCULATOR_VALUES = DEFAULT_CALCULATOR_VALUES;
			const unsubscribe = subscribe((v) => {
				currentValues = v;
			});
			unsubscribe();
			const newValues = updater(currentValues);
			await save(newValues);
		},
	};
}

export const calculator = createCalculatorStore();

// Initialize calculator values on import
calculator.load();

