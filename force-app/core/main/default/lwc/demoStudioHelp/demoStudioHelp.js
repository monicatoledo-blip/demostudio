import { LightningElement, api } from 'lwc';

export default class DemoStudioHelp extends LightningElement {
    @api heading = 'How to use';
    @api steps = [];
    open = false;

    get iconName() { return this.open ? 'utility:chevronup' : 'utility:chevrondown'; }
    get panelClass() { return this.open ? 'help-panel help-panel--open' : 'help-panel'; }
    get decoratedSteps() {
        return (this.steps || []).map((s, i) => ({ ...s, num: i + 1, key: `s-${i}` }));
    }

    toggle() { this.open = !this.open; }
}
