#!/usr/bin/env python3
# -*- coding: utf-8 -*-

import argparse

def main():
    parser = argparse.ArgumentParser(description='A simple tool to convert fasta file to cytosine position file')
    parser.add_argument('--file', '-i', help='Input the file name. eg:hg19.fa', required=True)
    parser.add_argument('--out', '-o', help='Input the output file name. eg:result', default="result")
    parser.add_argument('--mode', '-m', help='Input mode. CHH,CHG or CpG', default="CpG")
    args = parser.parse_args()

    print("Reading from file:" + args.file + " with mode " + args.mode)

    file = open(args.file)
    file_name = args.out

    pointer = 1
    patterns = ["cg"]
    pattern_length = 2

    if args.mode.lower() == "cpg":
        patterns = ["cg"]
        pattern_length = 2
    elif args.mode.lower() == "chg":
        patterns = ["cag", "ctg", "ccg"]
        pattern_length = 3
    elif args.mode.lower() == "chh":
        patterns = ["caa", "cat", "cac", "cta", "ctt", "ctc", "cca", "cct", "ccc"]
        pattern_length = 3

    bed_file_name = open(file_name + "_" + args.mode + "", mode="w")

    lastSeqs = ""
    seq_chr = ""

    while True:
        line = file.readline().replace("\n", "")
        # end of file
        if not line:
            break

        # new chr
        if "chr" in line:
            seq_chr = line.replace(">", "")
            pointer = 1
            lastSeqs = ""
            continue

        line = lastSeqs + line

        for i in range(0, len(line)):
            keyword = line[i:i + pattern_length].lower()

            if keyword in patterns:
                bed_file_name.write("{0}\t{1}\t{2}\n".format(seq_chr, pointer, pointer + pattern_length - 1))

            if pattern_length + i > len(line):
                lastSeqs = line[i:len(line)]
                break

            pointer += 1

            if pointer % 1000000 == 0:
                print("Fetching from {0} {1}".format(seq_chr, pointer))

    file.close()
    bed_file_name.close()

if __name__ == '__main__':
    main()
