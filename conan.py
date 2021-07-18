#!/usr/bin/env python3

import os.path
import subprocess

def main():
    os.environ["CONAN_REVISIONS_ENABLED"] = "1"
    os.environ["CONAN_V2_MODE"] = "1"

    script_path = os.path.dirname(os.path.realpath(__file__))

    remote_url = "https://ssrobins.jfrog.io/artifactory/api/conan/conan"
    subprocess.run(f"conan remote add artifactory-ssrobins {remote_url} --insert --force",
        cwd=script_path, shell=True, check=True)

    subprocess.run(f"conan create --update .",
        cwd=script_path, shell=True, check=True)


if __name__ == "__main__":
    main()
