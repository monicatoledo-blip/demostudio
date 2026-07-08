import { LightningElement, api } from 'lwc';

export default class DemoPersonaStudioStory extends LightningElement {
    @api persona;

    bubbleChange(e) {
        const field = e.target.dataset.field;
        const value = e.detail.value !== undefined ? e.detail.value : e.target.value;
        const numeric = e.target.type === 'number';
        this.dispatchEvent(new CustomEvent('change', {
            detail: { field, value: numeric ? Number(value) : value }
        }));
    }
}
