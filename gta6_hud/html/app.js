const RESOURCE = typeof GetParentResourceName === 'function' ? GetParentResourceName() : 'gta6_hud';
const SPEED_UNIT = 'MPH';
const VEHICLE_NAME_MS = 3500;
const DEG_PER_U = 4 / 3;

const $ = (sel) => document.querySelector(sel);
const num = (v, d = 0) => (typeof v === 'number' && !Number.isNaN(v) ? v : d);
const clamp = (v) => Math.max(0, Math.min(100, v));
const fmt = new Intl.NumberFormat('en-US');

function post(name) {
    fetch(`https://${RESOURCE}/${name}`, { method: 'POST', headers: { 'Content-Type': 'application/json' }, body: '{}' }).catch(() => {});
}

const settings = {
    isOutMapChecked: false,
    isOutCompassChecked: false,
    isCompassFollowChecked: true,
    isOpenMenuSoundsChecked: true,
    isResetSoundsChecked: true,
    isListSoundsChecked: true,
    isLowFuelChecked: true,
    isCinematicNotifChecked: true,
    isDynamicHealthChecked: true,
    isDynamicArmorChecked: true,
    isDynamicHungerChecked: true,
    isDynamicThirstChecked: true,
    isDynamicStressChecked: true,
    isDynamicOxygenChecked: true,
    isChangeFPSChecked: true,
    isHideMapChecked: false,
    isDynamicEngineChecked: true,
    isDynamicNitroChecked: true,
    isChangeCompassFPSChecked: true,
    isCompassShowChecked: true,
    isShowStreetsChecked: true,
    isPointerShowChecked: true,
    isDegreesShowChecked: true,
    isCinematicModeChecked: false,
};

const MENU = [
    ['map', [
        ['isOutMapChecked', 'showOutMap'],
        ['isHideMapChecked', 'HideMap'],
    ]],
    ['compass', [
        ['isOutCompassChecked', 'showOutCompass'],
        ['isCompassFollowChecked', 'showFollowCompass'],
        ['isCompassShowChecked', 'showCompassBase'],
        ['isShowStreetsChecked', 'showStreetsNames'],
        ['isPointerShowChecked', 'showPointerIndex'],
        ['isDegreesShowChecked', 'showDegreesNum'],
        ['isChangeCompassFPSChecked', 'changeCompassFPS'],
    ]],
    ['status', [
        ['isDynamicHealthChecked', 'dynamicHealth'],
        ['isDynamicArmorChecked', 'dynamicArmor'],
        ['isDynamicOxygenChecked', 'dynamicOxygen'],
        ['isDynamicHungerChecked', 'dynamicHunger'],
        ['isDynamicThirstChecked', 'dynamicThirst'],
        ['isDynamicStressChecked', 'dynamicStress'],
    ]],
    ['vehicle', [
        ['isChangeFPSChecked', 'changeFPS'],
        ['isDynamicEngineChecked', 'dynamicEngine'],
        ['isDynamicNitroChecked', 'dynamicNitro'],
        ['isLowFuelChecked', 'showFuelAlert'],
    ]],
    ['sound', [
        ['isOpenMenuSoundsChecked', 'openMenuSounds'],
        ['isResetSoundsChecked', 'resetHudSounds'],
        ['isListSoundsChecked', 'checklistSounds'],
        ['isCinematicNotifChecked', 'showCinematicNotif'],
    ]],
    ['cinematic', [
        ['isCinematicModeChecked', 'cinematicMode'],
    ]],
];

const STATS = [
    { id: 'health', icon: 'heart', color: 'var(--pink)', notch: true },
    { id: 'armor', icon: 'shield', color: 'var(--blue)' },
    { id: 'stamina', icon: 'bolt', color: 'var(--mint)' },
    { id: 'hunger', icon: 'food', color: 'var(--peach)' },
    { id: 'thirst', icon: 'drop', color: 'var(--sky)' },
    { id: 'stress', icon: 'stress', color: 'var(--lilac)' },
];

