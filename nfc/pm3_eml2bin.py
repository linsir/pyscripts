from __future__ import absolute_import, division, print_function

import argparse

import binascii


def main():
    parser = argparse.ArgumentParser(
        description="Converts a Proxmark3 eml file to the bin format."
    )
    parser.add_argument("input", type=argparse.FileType("r"))
    parser.add_argument("output", type=argparse.FileType("wb"))
    args = parser.parse_args()

    for line in args.input:
        line = line.rstrip("\n").rstrip("\r")
        print(line)
        args.output.write(binascii.unhexlify(line))


if __name__ == '__main__':
    main()
