#' Write raw data in tab-separated data format
#'
#' @param obj Seurat object to print
#' @param outfile Character. Name of a tsv file that should be written to
#' @param raw A logical scalar. Should raw data be written?
#' @export
#' @examples
#' WriteTsv(obj, filename, raw=FALSE)
WriteTsv <- function(obj, outfile, raw=TRUE) {
    assertthat::assert_that(class(obj) == "seurat")
    
    # Barcodes
    cat(obj@cell.names, file = paste0(dir, "/barcodes.tsv"), sep = "\n")
    
    # Genes. Seurat doesn't store ENS ID. As a hack, put ENS_ID for all genes
    df <- data.frame(ID = "ENS_ID", symbol = rownames(obj@raw.data))
    write.table(df, row.names = F, col.names = F, sep = "\t", quote = F, file = paste0(dir, "/genes.tsv"))

    if (raw) {
        mat <- obj@raw.data[, obj@cell.names] %>% as.matrix()
    } else {
        mat <- obj@data[, obj@cell.names] %>% as.matrix()
    }
    cat("gene\t", paste(colnames(mat), collapse="\t"), "\n", file=outfile)
    data.table::fwrite(as.data.frame(mat), file=outfile, append=TRUE, quote=FALSE, 
        sep="\t", row.names=TRUE, col.names=FALSE)
    return()
}
