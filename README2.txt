Wan2GP RTX 5060 Ti - LAN launcher bundle

Place these BAT files in the SAME folder as the working v8 installation root:
  runtime\Python311\python.exe
  Wan2GP\wgp.py

Main menu:
  WAN2GP_MENU.bat

Direct launchers:
  START_WAN2GP_GRADIO_URL.bat     = Gradio over LAN, port 7860
  START_WAN2GP_LAN.bat            = alias for the Gradio LAN launcher
  START_WAN2GP_DEEPY_LAN.bat      = standalone Deepy Web over LAN

URLs when running on port 7860:
  Local Gradio: http://127.0.0.1:7860/
  LAN Gradio:   http://<PC-LAN-IP>:7860/
  LAN Deepy:    http://<PC-LAN-IP>:7860/deepy/

Important:
  --listen is used for LAN access.
  --share is NOT used, so this does not create a public Hugging Face tunnel.
  Use the PC's actual LAN IP on the phone/tablet; do not type 0.0.0.0.
  If another device cannot connect, run ALLOW_LAN_FIREWALL_7860.bat once and approve UAC.

The menu also detects and runs existing BAT files in the same directory, while hiding its helper BAT files.
