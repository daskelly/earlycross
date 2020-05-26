#' Write data in CELLEX format https://github.com/perslab/CELLEX.
#'
#' @param seurat_obj Seurat object to print
#' @param cellranger_dir Dir of Cellranger results. Needed to get ENS IDs
#' @param outprefix Character. Prefix for outfiles
#' @param outdir Character. Directory in which to place files
#' @export
#' @importFrom assertthat assert_that
#' @importFrom readr write_csv
#' @examples
#' WriteCELLEX(seurat_obj, cellranger_dir, outprefix, outdir)
WriteCELLEX <- function(seurat_obj, cellranger_dir, outprefix, outdir='.') {
    assert_that(class(seurat_obj) %in% c("seurat", "Seurat"))
    if (! dir.exists(outdir)) {
        stop(paste0(outdir, " does not exist. Stopping!"))
    }

    if (class(seurat_obj) == "seurat") {
      # Seurat v2
	  stop("Unsupported (old) Seurat object")
    } else if (class(seurat_obj) == "Seurat") {
      # Seurat v3.
      cells <- colnames(seurat_obj)
      warning("Assuming cellranger3 directory specified")
      x <- CreateSeuratObject(Read10X(cellranger_dir, gene.column=1))
      assert_that(all(cells %in% colnames(x)))
      countsfile <- paste0(outdir, '/', outprefix, '_data.csv')
      write_csv(as.matrix(GetAssayData(x, 'counts')), path=countsfile)
      mdatfile <- paste0(outdir, '/', outprefix, '_metadata.csv')
      mdat <- data.frame(cell_id=cells, cell_type=Idents(seurat_obj))
      write_csv(mdat, path=mdatfile)
    } else {
      stop("Should not get here")
    }
    return()
}
