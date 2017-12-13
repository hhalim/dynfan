# dynfan
Dynamic fan control for Nvidia in Ubuntu linux.

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
