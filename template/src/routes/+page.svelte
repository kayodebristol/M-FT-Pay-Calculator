<script lang="ts">
	import { onMount } from 'svelte';

	let mounted = $state(false);

	onMount(() => {
		mounted = true;
	});
</script>

<div class="container">
	<header>
		<h1>{{PROJECT_NAME}}</h1>
		<p class="subtitle">{{PROJECT_DESCRIPTION}}</p>
	</header>

	<main>
		{#if mounted}
			<div class="welcome">
				<h2>Welcome to {{PROJECT_NAME}}!</h2>
				<p>This is your starting point. Edit <code>src/routes/+page.svelte</code> to get started.</p>
			</div>
		{/if}
	</main>
</div>

<style>
	.container {
		max-width: 800px;
		margin: 0 auto;
		padding: 2rem;
	}

	header {
		text-align: center;
		margin-bottom: 3rem;
	}

	h1 {
		font-size: 2.5rem;
		margin-bottom: 0.5rem;
	}

	.subtitle {
		color: #666;
		font-size: 1.2rem;
	}

	.welcome {
		background: #f5f5f5;
		border-radius: 8px;
		padding: 2rem;
		margin-top: 2rem;
	}

	code {
		background: #e0e0e0;
		padding: 0.2rem 0.4rem;
		border-radius: 4px;
		font-family: monospace;
	}
</style>


