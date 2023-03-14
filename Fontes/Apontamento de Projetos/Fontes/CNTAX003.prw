#Include "TOTVS.ch"
#Include "FWMVCDEF.ch"

User Function CNTAX003()

	local nRet      := 0
	local aBotoes   := {}
	local cTitulo   := 'Processamento dos Apontamentos'
	local cMsg      := ''
	local cSair     := 'Sair'
	local cToldias  := 'Tolerância de dias de Apontamento'
	local cPrcCtRec := 'Processar Recursos'
	local cPrcCtCli := 'Processar Clientes'

	aAdd( aBotoes, cSair )
	aAdd( aBotoes, cToldias )
	aAdd( aBotoes, cPrcCtRec )
	aAdd( aBotoes, cPrcCtCli )

	while .T.

		cMsg := 'Empresa: ' + AllTrim( cFilAnt )
		cMsg += ' - ' + AllTrim( FWFilName( cEmpAnt, cFilAnt ) ) + CRLF
		cMsg += 'Dias de Tolerância: ' + cValtoChar( GetMv( 'MX_TOLDIAS' ) )

		nRet := Aviso( cTitulo, cMsg, aBotoes, 3 )

		if aBotoes[ nRet ] == cSair

			exit

		elseif aBotoes[ nRet ] == cToldias

			if pergunte('CNTAX003A')

				PutMv( 'MX_TOLDIAS', MV_PAR01 )

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
	local aListCtr   := {}
	local nX         := 0

	Private cIdCV8     := ''
	Private nLimHrsMes := 0

	if pergunte( 'CNTAX003B' )

		if empty( FWGetSX5( 'ZY', MV_PAR01 ) )

			apMsgInfo( 'Não foi definida o total de horas úteis para esta competência, na tabela genérica "ZY".', 'Atenção !!!' )

			return

		else

			nLimHrsMes := VAL(FWGetSX5( 'ZY', MV_PAR01 )[1][4])

		end if

		cAlias     := getNextAlias()
		cCompent   := SubStr( MV_PAR01, 1, 2 ) + '/' + SubStr( MV_PAR01, 3, 4 )

		if Empty( cToD( '01/' + cCompent ) )

			ApMsgStop( 'Período informado inválido.', 'Atenção' )

		else

			If Select(cAlias) <> 0

				( cAlias )->( DbCloseArea() )

			EndIf

			MsgRun ( 'Processando Consulta ao Banco de Dados.', 'Aguarde ...',;
				{|| prcQuery( cAlias, strTran( cCompent, '/', '' ), cValTochar( nTipoProc ) ) } )

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

