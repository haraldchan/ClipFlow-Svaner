const actionBarStyle = /*html*/ `
<style>
    .action-bar {
        max-width: 800px;
        margin-top: 16px;
        display: flex;
        justify-content: flex-end;
        gap: 12px;
    }

    .btn {
        height: 38px;
        min-width: 100px;
        padding: 0 18px;
        border-radius: 8px;
        font-size: 14px;
        font-weight: 600;
        cursor: pointer;

        transition:
            transform 0.18s ease,
            border-color 0.18s ease,
            color 0.18s ease,
            background-color 0.18s ease,
            box-shadow 0.18s ease;

        position: relative;
    }

    .btn:hover {
        transform: translateY(-2px);
    }

    .btn:active {
        transform: translateY(0);
    }

    .btn-primary {
        border: 1px solid var(--primary-dark);
        background: linear-gradient(135deg,
                var(--primary),
                var(--primary-dark));
        color: white;
    }

    .btn-primary:hover {
        box-shadow: 0 6px 18px rgba(69, 146, 216, 0.25);
    }

    .btn-secondary {
        border: 1px solid var(--border);
        background: white;
        color: var(--text);
    }

    .btn-secondary:hover {
        color: var(--primary-dark);
        border-color: var(--primary-dark);
        box-shadow: 0 4px 12px rgba(69, 146, 216, 0.12);
    }

    .btn:focus-visible {
        outline: none;
        box-shadow: 0 0 0 3px rgba(99, 193, 246, 0.25);
    }
</style>
`;

const actionBarTemplate = document.createElement('template');
actionBarTemplate.innerHTML = /*html*/ `
${actionBarStyle}
<div class="action-bar">
    <button class="btn btn-secondary" id="read-btn">读取证件</button>
    <button class="btn btn-secondary" id="scan-btn">扫描证件</button>
    <button class="btn btn-primary" id="send-btn" type="sumit">发 送</button>
</div>
`;

class ActionBar extends HTMLElement {
    constructor() {
        super();
        const shadow = this.attachShadow({
            mode: 'open'
        });
    }

    sendCommand(e) {
        const option = e.target.id.replace('-btn', '');

        if (socket === null || socket.readyState !== WebSocket.OPEN) {
            alert('尚未连接到WebSocket服务器');
            return;
        }

        const message = `{"command":"${option}"}`;

        console.log(message);
        socket.send(message);
    }

    connectedCallback() {
        const shadow = this.shadowRoot
        shadow.appendChild(actionBarTemplate.content.cloneNode(true))

        this.readBtn = shadow.getElementById('read-btn');
        this.readBtn.addEventListener('click', this.sendCommand);

        this.scanBtn = shadow.getElementById('scan-btn');
        this.scanBtn.addEventListener('click', this.sendCommand);

        this.sendBtn = shadow.getElementById('send-btn');
        this.sendBtn.addEventListener('click', async () => {
            const FormContent = document.getElementById('form-content')
            if (!FormContent.shadowRoot.querySelector('.form-content').reportValidity()) return;

            const sendClip = {
                identifier: '3ed542123e774d45203ff60175cb614e',
                tsId: Date.now(),
                roomNum: FormContent.roomNum.value,
                tel: FormContent.tel.value,
                guestType: FormContent.guestType.value,
                idType: groupedCardTypes.get(FormContent.guestType.value).get(FormContent.idType.value),
                region: FormContent.region.value,
                data: currentData,
            };

            await navigator.clipboard.writeText(JSON.stringify(sendClip));
        });
    }
}

customElements.define('action-bar', ActionBar);
