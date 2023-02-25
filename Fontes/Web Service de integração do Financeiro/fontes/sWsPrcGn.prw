#include 'totvs.ch'

/*/{Protheus.doc} sWsPrcGn
Rotina a ser executada pelo schedule que busca os processamentos a
serem executados para a empresa/filial solicitada pelo schedule
@type function
@version  12.1.33
@author elton.alves@totvs.com.br
@since 25/03/2022
@param aParam, array, Array enviado pelo scheduele com os parâmetros de execução da rotina.
/*/
user function sWsPrcGn( aParam )

	local nTam   := len( aParam )
	local cEmp   := aParam[ nTam - 3 ]
	local cFil   := aParam[ nTam - 2 ]


	if RpcSetEnv( cEmp, cFil )

		if LockByName("sWsPrcGn", .T., .T.)

			Process()

			UnlockByName("sWsPrcGn", .T., .T., .F.)

		end if

	else

		ConOut( 'Não foi possível logar na Empresa/Filial ' + cEmp + '/' + cFil )

	end if

return

/*/{Protheus.doc} Process
Função que busca os processamentos a serem executados para a empresa/filial solicitada pelo schedule
@type function
@version  12.1.33
@author elton.alves@totvs.com.br
@since 25/03/2022
/*/
static function Process()

	local cAlias := getNextAlias()

	If Select(cAlias) <> 0
		(cAlias)->(DbCloseArea())
	EndIf

	BeginSql alias cAlias
       
        SELECT SZ1.Z1_UUID FROM %TABLE:SZ1% SZ1
        
        WHERE SZ1.%NOTDEL%
		AND SZ1.Z1_FILIAL = %XFILIAL:SZ1%
        AND SZ1.Z1_STATUS = '0'
       
	EndSql

	( cAlias )->( DbGoTop() )

	while ! ( cAlias )->( Eof() )

		U_pWsPrcGn( ( cAlias )->Z1_UUID )

		( cAlias )->( DbSkip() )

	end

	( cAlias )->( DbCloseArea() )

	rpcclearenv()

return
