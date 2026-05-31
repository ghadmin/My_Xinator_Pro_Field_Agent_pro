/**
 * Smart Field PDF Form Filling Application
 *
 * Main application controller that handles:
 * - API integration for fetching forms and smart field data
 * - Form rendering and submission
 * - Validation and progress tracking
 */

class PdfFormApp {
    constructor() {
        this.renderer = null;
        this.currentForm = null;
        this.formData = {};
        this.smartFieldValues = {};

        this.init();
    }

    init() {
        // Initialize UI event listeners
        this.initEventListeners();

        // Load form data from URL parameters or demo data
        this.loadFormData();
    }

    initEventListeners() {
        // Save draft button
        document.getElementById('save-draft-btn').addEventListener('click', () => {
            this.saveDraft();
        });

        // Submit button
        document.getElementById('submit-btn').addEventListener('click', () => {
            this.submitForm();
        });

        // Signature modal close
        document.getElementById('close-signature-modal').addEventListener('click', () => {
            const modal = document.getElementById('signature-modal');
            modal.classList.remove('show');
            modal.style.display = 'none';
        });

        // Close modal on outside click
        document.getElementById('signature-modal').addEventListener('click', (e) => {
            if (e.target.id === 'signature-modal') {
                e.target.classList.remove('show');
                e.target.style.display = 'none';
            }
        });
    }

    async loadFormData() {
        try {
            // Check for form data in URL parameters
            const urlParams = new URLSearchParams(window.location.search);
            const formId = urlParams.get('formId');
            const templateId = urlParams.get('templateId');

            if (formId && templateId) {
                // Load from API
                await this.loadFromApi(formId, templateId);
            } else {
                // Load demo data
                await this.loadDemoData();
            }
        } catch (error) {
            console.error('Error loading form data:', error);
            this.showError('Failed to load form: ' + error.message);
        }
    }

    async loadFromApi(formId, templateId) {
        // Show loading
        this.showLoading('Fetching form template...');

        try {
            // Fetch form data from your API
            const companyId = this.getCompanyId();

            // Fetch template
            const templateResponse = await fetch(`/api/forms/template/${templateId}?companyId=${companyId}`);
            const templateData = await templateResponse.json();

            // Fetch smart field data
            const smartFieldResponse = await fetch(`/api/forms/smart-fields/${formId}?companyId=${companyId}`);
            const smartFieldData = await smartFieldResponse.json();

            // Fetch PDF
            const pdfResponse = await fetch(`/api/forms/pdf/${templateId}?companyId=${companyId}`);
            const pdfBytes = await pdfResponse.arrayBuffer();

            // Parse data
            const template = this.parseTemplate(templateData);
            const smartFieldValues = SmartFieldParser.parseSmartFieldData(
                smartFieldData.smartFieldData || '{}'
            );

            // Render form
            await this.renderForm(new Uint8Array(pdfBytes), template, smartFieldValues);

        } catch (error) {
            console.error('Error loading from API:', error);
            throw error;
        }
    }

    async loadDemoData() {
        this.showLoading('Loading demo form...');

        // Simulate API delay
        await this.delay(1000);

        // Demo template structure
        const demoTemplate = {
            pdfPath: '/demo-form.pdf',
            totalPages: 1,
            fields: [
                {
                    id: 'pdf_1776450913261_56q93m',
                    type: 'smartfield',
                    header: 'Company Name',
                    smartFieldSource: 'system.CompanyName',
                    position: { xPct: 10, yPct: 15, wPct: 30, hPct: 5 },
                    page: 1
                },
                {
                    id: 'pdf_1776450936990_00x6c4',
                    type: 'smartfield',
                    header: 'Technician Name',
                    smartFieldSource: 'resource.Name',
                    position: { xPct: 10, yPct: 22, wPct: 30, hPct: 5 },
                    page: 1
                },
                {
                    id: 'pdf_1776451110655_lcbuk7',
                    type: 'text',
                    header: 'Customer Name',
                    position: { xPct: 10, yPct: 29, wPct: 30, hPct: 5 },
                    page: 1
                },
                {
                    id: 'pdf_1776451134538_txrlt7',
                    type: 'text',
                    header: 'Email',
                    position: { xPct: 10, yPct: 36, wPct: 30, hPct: 5 },
                    page: 1
                },
                {
                    id: 'pdf_1776451161804_m4ytb4',
                    type: 'textarea',
                    header: 'Work Description',
                    position: { xPct: 10, yPct: 43, wPct: 50, hPct: 15 },
                    page: 1
                },
                {
                    id: 'pdf_1778168910835_wyx0g6',
                    type: 'signature',
                    header: 'Technician Signature',
                    position: { xPct: 10, yPct: 60, wPct: 25, hPct: 12 },
                    page: 1
                }
            ]
        };

        // Demo smart field values (as they come from smartFieldData)
        const demoSmartFieldValues = {
            'pdf_1776450913261_56q93m': 'msProDemo',
            'pdf_1776450936990_00x6c4': 'John Doe'
        };

        // Get fields for page helper
        demoTemplate.getFieldsForPage = (pageNum) => {
            return demoTemplate.fields.filter(f => f.page === pageNum);
        };

        // For demo, create a simple PDF-like background
        const pdfBytes = await this.createDemoPdf();

        await this.renderForm(pdfBytes, demoTemplate, demoSmartFieldValues);
    }

