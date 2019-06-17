#' Given a Seurat object and treatment variable, compare
#' clusters between levels of the treatment
#'
#' @param obj Seurat object
#' @param trt_var Treatment variable
#' @param rep_var Replicate/Individual ID variable
#' @param ci Whether to plot binomial confidence intervals (Jeffreys)
#' @param group_by Name of grouping variable (default is Idents)
#' @export
#' @import tidyverse
#' @examples
#' CompareClustersByTrt(obj, drug, mouse_ID, ci=TRUE)
CompareClustersByTrt <- function(obj, trt_var, rep_var=NULL, group_by=NULL, ci=TRUE, ci_alpha=0.05, seed=1) {
	meta <- obj@meta.data %>% as.data.frame() %>%
		rownames_to_column("cell")
	trt_var_string <- trt_var
	trt_var <- enquo(trt_var)
	if (is.null(group_by)) {
		meta$ident <- Idents(obj)
	} else {
		meta$ident <- meta[[group_by]]
	}

	if (is.null(rep_var)) {
		grp_dat <- group_by(meta, !!trt_var) %>%
			mutate(N_tot=n()) %>% ungroup() %>%
			group_by(!!trt_var, ident, N_tot)
	} else {
		rep_var <- enquo(rep_var)
		grp_dat <- group_by(meta, !!trt_var, !!rep_var) %>%
			mutate(N_tot=n()) %>% ungroup() %>%
			group_by(!!trt_var, !!rep_var, ident, N_tot)
	}
	grp_dat <- grp_dat %>% summarize(N=n()) %>% mutate(frac=N/N_tot)
	
	# Put binomial confidence intervals around the cell abundance estimates
	# Use Jeffreys interval -- posterior dist'n is Beta(x + 1/2, n – x + 1/2)
	grp_stats <- mutate(grp_dat, lower=qbeta(ci_alpha/2, N + 1/2, N_tot - N + 1/2)) %>%
  		mutate(upper=qbeta(1-ci_alpha/2, N + 1/2, N_tot - N + 1/2)) %>%
 		mutate(cells_per_thousand=frac*1000) %>%
  		mutate(lower_per_thousand=lower*1000, upper_per_thousand=upper*1000)
  	# Get some summary stats
	cfrac <- grp_stats %>% group_by(ident) %>%
    	summarize(max_per_1k=max(cells_per_thousand)) %>%
    	arrange(desc(max_per_1k))
    
    # Make the plot
    set.seed(seed)
    dodge <- position_jitterdodge(jitter.width=0.4, dodge.width=0.55)
    grp_stats$popF <- factor(grp_stats$ident, cfrac$ident)
    g2 <- ggplot(grp_stats, aes(x=!!trt_var, y=cells_per_thousand, 
    	color=!!trt_var, fill=!!trt_var)) +
		geom_linerange(aes(ymin=lower_per_thousand, ymax=upper_per_thousand), 
			position=dodge, alpha=0.4, color='darkgray') +
		geom_point(shape=16, position=dodge) +
		facet_wrap(~ popF, scales="free_y") + xlab(trt_var_string) + ylab("Cells per thousand") +
		guides(fill=FALSE, color=FALSE) +
		theme_bw(base_size=16) +
		theme(panel.grid.minor=element_blank())
	g2
}
