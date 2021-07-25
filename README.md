# Switchboard Services Plug
Plugin for managing services

<p align="left">
    <a href="https://paypal.me/Dirli85">
        <img src="https://img.shields.io/badge/Donate-PayPal-green.svg">
    </a>
</p>

---

![screenshot](data/screenshot.png?raw=true)

## Building and Installation

### You'll need the following dependencies:
* libswitchboard-2.0-dev
* libgranite-dev
* libgtk-3-dev
* libgee-0.8-dev
* libpolkit-gobject-1-dev
* meson
* valac

### How to build
    meson build --prefix=/usr
    ninja -C build
    sudo ninja install -C build
