import sys
known_error_list, line = sys.argv[1:3]
sys.exit(1 if any([known_error in line for known_error in known_error_list.split('|')]) else 0)
