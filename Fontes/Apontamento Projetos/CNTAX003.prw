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

static function frmCtCli()

	local cTitulo := 'Processamento de Clientes'
	local aTexto  := {}
	local aBotoes := {}

	aAdd( aTexto, 'Rotina de processamento dos apontamentos dos recursos nos clientes' )
	aAdd( aTexto, 'para geração das medições dos contratos de vendas.' )

	aAdd( aBotoes, { 15, .T., {|| procLogView(,'PRCCTCLI') } } ) // Visualizar
	aAdd( aBotoes, { 05, .T., {|| pergunte( 'CNTAX003B' )  } } ) // Parâmetros
	aAdd( aBotoes, { 02, .T., {|| fechaBatch()             } } ) // Cancelar
	aAdd( aBotoes, { 01, .T., {|| prcCtCli(),FechaBatch()  } } ) // Ok

	FormBatch( cTitulo, aTexto, aBotoes, /*bValid*/, /*nAltura>*/, /*nLargura*/)

return

static function prcCtCli()

	local cAlias     := ''
	local cCompent   := ''
	local cIdCV8     := ''

	if pergunte( 'CNTAX003B' )

		cAlias     := getNextAlias()
		cCompent   := SubStr( MV_PAR01, 1, 2 ) + '/' + SubStr( MV_PAR01, 3, 4 )
		dDataDe    := cToD( '01/' + cCompent )
		dDataAte   := LastDay( dDataDe )

		if Empty( dDataDe )

			ApMsgStop( 'Período informado inválido.', 'Atenção' )

		else

			If Select(cAlias) <> 0

				(cAlias)->(DbCloseArea())

			EndIf

			BeginSql alias cAlias
		
				%NOPARSER%

				SELECT @@VERSION
		
			EndSql

			procLogIni(,,,@cIdCV8)
			ProcLogAtu('INICIO',,,,.T.)

			if ( cAlias )->( Eof() )

				ProcLogAtu('MENSAGEM', 'Não há registros a serem processados.',,,.T.)

			else

				While ( cAlias )->( !Eof() )

					( cAlias )->(  msgRun( 'Contrato: ' + AllTrim( Z03_CONTRA ) +;
						' - Competência: ' + allTrim( cCompent ), 'Processando Contratos de Clientes ...',;
						{||incMedicao( Z03_CONTRA, Z03_QTDHRS, cCompent ) } ) )

					( cAlias )->( DbSkip() )

				EndDo

			end if

			ProcLogAtu('FIM',,,,.T.)
			procLogView(,,,@cIdCV8)

			(cAlias)->(DbCloseArea())

		end if

	end if

return

static function frmCtRec()

	local cTitulo := 'Processamento de Recursos'
	local aTexto  := {}
	local aBotoes := {}

	aAdd( aTexto, 'Rotina de processamento dos apontamentos dos recursos' )
	aAdd( aTexto, 'para geração das medições dos contratos de compras.' )

	aAdd( aBotoes, { 15, .T., {|| procLogView(,'PRCCTREC') } } ) // Visualizar
	aAdd( aBotoes, { 05, .T., {|| pergunte( 'CNTAX003B ' )  } } ) // Parâmetros
	aAdd( aBotoes, { 02, .T., {|| fechaBatch()             } } ) // Cancelar
	aAdd( aBotoes, { 01, .T., {|| prcCtRec(),FechaBatch()  } } ) // Ok

	FormBatch( cTitulo, aTexto, aBotoes, /*bValid*/, /*nAltura>*/, /*nLargura*/)

return

static function prcCtRec()

	local cAlias     := ''
	local cCompent   := ''
	local dDataDe    := CtoD('')
	local dDataAte   := CtoD('')
	local cIdCV8     := ''
	local aListCtr   := {}
	local nPos       := 0

	if pergunte( 'CNTAX003B' )

		cAlias     := getNextAlias()
		cCompent   := SubStr( MV_PAR01, 1, 2 ) + '/' + SubStr( MV_PAR01, 3, 4 )
		dDataDe    := cToD( '01/' + cCompent )
		dDataAte   := LastDay( dDataDe )

		if Empty( dDataDe )

			ApMsgStop( 'Período informado inválido.', 'Atenção' )

		else

			If Select(cAlias) <> 0

				(cAlias)->(DbCloseArea())

			EndIf

			BeginSql alias cAlias
		
				%NOPARSER%

					SELECT 

					CNA.CNA_XPLHRE,CNA_XRTAPR, SZA.ZA_RECCTR, 
					SZA.ZA_RECRVCT, SZA.ZA_RECPLAN, SZA.ZA_RECITEM 

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

			procLogIni(,,,@cIdCV8)
			ProcLogAtu('INICIO',,,,.T.)

			if ( cAlias )->( Eof() )

				ProcLogAtu('MENSAGEM', 'Não há registros a serem processados.',,,.T.)

			else

				While ( cAlias )->( !Eof() )

					( cAlias )->( nPos := aScan( aListCtr, { | item |  item['CONTRATO'] == ZA_RECCTR } ) )

					if nPos == 0

						aAdd( aListCtr, jsonObject():new() )

						aTail( aListCtr )['CONTRATO']  := ( cAlias )->( ZA_RECCTR )
						aTail( aListCtr )['PLANILHAS'] := {}
						aTail( aListCtr )['COMPETENCIA'] := cCompent

					end if

					( cAlias )->( nPos := aScan( aTail( aListCtr )['PLANILHAS'], { | item |  item['NUMERO'] == ZA_RECPLAN } ) )

					if nPos == 0

						aAdd( aTail( aListCtr )['PLANILHAS'], jsonObject():new() )

						aTail( aTail( aListCtr )['PLANILHAS'] )['NUMERO'] := ( cAlias )->( ZA_RECPLAN )
						aTail( aTail( aListCtr )['PLANILHAS'] )['PLAN_EXCED'] := ( cAlias )->( CNA_XPLHRE )
						aTail( aTail( aListCtr )['PLANILHAS'] )['ITENS'] := {}

						( cAlias )->( hrsCpItPln( ZA_RECCTR, ZA_RECRVCT, ZA_RECPLAN, dDataDe, CNA_XRTAPR,;
							aTail( aTail( aListCtr )['PLANILHAS'] )['ITENS'] ) )

					end if

					( cAlias )->( DbSkip() )

				EndDo

			end if

			for nPos := 1 to len( aListCtr )

				incMedicao( aListCtr[ nPos ] )

			next nX

			ProcLogAtu('FIM',,,,.T.)
			procLogView(,,,@cIdCV8)

			(cAlias)->(DbCloseArea())

		end if

	end if

