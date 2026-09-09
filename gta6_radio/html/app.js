const $ = (s) => document.querySelector(s);
const radio = $('#radio');
const track = $('#track');
const nameEl = $('#name');
let stations = [];
let current = 255;
const resource = typeof GetParentResourceName === 'function' ? GetParentResourceName() : 'gta6_radio';

function iconFor(station) {
    return `stations/station_${station.name}.png`;
}

function renderStations() {
    track.innerHTML = '';
    stations.forEach((station) => {
        const tile = document.createElement('div');
        tile.className = 'tile';
        tile.dataset.index = station.index;
        const img = new Image();
        img.onload = () => { tile.style.backgroundImage = `url("${img.src}")`; };
        img.onerror = () => { tile.style.backgroundImage = 'url("stations/station__unknown.png")'; };
        img.src = iconFor(station);
        track.appendChild(tile);
    });
    renderCurrent();
}

function renderCurrent() {
    const tiles = Array.from(track.children);
    let pos = stations.findIndex((s) => s.index === current);
    if (pos < 0) pos = stations.length - 1;
    tiles.forEach((tile, i) => tile.classList.toggle('current', i === pos));
    const station = stations[pos];
    nameEl.textContent = station ? station.label : '';
    if (!tiles.length) return;
    const css = getComputedStyle(document.getElementById('root'));
    const gap = parseFloat(getComputedStyle(track).gap);
    const u = gap / parseFloat(css.getPropertyValue('--gap-n'));
    const tile = parseFloat(css.getPropertyValue('--tile-n')) * u;
    const big = parseFloat(css.getPropertyValue('--tile-current-n')) * u;
    const viewport = 5 * tile + 4 * gap + (big - tile);
    track.style.transform = `translateX(${viewport / 2 - big / 2 - pos * (tile + gap)}px)`;
}

window.addEventListener('message', (e) => {
    const data = e.data || {};
    switch (data.action) {
        case 'stations':
            stations = Array.isArray(data.stations) ? data.stations : [];
            renderStations();
            break;
        case 'radio':
            if (typeof data.current === 'number') current = data.current;
            radio.hidden = !data.show;
            if (data.show) renderCurrent();
            break;
        case 'config':
            if (data.top) document.getElementById('root').style.setProperty('--top', data.top);
            break;
    }
});

window.addEventListener('resize', () => { if (!radio.hidden) renderCurrent(); });

fetch(`https://${resource}/ready`, { method: 'POST', body: '{}' });
