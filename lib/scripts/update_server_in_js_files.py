"""
ex usage: 
python3 lib/scripts/update_server_in_js_files.py public/_expo/static/js/web/ "s/https:\/\/YOUR.DOMAIN.COM/https:\/\/EXAMPLE.DOMAIN.COM/g"
"""
import argparse
import os
import subprocess
import sys

def update_js_files(directory_path, sed_expression):
    """
    Applies a sed expression to all .js files in the specified directory
    and its subdirectories.

    Args:
        directory_path (str): The path to the directory to search.
        sed_expression (str): The sed expression to apply (e.g., 's/old/new/g').
    """
    if not os.path.isdir(directory_path):
        print(f"Error: Directory '{directory_path}' not found.", file=sys.stderr)
        return

    print(f"Searching for .js files in: {directory_path}")
    print(f"Applying sed expression: '{sed_expression}'")

    found_files = 0
    updated_files = 0
    errored_files = 0

    for root, _, files in os.walk(directory_path):
        for file_name in files:
            if file_name.endswith(".js"):
                found_files += 1
                file_path = os.path.join(root, file_name)
                print(f"Processing file: {file_path}")

                try:
                    # Construct the sed command.
                    # 'sed -i' edits the file in place.
                    # For macOS/BSD sed, '-i ""' is needed for in-place editing without a backup.
                    # For GNU sed, '-i' is sufficient.
                    # We'll try to detect the OS to provide a robust solution.

                    if sys.platform == 'darwin' or 'bsd' in sys.platform:
                        # macOS/BSD sed requires an empty string for the backup suffix
                        command = ["sed", "-i", "", sed_expression, file_path]
                    else:
                        # Linux (GNU sed) does not require the empty string
                        command = ["sed", "-i", sed_expression, file_path]

                    result = subprocess.run(command, check=True, capture_output=True, text=True)
                    if result.returncode == 0:
                        print(f"Successfully updated: {file_path}")
                        updated_files += 1
                    else:
                        print(f"Sed command failed for {file_path}:", file=sys.stderr)
                        print(result.stderr, file=sys.stderr)
                        errored_files += 1

                except subprocess.CalledProcessError as e:
                    print(f"Error applying sed to {file_path}: {e}", file=sys.stderr)
                    print(f"Stdout: {e.stdout}", file=sys.stderr)
                    print(f"Stderr: {e.stderr}", file=sys.stderr)
                    errored_files += 1
                except FileNotFoundError:
                    print(f"Error: 'sed' command not found. Please ensure sed is installed and in your PATH.", file=sys.stderr)
                    errored_files += 1
                    break # Exit early if sed isn't found
                except Exception as e:
                    print(f"An unexpected error occurred with {file_path}: {e}", file=sys.stderr)
                    errored_files += 1

    print("\n--- Summary ---")
    print(f"Total .js files found: {found_files}")
    print(f"Files successfully updated: {updated_files}")
    print(f"Files with errors: {errored_files}")
    if errored_files > 0:
        print("Please check the errors above for details on failed updates.", file=sys.stderr)


def main():
    parser = argparse.ArgumentParser(
        description="Update all .js files in a given path using a sed expression."
    )
    parser.add_argument(
        "directory",
        help="The path to the directory containing .js files."
    )
    parser.add_argument(
        "sed_expression",
        help="The sed expression to apply (e.g., 's/old_text/new_text/g'). "
             "Remember to quote expressions containing spaces or special characters."
    )

    args = parser.parse_args()

    update_js_files(args.directory, args.sed_expression)

if __name__ == "__main__":
    main()

