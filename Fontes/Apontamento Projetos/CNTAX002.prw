#Include "TOTVS.ch"
#Include "FWMVCDEF.ch"

Static lAdminApto := aScan( UsrRetGrp( __cUserID ), {|item| AllTrim( item ) == GetMv( 'MX_GRPADM' ) } ) != 0

User Function CNTAX002()

	Local oBrowse  := FwLoadBrw("CNTAX002")

	Private cUserRec := ''

	if lAdminApto

		if Pergunte( 'CNTAX002' )

			cUserRec := MV_PAR01

		end if

	else

		cUserRec := __cUserID

	end

	Z00->( DbSetOrder( 1 ) )

	if Z00->( DbSeek( xFilial('Z00') + cUserRec ) )

		oBrowse:Activate()

	else

		ApMsgStop( 'O usuário ' + UsrRetName( cUserRec ) + ' deve estar cadastrado como um recurso.', 'Atenção !!!' )

	end if

Return

Static Function BrowseDef()

	Local oBrowse := FwMBrowse():New()

	oBrowse:SetAlias("Z03")
	oBrowse:SetDescription("Apontamentos")

	oBrowse:SetFilterDefault( "Z03->Z03_RECURS == cUserRec" )

	oBrowse:SetMenuDef("CNTAX002")

Return oBrowse


Static Function MenuDef()

Return FwMvcMenu( 'CNTAX002' )

Static Function ModelDef()

	Local oModel    := MPFormModel():New("CNTAM003",, { | oModel | TudoOk( oModel ) } )
	Local oStru     := FwFormStruct(1, "Z03")


	oModel:AddFields("MASTER", NIL, oStru )

	oModel:SetDescription("Recursos x Contratos")

	oModel:GetModel("MASTER"):SetDescription("Apontamentos")

Return oModel

Static Function ViewDef()

	Local oView := FwFormView():New()
	Local oStru := FwFormStruct(2, "Z03")
	Local oModel := FwLoadModel("CNTAX002")

	oView:SetModel(oModel)

	oView:AddField("VIEW", oStru, "MASTER")

	oView:CreateHorizontalBox("TELA" , 100)

	oView:SetOwnerView("VIEW", "TELA")

Return oView

static function TudoOk( oModel )

	Local cRecurso  := FwFldGet( 'Z03_RECURS' )
	Local cContrato := FwFldGet( 'Z03_CONTRA' )
	Local dDtIni    := FwFldGet( 'Z03_DTINIC' )
	Local cDtIni    := DtoS( dDtIni )
	Local cHrIni    := FwFldGet( 'Z03_HRINIC' )
	Local dDtFim    := FwFldGet( 'Z03_DTFIM'  )
	Local cDtFim    := DtoS( dDtFim )
	Local cHrFim    := FwFldGet( 'Z03_HRFIM' )
	Local cAlias    := GetNextAlias()
	Local nCount    := 0
	Local dPerIni   := FirstDate( GetMv( 'MX_APTOMES' ) )
	Local dPerFim   := LastDate( dPerIni )

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

		SELECT COUNT(*) COUNT FROM %TABLE:Z03% Z03

		WHERE Z03.%NOTDEL%
		AND Z03.Z03_FILIAL = %XFILIAL:Z03%
		AND Z03.Z03_RECURS = %EXP:cRecurso%
		AND Z03.Z03_CONTRA = %EXP:cContrato%
		AND
			(
				%EXP:cDtIni + cHrIni% BETWEEN Z03.Z03_DTINIC + Z03.Z03_HRINIC AND Z03.Z03_DTFIM + Z03.Z03_HRFIM OR
				%EXP:cDtFim + cHrFim% BETWEEN Z03.Z03_DTINIC + Z03.Z03_HRINIC AND Z03.Z03_DTFIM + Z03.Z03_HRFIM 
			)
		*// Em caso de alteração desconsidera o registro posicionado na consulta
		AND ( 
				Z03.R_E_C_N_O_ <>  
				
				CASE WHEN %EXP:oModel:nOperation% = 4 THEN

					%EXP: Z03->( Recno() )%

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

	FwFldPut( 'Z03_QTDHRS', elapInt( dDtIni, cHrIni, dDtFim, cHrFim ),,,, .T. )

return .T.

static function elapInt( dDataIni, cHoraIni, dDataFim, cHoraFim )

	Local nRet     := 0
	Local nHoraIni := val( cHoraIni ) / 100
	Local nHoraFim := val( cHoraFim ) / 100
	Local nHora    := 0

	nHora := DataHora2Val( dDataIni, nHoraIni, dDataFim, nHoraFim, 'H' )

	nRet := round( int( nHora ) + ( ( nHora - int( nHora ) ) / 0.6 ), 2 )

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


