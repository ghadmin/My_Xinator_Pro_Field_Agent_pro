/**
 * PDF Form Renderer
 *
 * Following the PDF Implementation Details guide:
 * - ScrollContainer (overflow: auto) → PageContainer (position: relative) → (PageBitmap + Overlay)
 * - Field placement math: boxLeftPx = pageContainer.width * field.position.xPct
 * - No scroll listeners needed - fields scroll with their parent
 */

class PdfFormRenderer {
    constructor(containerId, options = {}) {
        this.container = document.getElementById(containerId);
        this.pdfDoc = null;
        this.pageContainers = [];
        this.formData = {};
        this.options = {
            dpi: options.dpi || 150,
            backgroundColor: options.backgroundColor || '#FFFFFF',
            onFormChanged: options.onFormChanged || (() => {}),
            readOnly: options.readOnly || false
        };
    }

    /**
     * Render a PDF form with fields
     *
     * @param {Uint8Array} pdfBytes - PDF file as bytes
     * @param {Object} template - Form template with fields
     * @param {Object} smartFieldValues - Smart field values map
     * @param {Object} initialFormData - Initial form data
     */
    async renderForm(pdfBytes, template, smartFieldValues = {}, initialFormData = {}) {
        try {
            this.showLoading('Loading PDF...');

            // Load PDF document
            const pdfLib = window.pdfLib;
            if (!pdfLib) {
                throw new Error('PDF library not loaded. Please include pdf-lib.min.js');
            }

            this.pdfDoc = await pdfLib.PDFDocument.load(pdfBytes);
            const totalPages = this.pdfDoc.getPageCount();

            // Store form data
            this.formData = { ...initialFormData };
            this.template = template;
            this.smartFieldValues = smartFieldValues;

            // Clear container
            this.container.innerHTML = '';
            this.pageContainers = [];

            // Render each page
            for (let pageNum = 0; pageNum < totalPages; pageNum++) {
                await this.renderPage(pageNum, totalPages);
            }

            this.hideLoading();
            this.options.onFormChanged(this.formData);
        } catch (error) {
            console.error('Error rendering form:', error);
            this.hideLoading();
            throw error;
        }
    }

    /**
     * Render a single PDF page
     *
     * @param {number} pageNum - Page number (0-indexed)
     * @param {number} totalPages - Total number of pages
     */
    async renderPage(pageNum, totalPages) {
        // Create PageContainer
        const pageContainer = this.createPageContainer(pageNum, totalPages);
        this.container.appendChild(pageContainer);
        this.pageContainers.push(pageContainer);

        // Render PDF page as image
        const pageImage = await this.renderPdfPageAsImage(pageNum);

        // Create PageBitmap layer
        const pageBitmap = this.createPageBitmap(pageImage);
        pageContainer.appendChild(pageBitmap);

        // Create Overlay layer
        const overlay = this.createOverlay(pageNum);
        pageContainer.appendChild(overlay);

        // Render fields for this page
        const pageFields = this.template.getFieldsForPage ?
            this.template.getFieldsForPage(pageNum + 1) :
            this.template.fields.filter(f => f.page === pageNum + 1);

        pageFields.forEach(field => {
            const fieldBox = this.createFieldBox(field, overlay);
            overlay.appendChild(fieldBox);
        });

        // Set container size after image loads
        pageImage.onload = () => {
            const width = pageImage.width;
            const height = pageImage.height;
            pageContainer.style.width = `${width}px`;
            pageContainer.style.height = `${height}px`;
        };
    }

    /**
     * Create a PageContainer
     *
     * Following PDF Implementation Details:
     * - position: relative
     * - width & height = rendered page in pixels
     */
    createPageContainer(pageNum, totalPages) {
        const container = document.createElement('div');
        container.className = 'pdfb-page';
        container.dataset.pageNumber = pageNum + 1;
        container.dataset.totalPages = totalPages;
        return container;
    }

    /**
     * Create PageBitmap layer
     *
     * The rendered PDF page image
     */
    createPageBitmap(imageElement) {
        const bitmap = document.createElement('div');
        bitmap.className = 'pdfb-page-canvas';
        bitmap.appendChild(imageElement);
        return bitmap;
    }

    /**
     * Create Overlay layer
     *
     * Following PDF Implementation Details:
     * - position: absolute
     * - top: 0, left: 0
     * - SAME width/height as bitmap
     */
    createOverlay(pageNum) {
        const overlay = document.createElement('div');
        overlay.className = 'pdfb-overlay';
        overlay.dataset.pageNumber = pageNum + 1;
        return overlay;
    }