return

static function hrsCpItPln( cContrato, cRevisao, cPlanilha, dCompt, nMesesRetr, aItens )

	local cAlias   := getNextAlias()
	local nX       := 0
	local dDataDe  := FirstDate( dCompt )
	local dDataAte := LastDay( dCompt )

	for nx := 1 to nMesesRetr

		dDataDe -= 1

		dDataDe  := FirstDate( dDataDe )
		dDataAte := LastDay( dDataDe )

	next nx

	BeginSql alias cAlias
		
		%NOPARSER%

		SELECT SZA.ZA_RECITEM,SUM(SZB.ZB_QTDHRS) ZB_QTDHRS FROM %TABLE:SZB% SZB

		INNER JOIN %TABLE:SZA% SZA
		ON SZA.D_E_L_E_T_  = SZB.D_E_L_E_T_
		AND SZA.ZA_FILIAL = SZB.ZB_FILIAL
		AND SZA.ZA_CODREC = SZB.ZB_RECURS
		AND SZA.ZA_CODIGO = SZB.ZB_TAREFA

		WHERE SZB.%NOTDEL%
		AND SZB.ZB_FILIAL = %XFILIAL:SZB%
		AND SZB.ZB_DTINIC BETWEEN %EXP:dTos( dDataDe )% AND %EXP:dTos( dDataAte )%
		AND SZA.ZA_RECCTR = %EXP:cContrato%
		AND SZA.ZA_RECRVCT = %EXP:cRevisao%
		AND SZA.ZA_RECPLAN = %EXP:cPlanilha%

		GROUP BY SZA.ZA_RECITEM

	EndSql

	(cAlias)->( DbGoTop() )

	while (cAlias)->( ! eof() )

		aAdd( aItens, jsonObject():new() )

		(cAlias)->( aTail( aItens )['ITEM'] := ZA_RECITEM )
		(cAlias)->( aTail( aItens )['QUANTIDADE'] := ZB_QTDHRS )

		(cAlias)->( DbSkip() )

	end

	(cAlias)->( DbCloseArea() )

return

static function incMedicao( jContrato ) // cContrato / nQtdHoras / cCompet

	Local oModel    := Nil
	Local aCompets  := {}
	Local nCompet   := 0
	Local cNumMed   := ""
	Local aMsgDeErro:= {}
	Local cMsgDeErro:= ''
	Local aArea     := GetArea()

	DbSelectArea('CN9')
	CN9->(DbSetOrder(1))

	If ! CN9->( DbSeek( xFilial( "CN9" ) + jContrato['CONTRATO'] ) )//Posicionar na CN9 para realizar a inclusão

		ProcLogAtu( 'ERRO', 'Contrato inválido.', 'O contrato ' + cContrato + ' não é válido para a Filial ' + cFilAnt,,.T.)

	else

		aCompets := CtrCompets()

		if Empty( nCompet := aScan( aCompets, { | cItem | allTrim( cItem ) == allTrim( jContrato['COMPETENCIA'] ) } ) )

			ProcLogAtu( 'ERRO', 'Competência inválida.',;
				'A competência ' + cCompet + ' não é válida para o contrato ' + cContrato,,.T.)

		else

			oModel := FWLoadModel("CNTA121")

			oModel:SetOperation(MODEL_OPERATION_INSERT)

			If oModel:CanActivate()

				oModel:Activate()
				oModel:SetValue("CNDMASTER","CND_CONTRA"    ,CN9->CN9_NUMERO)

				oModel:SetValue("CNDMASTER","CND_RCCOMP"    , cValToChar( nCompet ) )//Selecionar competência
//TODO TRATAR AQUI A VERIFICAÇÃO DA HORAS EXCEDENTES.
				oModel:SetValue("CXNDETAIL","CXN_CHECK", .T.)//Marcar a planilha(nesse caso apenas uma)
				oModel:GetModel('CNEDETAIL'):GoLine(1)
				oModel:SetValue( 'CNEDETAIL' , 'CNE_QUANT', nQtdHoras )

				
				
				If (oModel:VldData()) /*Valida o modelo como um todo*/

					oModel:CommitData()

				EndIf

			EndIf

			If( oModel:HasErrorMessage() )

				aMsgDeErro := oModel:GetErrorMessage()

				ascan( aMsgDeErro, { | cItem | cMsgDeErro += allTrim( cItem ) } )

				ProcLogAtu('ERRO', 'Erro no Processamento do contrato ' + cContrato, cMsgDeErro,,.T.)

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
