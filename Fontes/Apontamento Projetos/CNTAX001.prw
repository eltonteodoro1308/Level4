#Include "TOTVS.ch"
#Include "FWMVCDEF.ch"

User Function CNTAX001()

	Local oBrowse := FwLoadBrw("CNTAX001")

	oBrowse:Activate()

Return

Static Function BrowseDef()

	Local oBrowse := FwMBrowse():New()

	oBrowse:SetAlias("Z00")
	oBrowse:SetDescription("Cadastro de Recursos")

	oBrowse:SetMenuDef("CNTAX001")

Return oBrowse


Static Function MenuDef()

Return FwMvcMenu( 'CNTAX001' )


Static Function ModelDef()

	Local oModel := MPFormModel():New("CNTAM001")
	Local oStru  := FwFormStruct(1, "Z00")

	oModel:AddFields("MASTER", NIL, oStru )

	oModel:SetDescription("Cadastro de Recursos")

	oModel:GetModel("MASTER"):SetDescription("Cadastro de Recursos")

Return oModel

Static Function ViewDef()

	Local oView := FwFormView():New()
	Local oStru := FwFormStruct(2, "Z00")
	Local oModel := FwLoadModel("CNTAX001")

	oView:SetModel(oModel)

	oView:AddField("VIEW", oStru, "MASTER")

	oView:CreateHorizontalBox("TELA" , 100)

	oView:SetOwnerView("VIEW", "TELA")

Return oView
