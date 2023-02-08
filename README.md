# FlaOS for Mediatek-family Router Firmware #
Based on original Padavan rt-n56u with latest mtk 4.4.198 kernel, fetched from D-LINK GPL code.

- Features:
  - Based on 4.4.198 Linux kernel
  - Support MT7620/MT7621 based devices
  - Support MT7615D/MT7615N/MT7915D wireless chips
  - Support raeth and MT7621 hwnat with legacy driver
  - Support qca shortcut-fe
  - Support IPv6 NAT based on netfilter
  - Support WireGuard integrated in kernel
  - Support fullcone NAT (by Chion82)
  - Support LED&GPIO control via sysfs


- Supported devices
  - CR660x
  - MI-MINI (R1CM)
  - MI-R4
  - MI-R3G
  - MI-R3P
  - MI-R4AG
  - R2100
  - RM2100
  - NEWIFI (3D2)
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

- Manuals
  - Controlling GPIO and LEDs via sysfs
  - How to use NAND RWFS partition
  - How to use IPv6 NAT and fullcone NAT
  - How to add new device support with device tree