    async createDemoPdf() {
        // Create a simple canvas to represent the PDF page
        const canvas = document.createElement('canvas');
        const ctx = canvas.getContext('2d');

        // US Letter size at 150 DPI
        const dpi = 150;
        const width = 8.5 * dpi;
        const height = 11 * dpi;

        canvas.width = width;
        canvas.height = height;

        // White background
        ctx.fillStyle = '#FFFFFF';
        ctx.fillRect(0, 0, width, height);

        // Add some demo content
        ctx.fillStyle = '#CCCCCC';
        ctx.font = '24px Arial';
        ctx.fillText('DEMO SERVICE FORM', 50, 100);

        ctx.fillStyle = '#999999';
        ctx.font = '14px Arial';
        ctx.fillText('Company: ____________________', 50, 250);
        ctx.fillText('Technician: ____________________', 50, 350);
        ctx.fillText('Customer Name: __________________', 50, 450);
        ctx.fillText('Email: __________________________', 50, 550);
        ctx.fillText('Work Description:', 50, 650);
        ctx.strokeRect(50, 670, 600, 300);
        ctx.fillText('Technician Signature: ___________', 50, 1050);

        // Convert to bytes
        const dataUrl = canvas.toDataURL('image/jpeg', 0.95);
        const response = await fetch(dataUrl);
        const blob = await response.blob();
        return new Uint8Array(await blob.arrayBuffer());
    }

    async renderForm(pdfBytes, template, smartFieldValues) {
        // Update header
        document.getElementById('form-title').textContent = template.name || 'Service Form';
        document.getElementById('form-description').textContent = template.description || '';

        // Store form data
        this.currentForm = template;
        this.smartFieldValues = smartFieldValues;

        // Initialize renderer
        this.renderer = new PdfFormRenderer('pdf-container', {
            dpi: 150,
            backgroundColor: '#FFFFFF',
            onFormChanged: (formData) => {
                this.formData = formData;
                this.updateProgress();
            }
        });

        // Render the form
        await this.renderer.renderForm(pdfBytes, template, smartFieldValues);

        this.hideLoading();
    }

    parseTemplate(templateData) {
        // Parse template structure if it's a JSON string
        if (typeof templateData.structure === 'string') {
            templateData.structure = JSON.parse(templateData.structure);
        }

        // Add getFieldsForPage helper
        templateData.getFieldsForPage = (pageNum) => {
            return templateData.fields.filter(f => f.page === pageNum);
        };

        return templateData;
    }

    updateProgress() {
        if (!this.currentForm || !this.currentForm.fields) return;

        const totalFields = this.currentForm.fields.length;
        const filledFields = this.currentForm.fields.filter(field => {
            const value = this.formData[field.id];
            return value !== null && value !== undefined && value !== '';
        }).length;

        const percentage = Math.round((filledFields / totalFields) * 100);

        const indicator = document.querySelector('.completion-text');
        if (indicator) {
            indicator.textContent = `${percentage}%`;

            // Change color based on completion
            if (percentage === 100) {
                indicator.style.color = '#28a745';
            } else {
                indicator.style.color = '#667eea';
            }
        }

        // Enable/disable submit button
        const submitBtn = document.getElementById('submit-btn');
        if (submitBtn) {
            submitBtn.disabled = percentage < 100;
        }
    }

