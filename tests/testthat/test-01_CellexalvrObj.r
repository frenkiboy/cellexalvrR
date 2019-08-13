context('error throwing') 
expect_error( loadObject( 'SomeFileNotExistsing') )

context('export2cellexalvr function')
prefix = '.'
opath = file.path( prefix, 'data','output' )
ipath = file.path( prefix, 'data' )
if ( file.exists(opath)) {
	unlink( opath, recursive=TRUE)
}
dir.create(opath,  showWarnings = FALSE, recursive = TRUE)

if ( file.exists(file.path(ipath,'cellexalObjOK.RData.lock')) ) {
	unlink(file.path(ipath, 'cellexalObjOK.RData.lock') )
}
if ( ! file.exists (file.path(ipath,'cellexalObjOK.RData') ) ) {
	stop( paste("Libraray error - test file not found ", file.path(ipath,'cellexalObjOK.RData')) )
}
cellexalObj <- loadObject(file.path(ipath,'cellexalObjOK.RData'))

ofiles = c( 'a.meta.cell', 'c.meta.gene', 'database.sqlite', 'DDRtree.mds', 
		 'index.facs',  'diffusion.mds', 'tSNE.mds' )


for ( f in ofiles ) {
	ofile = file.path(opath, f ) 
	if(  file.exists(ofile ) ){
		unlink( ofile)
	}
}
if (! file.exists( opath)) {
	dir.create(opath )
	dir.create( file.path(opath, 'default_user') )
	dir.create( file.path(opath, 'default_user','testSession'))
	dir.create( file.path(opath, 'default_user','testSession', 'tables'),  recursive = TRUE)
}
#cellexalObj@outpath = opath
export2cellexalvr(cellexalObj , opath )


for ( f in ofiles ) {
	ofile = file.path(opath, f ) 
	expect_true( file.exists( ofile ), paste("outfile exists", ofile) )
}



context( "store user groupings" )

old_length = 0
if ( length(cellexalObj@userGroups) > 0 ){
	old_length = length(cellexalObj@userGroups) -2 ## and therefore a pointless test...
}
cellexalObj = userGrouping(cellexalObj,normalizePath(file.path(ipath, 'selection0.txt') ))
expect_equal( length(cellexalObj@userGroups) , old_length + 2 )

cellexalObj = userGrouping(cellexalObj, file.path(opath,'..', 'selection0.txt') )
expect_equal( length(cellexalObj@userGroups) ,old_length +  2 ) # same grouing no adding of the data



context( "heatmap is produced" )
ofile = file.path(opath, 'selection0.png') 
if(  file.exists(ofile ) ){
	unlink( ofile)
}

make.cellexalvr.heatmap.list ( file.path(opath, 'cellexalObj.RData') , file.path(ipath,'selection0.txt'), 300, ofile )

expect_true( file.exists( ofile ),  paste("outfile missing:", ofile) )

