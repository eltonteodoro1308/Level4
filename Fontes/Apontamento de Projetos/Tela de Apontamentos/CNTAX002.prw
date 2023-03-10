#Include "TOTVS.ch"
#Include "FWMVCDEF.ch"

User Function CNTAX002()

	Local cAlias   := 'SZC'
	Local aArea    := getArea()

	Private oBrowse  := FWMarkBrowse():New()
	Private lManutenc  := .F.
	Private lAprovac   := .F.
	Private aMarkRecno := {}

	if lManutenc := FwIsInCallStack( 'U_CNTAX102' )

		if ! SZZ->( DbSeek( FwXFilial() + __CUSERID ) )

			ApMsgStop( 'Acesso restrito a usuário cadastrado como recurso.', 'Atenção !!!' )

			return

		end if

		oBrowse:SetFilterDefault( "SZC->ZC_RECURS == __CUSERID" )

	elseif lAprovac := FwIsInCallStack( 'U_CNTAX202' )

		do while .T.

			if pergunte( 'CNTAX002' )

				if Empty( stod( substr(MV_PAR01, 3, 4) + substr(MV_PAR01, 1, 2) + '01') )

					apMsgStop( 'Informe uma competência no formato mm/aaaa válida.', 'Atenção !!!' )

					loop

				else

					exit

				end if

			else

				return

			end if

		end do

		oBrowse:SetFieldMark( 'ZC_OK' )
		oBrowse:SetAllMark( {|| .T. } )
		oBrowse:setValid( { || SZC->ZC_STATUS $ '123' } )
		oBrowse:SetFilterDefault( "SZC->ZC_COMPETE == MV_PAR01" )

	else

		return

	end if

	restArea( aArea )

	oBrowse:SetAlias( cAlias )
	oBrowse:SetDescription("Lote de Apontamentos")

	oBrowse:AddLegend( "SZC->ZC_STATUS == '0'", "BLUE " , "Em Apontamento" )
	oBrowse:AddLegend( "SZC->ZC_STATUS == '1'", "YELLOW", "Em Aprovação"   )
	oBrowse:AddLegend( "SZC->ZC_STATUS == '2'", "GREEN ", "Aprovado"       )
	oBrowse:AddLegend( "SZC->ZC_STATUS == '3'", "RED"   , "Não Aprovado"   )

	oBrowse:SetMenuDef("CNTAX002")

	oBrowse:Activate()

Return

Static Function MenuDef()

	Local aAux    := FwMvcMenu( 'CNTAX002' )
	Local aRotina := {}

	if lManutenc

		aRotina := aAux

		aRotina[3][2] := 'u_altLtApt'
		aRotina[4][2] := 'u_excLtApt'
		aAdd( aRotina, { 'Enviar p/ Aprovação', 'u_envAprov', 0, 8, 0,,, } )

	elseIf lAprovac

		aAdd( aRotina, { 'Aprovar' , 'u_Aprova' , 0, 8, 0,,, } )
		aAdd( aRotina, { 'Reprovar', 'u_Reprova', 0, 8, 0,,, } )
		aAdd( aRotina, aAux[1] )
		aAdd( aRotina, aAux[5] )

	endIf

Return aRotina

