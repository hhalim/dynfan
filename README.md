# dynfan
Dynamic fan control for Nvidia in Ubuntu Linux

# Startup
To run it after every reboot, use crontab.
```
$ crontab -e
```

Insert this line in crontab:
```
@reboot nohup ~/dynfan.sh &
```
