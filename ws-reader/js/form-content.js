const formContentStyle = /*html*/ `
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
        gap: 10px 16px;
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
formContentTemplate.innerHTML = /*html*/ `
${formContentStyle}
<form class="form-content">
    <div class="photo-panel">
        <img class="passport-photo" src="./no-avatar.png" alt="Passport Photo">
    </div>

    <div class="fields">

        <div class="field field-span-2">
            <label>全名</label>
            <input type="text" id="fullname" name="fullname">
        </div>

        <div class="field">
            <label>姓氏</label>
            <input type="text" id="lastname" name="lastname">
        </div>

        <div class="field">
            <label>名字</label>
            <input type="text" id="firstname" name="firstname">
        </div>

        <div class="field">
            <label>房号</label>
            <input type="text" id="room-num" name="room-num">
        </div>

        <div class="field">
            <label>电话</label>
            <input type="text" id="tel" name="tel">
        </div>

        <div class="field">
            <label>旅客类型</label>
            <select id="guest-type" name="guest-type">
                <option selected>---请选择类型---</option>
                <option value="内地旅客">内地旅客</option>
                <option value="港澳台旅客">港澳台旅客</option>
                <option value="国外旅客">国外旅客</option>
            </select>
        </div>

        <div class="field">
            <label>国籍/地区</label>
            <input id="region" type="text" list="region-list" placeholder="国籍或地区" name="region" required>
            <datalist id="region-list">
            </datalist>
            </input>
        </div>

        <div class="field field-span-2">
            <label>证件地址</label>
            <input type="text" id="address" name="address">
        </div>

        <div class="field">
            <label>证件号码</label>
            <input type="text" id="id-num" name="id-num" required>
        </div>

        <div class="field">
            <label>证件类型</label>
            <select id="id-type" name="id-type">
                <option selected>---请选择类型---</option>
            </select>
        </div>

        <div class="field">
            <label>性别</label>
            <select id="gender" name="gender">
                <option selected>---请选择性别---</option>
                <option>男</option>
                <option>女</option>
            </select>
        </div>

        <div class="field">
            <label>出生日期</label>
            <input type="date" id="birthday" name="birthday" required>
        </div>


        <div class="field">
            <label>证件有效期</label>
            <input type="date" id="valid-date" name="valid-date">
        </div>

    </div>
</form>
`;

class FormContent extends HTMLElement {
    constructor() {
        super()
        const shadow = this.attachShadow({
            mode: 'open'
        })
        shadow.innerHTML = formContentTemplate.innerHTML
    }

    createOption(select, textContent, value = null) {
        const option = document.createElement('option');

        if (value !== null) option.value = value;
        option.textContent = textContent;

        select.appendChild(option);
    }

    connectedCallback() {
        const shadow = this.shadowRoot

        this.passportPhotoImg = shadow.querySelector('.passport-photo');

        this.fullName = shadow.getElementById('fullname');
        this.fullName.addEventListener(
            'change',
            (e) => (currentData.data.name = e.target.value),
        );

        this.lastName = shadow.getElementById('lastname');
        this.lastName.addEventListener(
            'change',
            (e) => (currentData.lastName = e.target.value),
        );

        this.firstName = shadow.getElementById('firstname');
        this.firstName.addEventListener(
            'change',
            (e) => (currentData.firstName = e.target.value),
        );

        this.roomNum = shadow.getElementById('room-num');
        this.tel = shadow.getElementById('tel');

        this.guestType = shadow.getElementById('guest-type');
        this.guestType.addEventListener(
            'change',
            (e) => (currentData.guestType = e.target.value),
        );

        this.regionList = shadow.getElementById('region-list');
        this.region = shadow.getElementById('region');
        this.region.addEventListener('change', (e) => {
            currentData.nationalityArea =
                currentData.guestType === '内地旅客' ? 'CHN' : e.target.value;
        });

        this.address = shadow.getElementById('address');
        this.address.addEventListener(
            'change',
            (e) => (currentData.address = e.target.value),
        );

        this.idNum = shadow.getElementById('id-num');
        this.idNum.addEventListener('change', (e) => (currentData.cardNo = e.target.value));

        this.idType = shadow.getElementById('id-type');
        this.idType.addEventListener(
            'change',
            (e) => (currentData.cardType = e.target.value),
        );

        this.gender = shadow.getElementById('gender');
        this.gender.addEventListener('change', (e) => (currentData.sex = e.target.value));

        this.birthday = shadow.getElementById('birthday');
        this.birthday.addEventListener(
            'change',
            (e) => (currentData.birthday = e.target.value),
        );

        this.validDate = shadow.getElementById('valid-date');
        this.validDate.addEventListener(
            'change',
            (e) => (currentData.validDate = e.target.value),
        );

        for (const code in nationalityAreas) {
            this.createOption(this.regionList, code, nationalityAreas[code]);
        }

        for (const [code, idTypeName] of cardTypes) {
            this.createOption(this.idType, idTypeName, code);
        }
    }
}

customElements.define('form-content', FormContent)