# CleanFrame na Samsung QE55Q70R (2019, Tizen 5.0)

Ova kopija CleanFramea prilagođena je za **QE55Q70RATXXH**, softver **T-MSMDEUC-1500.9**.
Original je napravljen za The Frame iz 2024. (Tizen 9.0).

## Što je promijenjeno

| Promjena | Zašto |
| --- | --- |
| `app/config.xml`: `required_version` 6.5 → **5.0** | Tvoj TV ima Tizen 5.0; s 6.5 instalacija bi bila odbijena |
| `app/style.css`: `inset:0` → `top/right/bottom/left:0` | Preglednik u Tizenu 5.0 (Chromium ~63) ne zna `inset` |
| `app/flexgap-fallback.css` + kratka skripta u `app/index.html` | Chromium 63 ne zna flexbox `gap`. Skripta to otkrije i uključi zamjenske margine |
| `scripts/flexgap-fallback.py` | Generira `flexgap-fallback.css` iz `style.css` (`npm run css:flexgap` nakon promjene nekog `gap`) |

Provjereno u pregledniku: raspored s isključenim `gap` + zamjenskim CSS-om identičan je originalu
do piksela u svim Home rasporedima, postavkama, editoru i odabiru pozadine. Autorovi testovi
(`check:browser`, 344 provjere) prolaze. **Na pravom TV-u ovo još nije isprobano.**

Ne radi se zamjena Samsungovog Home ekrana (to je samo za The Frame 2024 i rizično je).
CleanFrame se instalira kao obična aplikacija i otvara iz **Apps**.

## Što ti treba (na računalu)

- Računalo na istoj mreži kao TV
- [Node.js 22+](https://nodejs.org) i [Python 3.10+](https://python.org)
- [Tizen Studio](https://developer.samsung.com/smarttv/develop/getting-started/setting-up-sdk/installing-tv-sdk.html):
  u Package Manageru instaliraj **Extension SDK → TV Extensions** i **Samsung Certificate Extension**
- Samsung račun

## 1. Napravi paket

```sh
git clone -b claude/cleanframe-samsung-tv-5j1xqj https://github.com/ckhour1/zadatakUHP.git
cd zadatakUHP/CleanFrame
npm ci
npm run dev:public          # (neobavezno) pregled na http://localhost:4795/home/
npm run export:public       # -> dist/CleanFrame-public-unsigned.wgt
```

Raspakiraj nepotpisani paket u mapu `build`:

```sh
mkdir build && cd build && tar -xf ../dist/CleanFrame-public-unsigned.wgt && cd ..
```

(Na Windowsu: preimenuj `.wgt` u `.zip` i raspakiraj u `build`.)

## 2. Developer Mode na TV-u

1. Doznaj IP svog **računala** (Windows: `ipconfig`, Mac: Postavke sustava → Mreža).
2. Na TV-u: **Home → Aplikacije (Apps)**.
3. Na daljinskom upiši **1 2 3 4 5** (Smart daljinski: tipka **123** za brojčanik).
4. **Developer mode → On**, a kao Host PC IP upiši **IP računala**. OK.
5. Isključi TV **iz struje**, pričekaj 10 s i ponovno uključi.

IP TV-a: **Postavke → Općenito → Mreža → Status mreže → IP postavke**.

## 3. Spoji se na TV

Alati su u mapi Tizen Studija (Windows: `C:\tizen-studio\tools\sdb.exe` i `C:\tizen-studio\tools\ide\bin\tizen.bat`).

```sh
sdb connect <IP_TV-a>:26101
sdb devices                 # zapamti ime uređaja, npr. QE55Q70R...
sdb capability              # treba pisati platform_version:5.0
```

## 4. Certifikat

Tizen Studio → **Tools → Certificate Manager → + → Samsung → TV**.
Napravi novi profil (npr. `MojTV`), author certifikat, prijavi se Samsung računom,
zatim distributor certifikat s razinom **Public**. **DUID** tvog TV-a pojavi se sam
dok je TV spojen preko `sdb`.

## 5. Potpiši, instaliraj, pokreni

```sh
tizen package -t wgt -s MojTV -o dist -- build
tizen install -n CleanFrame.wgt -s <ime_uređaja> -- dist
tizen run -p nClrkHome1.FrameHome -s <ime_uređaja>
```

Točno ime potpisane datoteke u `dist/` provjeri prije instalacije. Ako `tizen install` samo prenese
datoteku, a aplikacija se ne pojavi, instaliraj ručno:

```sh
sdb -s <IP_TV-a>:26101 push dist/CleanFrame.wgt /home/owner/share/tmp/sdk_tools/cf.wgt
sdb -s <IP_TV-a>:26101 shell 0 vd_appinstall nClrkHome1.FrameHome /home/owner/share/tmp/sdk_tools/cf.wgt
```

CleanFrame se zatim nalazi u **Aplikacijama**.

## Što provjeriti na TV-u

- Izgledaju li razmaci, ikone i fokus kao u pregledniku na računalu?
- Otvaraju li se Netflix, YouTube i ostale aplikacije (Postavke → Apps → otkrivanje instaliranih aplikacija)?
- Gumbi **Art Mode**, **Samsung Home** i **Postavke TV-a** koriste ID-jeve iz 2024. modela
  (`org.tizen.art-app`, `com.samsung.tv.csfs`, `com.samsung.tv.coba.setting`). Q70R nema Art Mode
  (ima Ambient Mode), pa ti gumbi vjerojatno samo prikažu poruku o grešci. Popis stvarnih
  ID-jeva dobiješ sa `sdb -s <IP_TV-a>:26101 shell 0 applist`, pa ih se može ispraviti u `app/device.js`.

Ako nešto izgleda krivo, slikaj ekran i pošalji.
