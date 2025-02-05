## Rename input files

import os
import glob

def rename_fastq_files(input_dir):
    '''
    Purpose:
        Rename R1, R2 and long fastq.gz files.
    Takes:
        input_dir (str): Path to the directory containing fastq.gz files.
    Returns:
        int: Number of files successfully renamed.
        Files renamed.
    '''
    renamed_count = 0
    try:
        if not os.path.isdir(input_dir):
            raise ValueError(f"Input directory does not exist: {input_dir}")
    
        # Get all fastq.gz files in the directory
        files = glob.glob(os.path.join(input_dir, "*.fastq.gz"))

        for file in files:
            # Extract the base name of the file
            base_name = os.path.basename(file).removesuffix(".fastq.gz")
            
            # Split the name into parts
            parts = base_name.split('_')
            
            # Get the prefix (ABxx) and type (R1, R2, long)
            prefix = parts[0]  # ABxx --> isolate name
            if "R1" in parts:
                new_name = f"{prefix}_R1.fastq.gz"
            elif "R2" in parts:
                new_name = f"{prefix}_R2.fastq.gz"
            elif "long" in parts:
                new_name = f"{prefix}_long.fastq.gz"
            else:
                print(f'"{file}" could not be renamed. Skipping...')
                continue  # If not R1, R2, or long, continue to the next file
            
            # Create the full path for the new name
            new_file_path = os.path.join(input_dir, new_name)

            # Check if new file name already exists
            if os.path.exists(new_file_path):
                print(f'Warning: "{new_file_path}" already exists. Skipping...')
                continue

            # Rename the file
            os.rename(file, new_file_path)
            renamed_count += 1
    
    except IOError as e:
        print(f"Error writing to file: {e}")
    except Exception as e:
        print(f"An unexpected error occurred: {e}")

    return renamed_count