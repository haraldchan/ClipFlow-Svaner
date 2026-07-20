const formContentStyle = html`
<style>
    .form-content {
        display: grid;
        grid-template-columns: 140px 1fr;
        gap: 18px;
        padding: 18px;
    }

    .photo-panel {
        display: flex;
        justify-content: center;
    }

    .passport-photo {
        width: 140px;
        height: 100%;
        aspect-ratio: 3 / 4;
        object-fit: cover;
        border-radius: 8px;
        border: 2px solid var(--primary);
        object-fit: contain;
    }

    .fields {
        display: grid;
        grid-template-columns: repeat(2, minmax(0, 1fr));
        gap: 20px 16px;
    }

    .field {
        display: flex;
        align-items: center;
        gap: 10px;
    }

    .field label {
        width: 90px;
        flex-shrink: 0;
        font-size: 12px;
        font-weight: 600;
        color: var(--muted);
    }

    .field input,
    .field select {
        width: 100%;
        min-width: 0;
        height: 32px;
        padding: 0 10px;
        border: 1px solid var(--border);
        border-radius: 6px;
        background: white;
        color: var(--text);
        font-size: 13px;
    }

    .field input:focus,
    .field select:focus {
        outline: none;
        border-color: var(--primary-dark);
        box-shadow: 0 0 0 3px rgba(99, 193, 246, 0.15);
    }

    .field-invalid {
        outline: none;
        border-color: var(--danger) !important;
        color: var(--danger)  !important;
        box-shadow: 0 0 0 3px rgba(246, 99, 99, 0.15) !important;
    }

    .field-span-2 {
        grid-column: span 2;
    }

    @media (max-width: 700px) {
        .content {
            grid-template-columns: 1fr;
        }

        .photo-panel {
            justify-content: center;
        }

        .fields {
            grid-template-columns: 1fr;
        }

        .field-span-2 {
            grid-column: auto;
        }
    }
</style>
`

const formContentTemplate = document.createElement('template')
formContentTemplate.innerHTML = html`
${formContentStyle}
<form class="form-content">
    <div class="photo-panel">
        <img class="passport-photo" src="./assets/no-avatar.png" alt="Passport Photo">
        <input hidden type="text" name="curPhoto">
    </div>

    <div class="fields">

        <div class="field field-span-2">
            <label>全名</label>
            <input type="text" id="name" name="name">
        </div>

        <div class="field">
            <label>姓氏</label>
            <input type="text" id="lastname" name="lastName">
        </div>

        <div class="field">
            <label>名字</label>
            <input type="text" id="firstname" name="firstName">
        </div>

        <div class="field">
            <label>房号</label>
            <input type="text" id="room-num" name="roomNum">
        </div>

        <div class="field">
            <label>电话</label>
            <input type="text" id="tel" name="tel">
        </div>

        <div class="field">
            <label>旅客类型</label>
            <select id="guest-type" name="guestType" required>
                <option value="" disabled hidden selected>---请选择类型---</option>
                <option value="内地旅客">内地旅客</option>
                <option value="港澳台旅客">港澳台旅客</option>
                <option value="国外旅客">国外旅客</option>
            </select>
        </div>

        <div class="field">
            <label>国籍/地区</label>
            <input id="region" type="text" list="region-list" placeholder="国籍或地区" name="region" required>
                <datalist id="region-list">
                    ${Object.entries(nationalityAreas).map(([code, regionName]) => html`<option value="${regionName}">${code}</option>`)}
                </datalist>
            </input>
        </div>

        <div class="field field-span-2">
            <label>证件地址</label>
            <input type="text" id="address" name="address">
        </div>

        <div class="field">
            <label>证件号码</label>
            <input type="text" id="id-num" name="cardNo" required>
        </div>

        <div class="field">
            <label>证件类型</label>
            <select id="card-type" name="cardType" required>
                <option value="" disabled hidden selected>---请选择类型---</option>
                ${each(groupedCardTypes, ([guestType, cardTypes]) => html`
                    <optgroup label="${guestType}">
                        ${each(cardTypes, ([cardTypeCode, cardTypeName]) => html`
                            <option value="${cardTypeCode}">${cardTypeName}</option>
                        `)}
                    </optgroup>`
)}
            </select>
        </div>

        <div class="field">
            <label>性别</label>
            <select id="gender" name="gender" required>
                <option value="" disabled hidden selected>---请选择性别---</option>
                <option value="男">男</option>
                <option value="女">女</option>
            </select>
        </div>

        <div class="field">
            <label>出生日期</label>
            <input type="date" id="birthday" name="birthday" required>
        </div>

        <div class="field" style="display:none;">
            <label>监护人姓名</label>
            <input type="text" id="guardian-name" name="guardianName">
        </div>
        
        <div class="field" style="display:none;">
            <label>监护人电话</label>
            <input type="text" id="guardian-tel" name="guardianTel">
        </div>
        
        <div class="field" style="display:none;">
            <label>监护人关系</label>
            <input type="text" id="guardian-relation" name="guardianRelation" list="relation-list">
                <datalist id="relation-list">
                    <option value="父亲"></option>
                    <option value="母亲"></option>
                    <option value="其他"></option>
                </datalist>
            </input>
        </div>


        <div class="field">
            <label>证件有效期</label>
            <input type="date" id="valid-date" name="validDate">
        </div>

    </div>
</form>
`