Static Function ModelDef()

	Local oModel     := MPFormModel():New("CNTAM002",,;
		{ | oModel | posTudoOk( oModel ) })
	Local oStruSZC   := FwFormStruct(1, "SZC")
	Local oStruSZB   := FwFormStruct(1, "SZB")
	Local aRelation  := {}
	Local aAux       := {}
	Local cCodeBlock := ''

	oStruSZC:SetProperty( 'ZC_TAREFA', MODEL_FIELD_VALID,;
		{ | oModel | vldTarComp( oModel ) } )
	oStruSZC:SetProperty( 'ZC_TAREFA', MODEL_FIELD_WHEN , { || INCLUI } )

	oStruSZC:SetProperty( 'ZC_COMPETE', MODEL_FIELD_INIT , { || getCompet() } )
	oStruSZC:SetProperty( 'ZC_COMPETE', MODEL_FIELD_WHEN , { || .F. } )

	aAux := aClone( FwStruTrigger( 'ZC_TAREFA' , 'ZC_DESCTAR', ;
		'POSICIONE( "SZA", 1, fWxfILIAL("SZA") + FwFldGet("ZC_TAREFA"), "ZA_DESCRIC" )',,,,,, '01' ) )
	oStruSZC:addTrigger( aAux[ 1 ], aAux[ 2 ], aAux[ 3 ], aAux[ 4 ] )

	cCodeBlock += 'a := FwFldGet( "ZB_DATA"  ),'
	cCodeBlock += 'b := FwFldGet( "ZB_HRINIC"  ),'
	cCodeBlock += 'c := FwFldGet( "ZB_INTERVA" ),'
	cCodeBlock += 'd := FwFldGet( "ZB_DATA"   ),'
	cCodeBlock += 'e := FwFldGet( "ZB_HRFIM"   ),'
	cCodeBlock += 'u_elapInt( a, b, c, d, e ) '

	aAux := aClone( FwStruTrigger( 'ZB_DATA' , 'ZB_QTDHRS', cCodeBlock, .F., '', 0, '', nil,  '02' ) )
	oStruSZB:addTrigger( aAux[ 1 ], aAux[ 2 ], aAux[ 3 ], aAux[ 4 ] )

	aAux := aClone( FwStruTrigger( 'ZB_HRINIC' , 'ZB_QTDHRS', cCodeBlock, .F., '', 0, '', nil,  '01' ) )
	oStruSZB:addTrigger( aAux[ 1 ], aAux[ 2 ], aAux[ 3 ], aAux[ 4 ] )

	aAux := aClone( FwStruTrigger( 'ZB_INTERVA', 'ZB_QTDHRS', cCodeBlock, .F., '', 0, '', nil,  '01' ) )
	oStruSZB:addTrigger( aAux[ 1 ], aAux[ 2 ], aAux[ 3 ], aAux[ 4 ] )

	aAux := aClone( FwStruTrigger( 'ZB_HRFIM'  , 'ZB_QTDHRS', cCodeBlock, .F., '', 0, '', nil,  '01' ) )
	oStruSZB:addTrigger( aAux[ 1 ], aAux[ 2 ], aAux[ 3 ], aAux[ 4 ] )

	oStruSZB:SetProperty( 'ZB_DATA'   , MODEL_FIELD_VALID, { | oModel | vldData( oModel ) })

	oStruSZB:SetProperty( 'ZB_HRINIC' , MODEL_FIELD_VALID, { | oModel | ;
		Empty( oModel:getValue('ZB_HRINIC') ) .Or. Empty( oModel:getValue('ZB_HRFIM') ) .Or.;
		oModel:getValue('ZB_HRINIC') < oModel:getValue('ZB_HRFIM') } )

	oStruSZB:SetProperty( 'ZB_HRFIM'  , MODEL_FIELD_VALID, { | oModel | ;
		Empty( oModel:getValue('ZB_HRINIC') ) .Or. Empty( oModel:getValue('ZB_HRFIM') ) .Or.;
		oModel:getValue('ZB_HRINIC') < oModel:getValue('ZB_HRFIM') } )

	oStruSZB:SetProperty( 'ZB_INTERVA', MODEL_FIELD_INIT , {||'0100'} )

	oModel:AddFields( 'SZCMASTER',, oStruSZC )
	oModel:AddGrid(   'SZBDETAIL', 'SZCMASTER', oStruSZB )

	aAdd( aRelation, { 'ZB_FILIAL' , 'FwxFilial("SZB")'  } )
	aAdd( aRelation, { 'ZB_RECURS' , 'ZC_RECURS'         } )
	aAdd( aRelation, { 'ZB_TAREFA' , 'ZC_TAREFA'         } )
	aAdd( aRelation, { 'ZB_COMPETE', 'ZC_COMPETE'        } )

	oModel:SetRelation( 'SZBDETAIL', aRelation, SZB->( IndexKey(1) ) )
	oModel:GetModel( 'SZBDETAIL' ):SetUniqueLine( { 'ZB_DATA' } )

	oModel:SetDescription( "Lote de Apontamento" )
	oModel:GetModel('SZCMASTER'):SetDescription( 'Modelo Lote de Apontamentos' )
	oModel:GetModel('SZBDETAIL'):SetDescription( 'Modelo Apontamentos'         )