const VEHICLE_ROWS = [
    { id: 'nitro', icon: 'nitro', color: 'var(--pink)' },
    { id: 'harness', icon: 'harness', color: 'var(--lilac)' },
];

const rows = {};

function makeRow({ id, icon, color, notch }) {
    const row = document.createElement('div');
    row.className = 'row';
    row.dataset.stat = id;
    row.style.setProperty('--c', color);
    row.hidden = true;
    row.innerHTML = `<div class="icon"><svg><use href="#i-${icon}"/></svg></div><div class="track"><div class="fill">${notch ? '<div class="notch"></div>' : ''}</div></div>`;
    rows[id] = row;
    return row;
}

function setRow(id, visible, pct, low) {
    const row = rows[id];
    row.hidden = !visible;
    if (!visible) return;
    row.querySelector('.fill').style.width = `${clamp(num(pct))}%`;
    row.classList.toggle('low', !!low);
}

const lastValues = {};
const hitTimers = {};

function playHit(id, icon) {
    icon.classList.remove('hit');
    void icon.offsetWidth;
    icon.classList.add('hit');
    hitTimers[id] = setTimeout(() => {
        hitTimers[id] = 0;
        icon.classList.remove('hit');
        if (icon.dataset.again) {
            delete icon.dataset.again;
            playHit(id, icon);
        }
    }, 720);
}

function hit(id, value) {
    const prev = lastValues[id];
    lastValues[id] = value;
    if (prev === undefined || value >= prev) return;
    const icon = rows[id].querySelector('.icon');
    if (hitTimers[id]) {
        icon.dataset.again = '1';
        return;
    }
    playHit(id, icon);
}

STATS.forEach((s) => $('#status').appendChild(makeRow(s)));
VEHICLE_ROWS.forEach((s) => $('#vehicle-rows').appendChild(makeRow(s)));
$('#speed-unit').textContent = SPEED_UNIT;

const hud = $('#hud');
const player = {};
const vehicle = {};

function applyMapClasses() {
    const mapShown = vehicle.show ? !settings.isHideMapChecked : settings.isOutMapChecked;
    hud.classList.toggle('map-hidden', !mapShown);
}

function syncMenuInputs() {
    document.querySelectorAll('#menu input[data-key]').forEach((input) => {
        input.checked = !!settings[input.dataset.key];
    });
}

function onSetting(key, value) {
    if (!(key in settings)) return;
    settings[key] = value;
    applyMapClasses();
    syncMenuInputs();
}

let hudVisible = false;
let compassShown = false;
let fullHealthInVehicle = false;
let vehicleHealthTimeout = 6000;
let vehicleHealthLow = 50;
let statusTimeout = 6000;
let statusAlways = false;
const statusLast = {};
const statusShownUntil = {};
const statusTimers = {};

function noteStatusChange(id, value) {
    const prev = statusLast[id];
    statusLast[id] = value;
    if (prev === undefined || value === prev) return;
    statusShownUntil[id] = performance.now() + statusTimeout;
    clearTimeout(statusTimers[id]);
    statusTimers[id] = setTimeout(applyNeedsRows, statusTimeout + 50);
}

function statusRecent(id) {
    return performance.now() < (statusShownUntil[id] || 0);
}

function applyNeedsRows() {
    const p = player;
    const hunger = num(p.hunger, 100);
    const thirst = num(p.thirst, 100);
    const stress = num(p.stress);
    setRow('hunger', statusAlways || !p.dynamicHunger || hunger <= 30 || statusRecent('hunger'), hunger, hunger <= 30);
    setRow('thirst', statusAlways || !p.dynamicThirst || thirst <= 30 || statusRecent('thirst'), thirst, thirst <= 30);
    setRow('stress', statusAlways || !p.dynamicStress || stress >= 75 || statusRecent('stress'), stress, stress >= 75);
}
let navText = {};
let navUnits = 'imperial';
const NAV = {
    1: { key: 'recalc', icon: 'n-recalc' },
    2: { key: 'proceed', icon: 'n-straight' },
    3: { key: 'left', icon: 'n-left', distance: true },
    4: { key: 'right', icon: 'n-right', distance: true },
    5: { key: 'straight', icon: 'n-straight' },
    6: { key: 'sharpLeft', icon: 'n-sharpleft', distance: true },
    7: { key: 'sharpRight', icon: 'n-sharpright', distance: true },
    8: { key: 'recalc', icon: 'n-recalc' },
    9: { key: 'arrived', icon: 'n-arrived' },
};

