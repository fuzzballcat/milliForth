import pyautogui
import time

pyautogui.typewrite(" ")
print("Place cursor in QEMU window and wait...")
time.sleep(5)
print("Now typing!")

for line in open("hello_world.FORTH", "r"):
    pyautogui.write(line,interval=0.1)
    time.sleep(0.25)