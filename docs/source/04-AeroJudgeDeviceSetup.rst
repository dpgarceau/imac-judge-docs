AeroJudge Device Setup
======================

New device
----------

If you have a new device or a new SD card, then you need to download the full device image:

1. download image here
2. Use pi imager to write image to SD card
   
   * Win32 Disk Imager https://sourceforge.net/projects/win32diskimager
   * balenaEtcher https://www.balena.io/etcher
   * Raspberry Pi Imager https://www.raspberrypi.com/software/
 
3. Once the pi image is written, a drive letter will be assigned (in Windows)
4. Continue to Configuring device for a contest


Updating the device
-------------------

If you have an existing device that needs to be updated:

1. Be sure device is connected to WiFi network with internet available
2. Login to the device
3. Run update command: ./judge_update.sh


Configuring device for a contest
--------------------------------

1. Insert SD card, opening the result drive, and find the file named settings.json. 
2. Open this file in a standard text editor (not a rich editor like MS Word).
3. Edit the file placing the appropriate values after the colon (:) being careful to preserve all formatting (braces, quotes, commas).

.. code-block:: javascript

    {
        "judge_id":1,
        "line_number":1,
        "score_host":"192.168.50.100",
        "score_http_port":80,
        "language":"en"
    }

*settings.json file parameters:*

 **line_number** is a single integer number starting at 1. Each AeroJudge device for a given flight line should have the same number. A different flight line should have the next highest integer number (eg 2) for all devices being used on that line.

 **judge_id** is a single integer number starting at 1. Each AeroJudge device for a given flight line should have a different judge id from 2 (minimum) to the number of judges for that line.

 **score_host** is the network IP address of the computer running the Score software with services running

 **score_http_port** is the port number entered on the Score software services tab

 **language** is the two letter language code (currently only en is supported)

4. Be sure to eject the disk properly (right-click drive letter and choose Eject)
5. Insert the SD card back into the device and power the device