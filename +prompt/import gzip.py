import gzip 
import pandas as pd



# Paths
input_gz_file = '/Users/ctp21/Desktop/GSE232789_RAW/GSM7383239_lumbar.barcodes.tsv.gz'
output_xls_file = '/Users/ctp21/Desktop/GSE232789_RAW/Converted/lumbar.barcodes.xls'

# Step 1: Decompress the .tsv.gz file
with gzip.open(input_gz_file, 'rt') as f_in:
    df = pd.read_csv(f_in, sep='\t')

# Step 2: Save to .xls (use ExcelWriter with xls engine)
df.to_excel(output_xls_file, index=False, engine='xlwt')  # .xls format