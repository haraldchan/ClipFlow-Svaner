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
        box-shadow: 0 0 0 3px rgba(99, 193, 246, 0.15);
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
            <input type="text" id="fullname" name="name">
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
                ${Object.entries(nationalityAreas).map(([code, regionName]) => html`<option value="${regionName}">${code}</option>`)
    }
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
            <select id="id-type" name="cardType" required>
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
            <select id="gender" name="sex" required>
                <option value="" disabled hidden selected>---请选择性别---</option>
                <option value="男">男</option>
                <option value="女">女</option>
            </select>
        </div>

        <div class="field">
            <label>出生日期</label>
            <input type="date" id="birthday" name="birthday" required>
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
        const shadow = this.attachShadow({
            mode: 'open'
        })
    }

    connectedCallback() {
        const shadow = this.shadowRoot
        shadow.appendChild(formContentTemplate.content.cloneNode(true))

        this.form = shadow.querySelector('form')
        this.form.addEventListener('change', e => {
            const field = e.target

            switch (field.name) {
                case 'roomNum':
                    if (field.value.length === 3 && Number.isInteger(Number(field.value))) {
                        field.value = '0' + field.value
                    }
                    currentData.roomNum = field.value
                    break
                case 'validDate':
                    const today = new Date()
                    today.setHours(0, 0, 0, 0)
                    const dateToValidate = new Date(field.value)
                    field.classList.toggle('field-invalid', today.getTime() > dateToValidate.getTime())
                    break
                default:
                    currentData[field.name] = field.value
                    break
            }
        })
    }
}

customElements.define('form-content', FormContent)