# AtomVM Elixir Firmware Example: Wi-Fi SNTP Clock for ESP32 

A minimal AtomVM project that:

- Provisions Wi-Fi credentials via environment variables
- Saves them to NVS (non-volatile storage)
- Connects to Wi-Fi and syncs time via SNTP
- Logs human-readable local time to the console every second

## Requirements

For the most up-to-date ESP32 hardware and software requirements, 
refer to the [official AtomVM Getting Started Guide](https://doc.atomvm.org/latest/getting-started-guide.html).

### Hardware

- An ESP32 board supported by AtomVM

### Software

- Erlang/OTP 27
- Elixir 1.17.x
- AtomVM toolchain (via [`exatomvm`](https://github.com/atomvm/exatomvm))
- A serial monitor tool such as:
  - `picocom`
  - `screen`
  - `minicom`

### Network

- A 2.4 GHz Wi-Fi network
- Internet access (required for SNTP time synchronization)

## Quickstart

### Fetch dependencies

From the project root:

```sh
mix deps.get
```

### Install AtomVM (one-time)

Flash the AtomVM runtime to your ESP32:

```sh
mix atomvm.esp32.install
```

Adjust the serial port if needed (for example `/dev/ttyUSB0`).

### Set Wi-Fi credentials (build-time provisioning)

Export your Wi-Fi credentials as environment variables before building/flashing:

```sh
export ATOMVM_WIFI_SSID="your-ssid"
export ATOMVM_WIFI_PASSPHRASE="your-passphrase"
```

Optional:

```sh
# If set (any non-empty value), overwrite NVS credentials on every boot
export ATOMVM_WIFI_FORCE=true
```

### Build and flash the application

```sh
mix clean
mix atomvm.esp32.flash --port /dev/ttyACM0
```

During the first boot, the firmware will:

- Store Wi-Fi credentials in NVS
- Connect to the access point (STA mode)
- Synchronize time via SNTP
- Start logging local time once per second

### Monitor logs

Open a serial console:

```sh
picocom /dev/ttyACM0
```

You should see logs like:

```text
wifi: first-time provision (stored Wi-Fi credentials in NVS)
wifi: started
wifi: connected to AP
wifi: got IP {192,168,1,123}
sntp: synced {tv_sec, tv_usec}
time: 2026-01-23 21:42:01 (JST)
```

## Firmware provisioning options

Wi-Fi credentials can be provisioned at build time using environment variables.
On boot, they are stored in ESP32 NVS and reused on subsequent boots.

### Environment variables

| Environment variable     | NVS key           | Description                                                                    |
| ------------------------ | ----------------- | ------------------------------------------------------------------------------ |
| `ATOMVM_WIFI_SSID`       | `wifi_ssid`       | Wi-Fi SSID to store in NVS                                                     |
| `ATOMVM_WIFI_PASSPHRASE` | `wifi_passphrase` | Wi-Fi passphrase (optional; omit for open networks)                            |
| `ATOMVM_WIFI_FORCE`      | —                 | If set (any non-empty value), overwrite existing NVS credentials on every boot |

### Provisioning behavior

- **First boot (NVS empty)**
  - If `ATOMVM_WIFI_SSID` is set, credentials are written to NVS.

- **Subsequent boots**
  - Stored NVS credentials are reused.

- **Forced provisioning** (`ATOMVM_WIFI_FORCE` set)
  - NVS credentials are overwritten on every boot.
  - If no passphrase is provided, any existing passphrase is removed (open network).

This allows you to:

- Flash once and reboot freely without re-exporting credentials
- Re-provision Wi-Fi by flashing again with `ATOMVM_WIFI_FORCE=true`
