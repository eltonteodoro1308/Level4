#include 'totvs.ch'
#include "fwmvcdef.CH"

user function CRMA980()

	local oObj      := Paramixb[1]
	local cIDPonto  := Paramixb[2]
	local cIDModel  := Paramixb[3]
	local nOpc      := 0
	local aArea     := getArea()
	local aAreaSa2  := if( select( 'SA2' ) <> 0, SA2->( getArea() ), {} )
	local aAreaSx5  := if( select( 'SX5' ) <> 0, SX5->( getArea() ), {} )
	local cSeek     := ''
	local aAux      := {}
	local oModelSa2 := nil
	local cError    := ''

	if cIDPonto == 'BUTTONBAR'

		xRet := {}

	elseif cIDPonto == 'MODELCOMMITNTTS' .And. GetMv( 'MX_A1_2_A2' )

		cSeek := SA1->( xFilial( 'SA2' ) + A1_COD + A1_LOJA)

		DbSelectArea( 'SA2' )
		SA2->( DbSetOrder( 1 ) )
		nOpc := if( SA2->( DbSeek( cSeek ) ), 4, 3 )

		DbSelectArea( 'SX5' )
		SX5->( DbSetOrder( 1 ) )
		cSeek := xFilial( 'SX5' ) + 'ZX'

		if ! ( SX5->( DbSeek( cSeek ) .And. cSeek == X5_FILIAL + allTrim( X5_TABELA ) ) )

			MsgStop( 'A tabela genérica "ZX" com o de/para de campos do cliente para o fornecedor não foi definida,'+;
				' o cliente não será cadastrado como fornecedor', 'Atenção !!!' )

		else

			oModelSa2 := FwLoadModel ( 'MATA020' )
			oModelSa2:SetOperation( nOpc )
			oModelSa2:Activate()

			do while SX5->( ! Eof() .And. cSeek == X5_FILIAL + allTrim( X5_TABELA ) )

				aAux := StrTokArr2( allTrim(SX5->X5_DESCRI), '=', .T. )

				if oModelSa2:canSetValue( 'SA2MASTER', allTrim( upper( aAux[ 1 ] ) ) ) .And.;
						! oModelSa2:SetValue( 'SA2MASTER', allTrim( upper( aAux[ 1 ] ) ) , SA1->( &( aAux[ 2 ] ) ) )

					exit

				end if

				SX5->( DbSkip() )

			end do

		end if

		If oModelSa2:VldData()

			oModelSa2:CommitData()

		Else

			if ! isBlind()

				cError += 'Id do submodelo de origem: ' + cValToChar( oModelSa2:GetErrorMessage()[1] ) + CRLF
				cError += 'Id do campo de origem: '     + cValToChar( oModelSa2:GetErrorMessage()[2] ) + CRLF
				cError += 'Id do submodelo de erro: '   + cValToChar( oModelSa2:GetErrorMessage()[3] ) + CRLF
				cError += 'Id do campo de erro: '       + cValToChar( oModelSa2:GetErrorMessage()[4] ) + CRLF
				cError += 'Id do erro: '                + cValToChar( oModelSa2:GetErrorMessage()[5] ) + CRLF
				cError += 'mensagem do erro: '          + cValToChar( oModelSa2:GetErrorMessage()[6] ) + CRLF
				cError += 'mensagem da solução: '       + cValToChar( oModelSa2:GetErrorMessage()[7] ) + CRLF
				cError += 'Valor atribuido: '           + cValToChar( oModelSa2:GetErrorMessage()[8] ) + CRLF
				cError += 'Valor anterior: '            + cValToChar( oModelSa2:GetErrorMessage()[9] ) + CRLF

				AutoGrLog( 'Não foi possível incluir o cliente como fornecedor' + CRLF + CRLF + cError )

				mostraErro()

			end if

		EndIf

		oModelSa2:DeActivate()
		oModelSa2:Destroy()
		oModelSa2 := NIL

		if Empty( aAreaSa2 )

			SA2->( DbCloseArea() )

		else

			SA2->( RestArea( aAreaSa2 ) )

		end if

		if empty( aAreaSx5 )

			SX5->( DbCloseArea() )

		else

			SX5->( RestArea( aAreaSx5 ) )

		end if

		restArea( aArea )

	end if

return .T.