function formatDistance(metres) {
    if (navUnits === 'metric') {
        if (metres >= 1000) return `${(metres / 1000).toFixed(1)} ${navText.km || 'km'}`;
        return `${Math.max(10, Math.round(metres / 10) * 10)} ${navText.m || 'm'}`;
    }
    const feet = metres * 3.28084;
    if (feet >= 1000) return `${(metres / 1609.344).toFixed(1)} ${navText.mi || 'mi'}`;
    return `${Math.max(10, Math.round(feet / 10) * 10)} ${navText.ft || 'ft'}`;
}

function renderNav() {
    const nav = $('#nav');
    const step = NAV[num(vehicle.navDir, 0)];
    nav.hidden = !vehicle.show || !step;
    if (!step) return;
    $('#nav-t1').textContent = navText[step.key] || step.key;
    $('#nav-t2').textContent = step.distance && num(vehicle.navDist) > 0 ? formatDistance(num(vehicle.navDist)) : '';
    $('#nav-icon').setAttribute('href', `#${step.icon}`);
}
let lastHealthValue;
let healthShownUntil = 0;
let healthTimer = 0;

function applyHealthRow() {
    const health = num(player.health, 100);
    const dead = !!player.playerDead;
    const keep = !player.dynamicHealth || !vehicle.show || fullHealthInVehicle || dead || health <= vehicleHealthLow || performance.now() < healthShownUntil;
    setRow('health', keep, dead ? 100 : health, dead || health <= 25);
}

function renderCompass() {
    $('#compass').hidden = !(hudVisible && compassShown);
}

function onHudTick(data) {
    Object.assign(player, data);
    const p = player;
    const show = !!data.show;
    hudVisible = show;
    renderWeapon();
    renderCompass();
    $('#status').hidden = !show;
    $('#chips').hidden = !show;
    if (!show) return;

    const health = num(p.health, 100);
    const armor = num(p.armor);
    const stamina = num(p.oxygen, 100);
    const hunger = num(p.hunger, 100);
    const thirst = num(p.thirst, 100);
    const stress = num(p.stress);
    const dead = !!p.playerDead;

    if (lastHealthValue !== undefined && health < lastHealthValue) {
        healthShownUntil = performance.now() + vehicleHealthTimeout;
        clearTimeout(healthTimer);
        healthTimer = setTimeout(applyHealthRow, vehicleHealthTimeout + 50);
    }
    lastHealthValue = health;
    applyHealthRow();
    setRow('armor', p.dynamicArmor ? armor > 0 : true, armor, false);
    setRow('stamina', p.dynamicOxygen ? stamina < 100 : true, stamina, stamina <= 20);
    rows.stamina.querySelector('use').setAttribute('href', p.underwater ? '#i-o2' : '#i-bolt');
    noteStatusChange('hunger', hunger);
    noteStatusChange('thirst', thirst);
    noteStatusChange('stress', stress);
    applyNeedsRows();
    hit('health', health);
    hit('armor', armor);
    hit('stamina', stamina);
    hit('hunger', hunger);
    hit('thirst', thirst);

    $('#chip-armed').hidden = !p.armed;
    $('#chip-parachute').hidden = num(p.parachute, -1) < 0;
    $('#chip-cruise').hidden = !p.cruise;
    $('#chip-dev').hidden = !p.dev;

    const engine = clamp(num(p.engine));
    const eng = $('#chip-engine');
    eng.classList.toggle('damaged', p.dynamicEngine ? engine < 95 : true);
    eng.classList.toggle('warn', engine <= 75);
    eng.classList.toggle('low', engine <= 45);
    eng.style.setProperty('--off', (62.83 * (1 - engine / 100)).toFixed(2));

    const nos = num(p.nos, -1);
    setRow('nitro', p.dynamicNitro ? nos > 0 : nos >= 0, nos, false);
    rows.nitro.classList.toggle('active', !!p.nitroActive);
    setRow('harness', !!p.harness, num(p.hp) * 5, false);
}

