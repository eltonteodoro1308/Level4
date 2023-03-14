#Include "TOTVS.ch"
#Include "FWMVCDEF.ch"

User Function CNTAX001()

	Local oBrowse := FwLoadBrw("CNTAX001")

	oBrowse:Activate()

Return

Static Function BrowseDef()

	Local oBrowse := FwMBrowse():New()

	oBrowse:SetAlias("SZA")
	oBrowse:SetDescription("Cadastro de Tarefas")

	oBrowse:SetMenuDef("CNTAX001")

Return oBrowse


Static Function MenuDef()

Return FwMvcMenu( 'CNTAX001' )


Static Function ModelDef()

	Local oModel := MPFormModel():New("CNTAM001")
	Local oStru  := FwFormStruct(1, "SZA")

	oModel:AddFields("MASTER", NIL, oStru )

	oModel:SetDescription("Cadastro de Tarefas")

	oModel:GetModel("MASTER"):SetDescription("Cadastro de Tarefas")

Return oModel

Static Function ViewDef()

	Local oView := FwFormView():New()
	Local oStru := FwFormStruct(2, "SZA")
	Local oModel := FwLoadModel("CNTAX001")

	oView:SetModel(oModel)

	oView:AddField("VIEW", oStru, "MASTER")

	oView:CreateHorizontalBox("TELA" , 100)

	oView:SetOwnerView("VIEW", "TELA")

	oView:AddUserButton( 'Define Ctr Recurso', '', { | oView | u_setCtRec()} )
	oView:AddUserButton( 'Define Ctr Cliente', '', { | oView | u_setCtCli()} )

Return oView

user function setCtRec()

	local aArea := GetArea()
	local cAlias := GetNextAlias()

	DbSelectArea('SA2')

	if ConPad1(, , , 'SA2')

		If Select(cAlias) <> 0

			(cAlias)->(DbCloseArea())

		EndIf

		BeginSql alias cAlias

			SELECT 
			CN9.CN9_NUMERO CONTRATO,
			CN9.CN9_REVISA REVISAO,
			CNA.CNA_NUMERO PLANILHA,
			CNA.CNA_FORNEC FORNECEDOR,
			CNA.CNA_LJFORN LOJA,
			SA2.A2_NOME NOME_FORNECEDOR,
			CNB.CNB_ITEM ITEM,
			CNB.CNB_PRODUT PRODUTO,
			CNB.CNB_DESCRI DESCRICAO_PRODUTO
			
			FROM %TABLE:CNB% CNB
			
			INNER JOIN %TABLE:CNA% CNA
			ON CNB.CNB_FILIAL = CNA.CNA_FILIAL
			AND CNB.CNB_CONTRA = CNA.CNA_CONTRA
			AND CNB.CNB_REVISA = CNA.CNA_REVISA
			AND CNB.CNB_NUMERO = CNA.CNA_NUMERO
			AND CNB.D_E_L_E_T_ = CNA.D_E_L_E_T_
			
			INNER JOIN %TABLE:CN9% CN9
			ON CNA.CNA_FILIAL = CN9.CN9_FILIAL
			AND CNA.CNA_CONTRA = CN9.CN9_NUMERO
			AND CNA.CNA_REVISA = CN9.CN9_REVISA
			AND CNA.D_E_L_E_T_ = CN9.D_E_L_E_T_
			
			INNER JOIN %TABLE:SA2% SA2
			ON SA2.A2_COD = CNA.CNA_FORNEC
			AND SA2.A2_LOJA = CNA.CNA_LJFORN
			AND SA2.D_E_L_E_T_ = CNA.D_E_L_E_T_
			
			WHERE CNB.%NOTDEL%
			AND CNB.CNB_FILIAL = %XFILIAL:CNB%
			AND CN9.CN9_SITUAC = '05'
			AND CN9.CN9_TPCTO = %EXP:SuperGetMv('MX_TPCTCP')%
			AND CNA.CNA_TIPPLA = %EXP:SuperGetMv('MX_TPPLCP')%
			AND SA2.A2_FILIAL = %XFILIAL:SA2%
			AND SA2.A2_COD = %EXP:SA2->A2_COD% 
			AND SA2.A2_LOJA = %EXP:SA2->A2_LOJA% 

		EndSql


		if ( cAlias )->( EOF() )

			Help(,,"CNTAX001",,"Não há contratos nas condições possíveis para o fornecedor.",;
				1,0,,,,,,{"Os contratos vinculados aos fornecedores deverão ser do tipo definido na parâmetro MX_TPCTCP e a ",;
				"a planilha deverá ser do tipo definido no parâmetro MX_TPPLCP"})

		else

			showResult( cAlias, '{ || selCtrRec( oBrowse ) }' )

		end if

		(cAlias)->(DbCloseArea())

	end if

	RestArea( aArea )

