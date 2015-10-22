#!/bin/env python

import os
import re
import signal
import subprocess
import time


pid = subprocess.Popen("ps ax".split(" "), stdout=subprocess.PIPE)

(out, _) = pid.communicate()

for line in out.split("\n"):
	if "na62-farm " in line:
		cmdArray = re.split("\s+", line.strip())
		print cmdArray
		startIndex = [ i for i, word in enumerate(cmdArray) if word.endswith('na62-farm') ][0]
		print startIndex
		os.kill(int(cmdArray[0]), signal.SIGKILL)
		paramList = cmdArray[startIndex+1:]
		paramList.append("--verbosity=3")
		paramList.append("--logtostderr=1")
		paramList.append("--printMissingSources=1")
		time.sleep(2)
#		os.execvp("/workspace/na62-farm/Debug/na62-farm", paramList)
		os.execvp("valgrind /workspace/na62-farm/Debug/na62-farm", paramList)
