import { LightningElement, api } from 'lwc';

// Curated list of SLDS utility icons commonly used to describe demo
// activity types. Users pick from a grid instead of typing icon names.
const ICONS = [
    'utility:email',
    'utility:sms',
    'utility:call',
    'utility:phone_landline',
    'utility:contact',
    'utility:groups',
    'utility:activity',
    'utility:event',
    'utility:date_time',
    'utility:calendar',
    'utility:task',
    'utility:check',
    'utility:success',
    'utility:priority',
    'utility:warning',
    'utility:info',
    'utility:notification',
    'utility:questions_and_answers',
    'utility:reminder',
    'utility:announcement',
    'utility:world',
    'utility:link',
    'utility:new_window',
    'utility:preview',
    'utility:search',
    'utility:einstein',
    'utility:bot',
    'utility:magicwand',
    'utility:file',
    'utility:upload',
    'utility:download',
    'utility:attach',
    'utility:paste',
    'utility:signpost',
    'utility:flow',
    'utility:trending',
    'utility:chart',
    'utility:moneybag',
    'utility:currency',
    'utility:cart',
    'utility:knowledge_base',
    'utility:agent_session',
    'utility:agent_home',
    'utility:opportunity',
    'utility:apps'
];

export default class DemoIconPicker extends LightningElement {
    @api value;
    @api label = 'Icon';
    @api rowIndex;
    @api fieldName;

    isOpen = false;

    get displayValue() {
        return this.value || '—';
    }

    get iconOptions() {
        return ICONS.map((name) => ({
            name,
            class: name === this.value ? 'ip-icon ip-icon--selected' : 'ip-icon'
        }));
    }

    toggleOpen() {
        this.isOpen = !this.isOpen;
    }

    handlePick(e) {
        const name = e.currentTarget.dataset.name;
        this.isOpen = false;
        this.dispatchEvent(new CustomEvent('change', {
            detail: {
                value: name,
                rowIndex: this.rowIndex,
                fieldName: this.fieldName
            }
        }));
    }

    close() {
        this.isOpen = false;
    }
}
