library("optparse")

option_list = list(make_option("--cpgFile", type = "character", default = NULL, help  = "CpG annotation file, for example, hg38_CpG.gz."),
				   make_option("--mCall", type = "character", default = NULL, help = "A text file with path to methylation calls, one per line."),
				   make_option("--coverage", type = "integer", default = 1, help = "The minimal coverage to calcuate mean methylation levels. [1]"),				   
				   make_option("--Tag", type = "character", default = NULL, help = "Tag"))
args <- parse_args(OptionParser(option_list=option_list))

# check parameters
if(is.null(args$cpgFile))
	stop("\nArgument cpgFile is required.\n")
if(is.null(args$mCall))
	stop("\nArgument mCall is required.\n")
if(is.null(args$Tag))
	stop("\nArgument Tag is required.\n")

# load required packages
suppressMessages(library("GenomicRanges"))
suppressMessages(library("data.table"))

# load CpG annotation
cat("loading cpg annotation file", args$cpgFile, "\n")
tx = fread(file = args$cpgFile, sep = "\t")
colnames(tx) = c("chr", "start", "end")
GR = makeGRangesFromDataFrame(tx)

# load each mCall file
filePath = read.table(file = args$mCall, sep = "\t")[,1]
N = length(filePath)
out = matrix(NA, length(GR), N)

for(i in 1:N){
	cat("loading", filePath[i], "\n")
	tx = fread(file = filePath[i], sep = "\t", skip = 1)
	coverage = tx$V5 + tx$V6
	idx = coverage > args$coverage
	fx = tx[idx, c("V1", "V2", "V3", "V4")]
	colnames(fx) = c("chr", "start", "end", "score")
	xgr = makeGRangesFromDataFrame(fx, keep.extra.columns=TRUE)
	start(xgr) = start(xgr) + 1
	x = findOverlaps(GR, xgr, type = "equal", ignore.strand = TRUE)
	out[queryHits(x), i] = xgr[subjectHits(x)]$score	
}

# filter out rows with missing values across all samples
colnames(out) = gsub(".bedGraph", "", sapply(strsplit(filePath, "/"), function(z) z[length(z)]))
idx = rowSums(is.na(out)) < N
res = data.frame(chr = as.character(seqnames(GR)), start = start(GR), end = end(GR), out)[idx, ]

# write to file
outMatrix = paste0(args$Tag, "_matrix.tmp")
outHeader = paste0(args$Tag, "_header.tmp")
header = colnames(res)
header[1] = "#seqnames"
write.table(res, file = outMatrix, row.names = FALSE, col.names = FALSE, sep = "\t", quote = FALSE)
write.table(rbind(header), file = outHeader, row.names = FALSE, col.names = FALSE, sep = "\t", quote = FALSE)

# shell command
outFile = paste0(args$Tag, ".txt")
outGZ = paste0(args$Tag, ".gz")

system(paste("cat", outHeader, outMatrix, ">", outFile))
system(paste("rm", outHeader, outMatrix))
system(paste("cat", outFile, "|sort -k1,1 -k2,2n | bgzip >", outGZ))
system(paste("tabix -b 2 -e 3", outGZ))
system(paste("rm", outFile))