Return oModel

static function getCompet()

	local dDate      := date()
	local dDateAnter := firstDate( dDate ) - 1
	local aCompet    := {}
	local oDlg       := nil
	local cRet       := ''
	local nRadio     := 2

	aAdd( aCompet,  Month2Str( dDateAnter ) + '/' + Year2Str( dDateAnter )  )
	aAdd( aCompet,  Month2Str( dDate ) + '/' + Year2Str( dDate )  )

	if day( dDate ) <= GetMv( 'MX_TOLDIAS' )

		DEFINE DIALOG oDlg TITLE 'Selecione a Competência' FROM 000, 000 TO 100, 200 PIXEL

		@ 005, 004 RADIO oRadMenu VAR nRadio ITEMS aCompet[ 1 ],aCompet[ 2 ] SIZE 040, 020 OF oDlg PIXEL
		@ 030, 005 BUTTON oButton PROMPT "Ok" SIZE 037, 012 OF oDlg ACTION {|| oDlg:end() } PIXEL

		//oRadMenu:setCss("QRadioButton {font-size: 20px}")
		//oButton:setCss("QPushButton {font-size: 20px}")

		ACTIVATE DIALOG oDlg CENTERED

		cRet := strTran( aCompet[ nRadio ], '/', '' )

	else

		cRet := strTran( aCompet[ 2 ], '/', '' )

	end if

return cRet

static function vldTarComp( oModel )

	Local lRet        := .T.
	Local cTarefa     := oModel:getValue( 'ZC_TAREFA' )
	Local dInicioTar  := Posicione( "SZA", 1, fWxfILIAL("SZA") + cTarefa, "ZA_INICIO" )
	Local dFinalTar   := Posicione( "SZA", 1, fWxfILIAL("SZA") + cTarefa, "ZA_FINAL" )
	local cMesApto    := oModel:getValue( 'ZC_COMPETE' )

	lRet := existChav( 'SZC', ;
		oModel:getValue( 'ZC_RECURS' ) + oModel:getValue( 'ZC_TAREFA' ) + oModel:getValue( 'ZC_COMPETE' ) )

	if lRet .And. ! Empty( cTarefa )

		lRet := Month2Str( dInicioTar ) + Year2Str( dInicioTar ) <= cMesApto .AND. lRet
		lRet := Month2Str( dFinalTar ) + Year2Str( dFinalTar )  >= cMesApto .AND. lRet

	end if

return lRet

static function vldData( oModel )

	local oModelFld := eval( {|| o := fwModelActive(), o:getModel( 'SZCMASTER' ) } )

	local lRet := oModelFld:getValue( 'ZC_COMPETE' ) == ;
		Month2Str( oModel:getValue( 'ZB_DATA' ) ) + Year2Str( oModel:getValue( 'ZB_DATA' ) )

return lRet

user function sxbSza()

	local lRet      := .T.
	local oModelFld := eval( {|| o := fwModelActive(), o:getModel( 'SZCMASTER' ) } )
	local cMesApto  := oModelFld:getValue( 'ZC_COMPETE' )

	lRet := SZA->ZA_CODREC==__CUSERID .AND. lRet
	lRet := SZA->( Month2Str( ZA_INICIO ) + Year2Str( ZA_INICIO ) ) <= cMesApto .AND. lRet
	lRet := SZA->( Month2Str( ZA_FINAL ) + Year2Str( ZA_FINAL ) ) >= cMesApto .AND. lRet

return lRet

