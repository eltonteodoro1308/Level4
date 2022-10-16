#Include "TOTVS.ch"
#Include "FWMVCDEF.ch"

User Function CNTAX003()

	local nRet      := 0
	local aBotoes   := {}
	local cTitulo   := 'Processamento dos Apontamentos'
	local cMsg      := ''
	local cSair     := 'Sair'
	local cPerApto  := 'Período de Apontamento'
	local cPrcCtRec := 'Processar Recursos'
	local cPrcCtCli := 'Processar Clientes'
	local uMesApto  := nil

	aAdd( aBotoes, cSair )
	aAdd( aBotoes, cPerApto )
	aAdd( aBotoes, cPrcCtRec )
	aAdd( aBotoes, cPrcCtCli )

	while .T.

		uMesApto := GetMv( 'MX_APTOMES' )
		uMesApto := Month2Str( uMesApto ) + '/' + Year2Str( uMesApto )

		cMsg := 'Período em aberto para apontamentos: ' + uMesApto + '.' + CRLF
		cMsg += 'Empresa: ' + AllTrim( cFilAnt )
		cMsg += ' - ' + AllTrim( FWFilName( cEmpAnt, cFilAnt ) )

		nRet := Aviso( cTitulo, cMsg, aBotoes, 3 )

		if aBotoes[ nRet ] == cSair

			exit

		elseif aBotoes[ nRet ] == cPerApto

			if pergunte('CNTAX003A')

				uMesApto := cToD( '01/' + SubStr( MV_PAR01, 1, 2 ) + '/' + SubStr( MV_PAR01, 3, 4 ) )

				if ! empty( uMesApto )

					PutMv( 'MX_APTOMES', uMesApto )

				else

					ApMsgStop( 'Período inválido', 'Atenção !!!' )

				end if

			end if

		elseif aBotoes[ nRet ] == cPrcCtCli

			frmCtCli()

		elseif aBotoes[ nRet ] == cPrcCtRec

			frmCtRec()

		end if

	end

Return

static function frmCtRec()

	local cTitulo := 'Processamento de Recursos'
	local aTexto  := {}
	local aBotoes := {}

	aAdd( aTexto, 'Rotina de processamento dos apontamentos dos recursos' )
	aAdd( aTexto, 'para geração das medições dos contratos de compras.' )

	aAdd( aBotoes, { 15, .T., {|| procLogView(,'PRCCTREC') } } ) // Visualizar
	aAdd( aBotoes, { 05, .T., {|| pergunte( 'CNTAX003B ' )  } } ) // Parâmetros
	aAdd( aBotoes, { 02, .T., {|| fechaBatch()             } } ) // Cancelar
	aAdd( aBotoes, { 01, .T., {|| prcCt(1),FechaBatch()  } } ) // Ok

	FormBatch( cTitulo, aTexto, aBotoes, /*bValid*/, /*nAltura>*/, /*nLargura*/)

return

static function frmCtCli()

	local cTitulo := 'Processamento de Clientes'
	local aTexto  := {}
	local aBotoes := {}

	aAdd( aTexto, 'Rotina de processamento dos apontamentos dos recursos nos clientes' )
	aAdd( aTexto, 'para geração das medições dos contratos de vendas.' )

	aAdd( aBotoes, { 15, .T., {|| procLogView(,'PRCCTCLI') } } ) // Visualizar
	aAdd( aBotoes, { 05, .T., {|| pergunte( 'CNTAX003B' )  } } ) // Parâmetros
	aAdd( aBotoes, { 02, .T., {|| fechaBatch()             } } ) // Cancelar
	aAdd( aBotoes, { 01, .T., {|| prcCt(2),FechaBatch()     } } ) // Ok

	FormBatch( cTitulo, aTexto, aBotoes, /*bValid*/, /*nAltura>*/, /*nLargura*/)

return

