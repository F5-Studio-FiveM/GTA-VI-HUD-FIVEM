<div align="center">

<img src="https://i.imgur.com/Fpp12Ev.png" alt="GTA VI HUD for FiveM" width="780" />

<br />

<a href="https://dc.f5stud.io"><img src="https://img.shields.io/discord/1396957541530865927?label=discord&style=for-the-badge&color=5865F2&labelColor=16161d" alt="Discord" /></a>

<br /><br />

<img src="https://img.shields.io/badge/6_Resources-install_what_you_need-f5a623?style=flat-square&labelColor=16161d" alt="6 resources" />&nbsp;
<img src="https://img.shields.io/badge/QBCore_·_QBox_·_ESX-auto--detected-f5a623?style=flat-square&labelColor=16161d" alt="Frameworks" />&nbsp;
<img src="https://img.shields.io/badge/Database-not_required-f5a623?style=flat-square&labelColor=16161d" alt="No database" />&nbsp;
<img src="https://img.shields.io/badge/Assets-bundled,_no_CDN-f5a623?style=flat-square&labelColor=16161d" alt="No CDN" />

<br /><br />

A GTA VI style HUD for FiveM, split into six resources.<br />
Status bars, minimap, notifications, radio strip and weapon block. Take the whole set or just the parts you want.

<br />

