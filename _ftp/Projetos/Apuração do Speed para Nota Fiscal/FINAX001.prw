#include 'totvs.ch'

user function FINAX001()

	if ! getMv( 'MX_FIAX001' )

		msgStop( 'Rotina não habilitada para esta Empresa/Filial: ' +;
			cEmpAnt + '/' + cFilAnt + ' - ' + FwSM0Util():getSM0FullName( cEmpAnt, cFilAnt) , 'Atenção !!!' )

		return

	end if

	if pergunte('FINAX001')

		private lMsErroAuto    := .F.
		private lMsHelpAuto    := .T.
		private lAutoErrNoFile := .T.

		private cPrefDe    := MV_PAR01
		private cPrefAte   := MV_PAR02
		private cNumDe     := MV_PAR03
		private cNumAte    := MV_PAR04
		private cParcDe    := MV_PAR05
		private cParcAte   := MV_PAR06
		private cTipoDe    := MV_PAR07
		private cTipoAte   := MV_PAR08
		private dEmissDe   := MV_PAR09
		private dEmissAte  := MV_PAR10
		private cFornecDe  := MV_PAR11
		private cLojaDe    := MV_PAR12
		private cFornecAte := MV_PAR13
		private cLojaAte   := MV_PAR14

		private cProduto   := MV_PAR15
		private cTes       := MV_PAR16
		private cCondPgto  := MV_PAR17
		private cSerie     := ''

		private cAlias     := getNextAlias()
		private aListFatur := {}
		private cErros     := ''
		private cNotas     := ''

		Sx5NumNota( @cSerie, GetMv( 'MV_TPNRNFS' ) )

		if pergunte( 'MT460A' )

			private lMostraLct := MV_PAR01 == 1
			private lAglutLct  := MV_PAR02 == 1
			private lContOnLin := MV_PAR03 == 1
			private lContCstOn := MV_PAR04 == 1

			MsgRun( 'Processando busca de Títulos...', 'Aguarde !!!', {|| makeQuery() } )

			if empty( aListFatur )

				msgInfo( 'Não foram localizados dados a serem processsados.', 'Atenção !!!' )

				return

			end if

			MsgRun( 'Gerando Faturamento...', 'Aguarde !!!', {|| makeNotas() } )

			lMsHelpAuto    := .F.
			lAutoErrNoFile := .F.

			if !Empty( cErros )

				autoGrLog( 'Ocorreram erros na geração do Faturamento' )
				autoGrLog( CRLF + PADR( '', 30, '-' ) + CRLF )
				autoGrLog( cErros )
				mostraErro()

			end if

			if !Empty( cNotas )

				autoGrLog( 'A seguir a lista de Pedidos/Notas Fiscais que foram geradas.' )
				autoGrLog( CRLF + PADR( '', 30, '-' ) + CRLF )
				autoGrLog( cNotas )
				mostraErro()

			end if

		end if

	end if

return

static function makeQuery()

	If Select( cAlias ) <> 0

		( cAlias )->( DbCloseArea() )

	EndIf

	BeginSql alias cAlias

		SELECT SE2.E2_FORNECE, SE2.E2_LOJA, SE2.E2_DECRESC, SE2.R_E_C_N_O_

		FROM %TABLE:SE2% SE2

		INNER JOIN %TABLE:SA2% SA2
		ON SA2.D_E_L_E_T_ = SE2.D_E_L_E_T_
		AND SA2.A2_COD = SE2.E2_FORNECE
		AND SA2.A2_LOJA = SE2.E2_LOJA

		WHERE SE2.E2_FILIAL = %XFILIAL:SE2%
		AND SE2.%NOTDEL%
		AND SE2.E2_DECRESC > 0
		AND SE2.E2_XPEDCOB = %EXP:SPACE(TAMSX3('E2_XPEDCOB')[1])%
		AND SE2.E2_PREFIXO BETWEEN %EXP:cPrefDe% AND %EXP:cPrefAte%
		AND SE2.E2_NUM BETWEEN %EXP:cNumDe% AND %EXP:cNumAte%
		AND SE2.E2_PARCELA BETWEEN %EXP:cParcDe% AND %EXP:cParcAte%
		AND SE2.E2_TIPO BETWEEN %EXP:cTipoDe% AND %EXP:cTipoAte%
		AND SE2.E2_EMISSAO BETWEEN %EXP:dTos(dEmissDe)% AND %EXP:dTos(dEmissAte)%
		AND SE2.E2_FORNECE BETWEEN %EXP:cFornecDe% AND %EXP:cFornecAte%
		AND SE2.E2_LOJA BETWEEN %EXP:cLojaDe% AND %EXP:cLojaAte%
		AND SA2.A2_FILIAL = %XFILIAL:SA2%
		AND SA2.A2_MSBLQL <> '1'

		ORDER BY SE2.E2_FORNECE, SE2.E2_LOJA		

	EndSql

	do while ( cAlias )->( !EOF() )

		( cAlias )->( MsgRun( 'Processando Cliente: ' + E2_FORNECE + '/' + E2_LOJA, 'Processando...',;
			{|| makeList() } ) )

		( cAlias )->( DbSkip() )

	end do

	( cAlias )->( DbCloseArea() )

