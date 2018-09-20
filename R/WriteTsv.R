#' Write raw data in tab-separated data format
#'
#' @param obj Seurat object to print
#' @param outfile Character. Name of a tsv file that should be written to
#' @param raw A logical scalar. Should raw data be written?
#' @param gzip A logical scalar. Should data be gzipped after writing?
#' @export
#' @examples
#' WriteTsv(obj, filename, raw=FALSE)
WriteTsv <- function(obj, outfile, raw=TRUE, gzip=TRUE) {
    assertthat::assert_that(class(obj) == "seurat")
    
    if (raw) {
        mat <- obj@raw.data[, obj@cell.names] %>% as.matrix()
    } else {
        mat <- obj@data[, obj@cell.names] %>% as.matrix()
    }
    cat("gene\t", paste(colnames(mat), collapse="\t"), "\n", file=outfile)
    data.table::fwrite(as.data.frame(mat), file=outfile, append=TRUE, quote=FALSE, 
        sep="\t", row.names=TRUE, col.names=FALSE)
    if (gzip) gzip(outfile)
    return()
}