const voiceChip = $('#chip-voice');

function onVoice(data) {
    voiceChip.style.setProperty('--off', (62.83 * (1 - Math.min(num(data.level), 1))).toFixed(2));
    voiceChip.classList.toggle('talking', !!data.talking);
    voiceChip.classList.toggle('radio', !!data.radioActive);
    $('#voice-icon').setAttribute('href', data.radio ? '#i-headset' : '#i-mic');
}

const speedEl = $('#speed');
let speedTarget = 0;
let speedShown = 0;
let speedRaf = 0;
let speedLast = 0;

function animateSpeed() {
    const now = performance.now();
    const dt = Math.min(now - speedLast, 100);
    speedLast = now;
    speedShown += (speedTarget - speedShown) * (1 - Math.exp(-dt / 220));
    if (Math.abs(speedTarget - speedShown) < 0.05) {
        speedShown = speedTarget;
        speedRaf = 0;
    } else {
        speedRaf = requestAnimationFrame(animateSpeed);
    }
    speedEl.textContent = Math.round(speedShown);
}

function setSpeed(value) {
    speedTarget = value;
    if (!speedRaf) {
        speedLast = performance.now();
        speedRaf = requestAnimationFrame(animateSpeed);
    }
}

let vinfoTimer = 0;
let vinfoName = null;

function measureVinfo() {
    hud.style.setProperty('--vinfo-h', `calc(${$('#vehicle-info').offsetHeight}px + var(--map-gap))`);
}

new ResizeObserver(() => {
    const info = $('#vehicle-info');
    if (info.hidden || hud.classList.contains('vinfo-settle')) return;
    measureVinfo();
}).observe($('#vehicle-info'));

new ResizeObserver(() => {
    hud.style.setProperty('--vehicle-h', `${$('#vehicle').offsetHeight}px`);
}).observe($('#vehicle'));

function presentVehicle() {
    const info = $('#vehicle-info');
    info.classList.remove('compact');
    clearTimeout(vinfoTimer);
    vinfoTimer = setTimeout(() => {
        info.classList.add('compact');
        hud.classList.add('vinfo-settle');
        const extra = info.offsetHeight - $('#vtile').offsetHeight;
        hud.style.setProperty('--vinfo-h', `calc(var(--vinfo-compact-h) + ${extra}px + var(--map-gap))`);
        setTimeout(() => {
            hud.classList.remove('vinfo-settle');
            measureVinfo();
        }, 1000);
    }, VEHICLE_NAME_MS);
    measureVinfo();
}

