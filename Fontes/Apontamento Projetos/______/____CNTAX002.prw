#Include "TOTVS.ch"
#Include "FWMVCDEF.ch"

User Function CNTAX002()

	Local oBrowse := FwLoadBrw("CNTAX002")

	oBrowse:Activate()

Return

Static Function BrowseDef()

	Local oBrowse := FwMBrowse():New()

	oBrowse:SetAlias("Z01")
	oBrowse:SetDescription("Recursos x Contratos")

	oBrowse:SetMenuDef("CNTAX002")

Return oBrowse


Static Function MenuDef()

Return FwMvcMenu( 'CNTAX002' )


Static Function ModelDef()

	Local oModel := MPFormModel():New("CNTAM002",, { | oModel | TudoOk( oModel ) } )
	Local oStru  := FwFormStruct(1, "Z01")

	oModel:AddFields("MASTER", NIL, oStru )

	oModel:SetDescription("Recursos x Contratos")

	oModel:GetModel("MASTER"):SetDescription("Recursos x Contratos")

Return oModel

Static Function ViewDef()

	Local oView := FwFormView():New()
	Local oStru := FwFormStruct(2, "Z01")
	Local oModel := FwLoadModel("CNTAX002")

	oView:SetModel(oModel)

	oView:AddField("VIEW", oStru, "MASTER")

	oView:CreateHorizontalBox("TELA" , 100)

	oView:SetOwnerView("VIEW", "TELA")

Return oView

static function TudoOk( oModel )

	local lRet := ExistChav( 'Z01', FwFldGet( 'Z01_RECURS' ) + FwFldGet( 'Z01_CONTRA' ), 3 )

return lRet