[**Read the Docs**](https://docs.f5stud.io/docs/gta6-inspired-hud/overview) &nbsp;&nbsp;&middot;&nbsp;&nbsp; [**Join Discord**](https://dc.f5stud.io) &nbsp;&nbsp;&middot;&nbsp;&nbsp; [**Report a Bug**](https://github.com/F5-Studio-FiveM/GTA-VI-HUD-FIVEM/issues)

<br /><br />

<img src="https://i.imgur.com/fLlPBQp.png" alt="Every piece of the HUD on screen at once" width="100%" />

<sub>Compass, radio strip, weapon block, cash and bank, status bars, vehicle tile, navigation, minimap, speed and a notification card &mdash; all of it in the repo.</sub>

</div>

<br />

<img src="https://raw.githubusercontent.com/andreasbm/readme/master/assets/lines/rainbow.png" alt="" width="100%" />

<br />

<div align="center">
<h2>What you get</h2>
</div>

<br />

<table align="center">
<tr>
<td align="center" width="25%">
<br />
<img src="https://img.shields.io/badge/-One_HUD,_three_cores-f5a623?style=for-the-badge&labelColor=f5a623" alt="" />
<br /><br />
<sub>Checks for <b>qbx_core</b>, then <b>qb-core</b>, then <b>es_extended</b> at start. Each adapter gates itself, so nothing framework-specific runs when that framework is absent.</sub>
<br /><br />
</td>
<td align="center" width="25%">
<br />
<img src="https://img.shields.io/badge/-Six_separate_folders-f5a623?style=for-the-badge&labelColor=f5a623" alt="" />
<br /><br />
<sub>Every folder is its own resource with its own <code>fxmanifest.lua</code>. Want <b>only</b> the notifications, or <b>only</b> the minimap? Copy that one folder.</sub>
<br /><br />
</td>
<td align="center" width="25%">
<br />
<img src="https://img.shields.io/badge/-Nothing_fetched_at_runtime-f5a623?style=for-the-badge&labelColor=f5a623" alt="" />
<br /><br />
<sub>Fonts, icons, sounds and map tiles all ship in the repo. The NUI makes <b>zero outbound requests</b>. No database, no Keymaster, no SQL.</sub>
<br /><br />
</td>
<td align="center" width="25%">
<br />
<img src="https://img.shields.io/badge/-Reads_the_game-f5a623?style=for-the-badge&labelColor=f5a623" alt="" />
<br /><br />
<sub>Health, speed, fuel, weapon, compass and zone come from <b>natives</b>. The framework only supplies what the game does not know: hunger, thirst, stress, cash, seatbelt.</sub>
<br /><br />
</td>
</tr>
</table>

<br />

<img src="https://raw.githubusercontent.com/andreasbm/readme/master/assets/lines/rainbow.png" alt="" width="100%" />

<br />

<div align="center">
<h2>The six resources</h2>
</div>

<br />

<div align="center">

| Resource | What it does | Needs a framework |
|:---|:---|:---|
| **gta6_hud** | The full HUD: status bars, cash and bank, vehicle column, compass, weapon block, minimap, settings menu | QBCore, QBox or ESX (optional, see below) |
| **gta6_notify** | Card notifications, 11 types, 9 positions, queue, duplicate merging, Lua API | No |
| **gta6_radio** | Station strip that replaces the native radio wheel while `Q` is held | No |
| **gta6_weaponhud** | Only the weapon and ammo block, for servers keeping their own HUD | No |
| **gta6_minimap** | Only the minimap swap: mask, position, route colour, fixed zoom | No |
| **gta6_atlasmap** | Coloured Atlas map tiles for the radar and pause menu | No |

</div>

<br />

<img src="https://raw.githubusercontent.com/andreasbm/readme/master/assets/lines/rainbow.png" alt="" width="100%" />

<br />

<div align="center">
<h2>Before you install: what goes with what</h2>
</div>

<br />

**`gta6_hud` already contains the weapon block and the minimap swap.** That is the only thing in this repo you can get wrong, so it is worth thirty seconds:

| Combination | Verdict |
|:---|:---|
| `gta6_hud` + `gta6_minimap` | **Do not.** Both stream `minimap.gfx`, `minimap.ytd` and `gta6_graphics.ytd`, and neither has a switch to turn the minimap off. |
| `gta6_hud` + `gta6_weaponhud` | Only after setting `Config.CustomWeaponHud = false` in `gta6_hud`. Otherwise you get two weapon blocks in the same corner. No files collide, so this one is just a config change. |
| `gta6_notify`, `gta6_radio`, `gta6_atlasmap` | Fine with anything, including a third-party HUD. |

Two setups that cover most servers:

```cfg
# Full GTA VI look
ensure gta6_hud
ensure gta6_notify
ensure gta6_radio
ensure gta6_atlasmap

# Keep your own HUD, borrow the pieces
ensure gta6_minimap
ensure gta6_weaponhud
ensure gta6_notify
ensure gta6_atlasmap
```

<br />

<img src="https://raw.githubusercontent.com/andreasbm/readme/master/assets/lines/rainbow.png" alt="" width="100%" />

<br />

<div align="center">
<h2>Quick Start</h2>
</div>

<br />

```bash
cd resources
git clone https://github.com/F5-Studio-FiveM/GTA-VI-HUD-FIVEM.git
```

Rename the cloned folder to `[gta6]`, or move the resource folders you want into a `[gta6]` category of your own. Delete the ones you do not want, then add to `server.cfg`, after your framework:

```cfg
ensure qb-core      # or qbx_core / es_extended
ensure [gta6]
```

> **That's it.** No SQL, no config edits needed to start. Press `I` in-game to open the HUD settings menu.

Framework-specific steps (turning off `qb-hud` or `esx_hud`, pointing `esx_cruisecontrol` at the HUD, routing framework notifications through `gta6_notify`) are on the docs site, linked under each resource below.

<br />

<img src="https://raw.githubusercontent.com/andreasbm/readme/master/assets/lines/rainbow.png" alt="" width="100%" />

<br />

<div align="center">
<h2>gta6_hud</h2>
</div>

<!-- SCREENSHOT gta6_hud: on foot and in a vehicle, showing status bars, minimap and the vehicle column. Replace src and uncomment.
<img src="" alt="gta6_hud" width="100%" />
-->

The whole HUD in one resource. It detects `qbx_core`, `qb-core` or `es_extended` at start and loads the matching adapter. The core is native-driven, so if no framework is running it still works: minimap, compass, speedometer, fuel, engine, weapon block and voice chip all keep going, and only the values the game cannot supply (hunger, thirst, stress, cash and bank, seatbelt, cruise control) stay at their defaults.

Status bars are not permanently parked on screen. Hunger, thirst, stress and in-vehicle health appear for six seconds after they change in either direction, so you get confirmation when you eat or drink as well as when you drop. They stay pinned once hunger or thirst hits 30, or stress hits 75. If you would rather have them always visible, `Config.ShowStatusAlways` and `Config.ShowFullHealthInVehicle` do that.

In a vehicle you get a column above the minimap: a zone-name pill, a turn-by-turn navigation pill when a waypoint is set, and a vehicle tile. The navigation distance only shows on actual turn manoeuvres, because the game native measures to the nearest junction rather than to the manoeuvre.

**Menu** `/hudmenu` (default `I`) with 24 toggles, saved per player. **Commands** `/resethud`, plus `/cash`, `/bank` and `/dev` on QBCore and QBox. **Languages** Twelve, one file each in `gta6_hud/locales/`, picked with `Config.Locale`. **Optional** `pma-voice` for the microphone chip, `LegacyFuel` (or anything with `provide 'LegacyFuel'`) for fuel, `interact-sound` for menu sounds, `gta6_notify` for notifications in the same style.

[**Read the docs**](https://docs.f5stud.io/docs/category/gta6-hud)

<br />

<img src="https://raw.githubusercontent.com/andreasbm/readme/master/assets/lines/rainbow.png" alt="" width="100%" />

<br />

<div align="center">
<h2>gta6_notify</h2>
</div>

<!-- SCREENSHOT gta6_notify: a few notification cards of different types stacked. Replace src and uncomment.
<img src="" alt="gta6_notify" width="100%" />
-->

Standalone notification cards. 11 built-in types (`success`, `error`, `warning`, `info`, `money`, `car`, `house`, `heart`, `location`, `objective`, `question`), each with its own icon and accent colour, plus aliases for the type names QBCore and ESX scripts already use. Nine screen positions, with a per-position visible limit and a queue behind it.

Send the same notification twice while the first is still up and it does not stack: the existing card gets an `×N` counter, a refreshed timer and a short bump. Cards hide while the pause menu is open and come back after, with their timers still running.

```lua
-- client
exports.gta6_notify:Notify({ type = 'money', message = '+$8,500', title = 'BANK' })
exports.gta6_notify:Notify('Vehicle stored in the garage', 'car')

-- server
exports.gta6_notify:Notify(source, { type = 'success', message = 'Done' })
```

The `esx_notify` signature `(type, length, message)` is accepted too, so a lot of existing code needs no changes. Routing an entire framework's notifications through it is a one-line patch in `qb-core` or `es_extended`, written out in the docs. Test it in-game with `/gta6notify success`.

Default position is `bottom-center`. Three notification sounds are bundled; `digital-quick-tone.ogg` is the default.

[**Read the docs**](https://docs.f5stud.io/docs/category/gta6-notify)

<br />

<img src="https://raw.githubusercontent.com/andreasbm/readme/master/assets/lines/rainbow.png" alt="" width="100%" />

<br />

<div align="center">
<h2>gta6_radio</h2>
</div>

<!-- SCREENSHOT gta6_radio: the station strip at the top of the screen with a station selected. Replace src and uncomment.
<img src="" alt="gta6_radio" width="100%" />
-->

Replaces the native radio wheel with a horizontal strip of station tiles at the top of the screen. Hold the radio key (`Q` by default) in a vehicle to bring it up, then the mouse wheel or the left and right arrows move the selection. The last position turns the radio off, and unlike the native wheel, you can turn it back on again afterwards.

The station list is rebuilt every time you enter a vehicle, straight from the game's unlocked-station natives, so DLC stations and any custom stations your server adds show up on their own. A station with no matching logo gets a neutral fallback tile. 28 tiles ship with the resource, 26 of them station logos.

Let go of the key and control goes back to the game. The strip also appears on its own for a couple of seconds whenever the station changes, so it doubles as a "now playing" indicator. It sits at `9vh` by default, which puts it just under the `gta6_hud` compass, and `Config.Top` moves it if you use a different HUD.

[**Read the docs**](https://docs.f5stud.io/docs/category/gta6-radio)

<br />

<img src="https://raw.githubusercontent.com/andreasbm/readme/master/assets/lines/rainbow.png" alt="" width="100%" />

<br />

<div align="center">
<h2>gta6_weaponhud</h2>
</div>

<!-- SCREENSHOT gta6_weaponhud: top-right corner showing ammo count and weapon icon. Replace src and uncomment.
<img src="" alt="gta6_weaponhud" width="100%" />
-->

The weapon block on its own, for servers that are happy with their current HUD but want this corner. Draw a weapon and the ammo count appears top right with the weapon icon under it. Firearms show clip and reserve, with the reserve dimmed and an empty clip turning red. Thrown weapons and anything without a magazine show a single number, melee and stun guns show just the icon, and the block disappears when you are unarmed or in the pause menu. 101 weapon icons are included.

Instead of trying to detect other HUDs, it announces itself and lets them move:

```lua
AddEventHandler('gta6_weaponhud:state', function(visible, height)
    SendNUIMessage({ action = 'weaponhud', visible = visible, height = height })
end)
```

`height` is the measured block height in screen pixels, so a HUD with its own money block in that corner can slide it down by exactly the right amount. There is a matching `exports.gta6_weaponhud:GetState()` for HUDs that start later. If you do not want to integrate at all, just move the block with `Config.Position`.

[**Read the docs**](https://docs.f5stud.io/docs/category/gta6-weaponhud)

<br />

<img src="https://raw.githubusercontent.com/andreasbm/readme/master/assets/lines/rainbow.png" alt="" width="100%" />

<br />

<div align="center">
<h2>gta6_minimap</h2>
</div>

<!-- SCREENSHOT gta6_minimap: the rounded-rectangle radar in the bottom-left corner. Replace src and uncomment.
<img src="" alt="gta6_minimap" width="100%" />
-->

The minimap swap on its own: one client script, three streamed files, no config and no NUI. It replaces the radar mask with the rounded-rectangle shape, repositions and resizes the component, recolours the route and waypoint to the GTA VI pink, and holds the zoom steady with a re-apply every half second so it stops jumping when you change vehicle or walk into an interior.

It never calls `DisplayRadar`, so whether the radar is visible stays your HUD's decision. It does force the zoom and close an expanded bigmap, though, so if your existing HUD manages the radar itself the two will disagree. Turn the minimap off in that HUD, or skip this resource.

[**Read the docs**](https://docs.f5stud.io/docs/category/gta6-minimap)

<br />

<img src="https://raw.githubusercontent.com/andreasbm/readme/master/assets/lines/rainbow.png" alt="" width="100%" />

<br />

<div align="center">
<h2>gta6_atlasmap</h2>
</div>

<!-- SCREENSHOT gta6_atlasmap: the pause-menu map showing the coloured Atlas tiles. Replace src and uncomment.
<img src="" alt="gta6_atlasmap" width="100%" />
-->

Swaps GTA V's grey map for a coloured atlas-style one, on both the radar and the pause menu. It is a FiveM port of neen-atlasmap, MIT licensed, and it pairs well with the GTA VI minimap because the rounded radar frame looks better with a map that has some colour in it.

Zoom levels are set on start so the tiles stay sharp when you zoom in rather than turning to mush. There is an `EnableCayoMiniMap` switch at the top of `client.lua`, off by default, that adds the Cayo Perico blips and interior radar mode. No config file, no NUI, no framework.

[**Read the docs**](https://docs.f5stud.io/docs/category/gta6-atlasmap)

<br />

<img src="https://raw.githubusercontent.com/andreasbm/readme/master/assets/lines/rainbow.png" alt="" width="100%" />

<br />

<div align="center">
<h2>At a Glance</h2>
</div>

<br />

<div align="center">

| | |
|:---|:---|
| **Frameworks** | QBCore &nbsp;&bull;&nbsp; QBox Core &nbsp;&bull;&nbsp; ESX Legacy, detected at start |
| **Standalone** | gta6_notify &nbsp;&bull;&nbsp; gta6_radio &nbsp;&bull;&nbsp; gta6_weaponhud &nbsp;&bull;&nbsp; gta6_minimap &nbsp;&bull;&nbsp; gta6_atlasmap |
| **Database** | None. Player settings live in client KVP |
| **Hard dependencies** | None |
| **Optional** | pma-voice &nbsp;&bull;&nbsp; LegacyFuel &nbsp;&bull;&nbsp; interact-sound &nbsp;&bull;&nbsp; gta6_notify |
| **Languages** | Arabic &nbsp;&bull;&nbsp; Chinese &nbsp;&bull;&nbsp; Czech &nbsp;&bull;&nbsp; Dutch &nbsp;&bull;&nbsp; English &nbsp;&bull;&nbsp; French &nbsp;&bull;&nbsp; German &nbsp;&bull;&nbsp; Polish &nbsp;&bull;&nbsp; Portuguese &nbsp;&bull;&nbsp; Spanish &nbsp;&bull;&nbsp; Thai &nbsp;&bull;&nbsp; Turkish (gta6_hud) |
| **Assets** | Fonts, icons, sounds and tiles all bundled. No CDN requests |
| **Requirements** | A recent FiveM server build. Nothing else |

</div>

<br />

<img src="https://raw.githubusercontent.com/andreasbm/readme/master/assets/lines/rainbow.png" alt="" width="100%" />

<br />

<details>
<summary><b>What it does not do</b></summary>

<br />

Worth knowing before you swap out a HUD you already rely on.

Compared to **esx_hud**: no vehicle mileage stored in the database, no keybinds for indicators and engine, no colour panel.

Compared to **qb-hud**: settings are not loaded from the server. Defaults come from `Config.Menu` and each player's own changes are kept in client KVP.

Other limits worth knowing:

- Stress is QBCore and QBox only. ESX has no stress metadata to read.
- Navigation distance appears only on turn manoeuvres. The `GenerateDirectionsToCoord` native measures to the nearest junction, not to the manoeuvre, so showing it on "keep going straight" would be misleading.
- `ESX.ShowAdvancedNotification`, `ESX.ShowHelpNotification` and `ESX.ShowFloatingHelpNotification` do not route through `gta6_notify`. ESX draws those with game scaleforms, not through the notification function.

</details>

<details>
<summary><b>Credits and licences</b></summary>

<br />

The Lua and NUI code here was written for this collection. Most of the artwork was not, and the people who made it deserve the credit:

| Asset | Used in | Author |
|:---|:---|:---|
| GTA VI style minimap files | `gta6_hud`, `gta6_minimap` | **sbc17**, [GTA VI Styled Minimap & HUD (Legacy)](https://www.gta5-mods.com/misc/gta-vi-styled-minimap-legacy) |
| Weapon icons (101 sprites) | `gta6_hud`, `gta6_weaponhud` | **fbicat**, [GTA VI HUD (Legacy / Enhanced)](https://www.gta5-mods.com/scripts/gta-vi-hud-mod-893860ef-7b03-4c23-abd9-92b224291705). Sprites originate from GTA V's `hud.ytd` (Rockstar Games) |
| Radio station logos and the strip layout | `gta6_radio` | **fbicat**, same mod |
| Atlas map tiles and the FiveM port | `gta6_atlasmap` | Port: **NeenGame** (neen-atlasmap, MIT, `LICENSE` included). Map: **Loren Vidican** |
| Notification sounds | `gta6_notify` | **Mixkit**, Mixkit Sound Effects Free License |
| Inter, Montserrat SemiBold | `gta6_hud`, `gta6_radio` | SIL Open Font License 1.1, licence files bundled next to the fonts |
| Pricedown Bl | `gta6_hud`, `gta6_weaponhud` | Ray Larabie, freeware |

The GTA V sprites and logos are Rockstar Games assets, included for use on your own server. If you are redistributing this, that is the part to think about.

</details>

<br />

<img src="https://raw.githubusercontent.com/andreasbm/readme/master/assets/lines/rainbow.png" alt="" width="100%" />

<br />

<div align="center">
<h2>Contributing</h2>
</div>

<br />

Free, open source, and better with help.

- **Report bugs** by opening an [issue](https://github.com/F5-Studio-FiveM/GTA-VI-HUD-FIVEM/issues). Tell us which resource, which framework, and what the F8 console said.
- **Suggest features** through [issues](https://github.com/F5-Studio-FiveM/GTA-VI-HUD-FIVEM/issues) or [Discord](https://dc.f5stud.io)
- **Send pull requests** for fixes, features and optimisations
- **Add a language** by copying `gta6_hud/locales/en.lua` to your language code and translating it
- **Star the repo** if it is useful to you

<br />

<img src="https://raw.githubusercontent.com/andreasbm/readme/master/assets/lines/rainbow.png" alt="" width="100%" />

<br />

<div align="center">

<a href="https://docs.f5stud.io/docs/gta6-inspired-hud/overview"><img src="https://img.shields.io/badge/read_the_docs-docs.f5stud.io-f5a623?style=for-the-badge&labelColor=16161d&logoColor=white" alt="Documentation" height="35" /></a>
&nbsp;&nbsp;
<a href="https://dc.f5stud.io"><img src="https://img.shields.io/badge/join-discord-5865F2?style=for-the-badge&labelColor=16161d&logoColor=white" alt="Discord" height="35" /></a>
&nbsp;&nbsp;
<a href="https://f5stud.io"><img src="https://img.shields.io/badge/visit-f5stud.io-white?style=for-the-badge&labelColor=16161d&logoColor=white" alt="Website" height="35" /></a>

<br /><br />

<sub>Open source and free forever. Made by <a href="https://f5stud.io"><b>F5 Studio</b></a></sub>

</div>
