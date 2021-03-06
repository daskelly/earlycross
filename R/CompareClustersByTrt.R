#' Given a Seurat object and treatment variable, compare
#' clusters between levels of the treatment
#'
#' @param obj Seurat object
#' @param trt_var Treatment variable
#' @param rep_var Replicate/Individual ID variable
#' @param ci Whether to plot binomial confidence intervals (Jeffreys)
#' @param group_by Name of grouping variable (default is Idents)
#' @export
#' @importFrom magrittr '%>%'
#' @examples
#' pbmc_small$trt <- sample(c('drug', 'control'), ncol(pbmc_small), replace=TRUE)
#' pbmc_small$genotype <- sample(c('1', '2', '3'), ncol(pbmc_small), replace=TRUE)
#' CompareClustersByTrt(pbmc_small, trt, genotype) + ggplot2::xlab('')
CompareClustersByTrt <- function(obj, trt_var, rep_var, group_by = NULL, ci = TRUE, 
    ci_alpha = 0.05, seed = 1) {
    # For curly curly {{ syntax see
    # https://www.tidyverse.org/blog/2019/06/rlang-0-4-0/
    meta <- obj@meta.data %>% as.data.frame() %>% tibble::rownames_to_column("cell")
    if (is.null(group_by)) {
        meta$ident <- Idents(obj)
    } else {
        meta$ident <- meta[[group_by]]
    }
    
    grp_dat <- dplyr::group_by(meta, {{ trt_var }}, {{ rep_var }}) %>% dplyr::mutate(N_tot = dplyr::n()) %>% 
            dplyr::ungroup() %>% dplyr::group_by({{ trt_var }}, {{ rep_var }}, ident, N_tot)
    grp_dat <- grp_dat %>% dplyr::summarize(N = dplyr::n()) %>% dplyr::mutate(frac = N/N_tot)
    
    # Put binomial confidence intervals around the cell abundance estimates Use
    # Jeffreys interval -- posterior dist'n is Beta(x + 1/2, n – x + 1/2)
    grp_stats <- dplyr::mutate(grp_dat, lower = qbeta(ci_alpha/2, N + 1/2, N_tot - 
        N + 1/2)) %>% dplyr::mutate(upper = qbeta(1 - ci_alpha/2, N + 1/2, N_tot - 
        N + 1/2)) %>% dplyr::mutate(cells_per_thousand = frac * 1000) %>% dplyr::mutate(lower_per_thousand = lower * 
        1000, upper_per_thousand = upper * 1000)
    # Get some summary stats
    cfrac <- grp_stats %>% dplyr::group_by(ident) %>% dplyr::summarize(max_per_1k = max(cells_per_thousand)) %>% 
        dplyr::arrange(dplyr::desc(max_per_1k))
    
    # Make the plot
    set.seed(seed)
    dodge <- ggplot2::position_jitterdodge(jitter.width = 0.4, dodge.width = 0.55)
    grp_stats$popF <- factor(grp_stats$ident, cfrac$ident)
    g2 <- ggplot2::ggplot(grp_stats, ggplot2::aes(x = {{ trt_var }}, y = cells_per_thousand, 
        color = {{ trt_var }}, fill = {{ trt_var }})) + ggplot2::geom_linerange(ggplot2::aes(ymin = lower_per_thousand, 
        ymax = upper_per_thousand), position = dodge, alpha = 0.4, color = "darkgray") + 
        ggplot2::geom_point(shape = 16, position = dodge) + ggplot2::facet_wrap(~popF, 
        scales = "free_y") + #ggplot2::xlab({{ trt_var }}) + 
        ggplot2::ylab("Cells per thousand") + 
        ggplot2::guides(fill = FALSE, color = FALSE) + ggplot2::theme_bw(base_size = 16) + 
        ggplot2::theme(panel.grid.minor = ggplot2::element_blank())
    g2
}
