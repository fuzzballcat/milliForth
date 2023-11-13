#import pyautogui
import time

#pyautogui.typewrite(" ")
#print("Place cursor in QEMU window and wait...")
#time.sleep(5)
#print("Now typing!")

import sys

for line in open(sys.argv[1], "r"):
    for char in line:
        if char == '\n':
            char = '\r'
        print(char,end='',flush=True)
        time.sleep(0.005)

#for line in open("hello_world.FORTH", "r"):
#    pyautogui.write(line,interval=0.1)
#    time.sleep(0.25)