    validateForm() {
        const errors = [];

        if (!this.currentForm || !this.currentForm.fields) return errors;

        this.currentForm.fields.forEach(field => {
            const value = this.formData[field.id];

            // Check required fields
            if (field.header && field.header.toLowerCase().includes('required')) {
                if (!value || value.toString().trim() === '') {
                    errors.push(`${field.header} is required`);
                }
            }

            // Signature required
            if (field.type === 'signature' && (!value || value.toString().trim() === '')) {
                errors.push('Signature is required');
            }

            // Parts table must have at least one row
            if (field.type === 'partstable') {
                const tableData = Array.isArray(value) ? value : [];
                if (tableData.length === 0) {
                    errors.push(`${field.header || 'Parts table'} must have at least one row`);
                }
            }
        });

        return errors;
    }

    showValidationErrors(errors) {
        const errorContainer = document.getElementById('validation-errors');
        const errorList = document.getElementById('error-list');

        errorList.innerHTML = '';
        errors.forEach(error => {
            const li = document.createElement('li');
            li.textContent = error;
            errorList.appendChild(li);
        });

        errorContainer.classList.add('show');

        // Auto-hide after 5 seconds
        setTimeout(() => {
            errorContainer.classList.remove('show');
        }, 5000);
    }

    async saveDraft() {
        this.showLoading('Saving draft...');

        try {
            // Simulate API call
            await this.delay(1000);

            console.log('Draft saved:', this.formData);

            this.hideLoading();
            this.showSuccess('Draft saved successfully');

        } catch (error) {
            console.error('Error saving draft:', error);
            this.hideLoading();
            this.showError('Failed to save draft');
        }
    }

    async submitForm() {
        // Validate first
        const errors = this.validateForm();

        if (errors.length > 0) {
            this.showValidationErrors(errors);
            return;
        }

        this.showLoading('Submitting form...');

        try {
            // Prepare submission data
            const submitData = {
                formInstanceId: this.getFormInstanceId(),
                templateId: this.getTemplateId(),
                appointmentId: this.getAppointmentId(),
                responses: this.prepareResponses(),
                submittedAt: new Date().toISOString()
            };

            // Simulate API call
            await this.delay(2000);

            console.log('Form submitted:', submitData);

            this.hideLoading();
            this.showSuccess('Form submitted successfully!');

            // Optionally redirect or close window
            // setTimeout(() => window.close(), 2000);

        } catch (error) {
            console.error('Error submitting form:', error);
            this.hideLoading();
            this.showError('Failed to submit form');
        }
    }

    prepareResponses() {
        if (!this.currentForm || !this.currentForm.fields) return [];

        return this.currentForm.fields.map(field => {
            const value = this.formData[field.id];

            return {
                fieldId: field.id,
                label: field.header || field.label || 'Field',
                type: field.type,
                value: value || '',
                position: field.position
            };
        });
    }

    // Helper methods
    getCompanyId() {
        return localStorage.getItem('companyId') || 'demo-company';
    }

    getFormInstanceId() {
        const urlParams = new URLSearchParams(window.location.search);
        return urlParams.get('formId') || 'demo-instance';
    }

    getTemplateId() {
        const urlParams = new URLSearchParams(window.location.search);
        return urlParams.get('templateId') || '57';
    }

    getAppointmentId() {
        const urlParams = new URLSearchParams(window.location.search);
        return urlParams.get('appointmentId') || 'demo-appointment';
    }

    showLoading(message) {
        const overlay = document.getElementById('loading-overlay');
        const text = document.getElementById('loading-text');
        text.textContent = message;
        overlay.classList.add('show');

        const progressBar = document.getElementById('loading-progress');
        if (progressBar) progressBar.classList.add('active');
    }

    hideLoading() {
        const overlay = document.getElementById('loading-overlay');
        overlay.classList.remove('show');

        const progressBar = document.getElementById('loading-progress');
        if (progressBar) progressBar.classList.remove('active');
    }

    showSuccess(message) {
        // Simple alert for now - could be replaced with a toast notification
        alert(message);
    }

    showError(message) {
        // Simple alert for now - could be replaced with a toast notification
        alert('Error: ' + message);
    }

    delay(ms) {
        return new Promise(resolve => setTimeout(resolve, ms));
    }
}

// Initialize app when DOM is ready
document.addEventListener('DOMContentLoaded', () => {
    window.pdfFormApp = new PdfFormApp();
});
