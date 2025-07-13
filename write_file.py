
import sys, os

def write_file(name_files: list[str]):

    home_dir = os.path.expanduser("~").replace("\\", "/")
    vivado_name_project = "project_multicycle"
    path = f"{home_dir}/{vivado_name_project}/{vivado_name_project}.srcs/sources_1/imports/src"
    
    # search path for the files
    for file in name_files:
        file_path_viv = os.path.join(path, file + '.v')
        if not os.path.exists(file_path_viv):
            print(f"File {file} does not exist in the specified path.")
            return

    # If all files exist, proceed with writing
    for file in name_files:
        file_path = f"src/{file}.v"
        with open(file_path, 'r') as f:
            content = f.read()

        # open name file from path
        file_path_viv = os.path.join(path, file + '.v')
        with open(file_path_viv, 'w') as f:
            f.write(content)
            print(f"File {file} written successfully at {file_path_viv}")

if __name__ == "__main__":
    if len(sys.argv) < 1:
        print("Usage: python write_file.py <file1> <file2> ...")
        sys.exit(1)

    # Get the list of file names and the path
    name_files = sys.argv[1:]
    path = sys.argv[-1]

    # Write the files
    write_file(name_files)
