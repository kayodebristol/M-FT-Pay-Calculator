<script lang="ts">
	import favicon from '$lib/assets/favicon.svg';

	let { children } = $props();
</script>

<svelte:head>
	<link rel="icon" href={favicon} />
	<link rel="icon" type="image/svg+xml" href="/favicon.svg" />
	<link rel="alternate icon" href="/favicon.svg" />
</svelte:head>

{@render children?.()}