static function prcCt( nTipoProc )

	local cAlias     := ''
	local cCompent   := ''
	local dDataDe    := CtoD('')
	local dDataAte   := CtoD('')
	local aListCtr   := {}
	local nX         := 0
	local cFuncName  := ''
	Local bConsProc  := nil

	Private cIdCV8     := ''

	if pergunte( 'CNTAX003B' )

		cAlias     := getNextAlias()
		cCompent   := SubStr( MV_PAR01, 1, 2 ) + '/' + SubStr( MV_PAR01, 3, 4 )
		dDataDe    := cToD( '01/' + cCompent )
		dDataAte   := LastDay( dDataDe )

		if Empty( dDataDe )

			ApMsgStop( 'Período informado inválido.', 'Atenção' )

		else

			If Select(cAlias) <> 0

				( cAlias )->( DbCloseArea() )

			EndIf

			if nTipoProc == 1

				cFuncName := 'prcCtRec'

			elseif nTipoProc == 2

				cFuncName := 'prcCtCli'

			else

				return

			end if

			bConsProc := &( '{||' + cFuncName + '( cAlias, dDataDe, dDataAte ) }' )

			MsgRun ( 'Processando Consulta ao Banco de Dados.', 'Aguarde ...', bConsProc )

			if ( cAlias )->( Eof() )

				ProcLogAtu('MENSAGEM', 'Não há registros a serem processados.',,,.T.)

			else

				While ( cAlias )->( !Eof() )

					MsgRun ( 'Montando Lista de Contratos.', 'Aguarde ...', {|| mntListCtr( aListCtr, cAlias, cCompent ) } )

					( cAlias )->( DbSkip() )

				EndDo

			end if

			for nX := 1 to len( aListCtr )

				MsgRun ( 'Processamento medições Contrato: ' + aListCtr[nX]["CONTRATO"], 'Aguarde ...', {|| incMedicao( aListCtr[ nX ] ) } )

			next nX

			ProcLogAtu('FIM',,,,.T.)
			procLogView(,,,@cIdCV8)

			( cAlias )->( DbCloseArea() )

		end if

	end if

return