return

user function setCtCli()

	local aArea := GetArea()
	local cAlias := GetNextAlias()

	DbSelectArea('SA1')

	if ConPad1(, , , 'SA1')

		If Select(cAlias) <> 0

			(cAlias)->(DbCloseArea())

		EndIf

		BeginSql alias cAlias

			SELECT 

			CN9.CN9_NUMERO CONTRATO,
			CN9.CN9_REVISA REVISAO,
			CNA.CNA_NUMERO PLANILHA,
			CNA.CNA_CLIENT CLIENTE,
			CNA.CNA_LOJACL LOJA,
			SA1.A1_NOME NOME_CLIENTE,
			CNB.CNB_ITEM ITEM,
			CNB.CNB_PRODUT PRODUTO,
			CNB.CNB_DESCRI DESCRICAO_PRODUTO

			FROM %TABLE:CNB% CNB

			INNER JOIN %TABLE:CNA% CNA
			ON CNB.CNB_FILIAL = CNA.CNA_FILIAL
			AND CNB.CNB_CONTRA = CNA.CNA_CONTRA
			AND CNB.CNB_REVISA = CNA.CNA_REVISA
			AND CNB.CNB_NUMERO = CNA.CNA_NUMERO
			AND CNB.D_E_L_E_T_ = CNA.D_E_L_E_T_

			INNER JOIN %TABLE:CN9% CN9
			ON CNA.CNA_FILIAL = CN9.CN9_FILIAL
			AND CNA.CNA_CONTRA = CN9.CN9_NUMERO
			AND CNA.CNA_REVISA = CN9.CN9_REVISA
			AND CNA.D_E_L_E_T_ = CN9.D_E_L_E_T_

			INNER JOIN %TABLE:SA1% SA1
			ON SA1.A1_COD = CNA.CNA_CLIENT
			AND SA1.A1_LOJA = CNA.CNA_LOJACL
			AND SA1.D_E_L_E_T_ = CNA.D_E_L_E_T_

			WHERE CNB.%NOTDEL%
			AND CNB.CNB_FILIAL = %XFILIAL:CNB%
			AND CN9.CN9_SITUAC = '05'
			*// AND CN9.CN9_TPCTO = %EXP:SuperGetMv('MX_TPCTVD')%
			*// AND CNA.CNA_TIPPLA = %EXP:SuperGetMv('MX_TPPLVD')%
			AND SA1.A1_FILIAL = %XFILIAL:SA1%
			AND SA1.A1_COD = %EXP:SA1->A1_COD%
			AND SA1.A1_LOJA = %EXP:SA1->A1_LOJA%

		EndSql

		if ( cAlias )->( EOF() )

			Help(,,"CNTAX001",,"Não há contratos nas condições possíveis para o cliente.",;
				1,0,,,,,,{"Os contratos vinculados aos clientes deverão ser do tipo definido na parâmetro MX_TPCTVD e a ",;
				"a planilha deverá ser do tipo definido no parâmetro MX_TPPLVD"})

		else

			showResult( cAlias, '{ || selCtrCli( oBrowse ) }' )

		end if

		(cAlias)->(DbCloseArea())

	end if

	RestArea( aArea )

return

