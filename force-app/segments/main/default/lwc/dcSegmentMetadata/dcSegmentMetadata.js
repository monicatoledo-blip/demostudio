import { LightningElement, api } from 'lwc';

const SCHEDULE_OPTIONS = [
    { label: 'Real-time', value: 'Real-time' },
    { label: 'Daily', value: 'Daily' },
    { label: 'Weekly', value: 'Weekly' },
    { label: 'On-demand', value: 'On-demand' }
];

export default class DcSegmentMetadata extends LightningElement {
    @api name;
    @api description;
    @api publishSchedule;
    @api populationCount;
    @api lastRefreshed;
    @api sampleMembers = [];
    @api counting = false;

    get scheduleOptions() { return SCHEDULE_OPTIONS; }
    get displayCount() { return typeof this.populationCount === 'number' ? this.populationCount.toLocaleString() : '—'; }
    get lastRefreshedDisplay() { return this.lastRefreshed || 'Never'; }
    get hasSample() { return this.sampleMembers?.length > 0; }

    emit(name, value) {
        this.dispatchEvent(new CustomEvent(name, { detail: value }));
    }
    handleName(e) { this.emit('namechange', e.detail?.value ?? e.target.value); }
    handleDescription(e) { this.emit('descriptionchange', e.detail?.value ?? e.target.value); }
    handleSchedule(e) { this.emit('schedulechange', e.detail.value); }
}
