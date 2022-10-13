#Include "TOTVS.ch"
#Include "FWMVCDEF.ch"

Static lAdminApto

User Function CNTAX002()

	Local oBrowse  := FwLoadBrw("CNTAX002")

	Private cUserRec := ''

	lAdminApto := aScan( UsrRetGrp( __cUserID ), {|item| AllTrim( item ) == GetMv( 'MX_GRPADM' ) } ) != 0

	if lAdminApto .And. ConPad1(, , , 'SZZ')

		cUserRec := SZZ->ZZ_CODIGO

	else

		cUserRec := __cUserID

	end

	SZZ->( DbSetOrder( 1 ) )

	if lAdminApto .Or. SZZ->( DbSeek( xFilial('SZZ') + cUserRec ) )

		oBrowse:Activate()

	else

		ApMsgStop( 'O usuário ' + UsrRetName( cUserRec ) + ' deve estar cadastrado como um recurso.', 'Atenção !!!' )

	end if

Return

Static Function BrowseDef()

	Local oBrowse := FwMBrowse():New()

	oBrowse:SetAlias("SZB")
	oBrowse:SetDescription("Apontamentos")

	oBrowse:SetFilterDefault( "SZB->ZB_RECURS == cUserRec" )

	oBrowse:SetMenuDef("CNTAX002")

Return oBrowse


Static Function MenuDef()

Return FwMvcMenu( 'CNTAX002' )

Static Function ModelDef()

	Local oModel    := MPFormModel():New("CNTAM003",, { | oModel | TudoOk( oModel ) } )
	Local oStru     := FwFormStruct(1, "SZB")

	oStru:SetProperty( 'ZB_INTERVA', MODEL_FIELD_INIT, {||'0100'} )

	oModel:AddFields("MASTER", NIL, oStru )

	oModel:SetDescription("Recursos x Contratos")

	oModel:GetModel("MASTER"):SetDescription("Apontamentos")

Return oModel

Static Function ViewDef()

	Local oView := FwFormView():New()
	Local oStru := FwFormStruct(2, "SZB")
	Local oModel := FwLoadModel("CNTAX002")

	oView:SetModel(oModel)

	oView:AddField("VIEW", oStru, "MASTER")

	oView:CreateHorizontalBox("TELA" , 100)

	oView:SetOwnerView("VIEW", "TELA")

Return oView

static function TudoOk( oModel )

	Local cRecurso := FwFldGet( 'ZB_RECURS' )
	Local cTarefa  := FwFldGet( 'ZB_TAREFA' )
	Local dDtIni   := FwFldGet( 'ZB_DTINIC' )
	Local cDtIni   := DtoS( dDtIni )
	Local cHrIni   := FwFldGet( 'ZB_HRINIC' )
	Local cInterv  := FwFldGet( 'ZB_INTERVA' )
	Local dDtFim   := FwFldGet( 'ZB_DTFIM'  )
	Local cDtFim   := DtoS( dDtFim )
	Local cHrFim   := FwFldGet( 'ZB_HRFIM' )
	Local cAlias   := GetNextAlias()
	Local nCount   := 0
	Local dPerIni  := FirstDate( GetMv( 'MX_APTOMES' ) )
	Local dPerFim  := LastDate( dPerIni )
	Local nQtdHrs  := 0

	if ! cValToChar( oModel:nOperation ) $ '349'

		return .T.

	end if

	if  ! lAdminApto .And. ! ( dDtIni >= dPerIni .And. dDtFim <= dPerFim )

		Help(,, "CNTAX002",, 'Período bloqueado para apontamentos.', 1, 0,,,,,,;
			{'O período aberto para apontamentos é de ' + dToC( dPerIni ) + ' a ' + dToC( dPerFim ) + '.'})

		Return .F.

	end if

	if FirstDate( dDtIni ) != FirstDate( dDtFim )

		Help(,, "CNTAX002",, 'A data de início e a data final do apontamento devem estar dentro do mesmo mês/ano.', 1, 0,,,,,,;
			{'Informe um intervalo válido.'})

		Return .F.

	end if

	if cDtIni + cHrIni >= cDtFim + cHrFim

		Help(,, "CNTAX002",, 'A Data/Hora início deve ser anterior a Data/Hora final do Apontamento.', 1, 0,,,,,,;
			{'Informe um intervalo válido.'})

		Return .F.

	end if

	If Select(cAlias) <> 0

		( cAlias )->( DbCloseArea() )

	EndIf

	BeginSql alias cAlias
	
		%NOPARSER%

		SELECT COUNT(*) COUNT FROM %TABLE:SZB% SZB

		WHERE SZB.%NOTDEL%
		AND SZB.ZB_FILIAL = %XFILIAL:SZB%
		AND SZB.ZB_RECURS = %EXP:cRecurso%
		AND SZB.ZB_TAREFA = %EXP:cTarefa%
		AND
			(
				%EXP:cDtIni + cHrIni% BETWEEN SZB.ZB_DTINIC + SZB.ZB_HRINIC AND SZB.ZB_DTFIM + SZB.ZB_HRFIM OR
				%EXP:cDtFim + cHrFim% BETWEEN SZB.ZB_DTINIC + SZB.ZB_HRINIC AND SZB.ZB_DTFIM + SZB.ZB_HRFIM 
			)
		*// Em caso de alteração desconsidera o registro posicionado na consulta
		AND ( 
				SZB.R_E_C_N_O_ <>  
				
				CASE WHEN %EXP:oModel:nOperation% = 4 THEN

					%EXP: SZB->( Recno() )%

				ELSE

					0

				END			
			)

	EndSql

	nCount := (cAlias)->COUNT

	(cAlias)->(DbCloseArea())

	if nCount > 0

		Help(,, "CNTAX002",, 'Já existe apontamento neste intervalo de data/hora.', 1, 0,,,,,, {'Informe um intervalo válido.'})

		Return .F.

	end if

	nQtdHrs := elapInt( dDtIni, cHrIni, cInterv, dDtFim, cHrFim )

	FwFldPut( 'ZB_QTDHRS', nQtdHrs,,,, .T. )

	if nQtdHrs < 0

		Help(,, "CNTAX002",, 'Não é permitido um total de horas negativas.', 1, 0,,,,,, {'Verifique o tempo de intervalo.'})

		Return .F.

	end if

return .T.

static function elapInt( dDtIni, cHrIni, cInterv, dDtFim, cHrFim )

	Local nRet     := 0
	Local nHoraIni := val( cHrIni ) / 100
	Local nInterv  := val( cInterv  ) / 100
	Local nHoraFim := val( cHrFim ) / 100
	Local nHora    := 0

	nHora := DataHora2Val( dDtIni, nHoraIni, dDtFim, nHoraFim, 'H' )

	nRet := round( int( nHora ) + ( ( nHora - int( nHora ) ) / 0.6 ), 2 )
	nRet -= round( int( nInterv ) + ( ( nInterv - int( nInterv ) ) / 0.6 ), 2 )

return nRet

user function vldFrmHr( cTime )

	local lRet    := .T.
	local cHora   := subStr( cTime, 1, 2 )
	local cMinuto := subStr( cTime, 3, 2 )

	lRet := lRet .And. ! Empty( cHora )
	lRet := lRet .And. ! Empty( cMinuto )
	lRet := lRet .And. val( cHora   ) >= 00
	lRet := lRet .And. val( cHora   ) <= 23
	lRet := lRet .And. val( cMinuto ) >= 00
	lRet := lRet .And. val( cMinuto ) <= 59

return lRet


