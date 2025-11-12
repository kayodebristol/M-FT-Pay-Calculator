<h1>
Microsoft Pay Calculator
</h1>

<p>
	Base salary (yearly)
</p>
<input bind:value = {base}>
<p>
	Clearance Bonus (%)
</p>
<input bind:value = {clearanceBonus}>
<p>
	Starting Bonus ($)
</p>
<input bind:value = {startingBonus}>
<p>
	Additional Bonus (%)
</p>
<input bind:value = {additionalBonus}>
<p>
	Relocation Bonus ($)
</p>
<input bind:value = {relocationBonus}>
<p>
	Stock Bonus ($)
</p>
<input bind:value = {stockBonus}>
<p>
	Annual Compensation = {totalComp}	
</p>
<ul>
	Pay Check Estimate (after tax) 
	<li>{totalComp * .75 } (yearly)</li>
	<li>{totalComp * .75 / 12} (monthly)</li>
	<li>{totalComp * .75 / 24} (semi monthly)</li>
</ul>


<script lang=typescript>
	import { run } from 'svelte/legacy';

let base = $state("1"); 
let clearanceBonus = $state(15);
let additionalBonus = $state(10);
let startingBonus = $state(0);
let stockBonus = $state(20000);
let relocationBonus = $state(0);

let clearanceBonusF = $derived(parseFloat(clearanceBonus.toString().endsWith('.') ? clearanceBonus.toString() + '0' : clearanceBonus.toString())); 
run(() => {
		additionalBonus = parseFloat(additionalBonus);
	}); 
run(() => {
		startingBonus = parseFloat(startingBonus);
	});
run(() => {
		stockBonus = parseFloat(stockBonus);
	});
run(() => {
		relocationBonus = parseFloat(relocationBonus);
	});
let totalComp = $derived((parseFloat(base) + (parseFloat(base) * (clearanceBonusF/100)) + (parseFloat(base) * (additionalBonus/100)) + (relocationBonus) + (startingBonus) + (stockBonus / 4)).toFixed(2)); 
let compPostTax = $derived(totalComp * .75); 
</script>