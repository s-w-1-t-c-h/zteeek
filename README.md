# PoC vulnerabilities for the ZTE MF91 4G pre-paid wireless modem (Telstra version) #

I was mucking around with my ZTE a while back and found a few vulnerabilties. Reported to the manufacturer via Telstra, no fixes appear to be planned for release so there you go.

# Default Wireless Key

Note also that by default, the MF91 (at least the Telstra version) uses a easily idenitifiable wireless network key when in its default state. The WPA2 key is always 8847[last four octets of the device's MAC address], so if your MF91 has a MAC address of  F4:D6:E2:DB:76:D8, then the default wireless key will be 8847E2DB76D8 (credit to Topaz Aral for discovering this).
