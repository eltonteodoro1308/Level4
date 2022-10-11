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

			if pergunte('CNTAX004A')

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
	aAdd( aBotoes, { 05, .T., {|| pergunte( 'CNTAX004B' )  } } ) // Parâmetros
	aAdd( aBotoes, { 02, .T., {|| fechaBatch()             } } ) // Cancelar
	aAdd( aBotoes, { 01, .T., {|| prcCtCli(),FechaBatch()  } } ) // Ok

	FormBatch( cTitulo, aTexto, aBotoes, /*bValid*/, /*nAltura>*/, /*nLargura*/)

return

static function prcCtCli()

	local cAlias     := ''
	local cClientDe  := ''
	local cLojaDe    := ''
	local cClientAte := ''
	local cLojaAte   := ''
	local cContrDe   := ''
	local cContrAte  := ''
	local dDataDe    := CtoD('')
	local dDataAte   := CtoD('')
	local cIdCV8     := ''

	if pergunte( 'CNTAX004B' )

		cAlias     := getNextAlias()
		cClientDe  := MV_PAR01
		cLojaDe    := MV_PAR02
		cClientAte := MV_PAR03
		cLojaAte   := MV_PAR04
		cContrDe   := MV_PAR05
		cContrAte  := MV_PAR06
		cCompent   := SubStr( MV_PAR07, 1, 2 ) + '/' + SubStr( MV_PAR07, 3, 4 )
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

				SELECT Z03.Z03_CONTRA, SUM( Z03.Z03_QTDHRS ) Z03_QTDHRS FROM %TABLE:Z03% Z03

				INNER JOIN %TABLE:CN9% CN9
				ON  Z03.Z03_FILIAL = CN9.CN9_FILIAL
				AND Z03.D_E_L_E_T_ = CN9.D_E_L_E_T_
				AND Z03.Z03_CONTRA = CN9.CN9_NUMERO

				INNER JOIN %TABLE:CN1% CN1
				ON CN9.CN9_FILIAL = CN1.CN1_FILIAL
				AND CN9.CN9_TPCTO = CN1.CN1_CODIGO
				AND CN9.D_E_L_E_T_ = CN1.D_E_L_E_T_

				WHERE Z03.%NOTDEL%
				AND Z03.Z03_FILIAL = %XFILIAL:Z03%
				AND Z03.Z03_DTINIC BETWEEN %EXP:DtoS( dDataDe  )% AND %EXP:DtoS( dDataAte )%
				AND Z03.Z03_DTFIM  BETWEEN %EXP:DtoS( dDataDe  )% AND %EXP:DtoS( dDataAte )%
				AND CN9.CN9_SITUAC = '05'
				AND CN9.CN9_NUMERO BETWEEN %EXP:cContrDe% AND %EXP:cContrAte%
				AND CN1.CN1_ESPCTR = '2'
				*//Verifica se o contrato tem apenas um cliente vinculado
				AND ( 
					SELECT COUNT(*) FROM %TABLE:CNC% CNC 
					WHERE CNC.%NOTDEL% 
					AND CNC.CNC_FILIAL = %XFILIAL:CNC% 
					AND CNC.CNC_NUMERO = CN9.CN9_NUMERO 
					) = 1
				*//Verifica se o cliente vinculado é o cliente informado nos parâmetros
				AND ( 
					SELECT COUNT(*) FROM %TABLE:CNC% CNC 
					WHERE CNC.%NOTDEL% 
					AND CNC.CNC_FILIAL = %XFILIAL:CNC% 
					AND CNC.CNC_NUMERO = CN9.CN9_NUMERO 
					AND CNC.CNC_CLIENT BETWEEN %EXP:cClientDe% AND %EXP:cClientAte% 
					AND CNC.CNC_CLIENT BETWEEN %EXP:cLojaDe% AND %EXP:cLojaAte% 
					) <> 0

				GROUP BY Z03.Z03_CONTRA
		
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
	aAdd( aBotoes, { 05, .T., {|| pergunte( 'CNTAX004C' )  } } ) // Parâmetros
	aAdd( aBotoes, { 02, .T., {|| fechaBatch()             } } ) // Cancelar
	aAdd( aBotoes, { 01, .T., {|| prcCtRec(),FechaBatch()  } } ) // Ok

	FormBatch( cTitulo, aTexto, aBotoes, /*bValid*/, /*nAltura>*/, /*nLargura*/)

return

