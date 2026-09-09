const $ = (s) => document.querySelector(s);
const root = $('#root');
const block = $('#weapon');
const ammo = $('#ammo');
const clip = $('#clip');
const reserve = $('#reserve');
const icon = $('#icon');
const fmt = new Intl.NumberFormat('en-US');
const resource = typeof GetParentResourceName === 'function' ? GetParentResourceName() : 'gta6_weaponhud';

function post(name, body) {
    return fetch(`https://${resource}/${name}`, { method: 'POST', body: JSON.stringify(body || {}) });
}

let reported = '';
function report() {
    const visible = !block.hidden;
    const height = visible ? block.offsetHeight : 0;
    const key = `${visible}|${height}`;
    if (key === reported) return;
    reported = key;
    post('state', { visible, height });
}

function setIcon(name) {
    if (!name) {
        icon.hidden = true;
        icon.removeAttribute('src');
        return;
    }
    const src = `icons/${name}.png`;
    if (icon.getAttribute('src') !== src) {
        icon.src = src;
        icon.classList.remove('swap');
        void icon.offsetWidth;
        icon.classList.add('swap');
    }
    icon.hidden = false;
}

function onWeapon(data) {
    if (!data.show) {
        block.hidden = true;
        report();
        return;
    }
    const w = data.data || {};
    const hasClip = w.clip !== undefined;
    const hasCount = w.count !== undefined;
    ammo.hidden = !(hasClip || hasCount);
    clip.textContent = fmt.format(hasClip ? w.clip : (w.count || 0));
    clip.classList.toggle('empty', (hasClip && w.clip === 0) || (hasCount && w.count === 0));
    reserve.hidden = !hasClip;
    if (hasClip) reserve.textContent = fmt.format(w.reserve);
    setIcon(w.icon);
    block.hidden = false;
    report();
}

function onConfig(data) {
    const pos = data.position || {};
    if (pos.top) root.style.setProperty('--top', pos.top);
    if (pos.right) root.style.setProperty('--right', pos.right);
}

icon.addEventListener('error', () => { setIcon(null); report(); });
icon.addEventListener('load', report);

window.addEventListener('message', (e) => {
    const data = e.data || {};
    switch (data.action) {
        case 'weapon': onWeapon(data); break;
        case 'config': onConfig(data); break;
        case 'visible': root.classList.toggle('paused', !data.state); break;
    }
});

post('ready');
