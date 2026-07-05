import fitz
import sys
import os

try:
    doc = fitz.open("assets/icons/ironlog_icon.svg")
    pix = doc[0].get_pixmap(alpha=False, dpi=72)
    pix.save("assets/icons/ironlog_icon.png")
    
    doc2 = fitz.open("assets/icons/ironlog_icon_foreground.svg")
    pix2 = doc2[0].get_pixmap(alpha=True, dpi=72)
    pix2.save("assets/icons/ironlog_icon_foreground.png")
    
    print("SVG conversion successful!")
except Exception as e:
    print(f"Error: {e}")
    sys.exit(1)
