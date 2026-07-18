const sideNavStyle = html`
<style>
    * {
        margin: 0;
        padding: 0;
        box-sizing: border-box;
    }

    .sidebar {
        position: absolute;
        left: 0;
        top: 0;
        width: 65px;
        height: 100vh;
        display: flex;
        flex-direction: column;
        align-items: center;
        background: #4592D8;
        user-select: none;
    }

    .sidebar-logo {
        width: 100%;
        height: 72px;
        display: flex;
        justify-content: center;
        align-items: center;
    }

    .sidebar-logo img {
        width: 38px;
        height: 38px;

        object-fit: contain;
    }

    .sidebar-divider {
        width: 42px;
        height: 1px;

        margin-bottom: 12px;

        background: rgba(255, 255, 255, .2);
    }

    .sidebar-menu {
        width: 100%;

        display: flex;
        flex-direction: column;
        align-items: center;
        gap: 8px;
    }

    .sidebar-btn {
        width: 46px;
        height: 46px;
        display: flex;
        justify-content: center;
        align-items: center;
        border: none;
        border-radius: 14px;
        background: transparent;
        color: white;
        font-size: 22px;
        cursor: pointer;
        transition:
            background .2s,
            transform .15s,
            box-shadow .2s;
    }

    .sidebar-btn:hover {
        background: rgba(255,255,255,.14);
        transform: translateY(-2px) scale(1.05);
    }

    .sidebar-btn:active {
        transform: translateY(0) scale(.96);
    }

    /* Selected page */
    .sidebar-btn.active {
        background: #63C1F6;
        box-shadow:
            0 4px 12px rgba(0,0,0,.18);
    }

    /* Keyboard focus */
    .sidebar-btn:focus-visible {
        outline: 2px solid white;
        outline-offset: 2px;
    }

    .sidebar-btn {
        position: relative;
    }

    .sidebar-btn.active::before {
        content: "";
        position: absolute;
        left: -9px;
        width: 4px;
        height: 24px;
        border-radius: 999px;
        background: white;
    }
</style>
`

const sideNavTemplate = document.createElement('template')
sideNavTemplate.innerHTML = html`
${sideNavStyle}
<nav class="sidebar">
    <div class="sidebar-logo">
        <img src="../assets/CFicon.jpg" alt="Logo">
    </div>

    <div class="sidebar-divider"></div>

    <div class="sidebar-menu">
        <button class="sidebar-btn active" id="reader-btn" title="Reader">🛂</button>
        <button class="sidebar-btn" id="history-btn" title="History">📄</button>
    </div>
</nav>
`

class SideNav extends HTMLElement {
    constructor() {
        super()
        const shadow = this.attachShadow({ mode: 'open' })

        this.tabState = { showing: 'reader' }
        this.tabs = new Proxy(this.tabState, {
            set(target, key, value, receiver) {
                const ok = Reflect.set(target, key, value, receiver)
                if (ok) {
                    switch (value) {
                        case 'reader':
                            document.querySelector('.passport-card').style.display = 'block'
                            document.querySelector('action-bar').shadowRoot.querySelector('.action-bar').style.display = 'flex'
                            document.querySelector('history-card').shadowRoot.querySelector('.history-card').style.display = 'none'
                            break
                        case 'history':
                            document.querySelector('.passport-card').style.display = 'none'
                            document.querySelector('action-bar').shadowRoot.querySelector('.action-bar').style.display = 'none'
                            document.querySelector('history-card').shadowRoot.querySelector('.history-card').style.display = 'flex'
                            break
                    }
                }
                return ok
            }
        })
    }

    connectedCallback() {
        const shadow = this.shadowRoot
        shadow.appendChild(sideNavTemplate.content.cloneNode(true))

        this.readerBtn = shadow.getElementById('reader-btn')
        this.readerBtn.addEventListener('click', this.handleBtnSelected.bind(this))

        this.historyBtn = shadow.getElementById('history-btn')
        this.historyBtn.addEventListener('click', this.handleBtnSelected.bind(this))
    }

    handleBtnSelected(e) {
        const thisBtn = e.target.id.replace('-btn', '')

        const btns = this.shadowRoot.querySelectorAll('button')
        for (const btn of btns) {
            btn.classList.remove('active')
        }
        e.target.classList.add('active')

        // switch tab
        this.tabs.showing = thisBtn
        if (thisBtn === 'history') {
            PDB.getAll()
        }
    }
}

customElements.define('side-nav', SideNav)