<script lang="ts">
	import '../app.css';
	import App from './App.svelte';
	import { onMount } from 'svelte';
	import { initializeAutoUpdate } from '$lib/services/updater';

	onMount(() => {
		// Initialize auto-update service
		initializeAutoUpdate();
	});
</script>

<App />