static function prcQuery( cAlias, cCompetenc, cEspCtr )

	procLogIni(,,,@cIdCV8)
	ProcLogAtu("INICIO",,,,.T.)

	BeginSql alias cAlias

		%NOPARSER%

		SELECT

    	CN9.CN9_NUMERO, CN9.CN9_REVISA, CN9.CN9_XCDPMD,
    	CNA.CNA_NUMERO, CNA.CNA_XPLHRE, 
    	CNB.CNB_ITEM, CNB.CNB_PRODUT, CNB.CNB_QUANT, CNB.CNB_VLUNIT, CNB.CNB_XHREXT, 
	
    	CASE CN9_ESPCTR
	
    		WHEN '1' THEN CNB.CNB_TE 
    		WHEN '2' THEN CNB.CNB_TS
    		ELSE ''
	
    	END CNE_TES,
	
    	SZC.ZC_TOTHRS 
	
    	FROM %TABLE:SZC% SZC
	
    	INNER JOIN %TABLE:SZA% SZA
    	ON  SZA.D_E_L_E_T_ = SZC.D_E_L_E_T_
    	AND SZA.ZA_FILIAL  = SZC.ZC_FILIAL
    	AND SZA.ZA_CODIGO  = SZC.ZC_TAREFA
	
    	INNER JOIN %TABLE:CN9% CN9
    	ON  SZA.D_E_L_E_T_ = SZC.D_E_L_E_T_
    	AND SZA.ZA_FILIAL  = CN9.CN9_FILIAL
    	AND ( 
    		CN9.CN9_ESPCTR  = '1' AND SZA.ZA_RECCTR  = CN9.CN9_NUMERO OR
    		CN9.CN9_ESPCTR  = '2' AND SZA.ZA_CLICTR  = CN9.CN9_NUMERO
    		)
    	AND ( 
    		CN9.CN9_ESPCTR  = '1' AND SZA.ZA_RECRVCT  = CN9.CN9_REVISA OR
    		CN9.CN9_ESPCTR  = '2' AND SZA.ZA_CLIRVCT  = CN9.CN9_REVISA
    		)
	
    	INNER JOIN %TABLE:CNA% CNA
    	ON  CN9.D_E_L_E_T_  = CNA.D_E_L_E_T_
    	AND CN9.CN9_FILIAL  = CNA.CNA_FILIAL
    	AND CN9.CN9_NUMERO  = CNA.CNA_CONTRA
    	AND CN9.CN9_REVISA  = CNA.CNA_REVISA
    	AND ( 
    		CN9.CN9_ESPCTR  = '1' AND SZA.ZA_RECPLAN  = CNA.CNA_NUMERO OR
    		CN9.CN9_ESPCTR  = '2' AND SZA.ZA_CLIPLAN  = CNA.CNA_NUMERO
    		)
	
    	INNER JOIN %TABLE:CNB% CNB
    	ON  CNA.D_E_L_E_T_  = CNB.D_E_L_E_T_
    	AND CNA.CNA_FILIAL  = CNB.CNB_FILIAL
    	AND CNA.CNA_CONTRA  = CNB.CNB_CONTRA
    	AND CNA.CNA_REVISA  = CNB.CNB_REVISA
    	AND CNA.CNA_NUMERO  = CNB.CNB_NUMERO
    	AND ( 
    		CN9.CN9_ESPCTR  = '1' AND SZA.ZA_RECITEM  = CNB.CNB_ITEM OR
    		CN9.CN9_ESPCTR  = '2' AND SZA.ZA_CLIITEM  = CNB.CNB_ITEM
    		)
		
    	WHERE SZC.%NOTDEL%
    	AND SZC.ZC_FILIAL = %XFILIAL:SZC%
    	AND SZC.ZC_COMPETE = %EXP:cCompetenc%
    	AND SZC.ZC_STATUS = '2'
    	AND ( 
    		CN9.CN9_ESPCTR  = '1' AND CN9.CN9_TPCTO = %EXP:GETMV('MX_TPCTCP')% OR
    		CN9.CN9_ESPCTR  = '2' AND CN9.CN9_TPCTO = %EXP:GETMV('MX_TPCTVD')%
    		)
    	AND CN9.CN9_SITUAC = '05'
    	AND ( 
    		CN9.CN9_ESPCTR  = '1' AND CNA.CNA_TIPPLA = %EXP:GETMV('MX_TPPLCP')% OR
    		CN9.CN9_ESPCTR  = '2' AND CNA.CNA_TIPPLA = %EXP:GETMV('MX_TPPLVD')%
    		)
    	AND CN9.CN9_ESPCTR = %EXP:cEspCtr%
    	AND CNA.CNA_XPLHRE <> %EXP:Space( TamSx3( 'CNA_XPLHRE' )[1] )%
    	AND CNA.CNA_XPLHRE <> CNA.CNA_NUMERO
    	AND ( 
    		CN9.CN9_ESPCTR  = '1' AND CNB.CNB_TE <> %EXP:Space( TamSx3( 'CNB_TE' )[1] )% OR
    		CN9.CN9_ESPCTR  = '2' AND CNB.CNB_TS <> %EXP:Space( TamSx3( 'CNB_TS' )[1] )%
    		)
    	AND SUBSTRING( CNA.CNA_PROMED, 5, 2 ) + LEFT( CNA.CNA_PROMED, 4 ) = %EXP:cCompetenc%

		ORDER BY CN9.CN9_FILIAL, CN9.CN9_NUMERO, CN9.CN9_REVISA, CNA.CNA_NUMERO, CNB.CNB_ITEM

	EndSql

return