return

static function makeList()

	local nPos := ( cAlias )->( ;
		aScan( aListFatur, {| item | item['CLIENTE'] == E2_FORNECE .And. item['LOJA'] == E2_LOJA } ) )

	if nPos == 0

		aAdd( aListFatur, jsonObject():New() )

		( cAlias )->( aTail( aListFatur )['CLIENTE'] := E2_FORNECE )
		( cAlias )->( aTail( aListFatur )['LOJA'] := E2_LOJA )
		( cAlias )->( aTail( aListFatur )['VALOR'] := 0 )
		( cAlias )->( aTail( aListFatur )['RECNOS'] := {} )

	endIf

	( cAlias )->( aTail( aListFatur )['VALOR'] += E2_DECRESC )
	( cAlias )->( aAdd( aTail( aListFatur )['RECNOS'], R_E_C_N_O_ ) )

return

static function makeNotas()

	local nX      := 0
	local cSc5Num := ''

	for nX:= 1 to len( aListFatur )

		if makePedido( @cSc5Num, aListFatur[ nX ] )

			MsgRun( 'Gerando Nota Fiscal : ' + aListFatur[nX]['CLIENTE'] + '/' + aListFatur[nX]['LOJA'],;
				'Aguarde...', {|| makeDocSda( cSc5Num ) } )

		end if

	next nX

return

static function makePedido( cSc5Num, jItem )

	local lRet     := .T.
	local aSc5     := {}
	local aSc6     := {{}}
	local cRecnos  := ''
	local nX       := 0

	aAdd( aSc5, { 'C5_TIPO'   , 'N'              , nil } )
	aAdd( aSc5, { 'C5_CLIENTE', jItem['CLIENTE'] , nil } )
	aAdd( aSc5, { 'C5_LOJACLI', jItem['LOJA']    , nil } )
	aAdd( aSc5, { 'C5_LOJAENT', jItem['LOJA']    , nil } )
	aAdd( aSc5, { 'C5_CONDPAG', cCondPgto        , nil } )

	aAdd( aTail( aSc6 ), { 'C6_ITEM'    , StrZero( 1, TamSx3('C6_ITEM')[1] ), nil } )
	aAdd( aTail( aSc6 ), { 'C6_PRODUTO' , cProduto                          , nil } )
	aAdd( aTail( aSc6 ), { 'C6_QTDVEN'  , 1                                 , nil } )
	aAdd( aTail( aSc6 ), { 'C6_QTDLIB'  , 1                                 , nil } )
	aAdd( aTail( aSc6 ), { 'C6_PRCVEN'  , jItem['VALOR']                    , nil } )
	aAdd( aTail( aSc6 ), { 'C6_VALOR'   , jItem['VALOR']                    , nil } )
	aAdd( aTail( aSc6 ), { 'C6_TES'     , cTes                              , nil } )

	MsgRun( 'Gerando Pedido de Vendas : ' + jItem['CLIENTE'] + '/' + jItem['LOJA'], 'Aguarde...', {|| MsExecAuto( { | a, b, c, d | MATA410( a, b, c, d ) }, aSc5, aSc6, 3, .F.) } )

	if lMsErroAuto

		lMsErroAuto := .F.
		lRet := .F.

		aEval( GetAutoGrLog(), { | item |  cErros += item + CRLF } )
		cErros += CRLF + PADR( '', 30, '-' ) + CRLF

		cSc5Num := ''

	else

		cSc5Num := SC5->C5_NUM

		for nX:= 1 to len( jItem['RECNOS'] )

			cRecnos += cValTochar( jItem['RECNOS'][nX] )

			if nX < len( jItem['RECNOS'] )

				cRecnos += ','

			end if

		next nX

		if 0 > TCSQLExec( "UPDATE " + RetSqlName( 'SE2' ) + " SET E2_XPEDCOB = '" + cSc5Num + "' WHERE R_E_C_N_O_ IN(" + cRecnos + ")")

			cErros += TCSQLError()
			cErros += CRLF + PADR( '', 30, '-' ) + CRLF

		end if

	endIf

return lRet