function onCar(data) {
    Object.assign(vehicle, data);
    const show = !!data.show;
    vehicle.show = show;
    applyHealthRow();
    $('#vehicle').hidden = !show;
    const voiceHome = show ? $('#vehicle-chips') : $('#chips');
    if (voiceChip.parentElement !== voiceHome) voiceHome.prepend(voiceChip);
    $('#vehicle-info').hidden = !show;
    hud.classList.toggle('in-vehicle', show);
    applyMapClasses();
    if (!show) {
        $('#nav').hidden = true;
        cancelAnimationFrame(speedRaf);
        speedRaf = 0;
        speedTarget = speedShown = 0;
        speedEl.textContent = '0';
        if (data.left) {
            clearTimeout(vinfoTimer);
            vinfoName = null;
        }
        return;
    }

    setSpeed(num(vehicle.speed));
    $('#altitude-row').hidden = !vehicle.showAltitude;
    $('#altitude').textContent = Math.round(num(vehicle.altitude));
    $('#vehicle-make').textContent = vehicle.make || '';
    $('#vehicle-model').textContent = vehicle.model || '';
    const zone = $('#zone');
    zone.textContent = vehicle.zone || '';
    zone.hidden = !vehicle.zone;
    renderNav();
    const fuel = clamp(num(vehicle.fuel));
    const fuelChip = $('#chip-fuel');
    fuelChip.style.setProperty('--off', (62.83 * (1 - fuel / 100)).toFixed(2));
    fuelChip.classList.toggle('low', fuel <= 20);
    const belt = $('#chip-belt');
    belt.hidden = !vehicle.showSeatbelt;
    belt.classList.toggle('unbuckled', !vehicle.seatbelt);
    const name = `${vehicle.make || ''}|${vehicle.model || ''}`;
    if (name !== vinfoName) {
        vinfoName = name;
        presentVehicle();
    }
}

const ruler = $('#ruler');
const NAMES = { 0: 'N', 45: 'NE', 90: 'E', 135: 'SE', 180: 'S', 225: 'SW', 270: 'W', 315: 'NW' };
for (let deg = -180; deg <= 540; deg += 45) {
    const name = NAMES[((deg % 360) + 360) % 360];
    const el = document.createElement('span');
    el.className = `lbl${name.length > 1 ? ' minor' : ''}${name === 'N' ? ' n' : ''}`;
    el.textContent = name;
    el.style.left = `calc(${(deg + 180) * DEG_PER_U} * var(--u))`;
    ruler.appendChild(el);
}

function onHeading(data) {
    if (data.value === undefined) return;
    const heading = Number(data.value) || 0;
    ruler.style.transform = `translateX(calc(${(120 - (heading + 180) * DEG_PER_U).toFixed(2)} * var(--u)))`;
    $('#degrees').textContent = `${heading}°`;
}

function onBaseplate(data) {
    compassShown = !!data.show;
    renderCompass();
    if (!data.show) return;
    $('#strip').hidden = !data.showCompass;
    $('#pointer').hidden = !data.showPointer;
    const streets = !!data.showStreets;
    $('#street1').hidden = !streets;
    $('#street2').hidden = !streets;
    $('#street1').textContent = streets ? data.street1 || '' : '';
    $('#street2').textContent = streets ? data.street2 || '' : '';
    $('#degrees').hidden = !data.showDegrees;
    $('#streets').classList.toggle('blank', !streets && !data.showDegrees);
}

const timers = {};
function flash(id, ms) {
    const el = $(id);
    el.hidden = false;
    clearTimeout(timers[id]);
    timers[id] = setTimeout(() => { el.hidden = true; }, ms);
}

function setMoney(type, value) {
    $(`#${type}`).textContent = `$${fmt.format(value)}`;
    $(`#money-${type}`).hidden = false;
}

function onShowMoney(data) {
    if (data.type !== 'cash' && data.type !== 'bank') return;
    $(`#money-${data.type === 'cash' ? 'bank' : 'cash'}`).hidden = true;
    setMoney(data.type, num(data.amount));
    flash('#money-lines', 3500);
}

function onUpdateMoney(data) {
    setMoney('cash', num(data.cash));
    setMoney('bank', num(data.bank));
    const delta = $('#money-delta');
    delta.textContent = `${data.minus ? '-' : '+'}$${fmt.format(num(data.amount))}`;
    delta.className = `delta ${data.minus ? 'minus' : 'plus'}`;
    flash('#money-delta', 1500);
    flash('#money-lines', 2500);
}

const weaponEl = $('#weapon');
const weaponIcon = $('#weapon-icon');
let weaponShown = false;

function renderWeapon() {
    weaponEl.hidden = !(hudVisible && weaponShown);
}

