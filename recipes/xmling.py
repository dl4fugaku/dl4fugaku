import xml.etree.ElementTree as ET
from pathlib import Path


def print_all(tree):
    for i in tree.iter():
        name_or_tag = f"{i.attrib['name']}-event" if i.tag == "event" else i.tag
        print(name_or_tag, i.text, i.attrib)


def print_cmg(tree):
    cmg, core = list(tree.getroot()[0][-1][0][-1])
    print(cmg.tag, cmg.attrib, core.tag, core.attrib)


path = Path("./prof")
for filename in path.glob("*"):
    # print("---------------------------")
    # print(filename)
    # print("---------------------------")
    tree = ET.parse(filename)
    # print_all(tree)
    print_cmg(tree)
