import { LightningElement, api } from 'lwc';

/**
 * Renders one Personalized Website editor field by its schema type and emits a
 * `fieldchange` event ({ id, value }) on edit. Used by personalizedWebsiteStudio to
 * render the full lifted-and-shifted Experience Generator form data-driven from the
 * field schema. Keeps the studio template flat regardless of field count.
 */
export default class WebField extends LightningElement {
    @api field;            // { id, label, type, options?, placeholder? }
    @api value;

    get type() { return (this.field && this.field.type) || 'text'; }
    get isText() { return this.type === 'text' || this.type === 'url' || this.type === 'number'; }
    get isTextarea() { return this.type === 'textarea'; }
    get isColor() { return this.type === 'color'; }
    get isImage() { return this.type === 'image'; }
    get isPicklist() { return this.type === 'picklist'; }
    get isToggle() { return this.type === 'toggle'; }

    get inputType() {
        if (this.type === 'url') return 'url';
        if (this.type === 'number') return 'number';
        return 'text';
    }
    get options() {
        return (this.field && this.field.options ? this.field.options : []).map((o) =>
            typeof o === 'string' ? { label: o, value: o } : o
        );
    }
    get checked() { return this.value === true || this.value === 'true'; }
    get colorValue() { return this.value || '#000000'; }
    // Pick the curated library for the demoStoryImage picker from the field id.
    get imageKind() {
        const id = (this.field && this.field.id ? this.field.id : '').toLowerCase();
        if (id.indexOf('logo') !== -1) return 'logo';
        if (id.indexOf('avatar') !== -1 || id.indexOf('agent') !== -1) return 'avatar';
        return 'hero';
    }
    handlePick(e) { this.emit(e.detail.url); }

    emit(value) {
        this.dispatchEvent(new CustomEvent('fieldchange', {
            detail: { id: this.field.id, value }
        }));
    }
    handleInput(e) { this.emit(e.target.value); }
    handleToggle(e) { this.emit(e.target.checked); }
    handleColor(e) { this.emit(e.target.value); }
}
