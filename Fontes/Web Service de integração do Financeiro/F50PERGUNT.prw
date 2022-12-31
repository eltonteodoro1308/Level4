#include 'totvs.ch'

/*/{Protheus.doc} F50PERGUNT
Ponto de entrada que possibilita alterar as perguntas do FINA050 para rotinas de ExecAuto.
Utilizado para definir se um PA com origem na API deve ou não ser enviado para o cnanb.
@type function
@version 12.1.33 
@author elton.alves@totvs.com.br
@since 07/07/2022
/*/
user function F50PERGUNT()

	local cAlias     := getNextAlias()
	local aArea      := getArea()

	if FWisInCallStack('U_pWsPrcGn') .And. lIsPa 

		If Select( cAlias ) <> 0

			( cAlias )->( DbCloseArea() )

		EndIf

		BeginSql alias cAlias
	
			%NOPARSER%

			SELECT X1_ORDEM FROM SX1990 WHERE X1_GRUPO = 'FIN050'
			AND X1_PERGUNT IN( 'Gerar Chq.p/Adiant. ?','Mov.Banc.sem Cheque ?' )
			AND D_E_L_E_T_ = ' '
	
		EndSql

		While ( cAlias )->( !EOF() )

			eval( {|| &( 'MV_PAR' + ( cAlias )->X1_ORDEM + ' := ' + iif( lCnab, '2', '1' ) ) } )

			( cAlias )->( DbSkip() )

		EndDo

		( cAlias )->( DbCloseArea() )

	endIf

	restArea( aArea )

return
