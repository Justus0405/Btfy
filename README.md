<p align="left">
    <!-- Discord Badge -->
    <a href="https://discord.justus0405.com/"><img src="https://img.shields.io/discord/1370519315400495234?logo=Discord&colorA=1e1e2e&colorB=a6e3a1&style=for-the-badge"></a>
    <!-- Version Badge -->
    <a href="https://github.com/Justus0405/Btfy/blob/main/Btfy"><img src="https://img.shields.io/badge/Version-1.0-blue?colorA=1e1e2e&colorB=cdd6f4&style=for-the-badge"></a>
</p>

<p align="left">
    <!-- Stars Badge -->
	<a href="https://github.com/Justus0405/Btfy/stargazers"><img src="https://img.shields.io/github/stars/Justus0405/Btfy?colorA=1e1e2e&colorB=b7bdf8&style=for-the-badge"></a>
    <!-- Issues Badge -->
	<a href="https://github.com/Justus0405/Btfy/issues"><img src="https://img.shields.io/github/issues/Justus0405/Btfy?colorA=1e1e2e&colorB=f5a97f&style=for-the-badge"></a>
    <!-- Contributors Badge -->
	<a href="https://github.com/Justus0405/Btfy/contributors"><img src="https://img.shields.io/github/contributors/Justus0405/Btfy?colorA=1e1e2e&colorB=a6da95&style=for-the-badge"></a>
</p>

# Btfy

Btfy is a small Bash script made for Termux. It checks your device battery status and sends updates to a Discord channel using a webhook.

> [!TIP]
> If you are experiencing sudden breakge of the script,
> disable deep sleep for termux using `termux-wake-lock`.

## Features

- Full Notification
- Charging Notification
- Discharging Notification
- Low Battery Notification
- Additional info like Temperature and Health

## Dependencies

```plaintext
termux-api
jq
curl
```

## Installation

1. Clone the repository:

```shell
git clone https://github.com/Justus0405/Btfy.git
```

2. Navigate to the directory:

```shell
cd Btfy
```

3. Make the script executable:

```shell
chmod +x btfy.sh
```

4. Edit the script to configure the webhook url and check interval:

```shell
nano btfy.sh
```

5. Run the script:

```shell
./btfy.sh
```

## Usage

```plaintext
usage: btfy.sh [...]
arguments:
	    start
	    stop
	    help
	    version
```

#

<p align="center">
	Copyright &copy; 2025-present <a href="https://github.com/Justus0405" target="_blank">Justus0405</a>
</p>

<p align="center">
	<a href="https://github.com/Justus0405/Btfy/blob/main/LICENSE"><img src="https://img.shields.io/github/license/Justus0405/Btfy?logo=Github&colorA=1e1e2e&colorB=cba6f7&style=for-the-badge"></a>
</p>
