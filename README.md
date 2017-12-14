# dynfan
Dynamic fan control for Nvidia in linux. Had been tested in Ubuntu 16.04 only. 

Unlike windows with MSI Burner or similar, linux has no apps to dynamically change the speed of the Nvidia fans. Your option is to leave the gpu fan to auto speed, which is not aggressive enough for crypto mining, or fixed speed, which is very inefficient when the temperature changes.

With this bash script I attempted to set the fan speed at a minimum of 40% at 40 degrees, this is configurable. The delta setting allows the fan not to change constantly with every temperature change, but have a small band of minor differences before a change of speed. If delta set to 0, then the fan speed will change in lockstep with the temp changes.

# Startup
To run it after every reboot, use crontab.
```
$ crontab -e
```

Insert this line in crontab:
```
@reboot nohup ~/dynfan.sh &
```

# Configuration
Accepts arguments:
```
-l Lower temperature range in C. Default: 40
-u Upper temperature range in C. Default: 80
-s Sleep delay in seconds, set interval of temperature check. Default: 10
-d Delta temperature before fan speed is changed. Default: 3
```
Fan speed set to automatic when the temp range is outside the lower/upper range.
