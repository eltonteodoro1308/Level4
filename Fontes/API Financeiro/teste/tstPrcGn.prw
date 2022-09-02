#include 'totvs.ch'

user function tstPrcGn()

	RpcSetEnv( '99', '01' )

	u_pWsPrcGn( FwInputBox('Informe o UUID', space(32) ) )

	RpcClearEnv()

return

user function tstsprcgn()

	u_sWsPrcGn( {'99','01','',''} )

return
