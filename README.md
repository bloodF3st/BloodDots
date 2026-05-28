# ⛧ BloodDots

Мои конфиги для Arch Linux с Hyprland. Catppuccin Mocha везде.

---

## Оболочка

**Fish** — основной шелл.
**Starship** — промпт. Показывает текущую папку, git-ветку и время последней команды. Символы `[ ]` вместо стандартных стрелок.
**Fastfetch** — выводится при каждом открытии терминала. Логотип подбирает HyDE автоматически под текущую тему, рендерится через Kitty graphics protocol.

---

## Рабочее окружение

| Компонент | Что |
|---|---|
| WM | [Hyprland](https://hyprland.org) |
| Бар | [Waybar](https://github.com/Alexays/Waybar) + [Quickshell](https://quickshell.outfoxxed.me) (тема ii / illogical-impulse) |
| Терминал | [Kitty](https://sw.kovidgoyal.net/kitty) |
| Лаунчер | [Rofi](https://github.com/davatorium/rofi) / [Fuzzel](https://codeberg.org/dnkl/fuzzel) |
| Уведомления | [Dunst](https://dunst-project.org) |
| Блокировка | [Hyprlock](https://github.com/hyprwm/hyprlock) |
| Idle | [Hypridle](https://github.com/hyprwm/hypridle) |
| Обои | [swww](https://github.com/LGFae/swww) / [mpvpaper](https://github.com/GhostNaN/mpvpaper) |

---

## Тема

**Catppuccin Mocha** — единая цветовая схема для всего.

| Элемент | Что применено |
|---|---|
| GTK 2/3/4 | catppuccin-gtk-theme-mocha |
| Qt | qt5ct + qt6ct + Kvantum |
| Курсор | Catppuccin Mocha (Bibata Modern Classic) |
| Иконки | Papirus + Catppuccin folders |
| Firefox | кастомный userChrome (Catppuccin) |
| Spotify | Spicetify |

---

## Шрифты

- **JetBrains Mono Nerd** — терминал, код
- **Google Sans Flex** — интерфейс
- **Maple Mono** — альтернатива в редакторе
- **SF Pro** — системный UI
- **Noto** — CJK, emoji, fallback

---

## Редактор

**Neovim** с конфигом на базе [LazyVim](https://lazyvim.org).

---

## Установка

```bash
git clone git@github.com:bloodF3st/BloodDots.git ~/dotfiles
cd ~/dotfiles
bash install.sh
```

Флаги:
- `--no-packages` — только конфиги, без установки пакетов
- `--no-configs` — только пакеты
- `--no-system` — не трогать `/etc/`

---

## Структура

```
configs/     — XDG конфиги (~/.config/)
home/        — домашние дотфайлы (.bashrc, .gitconfig и др.)
system/      — системные конфиги (/etc/)
firefox/     — userChrome + user.js
fonts/       — информация об установленных шрифтах
install.sh   — установщик
backup.sh    — скрипт бэкапа (запускается по таймеру)
```