static function mntListCtr( aListCtr, cAlias, cCompent )

	local nPos      := 0
	local nHrPlanej := ( cAlias )->( CNB_QUANT )
	local nHrTrabal := ( cAlias )->( ZC_TOTHRS )

	( cAlias )->( nPos := aScan( aListCtr, { | item |  item['CONTRATO'] == CN9_NUMERO } ) )

	if nPos == 0

		aAdd( aListCtr, jsonObject():new() )

		aTail( aListCtr )['CONTRATO']  := ( cAlias )->( CN9_NUMERO )
		aTail( aListCtr )['PLANILHAS'] := {}
		aTail( aListCtr )['COMPETENCIA'] := cCompent
		aTail( aListCtr )['COND_PAG_MED'] := ( cAlias )->( CN9_XCDPMD )


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
	aTail( aTail( aTail( aListCtr )['PLANILHAS'] )['ITENS'] )['VALOR_UNITARIO'] := ( cAlias )->( CNB_VLUNIT )
	aTail( aTail( aTail( aListCtr )['PLANILHAS'] )['ITENS'] )['VALOR_HREXTRA'] := ( cAlias )->( if( CNB_XHREXT > 0, CNB_XHREXT, CNB_VLUNIT ) )
	aTail( aTail( aTail( aListCtr )['PLANILHAS'] )['ITENS'] )['TES'] := ( cAlias )->( CNE_TES )

	if nHrPlanej >= nLimHrsMes

		if nHrPlanej >= nHrTrabal

			aTail( aTail( aTail( aListCtr )['PLANILHAS'] )['ITENS'] )["HR_MED_PLANEJADA"]        := nHrTrabal
			aTail( aTail( aTail( aListCtr )['PLANILHAS'] )['ITENS'] )["HR_MED_EXCED_VLR_NORMAL"] := 0
			aTail( aTail( aTail( aListCtr )['PLANILHAS'] )['ITENS'] )["HR_MED_EXCED_VLR_EXTRA"]  := 0

		else

			aTail( aTail( aTail( aListCtr )['PLANILHAS'] )['ITENS'] )["HR_MED_PLANEJADA"]        := nHrPlanej
			aTail( aTail( aTail( aListCtr )['PLANILHAS'] )['ITENS'] )["HR_MED_EXCED_VLR_NORMAL"] := 0
			aTail( aTail( aTail( aListCtr )['PLANILHAS'] )['ITENS'] )["HR_MED_EXCED_VLR_EXTRA"]  := nHrTrabal - nHrPlanej

		end if

	elseif nHrPlanej < nLimHrsMes

		if nHrPlanej >= nHrTrabal

			aTail( aTail( aTail( aListCtr )['PLANILHAS'] )['ITENS'] )["HR_MED_PLANEJADA"]        := nHrTrabal
			aTail( aTail( aTail( aListCtr )['PLANILHAS'] )['ITENS'] )["HR_MED_EXCED_VLR_NORMAL"] := 0
			aTail( aTail( aTail( aListCtr )['PLANILHAS'] )['ITENS'] )["HR_MED_EXCED_VLR_EXTRA"]  := 0

		else

			if nHrTrabal <= nLimHrsMes

				aTail( aTail( aTail( aListCtr )['PLANILHAS'] )['ITENS'] )["HR_MED_PLANEJADA"]        := nHrPlanej
				aTail( aTail( aTail( aListCtr )['PLANILHAS'] )['ITENS'] )["HR_MED_EXCED_VLR_NORMAL"] := nHrTrabal - nHrPlanej
				aTail( aTail( aTail( aListCtr )['PLANILHAS'] )['ITENS'] )["HR_MED_EXCED_VLR_EXTRA"]  := 0

			else

				aTail( aTail( aTail( aListCtr )['PLANILHAS'] )['ITENS'] )["HR_MED_PLANEJADA"]        := nHrPlanej
				aTail( aTail( aTail( aListCtr )['PLANILHAS'] )['ITENS'] )["HR_MED_EXCED_VLR_NORMAL"] := nLimHrsMes - nHrPlanej
				aTail( aTail( aTail( aListCtr )['PLANILHAS'] )['ITENS'] )["HR_MED_EXCED_VLR_EXTRA"]  := nHrTrabal - nLimHrsMes


			end if

		end if

	end if

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
	// Local nSldTotal  := 0

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
				oModel:SetValue("CNDMASTER","CND_CONDPG"    ,  jContrato['COND_PAG_MED'] )

				/*
				Tratando planilhas planejAdas
				*/
				for nX := 1 to Len( jContrato['PLANILHAS'] )

					if oModel:getModel('CXNDETAIL'):seekLine( { { 'CXN_NUMPLA', jContrato[ 'PLANILHAS' ][ nX ][ 'NUMERO' ] } } )

						oModel:SetValue("CXNDETAIL","CXN_CHECK", .T.)

						for nY := 1 to oModel:getModel('CNEDETAIL'):Length()

							oModel:GetModel('CNEDETAIL'):GoLine( nY )

							nPos := aScan( jContrato[ 'PLANILHAS' ][ nX ]['ITENS'],;
								{ | item | item["ITEM"] == oModel:getModel('CNEDETAIL'):GetValue( 'CNE_ITEM' ) } )

							if nPos > 0

								oModel:getModel('CNEDETAIL'):SetValue( 'CNE_QUANT',;
									jContrato[ 'PLANILHAS' ][ nX ]['ITENS'][ nPos ]['HR_MED_PLANEJADA']  )

							end if

						next nY

					end if

				next nX

				/* Planilha Excedente */				
				for nX := 1 to Len( jContrato['PLANILHAS'] )

					for nY := 1 to len( jContrato[ 'PLANILHAS' ][ nX ]['ITENS'] )

						/* Planilha excedente com valor normal */
						if jContrato[ 'PLANILHAS' ][ nX ]['ITENS'][nY]["HR_MED_EXCED_VLR_NORMAL"] > 0 .And.;
								oModel:getModel('CXNDETAIL'):seekLine( { { 'CXN_NUMPLA', jContrato[ 'PLANILHAS' ][ nX ][ 'PLAN_EXCED' ] } } )

							oModel:SetValue("CXNDETAIL","CXN_CHECK", .T.)

							if nY != 1

								oModel:GetModel('CNEDETAIL'):GoLine(;
									oModel:getModel('CNEDETAIL'):AddLine() )

							end if

							oModel:getModel('CNEDETAIL'):LoadValue('CNE_ITEM'  , PadL( cValToChar( nY ), CNE->( Len( CNE_ITEM ) ), '0' ) )
							oModel:getModel('CNEDETAIL'):setValue( 'CNE_PRODUT', jContrato[ 'PLANILHAS' ][ nX ]['ITENS'][ nY ][ 'PRODUTO' ] )
							oModel:getModel('CNEDETAIL'):setValue( 'CNE_QUANT ', jContrato[ 'PLANILHAS' ][ nX ]['ITENS'][ nY ][ 'HR_MED_EXCED_VLR_NORMAL' ] )
							oModel:getModel('CNEDETAIL'):setValue( 'CNE_VLUNIT', jContrato[ 'PLANILHAS' ][ nX ]['ITENS'][ nY ][ 'VALOR_UNITARIO' ] )
							oModel:getModel('CNEDETAIL'):setValue( 'CNE_TES'   , jContrato[ 'PLANILHAS' ][ nX ]['ITENS'][ nY ][ 'TES' ] )


						end if

						/* Planilha excedente com valor extra */
						if jContrato[ 'PLANILHAS' ][ nX ]['ITENS'][nY]["HR_MED_EXCED_VLR_EXTRA"] > 0 .And.;
								oModel:getModel('CXNDETAIL'):seekLine( { { 'CXN_NUMPLA', jContrato[ 'PLANILHAS' ][ nX ][ 'PLAN_EXCED' ] } } )

							oModel:SetValue("CXNDETAIL","CXN_CHECK", .T.)

							if nY != 1

								oModel:GetModel('CNEDETAIL'):GoLine(;
									oModel:getModel('CNEDETAIL'):AddLine() )

							end if

							oModel:getModel('CNEDETAIL'):LoadValue('CNE_ITEM'  , PadL( cValToChar( nY ), CNE->( Len( CNE_ITEM ) ), '0' ) )
							oModel:getModel('CNEDETAIL'):setValue( 'CNE_PRODUT', jContrato[ 'PLANILHAS' ][ nX ]['ITENS'][ nY ][ 'PRODUTO' ] )
							oModel:getModel('CNEDETAIL'):setValue( 'CNE_QUANT ', jContrato[ 'PLANILHAS' ][ nX ]['ITENS'][ nY ][ 'HR_MED_EXCED_VLR_EXTRA' ] )
							oModel:getModel('CNEDETAIL'):setValue( 'CNE_VLUNIT', jContrato[ 'PLANILHAS' ][ nX ]['ITENS'][ nY ][ 'VALOR_HREXTRA' ] )
							oModel:getModel('CNEDETAIL'):setValue( 'CNE_TES'   , jContrato[ 'PLANILHAS' ][ nX ]['ITENS'][ nY ][ 'TES' ] )

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
