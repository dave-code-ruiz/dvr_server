# DVR SERVER CCTV CAMERA HOME ASSISTANT MQTT MOTION SENSOR

Simple log/alarm server receiving and sending to MQTT remote dvr/camera events. Tested with:

HJCCTV HJ-H4808BW

http://www.aliexpress.com/item/Hybird-NVR-8chs-H-264DVR-8chs-onvif-2-3-Economical-DVR-8ch-Video-4-AUDIO-AND/1918734952.html

PBFZ TCV-UTH200

http://www.aliexpress.com/item/Free-shipping-2014-NEW-IP-camera-CCTV-2-0MP-HD-1080P-IP-Network-Security-CCTV-Waterproof/1958962188.html

Jienio Audio Poe Ip Cámara 1080 p HD Cctv

https://es.aliexpress.com/item/33052006803.html?spm=a2g0s.9042311.0.0.758f63c02eLfuS

BESDER-cámara IP

https://es.aliexpress.com/item/32831727674.html?spm=a2g0s.9042311.0.0.c48163c0vJgnYH

# Install perl and cpan

sudo apt-get install perl

sudo cpan JSON

sudo cpan Net::MQTT::Simple

# Install service

sudo systemctl daemon-reload

sudo systemctl enable dvralarm.service

sudo systemctl start dvralarm.service

# home assistant configuration.yaml

binary_sensor:

  - platform: mqtt
  
    name: movimiento_camera
    
    device_class: motion
    
    state_topic: "home-assistant/[ipofcamera]/movimiento"
    
    payload_on: "ON"
    
    off_delay: 30
    
# camera or dvr configuracion

Camera o DVR config is diferent for each camera, some example is:

![image](https://user-images.githubusercontent.com/34915602/109655607-c1e63380-7b63-11eb-8099-36bad58ba388.png)

Go remote config - system config - services - alarm center

![image](https://user-images.githubusercontent.com/34915602/109655807-fc4fd080-7b63-11eb-9b1e-7a4c588bd918.png)

Add raspberry/linux ip server to send motion alarm, default port 15002

![image](https://user-images.githubusercontent.com/34915602/109656039-446ef300-7b64-11eb-88e9-fd08454b0014.png)

Finally go Alarm - Motion Alarm 

![image](https://user-images.githubusercontent.com/34915602/109656261-86983480-7b64-11eb-9af4-890dece163ec.png)

Enable alarm and check "Exp. Alarma" to send motion alarm to server



