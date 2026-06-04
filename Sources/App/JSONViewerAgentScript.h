// JSONViewerAgentScript.h
// Automatically injected into pages to render a beautiful JSON UI when an API response is detected.

#pragma once
#include "include/internal/cef_string.h"

static const char kSoulJSONViewerAgent[] = R"SCRIPT(
(function() {
    // Only run once per page
    if (window.__soulJSONViewerInitialized) return;
    window.__soulJSONViewerInitialized = true;

    function init() {
        const isJsonType = document.contentType === 'application/json' || document.contentType === 'text/json';
        const isPreOnly = document.body && document.body.children.length === 1 && document.body.children[0].tagName === 'PRE';
        
        if (!isJsonType && !isPreOnly) return;

        let rawText = '';
        let preElement = null;

        if (isPreOnly) {
            preElement = document.body.children[0];
            rawText = preElement.textContent;
        } else if (document.body && document.body.textContent) {
            rawText = document.body.textContent;
        }

        if (!rawText || rawText.trim().length === 0) return;

        let jsonData;
        try {
            jsonData = JSON.parse(rawText);
        } catch (e) {
            return; // Not valid JSON
        }

        // It's valid JSON! Inject CSS.
        const style = document.createElement('style');
        style.textContent = `
            body.soul-json-viewer {
                margin: 0;
                padding: 0;
                font-family: ui-monospace, SFMono-Regular, "SF Mono", Menlo, Consolas, "Liberation Mono", monospace;
                font-size: 13px;
                line-height: 1.5;
                background-color: Canvas;
                color: CanvasText;
                color-scheme: light dark;
                -webkit-font-smoothing: antialiased;
            }
            .j-toolbar {
                position: sticky;
                top: 0;
                background: color-mix(in srgb, Canvas 80%, transparent);
                border-bottom: 1px solid rgba(128,128,128,0.2);
                padding: 10px 20px;
                display: flex;
                gap: 8px;
                backdrop-filter: blur(10px);
                -webkit-backdrop-filter: blur(10px);
                z-index: 100;
            }
            .j-toolbar button {
                background: transparent;
                border: 1px solid rgba(128,128,128,0.2);
                color: CanvasText;
                border-radius: 6px;
                padding: 4px 12px;
                font-size: 12px;
                font-family: -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, Helvetica, Arial, sans-serif;
                font-weight: 500;
                cursor: pointer;
                transition: background 0.1s, border-color 0.1s;
            }
            .j-toolbar button:hover {
                background: rgba(128,128,128,0.1);
                border-color: rgba(128,128,128,0.3);
            }
            .j-toolbar button:active {
                background: rgba(128,128,128,0.15);
            }
            .j-container {
                padding: 20px;
                overflow-wrap: break-word;
            }
            .j-block {
                margin-left: 20px;
                border-left: 1px solid rgba(128,128,128,0.15);
                padding-left: 6px;
            }
            .j-row {
                display: flex;
                align-items: flex-start;
            }
            .j-key {
                color: #9cdcfe;
                margin-right: 6px;
            }
            .j-idx {
                color: rgba(128,128,128,0.7);
            }
            .j-str { color: #ce9178; word-break: break-word; }
            .j-num { color: #b5cea8; }
            .j-bool { color: #569cd6; }
            .j-null { color: #569cd6; font-style: italic; }

            @media (prefers-color-scheme: light) {
                .j-key { color: #0451a5; }
                .j-str { color: #a31515; }
                .j-num { color: #098658; }
                .j-bool { color: #0000ff; }
                .j-null { color: #0000ff; }
            }

            details {
                display: block;
            }
            details > summary {
                cursor: pointer;
                list-style: none;
                display: inline-block;
                user-select: none;
            }
            details > summary::-webkit-details-marker {
                display: none;
            }
            details > summary::before {
                content: '▶';
                font-size: 8px;
                color: rgba(128,128,128,0.6);
                display: inline-block;
                width: 16px;
                text-align: center;
                transition: transform 0.15s;
                vertical-align: middle;
            }
            details[open] > summary::before {
                transform: rotate(90deg);
            }
            .j-arr-len, .j-obj-len {
                color: rgba(128,128,128,0.5);
                font-size: 11px;
                margin-left: 6px;
                font-style: italic;
            }
            #raw-content {
                display: none;
                white-space: pre-wrap;
                padding: 20px;
            }
        `;
        document.head.appendChild(style);
        document.body.classList.add('soul-json-viewer');

        function renderJSON(data) {
            if (data === null) return `<span class="j-null">null</span>`;
            if (typeof data === 'boolean') return `<span class="j-bool">${data}</span>`;
            if (typeof data === 'number') return `<span class="j-num">${data}</span>`;
            if (typeof data === 'string') {
                let escaped = data.replace(/&/g, '&amp;').replace(/</g, '&lt;').replace(/>/g, '&gt;');
                return `<span class="j-str">"${escaped}"</span>`;
            }
            
            if (Array.isArray(data)) {
                if (data.length === 0) return `<span>[]</span>`;
                let html = `<details open><summary><span class="j-arr-len">[ ${data.length} ]</span></summary><div class="j-block">`;
                for (let i=0; i<data.length; i++) {
                    html += `<div class="j-row"><span class="j-key j-idx">${i}:</span> <div>${renderJSON(data[i])}${i < data.length-1 ? ',' : ''}</div></div>`;
                }
                html += `</div></details>`;
                return html;
            }
            
            if (typeof data === 'object') {
                let keys = Object.keys(data);
                if (keys.length === 0) return `<span>{}</span>`;
                let html = `<details open><summary><span class="j-obj-len">{ ${keys.length} }</span></summary><div class="j-block">`;
                for (let i=0; i<keys.length; i++) {
                    let k = keys[i];
                    let escapedK = k.replace(/&/g, '&amp;').replace(/</g, '&lt;').replace(/>/g, '&gt;');
                    html += `<div class="j-row"><span class="j-key">"${escapedK}":</span> <div>${renderJSON(data[k])}${i < keys.length-1 ? ',' : ''}</div></div>`;
                }
                html += `</div></details>`;
                return html;
            }
            
            return '';
        }

        // Build UI
        document.body.innerHTML = '';

        const toolbar = document.createElement('div');
        toolbar.className = 'j-toolbar';

        const toggleBtn = document.createElement('button');
        toggleBtn.textContent = 'Raw';
        
        const collapseBtn = document.createElement('button');
        collapseBtn.textContent = 'Collapse All';
        
        const copyBtn = document.createElement('button');
        copyBtn.textContent = 'Copy';

        toolbar.appendChild(toggleBtn);
        toolbar.appendChild(collapseBtn);
        toolbar.appendChild(copyBtn);
        document.body.appendChild(toolbar);

        const container = document.createElement('div');
        container.className = 'j-container';
        container.innerHTML = renderJSON(jsonData);
        
        const rawContainer = document.createElement('pre');
        rawContainer.id = 'raw-content';
        rawContainer.textContent = rawText;

        document.body.appendChild(container);
        document.body.appendChild(rawContainer);

        // Events
        let isRaw = false;
        toggleBtn.addEventListener('click', () => {
            isRaw = !isRaw;
            toggleBtn.textContent = isRaw ? 'Parsed' : 'Raw';
            container.style.display = isRaw ? 'none' : 'block';
            rawContainer.style.display = isRaw ? 'block' : 'none';
        });

        let isCollapsed = false;
        collapseBtn.addEventListener('click', () => {
            isCollapsed = !isCollapsed;
            collapseBtn.textContent = isCollapsed ? 'Expand All' : 'Collapse All';
            const details = container.querySelectorAll('details');
            details.forEach(d => {
                if (isCollapsed) {
                    d.removeAttribute('open');
                } else {
                    d.setAttribute('open', '');
                }
            });
        });

        copyBtn.addEventListener('click', () => {
            navigator.clipboard.writeText(rawText);
            copyBtn.textContent = 'Copied!';
            setTimeout(() => { copyBtn.textContent = 'Copy'; }, 2000);
        });
    }

    if (document.readyState === 'loading') {
        document.addEventListener('DOMContentLoaded', init);
    } else {
        init();
    }
})();
)SCRIPT";