static function selCtrRec( oBrowse )

	local oModel := FwModelActive()
	local oDlg   := oBrowse:oParent

	oModel := oModel:GetModel('MASTER')

	oModel:loadValue('ZA_RECCTR' , oBrowse:aArray[oBrowse:nAt][aScan(oBrowse:aHeaders, 'CONTRATO'          )] )
	oModel:loadValue('ZA_RECRVCT', oBrowse:aArray[oBrowse:nAt][aScan(oBrowse:aHeaders, 'REVISAO'           )] )
	oModel:loadValue('ZA_RECPLAN', oBrowse:aArray[oBrowse:nAt][aScan(oBrowse:aHeaders, 'PLANILHA'          )] )
	oModel:loadValue('ZA_RECITEM', oBrowse:aArray[oBrowse:nAt][aScan(oBrowse:aHeaders, 'ITEM'              )] )
	oModel:loadValue('ZA_FORNECE', oBrowse:aArray[oBrowse:nAt][aScan(oBrowse:aHeaders, 'FORNECEDOR'        )] )
	oModel:loadValue('ZA_FORNELJ', oBrowse:aArray[oBrowse:nAt][aScan(oBrowse:aHeaders, 'LOJA'              )] )
	oModel:loadValue('ZA_FORNNOM', oBrowse:aArray[oBrowse:nAt][aScan(oBrowse:aHeaders, 'NOME_FORNECEDOR'   )] )
	oModel:loadValue('ZA_CPRODCP', oBrowse:aArray[oBrowse:nAt][aScan(oBrowse:aHeaders, 'PRODUTO'           )] )
	oModel:loadValue('ZA_NPRODCP', oBrowse:aArray[oBrowse:nAt][aScan(oBrowse:aHeaders, 'DESCRICAO_PRODUTO' )] )

	oDlg:end()

return

Static Function selCtrCli( oBrowse )

	local oModel := FwModelActive()
	local oDlg   := oBrowse:oParent

	oModel := oModel:GetModel('MASTER')

	oModel:loadValue('ZA_CLICTR' , oBrowse:aArray[oBrowse:nAt][aScan(oBrowse:aHeaders, 'CONTRATO'          )] )
	oModel:loadValue('ZA_CLIRVCT', oBrowse:aArray[oBrowse:nAt][aScan(oBrowse:aHeaders, 'REVISAO'           )] )
	oModel:loadValue('ZA_CLIPLAN', oBrowse:aArray[oBrowse:nAt][aScan(oBrowse:aHeaders, 'PLANILHA'          )] )
	oModel:loadValue('ZA_CLIITEM', oBrowse:aArray[oBrowse:nAt][aScan(oBrowse:aHeaders, 'ITEM'              )] )
	oModel:loadValue('ZA_CLIENTE', oBrowse:aArray[oBrowse:nAt][aScan(oBrowse:aHeaders, 'CLIENTE'           )] )
	oModel:loadValue('ZA_CLIENLJ', oBrowse:aArray[oBrowse:nAt][aScan(oBrowse:aHeaders, 'LOJA'              )] )
	oModel:loadValue('ZA_CLINOM' , oBrowse:aArray[oBrowse:nAt][aScan(oBrowse:aHeaders, 'NOME_CLIENTE'      )] )
	oModel:loadValue('ZA_CPRODVD', oBrowse:aArray[oBrowse:nAt][aScan(oBrowse:aHeaders, 'PRODUTO'           )] )
	oModel:loadValue('ZA_NPRODVD', oBrowse:aArray[oBrowse:nAt][aScan(oBrowse:aHeaders, 'DESCRICAO_PRODUTO' )] )

	oDlg:end()

return

