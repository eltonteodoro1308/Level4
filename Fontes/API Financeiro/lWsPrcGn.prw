#Include "TOTVS.ch"
#Include "FWMVCDEF.ch"

/*/{Protheus.doc} lWsPrcGn
Rotina de consulta e limpeza de log´s de processamento recebidos pelo web service de integração com o faturamento 
@type function
@version 12.1.33 
@author elton.alves@totvs.com.br
@since 25/03/2022
/*/
User Function lWsPrcGn()

	Local oBrowse := FwLoadBrw("lWsPrcGn")

	oBrowse:Activate()

Return

/*/{Protheus.doc} BrowseDef
Monta a tela de browse da rotina
@type function
@version 12.1,33 
@author elton.alves@totvs.com.br
@since 25/03/2022
@return object, Objeto do Browse
/*/
Static Function BrowseDef()

	Local oBrowse := FwMBrowse():New()

	oBrowse:SetAlias("SZ1")
	oBrowse:SetDescription("Log de Processamentos")

	oBrowse:AddLegend("Z1_STATUS=='0'", "GRAY"  , "Não Processado"         )
	oBrowse:AddLegend("Z1_STATUS=='1'", "GREEN" , "Processado com Sucesso" )
	oBrowse:AddLegend("Z1_STATUS=='2'", "RED"   , "Processado com erros"   )

	oBrowse:SetMenuDef("lWsPrcGn")

Return oBrowse

/*/{Protheus.doc} MenuDef
Monta o array com a lista de rotinas da rotina
@type function
@version 12.1,33 
@author elton.alves@totvs.com.br
@since 25/03/2022
@return array, Array com os itens de menu
/*/
Static Function MenuDef()

	Local aRotina := {}

	ADD OPTION aRotina TITLE 'Visualizar'       ACTION 'VIEWDEF.lWsPrcGn' OPERATION 2 ACCESS 0
	ADD OPTION aRotina TITLE 'Limpar Registros' ACTION 'U_DEL_SZ1'     OPERATION 9 ACCESS 0
	ADD OPTION aRotina TITLE 'Reprocessa'       ACTION 'U_REP_SZ1'     OPERATION 9 ACCESS 0

Return aRotina

/*/{Protheus.doc} ModelDef
Monta o modelo de dados da roina
@type function
@version 12.1,.33 
@author elton.alves@totvs.com.br
@since 25/03/2022
@return object, Objeto do modelo de dados
/*/
Static Function ModelDef()

	Local oModel := MPFormModel():New("mWsPrcGn")

	Local oStruSZ1 := FwFormStruct(1, "SZ1")

	oModel:AddFields("SZ1MASTER", NIL, oStruSZ1)

	oModel:SetDescription("Processamentos")

	oModel:GetModel("SZ1MASTER"):SetDescription("Dados dos Processamentos")

Return oModel

/*/{Protheus.doc} ViewDef
Monta o objeto da view do modelo de dados
@type function
@version 12.1.33 
@author elton.alves@totvs.com.br
@since 25/03/2022
@return object, Objeto da view
/*/
Static Function ViewDef()

	Local oView := FwFormView():New()

	Local oStruSZ1 := FwFormStruct(2, "SZ1")

	Local oModel := FwLoadModel("lWsPrcGn")

	oView:SetModel(oModel)

	oView:AddField("VIEW_SZ1", oStruSZ1, "SZ1MASTER")

	oView:CreateHorizontalBox("TELA" , 100)

	oView:SetOwnerView("VIEW_SZ1", "TELA")

Return oView

/*/{Protheus.doc} DEL_SZ1
Rotina que exclui log´s dos registros considerando a data de inclusão, processamento e status
@type function
@version 12.1.33 
@author elton.alves@totvs.com.br
@since 25/03/2022
/*/
user function DEL_SZ1()

	local cCommand   := ''
	local cDtIncInic := ''
	local cDtIncFim  := ''
	local cDtPrcInic := ''
	local cDtPrcFim  := ''
	local lDelNoProc := .F.

	local cInList    := '1/2'
	local nStatus    := 0

	if Pergunte( 'LWSPRCGN', .T. )

		cDtIncInic := DtoS( MV_PAR01 )
		cDtIncFim  := DtoS( MV_PAR02 )
		cDtPrcInic := DtoS( MV_PAR03 )
		cDtPrcFim  := DtoS( MV_PAR04 )
		lDelNoProc := MV_PAR05 == 1

		cCommand += " DELETE "  + RetSqlName( 'SZ1' )
		cCommand += " WHERE Z1_DATAINC BETWEEN '" + cDtIncInic  + "' AND '" + cDtIncFim + "' "
		cCommand += " AND   Z1_DATAPRC BETWEEN '" + cDtPrcInic  + "' AND '" + cDtPrcFim + "' "

		if lDelNoProc

			cCommand += " OR Z1_DATAPRC = '" + Space( TamSx3( "Z1_DATAPRC" )[1] ) + "' "

			cInList := '0/' + cInList

		end if

		cCommand += " AND Z1_STATUS IN " + FormatIn( cInList, '/' )

		nStatus := TCSqlExec( cCommand )

		if nStatus < 0

			ApMsgStop( 'Um erro impediu que a limpeza fosse executada.' )

			autoGrLog( TCSQLError() )

			mostraErro()

		else

			ApMsgInfo( 'Limpeza executada com sucesso.' )

		end if

	end if

return

/*/{Protheus.doc} REP_SZ1
Permite o reprocessamento de uma requsição processada com erro.
@type function
@version  12.1.33
@author elton.alves@totvs.com.br
@since 16/05/2022
/*/
user function REP_SZ1()

	if SZ1->Z1_STATUS == '2'

		MsgRun("Aguarde...", "Reprocessando rerquisição.", {|| U_pWsPrcGn( SZ1->Z1_UUID ) })

	else

		ApMsgAlert( 'O reprocessamento só é permitido para requisições com erro. ', 'Atenção')

	end if

return
