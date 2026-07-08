import { LightningElement, track } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import runSeed from '@salesforce/apex/DmoSeedRunner.runSeed';

const PACKS = [
    { label: 'FINS (Banking / Wealth / Insurance / Asset Mgmt)', value: 'demoDmoSeedFins' },
    { label: 'Healthcare', value: 'demoDmoSeedHealthcare' },
    { label: 'Retail', value: 'demoDmoSeedRetail' },
    { label: 'Onboarding', value: 'demoDmoSeedOnboarding' },
    { label: 'Custom (enter name below)', value: '__custom__' }
];

export default class DcSeedAdmin extends LightningElement {
    @track selectedPack = 'demoDmoSeedFins';
    @track customPackName = '';
    @track wipeExisting = true;
    @track running = false;
    @track lastResult = null;
    @track lastError = null;

    get packOptions() { return PACKS; }
    get showCustomInput() { return this.selectedPack === '__custom__'; }
    get resolvedPackName() {
        return this.selectedPack === '__custom__' ? this.customPackName.trim() : this.selectedPack;
    }
    get runDisabled() { return this.running || !this.resolvedPackName; }

    handlePackChange(e) { this.selectedPack = e.detail.value; }
    handleCustomChange(e) { this.customPackName = e.detail.value; }
    handleWipeChange(e) { this.wipeExisting = e.target.checked; }

    async handleRun() {
        this.running = true;
        this.lastResult = null;
        this.lastError = null;
        try {
            const result = await runSeed({
                packName: this.resolvedPackName,
                wipeExisting: this.wipeExisting
            });
            this.lastResult = result;
            this.dispatchEvent(new ShowToastEvent({
                title: 'Seed complete',
                message: `${result.individuals} individuals, ${result.events} events, ${result.transactions} transactions in ${result.durationMs} ms`,
                variant: 'success'
            }));
        } catch (err) {
            this.lastError = err.body?.message || err.message || String(err);
            this.dispatchEvent(new ShowToastEvent({
                title: 'Seed failed',
                message: this.lastError,
                variant: 'error'
            }));
        } finally {
            this.running = false;
        }
    }
}
