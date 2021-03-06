
setGeneric('logTimeLine', ## Name
	function ( cellexalObj, stats, genes, info, png, timeInfo  ) {
		standardGeneric('logTimeLine')
	}
)
#' logTimeLine will create a section in the log document including 
#' (1) the DRC the grouping was selected from (colored 2D)
#' (2) the heatmap itself
#' (3) a GO analysis of the genes displayed in the heatmap (using ontologyLogPage()) #function definition in file 'ontologyLogPage.R'
#' @name logTimeLine
#' @aliases logTimeLine,cellexalvrR-method
#' @rdname logTimeLine-methods
#' @docType methods
#' @description preload the object before creating one Heatmap session report page
#' @param cellexalObj the cellexalvrR object
#' @param stats the correlation statistics
#' @param genes the genes to display on the heatmap
#' @param info the original grouping information list
#' @param png the heatmap of the rolling sum data
#' @param timeInfo the time grouping information list
#' @title description of function logTimeLine
#' @export 
setMethod('logTimeLine', signature = c ('cellexalvrR'),
	definition = function ( cellexalObj, stats, genes, info, png, timeInfo ) {
	## here I need to create a page of the final log

	if ( !is.null(genes)){
		if ( file.exists(genes[1])) {
			genes = as.vector(utils::read.delim(genes[1])[,1])
		}
	}

	cellexalObj = sessionPath( cellexalObj ) #function definition in file 'sessionPath.R'
	sessionPath = cellexalObj@usedObj$sessionPath

	cellexalObj = sessionRegisterGrouping( cellexalObj, cellexalObj@usedObj$lastGroup ) #function definition in file 'sessionRegisterGrouping.R'
	n = sessionCounter( cellexalObj, cellexalObj@usedObj$lastGroup ) #function definition in file 'sessionCounter.R'

	## now I need to create a heatmap myself using the genes provided

#	message("find a usable way to get the heatmap png")
	#file.copy(png, file.path( sessionPath , 'png', basename( png ) ) )
	#figureF = file.path( 'png', basename( png ) )
	#figureF = "Missing at the moment!"

	## now I need to create the 2D drc plots for the grouping
	drcFiles = drcPlots2D( cellexalObj, info ) #function definition in file 'drcPlot2D.R'
	## but I also want to show the TIME in the drc plot - hence I need a new grouping!

	drcFiles2 = drcPlots2D( cellexalObj, timeInfo) #function definition in file 'drcPlot2D.R'


	content = paste( sep="\n",
		paste( "##", "TimeLine control from Saved Selection ", sessionCounter( cellexalObj, cellexalObj@usedObj$lastGroup ) ),
		paste("This TimeLine is available in the R object as group",cellexalObj@usedObj$lastGroup ),
		"",
		paste( "### Genes") )
	content = paste( collapse=" ",content,
		paste( collapse=" ", unlist( lapply(sort(genes), function(n) { rmdLink(n, "https://www.genecards.org/cgi-bin/carddisp.pl?gene=")  })) ))
	
	if ( file.exists( png ) ) {
		figureF = stringr::str_extract( png,'png.*')

		content = paste( sep="\n", content,
			paste( "### Heatmapof rolling sum transformed expression (from R)"),
			paste("![](",figureF,")"),
			'The gene order is the same as in the Genes section and the VR heatmap')
	}
	content = paste( sep="\n", content,
		paste( "### 2D DRC", info$drc, " dim 1,2"),
		paste("![](",drcFiles[1],")"),
		'',
		paste( "### 2D DRC", info$drc, " dim 2,3"),
		paste("![](",drcFiles[2],")"),
		"",
		paste( "### TimeLine 2D DRC", info$drc, " dim 1,2"),
		paste("![](",drcFiles2[1],")"),
		'',
		paste( "### TimeLine 2D DRC", info$drc, " dim 2,3"),
		paste("![](",drcFiles2[2],")"),
		""

	)

	cellexalObj = storeLogContents( cellexalObj, content, type="OneGroupTime")
	id = length(cellexalObj@usedObj$sessionRmdFiles)
	cellexalObj = renderFile( cellexalObj, id, type="OneGroupTime" )

	if ( ! file.exists(file.path(sessionPath, '..', "cellexalObj.RData") )){
		lockedSave(cellexalObj, file.path(sessionPath, '..') ) #function definition in file 'lockedSave.R'
	}else {
		savePart(cellexalObj, 'usedObj' ) #function definition in file 'integrateParts.R'
	}
	
	cellexalObj
} )

#' @describeIn logTimeLine cellexalvrR
#' @description create one Heatmap session report page
#' @param cellexalObj the cellexalvrR file
#' @param stats the correlation statistics
#' @param genes the genes to display on the heatmap
#' @param info the original grouping information list
#' @param timeInfo the time grouping information list
#' @title description of function logTimeLine
#' @export
setMethod('logTimeLine', signature = c ('character'),
		definition = function (cellexalObj, stats, genes, info, png, timeInfo   ) {
			cellexalObj <- loadObject(cellexalObj) #function definition in file 'lockedSave.R'
			logTimeLine(cellexalObj, genes, png, grouping, ... ) #function definition in file 'logTimeLine.R'
		}
)


#' @name CreateBin
#' @aliases CreateBin,cellexalvrR-method
#' @rdname CreateBin-methods
#' @docType methods
#' @description Bin the UMI data into 13 bins for plotting and define a blue <- red color gradient
#' @param x the cellexalvrR object
#' @param group the group (defaule = 'nUMI'
#' @param where in the samples (sample) or annotation (gene) data frame (sample)
#' @param colFun colory function default=  gplots::bluered
#' @title Create a binned annotation column from numeric data
#' @export 
setGeneric('CreateBin', ## Name
	function (x, group = 'nUMI', where='sample', colFun =  gplots::bluered ) { 
		standardGeneric('CreateBin')
	}
)

setMethod('CreateBin', signature = c ('cellexalvrR'),
	definition = function (x, group = 'nUMI', where='sample', colFun =  gplots::bluered ) {
	if ( where == 'sample' ){
		n <-as.numeric(as.vector(x@userGroups[,group] ))
	}else if ( where == 'gene' ) {
		stop("Not implemented")
	}else {
		stop(paste("Sorry where =",where,"is not supported (only sample and gene)") )
	}
	n[which(is.na(n))] = -1
	m <- min( n )
	brks= c( (m-.1),m ,as.vector(quantile(n[which(n != m)],seq(0,1,by=0.1)) ))
	brks = unique(as.numeric(sprintf("%2.6e", brks)))
	d  <- factor(brks [cut( n, breaks= brks)], levels=brks)
	if ( where == 'sample' ){
		x@userGroups[, group] <- d
	}else {
	}
	# defined the color
	x@colors[[group]] <- colFun( 13 )
	invisible(x)
} )