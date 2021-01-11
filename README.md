# DVR SERVER CCTV CAMERA HOME ASSISTANT MQTT MOTION SENSOR

Simple log/alarm server receiving and sending to MQTT remote dvr/camera events. Tested with:

HJCCTV HJ-H4808BW

http://www.aliexpress.com/item/Hybird-NVR-8chs-H-264DVR-8chs-onvif-2-3-Economical-DVR-8ch-Video-4-AUDIO-AND/1918734952.html

PBFZ TCV-UTH200

http://www.aliexpress.com/item/Free-shipping-2014-NEW-IP-camera-CCTV-2-0MP-HD-1080P-IP-Network-Security-CCTV-Waterproof/1958962188.html

Jienio Audio Poe Ip Cámara 1080 p HD Cctv

https://es.aliexpress.com/item/33052006803.html?spm=a2g0s.9042311.0.0.758f63c02eLfuS


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
    
    state_topic: "home-assistant/camera/movimiento"
    
    payload_on: "ON"
    
    off_delay: 30
    
