#' Write data in CELLEX format https://github.com/perslab/CELLEX.
#'
#' @param seurat_obj Seurat object to print
#' @param outprefix Character. Prefix for outfiles
#' @param outdir Character. Directory in which to place files
#' @export
#' @importFrom assertthat assert_that
#' @examples
#' WriteCELLEX(seurat_obj, cellranger_dir, outprefix, outdir)
WriteCELLEX <- function(seurat_obj, outprefix, outdir = ".") {
    assert_that(class(seurat_obj) %in% c("seurat", "Seurat"))
    if (!dir.exists(outdir)) {
        stop(paste0(outdir, " does not exist. Stopping!"))
    }
    
    if (class(seurat_obj) == "seurat") {
        # Seurat v2
        stop("Unsupported (old) Seurat object")
    } else if (class(seurat_obj) == "Seurat") {
        # Seurat v3.
        countsfile <- paste0(outdir, "/", outprefix, "_data.csv")
        write.csv(as.matrix(GetAssayData(seurat_obj, "counts")), file = countsfile)
        # previously used write_csv but that requires a data.frame.
        mdatfile <- paste0(outdir, "/", outprefix, "_metadata.csv")
        mdat <- data.frame(cell_id = Cells(seurat_obj), cell_type = Idents(seurat_obj))
        write.csv(mdat, file=mdatfile, quote=FALSE, row.names=FALSE)
    } else {
        stop("Should not get here")
    }
    return()
}
