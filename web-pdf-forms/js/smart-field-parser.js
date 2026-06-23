/**
 * Smart Field Parser
 *
 * Following the Smart Field Issue Solution PDF:
 * - smartFieldData is a sibling property to template.structure
 * - Both are JSON strings that need to be parsed
 * - Smart field values are keyed by field.id (e.g., "pdf_1776450913261_56q93m")
 * - NOT by smartFieldSource (e.g., "system.CompanyName")
 */

class SmartFieldParser {
    /**
     * Parse smart field data from API response
     *
     * @param {string} smartFieldDataJson - JSON string from smartFieldData field
     * @returns {Object} Map of field.id -> value
     */
    static parseSmartFieldData(smartFieldDataJson) {
        try {
            if (!smartFieldDataJson || smartFieldDataJson.trim() === '{}') {
                console.log('⚠️ No smartFieldData provided');
                return {};
            }

            const smartFieldData = JSON.parse(smartFieldDataJson);
            console.log('✅ Parsed smartFieldData:', Object.keys(smartFieldData));
            return smartFieldData;
        } catch (e) {
            console.error('❌ Error parsing smartFieldData:', e);
            return {};
        }
    }

    /**
     * Parse template structure to extract field definitions
     *
     * @param {string} templateStructureJson - JSON string from template.structure field
     * @returns {Object} Map of field.id -> field definition
     */
    static parseTemplateStructure(templateStructureJson) {
        try {
            if (!templateStructureJson || templateStructureJson.trim() === '{}') {
                console.log('⚠️ No template structure provided');
                return {};
            }

            const structureData = JSON.parse(templateStructureJson);
            const fields = structureData.fields || [];

            const fieldMap = {};
            fields.forEach(field => {
                if (field.id) {
                    fieldMap[field.id] = field;
                }
            });

            console.log(`✅ Parsed template structure: ${Object.keys(fieldMap).length} fields`);
            return fieldMap;
        } catch (e) {
            console.error('❌ Error parsing template structure:', e);
            return {};
        }
    }

    /**
     * Get smart field value for a specific field
     *
     * Looks up by field.id (e.g., "pdf_1776450913261_56q93m")
     * NOT by smartFieldSource (e.g., "system.CompanyName")
     *
     * @param {Object} field - Field definition
     * @param {Object} smartFieldValues - Map of field.id -> value
     * @returns {string} The smart field value or empty string
     */
    static getSmartFieldValue(field, smartFieldValues) {
        if (!field || !field.id) {
            return '';
        }

        // Look up by field.id, NOT by smartFieldSource
        const value = smartFieldValues[field.id] || '';

        if (field.type === 'smartfield' && value) {
            console.log(`📋 Smart field ${field.id} = "${value}"`);
        }

        return value;
    }

    /**
     * Merge smart field values with app-level defaults
     *
     * @param {Object} apiSmartFields - Smart fields from API (smartFieldData)
     * @param {Object} appSmartFields - App-level smart fields (technician, date, etc.)
     * @returns {Object} Merged smart field values
     */
    static mergeSmartFields(apiSmartFields, appSmartFields) {
        // API smart fields take precedence
        return {
            ...appSmartFields,
            ...apiSmartFields
        };
    }

    /**
     * Get app-level smart field values
     *
     * @param {Object} context - Form context (form instance, appointment, etc.)
     * @returns {Object} App-level smart field values
     */
    static getAppSmartFields(context) {
        return {
            technician_name: context.technicianName || 'Unknown',
            technician_id: context.technicianId || '',
            company_id: context.companyId || '',
            appointment_id: context.appointmentId || '',
            form_instance_id: context.formInstanceId || '',
            template_id: context.templateId || '',
            customer_id: context.customerId || '',
            queue_id: context.queueId || '',
            date: new Date().toISOString().split('T')[0], // YYYY-MM-DD
            datetime: new Date().toISOString(),
        };
    }
}

// Export for use in other modules
if (typeof module !== 'undefined' && module.exports) {
    module.exports = SmartFieldParser;
}