Static Function ViewDef()

	Local oView    := FwFormView():New()
	Local oStruSZC := FwFormStruct(2, "SZC")
	Local oStruSZB := FwFormStruct(2, "SZB")
	Local oModel   := FwLoadModel("CNTAX002")

	oView:SetModel(oModel)

	oView:AddField('VIEW_SZC', oStruSZC, 'SZCMASTER')
	oView:AddGrid( 'VIEW_SZB', oStruSZB, 'SZBDETAIL')

	oView:CreateHorizontalBox('CABEC',30)
	oView:CreateHorizontalBox('GRID',70)

	oView:SetOwnerView('VIEW_SZC','CABEC')
	oView:SetOwnerView('VIEW_SZB','GRID')

Return oView

static function posTudoOk( oModel )

	Local oModelField := oModel:getModel( 'SZCMASTER' )
	Local oModelGrid  := oModel:getModel( 'SZBDETAIL' )
	Local nQtdLine    := 0
	Local nX          := 0
	Local nTotal      := 0
	Local lRet        := .T.

	if cValTochar( oModel:nOperation ) $ '34'

		nQtdLine := oModelGrid:getQtdLine()

		for nX := 1 to nQtdLine

			if lRet := ! oModelGrid:isDeleted( nX ) .And.;
					oModelGrid:getValue( 'ZB_QTDHRS' ) > 0

				oModelGrid:GoLine( nX )

				nTotal += oModelGrid:getValue( 'ZB_QTDHRS' )

			else

				Help(,, "posTudoOk",, ;
					"Não é permitido apontamentos com total de horas zeradas ou negativas.", 1, 0,,,,,,;
					{"Verifique os apontontamentos deste lote."})

				exit

			end if

		next nX

		oModelField:setValue( 'ZC_TOTHRS', nTotal )

	end if

return lRet

user function elapInt( dDtIni, cHrIni, cInterv, dDtFim, cHrFim )

	Local nRet     := 0
	Local nHoraIni := val( cHrIni ) / 100
	Local nInterv  := val( cInterv  ) / 100
	Local nHoraFim := val( cHrFim ) / 100
	Local nHora    := 0

	if !( Empty( dDtIni ) .Or. Empty( cHrIni ) .Or.;
			Empty( cInterv ) .Or. Empty( dDtFim ) .Or. Empty( cHrFim ) )

		nHora := DataHora2Val( dDtIni, nHoraIni, dDtFim, nHoraFim, 'H' )

		nRet := round( int( nHora ) + ( ( nHora - int( nHora ) ) / 0.6 ), 2 )
		nRet -= round( int( nInterv ) + ( ( nInterv - int( nInterv ) ) / 0.6 ), 2 )

	end if

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

user function envAprov()

	if SZC->ZC_STATUS $ '03'

		setStatus( '1' )

	else

		ApMsgStop( 'Não é possível enviar para aprovação.', 'Atenção !!!' )

	endIf

return

user function aprova()

	AprvOrRepr( '2' )

return

user function reprova()

	AprvOrRepr( '3' )

return

static function AprvOrRepr( cStatus )

	Local aAreaSZC := SZC->( getArea() )

	SZC->( DbGoTop() )

	do while SZC->( ! eof() )

		if oBrowse:isMark( oBrowse:Mark() )

			setStatus( cStatus )

		end if

		SZC->( DbSkip() )

	end do

	SZC->( restArea( aAreaSZC ) )

return

static function setStatus( cStatus )

	RecLock( 'SZC', .F. )
	SZC->ZC_STATUS := cStatus
	SZC->ZC_OK := ''
	SZC->( MsUnlock() )

return

user function altLtApt()

	if SZC->ZC_STATUS $ '12'

		apMsgStop( 'Não é permitido altear Lote em Aprovação/Aprovado.', 'Atenção !!!' )

	else

		FWExecView(,'CNTAX002',MODEL_OPERATION_UPDATE)

	end if

return

user function excLtApt()

	if SZC->ZC_STATUS $ '12'

		apMsgStop( 'Não é permitido excluir Lote em Aprovação/Aprovado.', 'Atenção !!!' )

	else

		FWExecView(,'CNTAX002',MODEL_OPERATION_DELETE)

	end if

return
