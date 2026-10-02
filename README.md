# Sunshine VDA

**Sunshine VDA** is an advanced self-hosted game and desktop stream host for [Moonlight](https://moonlight-stream.org/) clients. It combines the robust streaming engine and network stack of **[LizardByte/Sunshine](https://github.com/LizardByte/Sunshine)** with the native Windows Virtual Display driver (**SudoVDA**) and automated physical display management originally designed in **[ClassicOldSong/Apollo](https://github.com/ClassicOldSong/Apollo)**.

Offering low latency, dynamic client-matched resolutions, HDR support, and hardware-accelerated encoding for AMD, Intel, and Nvidia GPUs, Sunshine VDA allows you to turn your Windows PC into a dedicated cloud gaming and remote desktop server without requiring physical monitors to stay on or needing dummy HDMI/DisplayPort plugs.

---

## 1. Origins of this Fork

Sunshine VDA bridges two pivotal projects in the game streaming ecosystem:

* **[LizardByte/Sunshine](https://github.com/LizardByte/Sunshine):** The upstream, open-source GameStream host with multi-platform support, active community development, and robust WAN streaming capabilities.
* **[ClassicOldSong/Apollo](https://github.com/ClassicOldSong/Apollo):** A specialized fork that introduced **SudoVDA** (an IddCx-based virtual display driver), automated physical monitor management (`ensure_only_display`), and per-client display identity.

**Sunshine VDA** builds upon these foundations by integrating the virtual display architecture into a streamlined codebase while resolving critical GPU startup deadlocks, virtual display session recovery bugs, and WAN/cellular network routing edge cases.

---

## 2. Core Features

* **Native SudoVDA Virtual Display:** Creates a high-performance virtual monitor on demand that automatically adopts the exact resolution and refresh rate requested by your Moonlight client (up to 4K+, 120Hz/144Hz+).
* **Automated Physical Display Management (`ensure_only_display`):** Automatically puts physical monitors into sleep/standby mode when a stream starts to conserve power and ensure privacy, restoring them immediately upon disconnection.
* **Persistent Display Identity:** Unlike virtual display tools that assign random IDs on each launch, Sunshine VDA pairs persistent EDIDs with client certificates. Windows natively remembers your scaling (DPI), desktop layout, and preferences per client device.
* **Client Display Mode Override (`display_mode`):** Force custom aspect ratios and resolutions (e.g. 16:10 such as `1280x800` or `1920x1200` for tablets and handhelds) on the server side, even if your client's UI only presents standard 16:9 dropdown choices.
* **Universal Hardware Acceleration:** Low-latency hardware encoding using AMD AMF, Nvidia NVENC, and Intel QuickSync/VAAPI.
* **Integrated Web Management Interface:** Secure browser-based configuration, PIN-based client pairing, and fine-grained permission controls (mouse, keyboard, launch permissions, clipboard synchronization).
* **Virtual Audio Routing:** Automatic routing of system audio to a dedicated virtual stereo sink during streaming.

---

## 3. Custom Improvements in this Fork

This fork introduces key architectural fixes and optimizations:

### A. AMD AMF Encoder Startup Deadlock Fix
* **Problem:** In upstream Apollo and certain Sunshine builds, initializing encoder probes on modern AMD Radeon GPUs (RDNA/RDNA2/RDNA3 architectures) triggered an indefinite hang with 100% CPU usage on a single thread. This was caused by invoking `avcodec_send_frame(..., nullptr)` to drain a codec session that had not received any frames.
* **Fix:** Eliminated the unnecessary drain call during initial encoder enumeration (`src/video.cpp`), allowing AMD AMF hardware encoding (`hevc_amf`, `h264_amf`) to initialize instantly and reliably.

### B. Virtual Display Lifecycle & Session Reconnection
* **Problem:** When a streaming client disconnected, the virtual display was dismantled. If the application session remained paused (`terminate-on-pause = false`), subsequent reconnects executed `resume()` rather than a fresh `launch()`, failing to recreate the virtual display and causing DXGI capture errors (`Failed to locate an output device`).
* **Fix:** Enforced clean session teardown and automated re-creation hooks, ensuring that every reconnection reliably reinitializes the SudoVDA display adapter with zero capture stalling.

### C. WAN, Double-NAT & Cellular (4G/5G) Compatibility
* **IPv6 Routing Blackhole Prevention:** Cellular networks frequently provision native IPv6. When hosts advertise dual-stack (`both`) across routers with IPv4-only DMZ/Port Forwarding, mobile clients could stall trying to negotiate unreachable IPv6 endpoints. Sunshine VDA provides streamlined IPv4 enforcement (`address_family = ipv4`) to guarantee direct NAT routing.
* **Firewall NAT Traversal:** Comprehensive configuration guides for Windows Defender Firewall `EdgeTraversalPolicy` to prevent silent dropping of inbound UDP video and audio packets (ports 47998–48010) over WAN.

### D. Refined Multi-Device Coexistence
* Enhanced handling of simultaneous client profiles (e.g. Steam Deck, handheld PCs, tablets, laptops) ensuring that each device's specific resolution, aspect ratio, and Windows DPI scaling profile remain completely isolated.

---

## 4. Quick Start & Installation

### Requirements
* **Operating System:** Windows 10 (64-bit) or Windows 11 (64-bit).
* **GPU:**
  * AMD: Radeon RX 400 series or newer (VCE / AMF support).
  * Nvidia: GeForce GTX 900 series or newer (NVENC support).
  * Intel: Skylake HD Graphics 500 series or newer (QuickSync support).

### Installation
1. Download the latest installer (`Sunshine-VirtualDisplay-*.exe`) from the [Releases](https://github.com/fedehda/Sunshine_vda/releases) page.
2. Run the installer with Administrator privileges to install the Sunshine service and the SudoVDA driver.
3. Access the Web UI in your browser at `https://localhost:47990`.
4. Configure your credentials on first launch.
5. In Moonlight on your client device, select your PC and enter the pairing PIN in the Sunshine Web UI under the **PIN** tab.

---

## 5. Network Configuration (WAN / Internet Streaming)

If you plan to stream over the internet or cellular data, ensure the following ports are forwarded to your host PC:

| Port | Protocol | Purpose |
| :--- | :--- | :--- |
| **47984** | TCP | HTTPS Control / App List / Launch |
| **47989** | TCP | HTTP Server Discovery |
| **48010** | TCP | RTSP Video Handshake |
| **47998** | UDP | Video Streaming Data |
| **47999** | UDP | Control / Ping Packets |
| **48000** | UDP | Audio Streaming Data |
| **48002** | UDP | Secondary Streaming Data |
| **48010** | UDP | Voice / Microphone Stream |

> [!TIP]
> If streaming from mobile networks (4G/LTE/5G) through a router with IPv4 Port Forwarding or DMZ, ensure `address_family = ipv4` is set in `sunshine.conf` to prevent cellular clients from attempting unreachable IPv6 routes.

---

## 6. Credits & Acknowledgments

* **[LizardByte/Sunshine](https://github.com/LizardByte/Sunshine):** Upstream foundation, multi-platform streaming engine, and community maintenance.
* **[ClassicOldSong/Apollo](https://github.com/ClassicOldSong/Apollo):** SudoVDA driver integration and display management architecture.
* **[Moonlight Game Streaming](https://moonlight-stream.org/):** The client ecosystem that makes low-latency remote gaming possible.

---

## 7. License

Sunshine VDA is free and open-source software licensed under the **GNU General Public License v3.0 (GPLv3)**. See the [LICENSE](LICENSE) file for details.
