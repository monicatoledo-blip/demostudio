import { LightningElement, api } from 'lwc';
import { NBA_IMAGE_LIBRARY } from 'c/demoNbaImageLibrary';

/**
 * Image picker for Story Studio — mirrors the NBA image library UX in the
 * Unified Profile tool: a current thumbnail, a paste-URL field, and a toggle
 * to browse the shared curated image library (reused from demoNbaImageLibrary).
 * Emits a `pick` event with { url } when the image changes; the parent reads the
 * field name from the element's data-field and commits it to the config.
 */
// Avatar/logo libraries are populated once Monica supplies her Cloudinary URLs;
// hero uses the shared NBA scene library.
// Avatar images from Monica's Cloudinary collection (dfx98jgdc).
const AVATAR_LIBRARY = [
    { id: 'av-01', description: 'Avatar', url: 'https://res.cloudinary.com/dfx98jgdc/image/upload/v1791137635/AdobeStock_302945654_pkqmop.jpg' },
    { id: 'av-02', description: 'Female student, confident', url: 'https://res.cloudinary.com/dfx98jgdc/image/upload/v1791137631/young-determined-armenian-curlyhaired-female-university-student-listen-carefully-asignment-look-confident-ready-task-cross-hands-chest-smiling-selfassured-standing-white-background_176420-56066_ihoixg.avif' },
    { id: 'av-03', description: 'Avatar', url: 'https://res.cloudinary.com/dfx98jgdc/image/upload/v1791137631/Screenshot_2026-09-02_at_12.37.01_PM_s0t1yf.png' },
    { id: 'av-04', description: 'Avatar', url: 'https://res.cloudinary.com/dfx98jgdc/image/upload/v1791137631/Screenshot_2026-07-07_at_12.50.20_AM_tahmw0.png' },
    { id: 'av-05', description: 'Avatar', url: 'https://res.cloudinary.com/dfx98jgdc/image/upload/v1791137631/Screenshot_2026-07-13_alle_10.10.44_qadpwo.png' },
    { id: 'av-06', description: 'Alan Reed', url: 'https://res.cloudinary.com/dfx98jgdc/image/upload/v1791137630/Alan_Reed_baf3az.jpg' },
    { id: 'av-07', description: 'Avatar', url: 'https://res.cloudinary.com/dfx98jgdc/image/upload/v1791137630/Capture_d_e%CC%81cran_2026-03-24_a%CC%80_12.24.49_wdwjwi.png' },
    { id: 'av-08', description: 'Mary', url: 'https://res.cloudinary.com/dfx98jgdc/image/upload/v1791137629/Mary_af4sgw.jpg' },
    { id: 'av-09', description: 'Richard Bennett', url: 'https://res.cloudinary.com/dfx98jgdc/image/upload/v1791137629/Richard-Bennett-avatar_uamfrc.jpg' },
    { id: 'av-10', description: 'Headshot', url: 'https://res.cloudinary.com/dfx98jgdc/image/upload/v1791137625/AdobeStock_60145673-headshot_i3tm7d.jpg' },
    { id: 'av-11', description: 'Matthew Wells', url: 'https://res.cloudinary.com/dfx98jgdc/image/upload/v1791137624/1790605494464-Matthew-Wells-Avatar_WEB_zjm0wy.jpg' },
    { id: 'av-12', description: 'Avatar', url: 'https://res.cloudinary.com/dfx98jgdc/image/upload/v1791137623/360_F_631600560_6zvceKXiNXlRmBxsc5JEnRkEIsiCJXem_iua2uy.jpg' },
    { id: 'av-13', description: 'Avatar', url: 'https://res.cloudinary.com/dfx98jgdc/image/upload/v1791137623/360_F_604884254_MGt40Y4wE1gyheD7bTX6wbDZ9afN2njJ_gk0edr.jpg' }
];
const LOGO_LIBRARY = [];

export default class DemoStoryImage extends LightningElement {
    @api label;
    @api value;
    @api kind = 'hero'; // 'hero' | 'avatar' | 'logo'
    @api libraryImages; // optional: override the browse grid (e.g. per-industry pool)
    showGrid = false;
    uploading = false;

    CLOUD = 'dfx98jgdc';
    PRESET = 'salesforcepersonalization';

    get hasValue() { return !!this.value; }
    get uploadLabel() { return this.uploading ? 'Uploading…' : 'Upload an image'; }

    // Upload to Cloudinary (unsigned) so the image gets a durable public URL that
    // works in the preview AND the downloaded HTML.
    async handleFile(e) {
        const file = e.target && e.target.files && e.target.files[0];
        if (!file) return;
        this.uploading = true;
        try {
            const form = new FormData();
            form.append('file', file);
            form.append('upload_preset', this.PRESET);
            const res = await fetch('https://api.cloudinary.com/v1_1/' + this.CLOUD + '/image/upload', { method: 'POST', body: form });
            const data = await res.json();
            if (data && data.secure_url) this.fire(data.secure_url);
        } catch (err) {
            // leave the field as-is on failure; user can paste a URL instead
        } finally {
            this.uploading = false;
        }
    }
    get toggleLabel() { return this.showGrid ? 'Hide library' : 'Browse library'; }
    get hasLibrary() { return this.images.length > 0; }
    get images() {
        // A caller-supplied pool (e.g. the record's industry library) overrides the
        // built-in kind-based collections. Falls back to the shared libraries so the
        // 2-way sims are unaffected.
        if (this.libraryImages && this.libraryImages.length) {
            return this.libraryImages.map((u, i) => ({ id: 'lib-' + i, url: u, description: '' }));
        }
        let src = NBA_IMAGE_LIBRARY;
        if (this.kind === 'avatar') src = AVATAR_LIBRARY;
        else if (this.kind === 'logo') src = LOGO_LIBRARY;
        return (src || []).map((i) => ({ id: i.id, url: i.url, description: i.description }));
    }

    toggleGrid() { this.showGrid = !this.showGrid; }
    handleUrl(e) { this.fire(e.target.value); }
    clearImg() { this.fire(''); }
    pickFromGrid(e) { this.fire(e.currentTarget.dataset.url); this.showGrid = false; }

    fire(url) {
        this.dispatchEvent(new CustomEvent('pick', { detail: { url } }));
    }
}
