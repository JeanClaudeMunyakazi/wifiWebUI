# wifiWebUI
WebUI for raspi wifi-bridge

(Raspberry Pi WLAN-zu-LAN-Brücke mit Konfigurationsoberfläche im Browser)

## Install wifiWebUI
### Enable root acces and ssh on you raspi
1. Copy an empty file with the name ```ssh``` and NO file extension under the ```boot``` path of your SD-card.
2. Remove the SD-card from your computer and put it in the raspi. Connect the ethernet of the raspi to your router and boot it up.
3. Search for the IP of the raspi in your LAN via a network scanner or in the User Interface (UI) of your router e.g. fritz!Box.
4. Connect to the raspi via SSH and the user ```pi``` using the password ```raspberry```.
5. Execute the following commands
```bash
sudo -i
nano /etc/ssh/sshd_config
```
Change the line ```#PermitRootLogin without-password``` to ```PermitRootLogin yes```

To reload the new configuration you just changed, you have to restart the sshd daemon by the following command.

*If you may have made any mistakes, the restart command will tell you with an error message, what you may have done wrong.*
```bash
/etc/init.d/ssh restart
```
6. Change the password for ```root```, because it is not set by default. For simplicity reasons of the documentation we use the password ```raspberry```.
```bash
passwd root
```
### Copy files and execute the installation
1. Copy the complete folder "wifiWebUI" to /opt

Make the file /opt/wifiWebUI/deployment/install.sh executable
```bash
chmod +x /opt/wifiWebUI/deployment/install.sh
```
3. Start the installation
```bash
sh /opt/wifiWebUI/deployment/install.sh
```

### After the Installation
Take the ethernet cable out of the router and connect the raspi to your local PC or fritz!Box.

### Configure your WiFi Network in the Web user Interface
Open your Browser and go to the following URL: ```http://192.168.55.1```
Type in ```admin``` as user and ```hammer4296```
Then scan for your device and click on the ´desired SSID.
Put in the PSK and click on "set and reboot".

---------------------------------------------------------------------------------------------

#  IHK Abschlussprojekt – Mobile Office Case mit Raspberry Pi (WLAN–LAN Bridge)

Dieses Repository dokumentiert mein Abschlussprojekt zur IHK-Prüfung als IT-Systemelektroniker.

##  Projekttitel

**„Bereitstellung eines Mobile Office Case mit einer WLAN zu LAN-Brücke“**

##  Projektziel

Das Ziel war es, eine flexible und kostengünstige Lösung zu entwickeln, um LAN-basierte Geräte (z. B. Laptops, Drucker) vor Ort über WLAN ins Internet zu bringen. Die Lösung basiert auf einem Raspberry Pi, der als Netzwerkbrücke (WLAN zu LAN) dient.

---

##  Projektinhalte

- Raspberry Pi 4 mit Raspberry Pi OS Lite
- Netzwerkkonfiguration mit `dnsmasq` und `iptables`
- NAT, DHCP, lokale DNS-Services
- Fernverwaltung über mRemoteNG
- Stromversorgung über mobile Powerbank
- Hardware-Komponenten im praktischen Office Case

---

##  Verzeichnisstruktur

```bash
.
├── config/           # Beispielkonfigurationen (dnsmasq, Interfaces)
├── bashScripts/      # Automatisierungsskripte
├── lib/, root/, t/   # Projektstruktur
├── deployment/       # Installationshinweise
├── README.md         # Diese Datei
├── README.pdf        # Projektbeschreibung (PDF)
├── wifiwebui.conf    # Konfiguration für Weboberfläche
├── wifiwebui.psgi    # CGI-basierte Verwaltungsoberfläche


## Netzwerkarchitektur

. Pi verbindet sich mit dem Kunden-WLAN

. NAT übersetzt die Adressen

. Endgeräte erhalten IPs über lokalen DHCP

##  Getestet wurde:

WLAN-Verbindung über Raspberry Pi

DHCP- und NAT-Funktion

Stabile Internetverbindung über LAN-Port

# Autor
Jean-Claude Munyakazi
 Berlin
 IT-Systemelektroniker (IHK)
 https://munyakazi.org

 # Lizenz
Dieses Projekt steht unter der MIT Lizenz.