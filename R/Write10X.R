#' Write data in 10X format i.e. directory with barcodes.tsv, genes.tsv, matrix.mtx
#'
#' @export
#' @examples
#' Write10X(obj, dir)
Write10X <- function(obj, dir) {
    assertthat::assert_that(class(obj) == "seurat")
    if (! dir.exists(dir)) {
        stop(paste0(dir, " does not exist. Stopping!"))
    }
    
    # Barcodes
    cat(obj@cell.names, file = paste0(dir, "/barcodes.tsv"), sep = "\n")
    
    # Genes. Seurat doesn't store ENS ID. As a hack, put ENS_ID for all genes
    df <- data.frame(ID = "ENS_ID", symbol = rownames(obj@raw.data))
    write.table(df, row.names = F, col.names = F, sep = "\t", quote = F, file = paste0(dir, "/genes.tsv"))
    
    mat <- obj@raw.data[, obj@cell.names]
    Matrix::writeMM(mat, file = paste0(dir, "/matrix.mtx"))
}
