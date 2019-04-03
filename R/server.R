#' @name server
#' @aliases server,character-method
#' @rdname server-methods
#' @docType methods
#' @description starts a server looking for a sourcable file in paste(file, 'input.R', sep='.')
#' The function sets a paste(file, 'input.lock', sep='.') lock file on processed scripts.
#' To shut down the server process you can either write a q('no') into the script file or remove the pid file.
#' @param file the file bas string to create input.R input.log and pid files.
#' @param sleepT sleep time in seconds between checks for the input.R file
#' @keywords server
#' @title start a server function periodicly sourcing in a file.
#' @export loadObject

if ( ! isGeneric('server') ){setGeneric('server', ## Name
			function ( file, sleepT=1 ) { 
				standardGeneric('server') 
			}
	) }

setMethod('server', signature = c ('character'),
		definition =  function(file, sleepT=1){
	lockfile   = paste( file, 'input.lock', sep=".") 
	scriptfile = paste( file, 'input.R', sep="." )
	pidfile    = paste( file, 'pid', sep='.')
	cat( Sys.getpid() , file = pidfile )
	
	print ( paste( "server is starting - reading from file:\n", scriptfile))
  	while(TRUE){
		if ( ! file.exists(pidfile ) ) {
			break
		}
        if ( file.exists( scriptfile ) ) {
                while ( file.exists( lockfile ) ) {
                        sleep( sleepT )
                }
				file.create(lockfile)
                try ( {source( scriptfile ) } )
                file.remove( scriptfile )
				file.remove(lockfile)
        }
        Sys.sleep( sleepT )   
	} 
	message( "Server pid file lost - closing down" );
	q('no')
}
)