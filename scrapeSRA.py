# read in the file downloaded from the run archive, in this partcular case https://www.ncbi.nlm.nih.gov/Traces/study/?query_key=1&WebEnv=MCID_6178e8ee92f0234b8354c36f&o=acc_s%3Aa (may not be functional)
    # SraRunTable.txt
    # Contains Metadata for all samples
    # check for each line if it contains "HMP_" -> that is the tissue
    # Check is_affected or is_tumor for extra subcategories in later versions of this script (but initially ignore these)

# we select the first element from each line except the first line: the Run identifier
# we select the element HMP_ which represnets the category
# we ignore all lines that do not contain HMP_
# then we load teh file https://trace.ncbi.nlm.nih.gov/Traces/sra/?run= >>Run identifier here <<
# a basic frequency table is stored in the function "oTaxAnalysisData"
# From this function we collect "name" and "percent"
# This is stored as a file RunIdentifier.txt in the directory that carries the name of the category
