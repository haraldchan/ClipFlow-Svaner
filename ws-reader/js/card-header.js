const cardHeaderStyle = /*html*/ `
<style>
    .card-header {
        display: flex;
        justify-content: space-between;
        align-items: center;
        padding: 12px 18px;
        background: linear-gradient(135deg, var(--primary), var(--primary-dark));
        color: white;
    }

    .card-header h2 {
        margin: 0;
        font-size: 16px;
        font-weight: 600;
    }

    .header-controls {
        display: flex;
        align-items: center;
        gap: 8px;
    }

    .port-select {
        height: 30px;
        min-width: 92px;

        padding: 0 10px;

        border: 1px solid rgba(255, 255, 255, .3);
        border-radius: 999px;

        background: rgba(255, 255, 255, .12);
        color: white;

        font-size: 12px;
        font-weight: 600;

        cursor: pointer;

        transition:
            background-color .2s,
            border-color .2s,
            transform .15s;
    }

    .port-select:hover {
        background: rgba(255, 255, 255, .2);
        border-color: rgba(255, 255, 255, .6);
        transform: translateY(-1px);
    }

    .port-select:focus {
        outline: none;
        border-color: white;
    }

    .port-select option {
        color: var(--text);
        background: white;
    }

    .status {
        font-size: 11px;
        font-weight: 700;
        letter-spacing: 0.08em;
    }

    /* websocket conn btn styles */
    .connection-btn {
        height: 30px;
        line-height: 30px;
        padding: 0 12px;
        border-radius: 999px;
        border: 1px solid transparent;

        font-size: 14px;
        font-weight: bolder;

        cursor: pointer;

        transition:
            background-color 0.2s ease,
            color 0.2s ease,
            border-color 0.2s ease,
            transform 0.15s ease;
    }

    .connection-btn:hover {
        transform: translateY(-1px);
    }

    .status-connected {
        background: rgba(255, 255, 255, 0.18);
        color: #71ff6f;
        border-color: rgba(255, 255, 255, 0.25);
    }

    .status-connected:hover {
        background: rgba(255, 255, 255, 0.28);
    }

    .status-connecting {
        background: rgba(255, 255, 255, 0.12);
        color: #ffc107;
        border-color: rgba(255, 255, 255, 0.25);
    }

    .status-connecting {
        animation: pulse 1.5s infinite;
    }

    @keyframes pulse {

        0%,
        100% {
            opacity: 1;
        }

        50% {
            opacity: 0.65;
        }
    }

    .status-disconnected {
        background: rgba(255, 255, 255, 0.18);
        color: #de5664;
        border-color: rgba(255, 255, 255, 0.25);
    }
</style>
`;

const cardHeaderTemplate = document.createElement('template');
cardHeaderTemplate.innerHTML = /*html*/ `
${cardHeaderStyle}
<div class="card-header">
    <h2>证 件 登 记</h2>
    <div class="header-controls">
        <select id="port-select" class="port-select">
        </select>
        <span class="connection-btn status-disconnected">
            未连接
        </span>
    </div>
</div>
`;

class CardHeader extends HTMLElement {
    constructor() {
        super();
        const shadow = this.attachShadow({
            mode: 'open'
        });
        shadow.innerHTML = cardHeaderTemplate.innerHTML;
    }

    connectedCallback() {
        const shadow = this.shadowRoot

        this.connBtn = shadow.querySelector('.connection-btn');
        this.connBtn.addEventListener('click', async () => connectOrDisconnect());

        this.portSelect = shadow.querySelector('.port-select');
        this.portSelect.addEventListener('change', async (e) => {
            const curPort = e.target.value

            if (socket) {
                socket.close();
                socket = null;
            }
            console.log(`current port: ${curPort}`);
            await connectOrDisconnect(curPort);
        });

        for (const [port, maker] of portsWithMakers) {
            const option = document.createElement('option')

            option.value = port
            option.textContent = `${maker}:${port}`

            this.portSelect.appendChild(option)
        }
    }
}

customElements.define('card-header', CardHeader);