static function prcCtRec( cAlias, dDataDe, dDataAte )

	procLogIni(,,,@cIdCV8)
	ProcLogAtu("INICIO",,,,.T.)

	BeginSql alias cAlias
		
		%NOPARSER%

		SELECT

		CN9.CN9_NUMERO, CN9.CN9_REVISA,
		CNA.CNA_NUMERO, CNA.CNA_XPLHRE, CNA.CNA_XRTAPR, 
		CNB.CNB_ITEM, CNB.CNB_PRODUT, CNB.CNB_QUANT, CNB.CNB_VLUNIT, CNB.CNB_TE CNE_TES,
		ZB_DTDHRS = (

			SELECT SUM(SZB.ZB_QTDHRS) ZB_QTDHRS FROM %TABLE:SZB% SZB
			INNER JOIN %TABLE:SZA% SZAX
			ON SZAX.D_E_L_E_T_  = SZB.D_E_L_E_T_
			AND SZAX.ZA_FILIAL = SZB.ZB_FILIAL
			AND SZAX.ZA_CODREC = SZB.ZB_RECURS
			AND SZAX.ZA_CODIGO = SZB.ZB_TAREFA
			WHERE SZB.%NOTDEL%
			AND SZB.ZB_FILIAL = %XFILIAL:SZB%
			AND SZB.ZB_DTINIC BETWEEN 
			CONVERT( CHAR(8), DATEADD( M, -CNA.CNA_XRTAPR, CAST( %EXP:dTos( dDataDe )% AS DATE )  ), 112) AND 
			CONVERT( CHAR(8), DATEADD( D, -1, DATEADD(M, 1, DATEADD( M, -CNA.CNA_XRTAPR, CAST( %EXP:dTos( dDataDe )% AS DATE ) ) ) ), 112 )
			AND SZAX.ZA_RECCTR = CN9.CN9_NUMERO
			AND SZAX.ZA_RECRVCT = CN9.CN9_REVISA
			AND SZAX.ZA_RECPLAN = CNA.CNA_NUMERO
			AND SZAX.ZA_RECITEM = CNB.CNB_ITEM
		)

		FROM %TABLE:CN9% CN9

		INNER JOIN %TABLE:CNA% CNA
		ON CN9.D_E_L_E_T_  = CNA.D_E_L_E_T_
		AND CN9.CN9_FILIAL = CNA.CNA_FILIAL
		AND CN9.CN9_NUMERO = CNA.CNA_CONTRA
		AND CN9.CN9_REVISA = CNA.CNA_REVISA

		INNER JOIN %TABLE:CNB% CNB
		ON CNA.D_E_L_E_T_  = CNB.D_E_L_E_T_
		AND CNA.CNA_FILIAL = CNB.CNB_FILIAL
		AND CNA.CNA_CONTRA = CNB.CNB_CONTRA
		AND CNA.CNA_REVISA = CNB.CNB_REVISA
		AND CNA.CNA_NUMERO = CNB.CNB_NUMERO

		INNER JOIN %TABLE:SZA% SZA
		ON CNB.D_E_L_E_T_  = SZA.D_E_L_E_T_
		AND CNB.CNB_FILIAL = SZA.ZA_FILIAL
		AND CNB.CNB_CONTRA = SZA.ZA_RECCTR
		AND CNB.CNB_REVISA = SZA.ZA_RECRVCT   
		AND CNB.CNB_NUMERO = SZA.ZA_RECPLAN
		AND CNB.CNB_ITEM   = SZA.ZA_RECITEM

		WHERE CN9.%NOTDEL%
		AND CN9.CN9_TPCTO = %EXP:GETMV('MX_TPCTCP')%
		AND CN9.CN9_SITUAC = '05'
		AND CNA.CNA_TIPPLA = %EXP:GETMV('MX_TPPLCP')%
		AND CNA.CNA_PROMED BETWEEN %EXP:dTos(dDataDe)% AND %EXP:dTos(dDataAte)%

		ORDER BY SZA.ZA_FILIAL, SZA.ZA_RECCTR, SZA.ZA_RECRVCT, SZA.ZA_RECPLAN, SZA.ZA_RECITEM
		
	EndSql

return

