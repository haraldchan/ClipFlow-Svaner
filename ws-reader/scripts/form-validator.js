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

    static isUnder18 = new Proxy({ yes: false }, {
        set(target, key, isTrue, receiver) {
            const ok = Reflect.set(target, key, isTrue, receiver)
            if (ok) {
                const FormContent = document.querySelector('form-content')
                const isForeigner = FormContent.curGuestType.selected === '国外旅客'

                if (!isTrue && currentData.hasOwnProperty('guardianInfo')) {
                    delete currentData.guardianInfo
                }

                FormContent.guardianFields.forEach(field => {
                    /** @type {HTMLInputElement} */
                    const f = field
                    f.parentElement.style.display = (isTrue && !isForeigner) ? 'flex' : 'none'
                    f.required = (isTrue && !isForeigner)
                    if (!(isTrue && !isForeigner)) {
                        f.value = ''
                    }
                })
            }
            return ok
        }
    })

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
    */
    static validateBirthday(field) {
        const birthday = new Date(field.value)
        const isUnder18 = this.getAge(birthday) < 18

        this.isUnder18.yes = isUnder18
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

                case 'validDate':
                    const isExpired = this.validateDate(field, '证件已过期，请核验原件')
                    field.classList.toggle('field-invalid', isExpired)
                    break

                case 'birthday':
                    this.validateBirthday(field)
                    if (!field.checkValidity()) field.reportValidity()
                    field.classList.toggle('field-invalid', !field.checkValidity())
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