static function makeDocSda( cSc5Num )

	local aPvlDocS := {}

	DbSelectArea( 'SC5' )
	SC5->( DbSetOrder( 1 ) )
	SC5->( DbSeek( xFilial( 'SC5' ) + cSc5Num ) )

	DbSelectArea( 'SC6' )
	SC6->( DbSetOrder( 1 ) )
	SC6->( DbSeek( xFilial( 'SC6' ) + SC5->C5_NUM ) )

	Pergunte( 'MT460A', .F. )

	While SC6->( !Eof() .And. C6_FILIAL == xFilial('SC6') ) .And. SC6->C6_NUM == SC5->C5_NUM

		SC9->(DbSetOrder(1))
		SC9->(MsSeek(xFilial("SC9")+SC6->(C6_NUM+C6_ITEM))) //FILIAL+NUMERO+ITEM

		SE4->(DbSetOrder(1))
		SE4->(MsSeek(xFilial("SE4")+SC5->C5_CONDPAG) )  //FILIAL+CONDICAO PAGTO

		SB1->(DbSetOrder(1))
		SB1->(MsSeek(xFilial("SB1")+SC6->C6_PRODUTO))    //FILIAL+PRODUTO

		SB2->(DbSetOrder(1))
		SB2->(MsSeek(xFilial("SB2")+SC6->(C6_PRODUTO+C6_LOCAL))) //FILIAL+PRODUTO+LOCAL

		SF4->(DbSetOrder(1))
		SF4->(MsSeek(xFilial("SF4")+SC6->C6_TES))   //FILIAL+TES

		nPrcVen := SC9->C9_PRCVEN
		If ( SC5->C5_MOEDA <> 1 )
			nPrcVen := xMoeda(nPrcVen,SC5->C5_MOEDA,1,dDataBase)
		EndIf

		If AllTrim(SC9->C9_BLEST) == "" .And. AllTrim(SC9->C9_BLCRED) == ""
			AAdd(aPvlDocS,{ SC9->C9_PEDIDO,;
				SC9->C9_ITEM,;
				SC9->C9_SEQUEN,;
				SC9->C9_QTDLIB,;
				nPrcVen,;
				SC9->C9_PRODUTO,;
				.F.,;
				SC9->(RecNo()),;
				SC5->(RecNo()),;
				SC6->(RecNo()),;
				SE4->(RecNo()),;
				SB1->(RecNo()),;
				SB2->(RecNo()),;
				SF4->(RecNo())})
		EndIf

		SC6->( DbSkip() )

	end

	if !Empty( aPvlDocS )

		SetFunName("MATA461")

		cDoc := MaPvlNfs(	/*aPvlNfs*/         aPvlDocS,;   // 01 - Array com os itens a serem gerados
							/*cSerieNFS*/       cSerie,;     // 02 - Serie da Nota Fiscal
							/*lMostraCtb*/      lMostraLct,; // 03 - Mostra Lançamento Contábil
							/*lAglutCtb*/       lAglutLct,;  // 04 - Aglutina Lançamento Contábil
							/*lCtbOnLine*/      lContOnLin,; // 05 - Contabiliza On-Line
							/*lCtbCusto*/       lContCstOn,; // 06 - Contabiliza Custo On-Line
							/*lReajuste*/       .F.,;        // 07 - Reajuste de preço na Nota Fiscal
							/*nCalAcrs*/        0,;          // 08 - Tipo de Acréscimo Financeiro
							/*nArredPrcLis*/    0,;          // 09 - Tipo de Arredondamento
							/*lAtuSA7*/         .T.,;        // 10 - Atualiza Amarração Cliente x Produto
							/*lECF*/            .F.,;        // 11 - Cupom Fiscal
							/*cEmbExp*/         '',;         // 12 - Número do Embarque de Exportação
							/*bAtuFin*/         {||},;       // 13 - Bloco de Código para complemento de atualização dos títulos financeiros
							/*bAtuPGerNF*/      {||},;       // 14 - Bloco de Código para complemento de atualização dos dados após a geração da Nota Fiscal
							/*bAtuPvl*/         {||},;       // 15 - Bloco de Código de atualização do Pedido de Venda antes da geração da Nota Fiscal
							/*bFatSE1*/         {|| .T. },;  // 16 - Bloco de Código para indicar se o valor do Titulo a Receber será gravado no campo F2_VALFAT quando o parâmetro MV_TMSMFAT estiver com o valor igual a "2".
							/*dDataMoe*/        dDatabase,;  // 17 - Data da cotação para conversão dos valores da Moeda do Pedido de Venda para a Moeda Forte
							/*lJunta*/          .F.)         // 18 - Aglutina Pedido Iguaisf
	end if


	cNotas += "Pedido: " + cSc5Num + ' / ' + "NF: " + cValToChar( cDoc ) + CRLF

return
