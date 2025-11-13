import { sveltekit } from '@sveltejs/kit/vite';
import { defineConfig } from 'vite';

// Get the host from environment variable for mobile development
const host = process.env.TAURI_DEV_HOST;
const port = process.env.TAURI_DEV_PORT ? parseInt(process.env.TAURI_DEV_PORT) : 5173;

export default defineConfig({
	plugins: [sveltekit()],
	clearScreen: false,
	server: {
		host: host || false,
		port: port,
		strictPort: true,
		hmr: host
			? {
					protocol: 'ws',
					host: host,
					port: port + 1,
				}
			: undefined,
	},
});
