import multiprocessing
import os
import subprocess
import sys
import time

from boto3 import Session

CREDENTIAL_REFRESH_INTERVAL_IN_SECONDS = int(os.getenv('CREDENTIAL_REFRESH_INTERVAL_IN_SECONDS', 55 * 60))


def refresh_credentials(run_indefinitely=False):
    session = Session()
    credentials = session.get_credentials().get_frozen_credentials()

    while run_indefinitely:
        set_credentials(credentials)
        time.sleep(CREDENTIAL_REFRESH_INTERVAL_IN_SECONDS)

    set_credentials(credentials)


def set_credentials(frozen_credentials):
    os.environ['AWS_ACCESS_KEY_ID'] = frozen_credentials.access_key
    os.environ['AWS_SECRET_ACCESS_KEY'] = frozen_credentials.secret_key
    os.environ['AWS_SESSION_TOKEN'] = frozen_credentials.token
    print("Credentials set.")


def command(cmd):
    p = subprocess.Popen(
        cmd
    )
    print(p.communicate())


def main(cmd):
    refresh_credentials(run_indefinitely=False)

    credential_process = multiprocessing.Process(target=refresh_credentials, args=())
    command_process = multiprocessing.Process(target=command, args=(cmd,))

    credential_process.start()
    command_process.start()

    if not command_process.is_alive():
        credential_process.terminate()

    credential_process.join()
    command_process.join()


if __name__ == "__main__":
    main(sys.argv[1:])
