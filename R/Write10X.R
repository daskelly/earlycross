#' Write data in 10X format i.e. directory with barcodes.tsv, genes.tsv, matrix.mtx
#' If object is Seurat v2, output cellranger2-like format
#' If object is Seurat v3, output cellranger3-like format
#'
#' @param obj Seurat object to print
#' @param dir Character. Directory in which to place 10X-like files
#' @export
#' @importFrom assertthat assert_that
#' @importFrom Matrix writeMM
#' @importFrom R.utils gzip
#' @examples
#' Write10X(obj, dir)
Write10X <- function(obj, dir) {
    assert_that(class(obj) %in% c("seurat", "Seurat"))
    if (!dir.exists(dir)) {
        stop(paste0(dir, " does not exist. Stopping!"))
    }
    
    if (class(obj) == "seurat") {
        # Seurat v2. Will output in cellranger2-like format i.e. barcodes.tsv, genes.tsv,
        # matrix.mtx
        cat(obj@cell.names, file = paste0(dir, "/barcodes.tsv"), sep = "\n")
        
        # Genes. Seurat doesn't store ENS ID. As a hack, put ENS_ID for all genes
        df <- data.frame(ID = "ENS_ID", symbol = rownames(obj@raw.data))
        write.table(df, row.names = F, col.names = F, sep = "\t", quote = F, file = paste0(dir, 
            "/genes.tsv"))
        
        mat <- obj@raw.data[, obj@cell.names]
        writeMM(mat, file = paste0(dir, "/matrix.mtx"))
    } else if (class(obj) == "Seurat") {
        # Seurat v3. Will output in cellranger3-like format i.e. barcodes.tsv.gz
        # features.tsv.gz matrix.mtx.gz
        gz1 <- gzfile(paste0(dir, "/barcodes.tsv.gz"), "w")
        cat(colnames(obj), file = gz1, sep = "\n")
        close(gz1)
        
        # Genes. Seurat doesn't store ENS ID. As a hack, put ENS_ID for all genes
        df <- data.frame(ID = "ENS_ID", symbol = rownames(obj))
        gz2 <- gzfile(paste0(dir, "/features.tsv.gz"), "w")
        write.table(df, row.names = F, col.names = F, sep = "\t", quote = F, file = gz2)
        close(gz2)
        
        mat <- GetAssayData(obj, slot = "counts")[, colnames(obj)]
        assert_that(nrow(mat) > 0 && ncol(mat) > 0, msg = "counts matrix is not present!")
        writeMM(mat, file = paste0(dir, "/matrix.mtx"))
        gzip(filename = paste0(dir, "/matrix.mtx"))
    } else {
        stop("Should not get here")
    }
    return()
}
