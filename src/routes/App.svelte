<div class="calculator-container">
	<header class="calculator-header">
		<h1>Microsoft Pay Calculator</h1>
		<div class="header-actions">
			<button class="reset-button" onclick={resetValues} aria-label="Reset to defaults" title="Reset all values to defaults">
				<svg width="20" height="20" viewBox="0 0 20 20" fill="none" xmlns="http://www.w3.org/2000/svg">
					<path d="M10 3V1M10 3C8.89543 3 7.83657 3.42143 7.03553 4.17157C6.2345 4.92172 5.75 5.93913 5.75 7C5.75 7.41421 5.41421 7.75 5 7.75C4.58579 7.75 4.25 7.41421 4.25 7C4.25 5.4087 4.88214 3.88258 6.00628 2.75736C7.13043 1.63214 8.65652 1 10.25 1C11.8435 1 13.3696 1.63214 14.4937 2.75736C15.6179 3.88258 16.25 5.4087 16.25 7C16.25 8.5913 15.6179 10.1174 14.4937 11.2426C13.3696 12.3679 11.8435 13 10.25 13H5M5 13L7.5 10.5M5 13L7.5 15.5" stroke="currentColor" stroke-width="1.5" stroke-linecap="round" stroke-linejoin="round"/>
				</svg>
				Reset
			</button>
			<button class="settings-button" onclick={openSettings} aria-label="Settings" title="Open settings">
				<svg width="20" height="20" viewBox="0 0 20 20" fill="none" xmlns="http://www.w3.org/2000/svg">
					<circle cx="10" cy="4" r="1.5" fill="currentColor"/>
					<circle cx="10" cy="10" r="1.5" fill="currentColor"/>
					<circle cx="10" cy="16" r="1.5" fill="currentColor"/>
				</svg>
			</button>
		</div>
	</header>

	<!-- Tabs Container -->
	<div class="tabs-container">
		<div class="tabs-header">
			<button
				class="tab-button"
				class:active={activeTab === 'compensation'}
				onclick={() => activeTab = 'compensation'}
			>
				Compensation Details
			</button>
			<button
				class="tab-button"
				class:active={activeTab === 'benefits'}
				onclick={() => activeTab = 'benefits'}
			>
				Retirement & Benefits
			</button>
		</div>

		<div class="tabs-content">
			{#if activeTab === 'compensation'}
				<div class="tab-panel">
					<div class="form-grid">
						<div class="form-group">
							<label for="base">Base Salary (Yearly)</label>
							<input id="base" type="number" bind:value={base} placeholder="Enter base salary">
						</div>
						<div class="form-group">
							<label for="clearanceBonus">Clearance Bonus (%)</label>
							<input id="clearanceBonus" type="number" bind:value={clearanceBonus} placeholder="Enter percentage">
						</div>
						<div class="form-group">
							<label for="additionalBonus">Additional Bonus (%)</label>
							<input id="additionalBonus" type="number" bind:value={additionalBonus} placeholder="Enter percentage">
						</div>
						<div class="form-group">
							<label for="startingBonus">Starting Bonus ($)</label>
							<input id="startingBonus" type="number" bind:value={startingBonus} placeholder="Enter amount">
						</div>
						<div class="form-group">
							<label for="relocationBonus">Relocation Bonus ($)</label>
							<input id="relocationBonus" type="number" bind:value={relocationBonus} placeholder="Enter amount">
						</div>
						<div class="form-group">
							<label for="stockBonus">Stock Bonus ($)</label>
							<input id="stockBonus" type="number" bind:value={stockBonus} placeholder="Enter amount">
						</div>
					</div>
				</div>
			{:else if activeTab === 'benefits'}
				<div class="tab-panel">
					<div class="form-grid">
						<div class="form-group">
							<label for="contribution401K">401K Contribution (%)</label>
							<input id="contribution401K" type="number" bind:value={contribution401K} placeholder="Enter percentage">
						</div>
						<div class="form-group">
							<label for="employer401KMatch">401K Employer Match (%)</label>
							<input id="employer401KMatch" type="number" bind:value={employer401KMatch} placeholder="Enter percentage">
						</div>
						<div class="form-group">
							<label for="hsaEmployeeContribution">HSA Employee Contribution ($ yearly)</label>
							<input id="hsaEmployeeContribution" type="number" bind:value={hsaEmployeeContribution} placeholder="Enter amount">
						</div>
						<div class="form-group">
							<label for="hsaEmployerContribution">HSA Employer Contribution ($ yearly)</label>
							<input id="hsaEmployerContribution" type="number" bind:value={hsaEmployerContribution} placeholder="Enter amount">
						</div>
					</div>
				</div>
			{/if}
		</div>
	</div>

	<!-- Results Section with Tabs -->
	<div class="results-container">
		<div class="results-header">
			<h2 class="results-title">Results</h2>
			<div class="results-tabs-header">
				<button
					class="results-tab-button"
					class:active={activeResultsTab === 'summary'}
					onclick={() => activeResultsTab = 'summary'}
				>
					Annual Summary
				</button>
				<button
					class="results-tab-button"
					class:active={activeResultsTab === 'paycheck'}
					onclick={() => activeResultsTab = 'paycheck'}
				>
					Paycheck Estimate
				</button>
			</div>
		</div>

		<div class="results-content">
			{#if activeResultsTab === 'summary'}
				<div class="results-tab-panel">
					<div class="results-grid">
						<div class="result-item">
							<div class="result-item-label">Annual Compensation</div>
							<div class="result-item-value primary">{formatCurrency(totalComp)}</div>
						</div>
						<div class="result-item">
							<div class="result-item-label">401K Employee Contribution</div>
							<div class="result-item-value">{formatCurrency(annual401KEmployee)}</div>
						</div>
						<div class="result-item">
							<div class="result-item-label">401K Employer Match</div>
							<div class="result-item-value">{formatCurrency(annual401KEmployer)}</div>
						</div>
						<div class="result-item">
							<div class="result-item-label">401K Total</div>
							<div class="result-item-value">{formatCurrency(annual401KTotal)}</div>
						</div>
						<div class="result-item">
							<div class="result-item-label">HSA Employee Contribution</div>
							<div class="result-item-value">{formatCurrency(hsaEmployeeContributionF.toString())}</div>
						</div>
						<div class="result-item">
							<div class="result-item-label">HSA Employer Contribution</div>
							<div class="result-item-value">{formatCurrency(hsaEmployerContributionF.toString())}</div>
						</div>
						<div class="result-item">
							<div class="result-item-label">HSA Total Contribution</div>
							<div class="result-item-value">{formatCurrency(hsaTotalContribution)}</div>
						</div>
					</div>
				</div>
			{:else if activeResultsTab === 'paycheck'}
				<div class="results-tab-panel">
					<div class="paycheck-content">
						<h3 class="paycheck-subtitle">After Tax & Deductions</h3>
						<ul class="paycheck-list">
							<li class="paycheck-item">
								<span class="paycheck-label">Yearly:</span>
								<span class="paycheck-value">{formatCurrency(takeHomeYearly)}</span>
							</li>
							<li class="paycheck-item">
								<span class="paycheck-label">Monthly:</span>
								<span class="paycheck-value">{formatCurrency(takeHomeMonthly)}</span>
							</li>
							<li class="paycheck-item">
								<span class="paycheck-label">Semi-Monthly:</span>
								<span class="paycheck-value">{formatCurrency(takeHomeSemiMonthly)}</span>
							</li>
						</ul>
					</div>
				</div>
			{/if}
		</div>
	</div>
</div>

<script lang="ts">
	import { calculator, DEFAULT_CALCULATOR_VALUES } from '$lib/stores/calculator';
	import { onMount, onDestroy } from 'svelte';

	let base = $state(DEFAULT_CALCULATOR_VALUES.base);
	let clearanceBonus = $state(DEFAULT_CALCULATOR_VALUES.clearanceBonus);
	let additionalBonus = $state(DEFAULT_CALCULATOR_VALUES.additionalBonus);
	let startingBonus = $state(DEFAULT_CALCULATOR_VALUES.startingBonus);
	let stockBonus = $state(DEFAULT_CALCULATOR_VALUES.stockBonus);
	let relocationBonus = $state(DEFAULT_CALCULATOR_VALUES.relocationBonus);
	let contribution401K = $state(DEFAULT_CALCULATOR_VALUES.contribution401K);
	let employer401KMatch = $state(DEFAULT_CALCULATOR_VALUES.employer401KMatch);
	let hsaEmployeeContribution = $state(DEFAULT_CALCULATOR_VALUES.hsaEmployeeContribution);
	let hsaEmployerContribution = $state(DEFAULT_CALCULATOR_VALUES.hsaEmployerContribution);

	// Active tab state
	let activeTab = $state<'compensation' | 'benefits'>('compensation');
	let activeResultsTab = $state<'summary' | 'paycheck'>('summary');

	// Subscribe to calculator store to keep values in sync
	let unsubscribe: (() => void) | null = null;
	let isLoadingFromStore = false;

	onMount(async () => {
		// Ensure calculator values are loaded
		await calculator.load();
		
		// Load values from store
		unsubscribe = calculator.subscribe((values) => {
			isLoadingFromStore = true;
			base = values.base;
			clearanceBonus = values.clearanceBonus;
			additionalBonus = values.additionalBonus;
			startingBonus = values.startingBonus;
			stockBonus = values.stockBonus;
			relocationBonus = values.relocationBonus;
			contribution401K = values.contribution401K;
			employer401KMatch = values.employer401KMatch;
			hsaEmployeeContribution = values.hsaEmployeeContribution;
			hsaEmployerContribution = values.hsaEmployerContribution;
			// Reset flag after a brief delay to allow reactivity to settle
			setTimeout(() => {
				isLoadingFromStore = false;
			}, 100);
		});
	});

	// Cleanup subscription on unmount
	onDestroy(() => {
		if (unsubscribe) {
			unsubscribe();
		}
	});

	// Save values when they change (debounced)
	let saveTimeout: ReturnType<typeof setTimeout> | null = null;
	function saveValues() {
		// Don't save if we're currently loading from store
		if (isLoadingFromStore) {
			return;
		}
		
		if (saveTimeout) {
			clearTimeout(saveTimeout);
		}
		saveTimeout = setTimeout(async () => {
			await calculator.update(() => ({
				base,
				clearanceBonus,
				additionalBonus,
				startingBonus,
				stockBonus,
				relocationBonus,
				contribution401K,
				employer401KMatch,
				hsaEmployeeContribution,
				hsaEmployerContribution,
			}));
		}, 500); // Debounce by 500ms
	}

	// Watch for changes and save
	$effect(() => {
		// Access all values to create dependencies
		const _ = base + clearanceBonus + additionalBonus + startingBonus + 
			stockBonus + relocationBonus + contribution401K + employer401KMatch + 
			hsaEmployeeContribution + hsaEmployerContribution;
		saveValues();
	});

	// Reset to default values
	async function resetValues() {
		await calculator.reset();
		// Values will be updated via subscription
	}

	let clearanceBonusF = $derived(parseFloat(clearanceBonus.toString().endsWith('.') ? clearanceBonus.toString() + '0' : clearanceBonus.toString()) || 0);
	let baseNum = $derived(parseFloat(base) || 0);
	let additionalBonusNum = $derived(parseFloat(additionalBonus) || 0);
	let startingBonusNum = $derived(parseFloat(startingBonus) || 0);
	let stockBonusNum = $derived(parseFloat(stockBonus) || 0);
	let relocationBonusNum = $derived(parseFloat(relocationBonus) || 0);
	let contribution401KNum = $derived(parseFloat(contribution401K) || 0);
	let employer401KMatchNum = $derived(parseFloat(employer401KMatch) || 0);
	let hsaEmployeeContributionNum = $derived(parseFloat(hsaEmployeeContribution) || 0);
	let hsaEmployerContributionNum = $derived(parseFloat(hsaEmployerContribution) || 0);

	// Base compensation (before employer contributions)
	let baseComp = $derived(baseNum + (baseNum * (clearanceBonusF/100)) + (baseNum * (additionalBonusNum/100)) + relocationBonusNum + startingBonusNum + (stockBonusNum / 4));

	// 401K calculations
	let annual401KEmployee = $derived((baseNum * (contribution401KNum / 100)).toFixed(2));
	let annual401KEmployeeNum = $derived(parseFloat(annual401KEmployee) || 0);
	let annual401KEmployer = $derived((annual401KEmployeeNum * (employer401KMatchNum / 100)).toFixed(2));
	let annual401KEmployerNum = $derived(parseFloat(annual401KEmployer) || 0);
	let annual401KTotal = $derived((annual401KEmployeeNum + annual401KEmployerNum).toFixed(2));

	// HSA calculations
	let hsaEmployeeContributionF = $derived(hsaEmployeeContributionNum);
	let hsaEmployerContributionF = $derived(hsaEmployerContributionNum);
	let hsaTotalContribution = $derived((hsaEmployeeContributionF + hsaEmployerContributionF).toFixed(2));

	// Total compensation includes base comp + employer 401K match + employer HSA contribution
	let totalComp = $derived((baseComp + annual401KEmployerNum + hsaEmployerContributionF).toFixed(2));

	// Taxable income = base compensation - employee 401K - employee HSA (employer contributions don't reduce taxable income)
	let taxableIncome = $derived(baseComp - annual401KEmployeeNum - hsaEmployeeContributionF);
	let compPostTax = $derived(taxableIncome * .75);
	let takeHomeYearly = $derived(compPostTax.toFixed(2));
	let takeHomeMonthly = $derived((compPostTax / 12).toFixed(2));
	let takeHomeSemiMonthly = $derived((compPostTax / 24).toFixed(2));

	// Format currency function
	function formatCurrency(value: string | number): string {
		const numValue = typeof value === 'string' ? parseFloat(value) : value;
		if (isNaN(numValue)) return '$0.00';
		return new Intl.NumberFormat('en-US', {
			style: 'currency',
			currency: 'USD',
			minimumFractionDigits: 2,
			maximumFractionDigits: 2
		}).format(numValue);
	}

	// Navigate to settings
	async function openSettings() {
		const { goto } = await import('$app/navigation');
		goto('/settings');
	}
</script>
