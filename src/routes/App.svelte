<div class="calculator-container">
	<header class="calculator-header">
		<h1>Microsoft Pay Calculator</h1>
		<button class="settings-button" onclick={openSettings} aria-label="Settings">
			<svg width="20" height="20" viewBox="0 0 20 20" fill="none" xmlns="http://www.w3.org/2000/svg">
				<circle cx="10" cy="4" r="1.5" fill="currentColor"/>
				<circle cx="10" cy="10" r="1.5" fill="currentColor"/>
				<circle cx="10" cy="16" r="1.5" fill="currentColor"/>
			</svg>
		</button>
	</header>

	<section class="form-section">
		<h2 class="section-title">Compensation Details</h2>
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
	</section>

	<section class="form-section">
		<h2 class="section-title">Retirement & Benefits</h2>
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
	</section>

	<section class="results-section">
		<h2 class="section-title">Annual Compensation Summary</h2>
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
	</section>

	<section class="paycheck-section">
		<h3 class="paycheck-title">💵 Paycheck Estimate (After Tax & Deductions)</h3>
		<ul class="paycheck-list">
			<li>
				<strong>Yearly:</strong> {formatCurrency(takeHomeYearly)}
			</li>
			<li>
				<strong>Monthly:</strong> {formatCurrency(takeHomeMonthly)}
			</li>
			<li>
				<strong>Semi-Monthly:</strong> {formatCurrency(takeHomeSemiMonthly)}
			</li>
		</ul>
	</section>
</div>

<script lang="ts">
	let base = $state("100000");
	let clearanceBonus = $state("15");
	let additionalBonus = $state("10");
	let startingBonus = $state("0");
	let stockBonus = $state("20000");
	let relocationBonus = $state("0");
	let contribution401K = $state("0");
	let employer401KMatch = $state("50");
	let hsaEmployeeContribution = $state("8550");
	let hsaEmployerContribution = $state("1000");

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
