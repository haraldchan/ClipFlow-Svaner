class FormValidator {
   	/**
	 * @param {HTMLInputElement | HTMLSelectElement} field
	 * @param {string} message
     * @returns {boolean} true: is expired
	 */
    static validateDate(field, message) {
        const today = new Date()
        today.setHours(0, 0, 0, 0)
        const dateToValidate = new Date(field.value)
        const isExpired = today.getTime() > dateToValidate.getTime()
        if (isExpired) {
            field.setCustomValidity(message)
            field.reportValidity()
        } else {
            field.setCustomValidity('')
        }
        
        return isExpired
    }

   	/**
	 * @param {string} birthday
	 */
    static getAge(birthday) {
        const today = new Date()
        let age = today.getFullYear() - birthday.getFullYear()

        const hasHadBirthday =
            today.getMonth() > birthday.getMonth() ||
            (
                today.getMonth() === birthday.getMonth() &&
                today.getDate() >= birthday.getDate()
            )

        if (!hasHadBirthday) age--
        
        return age
    }

   	/**
	 * @param {HTMLInputElement} field
	 * @param {string} message	 
     * @return {boolean} true: is under 18.
	 */
    static validateBirthday(field, message) {
        if (!field.value) {
            field.setCustomValidity('缺少生日字段，请补全')
            field.reportValidity()
            return true
        }

        const birthday = new Date(field.value)
        const isUnder18 = this.getAge(birthday) < 18

        if (isUnder18) {
            field.setCustomValidity(message)
            field.reportValidity()
        } else {
            field.setCustomValidity('')
        }
        
        return isUnder18
    }

	/**
	 * @param {HTMLFormElement} form
	 */
	static handleFormValidate(form) {
        /** @type {Array<HTMLInputElement | HTMLSelectElement>} */
		const fields = form.elements
        const guestType = Number.isInteger(parseInt(currentData.guestType))
            ? getGuestType(currentData.guestType, currentData.hasOwnProperty('nationalityArea') ? currentData.nationalityArea : '')
            : currentData.guestType

        for (const field of fields) {
			switch (field.name) {
                case 'name':
                    field.required = guestType !== '国外旅客'
                    if (!field.checkValidity()) field.reportValidity()
                    field.classList.toggle('field-invalid', !field.checkValidity())
                    break

                case 'firstName':
                case 'lastName':
                    field.required = guestType !== '内地旅客'
                    if (!field.checkValidity()) field.reportValidity()
                    field.classList.toggle('field-invalid', !field.checkValidity())
                    break

                case 'region':
                    if (!field.checkValidity()) field.reportValidity()
                    field.classList.toggle('field-invalid', !field.checkValidity())
                    break

				case 'birthday':
					const isUnder18 = this.validateBirthday(field, '此客人为未成年人，请记录监护人信息并核实')
                    field.classList.toggle('field-invalid', isUnder18)
                    break

                case 'validDate':
                    const isExpired = this.validateDate(field, '证件已过期，请核验原件')
                    field.classList.toggle('field-invalid', isExpired)
                    break           

                default:
                    if (!field.checkValidity()) field.reportValidity()
                    field.classList.toggle('field-invalid', !field.checkValidity())
                    break
			}
		}
        const invalidFields = form.querySelectorAll(":invalid")

        return {
            isValid: invalidFields.length === 0,
            invalidFields
        }
	}
}