static function prcCtCli( cAlias, dDataDe, dDataAte )

	procLogIni(,,,@cIdCV8)
	ProcLogAtu("INICIO",,,,.T.)

	BeginSql alias cAlias
		
		%NOPARSER%

		SELECT

		CN9.CN9_NUMERO, CN9.CN9_REVISA,
		CNA.CNA_NUMERO, CNA.CNA_XPLHRE, CNA.CNA_XRTAPR, 
		CNB.CNB_ITEM, CNB.CNB_PRODUT, CNB.CNB_QUANT, CNB.CNB_VLUNIT, CNB.CNB_TS  CNE_TES,
		ZB_DTDHRS = (

			SELECT SUM(SZB.ZB_QTDHRS) ZB_QTDHRS FROM %TABLE:SZB% SZB

			INNER JOIN %TABLE:SZA% SZAX
			ON SZAX.D_E_L_E_T_  = SZB.D_E_L_E_T_
			AND SZAX.ZA_FILIAL = SZB.ZB_FILIAL
			AND SZAX.ZA_CODREC = SZB.ZB_RECURS
			AND SZAX.ZA_CODIGO = SZB.ZB_TAREFA

			WHERE SZB.%NOTDEL%
			AND SZB.ZB_FILIAL = %XFILIAL:SZB%
			AND SZB.ZB_DTINIC BETWEEN 
			CONVERT( CHAR(8), DATEADD( M, -CNA.CNA_XRTAPR, CAST( %EXP:dTos( dDataDe )% AS DATE )  ), 112) AND 
			CONVERT( CHAR(8), DATEADD( D, -1, DATEADD(M, 1, DATEADD( M, -CNA.CNA_XRTAPR, CAST( %EXP:dTos( dDataDe )% AS DATE ) ) ) ), 112 )
			AND SZAX.ZA_CLICTR = CN9.CN9_NUMERO
			AND SZAX.ZA_CLIRVCT = CN9.CN9_REVISA
			AND SZAX.ZA_CLIPLAN = CNA.CNA_NUMERO
			AND SZAX.ZA_CLIITEM = CNB.CNB_ITEM
		)

		FROM %TABLE:CN9% CN9

		INNER JOIN %TABLE:CNA% CNA
		ON CN9.D_E_L_E_T_  = CNA.D_E_L_E_T_
		AND CN9.CN9_FILIAL = CNA.CNA_FILIAL
		AND CN9.CN9_NUMERO = CNA.CNA_CONTRA
		AND CN9.CN9_REVISA = CNA.CNA_REVISA

		INNER JOIN %TABLE:CNB% CNB
		ON CNA.D_E_L_E_T_  = CNB.D_E_L_E_T_
		AND CNA.CNA_FILIAL = CNB.CNB_FILIAL
		AND CNA.CNA_CONTRA = CNB.CNB_CONTRA
		AND CNA.CNA_REVISA = CNB.CNB_REVISA
		AND CNA.CNA_NUMERO = CNB.CNB_NUMERO

		INNER JOIN %TABLE:SZA% SZA
		ON CNB.D_E_L_E_T_  = SZA.D_E_L_E_T_
		AND CNB.CNB_FILIAL = SZA.ZA_FILIAL
		AND CNB.CNB_CONTRA = SZA.ZA_CLICTR
		AND CNB.CNB_REVISA = SZA.ZA_CLIRVCT   
		AND CNB.CNB_NUMERO = SZA.ZA_CLIPLAN
		AND CNB.CNB_ITEM   = SZA.ZA_CLIITEM

		WHERE CN9.%NOTDEL%
		AND CN9.CN9_TPCTO = %EXP:GETMV('MX_TPCTVD')%
		AND CN9.CN9_SITUAC = '05'
		AND CNA.CNA_TIPPLA = %EXP:GETMV('MX_TPPLVD')%
		AND CNA.CNA_PROMED BETWEEN %EXP:dTos(dDataDe)% AND %EXP:dTos(dDataAte)%

		ORDER BY SZA.ZA_FILIAL, SZA.ZA_CLICTR, SZA.ZA_CLIRVCT, SZA.ZA_CLIPLAN, SZA.ZA_CLIITEM
		
	EndSql

return

static function mntListCtr( aListCtr, cAlias, cCompent )

	local nPos := 0

	( cAlias )->( nPos := aScan( aListCtr, { | item |  item['CONTRATO'] == CN9_NUMERO } ) )

	if nPos == 0

		aAdd( aListCtr, jsonObject():new() )

		aTail( aListCtr )['CONTRATO']  := ( cAlias )->( CN9_NUMERO )
		aTail( aListCtr )['PLANILHAS'] := {}
		aTail( aListCtr )['COMPETENCIA'] := cCompent

	end if

	( cAlias )->( nPos := aScan( aTail( aListCtr )['PLANILHAS'], { | item |  item['NUMERO'] == CNA_NUMERO } ) )

	if nPos == 0

		aAdd( aTail( aListCtr )['PLANILHAS'], jsonObject():new() )

		aTail( aTail( aListCtr )['PLANILHAS'] )['NUMERO'] := ( cAlias )->( CNA_NUMERO )
		aTail( aTail( aListCtr )['PLANILHAS'] )['PLAN_EXCED'] := ( cAlias )->( CNA_XPLHRE )
		aTail( aTail( aListCtr )['PLANILHAS'] )['ITENS'] := {}

	end if

	aAdd(aTail( aTail( aListCtr )['PLANILHAS'] )['ITENS'], JsonObject():New() )

	aTail( aTail( aTail( aListCtr )['PLANILHAS'] )['ITENS'] )['ITEM']  := ( cAlias )->( CNB_ITEM )
	aTail( aTail( aTail( aListCtr )['PLANILHAS'] )['ITENS'] )['PRODUTO']  := ( cAlias )->( CNB_PRODUT )
	aTail( aTail( aTail( aListCtr )['PLANILHAS'] )['ITENS'] )['QUANT_ESTIMADA']  := ( cAlias )->( CNB_QUANT )
	aTail( aTail( aTail( aListCtr )['PLANILHAS'] )['ITENS'] )['QUANT_REALIZADA']  := ( cAlias )->( ZB_DTDHRS )
	aTail( aTail( aTail( aListCtr )['PLANILHAS'] )['ITENS'] )['VALOR_UNITARIO'] := ( cAlias )->( CNB_VLUNIT )
	aTail( aTail( aTail( aListCtr )['PLANILHAS'] )['ITENS'] )['TES'] := ( cAlias )->( CNE_TES )

