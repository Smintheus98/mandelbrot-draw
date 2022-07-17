#!/usr/bin/python3
import glob

from PIL import Image


def make_gif(frame_folder, file_name):
    ffiles = [frame for frame in glob.glob(f"{frame_folder}/*.png")]
    ffiles.sort()
    frames = [Image.open(frame) for frame in ffiles]
    frame_one = frames[0]
    frame_one.save(file_name, format="GIF", append_images=frames,
               save_all=True, duration=75, loop=1)
    

if __name__ == "__main__":
    make_gif("frames", "mandelbrot.gif")
