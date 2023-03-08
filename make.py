#!/usr/bin/python3

import os
from pathlib import Path
import click
import ezdxf
from ezdxf import colors
from ezdxf.enums import TextEntityAlignment

def insert_text_into_dxf(dxf_path:Path, text:str, x:float, y:float, z:float, height:float, color):
    dxf = ezdxf.readfile(dxf_path)
    msp = dxf.modelspace()
    msp.add_text(text, dxfattribs={
        'height': height,
        'color': color,
        'rotation': 0,
        'style': 'OpenSans-Regular',
        'insert': (x, y, z),
    })
    dxf.saveas(dxf_path)

SCAD_FILE_NAME = "mk3.scad"
EXPORT_PATH = "./DXFs/"

@click.command()
@click.option('--filter', default="all", help='Filter for parts to export')
def main(filter: str):
    part_revsion = 0
    files = []
    grab_mode = False
    # Create the EXPORT_PATH directory if it doesn't exist
    Path(EXPORT_PATH).mkdir(parents=True, exist_ok=True)
    with open(SCAD_FILE_NAME) as f:
        for line in f:
            if "PARTSMARKERSTART" in line:
                grab_mode = True
                continue
            if "PARTSMARKEREND" in line:
                grab_mode = False
                continue
            if line.strip().startswith("//"):
                continue
            if "part_revision_number" in line:
                part_revsion = int(line.split("=")[1].strip()[:-1])
                continue
            if grab_mode:
                files.append(line.split()[0].removeprefix("export_"))
    print("Part revsion:", part_revsion)
    for file in files:
        if filter != "all" and filter not in file:
            continue
        print(f"Processing {file}")
        os.system(f"openscad -o {EXPORT_PATH}{file}.dxf {SCAD_FILE_NAME} -D z_scale=0 -D xy_scale=1 -D batch_export=true -D export_{file}=true")
        insert_text_into_dxf(Path(EXPORT_PATH+file + ".dxf"), f"{part_revsion}", 0, 0, 0, 3, colors.BLUE)
        insert_text_into_dxf(Path(EXPORT_PATH+file + ".dxf"), f"{file}", 0, 0, 0, 3, colors.BLUE)

if __name__ == "__main__":
    main()