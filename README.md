# FlaOS Router Firmware #
Based on Padavan with mtk 4.4.198 kernel, fetched from D-LINK GPL code.

- Features:
  - Based on 4.4.198 Linux kernel
  - Support MT7621 based devices
  - Support MT76x3/MT76x2/MT7615D(N)/MT7915D wireless chips
  - Support raeth and MT7621 hwnat 
  - Support qca shortcut-fe
  - IPv6 NAT based on netfilter
  - WireGuard integrated in kernel
  - Fullcone NAT (by Chion82)
  - LED&GPIO control via sysfs

- FlaOS exclusive features:
  - Brand new UI with optimized resource, usable in any device
  - Multi-dial via macvlan
  - First padavan Multi-wan
  - Optimal size for SPI NOR-based devices (full-featured with less than 10mb)
  - OTA upgrade (can be completely disabled for privacy)

- Supported devices
  - CR660x
  - MI-R4
  - MI-R3G
  - MI-R3P
  - MI-R4AG
  - R2100
  - RM2100
  - NEWIFI D2
  - DIR-878
  - DIR-882
  - JCG-Q20
  - JCG-AC860M
  - JCG-836PRO
  - JCG-Y2
  - K2P
  - K2P-USB
  - NETGEAR-BZV
  - MR2600
  - XY-C1
  - ZTE-E8820S

- Manuals
  - Controlling GPIO and LEDs via sysfs
  - How to use NAND RWFS partition
  - How to add new device support with device tree
