#Include "TOTVS.ch"
#Include "FWMVCDEF.ch"

User Function CNTAX000()

	Local oBrowse := FwLoadBrw("CNTAX000")

	oBrowse:Activate()

Return

Static Function BrowseDef()

	Local oBrowse := FwMBrowse():New()

	oBrowse:SetAlias("SZZ")
	oBrowse:SetDescription("Recursos")

	oBrowse:SetMenuDef("CNTAX000")

Return oBrowse


Static Function MenuDef()

Return FwMvcMenu( 'CNTAX000' )


Static Function ModelDef()

	Local oModel := MPFormModel():New("CNTAM000")
	Local oStru  := FwFormStruct(1, "SZZ")

	oModel:AddFields("MASTER", NIL, oStru )

	oModel:SetDescription("Recursos")

	oModel:GetModel("MASTER"):SetDescription("Recursos")

Return oModel

Static Function ViewDef()

	Local oView := FwFormView():New()
	Local oStru := FwFormStruct(2, "SZZ")
	Local oModel := FwLoadModel("CNTAX000")

	oView:SetModel(oModel)

	oView:AddField("VIEW", oStru, "MASTER")

	oView:CreateHorizontalBox("TELA" , 100)

	oView:SetOwnerView("VIEW", "TELA")

Return oView
