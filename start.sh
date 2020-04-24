#!/bin/bash

cd ~/.conky/Clock-With-Weather-Conky 
nohup conky -c ~/.conky/Clock-With-Weather-Conky/app.cfg > /dev/null & 
cd -