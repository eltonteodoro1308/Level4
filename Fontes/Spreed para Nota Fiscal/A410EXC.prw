#include 'totvs.ch'

user function A410EXC()

	local lRet := .T.

	if getMv( 'MX_FIAX001' )

		if 0 > TCSQLExec( "UPDATE " + RetSqlName( 'SE2' ) + " SET E2_XPEDCOB = '" +;
				Space( TamSx3( "E2_XPEDCOB" )[ 1 ] ) + "' WHERE E2_XPEDCOB = '" + SC5->C5_NUM + "'" )

			msgStop( 'Ocorreu um erro ao desvincular os títulos a pagar vinculados a este pedido.', 'Atenção' )

			autoGrLog( TCSQLError() )

			MostraErro()

            lRet := .F.

		end if

	end if

return lRet