    /**
     * Render PDF page as image element
     */
    async renderPdfPageAsImage(pageNum) {
        const page = this.pdfDoc.getPage(pageNum + 1);
        const { width, height } = page.getSize();

        // Create canvas for rendering
        const canvas = document.createElement('canvas');
        const scale = this.options.dpi / 72; // Convert DPI to scale
        canvas.width = width * scale;
        canvas.height = height * scale;

        const context = canvas.getContext('2d');
        context.fillStyle = this.options.backgroundColor;
        context.fillRect(0, 0, canvas.width, canvas.height);

        // Render PDF page to canvas
        const renderContext = {
            canvasContext: context,
            viewport: page.getViewport({ scale })
        };

        await page.render(renderContext).promise;

        // Convert to image
        const img = document.createElement('img');
        img.className = 'pdf-page-image';
        img.src = canvas.toDataURL('image/jpeg', 0.95);
        img.crossOrigin = 'anonymous';

        return img;
    }

    /**
     * Create a field box
     *
     * Field placement math from PDF Implementation Details:
     * boxLeftPx = pageContainer.width * field.position.xPct
     * boxTopPx = pageContainer.height * field.position.yPct
     * boxWidthPx = pageContainer.width * field.position.wPct
     * boxHeightPx = pageContainer.height * field.position.hPct
     */
    createFieldBox(field, overlay) {
        const container = overlay.parentElement;

        const box = document.createElement('div');
        box.className = 'pdfb-field-box';
        box.dataset.fieldId = field.id;
        box.dataset.fieldType = field.type;

        // Position using percentage math (will be converted to pixels after container size is known)
        const position = field.position || {};

        // Wait for container to have size, then position the field
        setTimeout(() => {
            const pageWidth = container.offsetWidth;
            const pageHeight = container.offsetHeight;

            const boxLeftPx = pageWidth * (position.xPct || 0) / 100;
            const boxTopPx = pageHeight * (position.yPct || 0) / 100;
            const boxWidthPx = pageWidth * (position.wPct || 100) / 100;
            const boxHeightPx = pageHeight * (position.hPct || 10) / 100;

            box.style.left = `${boxLeftPx}px`;
            box.style.top = `${boxTopPx}px`;
            box.style.width = `${boxWidthPx}px`;
            box.style.height = `${boxHeightPx}px`;
        }, 100);

        // Create field input based on type
        const fieldElement = this.createFieldElement(field);
        box.appendChild(fieldElement);

        return box;
    }

    /**
     * Create the actual input element for a field
     */
    createFieldElement(field) {
        const value = this.formData[field.id] || field.defaultValue || '';

        switch (field.type?.toLowerCase()) {
            case 'text':
            case 'textfield':
                return this.createTextField(field, value);

            case 'textarea':
                return this.createTextAreaField(field, value);

            case 'dropdown':
                return this.createDropdownField(field, value);

            case 'checkbox':
            case 'check':
                return this.createCheckboxField(field, value);

            case 'signature':
                return this.createSignatureField(field, value);

            case 'smartfield':
                return this.createSmartField(field, value);

            case 'partstable':
                return this.createPartsTableField(field, value);

            default:
                return this.createTextField(field, value);
        }
    }

    createTextField(field, value) {
        const input = document.createElement('input');
        input.type = 'text';
        input.value = value;
        input.placeholder = field.header || '';
        input.readOnly = this.options.readOnly;
        input.addEventListener('input', (e) => {
            this.updateFieldValue(field.id, e.target.value);
        });
        return input;
    }

    createTextAreaField(field, value) {
        const textarea = document.createElement('textarea');
        textarea.value = value;
        textarea.placeholder = field.header || '';
        textarea.readOnly = this.options.readOnly;
        textarea.addEventListener('input', (e) => {
            this.updateFieldValue(field.id, e.target.value);
        });
        return textarea;
    }

    createDropdownField(field, value) {
        const select = document.createElement('select');
        select.disabled = this.options.readOnly;

        const options = field.dropdownOptions || [];
        options.forEach(optionValue => {
            const option = document.createElement('option');
            option.value = optionValue;
            option.textContent = optionValue;
            if (optionValue === value) {
                option.selected = true;
            }
            select.appendChild(option);
        });

        select.addEventListener('change', (e) => {
            this.updateFieldValue(field.id, e.target.value);
        });

        return select;
    }

    createCheckboxField(field, value) {
        const checkbox = document.createElement('input');
        checkbox.type = 'checkbox';
        checkbox.checked = value === true || value === 'true';
        checkbox.disabled = this.options.readOnly;
        checkbox.addEventListener('change', (e) => {
            this.updateFieldValue(field.id, e.target.checked);
        });
        return checkbox;
    }

    createSignatureField(field, value) {
        const container = document.createElement('div');
        container.className = 'signature-field';

        if (value) {
            const img = document.createElement('img');
            img.src = value;
            img.className = 'signature-image';
            container.appendChild(img);
            container.classList.add('signed');
        } else {
            const placeholder = document.createElement('div');
            placeholder.className = 'signature-placeholder';
            placeholder.innerHTML = `
                <svg xmlns="http://www.w3.org/2000/svg" width="32" height="32" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                    <path d="M12 19l7-7 3 3-7 7-3-3z"/>
                    <path d="M18 13l-1.5-7.5L2 2l3.5 14.5L13 18l5-5z"/>
                    <path d="M2 2l7.586 7.586"/>
                    <circle cx="11" cy="11" r="2"/>
                </svg>
                <div>${this.options.readOnly ? 'Signature Required' : 'Tap to Sign'}</div>
            `;
            container.appendChild(container);
        }

        if (!this.options.readOnly) {
            container.style.cursor = 'pointer';
            container.addEventListener('click', () => {
                this.openSignatureModal(field.id);
            });
        }

        return container;
    }

