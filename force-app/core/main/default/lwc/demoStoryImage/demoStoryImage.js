import { LightningElement, api } from 'lwc';
import { NBA_IMAGE_LIBRARY } from 'c/demoNbaImageLibrary';

/**
 * Image picker for Story Studio — mirrors the NBA image library UX in the
 * Unified Profile tool: a current thumbnail, a paste-URL field, and a toggle
 * to browse the shared curated image library (reused from demoNbaImageLibrary).
 * Emits a `pick` event with { url } when the image changes; the parent reads the
 * field name from the element's data-field and commits it to the config.
 */
export default class DemoStoryImage extends LightningElement {
    @api label;
    @api value;
    showGrid = false;

    get hasValue() { return !!this.value; }
    get toggleLabel() { return this.showGrid ? 'Hide library' : 'Browse library'; }
    get images() {
        return (NBA_IMAGE_LIBRARY || []).map((i) => ({ id: i.id, url: i.url, description: i.description }));
    }

    toggleGrid() { this.showGrid = !this.showGrid; }
    handleUrl(e) { this.fire(e.target.value); }
    clearImg() { this.fire(''); }
    pickFromGrid(e) { this.fire(e.currentTarget.dataset.url); this.showGrid = false; }

    fire(url) {
        this.dispatchEvent(new CustomEvent('pick', { detail: { url } }));
    }
}
