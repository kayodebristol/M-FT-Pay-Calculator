<script lang="ts">
	import { onMount } from 'svelte';
	import { goto } from '$app/navigation';

	let { children } = $props();

	function goBack() {
		goto('/');
	}
</script>

<div class="settings-layout">
	<button class="back-button" onclick={goBack} aria-label="Back to Calculator">
		<svg width="20" height="20" viewBox="0 0 20 20" fill="none" xmlns="http://www.w3.org/2000/svg">
			<path d="M12.5 15L7.5 10L12.5 5" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"/>
		</svg>
		Back
	</button>
	{@render children?.()}
</div>

<style>
	.settings-layout {
		position: relative;
	}

	.back-button {
		display: flex;
		align-items: center;
		gap: 0.5rem;
		padding: 0.75rem 1rem;
		margin-bottom: 1rem;
		background: transparent;
		border: 1px solid var(--border-color);
		border-radius: var(--border-radius);
		cursor: pointer;
		color: var(--text-secondary);
		font-size: 0.9rem;
		transition: all 0.2s ease;
	}

	.back-button:hover {
		background-color: var(--primary-light);
		color: var(--primary-color);
		border-color: var(--primary-color);
	}

	.back-button svg {
		display: block;
	}
</style>