    createSmartField(field, value) {
        const container = document.createElement('div');
        container.className = 'smart-field';

        // Look up by field.id, NOT by smartFieldSource
        const smartValue = this.smartFieldValues[field.id] || value || '';

        const input = document.createElement('input');
        input.type = 'text';
        input.value = smartValue;
        input.readOnly = true;
        input.placeholder = field.header || '';

        container.appendChild(input);
        return container;
    }

    createPartsTableField(field, value) {
        const container = document.createElement('div');
        container.className = 'parts-table-field';

        const table = document.createElement('table');
        table.className = 'parts-table';

        const thead = document.createElement('thead');
        thead.innerHTML = `
            <tr>
                <th>Qty</th>
                <th>Description</th>
                ${!this.options.readOnly ? '<th></th>' : ''}
            </tr>
        `;

        const tbody = document.createElement('tbody');
        const rows = Array.isArray(value) ? value : [{ qty: '', description: '' }];

        const renderRows = () => {
            tbody.innerHTML = '';
            rows.forEach((row, index) => {
                const tr = document.createElement('tr');
                tr.innerHTML = `
                    <td><input type="text" value="${row.qty || ''}" data-idx="${index}" data-field="qty"></td>
                    <td><input type="text" value="${row.description || ''}" data-idx="${index}" data-field="description"></td>
                    ${!this.options.readOnly ? `<td><button class="remove-row-btn" data-idx="${index}">×</button></td>` : ''}
                `;
                tbody.appendChild(tr);
            });
        };

        renderRows();

        if (!this.options.readOnly) {
            tbody.addEventListener('input', (e) => {
                if (e.target.tagName === 'INPUT') {
                    const idx = parseInt(e.target.dataset.idx);
                    const fieldName = e.target.dataset.field;
                    rows[idx][fieldName] = e.target.value;
                    this.updateFieldValue(field.id, rows);
                }
            });

            tbody.addEventListener('click', (e) => {
                if (e.target.classList.contains('remove-row-btn')) {
                    const idx = parseInt(e.target.dataset.idx);
                    if (rows.length > 1) {
                        rows.splice(idx, 1);
                        renderRows();
                        this.updateFieldValue(field.id, rows);
                    }
                }
            });
        }

        table.appendChild(thead);
        table.appendChild(tbody);
        container.appendChild(table);

        if (!this.options.readOnly) {
            const addBtn = document.createElement('button');
            addBtn.className = 'add-row-btn';
            addBtn.textContent = '+ Add Row';
            addBtn.style.marginTop = '8px';
            addBtn.addEventListener('click', () => {
                rows.push({ qty: '', description: '' });
                renderRows();
                this.updateFieldValue(field.id, rows);
            });
            container.appendChild(addBtn);
        }

        return container;
    }

    updateFieldValue(fieldId, value) {
        this.formData[fieldId] = value;
        this.options.onFormChanged(this.formData);
    }

    openSignatureModal(fieldId) {
        const modal = document.getElementById('signature-modal');
        const canvas = document.getElementById('signature-canvas');

        modal.classList.add('show');
        modal.style.display = 'flex';

        // Initialize signature pad
        if (window.SignaturePad) {
            const sigPad = new SignaturePad(canvas);
            canvas.signaturePad = sigPad;

            document.getElementById('save-signature').onclick = () => {
                const dataUrl = sigPad.toDataURL();
                this.updateFieldValue(fieldId, dataUrl);
                modal.classList.remove('show');
                modal.style.display = 'none';
                sigPad.clear();

                // Re-render the field
                setTimeout(() => {
                    const fieldBox = document.querySelector(`[data-field-id="${fieldId}"]`);
                    if (fieldBox) {
                        fieldBox.innerHTML = '';
                        const newSignature = this.createSignatureField(
                            { id: fieldId, type: 'signature', header: '' },
                            dataUrl
                        );
                        fieldBox.appendChild(newSignature);
                    }
                }, 100);
            };

            document.getElementById('clear-signature').onclick = () => {
                sigPad.clear();
            };
        }
    }

    showLoading(message) {
        const overlay = document.getElementById('loading-overlay');
        const text = document.getElementById('loading-text');
        text.textContent = message;
        overlay.classList.add('show');
    }

    hideLoading() {
        const overlay = document.getElementById('loading-overlay');
        overlay.classList.remove('show');
    }

    getFormData() {
        return this.formData;
    }
}

// Export for use in other modules
if (typeof module !== 'undefined' && module.exports) {
    module.exports = PdfFormRenderer;
}