return

static function incMedicao( jContrato )

	Local oModel     := Nil
	Local aCompets   := {}
	Local nCompet    := 0
	Local cNumMed    := ""
	Local aMsgDeErro := {}
	Local cMsgDeErro := ''
	Local aArea      := GetArea()
	Local nPos       := 0
	Local nX         := 0
	Local nY         := 0

	DbSelectArea('CN9')
	CN9->(DbSetOrder(1))

	If ! CN9->( DbSeek( xFilial( "CN9" ) + jContrato['CONTRATO'] ) )//Posicionar na CN9 para realizar a inclusão

		ProcLogAtu( 'ERRO', 'Contrato inválido.', 'O contrato ' + jContrato['CONTRATO'] + ' não é válido para a Filial ' + cFilAnt,,.T.)

	else

		aCompets := CtrCompets()

		if Empty( nCompet := aScan( aCompets, { | cItem | allTrim( cItem ) == allTrim( jContrato['COMPETENCIA'] ) } ) )

			ProcLogAtu( 'ERRO', 'Competência inválida.',;
				'A competência ' + cCompet + ' não é válida para o contrato ' + jContrato['CONTRATO'],,.T.)

		else

			oModel := FWLoadModel("CNTA121")

			oModel:SetOperation(MODEL_OPERATION_INSERT)

			If oModel:CanActivate()

				oModel:Activate()
				oModel:SetValue("CNDMASTER","CND_CONTRA"    ,CN9->CN9_NUMERO)
				oModel:SetValue("CNDMASTER","CND_RCCOMP"    , cValToChar( nCompet ) )//Selecionar competência

				/*
				Tratando planilhas planejdas
				*/
				for nX := 1 to Len( jContrato['PLANILHAS'] )

					if oModel:getModel('CXNDETAIL'):seekLine( { { 'CXN_NUMPLA', jContrato[ 'PLANILHAS' ][ nX ][ 'NUMERO' ] } } )

						oModel:SetValue("CXNDETAIL","CXN_CHECK", .T.)
						oModel:GetModel('CNEDETAIL'):GoLine(1)

						for nY := 1 to Len( oModel:getModel('CNEDETAIL'):getOldData() )

							nPos := aScan( jContrato[ 'PLANILHAS' ][ nX ]['ITENS'],;
								{ | item | item["ITEM"] == oModel:getModel('CNEDETAIL'):GetValue( 'CNE_ITEM' ) } )

							if nPos > 0

								if jContrato[ 'PLANILHAS' ][ nX ]['ITENS'][ nPos ]['QUANT_REALIZADA'] < ;
										oModel:getModel('CNEDETAIL'):GetValue( 'CNE_QUANT' )

									oModel:getModel('CNEDETAIL'):SetValue( 'CNE_QUANT',;
										jContrato[ 'PLANILHAS' ][ nX ]['ITENS'][ nPos ]['QUANT_REALIZADA']  )

								end if

							else

								oModel:getModel('CNEDETAIL'):SetValue( 'CNE_QUANT', 0 )

							end if

							oModel:GetModel('CNEDETAIL'):GoLine( nX )

						next nX

					end if

				next nX

				/*
				Tratando planilhas de horas excedentes
				*/
				for nX := 1 to Len( jContrato['PLANILHAS'] )

					for nY := 1 to len( jContrato[ 'PLANILHAS' ][ nX ]['ITENS'] )

						if jContrato[ 'PLANILHAS' ][ nX ]['ITENS'][ nY ]['QUANT_REALIZADA'] >;
								jContrato[ 'PLANILHAS' ][ nX ]['ITENS'][ nY ]['QUANT_ESTIMADA'] .And.;
								oModel:getModel('CXNDETAIL'):seekLine( { { 'CXN_NUMPLA', jContrato[ 'PLANILHAS' ][ nX ][ 'PLAN_EXCED' ] } } )

							oModel:SetValue("CXNDETAIL","CXN_CHECK", .T.)

							if nY != 1

								oModel:GetModel('CNEDETAIL'):GoLine(;
									oModel:getModel('CNEDETAIL'):AddLine() )

							end if

							oModel:getModel('CNEDETAIL'):LoadValue('CNE_ITEM', PadL( cValToChar( nY ), CNE->( Len( CNE_ITEM ) ), '0' ) )

							oModel:getModel('CNEDETAIL'):setValue( 'CNE_PRODUT', jContrato[ 'PLANILHAS' ][ nX ]['ITENS'][ nY ][ 'PRODUTO' ] )
							oModel:getModel('CNEDETAIL'):setValue( 'CNE_QUANT ', jContrato[ 'PLANILHAS' ][ nX ]['ITENS'][ nY ][ 'QUANT_REALIZADA' ] -;
								jContrato[ 'PLANILHAS' ][ nX ]['ITENS'][ nY ]['QUANT_ESTIMADA'] )
							oModel:getModel('CNEDETAIL'):setValue( 'CNE_VLUNIT', jContrato[ 'PLANILHAS' ][ nX ]['ITENS'][ nY ][ 'VALOR_UNITARIO' ] )

							if ! Empty( jContrato[ 'PLANILHAS' ][ nX ]['ITENS'][ nY ][ 'TES' ] )

								oModel:getModel('CNEDETAIL'):setValue( 'CNE_TES', jContrato[ 'PLANILHAS' ][ nX ]['ITENS'][ nY ][ 'TES' ] )

							END IF

						end if

					next nY

				next nX

				If (oModel:VldData()) /*Valida o modelo como um todo*/

					oModel:CommitData()

				EndIf

			EndIf

			If( oModel:HasErrorMessage() )

				aMsgDeErro := oModel:GetErrorMessage()

				ascan( aMsgDeErro, { | cItem | cMsgDeErro += allTrim( cItem ) } )

				ProcLogAtu('ERRO', 'Erro no Processamento do contrato ' + jContrato['CONTRATO'], cMsgDeErro,,.T.)

			Else

				cNumMed := CND->CND_NUMMED

				oModel:DeActivate()

				ProcLogAtu('MENSAGEM', 'Gerada a Medição ' + cNumMed,,,.T.)

				if CN121Encerr(.T.) //Realiza o encerramento da medição

					ProcLogAtu('MENSAGEM', 'Medição ' + cNumMed + ' encerrada.',,,.T.)

				else

					ProcLogAtu('ERRO', 'Medição ' + cNumMed + ' não pode ser encerrada.',,,.T.)

				end if

			EndIf

		end if

	end if

	RestArea( aArea )

Return

// ProcLogAtu('INICIO', 'Início do processamnto do contrato',,,.T.)
// ProcLogAtu('ALERTA', 'Alerta de processamento',,,.T.)
// ProcLogAtu('ERRO', 'Erro no Processamento',,,.T.)
// ProcLogAtu('CANCEL', 'Processamento Cancelado',,,.T.)
// ProcLogAtu('MENSAGEM', 'Mensagem do Processamento',,,.T.)
// ProcLogAtu('FIM', 'Fim do processamento',,,.T.)