static function showResult( cAlias, cSelect )

	Local oDfSzDlg  := FwDefSize():New( .F. )
	Local oDfSzBtn  := FwDefSize():New( .F. )
	Local oDlg      := Nil
	Local oBtnClose := Nil
	Local oBrowse   := Nil
	Local aHeaders  := {}
	Local aLinesBrw := {}
	Local bLinesBrw := nil

	oDfSzDlg:AddObject ( 'oButtons', 000, 015, .T., .F. )
	oDfSzDlg:AddObject ( 'oBrowse' , 000, 000, .T., .T. )
	oDfSzDlg:Process()

	oDfSzBtn:AddObject ( 'oBtnClose', 050, 015, .F., .F. )
	oDfSzBtn:lLateral := .T.
	oDfSzBtn:Process()

	oDlg := MsDialog():New(;
	/* nTop         */ oDfSzDlg:aWindSize[ 1 ] ,;
	/* nLeft        */ oDfSzDlg:aWindSize[ 2 ] ,;
	/* nBottom      */ oDfSzDlg:aWindSize[ 3 ] ,;
	/* nRight       */ oDfSzDlg:aWindSize[ 4 ] ,;
	/* cCaption     */                  cAlias ,;
	/* uParam6      */                         ,;
	/* uParam7      */                         ,;
	/* uParam8      */                         ,;
	/* uParam9      */                         ,;
	/* nClrText     */                         ,;
	/* nClrBack     */                         ,;
	/* uParam12     */                         ,;
	/* oWnd         */                         ,;
	/* lPixel       */                     .T. ,;
	/* uParam15     */                         ,;
	/* uParam16     */                         ,;
	/* uParam17     */                         ,;
	/* lTransparent */                          )

	oBtnClose := TButton():New(;
	/* nRow     */  oDfSzBtn:GetDimension( 'oBtnClose', 'LININI' ) ,;
	/* nCol     */  oDfSzBtn:GetDimension( 'oBtnClose', 'COLINI' ) ,;
	/* cCaption */                                        'FECHAR' ,;
	/* oWnd     */                                            oDlg ,;
	/* bAction  */                               { || oDlg:End() } ,;
	/* nWidth   */  oDfSzBtn:GetDimension( 'oBtnClose', 'XSIZE'  ) ,;
	/* nHeight  */  oDfSzBtn:GetDimension( 'oBtnClose', 'YSIZE'  ) ,;
	/* uParam8  */                                                 ,;
	/* oFont    */                                                 ,;
	/* uParam10 */                                                 ,;
	/* lPixel   */                                             .T. ,;
	/* uParam12 */                                                 ,;
	/* uParam13 */                                                 ,;
	/* uParam14 */                                                 ,;
	/* bWhen    */                                                 ,;
	/* uParam16 */                                                 ,;
	/* uParam17 */                                                  )

	oBtnClose:cToolTip := "Fecha a Janela."

	MsgRun ( 'Montando Browse de Exibição ...', 'Aguarde ...',;
		{ || makeLstBrw( cAlias, aHeaders, aLinesBrw, @bLinesBrw ) } )

	bLinesBrw := &( bLinesBrw )

	oBrowse := TWBrowse():New(;
	/* nRow       */ oDfSzDlg:GetDimension( 'oBrowse', 'LININI' ) ,;
	/* nCol       */ oDfSzDlg:GetDimension( 'oBrowse', 'COLINI' ) ,;
	/* nWidth     */ oDfSzDlg:GetDimension( 'oBrowse', 'XSIZE'  ) ,;
	/* nHeight    */ oDfSzDlg:GetDimension( 'oBrowse', 'YSIZE'  ) ,;
	/* bLine      */                                              ,;
	/* aHeaders   */                                     aHeaders ,;
	/* aColSizes  */                                              ,;
	/* oDlg       */                                         oDlg ,;
	/* cField     */                                              ,;
	/* uValue1    */                                              ,;
	/* uValue2    */                                              ,;
	/* bChange    */                                              ,;
	/* bLDblClick */                                              ,;
	/* bRClick    */                                              ,;
	/* oFont      */                                              ,;
	/* oCursor    */                                              ,;
	/* nClrFore   */                                              ,;
	/* nClrBack   */                                              ,;
	/* cMsg       */                                              ,;
	/* uParam20   */                                              ,;
	/* cAlias     */                                              ,;
	/* lPixel     */                                          .T. ,;
	/* bWhen      */                                              ,;
	/* uParam24   */                                              ,;
	/* bValid     */                                              ,;
	/* lHScroll   */                                          .T. ,;
	/* lVScroll   */                                          .T.  )

	oBrowse:setArray( aLinesBrw )
	oBrowse:bLine    := bLinesBrw
	oBrowse:bLDblClick := &(cSelect)

	oDlg:Activate(,,,.T.)

	aLinesBrw := nil
	aHeaders := nil

return

static function makeLstBrw( cAlias, aHeaders, aLinesBrw, bLinesBrw )

	Local nX   := 0
	Local aAux := {}

	( cAlias )->( DbGoTop() )

	While ! ( cAlias )->( Eof() )

		For nX := 1 To ( cAlias )->( FCount() )

			aAdd( aAux, ( cAlias )->&( FieldName( nX ) ) )

		Next

		aAdd( aLinesBrw, aClone( aAux ) )

		aSize( aAux, 0 )

		( cAlias )->( DbSkip() )

	End

	bLinesBrw := '{||{'

	For nX := 1 To ( cAlias )->( FCount() )

		aAdd( aHeaders, ( cAlias )->( FieldName( nX ) ) )

		bLinesBrw += 'aLinesBrw[ oBrowse:nAt, ' + cValToChar( nX ) + ']'

		If nX < ( cAlias )->( FCount() )

			bLinesBrw += ','

		EndIf

	Next

	bLinesBrw += '}}'

return
