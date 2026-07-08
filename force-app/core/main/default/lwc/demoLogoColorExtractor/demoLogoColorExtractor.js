import { LightningElement } from 'lwc';
export default class DemoLogoColorExtractor extends LightningElement {}

// Client-side logo color extractor.
//
// Given a logo URL, loads the image through a CORS-friendly proxy
// (images.weserv.nl), draws it to a hidden canvas, samples pixels,
// buckets similar colors, and returns the top-2 dominant colors that
// aren't near-white, near-black, or near-transparent.
//
// Used by Brand Kit Studio to derive brand colors from the actual logo
// image — deterministic, factual, way more accurate than asking an LLM
// to remember which shade of yellow Edward Jones uses.

const PROXY_BASE = 'https://images.weserv.nl/?url=';

function stripProtocol(url) {
    return (url || '').replace(/^https?:\/\//, '');
}

function proxied(url) {
    return PROXY_BASE + encodeURIComponent(stripProtocol(url));
}

// Load an image element, wait for it, resolve to the element. Rejects on error/timeout.
function loadImage(src, timeoutMs = 6000) {
    return new Promise((resolve, reject) => {
        const img = new Image();
        img.crossOrigin = 'anonymous';
        let done = false;
        const timer = setTimeout(() => {
            if (done) return;
            done = true;
            reject(new Error('logo load timeout'));
        }, timeoutMs);
        img.onload = () => {
            if (done) return;
            done = true;
            clearTimeout(timer);
            resolve(img);
        };
        img.onerror = () => {
            if (done) return;
            done = true;
            clearTimeout(timer);
            reject(new Error('logo load error'));
        };
        img.src = src;
    });
}

function rgbToHex(r, g, b) {
    const h = (n) => Math.max(0, Math.min(255, Math.round(n))).toString(16).padStart(2, '0');
    return ('#' + h(r) + h(g) + h(b)).toUpperCase();
}

function rgbLuminance(r, g, b) {
    return (0.299 * r + 0.587 * g + 0.114 * b) / 255;
}

// Reject colors that are functionally white/black/gray-neutral so we get
// the actual brand colors, not the background.
function isMeaningfulColor(r, g, b) {
    const lum = rgbLuminance(r, g, b);
    if (lum > 0.94) return false; // near-white
    if (lum < 0.06) return false; // near-black
    const max = Math.max(r, g, b);
    const min = Math.min(r, g, b);
    if (max - min < 20) return false; // near-neutral gray
    return true;
}

// Quantize RGB to a 5-bit-per-channel bucket key so shades of the same color group up.
function bucketKey(r, g, b) {
    return `${r >> 3}-${g >> 3}-${b >> 3}`;
}
function bucketToRgb(key) {
    const [r, g, b] = key.split('-').map(Number);
    // Center of the bucket
    return { r: (r << 3) + 4, g: (g << 3) + 4, b: (b << 3) + 4 };
}

// Return {primary, accent} hex strings or null if extraction fails.
export async function extractDominantColors(logoUrl) {
    if (!logoUrl) return null;
    // Try proxied first (CORS-safe). Fall back to raw URL (may still work
    // for same-origin uploads via /sfc/servlet.shepherd).
    const attempts = logoUrl.startsWith('/sfc/servlet.shepherd')
        ? [logoUrl]
        : [proxied(logoUrl), logoUrl];

    for (const src of attempts) {
        try {
            const img = await loadImage(src);
            const result = sampleImage(img);
            if (result) return result;
        } catch (e) {
            // Try next attempt
        }
    }
    return null;
}

function sampleImage(img) {
    const w = img.naturalWidth || img.width || 0;
    const h = img.naturalHeight || img.height || 0;
    if (!w || !h) return null;

    // Downscale to keep the pixel loop fast (200-ish pixels max on the long side)
    const maxDim = 200;
    const scale = Math.min(1, maxDim / Math.max(w, h));
    const canvas = document.createElement('canvas');
    canvas.width = Math.max(1, Math.round(w * scale));
    canvas.height = Math.max(1, Math.round(h * scale));
    const ctx = canvas.getContext('2d');
    if (!ctx) return null;

    try {
        ctx.drawImage(img, 0, 0, canvas.width, canvas.height);
    } catch (e) {
        return null;
    }

    let data;
    try {
        data = ctx.getImageData(0, 0, canvas.width, canvas.height).data;
    } catch (e) {
        // Tainted canvas — CORS blocked us
        return null;
    }

    const buckets = new Map(); // bucketKey → weight (count)
    for (let i = 0; i < data.length; i += 4) {
        const r = data[i], g = data[i + 1], b = data[i + 2], a = data[i + 3];
        if (a < 128) continue; // skip transparent
        if (!isMeaningfulColor(r, g, b)) continue;
        const key = bucketKey(r, g, b);
        buckets.set(key, (buckets.get(key) || 0) + 1);
    }

    if (buckets.size === 0) return null;

    // Rank buckets by count, pick top; ensure the two picks are visually different.
    const ranked = Array.from(buckets.entries()).sort((a, b) => b[1] - a[1]);
    const primary = bucketToRgb(ranked[0][0]);
    let accent = null;
    for (let i = 1; i < ranked.length; i++) {
        const cand = bucketToRgb(ranked[i][0]);
        // Require some perceptual distance so we don't return two near-identical shades
        const dr = cand.r - primary.r, dg = cand.g - primary.g, db = cand.b - primary.b;
        const dist = Math.sqrt(dr * dr + dg * dg + db * db);
        if (dist > 60) { accent = cand; break; }
    }
    if (!accent) {
        // Fall back to a darkened version of the primary
        accent = { r: primary.r * 0.55, g: primary.g * 0.55, b: primary.b * 0.55 };
    }

    return {
        primary: rgbToHex(primary.r, primary.g, primary.b),
        accent:  rgbToHex(accent.r, accent.g, accent.b)
    };
}