class FormContent extends HTMLElement {
    constructor() {
        super()
        const shadow = this.attachShadow({ mode: 'open' })

        this.guestTypeState = { selected: '' }
        this.curGuestType = new Proxy(this.guestTypeState, {
            set: (target, key, value, receiver) => {              
                if (target[key] === value) {
                    return true
                }

                const ok = Reflect.set(target, key, value, receiver)
                if (ok) {
                    // swap card type group
                    const cardTypeSelect = shadow.getElementById('card-type')
                    cardTypeSelect.innerHTML = html`
                        <option value="" disabled hidden selected>---请选择类型---</option>
                        ${each(groupedCardTypes.get(value), ([cardTypeCode, cardTypeName]) => html`
                            <option value="${cardTypeCode}">${cardTypeName}</option>
                        `)}
                    `

                    // swap region
                    const regionInput = shadow.getElementById('region')
                    const regionList = shadow.getElementById('region-list')
                    switch (value) {
                        case '内地旅客':
                            regionList.innerHTML = html`<option value="中国">CHN</option>`
                            regionInput.value = '中国'
                            break
                        case '港澳台旅客':
                            regionList.innerHTML = html`
                                <option value="香港">HKG</option>
                                <option value="澳门">MAC</option>
                                <option value="台湾">TWN</option>
                            `
                            break
                        case '国外旅客':
                            regionList.innerHTML = html`
                                ${Object.entries(nationalityAreas).map(([code, regionName]) => {
                                if (!['CHN', 'HKG', 'MAC', 'TWN'].find(chinaRegion => chinaRegion === code)) {
                                    return html`<option value="${regionName}">${code}</option>`
                                }
                            })}
                            `
                            FormValidator.isUnder18.yes = false
                            break
                    }

                    if (this.curCardType.selected && groupedCardTypes.get(value).get(this.curCardType.selected)) {
                        cardTypeSelect.value = this.curCardType.selected
                    }
                }
                return ok
            }
        })

        this.cardTypeState = { selected: '' }
        this.curCardType = new Proxy(this.cardTypeState, {
            set: (target, key, value, receiver) => { 
                if (target[key] === value) {
                    return true
                }
                
                const ok = Reflect.set(target, key, value, receiver)
                if (ok) {
                    // change guest type
                    const guestTypeSelect = shadow.getElementById('guest-type')
                    const cardTypeCodes = [...groupedCardTypes.values()].map(m => [...m.keys()])
                    let index = 1
                    for (const codeGroup of cardTypeCodes) {
                        if (codeGroup.find(code => code === value)) {
                            guestTypeSelect.selectedIndex = index
                            this.curGuestType.selected = guestTypeSelect.value
                        }
                        index++
                    }
                }
                return ok
            }
        })
    }

    connectedCallback() {
        const shadow = this.shadowRoot
        shadow.appendChild(formContentTemplate.content.cloneNode(true))

        this.form = shadow.querySelector('form')
        this.form.addEventListener('change', e => {
            /**
             * @type {HTMLInputElement | HTMLSelectElement}
             */
            const field = e.target

            switch (field.name) {
                case 'roomNum':
                    if (field.value.length === 3 && Number.isInteger(Number(field.value))) {
                        field.value = '0' + field.value
                    }
                    currentData.roomNum = field.value
                    break

                case 'region':
                    currentData.region = field.value
                    break

                case 'guestType':
                    this.curGuestType.selected = field.value
                    currentData.guestType = field.value
                    break

                case 'cardType':
                    this.curCardType.selected = field.value
                    currentData.cardType = field.value
                    break

                case 'guardianName':
                case 'guardianTel':
                case 'guardianRelation':
                    if (field.value) {
                        if (!currentData.hasOwnProperty('guardianInfo')) {
                            currentData.guardianInfo = {}
                        }
                        currentData.guardianInfo[field.name] = field.value
                    }
                    break

                default:
                    currentData[field.name] = field.value
                    break
            }

            const validateResult = FormValidator.handleFormValidate(e.currentTarget)
            if (validateResult.isValid) {
                PDB.add(currentData)
            }
        })

        this.guardianFields = [
            this.form.elements.namedItem("guardianName"),
            this.form.elements.namedItem("guardianTel"),
            this.form.elements.namedItem("guardianRelation"),
        ]
    }
}

customElements.define('form-content', FormContent)