static function prcCtRec()

	local cAlias     := ''
	local cRecursDe  := ''
	local cRecursAte := ''
	local dDataDe    := CtoD('')
	local dDataAte   := CtoD('')
	local cIdCV8     := ''

	if pergunte( 'CNTAX004C' )

		cAlias     := getNextAlias()
		cRecursDe  := MV_PAR01
		cRecursAte := MV_PAR02
		cCompent   := SubStr( MV_PAR03, 1, 2 ) + '/' + SubStr( MV_PAR03, 3, 4 )
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

				SELECT CN9.CN9_NUMERO, SUM( Z03.Z03_QTDHRS ) Z03_QTDHRS FROM %TABLE:Z03% Z03

				INNER JOIN %TABLE:Z00% Z00
				ON  Z03.Z03_FILIAL = Z00.Z00_FILIAL
				AND Z03.D_E_L_E_T_ = Z00.D_E_L_E_T_
				AND Z03.Z03_RECURS = Z00.Z00_CODIGO

				INNER JOIN %TABLE:CN9% CN9
				ON  Z00.Z00_FILIAL = CN9.CN9_FILIAL
				AND Z00.D_E_L_E_T_ = CN9.D_E_L_E_T_
				AND Z00.Z00_CONTRA = CN9.CN9_NUMERO

				INNER JOIN %TABLE:CN1% CN1
				ON CN9.CN9_FILIAL = CN1.CN1_FILIAL
				AND CN9.CN9_TPCTO = CN1.CN1_CODIGO
				AND CN9.D_E_L_E_T_ = CN1.D_E_L_E_T_

				WHERE Z03.%NOTDEL%
				AND Z03.Z03_FILIAL = %XFILIAL:Z03%
				AND Z03.Z03_DTINIC BETWEEN %EXP:DtoS( dDataDe  )% AND %EXP:DtoS( dDataAte )%
				AND Z03.Z03_DTFIM  BETWEEN %EXP:DtoS( dDataDe  )% AND %EXP:DtoS( dDataAte )%
				AND CN9.CN9_SITUAC = '05'
				AND Z03.Z03_RECURS BETWEEN %EXP:cRecursDe% AND %EXP:cRecursAte%
				AND CN1.CN1_ESPCTR = '1'

				*//Verifica se o contrato tem apenas um fornecedor vinculado
				AND ( 
					SELECT COUNT(*) FROM %TABLE:CNC% CNC 
					WHERE CNC.%NOTDEL% 
					AND CNC.CNC_FILIAL = %XFILIAL:CNC% 
					AND CNC.CNC_NUMERO = CN9.CN9_NUMERO 
					) = 1

				GROUP BY CN9.CN9_NUMERO
		
			EndSql

			procLogIni(,,,@cIdCV8)
			ProcLogAtu('INICIO',,,,.T.)

			if ( cAlias )->( Eof() )

				ProcLogAtu('MENSAGEM', 'Não há registros a serem processados.',,,.T.)

			else

				While ( cAlias )->( !Eof() )

					( cAlias )->(  msgRun( 'Contrato: ' + AllTrim( CN9_NUMERO ) +;
						' - Competência: ' + allTrim( cCompent ), 'Processando Contratos de Recursos ...',;
						{||incMedicao( CN9_NUMERO, Z03_QTDHRS, cCompent ) } ) )

					( cAlias )->( DbSkip() )

				EndDo

			end if

			ProcLogAtu('FIM',,,,.T.)
			procLogView(,,,@cIdCV8)

			(cAlias)->(DbCloseArea())

		end if

	end if

return

static function incMedicao( cContrato, nQtdHoras, cCompet )


	Local oModel    := Nil
	Local aCompets  := {}
	Local nCompet   := 0
	Local cNumMed   := ""
	Local aMsgDeErro:= {}
	Local cMsgDeErro:= ''
	Local aArea     := GetArea()

	DbSelectArea('CN9')
	CN9->(DbSetOrder(1))

	If ! CN9->( DbSeek( xFilial( "CN9" ) + cContrato ) )//Posicionar na CN9 para realizar a inclusão

		ProcLogAtu( 'ERRO', 'Contrato inválido.', 'O contrato ' + cContrato + ' não é válido para a Filial ' + cFilAnt,,.T.)

	else

		aCompets := CtrCompets()

		if Empty( nCompet := aScan( aCompets, { | cItem | allTrim( cItem ) == allTrim( cCompet ) } ) )

			ProcLogAtu( 'ERRO', 'Competência inválida.',;
				'A competência ' + cCompet + ' não é válida para o contrato ' + cContrato,,.T.)

		else

			oModel := FWLoadModel("CNTA121")

			oModel:SetOperation(MODEL_OPERATION_INSERT)

			If oModel:CanActivate()

				oModel:Activate()
				oModel:SetValue("CNDMASTER","CND_CONTRA"    ,CN9->CN9_NUMERO)


				oModel:SetValue("CNDMASTER","CND_RCCOMP"    , cValToChar( nCompet ) )//Selecionar competência

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
