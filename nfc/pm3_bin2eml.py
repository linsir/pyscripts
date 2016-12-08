from __future__ import absolute_import, division, print_function

import argparse

import binascii

READ_BLOCKSIZE = 16


def main():
    parser = argparse.ArgumentParser(
        description="Converts a Proxmark3 bin file to the eml format."
    )
    parser.add_argument("input", type=argparse.FileType("rb"))
    parser.add_argument("output", type=argparse.FileType("w"))
    args = parser.parse_args()

    while True:
        input_bytes = args.input.read(READ_BLOCKSIZE)
        if not input_bytes:
            break
        args.output.write(binascii.hexlify(input_bytes))
        args.output.write("\n")


if __name__ == '__main__':
    main()
