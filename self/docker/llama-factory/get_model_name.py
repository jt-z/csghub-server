#!/usr/bin/env python3

import re
import sys


def find_model_name_by_repo_id(constants_file, repo_id):
    try:
        with open(constants_file, 'r', encoding='utf-8') as f:
            lines = f.readlines()
    except FileNotFoundError:
        return None

    repo_pattern = rf'DownloadSource\.DEFAULT:\s*"{re.escape(repo_id)}"'

    for i, line in enumerate(lines):
        if re.search(repo_pattern, line):
            for j in range(i, max(-1, i - 50), -1):
                model_match = re.search(r'"([^"]+)":\s*\{', lines[j])
                if model_match:
                    model_name = model_match.group(1)
                    model_dict_content = ''.join(lines[j:i+1])
                    if re.search(repo_pattern, model_dict_content):
                        return model_name

    parts = repo_id.split('/')
    if len(parts) >= 2:
        model_name_only = parts[-1]
        flexible_pattern = rf'DownloadSource\.DEFAULT:\s*"[^"]*/{re.escape(model_name_only)}"'

        for i, line in enumerate(lines):
            if re.search(flexible_pattern, line):
                match = re.search(r'DownloadSource\.DEFAULT:\s*"([^"]+)"', line)
                if match:
                    matched_repo_id = match.group(1)
                    matched_parts = matched_repo_id.split('/')
                    if len(matched_parts) >= 2 and matched_parts[-1] == model_name_only:
                        for j in range(i, max(-1, i - 50), -1):
                            model_match = re.search(r'"([^"]+)":\s*\{', lines[j])
                            if model_match:
                                found_model_name = model_match.group(1)
                                model_dict_content = ''.join(lines[j:i+1])
                                if re.search(rf'DownloadSource\.DEFAULT:\s*"{re.escape(matched_repo_id)}"', model_dict_content):
                                    return found_model_name

    return None


if __name__ == "__main__":
    if len(sys.argv) < 2:
        print("Usage: python get_model_name.py <REPO_ID>", file=sys.stderr)
        sys.exit(1)

    repo_id = sys.argv[1]
    constants_file = "/app/src/llamafactory/extras/constants.py"

    model_name = find_model_name_by_repo_id(constants_file, repo_id)

    if model_name:
        print(model_name)
        sys.exit(0)
    else:
        parts = repo_id.split('/')
        if len(parts) >= 2:
            print(parts[1])
        else:
            print(repo_id)
        sys.exit(0)