function setWeaponIcon(name) {
    if (!name) {
        weaponIcon.hidden = true;
        weaponIcon.removeAttribute('src');
        return;
    }
    const src = `weapons/${name}.png`;
    if (weaponIcon.getAttribute('src') !== src) {
        weaponIcon.src = src;
        weaponIcon.classList.remove('swap');
        void weaponIcon.offsetWidth;
        weaponIcon.classList.add('swap');
    }
    weaponIcon.hidden = false;
}

function onWeapon(data) {
    weaponShown = !!data.show;
    if (weaponShown) {
        const w = data.data || {};
        const hasClip = w.clip !== undefined;
        const hasCount = w.count !== undefined;
        $('#ammo').hidden = !(hasClip || hasCount);
        const clip = $('#ammo-clip');
        clip.textContent = fmt.format(hasClip ? w.clip : (w.count || 0));
        clip.classList.toggle('empty', (hasClip && w.clip === 0) || (hasCount && w.count === 0));
        $('#ammo-reserve').hidden = !hasClip;
        if (hasClip) $('#ammo-reserve').textContent = fmt.format(w.reserve);
        setWeaponIcon(w.icon);
    }
    renderWeapon();
}

weaponIcon.addEventListener('error', () => setWeaponIcon(null));

const menu = $('#menu');
const sections = $('#menu-sections');

function buildMenu(text) {
    sections.textContent = '';
    MENU.forEach(([id, options]) => {
        const h = document.createElement('h2');
        h.textContent = text.sections[id] || id;
        sections.appendChild(h);
        options.forEach(([key, callback]) => {
            const opt = document.createElement('label');
            opt.className = 'opt';
            opt.innerHTML = `<span></span><input type="checkbox" data-key="${key}" data-cb="${callback}"><i class="sw"></i>`;
            opt.querySelector('span').textContent = text.options[key] || key;
            sections.appendChild(opt);
        });
    });
    syncMenuInputs();
}

function applyMenuText(text) {
    $('#menu-title').textContent = text.title || '';
    $('#btn-restart').textContent = text.restart || '';
    $('#btn-reset').textContent = text.reset || '';
    buildMenu(text);
}

sections.addEventListener('change', (e) => {
    const input = e.target;
    if (!input.dataset.key) return;
    settings[input.dataset.key] = input.checked;
    post(input.dataset.cb);
    applyMapClasses();
});

function closeMenu() {
    if (menu.hidden) return;
    menu.hidden = true;
    post('closeMenu');
}

$('#menu-close').addEventListener('click', closeMenu);
$('#btn-restart').addEventListener('click', () => { closeMenu(); post('restartHud'); });
$('#btn-reset').addEventListener('click', () => { closeMenu(); post('resetStorage'); });
document.addEventListener('keyup', (e) => { if (e.key === 'Escape') closeMenu(); });

window.addEventListener('message', (e) => {
    const data = e.data || {};
    switch (data.action) {
        case 'hudtick': onHudTick(data); break;
        case 'voice': onVoice(data); break;
        case 'car': onCar(data); break;
        case 'update': onHeading(data); break;
        case 'baseplate': onBaseplate(data); break;
        case 'show': onShowMoney(data); break;
        case 'updatemoney': onUpdateMoney(data); break;
        case 'weapon': onWeapon(data); break;
        case 'setting': onSetting(data.key, data.value); break;
        case 'open': menu.hidden = false; syncMenuInputs(); break;
        case 'config':
            $('#speed-unit').textContent = data.unit || SPEED_UNIT;
            fullHealthInVehicle = !!data.fullHealthInVehicle;
            vehicleHealthTimeout = num(data.vehicleHealthTimeout, 6000);
            vehicleHealthLow = num(data.vehicleHealthLow, 50);
            statusTimeout = num(data.statusTimeout, 6000);
            statusAlways = !!data.statusAlways;
            navText = data.nav || {};
            navUnits = data.navUnits === 'metric' ? 'metric' : 'imperial';
            if (data.locale) document.documentElement.lang = data.locale;
            if (data.menu) applyMenuText(data.menu);
            break;
    }
});

applyMapClasses();
post('nuiReady');
